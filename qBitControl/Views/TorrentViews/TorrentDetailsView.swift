//
//  TorrentDetailsView.swift
//  qBitControl
//

import SwiftUI

struct ChangeCategoryView: View {
    
    @State var torrentHash: String
    
    @State private var categories: [Category] = []

    @State var category: String

    
    var body: some View {
        VStack {
            Form {
                if categories.count > 1 {
                    Picker("Categories", selection: $category) {
                        Text("None").tag("")
                        ForEach(categories, id: \.self) { category in
                            Text(category.name).tag(category.name)
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
            qBittorrent.getCategories(completionHandler: { response in
                // Append sorted list of Category objects to ensure "None" always appears at the top
                self.categories.append(contentsOf: response.map { $1 }.sorted { $0.name < $1.name })
            })
        }.onChange(of: category) {
            category in
            let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/setCategory", queryItems: [
                URLQueryItem(name: "hashes", value: torrentHash),
                URLQueryItem(name: "category", value: category)
            ])
            
            qBitRequest.requestTorrentManagement(request: request, statusCode: {
                code in
            })
        }
    }
}

struct ChangePathView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var path: String
    let torrentHash: String
    
    func setPath() {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/setLocation", queryItems: [
            URLQueryItem(name: "hashes", value: torrentHash),
            URLQueryItem(name: "location", value: path)
        ])
        
        qBitRequest.requestTorrentManagement(request: request, statusCode: {
            code in
            print("Code: \(code ?? -1)")
        })
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Save Path", text: $path, axis: .vertical)
                    .lineLimit(1...5)
            }
            
            Section {
                Button {
                    setPath()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Update")
                }
            }
        }.navigationTitle("Save Path")
    }
}

