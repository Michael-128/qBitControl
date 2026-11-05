//
//  TorrentListHelperViewModel.swift
//  qBitControl
//

import SwiftUI
import Combine

/// Everything the torrent list's filter and sort depend on, snapshotted on the main actor
/// so the work can run off it.
struct TorrentListInputs: Sendable {
    let torrents: [Torrent]
    let query: String
    let filter: TorrentFilterOption
    let category: String
    let tag: String
    let sort: TorrentSortOption
    let reverse: Bool
    let filterStrategy: any TorrentFilterStrategy
}

struct TorrentListResult: Sendable, Equatable {
    /// All torrents, sorted.
    let sorted: [Torrent]
    /// The sorted torrents that match the search query, status filter, category and tag.
    let filtered: [Torrent]
}

@MainActor
class TorrentListHelperViewModel: ObservableObject {
    let defaults = UserDefaults.standard
    private let client: TorrentClientProtocol
    private let filterStrategy: TorrentFilterStrategy
    
    @Published public var torrents: [Torrent] = []
    
    @Published public var searchQuery: String = ""
    @Published public var sort: TorrentSortOption = .name
    @Published public var reverse: Bool = false
    @Published public var filter: TorrentFilterOption = .all
    @Published public var category: String = "All"
    @Published public var tag: String = "All"
    
    @Published public var isTorrentAddView: Bool = false
    @Published public var isSelectionMode: Bool = false
    
    @Published public var selectedTorrents: Set<String> = Set()
    
    @Published public var filteredTorrents: [Torrent] = []
    
    @Published var scenePhase: ScenePhase = .active
    @Published var isDeleteAlert: Bool = false
    @Published var isDeleteSelectedAlert: Bool = false
    
    @Published var isAlertClearCompleted: Bool = false
    @Published var isFilterView: Bool = false
    @Published var alertIdentifier: AlertIdentifier?
    @Published var sheetIdentifier: SheetIdentifier?
    
    private var pollingTask: Task<Void, Never>?
    
    /// Filters and sorts the list. Runs off the main actor.
    private let listComputation: @Sendable (TorrentListInputs) -> TorrentListResult
    /// The latest scheduled list update. Older updates are cancelled and their results dropped.
    private(set) var listUpdateTask: Task<Void, Never>?
    /// Incremented for every scheduled list update; a result is only published if its
    /// generation is still the latest, so an older, slower computation can never
    /// overwrite a newer one.
    private var listGeneration: UInt64 = 0
    
    var hash = ""
    private var cancellables = Set<AnyCancellable>()
    
    public var categoryName: String {
        if(category == "All") {
            return NSLocalizedString("All", comment: "Pause All/Resume All")
        }
        return category.capitalized
    }
    
    init(
        client: TorrentClientProtocol,
        filterStrategy: TorrentFilterStrategy = QBitTorrentFilterStrategy(),
        listComputation: (@Sendable (TorrentListInputs) -> TorrentListResult)? = nil
    ) {
        self.client = client
        self.filterStrategy = filterStrategy
        self.listComputation = listComputation ?? { TorrentListHelperViewModel.computeLists($0) }
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        Publishers.CombineLatest4(
            qBitData.shared.cacheManager.$torrents,
            $searchQuery,
            $filter,
            Publishers.CombineLatest4($category, $tag, $sort, $reverse)
        )
        .sink { [weak self] dict, query, filterVal, otherParams in
            guard let self = self else { return }
            let (cat, tag, sortVal, rev) = otherParams
            
            self.scheduleListUpdate(TorrentListInputs(
                torrents: Array(dict.values),
                query: query,
                filter: filterVal,
                category: cat,
                tag: tag,
                sort: sortVal,
                reverse: rev,
                filterStrategy: self.filterStrategy
            ))
        }
        .store(in: &cancellables)
    }
    
