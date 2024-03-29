//

import SwiftUI

struct TorrentList: View {
    @Binding public var torrents: [Torrent]
    
    @Binding public var searchQuery: String
    @Binding public var sort: String
    @Binding public var reverse: Bool
    @Binding public var filter: String
    @Binding public var category: String
    @Binding public var tag: String
    
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.scenePhase) var scenePhaseEnv
    @State var scenePhase: ScenePhase = .active
    
    @Binding public var isTorrentAddView: Bool
    @State private var isDeleteAlert: Bool = false
    
    @State private var timer: Timer?
    
    let defaults = UserDefaults.standard
    
    @State private var hash = ""
    
    @Binding public var isSelectionMode: Bool
    @Binding public var selectedTorrents: Set<Torrent>
    
    var body: some View {
        Section(header: torrentListHeader()) {
            ForEach(torrents, id: \.hash) {
                torrent in
                if searchQuery == "" || torrent.name.lowercased().contains(searchQuery.lowercased()) {
                    if(!isSelectionMode) {
                        NavigationLink {
                            TorrentDetailsView(torrent: torrent)
                        } label: {
                            TorrentRowView(name: torrent.name, progress: torrent.progress, state: torrent.state, dlspeed: torrent.dlspeed, upspeed: torrent.upspeed, ratio: torrent.ratio)
                                .contextMenu() {
                                    torrentRowContextMenu(torrent: torrent)
                                }
                        }
                    } else {
                        if(selectedTorrents.contains(torrent)) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill").scaleEffect(1.25).foregroundStyle(Color(.blue))
                                TorrentRowView(name: torrent.name, progress: torrent.progress, state: torrent.state, dlspeed: torrent.dlspeed, upspeed: torrent.upspeed, ratio: torrent.ratio)
                            }.onTapGesture {
                                selectedTorrents.remove(torrent)
                            }
                        } else {
                            HStack {
                                Image(systemName: "circle").scaleEffect(1.25).foregroundStyle(Color(.gray))
                                TorrentRowView(name: torrent.name, progress: torrent.progress, state: torrent.state, dlspeed: torrent.dlspeed, upspeed: torrent.upspeed, ratio: torrent.ratio)
                            }.onTapGesture {
                                selectedTorrents.insert(torrent)
                            }
                        }
                    }
                }
            }
        }.onAppear() {
            reverse = defaults.bool(forKey: "reverse")
            sort = defaults.string(forKey: "sort") ?? sort
            filter = defaults.string(forKey: "filter") ?? filter
            
            getTorrents()
            
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                timer in
                getTorrents()
            }
            
        }.onDisappear() {
            timer?.invalidate()
        }.refreshable {
            getTorrents()
        }.onChange(of: scenePhaseEnv) {
            phase in
            scenePhase = phase
        }.confirmationDialog("Delete Task", isPresented: $isDeleteAlert) {
            Button("Delete Torrent", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                qBittorrent.deleteTorrent(hash: hash)
                hash = ""
            }
            Button("Delete Task with Files", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                qBittorrent.deleteTorrent(hash: hash, deleteFiles: true)
                hash = ""
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    func torrentListHeader() -> some View {
        HStack(spacing: 3) {
            Text("\(torrents.count) Tasks")
            Text("•")
            Image(systemName: "arrow.down")
            Text("\( qBittorrent.getFormatedSize(size: torrents.compactMap({$0.dlspeed}).reduce(0, +)) )/s")
            Text("•")
            Image(systemName: "arrow.up")
            Text("\( qBittorrent.getFormatedSize(size: torrents.compactMap({$0.upspeed}).reduce(0, +)) )/s")
        }
        .lineLimit(1)
    }
    
    func torrentRowContextMenu(torrent: Torrent) -> some View {
        VStack {
            if let preferences = qBittorrent.getSavedPreferences() {
                if(preferences.queueing_enabled == true) {
                    Section(header: Text("Queue")) {
                        Button {
                            qBittorrent.increasePriorityTorrents(hashes: [torrent.hash])
                        } label: {
                            Text("Move Up")
                            Image(systemName: "arrow.up")
                        }
                        Button {
                            qBittorrent.decreasePriorityTorrents(hashes: [torrent.hash])
                        } label: {
                            Text("Move Down")
                            Image(systemName: "arrow.down")
                        }
                    }
                }
            }
            
            Section(header: Text("Manage")) {
                Button {
                    if torrent.state.contains("paused") {
                        qBittorrent.resumeTorrent(hash: torrent.hash)
                    } else {
                        qBittorrent.pauseTorrent(hash: torrent.hash)
                    }
                } label: {
                    HStack {
                        if torrent.state.contains("paused") {
                            Text("Resume")
                            Image(systemName: "play")
                        } else {
                            Text("Pause")
                            Image(systemName: "pause")
                        }
                    }
                }
                
                Button {
                    qBittorrent.recheckTorrent(hash: torrent.hash)
                } label: {
                    HStack {
                        Text("Recheck")
                        Image(systemName: "magnifyingglass")
                    }
                }
                
                Button {
                    qBittorrent.reannounceTorrent(hash: torrent.hash)
                } label: {
                    HStack {
                        Text("Reannounce")
                        Image(systemName: "circle.dashed")
                    }
                }
                
                Button(role: .destructive) {
                    self.hash = torrent.hash
                    isDeleteAlert.toggle()
                } label: {
                    HStack {
                        Text("Delete")
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
    
    
    func getTorrents() {
        if(scenePhase != .active || isTorrentAddView || isSelectionMode) {
            return
        }
        
        var queryItems = [URLQueryItem(name: "sort", value: sort), URLQueryItem(name: "filter", value: filter), URLQueryItem(name: "reverse", value: String(reverse))]
        
        if category != "None" {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        if tag != "None" {
            queryItems.append(URLQueryItem(name: "tag", value: tag))
        }
        
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/info", queryItems: queryItems)
        
        qBitRequest.requestTorrentListJSON(request: request) {
            torrent in
            
            switch(sort) {
            case "priority":
                torrents = torrent.sorted(by: {
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
                break
            default:
                torrents = torrent
            }
        }
    }
}
