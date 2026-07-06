//
//  TorrentListHelperViewModel.swift
//  qBitControl
//

import SwiftUI
import Combine

@MainActor
class TorrentListHelperViewModel: ObservableObject {
    let defaults = UserDefaults.standard
    private let client: TorrentClientProtocol
    
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
    var hash = ""
    private var cancellables = Set<AnyCancellable>()
    
    public var categoryName: String {
        if(category == "All") {
            return NSLocalizedString("All", comment: "Pause All/Resume All")
        }
        return category.capitalized
    }
    
    init(client: TorrentClientProtocol) {
        self.client = client
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
            
            let allTorrents = Array(dict.values)
            
            // 1. Update self.torrents (sorted by VM sorting)
            self.torrents = self.getProcessedTorrents(
                allTorrents: allTorrents,
                query: "",
                filterVal: .all,
                categoryVal: "All",
                tagVal: "All",
                sortVal: sortVal,
                reverseVal: rev
            )
            
            // 2. Update self.filteredTorrents (filtered and sorted)
            self.filteredTorrents = self.getProcessedTorrents(
                allTorrents: allTorrents,
                query: query,
                filterVal: filterVal,
                categoryVal: cat,
                tagVal: tag,
                sortVal: sortVal,
                reverseVal: rev
            )
        }
        .store(in: &cancellables)
    }
    
    func getProcessedTorrents(
        allTorrents: [Torrent],
        query: String,
        filterVal: TorrentFilterOption,
        categoryVal: String,
        tagVal: String,
        sortVal: TorrentSortOption,
        reverseVal: Bool
    ) -> [Torrent] {
        var list = allTorrents.filter { torrent in
            // Filter by status (filterVal)
            switch filterVal {
            case .downloading:
                if !(torrent.state == "downloading" || torrent.state == "stalledDL" || torrent.state == "checkingDL" || torrent.state == "metaDL" || torrent.state == "forcedDL" || torrent.state == "allocating") { return false }
            case .completed, .seeding:
                if !(torrent.state == "seeding" || torrent.state == "uploading" || torrent.state == "stalledUP" || torrent.state == "checkingUP" || torrent.state == "forcedUP" || torrent.state == "queuedUP" || torrent.state == "pausedUP" || torrent.state == "stoppedUP") { return false }
            case .paused:
                if !(torrent.state == "pausedDL" || torrent.state == "pausedUP" || torrent.state == "stoppedDL" || torrent.state == "stoppedUP") { return false }
            case .active:
                if !(torrent.dlspeed > 0 || torrent.upspeed > 0) { return false }
            case .inactive:
                if !(torrent.dlspeed == 0 && torrent.upspeed == 0) { return false }
            case .stalled:
                if !(torrent.state == "stalledDL" || torrent.state == "stalledUP") { return false }
            case .stalledDownloading:
                if !(torrent.state == "stalledDL") { return false }
            case .stalledUploading:
                if !(torrent.state == "stalledUP") { return false }
            case .checking:
                if !(torrent.state == "checkingDL" || torrent.state == "checkingUP" || torrent.state == "checkingResumeData") { return false }
            case .errored:
                if !(torrent.state == "error" || torrent.state == "missingFiles") { return false }
            case .resumed:
                if torrent.state.contains("paused") || torrent.state.contains("stopped") { return false }
            case .all:
                break
            }
            
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
                if tagVal == "Untagged" {
                    if torrent.tags != "" && torrent.tags != "Untagged" { return false }
                } else {
                    let tagsList = torrent.tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    if !tagsList.contains(tagVal) { return false }
                }
            }
            
            // Filter by Search Query
            if query != "" {
                if !torrent.name.lowercased().contains(query.lowercased()) { return false }
            }
            
            return true
        }
        
        // Sort
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
                print("Failed to fetch fallback torrents: \(error)")
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
            torrent.state = torrent.progress < 1.0 ? "downloading" : "uploading"
        }
        Task {
            do {
                try await client.resumeTorrents(hashes: hashes)
            } catch {
                print("Failed to resume torrents: \(error)")
            }
        }
    }
    
    func resumeAllTorrents() {
        let hashes = torrents.map { $0.hash }
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: hashes) { torrent in
            torrent.state = torrent.progress < 1.0 ? "downloading" : "uploading"
        }
        Task {
            do {
                try await client.resumeAllTorrents()
            } catch {
                print("Failed to resume all torrents: \(error)")
            }
        }
    }
    
    func pauseAllTorrents() {
        let hashes = torrents.map { $0.hash }
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: hashes) { torrent in
            torrent.state = torrent.progress < 1.0 ? "pausedDL" : "pausedUP"
            torrent.dlspeed = 0
            torrent.upspeed = 0
        }
        Task {
            do {
                try await client.pauseAllTorrents()
            } catch {
                print("Failed to pause all torrents: \(error)")
            }
        }
    }
    
    func pauseTorrents(hashes: [String]) {
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: hashes) { torrent in
            torrent.state = torrent.progress < 1.0 ? "pausedDL" : "pausedUP"
            torrent.dlspeed = 0
            torrent.upspeed = 0
        }
        Task {
            do {
                try await client.pauseTorrents(hashes: hashes)
            } catch {
                print("Failed to pause torrents: \(error)")
            }
        }
    }
    
    func increasePriority(hashes: [String]) {
        Task {
            do {
                try await client.increasePriorityTorrents(hashes: hashes)
            } catch {
                print("Failed to increase priority: \(error)")
            }
        }
    }
    
    func decreasePriority(hashes: [String]) {
        Task {
            do {
                try await client.decreasePriorityTorrents(hashes: hashes)
            } catch {
                print("Failed to decrease priority: \(error)")
            }
        }
    }
    
    func recheckTorrents(hashes: [String]) {
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: hashes) { torrent in
            torrent.state = torrent.progress < 1.0 ? "checkingDL" : "checkingUP"
        }
        Task {
            do {
                try await client.recheckTorrents(hashes: hashes)
            } catch {
                print("Failed to recheck torrents: \(error)")
            }
        }
    }
    
    func reannounceTorrents(hashes: [String]) {
        Task {
            do {
                try await client.reannounceTorrents(hashes: hashes)
            } catch {
                print("Failed to reannounce torrents: \(error)")
            }
        }
    }
    
    func deleteTorrents(hashes: [String], deleteFiles: Bool) {
        qBitData.shared.cacheManager.deleteTorrentsOptimistically(hashes: hashes)
        Task {
            do {
                try await client.deleteTorrents(hashes: hashes, deleteFiles: deleteFiles)
            } catch {
                print("Failed to delete torrents: \(error)")
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