    /// Filters and sorts on a background thread, then publishes on the main actor.
    /// Inputs that change in quick succession (several properties set in one pass, or a
    /// poll landing while the user types) cancel the pending update, so only the latest
    /// one is computed and published.
    private func scheduleListUpdate(_ inputs: TorrentListInputs) {
        listGeneration &+= 1
        let generation = listGeneration
        let compute = listComputation
        
        listUpdateTask?.cancel()
        listUpdateTask = Task { [weak self] in
            guard !Task.isCancelled else { return }
            let result = await Task.detached(priority: .userInitiated) {
                compute(inputs)
            }.value
            guard let self, !Task.isCancelled, generation == self.listGeneration else { return }
            // Skip no-op assignments so SwiftUI doesn't re-diff an unchanged list.
            if self.torrents != result.sorted { self.torrents = result.sorted }
            if self.filteredTorrents != result.filtered { self.filteredTorrents = result.filtered }
        }
    }
    
    /// Waits until the most recently scheduled list update has been applied (or dropped
    /// because a newer one replaced it, in which case it waits for that one instead).
    func waitForListUpdate() async {
        while let task = listUpdateTask {
            await task.value
            if task == listUpdateTask { return }
        }
    }
    
    /// Sorts once, then filters the sorted list (filter preserves order).
    nonisolated static func computeLists(_ inputs: TorrentListInputs) -> TorrentListResult {
        let sorted = sortTorrents(inputs.torrents, sortVal: inputs.sort, reverseVal: inputs.reverse)
        let filtered = filterTorrents(
            sorted,
            using: inputs.filterStrategy,
            query: inputs.query,
            filterVal: inputs.filter,
            categoryVal: inputs.category,
            tagVal: inputs.tag
        )
        return TorrentListResult(sorted: sorted, filtered: filtered)
    }
    
    // Pure functions with no actor state, so they can run off the main actor.
    nonisolated static func filterTorrents(
        _ allTorrents: [Torrent],
        using filterStrategy: TorrentFilterStrategy,
        query: String,
        filterVal: TorrentFilterOption,
        categoryVal: String,
        tagVal: String
    ) -> [Torrent] {
        let lowercasedQuery = query.lowercased()
        return allTorrents.filter { torrent in
            // Filter by status (filterVal)
            if !filterStrategy.matches(torrent, filter: filterVal) { return false }
            
            // Filter by Category
            if categoryVal != "All" {
                if categoryVal == "Uncategorized" {
                    if torrent.category != "" && torrent.category != "Uncategorized" { return false }
                } else {
                    if torrent.category != categoryVal { return false }
                }
            }
            
            // Filter by Tag
            if tagVal != "All" {
                if tagVal == "" || tagVal == "Untagged" {
                    if torrent.tags != "" && torrent.tags != "Untagged" { return false }
                } else {
                    let tagsList = torrent.tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    if !tagsList.contains(tagVal) { return false }
                }
            }
            
            // Filter by Search Query
            if query != "" {
                if !torrent.name.lowercased().contains(lowercasedQuery) { return false }
            }
            
            return true
        }
    }
    
