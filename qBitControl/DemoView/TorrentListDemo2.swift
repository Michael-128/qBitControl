//

import SwiftUI

struct TorrentListDemo2: View {
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
                            TorrentDetailsDemo(torrent: torrent)
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
        }.refreshable {
            //getTorrents()
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
            Button {
                if torrent.state.contains("paused") {
                    //qBittorrent.resumeTorrent(hash: torrent.hash)
                } else {
                    //qBittorrent.pauseTorrent(hash: torrent.hash)
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
                //qBittorrent.recheckTorrent(hash: torrent.hash)
            } label: {
                HStack {
                    Text("Recheck")
                    Image(systemName: "magnifyingglass")
                }
            }
            
            Button {
                //qBittorrent.reannounceTorrent(hash: torrent.hash)
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
