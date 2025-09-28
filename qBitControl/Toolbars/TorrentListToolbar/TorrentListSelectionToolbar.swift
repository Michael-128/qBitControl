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
                    Image(systemName: "checklist.unchecked")
                }
            } else {
                Button {
                    torrents.forEach {
                        torrent in
                        selectedTorrents.insert(torrent)
                    }
                } label: {
                    Image(systemName: "checklist.checked")
                }
            }
        }
        
        if(selectedTorrents.count > 0 && SystemHelper.instance.isLiquidGlass) {
            ToolbarItem(placement: .topBarLeading) {
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
            }
            
            ToolbarItem(placement: .topBarLeading) {
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
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isAlertDeleteSelected = true
                } label: {
                    Image(systemName: "trash.fill").foregroundStyle(Color(.red))
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
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isSelectionMode = false
                
                // do something
                
                selectedTorrents.removeAll()
            } label: {
                Image(systemName: "checkmark")
            }
        }
        
        if(selectedTorrents.count > 0 && !SystemHelper.instance.isLiquidGlass) {
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
    
    func removeButton() {
        
    }
}
