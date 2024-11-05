//
//  TorrentDetailsView.swift
//  qBitControl
//

import SwiftUI


struct TorrentDetailsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var trackersViewModel: TrackersViewModel
    @StateObject private var viewModel: TorrentDetailsViewModel
    
    init(torrent: Torrent) {
        _viewModel = StateObject(wrappedValue: TorrentDetailsViewModel(torrent: torrent))
        _trackersViewModel = StateObject(wrappedValue: TrackersViewModel(torrentHash: torrent.hash))
    }
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Management")) {
                    Button { viewModel.toggleTorrentPause() } label: { Text(viewModel.isPaused() ? "Resume Task" : "Pause Task") }
                    Button { viewModel.recheckTorrent() } label: { Text("Recheck Task") }
                    Button { viewModel.reannounceTorrent() } label: { Text("Reannounce Task") }
                    Button { viewModel.deleteTorrent() } label: { Text("Delete Task").foregroundColor(Color.red) }
                }
                
                if let preferences = qBittorrent.getSavedPreferences() {
                    if(preferences.queueing_enabled == true) {
                        Section(header: Text("Queue Management")) {
                            CustomLabelView(label: "Priority", value: "\(viewModel.torrent.priority)")
                            Button { viewModel.moveToTopPriority() } label: { Text("Move to Top") }
                            Button { viewModel.increasePriority() } label: { Text("Move Up") }
                            Button { viewModel.decreasePriority() } label: { Text("Move Down") }
                            Button { viewModel.moveToBottomPriority() } label: { Text("Move to Bottom") }
                        }
                    }
                }
                
                Section(header: Text("Information")) {
                    CustomLabelView(label: "Name", value: viewModel.torrent.name)
                    CustomLabelView(label: "Added On", value: viewModel.getAddedOn())
                    
                    NavigationLink {
                        ChangeCategoryView(torrentHash: viewModel.torrent.hash, category: viewModel.torrent.category)
                    } label: {
                        CustomLabelView(label: "Categories", value: viewModel.getCategory())
                    }
                    
                    CustomLabelView(label: "Tags", value: viewModel.getTags())
                    CustomLabelView(label: "Size", value: viewModel.getSize())
                    CustomLabelView(label: "Total Size", value: viewModel.getTotalSize())
                    CustomLabelView(label: "Availability", value: viewModel.getAvailability())
                }
                
                Section(header: Text("Connections")) {
                    NavigationLink {
                        PeersView(torrentHash: .constant(viewModel.torrent.hash))
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
                        ChangePathView(path: viewModel.torrent.save_path, torrentHash: viewModel.torrent.hash)
                    } label: {
                        CustomLabelView(label: "Save Path", value: viewModel.torrent.save_path)
                    }
                    
                    NavigationLink {
                        FilesView(torrentHash: .constant(viewModel.torrent.hash))
                    } label: {
                        Text("Files")
                    }
                }
                
                Section(header: Text("Status")) {
                    CustomLabelView(label: "State", value: viewModel.getState())
                    CustomLabelView(label: "Progress", value: viewModel.getProgress())
                    CustomLabelView(label: "Download Speed", value: viewModel.getDownloadSpeed())
                    CustomLabelView(label: "Upload Speed", value: viewModel.getUploadSpeed())
                    CustomLabelView(label: "Downloaded", value: viewModel.getDownloaded())
                    CustomLabelView(label: "Uploaded", value: viewModel.getUploaded())
                    CustomLabelView(label: "Ratio", value: viewModel.getRatio())
                }
                
                Section(header: Text("Session")) {
                    CustomLabelView(label: "Downloaded", value: viewModel.getDownloadedSession())
                    CustomLabelView(label: "Uploaded", value: viewModel.getUploadedSession())
                }
                
                Section(header: Text("Advanced")) {
                    Toggle(isOn: $viewModel.isSequentialDownload, label: { Text("Sequential Download") })
                        .onTapGesture { viewModel.toggleSequentialDownload() }
                }
                
                Section(header: Text("Limits")) {
                    CustomLabelView(label: "Maximum Ratio", value: viewModel.getMaxRatio())
                    CustomLabelView(label: "Download Limit", value: viewModel.getDownloadLimit())
                    CustomLabelView(label: "Upload Limit", value: viewModel.getUploadLimit())
                }
                
            }
            .navigationTitle("Details")
        }
        .onAppear() { viewModel.setRefreshTimer() }
        .onDisappear() { viewModel.removeRefreshTimer() }
        .confirmationDialog("Delete Task", isPresented: $viewModel.isDeleteAlert) {
            Button("Delete Task", role: .destructive) { viewModel.deleteTorrent(then: self.dismiss) }
            Button("Delete Task with Files", role: .destructive) { viewModel.deleteTorrentWithFiles(then: self.dismiss) }
            Button("Cancel", role: .cancel) { }
        }.refreshable() { viewModel.getTorrent() }
    }
}