    nonisolated static func sortTorrents(_ torrents: [Torrent], sortVal: TorrentSortOption, reverseVal: Bool) -> [Torrent] {
        var list = torrents
        list.sort { a, b in
            let isOrdered: Bool
            switch sortVal {
            case .size:
                isOrdered = a.size < b.size
            case .totalSize:
                isOrdered = a.total_size < b.total_size
            case .amountLeft:
                isOrdered = a.amount_left < b.amount_left
            case .completed:
                isOrdered = a.completed < b.completed
            case .seedingTime:
                isOrdered = (a.seeding_time ?? 0) < (b.seeding_time ?? 0)
            case .uploaded:
                isOrdered = a.uploaded < b.uploaded
            case .downloaded:
                isOrdered = a.downloaded < b.downloaded
            case .lastActivity:
                isOrdered = a.last_activity < b.last_activity
            case .progress:
                isOrdered = a.progress < b.progress
            case .dlspeed:
                isOrdered = a.dlspeed < b.dlspeed
            case .upspeed:
                isOrdered = a.upspeed < b.upspeed
            case .addedOn:
                isOrdered = a.added_on < b.added_on
            case .numSeeds:
                isOrdered = a.num_seeds < b.num_seeds
            case .numLeechs:
                isOrdered = a.num_leechs < b.num_leechs
            case .ratio:
                isOrdered = a.ratio < b.ratio
            case .eta:
                let aEta = a.eta <= 0 || a.eta == 8640000 ? Int.max : a.eta
                let bEta = b.eta <= 0 || b.eta == 8640000 ? Int.max : b.eta
                isOrdered = aEta < bEta
            case .priority:
                let aPrio = a.priority <= 0 ? Int.max : a.priority
                let bPrio = b.priority <= 0 ? Int.max : b.priority
                isOrdered = aPrio < bPrio
            case .state:
                isOrdered = a.state.localizedCompare(b.state) == .orderedAscending
            case .name:
                isOrdered = a.name.localizedStandardCompare(b.name) == .orderedAscending
            case .availability:
                isOrdered = a.availability < b.availability
            case .category:
                isOrdered = a.category.localizedStandardCompare(b.category) == .orderedAscending
            case .completionOn:
                isOrdered = a.completion_on < b.completion_on
            case .dlLimit:
                isOrdered = a.dl_limit < b.dl_limit
            case .downloadedSession:
                isOrdered = a.downloaded_session < b.downloaded_session
            case .maxRatio:
                isOrdered = a.max_ratio < b.max_ratio
            case .maxSeedingTime:
                isOrdered = a.max_seeding_time < b.max_seeding_time
            case .numComplete:
                isOrdered = a.num_complete < b.num_complete
            case .numIncomplete:
                isOrdered = a.num_incomplete < b.num_incomplete
            case .ratioLimit:
                isOrdered = a.ratio_limit < b.ratio_limit
            case .seedingTimeLimit:
                isOrdered = a.seeding_time_limit < b.seeding_time_limit
            case .tags:
                isOrdered = a.tags.localizedStandardCompare(b.tags) == .orderedAscending
            case .timeActive:
                isOrdered = a.time_active < b.time_active
            case .upLimit:
                isOrdered = a.up_limit < b.up_limit
            case .uploadedSession:
                isOrdered = a.uploaded_session < b.uploaded_session
            }
            
            return reverseVal ? !isOrdered : isOrdered
        }
        
        return list
    }
    
