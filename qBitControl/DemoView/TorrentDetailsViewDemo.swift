//
//  TorrentDetailsView.swift
//  qBitControl
//

import SwiftUI

struct ChangeCategoryViewDemo: View {
    
    @State var torrentHash: String
    
    @State private var categories: [String] = ["Category"]
    
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

            }
            .navigationTitle("Categories")
        }
    }
}

struct ChangePathViewDemo: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var path: String
    let torrentHash: String
    
    var body: some View {
        Form {
            Section {
                TextField("Save Path", text: $path, axis: .vertical)
                    .lineLimit(1...5)
            }
            
            Section {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Update")
                }
            }
        }.navigationTitle("Save Path")
    }
}

struct TorrentDetailsViewDemo: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var torrent: Torrent
    @State private var timer: Timer?
    @State private var buttonTextColor = UITraitCollection.current.userInterfaceStyle == .dark ? Color.white : Color.black
    @State private var presentDeleteAlert = false
    

    
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

                        if torrent.state.contains("paused") {
                            //qBittorrent.resumeTorrent(hash: torrent.hash)
                        } else {
                            //qBittorrent.pauseTorrent(hash: torrent.hash)
                        }

                        
                    }) {
                        if torrent.state.contains("paused") {
                            Text("Resume Task")
                        } else {
                            Text("Pause Task")
                        }
                    }
                    
                    Button(action: {

                        //qBittorrent.recheckTorrent(hash: torrent.hash)
                    }) {
                        Text("Recheck Task")
                    }
                    
                    Button(action: {
                       
                        //..qBittorrent.reannounceTorrent(hash: torrent.hash)
                    }) {
                        Text("Reannounce Task")
                    }
                    Button(action: {
                     
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
                        List {
                            Section(header: Text("5 peers")) {
                                TorrentDetailsPeersRowView(peer: .constant(Peer(client: "example client", connection: "BT", country: "Poland", country_code: "pl", dl_speed: 10000, downloaded: 100000, files: "example file", flags: "e", flags_desc: "e", ip: "192.168.1.1", port: 22222, progress: 1, relevance: 1, up_speed: 10000, uploaded: 10000)))
                                TorrentDetailsPeersRowView(peer: .constant(Peer(client: "example client", connection: "BT", country: "Netherlands", country_code: "nl", dl_speed: 10000, downloaded: 100000, files: "example file", flags: "e", flags_desc: "e", ip: "192.168.1.1", port: 22222, progress: 1, relevance: 1, up_speed: 10000, uploaded: 10000)))
                                TorrentDetailsPeersRowView(peer: .constant(Peer(client: "example client", connection: "BT", country: "Greece", country_code: "gr", dl_speed: 10000, downloaded: 100000, files: "example file", flags: "e", flags_desc: "e", ip: "192.168.1.1", port: 22222, progress: 1, relevance: 1, up_speed: 10000, uploaded: 10000)))
                                TorrentDetailsPeersRowView(peer: .constant(Peer(client: "example client", connection: "BT", country: "United Kingdom", country_code: "gb", dl_speed: 10000, downloaded: 100000, files: "example file", flags: "e", flags_desc: "e", ip: "192.168.1.1", port: 22222, progress: 1, relevance: 1, up_speed: 10000, uploaded: 10000)))
                                TorrentDetailsPeersRowView(peer: .constant(Peer(client: "example client", connection: "BT", country: "France", country_code: "fr", dl_speed: 10000, downloaded: 100000, files: "example file", flags: "e", flags_desc: "e", ip: "192.168.1.1", port: 22222, progress: 1, relevance: 1, up_speed: 10000, uploaded: 10000)))
                            }
                            
                            .navigationTitle("Peers")
                        }
                    } label: {
                        Text("Peers")
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
        }.confirmationDialog("Delete Task",isPresented: $presentDeleteAlert) {
            Button("Delete Task", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                //qBittorrent.deleteTorrent(hash: torrent.hash)
            }
            Button("Delete Task with Files", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                //qBittorrent.deleteTorrent(hash: torrent.hash, deleteFiles: true)
            }
            Button("Cancel", role: .cancel) {}
        }.refreshable() {
            //getTorrent()
        }
    }
}

/*struct TorrentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TorrentDetailsView()
    }
}*/
