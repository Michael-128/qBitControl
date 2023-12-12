//

import SwiftUI

struct TorrentListSelectionToolbar: ToolbarContent {
    @Binding public var torrents: [Torrent]
    
    @Binding public var isSelectionMode: Bool
    @State private var isAlertDeleteSelected: Bool = false
    
    @Binding public var selectedTorrents: Set<Torrent>
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if(selectedTorrents.count == torrents.count) {
                Button {
                    selectedTorrents.removeAll()
                } label: {
                    Text("Deselect All")
                }
            } else {
                Button {
                    torrents.forEach {
                        torrent in
                        selectedTorrents.insert(torrent)
                    }
                } label: {
                    Text("Select All")
                }
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isSelectionMode = false
                
                // do something
                
                selectedTorrents.removeAll()
            } label: {
                Text("Done")
                    .fontWeight(.bold)
            }
        }
        
        if(selectedTorrents.count > 0) {
            ToolbarItemGroup(placement: .bottomBar) {
                HStack {
                    Button {
                        let selectedHashes = selectedTorrents.compactMap {
                            torrent in
                            torrent.hash
                        }
                        
                        qBittorrent.resumeTorrents(hashes: selectedHashes)
                        isSelectionMode = false
                        selectedTorrents.removeAll()
                    } label: {
                        Image(systemName: "play.fill")
                    }
                    
                    Spacer()
                    
                    Button {
                        let selectedHashes = selectedTorrents.compactMap {
                            torrent in
                            torrent.hash
                        }
                        
                        qBittorrent.pauseTorrents(hashes: selectedHashes)
                        isSelectionMode = false
                        selectedTorrents.removeAll()
                    } label: {
                        Image(systemName: "pause.fill")
                    }
                    
                    Spacer()
                    
                    Button {
                        let selectedHashes = selectedTorrents.compactMap {
                            torrent in
                            torrent.hash
                        }
                        
                        qBittorrent.recheckTorrents(hashes: selectedHashes)
                        isSelectionMode = false
                        selectedTorrents.removeAll()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    
                    Spacer()
                    
                    Button {
                        let selectedHashes = selectedTorrents.compactMap {
                            torrent in
                            torrent.hash
                        }
                        
                        qBittorrent.reannounceTorrents(hashes: selectedHashes)
                        isSelectionMode = false
                        selectedTorrents.removeAll()
                    } label: {
                        Image(systemName: "circle.dashed")
                    }
                    
                    Spacer()
                    
                    Button {
                        isAlertDeleteSelected = true
                    } label: {
                        Image(systemName: "trash.fill").foregroundStyle(Color(.red))
                    }
                }.alert("Confirm Deletion", isPresented: $isAlertDeleteSelected, actions: {
                    Button("Delete Selected Tasks", role: .destructive) {
                        let selectedHashes = selectedTorrents.compactMap {
                            torrent in
                            torrent.hash
                        }
                        
                        qBittorrent.deleteTorrents(hashes: selectedHashes)
                        
                        isSelectionMode = false
                        selectedTorrents.removeAll()
                    }
                    Button("Delete Selected Tasks with Files", role: .destructive) {
                        let selectedHashes = selectedTorrents.compactMap {
                            torrent in
                            torrent.hash
                        }
                        
                        qBittorrent.deleteTorrents(hashes: selectedHashes, deleteFiles: true)
                        
                        isSelectionMode = false
                        selectedTorrents.removeAll()
                    }
                })
            }
        }
    }
}
