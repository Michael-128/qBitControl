//
//  TorrentListHelperViewModel.swift
//  qBitControl
//

import SwiftUI

@MainActor
class TorrentListHelperViewModel: ObservableObject {
    let defaults = UserDefaults.standard
    private let client: TorrentClientProtocol
    
    @Published public var torrents: [Torrent] = []
    
    @Published public var searchQuery: String = ""
    @Published public var sort: String = "name"
    @Published public var reverse: Bool = false
    @Published public var filter: String = "all"
    @Published public var category: String = "All"
    @Published public var tag: String = "All"
    
    @Published public var isTorrentAddView: Bool = false
    @Published public var isSelectionMode: Bool = false
    
    @Published public var selectedTorrents: Set<Torrent> = Set()
    
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
    
    public var categoryName: String {
        if(category == "All") {
            return NSLocalizedString("All", comment: "Pause All/Resume All")
        }
        return category.capitalized
    }
    
    init(client: TorrentClientProtocol) {
        self.client = client
    }
    
    func getTorrents() async {
        if(scenePhase != .active || isTorrentAddView || isSelectionMode) { return }
        
        do {
            let catParam = category == "All" ? nil : category
            let tagParam = tag == "All" ? nil : tag
            
            let _torrents = try await client.fetchTorrents(
                filter: filter,
                category: catParam,
                tag: tagParam,
                sort: sort,
                reverse: reverse
            )
            
            if self.sort == "priority" {
                self.torrents = self.getTorrentsSortedByPriority(torrents: _torrents)
            } else {
                self.torrents = _torrents
            }
            self.filteredTorrents = self.getFilteredTorrents(torrents: self.torrents)
        } catch {
            print("Failed to fetch torrents: \(error)")
        }
    }
    
    func getTorrentsSortedByPriority(torrents: [Torrent]) -> [Torrent] {
        return torrents.sorted(by: {
            tor1, tor2 in
            
            if(reverse) {
                if(tor2.priority <= 0) { return false }
                if(tor1.priority < tor2.priority) { return false }
                return true
            } else {
                if(tor2.priority <= 0) { return true }
                if(tor1.priority < tor2.priority) { return true }
                return false
            }
        })
    }
    
    func getFilteredTorrents(torrents: [Torrent]) -> [Torrent] {
        if(searchQuery == "") { return torrents }
        return torrents.filter { torrent in torrent.name.lowercased().contains(searchQuery.lowercased()) }
    }
    
    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                await getTorrents()
                do {
                    // Sleep for 2 seconds (2,000,000,000 nanoseconds)
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                } catch {
                    break
                }
            }
        }
    }
    
    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    func startTimer() {
        startPolling()
    }
    
    func stopTimer() {
        stopPolling()
    }
    
    func getInitialTorrents() {
        reverse = defaults.bool(forKey: "reverse")
        sort = defaults.string(forKey: "sort") ?? sort
        filter = defaults.string(forKey: "filter") ?? filter
        
        startPolling()
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
            self.selectedTorrents.insert(torrent)
        }
    }
    
    func doForSelectedTorrents(action: ([String]) -> Void) {
        let selectedHashes = self.selectedTorrents.compactMap {
            torrent in
            torrent.hash
        }
        
        action(selectedHashes)
        self.quitSelectionMode()
    }
    
    func resumeSelectedTorrents() {
        self.doForSelectedTorrents { hashes in
            Task {
                do {
                    try await client.resumeTorrents(hashes: hashes)
                } catch {
                    print("Failed to resume torrents: \(error)")
                }
            }
        }
    }
    
    func pauseSelectedTorrents() {
        self.doForSelectedTorrents { hashes in
            Task {
                do {
                    try await client.pauseTorrents(hashes: hashes)
                } catch {
                    print("Failed to pause torrents: \(error)")
                }
            }
        }
    }
    
    func deleteSelectedTorrents(isDeleteFiles: Bool = false) {
        self.doForSelectedTorrents { hashes in
            Task {
                do {
                    try await client.deleteTorrents(hashes: hashes, deleteFiles: isDeleteFiles)
                } catch {
                    print("Failed to delete torrents: \(error)")
                }
            }
        }
    }
    
    func recheckSelectedTorrents() {
        self.doForSelectedTorrents { hashes in
            Task {
                do {
                    try await client.recheckTorrents(hashes: hashes)
                } catch {
                    print("Failed to recheck torrents: \(error)")
                }
            }
        }
    }
    
    func reannounceSelectedTorrents() {
        self.doForSelectedTorrents { hashes in
            Task {
                do {
                    try await client.reannounceTorrents(hashes: hashes)
                } catch {
                    print("Failed to reannounce torrents: \(error)")
                }
            }
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
            Task {
                do {
                    try await client.resumeTorrents(hashes: hashes)
                } catch {
                    print("Failed to resume category torrents: \(error)")
                }
            }
        }
    }
    
    func pauseCurrentCategoryTorrents() {
        self.doForTorrentsInCategory { hashes in
            Task {
                do {
                    try await client.pauseTorrents(hashes: hashes)
                } catch {
                    print("Failed to pause category torrents: \(error)")
                }
            }
        }
    }
    
    func deleteCompletedTorrents(isDeleteFiles: Bool = false) {
        let completedTorrents = torrents.filter {torrent in torrent.progress == 1}
        let completedHashes = completedTorrents.compactMap {torrent in torrent.hash}
        
        Task {
            do {
                try await client.deleteTorrents(hashes: completedHashes, deleteFiles: isDeleteFiles)
            } catch {
                print("Failed to delete completed torrents: \(error)")
            }
        }
    }
}
