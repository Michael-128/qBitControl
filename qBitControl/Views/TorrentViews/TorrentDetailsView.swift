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
        let client = ServersHelper.shared.client ?? MockTorrentClient()
        _viewModel = StateObject(wrappedValue: TorrentDetailsViewModel(torrent: torrent, client: client))
        _trackersViewModel = StateObject(wrappedValue: TrackersViewModel(torrentHash: torrent.hash, client: client))
    }
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Management")) {
                    if viewModel.isPaused() {
                        Button { viewModel.toggleTorrentPause() } label: { Label("Resume Task", systemImage: "play.fill") }
                    } else {
                        Button { viewModel.toggleTorrentPause() } label: { Label("Pause Task", systemImage: "pause.fill") }
                    }
                    Button { viewModel.recheckTorrent() } label: { Label("Recheck Task", systemImage: "arrow.triangle.2.circlepath") }
                    Button { viewModel.reannounceTorrent() } label: { Label("Reannounce Task", systemImage: "antenna.radiowaves.left.and.right") }
                    if viewModel.isForceStart() {
                        Button { viewModel.setForceStart(value: false) } label: { Label("Stop Force Start", systemImage: "bolt.slash.fill").foregroundColor(.yellow) }
                    } else {
                        Button { viewModel.setForceStart(value: true) } label: { Label("Force Start", systemImage: "bolt.fill").foregroundColor(.yellow) }
                    }
                    Button { viewModel.deleteTorrent() } label: { Label("Delete Task", systemImage: "trash.fill").foregroundColor(.red) }
                }
                
                if let preferences = ServersHelper.shared.preferences {
                    if(preferences.queueing_enabled == true) {
                        Section(header: Text("Queue Management")) {
                            CustomLabelView(label: "Priority", value: "\(viewModel.torrent.priority)")
                            Button { viewModel.moveToTopPriority() } label: { Label("Move to Top", systemImage: "arrow.up.to.line") }
                            Button { viewModel.increasePriority() } label: { Label("Move Up", systemImage: "arrow.up") }
                            Button { viewModel.decreasePriority() } label: { Label("Move Down", systemImage: "arrow.down") }
                            Button { viewModel.moveToBottomPriority() } label: { Label("Move to Bottom", systemImage: "arrow.down.to.line") }
                        }
                    }
                }
                
                Section(header: Text("Status")) {
                    CustomLabelView(label: "State", value: viewModel.getState())
                    CustomLabelView(label: "Progress", value: viewModel.getProgress())
                    CustomLabelView(label: "ETA", value: viewModel.getETA())
                    CustomLabelView(label: "Download Speed", value: viewModel.getDownloadSpeed())
                    CustomLabelView(label: "Upload Speed", value: viewModel.getUploadSpeed())
                    CustomLabelView(label: "Downloaded", value: viewModel.getDownloaded())
                    CustomLabelView(label: "Uploaded", value: viewModel.getUploaded())
                    CustomLabelView(label: "Ratio", value: viewModel.getRatio())
                }
                
                Section(header: Text("Information")) {
                    CustomLabelView(label: "Name", value: viewModel.torrent.name)
                    CustomLabelView(label: "Added On", value: viewModel.getAddedOn())
                    
                    NavigationLink {
                        ChangeCategoryView(torrentHash: viewModel.torrent.hash, category: viewModel.torrent.category, onCategoryChange: {_ in
                            viewModel.getTorrent()
                        })
                    } label: {
                        CustomLabelView(label: "Categories", value: viewModel.getCategory())
                    }
                    
                    NavigationLink{
                        ChangeTagsView(torrentHash: viewModel.torrent.hash, selectedTags: viewModel.getTags())
                    } label: {
                        CustomLabelView(label: "Tags", value: viewModel.getTag())
                    }
                    
                    CustomLabelView(label: "Size", value: viewModel.getSize())
                    CustomLabelView(label: "Total Size", value: viewModel.getTotalSize())
                    CustomLabelView(label: "Availability", value: viewModel.getAvailability())
                }
                
                Section(header: Text("Session")) {
                    CustomLabelView(label: "Downloaded", value: viewModel.getDownloadedSession())
                    CustomLabelView(label: "Uploaded", value: viewModel.getUploadedSession())
                }
                
                Section(header: Text("Connections")) {
                    NavigationLink {
                        PeersView(torrentHash: .constant(viewModel.torrent.hash))
                    } label: {
                        Label("Peers", systemImage: "person.2.fill")
                    }
                    NavigationLink {
                        TrackersView(viewModel: trackersViewModel)
                    } label: {
                        Label("Trackers", systemImage: "point.3.connected.trianglepath.dotted")
                    }
                }
                
                Section(header: Text("Files")) {
                    NavigationLink {
                        ChangePathView(path: viewModel.torrent.save_path, torrentHash: viewModel.torrent.hash)
                    } label: {
                        Label {
                            CustomLabelView(label: "Save Path", value: viewModel.torrent.save_path)
                        } icon: {
                            Image(systemName: "folder.fill")
                        }
                    }
                    
                    NavigationLink {
                        FilesView(torrentHash: .constant(viewModel.torrent.hash), client: ServersHelper.shared.client ?? MockTorrentClient())
                    } label: {
                        Label("Files", systemImage: "doc.fill")
                    }
                }
                
                Section(header: Text("Advanced")) {
                    Toggle(isOn: $viewModel.isSequentialDownload) {
                        Label("Sequential Download", systemImage: "arrow.right.to.line.compact")
                    }
                        .onChange(of: viewModel.isSequentialDownload, perform: { _ in viewModel.toggleSequentialDownload() })
                    Toggle(isOn: $viewModel.isFLPiecesFirst) {
                        Label("First & Last Pieces First", systemImage: "arrow.left.and.right")
                    }
                        .onChange(of: viewModel.isFLPiecesFirst, perform: { _ in viewModel.toggleFLPiecesFirst() })
                }
                
                Section(header: Text("Limits")) {
                    CustomLabelView(label: "Download Limit", value: viewModel.getDownloadLimit())
                    CustomLabelView(label: "Upload Limit", value: viewModel.getUploadLimit())
                    CustomLabelView(label: "Share Ratio Limit", value: viewModel.getRatioLimit())
                    CustomLabelView(label: "Seeding Time Limit", value: viewModel.getSeedingTimeLimit())
                    CustomLabelView(label: "Inactive Seeding Limit", value: viewModel.getInactiveSeedingTimeLimit())
                    CustomLabelView(label: "Limit Action", value: viewModel.getShareLimitAction())
                    
                    NavigationLink {
                        TorrentLimitsView(torrent: viewModel.torrent) { dl, up, ratio, time, inactive, action in
                            viewModel.updateTorrentLimits(
                                dlLimitKiB: dl,
                                upLimitKiB: up,
                                ratioLimit: ratio,
                                seedingTimeLimit: time,
                                inactiveSeedingTimeLimit: inactive,
                                shareLimitAction: action
                            )
                        }
                    } label: {
                        Label("Configure Limits", systemImage: "slider.horizontal.3")
                    }
                }
                
            }
            .navigationTitle("Details")
        }
        .onAppear() { viewModel.setRefreshTimer() }
        .onDisappear() { viewModel.removeRefreshTimer() }
        .alert("Delete Task", isPresented: $viewModel.isDeleteAlert) {
            Button("Delete Task", role: .destructive) { viewModel.deleteTorrent(then: self.dismiss) }
            Button("Delete Task with Files", role: .destructive) { viewModel.deleteTorrentWithFiles(then: self.dismiss) }
            Button("Cancel", role: .cancel) { }
        }.refreshable() { viewModel.getTorrent() }
    }
}
