//
//  LoggedInView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 25/10/2022.
//

import SwiftUI

struct LoggedInView: View {
    @State private var timer: Timer?
    @State var torrents: [Torrent] = Array()
    @State private var searchQuery = ""
    @State private var sort = "name"
    @State private var reverse = false
    
    @State private var totalDlSpeed = 0
    @State private var totalUpSpeed = 0
    
    @State private var isTorrentAddView = false
    
    @Binding var isLoggedIn: Bool
    
    let defaults = UserDefaults.standard
    
    func getTorrents() {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/info", queryItems: [URLQueryItem(name: "sort", value: sort), URLQueryItem(name: "reverse", value: String(reverse))])
        
        qBitRequest.requestTorrentListJSON(request: request) {
            torrent in
            torrents = torrent
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Search")) {
                    TextField("Search", text: $searchQuery)
                        .autocapitalization(.none)
                    Picker(selection: $sort, label: Text("Sort")) {
                        Group {
                            Text("Added On").tag("added_on")
                            Text("Amount Left").tag("amount_left")
                            //Text("Auto Torrent Management").tag("auto_tmm")
                            Text("Availability").tag("availability")
                            Text("Category").tag("category")
                            Text("Completed").tag("completed")
                            Text("Completion On").tag("completion_on")
                            //Text("Content Path").tag("content_path")
                            Text("Download Limit").tag("dl_limit")
                            Text("Download Speed").tag("dlspeed")
                        }
                        
                        Group {
                            Text("Downloaded").tag("downloaded")
                            Text("Downloaded Session").tag("downloaded_session")
                            Text("ETA").tag("eta")
                            //Text("FL Piece Ratio").tag("f_l_piece_prio")
                            //Text("Force Start").tag("force_start")
                            //Text("Hash").tag("hash")
                            Text("Last Activity").tag("last_activity")
                            //Text("Magnet URI").tag("magnet_uri")
                            Text("Max Ratio").tag("max_ratio")
                            Text("Max Seeding Time").tag("max_seeding_time")
                        }
                        
                        Group {
                            Text("Name").tag("name")
                            Text("Seeds In Swarm").tag("num_complete")
                            Text("Peers In Swarm").tag("num_incomplete")
                            Text("Connected Leeches").tag("num_leechs")
                            Text("Connected Seeds").tag("num_seeds")
                            //Text("Priority").tag("priority")
                            Text("Progress").tag("progress")
                            Text("Ratio").tag("ratio")
                            Text("Ratio Limit").tag("ratio_limit")
                        }
                        
                        Group {
                            //Text("Save Path").tag("save_path")
                            Text("Seeding Time").tag("seeding_time")
                            Text("Seeding Time Limit").tag("seeding_time_limit")
                            //Text("Seen Complete").tag("seen_complete")
                            //Text("Seq DL").tag("seq_dl")
                            Text("Size").tag("size")
                            Text("State").tag("state")
                            //Text("Super Seeding").tag("super_seeding")
                            Text("Tags").tag("tags")
                            Text("Time Active").tag("time_active")
                            Text("Total Size").tag("total_size")
                        }
                        
                        Group {
                            //Text("Tracker").tag("tracker")
                            Text("Upload Limit").tag("up_limit")
                            Text("Uploaded").tag("uploaded")
                            Text("Uploaded Session").tag("uploaded_session")
                            Text("Upload Speed").tag("upspeed")
                        }
                    }.onChange(of: sort, perform: {
                        value in
                        defaults.set(sort, forKey: "sort")
                    })
                    Toggle(isOn: $reverse) {
                        Text("Reverse")
                    }.onChange(of: reverse) { value in
                        defaults.set(reverse, forKey: "reverse")
                        getTorrents()
                    }
                }
                
                
                Section(header:
                    HStack {
                        Text("\(torrents.count) Torrents")
                        Text("•")
                        Image(systemName: "arrow.down")
                        Text("\( qBittorrent.getFormatedSize(size: torrents.compactMap({$0.dlspeed}).reduce(0, +)) )")
                        Text("•")
                        Image(systemName: "arrow.up")
                        Text("\( qBittorrent.getFormatedSize(size: torrents.compactMap({$0.upspeed}).reduce(0, +)) )")
                    }
                ) {
                    ForEach(torrents, id: \.name) {
                        torrent in
                        if searchQuery == "" || torrent.name.lowercased().contains(searchQuery.lowercased()) {
                            NavigationLink {
                                TorrentDetailsView(torrent: torrent)
                            } label: {
                                TorrentRowView(name: torrent.name, progress: torrent.progress, state: torrent.state, dlspeed: torrent.dlspeed, upspeed: torrent.upspeed, ratio: torrent.ratio)
                            }
                        }
                    }
                }.onAppear() {
                    reverse = defaults.bool(forKey: "reverse")
                    sort = defaults.string(forKey: "sort") ?? sort
                    
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
                        isTorrentAddView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                }
            }
            .sheet(isPresented: $isTorrentAddView, content: {
                TorrentAddView(isPresented: $isTorrentAddView)
            })
            .refreshable() {
                getTorrents()
            }
        }
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