struct TorrentDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var torrent: Torrent
    
    @State private var isSequentialDownload: Bool = false
    
    @State private var timer: Timer?
    @State private var buttonTextColor = UITraitCollection.current.userInterfaceStyle == .dark ? Color.white : Color.black
    @State private var presentDeleteAlert = false
    @StateObject private var trackersViewModel: TrackersViewModel
    
    init(torrent: Torrent) {
        self.torrent = torrent
        _trackersViewModel = StateObject(wrappedValue: TrackersViewModel(torrentHash: torrent.hash))
    }
    
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    
    func getTorrent() {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/info", queryItems: [URLQueryItem(name:"hashes", value: torrent.hash)])
        
        qBitRequest.requestTorrentListJSON(request: request) {
            torrent in
            if torrent.count >= 1 {
                self.torrent = torrent[0]
                self.isSequentialDownload = self.torrent.seq_dl
            } // There should be only one torrent in the response
        }
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
                            Text("Resume Task")
                        } else {
                            Text("Pause Task")
                        }
                    }
                    
                    Button(action: {
                        impactMed.impactOccurred()
                        qBittorrent.recheckTorrent(hash: torrent.hash)
                    }) {
                        Text("Recheck Task")
                    }
                    
                    Button(action: {
                        impactMed.impactOccurred()
                        qBittorrent.reannounceTorrent(hash: torrent.hash)
                    }) {
                        Text("Reannounce Task")
                    }
                    Button(action: {
                        impactMed.impactOccurred()
                        presentDeleteAlert = true
                    }) {
                        Text("Delete Task")
                            .foregroundColor(Color.red)
                    }
                }
                
                if let preferences = qBittorrent.getSavedPreferences() {
                    if(preferences.queueing_enabled == true) {
                        Section(header: Text("Queue Management")) {
                            CustomLabelView(label: "Priority", value: "\(torrent.priority)")
                            
                            Button(action: {
                                impactMed.impactOccurred()
                                qBittorrent.topPriorityTorrents(hashes: [torrent.hash])
                            }) {
                                Text("Move to Top")
                            }
                            
                            Button(action: {
                                impactMed.impactOccurred()
                                qBittorrent.increasePriorityTorrents(hashes: [torrent.hash])
                            }) {
                                Text("Move Up")
                            }
                            
                            Button(action: {
                                impactMed.impactOccurred()
                                qBittorrent.decreasePriorityTorrents(hashes: [torrent.hash])
                            }) {
                                Text("Move Down")
                            }
                            
                            Button(action: {
                                impactMed.impactOccurred()
                                qBittorrent.bottomPriorityTorrents(hashes: [torrent.hash])
                            }) {
                                Text("Move to Bottom")
                            }
                        }
                    }
                }
                
                Section(header: Text("Information")) {
                    CustomLabelView(label: "Name", value: "\(torrent.name)")
                    
                    CustomLabelView(label: "Added On", value: "\( qBittorrent.getFormatedDate(date: torrent.added_on) )")
                    
                    //listElement(label: "Categories", value: "\( torrent.category != "" ? torrent.category : "None" )")
                    
                    NavigationLink {
                        ChangeCategoryView(torrentHash: torrent.hash, category: torrent.category)
                    } label: {
                        CustomLabelView(label: "Categories", value: "\( torrent.category != "" ? torrent.category : "None" )")
                    }
                    
                    /*NavigationLink {
                        ChangeTagsView(torrentHash: torrent.hash, selectedTags: torrent.tags.components(separatedBy: ","))
                    } label: {*/
                        CustomLabelView(label: "Tags", value: "\( torrent.tags != "" ? torrent.tags : "None" )")
                    //}
                    
                    CustomLabelView(label: "Size", value: "\(qBittorrent.getFormatedSize(size: torrent.size))")
                    
                    CustomLabelView(label: "Total Size", value: "\(qBittorrent.getFormatedSize(size: torrent.total_size))")
                    
                    CustomLabelView(label: "Availability", value: torrent.availability < 0 ? "-" : "\(String(format: "%.1f", torrent.availability*100))%")
                }
                
                Section(header: Text("Connections")) {
                    NavigationLink {
                        PeersView(torrentHash: .constant(torrent.hash))
                    } label: {
                        Text("Peers")
                    }
                    NavigationLink {
                        TrackersView(viewModel: trackersViewModel)
                    } label: {
                        Text("Trackers")
                    }
                }
                
                Section(header: Text("Files")) {
                    NavigationLink {
                        ChangePathView(path: torrent.save_path, torrentHash: torrent.hash)
                    } label: {
                        CustomLabelView(label: "Save Path", value: torrent.save_path)
                    }
                    
                    NavigationLink {
                        FilesView(torrentHash: .constant(torrent.hash))
                    } label: {
                        Text("Files")
                    }
                }
                
                Section(header: Text("Status")) {
                    CustomLabelView(label: "State", value: "\(qBittorrent.getState(state: torrent.state))")
                    
                    CustomLabelView(label: "Progress", value: "\(String(format: "%.2f", (torrent.progress*100)))%")
                    
                    CustomLabelView(label: "Download Speed", value: "\(qBittorrent.getFormatedSize(size: torrent.dlspeed))/s")
                    
                    CustomLabelView(label: "Upload Speed", value: "\(qBittorrent.getFormatedSize(size: torrent.upspeed))/s")
                    
                    CustomLabelView(label: "Downloaded", value: "\(qBittorrent.getFormatedSize(size: torrent.downloaded))")
                    
                    CustomLabelView(label: "Uploaded", value: "\(qBittorrent.getFormatedSize(size: torrent.uploaded))")
                    
                    CustomLabelView(label: "Ratio", value: "\(String(format:"%.2f", torrent.ratio))")
                    
                }
                
                Section(header: Text("Session")) {
                    CustomLabelView(label: "Downloaded", value: "\(qBittorrent.getFormatedSize(size: torrent.downloaded_session))")
                    
                    CustomLabelView(label: "Uploaded", value: "\(qBittorrent.getFormatedSize(size: torrent.uploaded_session))")
                }
                
                Section(header: Text("Advanced")) {
                    Toggle(isOn: $isSequentialDownload, label: {Text("Sequential Download")})
                        .onTapGesture {
                            qBittorrent.toggleSequentialDownload(hashes: [torrent.hash])
                            isSequentialDownload = !isSequentialDownload
                        }
                }
                
                Section(header: Text("Limits")) {
                    //listElement(label: "Maximum Seeding Time", value: "n/a")
                    
                    CustomLabelView(label: "Maximum Ratio", value: "\(torrent.max_ratio > -1 ? String(format:"%.2f", torrent.max_ratio) : NSLocalizedString("None", comment: "None"))")
                    
                    CustomLabelView(label: "Download Limit", value: "\(torrent.dl_limit > 0 ? qBittorrent.getFormatedSize(size: torrent.dl_limit)+"/s" : NSLocalizedString("None", comment: "None"))")
                    
                    CustomLabelView(label: "Upload Limit", value: "\(torrent.up_limit > 0 ? qBittorrent.getFormatedSize(size: torrent.up_limit)+"/s" : NSLocalizedString("None", comment: "None"))")
                }
                
            }
            .navigationTitle("Details")
        }
        .onAppear() {
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                timer in
                getTorrent()
            }
            isSequentialDownload = torrent.seq_dl
        }.onDisappear() {
            timer?.invalidate()
        }.confirmationDialog("Delete Task",isPresented: $presentDeleteAlert) {
            Button("Delete Task", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                qBittorrent.deleteTorrent(hash: torrent.hash)
            }
            Button("Delete Task with Files", role: .destructive) {
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