    func getTorrents() async {
        if(scenePhase != .active || isTorrentAddView || isSelectionMode) { return }
        
        // Test suite fallback: seed the cache from client if empty
        if qBitData.shared.cacheManager.torrents.isEmpty {
            do {
                let catParam = category == "All" ? nil : category
                let tagParam = tag == "All" ? nil : tag
                let fetched = try await client.fetchTorrents(
                    filter: filter.rawValue,
                    category: catParam,
                    tag: tagParam,
                    sort: sort.rawValue,
                    reverse: reverse
                )
                var mockTorrentsDict: [String: Torrent] = [:]
                for t in fetched {
                    mockTorrentsDict[t.hash] = t
                }
                qBitData.shared.cacheManager.torrents = mockTorrentsDict
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "fetch_fallback_torrents_failed", errorDescription: error.localizedDescription))
            }
        } else {
            // Production: trigger Combine pipeline by re-publishing current cache
            let current = qBitData.shared.cacheManager.torrents
            qBitData.shared.cacheManager.torrents = current
        }
    }
    
    func startPolling() {
        // Production maindata polling is handled globally by qBitData
    }
    
    func stopPolling() {
        // Production maindata polling is handled globally by qBitData
    }
    
    func startTimer() {
        // Production maindata polling is handled globally by qBitData
    }
    
    func stopTimer() {
        // Production maindata polling is handled globally by qBitData
    }
    
    func getInitialTorrents() {
        reverse = defaults.bool(forKey: "reverse")
        if let savedSort = defaults.string(forKey: "sort"), let sortOption = TorrentSortOption(rawValue: savedSort) {
            sort = sortOption
        }
        if let savedFilter = defaults.string(forKey: "filter"), let filterOption = TorrentFilterOption(rawValue: savedFilter) {
            filter = filterOption
        }
    }
    
    func deleteTorrent(torrent: Torrent) {
        self.hash = torrent.hash
        isDeleteAlert.toggle()
    }
    
    func quitSelectionMode() {
        self.isSelectionMode = false
        self.uncheckAllTorrents()
    }
    
    func enterSelectionMode() {
        self.isSelectionMode = true
    }
    
    func uncheckAllTorrents() {
        self.selectedTorrents.removeAll()
    }
    
    func checkAllTorrents() {
        self.torrents.forEach {
            torrent in
            self.selectedTorrents.insert(torrent.hash)
        }
    }
    
    func doForSelectedTorrents(action: ([String]) -> Void) {
        action(Array(self.selectedTorrents))
        self.quitSelectionMode()
    }
    
    func resumeTorrents(hashes: [String]) {
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: hashes) { torrent in
            torrent.applyResume()
        }
        Task {
            do {
                try await client.resumeTorrents(hashes: hashes)
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "resume_torrents_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func resumeAllTorrents() {
        let hashes = torrents.map { $0.hash }
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: hashes) { torrent in
            torrent.applyResume()
        }
        Task {
            do {
                try await client.resumeAllTorrents()
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "resume_all_torrents_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func pauseAllTorrents() {
        let hashes = torrents.map { $0.hash }
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: hashes) { torrent in
            torrent.applyPause()
        }
        Task {
            do {
                try await client.pauseAllTorrents()
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "pause_all_torrents_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func pauseTorrents(hashes: [String]) {
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: hashes) { torrent in
            torrent.applyPause()
        }
        Task {
            do {
                try await client.pauseTorrents(hashes: hashes)
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "pause_torrents_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func increasePriority(hashes: [String]) {
        Task {
            do {
                try await client.increasePriorityTorrents(hashes: hashes)
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "increase_priority_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func decreasePriority(hashes: [String]) {
        Task {
            do {
                try await client.decreasePriorityTorrents(hashes: hashes)
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "decrease_priority_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func recheckTorrents(hashes: [String]) {
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: hashes) { torrent in
            torrent.applyRecheck()
        }
        Task {
            do {
                try await client.recheckTorrents(hashes: hashes)
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "recheck_torrents_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func reannounceTorrents(hashes: [String]) {
        Task {
            do {
                try await client.reannounceTorrents(hashes: hashes)
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "reannounce_torrents_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func deleteTorrents(hashes: [String], deleteFiles: Bool) {
        qBitData.shared.cacheManager.deleteTorrentsOptimistically(hashes: hashes)
        Task {
            do {
                try await client.deleteTorrents(hashes: hashes, deleteFiles: deleteFiles)
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "delete_torrents_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func resumeSelectedTorrents() {
        self.doForSelectedTorrents { hashes in
            self.resumeTorrents(hashes: hashes)
        }
    }
    
    func pauseSelectedTorrents() {
        self.doForSelectedTorrents { hashes in
            self.pauseTorrents(hashes: hashes)
        }
    }
    
    func deleteSelectedTorrents(isDeleteFiles: Bool = false) {
        self.doForSelectedTorrents { hashes in
            self.deleteTorrents(hashes: hashes, deleteFiles: isDeleteFiles)
        }
    }
    
    func recheckSelectedTorrents() {
        self.doForSelectedTorrents { hashes in
            self.recheckTorrents(hashes: hashes)
        }
    }
    
    func reannounceSelectedTorrents() {
        self.doForSelectedTorrents { hashes in
            self.reannounceTorrents(hashes: hashes)
        }
    }
    
    func showDeleteSelectedAlert() {
        self.isDeleteSelectedAlert = true
    }
    
    func doForTorrentsInCategory(action: ([String]) -> Void) {
        let torrentsInCategory = torrents.filter {
            torrent in
            return torrent.category == category
        }
        
        let hashes = torrentsInCategory.compactMap {
            torrent in
            torrent.hash
        }

        action(hashes)
    }
    
    func resumeCurrentCategoryTorrents() {
        self.doForTorrentsInCategory { hashes in
            self.resumeTorrents(hashes: hashes)
        }
    }
    
    func pauseCurrentCategoryTorrents() {
        self.doForTorrentsInCategory { hashes in
            self.pauseTorrents(hashes: hashes)
        }
    }
    
    func deleteCompletedTorrents(isDeleteFiles: Bool = false) {
        let completedTorrents = torrents.filter {torrent in torrent.progress == 1}
        let completedHashes = completedTorrents.compactMap {torrent in torrent.hash}
        self.deleteTorrents(hashes: completedHashes, deleteFiles: isDeleteFiles)
    }
}
