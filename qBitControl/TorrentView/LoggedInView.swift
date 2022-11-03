//
//  LoggedInView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 25/10/2022.
//

import SwiftUI

struct LoggedInView: View {
    @Environment(\.presentationMode) var presentationMode
    
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
    
    let defaults = UserDefaults.standard
    
    func getTorrents() {
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
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Manage")) {
                    Button {
                        isTorrentAddView.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Torrent")
                        }
                    }.searchable(text: $searchQuery)
                }
                Section(header:
                    HStack {
                        Text("\(torrents.count) Torrents")
                        Text("•")
                        Image(systemName: "arrow.down")
                        Text("\( qBittorrent.getFormatedSize(size: torrents.compactMap({$0.dlspeed}).reduce(0, +)) )/s")
                        Text("•")
                        Image(systemName: "arrow.up")
                        Text("\( qBittorrent.getFormatedSize(size: torrents.compactMap({$0.upspeed}).reduce(0, +)) )/s")
                    }
                ) {
                    Group {
                        ForEach(torrents, id: \.name) {
                            torrent in
                            if searchQuery == "" || torrent.name.lowercased().contains(searchQuery.lowercased()) {
                                NavigationLink {
                                    TorrentDetailsView(torrent: torrent)
                                } label: {
                                    TorrentRowView(name: torrent.name, progress: torrent.progress, state: torrent.state, dlspeed: torrent.dlspeed, upspeed: torrent.upspeed, ratio: torrent.ratio)
                                        .contextMenu() {
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
                                                hash = torrent.hash
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
                }
                
                .navigationTitle("Torrents")
            }
            .toolbar() {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        qBittorrent.setURL(url: "")
                        qBittorrent.setCookie(cookie: "")
                        isLoggedIn = false
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                            .rotationEffect(.degrees(180))
                        Text("Log out")
                    }
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
            }.confirmationDialog("Delete Torrent",isPresented: $isDeleteAlert) {
                Button("Delete Torrent", role: .destructive) {
                    presentationMode.wrappedValue.dismiss()
                    qBittorrent.deleteTorrent(hash: hash)
                    hash = ""
                }
                Button("Delete Torrent with Files", role: .destructive) {
                    presentationMode.wrappedValue.dismiss()
                    qBittorrent.deleteTorrent(hash: hash, deleteFiles: true)
                    hash = ""
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
