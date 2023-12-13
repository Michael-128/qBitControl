//
//  TorrentDetailsView.swift
//  qBitControl
//

import SwiftUI
struct TorrentDetailsDemo: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var torrent: Torrent
    @State private var timer: Timer?
    @State private var buttonTextColor = UITraitCollection.current.userInterfaceStyle == .dark ? Color.white : Color.black
    @State private var presentDeleteAlert = false
    
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack {
            //Text("Torrent Details")
             //   .font(.tit
            List {
                Section(header: Text("Management")) {
                    Button(action: {
                        impactMed.impactOccurred()
                        if torrent.state.contains("paused") {
                            //qBittorrent.resumeTorrent(hash: torrent.hash)
                        } else {
                            //qBittorrent.pauseTorrent(hash: torrent.hash)
                        }
                        //getTorrent()
                        
                    }) {
                        if torrent.state.contains("paused") {
                            Text("Resume Task")
                        } else {
                            Text("Pause Task")
                        }
                    }
                    
                    Button(action: {
                        impactMed.impactOccurred()
                        //qBittorrent.recheckTorrent(hash: torrent.hash)
                    }) {
                        Text("Recheck Task")
                    }
                    
                    Button(action: {
                        impactMed.impactOccurred()
                        //qBittorrent.reannounceTorrent(hash: torrent.hash)
                    }) {
                        Text("Reannounce Task")
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
                    ListElement(label: "Name", value: "\(torrent.name)")
                    
                    ListElement(label: "Added On", value: "\( qBittorrent.getFormatedDate(date: torrent.added_on) )")
                    
                    //listElement(label: "Categories", value: "\( torrent.category != "" ? torrent.category : "None" )")
                    
                    ListElement(label: "Categories", value: "\( torrent.category != "" ? torrent.category : "None" )")
                    
                    /*NavigationLink {
                        ChangeTagsView(torrentHash: torrent.hash, selectedTags: torrent.tags.components(separatedBy: ","))
                    } label: {*/
                        ListElement(label: "Tags", value: "\( torrent.tags != "" ? torrent.tags : "None" )")
                    //}
                    
                    ListElement(label: "Size", value: "\(qBittorrent.getFormatedSize(size: torrent.size))")
                    
                    ListElement(label: "Total Size", value: "\(qBittorrent.getFormatedSize(size: torrent.total_size))")
                    
                    ListElement(label: "Availability", value: torrent.availability < 0 ? "-" : "\(String(format: "%.1f", torrent.availability))%")
                }
                
                Section(header: Text("Connections")) {
                    NavigationLink {
                        TorrentPeersDemo(torrentHash: .constant(torrent.hash))
                    } label: {
                        Text("Peers")
                    }
                }
                
                Section(header: Text("Files")) {
                    NavigationLink {
                        ChangePathView(path: torrent.save_path, torrentHash: torrent.hash)
                    } label: {
                        ListElement(label: "Save Path", value: torrent.save_path)
                    }
                    
                    NavigationLink {
                        TorrentFilesDemo(torrentHash: .constant(torrent.hash))
                    } label: {
                        Text("Files")
                    }
                }
                
                Section(header: Text("Status")) {
                    ListElement(label: "State", value: "\(qBittorrent.getState(state: torrent.state))")
                    
                    ListElement(label: "Progress", value: "\(String(format: "%.2f", (torrent.progress*100)))%")
                    
                    ListElement(label: "Download Speed", value: "\(qBittorrent.getFormatedSize(size: torrent.dlspeed))/s")
                    
                    ListElement(label: "Upload Speed", value: "\(qBittorrent.getFormatedSize(size: torrent.upspeed))/s")
                    
                    ListElement(label: "Downloaded", value: "\(qBittorrent.getFormatedSize(size: torrent.downloaded))")
                    
                    ListElement(label: "Uploaded", value: "\(qBittorrent.getFormatedSize(size: torrent.uploaded))")
                    
                    ListElement(label: "Ratio", value: "\(String(format:"%.2f", torrent.ratio))")
                    
                }
                
                Section(header: Text("Session")) {
                    ListElement(label: "Downloaded", value: "\(qBittorrent.getFormatedSize(size: torrent.downloaded_session))")
                    
                    ListElement(label: "Uploaded", value: "\(qBittorrent.getFormatedSize(size: torrent.uploaded_session))")
                }
                
                Section(header: Text("Limits")) {
                    //listElement(label: "Maximum Seeding Time", value: "n/a")
                    
                    ListElement(label: "Maximum Ratio", value: "\(torrent.max_ratio > -1 ? String(format:"%.2f", torrent.max_ratio) : "None")")
                    
                    ListElement(label: "Download Limit", value: "\(torrent.dl_limit > 0 ? qBittorrent.getFormatedSize(size: torrent.dl_limit)+"/s" : "None")")
                    
                    ListElement(label: "Upload Limit", value: "\(torrent.up_limit > 0 ? qBittorrent.getFormatedSize(size: torrent.up_limit)+"/s" : "None")")
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
