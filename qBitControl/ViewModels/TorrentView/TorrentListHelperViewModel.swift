//
import SwiftUI

class TorrentListHelperViewModel: ObservableObject {
    let defaults = UserDefaults.standard
    
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
    
    var timer: Timer?
    var hash = ""
    
    public var categoryName: String {
        if(category == "All") {
            return NSLocalizedString("All", comment: "Pause All/Resume All")
        }
        return category.capitalized
    }
    
    init() {}
    
    func getTorrents() {
        if(scenePhase != .active || isTorrentAddView || isSelectionMode) { return }
        
        var queryItems = [URLQueryItem(name: "sort", value: sort), URLQueryItem(name: "filter", value: filter), URLQueryItem(name: "reverse", value: String(reverse))]
        
        if category != "All" { queryItems.append(URLQueryItem(name: "category", value: category)) }
        if tag != "All" { queryItems.append(URLQueryItem(name: "tag", value: tag)) }
        
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/info", queryItems: queryItems)
        
        qBitRequest.requestTorrentListJSON(request: request) {
            _torrents in
            
            DispatchQueue.main.async {
                if(self.sort == "priority") { self.torrents = self.getTorrentsSortedByPriority(torrents: _torrents) }
                else { self.torrents = _torrents }
                
                self.filteredTorrents = self.getFilteredTorrents(torrents: self.torrents)
            }
        }
    }
    
    func getTorrentsSortedByPriority(torrents: [Torrent]) -> [Torrent] {
        return torrents.sorted(by: {
            tor1, tor2 in
            
            if(reverse) {
                if(tor2.priority <= 0) { return false }
                if(tor1.priority < tor2.priority) { return false }
                return true;
            } else {
                if(tor2.priority <= 0) { return true }
                if(tor1.priority < tor2.priority) { return true; }
                return false;
            }
        })
    }
    
    func getFilteredTorrents(torrents: [Torrent]) -> [Torrent] {
        if(searchQuery == "") { return torrents }
        return torrents.filter { torrent in torrent.name.lowercased().contains(searchQuery.lowercased()) }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
            timer in
            self.getTorrents()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func getInitialTorrents() {
        reverse = defaults.bool(forKey: "reverse")
        sort = defaults.string(forKey: "sort") ?? sort
        filter = defaults.string(forKey: "filter") ?? filter
        
        getTorrents()
        
        startTimer()
    }
    
    func deleteTorrent(torrent: Torrent) {
        self.hash = torrent.hash
        isDeleteSelectedAlert.toggle()
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
            qBittorrent.resumeTorrents(hashes: hashes)
        }
    }
    
    func pauseSelectedTorrents() {
        self.doForSelectedTorrents { hashes in
            qBittorrent.pauseTorrents(hashes: hashes)
        }
    }
    
    func deleteSelectedTorrents(isDeleteFiles: Bool = false) {
        self.doForSelectedTorrents { hashes in
            qBittorrent.deleteTorrents(hashes: hashes, deleteFiles: isDeleteFiles)
        }
    }
    
    func recheckSelectedTorrents() {
        self.doForSelectedTorrents { hashes in
            qBittorrent.recheckTorrents(hashes: hashes)
        }
    }
    
    func reannounceSelectedTorrents() {
        self.doForSelectedTorrents { hashes in
            qBittorrent.reannounceTorrents(hashes: hashes)
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
            qBittorrent.resumeTorrents(hashes: hashes)
        }
    }
    
    func pauseCurrentCategoryTorrents() {
        self.doForTorrentsInCategory { hashes in
            qBittorrent.pauseTorrents(hashes: hashes)
        }
    }
    
    func deleteCompletedTorrents(isDeleteFiles: Bool = false) {
        let completedTorrents = torrents.filter {torrent in torrent.progress == 1}
        let completedHashes = completedTorrents.compactMap {torrent in torrent.hash}
        
        qBittorrent.deleteTorrents(hashes: completedHashes, deleteFiles: isDeleteFiles)
    }
}
