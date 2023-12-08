//
//  LoggedInView.swift
//  qBitControl
//

import SwiftUI

struct TorrentListView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhaseEnv
    @State var scenePhase: ScenePhase = .active
    
    @State private var timer: Timer?
    @State var torrents: [Torrent] = Array()
    
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
    
    @State private var hash = ""
    
    @Binding var isLoggedIn: Bool
    
    @State private var alertIdentifier: AlertIdentifier?
    
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
                
                Section(header: torrentListHeader()) {
                    Group {
                        ForEach(torrents, id: \.hash) {
                            torrent in
                            if searchQuery == "" || torrent.name.lowercased().contains(searchQuery.lowercased()) {
                                NavigationLink {
                                    TorrentDetailsView(torrent: torrent)
                                } label: {
                                    TorrentRowView(name: torrent.name, progress: torrent.progress, state: torrent.state, dlspeed: torrent.dlspeed, upspeed: torrent.upspeed, ratio: torrent.ratio)
                                        .contextMenu() {
                                            torrentRowContextMenu(torrent: torrent)
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
                }.onChange(of: scenePhaseEnv) {
                    phase in
                    scenePhase = phase
                }
                
                .navigationTitle(category == "None" ? "Tasks" : category)
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
            .refreshable() {
                getTorrents()
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
    }
    
    func getTorrents() {
        if(scenePhase != .active) {
            //print("App inactive")
            return
        }
        if(isFilterView) {
            //print("Filter view active")
            return
        }
        if(isTorrentAddView) {
            //print("Torrent view active")
            return
        }
        
        //print("Fetching torrents")
        //print(scenePhase)
        
        var queryItems = [URLQueryItem(name: "sort", value: sort), URLQueryItem(name: "filter", value: filter), URLQueryItem(name: "reverse", value: String(reverse))]
        
        if category != "None" {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        if tag != "None" {
            queryItems.append(URLQueryItem(name: "tag", value: category))
        }
        
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/info", queryItems: queryItems)
        
        qBitRequest.requestTorrentListJSON(request: request) {
            torrent in
            torrents = torrent
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
        Group {
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
    
    func leftToolbarMenu() -> some View {
        Menu {
            /*Section {
                Button {
                    //alertIdentifier = AlertIdentifier(id: .resumeAll)
                } label: {
                    Image(systemName: "play")
                        .rotationEffect(.degrees(180))
                    Text("Resume Category")
                }
                
                Button {
                    //alertIdentifier =  AlertIdentifier(id: .pauseAll)
                } label: {
                    Image(systemName: "pause")
                        .rotationEffect(.degrees(180))
                    Text("Pause Category")
                }
            }*/
            
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
        }
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
