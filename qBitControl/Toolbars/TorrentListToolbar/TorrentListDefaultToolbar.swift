//

import SwiftUI

struct TorrentListDefaultToolbar: ToolbarContent {
    @Binding public var torrents: [Torrent]
    
    @Binding public var category: String
    
    @Binding public var isSelectionMode: Bool
    @Binding public var isFilterView: Bool
    
    @State private var alertIdentifier: AlertIdentifier?
    @State private var sheetIdentifier: SheetIdentifier?
    @State private var isAlertClearCompleted: Bool = false
    
    private var categoryName: String {
        if(category == "All") {
            return NSLocalizedString("All", comment: "Pause All/Resume All")
        }
        return category.capitalized
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Section {
                    Button {
                        isSelectionMode = true
                    } label: {
                        Image(systemName: "checkmark.circle")
                        Text("Select")
                    }
                }
                
                if(category != "None") {
                    Section {
                        Button {
                            let torrentsInCategory = torrents.filter {
                                torrent in
                                return torrent.category == category
                            }
                            
                            qBittorrent.resumeTorrents(hashes: torrentsInCategory.compactMap { torrent in torrent.hash })
                        } label: {
                            Image(systemName: "play")
                                .rotationEffect(.degrees(180))
                            Text(NSLocalizedString("Resume", comment: "") + " " + self.categoryName)
                        }
                        
                        Button {
                            let torrentsInCategory = torrents.filter {
                                torrent in
                                return torrent.category == category
                            }
                            
                            qBittorrent.pauseTorrents(hashes: torrentsInCategory.compactMap { torrent in torrent.hash })
                        } label: {
                            Image(systemName: "pause")
                                .rotationEffect(.degrees(180))
                            Text(NSLocalizedString("Pause", comment: "") + " " + self.categoryName)
                        }
                    }
                }
                
                Section {
                    Button {
                        alertIdentifier = AlertIdentifier(id: .resumeAll)
                    } label: {
                        Image(systemName: "play")
                            .rotationEffect(.degrees(180))
                        Text("Resume All Tasks")
                    }
                    
                    Button {
                        alertIdentifier = AlertIdentifier(id: .pauseAll)
                    } label: {
                        Image(systemName: "pause")
                            .rotationEffect(.degrees(180))
                        Text("Pause All Tasks")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        isAlertClearCompleted = true
                    } label: {
                        Image(systemName: "trash")
                            .rotationEffect(.degrees(180))
                        Text("Clear Completed")
                    }
                }
                
                Section {
                    Button {
                        sheetIdentifier = SheetIdentifier(id: .showAbout)
                    } label: {
                        Image(systemName: "info.circle")
                        Text("About")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }.alert(item: $alertIdentifier) { alert in
                switch(alert.id) {
                case .resumeAll:
                    return Alert(title: Text("Confirm Resume All"), message: Text("Are you sure you want to resume all tasks?"), primaryButton: .default(Text("Resume")) {
                        qBittorrent.resumeAllTorrents()
                    }, secondaryButton: .cancel())
                case .pauseAll:
                    return Alert(title: Text("Confirm Pause All"), message: Text("Are you sure you want to pause all tasks?"), primaryButton: .default(Text("Pause")) {
                        qBittorrent.pauseAllTorrents()
                    }, secondaryButton: .cancel())
                }
            }.alert("Confirm Deletion", isPresented: $isAlertClearCompleted, actions: {
                Button("Delete Completed Tasks", role: .destructive) {
                    let completedTorrents = torrents.filter {torrent in torrent.progress == 1}
                    let completedHashes = completedTorrents.compactMap {torrent in torrent.hash}
                    
                    qBittorrent.deleteTorrents(hashes: completedHashes)
                }
                Button("Delete Completed Tasks with Files", role: .destructive) {
                    let completedTorrents = torrents.filter {torrent in torrent.progress == 1}
                    let completedHashes = completedTorrents.compactMap {torrent in torrent.hash}
                    
                    
                    qBittorrent.deleteTorrents(hashes: completedHashes, deleteFiles: true)
                }
            })
            .sheet(item: $sheetIdentifier) {
                sheet in
                switch sheet.id {
                case .showAbout:
                    return AboutView()
                }
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isFilterView.toggle()
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
    }
}
