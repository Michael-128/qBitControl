//
import SwiftUI

class TorrentListModel: ObservableObject {
    let defaults = UserDefaults.standard
    
    @Binding public var torrents: [Torrent]
    
    @Binding public var searchQuery: String
    @Binding public var sort: String
    @Binding public var reverse: Bool
    @Binding public var filter: String
    @Binding public var category: String
    @Binding public var tag: String
    
    @Binding public var isTorrentAddView: Bool
    @Binding public var isSelectionMode: Bool
    
    @Binding public var selectedTorrents: Set<Torrent>
    
    @Published public var filteredTorrents: [Torrent] = []
    
    @Published var scenePhase: ScenePhase = .active
    @Published var isDeleteAlert: Bool = false
    var timer: Timer?
    var hash = ""
    
    init(torrents: Binding<[Torrent]>, searchQuery: Binding<String>, sort: Binding<String>, reverse: Binding<Bool>, filter: Binding<String>, category: Binding<String>, tag: Binding<String>, isTorrentAddView: Binding<Bool>, isSelectionMode: Binding<Bool>, selectedTorrents: Binding<Set<Torrent>>) {
        _torrents = torrents
        _searchQuery = searchQuery
        _sort = sort
        _reverse = reverse
        _filter = filter
        _category = category
        _tag = tag
        _isTorrentAddView = isTorrentAddView
        _isSelectionMode = isSelectionMode
        _selectedTorrents = selectedTorrents
    }
    
    func getTorrents() {
        if(scenePhase != .active || isTorrentAddView || isSelectionMode) { return }
        
        var queryItems = [URLQueryItem(name: "sort", value: sort), URLQueryItem(name: "filter", value: filter), URLQueryItem(name: "reverse", value: String(reverse))]
        
        if category != "None" { queryItems.append(URLQueryItem(name: "category", value: category)) }
        if tag != "None" { queryItems.append(URLQueryItem(name: "tag", value: tag)) }
        
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
        isDeleteAlert.toggle()
    }
}
