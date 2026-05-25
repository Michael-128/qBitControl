//
//  TorrentDetailsView.swift
//  qBitControl
//

import SwiftUI


struct TorrentDetailsView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var trackersViewModel: TrackersViewModel
    @StateObject private var viewModel: TorrentDetailsViewModel
    @State private var showCategorySheet = false
    @State private var showLimitsSheet = false
    @State private var showRenameAlert = false
    @State private var renameText = ""
    
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
                    Button { viewModel.setForceStart(value: !viewModel.isForceStart()) } label: { Text(viewModel.isForceStart() ? "Stop Force Start" : "Force Start").foregroundColor(.yellow) }
                    Button { viewModel.deleteTorrent() } label: { Text("Delete Task").foregroundColor(.red) }
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
                    Button {
                        renameText = viewModel.torrent.name
                        showRenameAlert = true
                    } label: {
                        CustomLabelView(label: "Name", lineLimit: 2, value: viewModel.torrent.name)
                    }
                    .buttonStyle(.plain)
                    CustomLabelView(label: "Added On", value: viewModel.getAddedOn())
                    
                    Button {
                        showCategorySheet = true
                    } label: {
                        CustomLabelView(label: "Categories", value: viewModel.getCategory())
                    }
                    .buttonStyle(.plain)
                    
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
                
                Section(header: Text("Advanced")) {
                    Toggle(isOn: $viewModel.isSequentialDownload, label: { Text("Sequential Download") })
                        .onChange(of: viewModel.isSequentialDownload, perform: { _ in viewModel.toggleSequentialDownload() })
                    Toggle(isOn: $viewModel.isFLPiecesFirst, label: { Text("First & Last Pieces First") })
                        .onChange(of: viewModel.isFLPiecesFirst, perform: { _ in viewModel.toggleFLPiecesFirst() })
                }

                Section(header: Text("Properties")) {
                    NavigationLink {
                        TorrentPropertiesView(hash: viewModel.torrent.hash)
                    } label: {
                        Text("Torrent Properties")
                    }
                }
                
                Section(header: Text("Limits")) {
                    Button {
                        showLimitsSheet = true
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            CustomLabelView(label: "Download Limit", value: viewModel.getDownloadLimit())
                            CustomLabelView(label: "Upload Limit", value: viewModel.getUploadLimit())
                            CustomLabelView(label: "Maximum Ratio", value: viewModel.getMaxRatio())
                        }
                    }
                    .buttonStyle(.plain)
                }
                
            }
            .navigationTitle("Details")
        }
        .onAppear() { viewModel.setRefreshTimer() }
        .onDisappear() { viewModel.removeRefreshTimer() }
        .sheet(isPresented: $showCategorySheet) {
            NavigationView {
                ChangeCategoryView(torrentHash: viewModel.torrent.hash, category: viewModel.torrent.category, onCategorySelected: { _ in
                    viewModel.getTorrent()
                    showCategorySheet = false
                })
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showCategorySheet = false
                        }
                    }
                }
            }
        }
        .confirmationDialog("Delete Task", isPresented: $viewModel.isDeleteAlert) {
            Button("Delete Task", role: .destructive) { viewModel.deleteTorrent(then: self.dismiss) }
            Button("Delete Task with Files", role: .destructive) { viewModel.deleteTorrentWithFiles(then: self.dismiss) }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showLimitsSheet) {
            ChangeLimitsView(
                torrentHash: viewModel.torrent.hash,
                dlLimit: viewModel.torrent.dl_limit,
                upLimit: viewModel.torrent.up_limit,
                ratioLimit: viewModel.torrent.ratio_limit,
                seedingTimeLimit: viewModel.torrent.seeding_time_limit
            )
        }
        .alert("Rename Torrent", isPresented: $showRenameAlert) {
            TextField("Name", text: $renameText)
            Button("Rename") {
                guard !renameText.isEmpty else { return }
                qBittorrent.renameTorrent(hash: viewModel.torrent.hash, name: renameText)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.getTorrent()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .refreshable() { viewModel.getTorrent() }
    }
}

struct ChangeLimitsView: View {
    @Environment(\.dismiss) var dismiss
    let torrentHash: String

    @State var dlLimit: String
    @State var upLimit: String
    @State var ratioLimit: String
    @State var seedingTimeLimit: String

    init(torrentHash: String, dlLimit: Int64, upLimit: Int64, ratioLimit: Float, seedingTimeLimit: Int) {
        self.torrentHash = torrentHash
        _dlLimit = State(initialValue: dlLimit > 0 ? String(dlLimit / 1024) : "")
        _upLimit = State(initialValue: upLimit > 0 ? String(upLimit / 1024) : "")
        _ratioLimit = State(initialValue: ratioLimit >= 0 ? String(format: "%.2f", ratioLimit) : "")
        _seedingTimeLimit = State(initialValue: seedingTimeLimit >= 0 ? String(seedingTimeLimit) : "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Speed Limits"), footer: Text("Leave empty or 0 for unlimited.")) {
                    HStack {
                        Text("Download (KB/s)")
                        Spacer()
                        TextField("Unlimited", text: $dlLimit)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    HStack {
                        Text("Upload (KB/s)")
                        Spacer()
                        TextField("Unlimited", text: $upLimit)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }

                Section(header: Text("Share Limits"), footer: Text("-1 for global setting, -2 for unlimited.")) {
                    HStack {
                        Text("Max Ratio")
                        Spacer()
                        TextField("Global", text: $ratioLimit)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    HStack {
                        Text("Max Seeding Time (min)")
                        Spacer()
                        TextField("Global", text: $seedingTimeLimit)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
            }
            .navigationTitle("Edit Limits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveLimits() }
                }
            }
        }
    }

    private func saveLimits() {
        let dlBytes = (Int(dlLimit) ?? 0) * 1024
        let upBytes = (Int(upLimit) ?? 0) * 1024
        qBittorrent.setDownloadLimit(hashes: [torrentHash], limit: dlBytes)
        qBittorrent.setUploadLimit(hashes: [torrentHash], limit: upBytes)

        let ratio = Float(ratioLimit) ?? -1
        let seedTime = Int(seedingTimeLimit) ?? -1
        qBittorrent.setShareLimits(hashes: [torrentHash], ratioLimit: ratio, seedingTimeLimit: seedTime)

        dismiss()
    }
}
