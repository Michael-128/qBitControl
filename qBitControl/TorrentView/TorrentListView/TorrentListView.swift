//
//  LoggedInView.swift
//  qBitControl
//

import SwiftUI

    
struct TorrentListView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var torrents: [Torrent] = Array()
    
    @State private var searchQuery = ""
    @State private var sort = "name"
    @State private var reverse = false
    @State private var filter = "all"
    @State private var category: String = "None"
    @State private var tag: String = "None"
    
    @State private var totalDlSpeed = 0
    @State private var totalUpSpeed = 0
    
    @State private var isTorrentAddView = false
    @State private var isFilterView = false
    @State private var isDeleteAlert = false
    
    @Binding var isLoggedIn: Bool
    
    @State private var alertIdentifier: AlertIdentifier?
    @State private var isAlertClearCompleted: Bool = false
    
    let defaults = UserDefaults.standard
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Manage")) {
                    Button {
                        isTorrentAddView.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Task")
                        }
                    }.searchable(text: $searchQuery)
                }
    
                TorrentList(torrents: $torrents, searchQuery: $searchQuery, sort: $sort, reverse: $reverse, filter: $filter, category: $category, tag: $tag, isTorrentAddView: $isTorrentAddView)
                
                .navigationTitle(category == "None" ? "Tasks" : category.capitalized)
            }
            .toolbar() {
                ToolbarItem(placement: .navigationBarLeading) {
                    leftToolbarMenu()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isFilterView.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    
                }
            }
            .sheet(isPresented: $isFilterView, content: {
                TorrentFilterView(sort: $sort, reverse: $reverse, filter: $filter, category: $category, tag: $tag)
            })
            .sheet(isPresented: $isTorrentAddView, content: {
                TorrentAddView(isPresented: $isTorrentAddView)
            })
        }
    }
    
    func leftToolbarMenu() -> some View {
        Menu {
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
                        Text("Resume \(category.capitalized)")
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
                        Text("Pause \(category.capitalized)")
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
                    alertIdentifier =  AlertIdentifier(id: .pauseAll)
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
                Button(role: .destructive) {
                    alertIdentifier =  AlertIdentifier(id: .logOut)
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.forward")
                        .rotationEffect(.degrees(180))
                    Text("Log out")
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
            case .logOut:
                return Alert(title: Text("Confirm Logout"), message: Text("Are you sure you want to log out?"), primaryButton: .destructive(Text("Log Out")) {
                    qBittorrent.setCookie(cookie: "")
                    isLoggedIn = false
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
    }
}
    

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
