//
//  TorrentDetailsView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 26/10/2022.
//

import SwiftUI

struct ChangeCategoryView: View {
    
    @State var torrentHash: String
    
    @State private var categories: [String] = []
    
    @State var category: String

    
    var body: some View {
        VStack {
            Form {
                if categories.count > 1 {
                    Picker("Categories", selection: $category) {
                        Text("None").tag("")
                        ForEach(categories, id: \.self) {
                            category in
                            Text(category).tag(category)
                        }
                    }.pickerStyle(.inline)
                }
                
                /*Button {
                    // link to management view
                } label: {
                    Text("Manage Categories")
                        .frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                    .listRowBackground(Color.blue)*/
            }
            .navigationTitle("Categories")
        }.onAppear() {
            qBittorrent.getCategories(completionHandler: {
                categories in
                
                for (category, _) in categories {
                    self.categories.append(category)
                    self.categories.sort(by: <)
                }
            })
        }.onChange(of: category) {
            category in
            print(category)
            let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/setCategory", queryItems: [
                URLQueryItem(name: "hashes", value: torrentHash),
                URLQueryItem(name: "category", value: category)
            ])
            
            qBitRequest.requestTorrentManagement(request: request, statusCode: {
                code in
                print(code)
            })
        }
    }
}

struct TorrentDetailsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var torrent: Torrent
    @State private var timer: Timer?
    @State private var buttonTextColor = UITraitCollection.current.userInterfaceStyle == .dark ? Color.white : Color.black
    @State private var presentDeleteAlert = false
    
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    
    func getTorrent() {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/info", queryItems: [URLQueryItem(name:"hashes", value: torrent.hash)])
        
        qBitRequest.requestTorrentListJSON(request: request) {
            torrent in
            if torrent.count >= 1 {
                self.torrent = torrent[0]
            } // There should be only one torrent in the response
        }
    }
    
    func listElement(label: String, value: String) -> some View {
        Button(action: {UIPasteboard.general.string = "\(value)"}) {
            HStack {
                Text("\(label)")
                Spacer()
                Text("\(value)")
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
            }
        }.foregroundColor(buttonTextColor)
    }
    
    var body: some View {
        VStack {
            //Text("Torrent Details")
             //   .font(.tit
            List {
                Section(header: Text("Management")) {
                    Button(action: {
                        impactMed.impactOccurred()
                        if torrent.state.contains("paused") {
                            qBittorrent.resumeTorrent(hash: torrent.hash)
                        } else {
                            qBittorrent.pauseTorrent(hash: torrent.hash)
                        }
                        getTorrent()
                        
                    }) {
                        if torrent.state.contains("paused") {
                            Text("Resume Torrent")
                        } else {
                            Text("Pause Torrent")
                        }
                    }
                    
                    Button(action: {
                        impactMed.impactOccurred()
                        qBittorrent.recheckTorrent(hash: torrent.hash)
                    }) {
                        Text("Recheck Torrent")
                    }
                    
                    Button(action: {
                        impactMed.impactOccurred()
                        qBittorrent.reannounceTorrent(hash: torrent.hash)
                    }) {
                        Text("Reannounce Torrent")
                    }
                    Button(action: {
                        impactMed.impactOccurred()
                        presentDeleteAlert = true
                    }) {
                        Text("Delete Torrent")
                            .foregroundColor(Color.red)
                    }
                }
                
                Section(header: Text("Information")) {
                    listElement(label: "Name", value: "\(torrent.name)")
                    
                    listElement(label: "Added On", value: "\( qBittorrent.getFormatedDate(date: torrent.added_on) )")
                    
                    //listElement(label: "Categories", value: "\( torrent.category != "" ? torrent.category : "None" )")
                    
                    NavigationLink {
                        ChangeCategoryView(torrentHash: torrent.hash, category: torrent.category)
                    } label: {
                        listElement(label: "Categories", value: "\( torrent.category != "" ? torrent.category : "None" )")
                    }
                    
                    /*NavigationLink {
                        ChangeTagsView(torrentHash: torrent.hash, selectedTags: torrent.tags.components(separatedBy: ","))
                    } label: {*/
                        listElement(label: "Tags", value: "\( torrent.tags != "" ? torrent.tags : "None" )")
                    //}
                    
                    listElement(label: "Size", value: "\(qBittorrent.getFormatedSize(size: torrent.size))")
                    
                    listElement(label: "Total Size", value: "\(qBittorrent.getFormatedSize(size: torrent.total_size))")
                    
                    listElement(label: "Availability", value: torrent.availability < 0 ? "-" : "\(String(format: "%.1f", torrent.availability))%")
                }
                
                Section(header: Text("Connections")) {
                    NavigationLink {
                        TorrentDetailsPeersView(torrentHash: .constant(torrent.hash))
                    } label: {
                        Text("Peers")
                    }
                    NavigationLink {
                        TorrentDetailsTrackersView(torrentHash: .constant(torrent.hash))
                    } label: {
                        Text("Trackers")
                    }
                }
                
                Section(header: Text("Files")) {
                    NavigationLink {
                        TorrentDetailsFilesView(torrentHash: .constant(torrent.hash))
                    } label: {
                        Text("Files")
                    }
                }
                
                Section(header: Text("Status")) {
                    listElement(label: "State", value: "\(qBittorrent.getState(state: torrent.state))")
                    
                    listElement(label: "Progress", value: "\(String(format: "%.2f", (torrent.progress*100)))%")
                    
                    listElement(label: "Download Speed", value: "\(qBittorrent.getFormatedSize(size: torrent.dlspeed))/s")
                    
                    listElement(label: "Upload Speed", value: "\(qBittorrent.getFormatedSize(size: torrent.upspeed))/s")
                    
                    listElement(label: "Downloaded", value: "\(qBittorrent.getFormatedSize(size: torrent.downloaded))")
                    
                    listElement(label: "Uploadeded", value: "\(qBittorrent.getFormatedSize(size: torrent.uploaded))")
                    
                    listElement(label: "Ratio", value: "\(String(format:"%.2f", torrent.ratio))")
                    
                }
                
                Section(header: Text("Session")) {
                    listElement(label: "Downloaded", value: "\(qBittorrent.getFormatedSize(size: torrent.downloaded_session))")
                    
                    listElement(label: "Uploadeded", value: "\(qBittorrent.getFormatedSize(size: torrent.uploaded_session))")
                }
                
                Section(header: Text("Limits")) {
                    //listElement(label: "Maximum Seeding Time", value: "n/a")
                    
                    listElement(label: "Maximum Ratio", value: "\(torrent.max_ratio > -1 ? String(format:"%.2f", torrent.max_ratio) : "None")")
                    
                    listElement(label: "Download Limit", value: "\(torrent.dl_limit > 0 ? qBittorrent.getFormatedSize(size: torrent.dl_limit)+"/s" : "None")")
                    
                    listElement(label: "Upload Limit", value: "\(torrent.up_limit > 0 ? qBittorrent.getFormatedSize(size: torrent.up_limit)+"/s" : "None")")
                }
                
            }
            .navigationTitle("Details")
        }
        .onAppear() {
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                timer in
                getTorrent()
            }
            
        }.onDisappear() {
            timer?.invalidate()
        }.confirmationDialog("Delete Torrent",isPresented: $presentDeleteAlert) {
            Button("Delete Torrent", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                qBittorrent.deleteTorrent(hash: torrent.hash)
            }
            Button("Delete Torrent with Files", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                qBittorrent.deleteTorrent(hash: torrent.hash, deleteFiles: true)
            }
            Button("Cancel", role: .cancel) {}
        }.refreshable() {
            getTorrent()
        }
    }
}

/*struct TorrentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TorrentDetailsView()
    }
}*/
