//

import SwiftUI

struct TorrentList: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhaseEnv
    
    @ObservedObject var viewModel: TorrentListModel
    
    var body: some View {
        Section(header: torrentListHeader()) {
            ForEach(viewModel.filteredTorrents, id: \.hash) { torrent in torrentRowView(torrent: torrent) }
        }
        .onAppear { viewModel.getInitialTorrents() }
        .onDisappear { viewModel.stopTimer() }
        .onChange(of: scenePhaseEnv) { phase in viewModel.scenePhase = phase }
        .confirmationDialog("Delete Task", isPresented: $viewModel.isDeleteAlert) { deleteAlertView() }
    }
    
    // Helper Views
    
    // Torrent List
    
    func torrentListHeader() -> some View {
        HStack(spacing: 3) {
            Text("\(viewModel.filteredTorrents.count) Tasks")
            Text("•")
            Image(systemName: "arrow.down")
            Text("\( qBittorrent.getFormatedSize(size: viewModel.filteredTorrents.compactMap({$0.dlspeed}).reduce(0, +)) )/s")
            Text("•")
            Image(systemName: "arrow.up")
            Text("\( qBittorrent.getFormatedSize(size: viewModel.filteredTorrents.compactMap({$0.upspeed}).reduce(0, +)) )/s")
        }
        .lineLimit(1)
    }
    
    
    // Torrent Rows
    
    func torrentRowView(torrent: Torrent) -> some View {
        if(viewModel.isSelectionMode) { return AnyView(torrentSelectionModeRowView(torrent: torrent)) }
        return AnyView(torrentStandardRowView(torrent: torrent))
    }
    
    func torrentStandardRowView(torrent: Torrent) -> some View {
        NavigationLink {
            TorrentDetailsView(torrent: torrent)
        } label: {
            TorrentRowView(name: torrent.name, progress: torrent.progress, state: torrent.state, dlspeed: torrent.dlspeed, upspeed: torrent.upspeed, ratio: torrent.ratio)
            .contextMenu() { torrentRowContextMenu(torrent: torrent) }
        }
    }
    
    func torrentSelectionModeRowView(torrent: Torrent) -> some View {
        let isTorrentSelected = viewModel.selectedTorrents.contains(torrent)
        
        return HStack {
            Image(systemName: isTorrentSelected ? "checkmark.circle.fill" : "circle").scaleEffect(1.25).foregroundStyle(isTorrentSelected ? Color(.blue) : Color(.gray))
            TorrentRowView(name: torrent.name, progress: torrent.progress, state: torrent.state, dlspeed: torrent.dlspeed, upspeed: torrent.upspeed, ratio: torrent.ratio)
        }.onTapGesture {
            if(isTorrentSelected) { viewModel.selectedTorrents.remove(torrent) } else { viewModel.selectedTorrents.insert(torrent) }
        }
    }
    
    
    // Context Menu
    
    func torrentRowQueueControls(torrent: Torrent) -> some View {
        var isQueueingEnabled = false
        
        if let preferences = qBittorrent.getSavedPreferences() { isQueueingEnabled = preferences.queueing_enabled ?? false }
        
        if(isQueueingEnabled) {
            return AnyView(Section(header: Text("Queue")) {
                Button { qBittorrent.increasePriorityTorrents(hashes: [torrent.hash]) }
                label: { MenuControlsLabel(text: "Move Up", icon: "arrow.up") }
                
                Button { qBittorrent.decreasePriorityTorrents(hashes: [torrent.hash]) }
                label: { MenuControlsLabel(text: "Move Down", icon: "arrow.down") }
            })
        }
        
        return AnyView(EmptyView())
    }
    
    func torrentRowManageControls(torrent: Torrent) -> some View {
        let isTorrentPaused = torrent.state.contains("paused")
        
        return Section(header: Text("Manage")) {
            Button { if isTorrentPaused { qBittorrent.resumeTorrent(hash: torrent.hash) } else { qBittorrent.pauseTorrent(hash: torrent.hash) } }
            label: { MenuControlsLabel(text: isTorrentPaused ? "Resume" : "Pause", icon: isTorrentPaused ? "play" : "pause") }
            
            Button { qBittorrent.recheckTorrent(hash: torrent.hash) }
            label: { MenuControlsLabel(text: "Recheck", icon: "magnifyingglass") }
            
            Button { qBittorrent.reannounceTorrent(hash: torrent.hash) }
            label: { MenuControlsLabel(text: "Reannounce", icon: "circle.dashed") }
            
            Button(role: .destructive) { viewModel.deleteTorrent(torrent: torrent) }
            label: { MenuControlsLabel(text: "Delete", icon: "trash") }
        }
    }
    
    func torrentRowContextMenu(torrent: Torrent) -> some View {
        VStack {
            torrentRowQueueControls(torrent: torrent)
            torrentRowManageControls(torrent: torrent)
        }
    }
    
    
    // Alerts
    
    func deleteAlertView() -> some View {
        Group {
            Button("Delete Torrent", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                qBittorrent.deleteTorrent(hash: viewModel.hash)
                viewModel.hash = ""
            }
            Button("Delete Task with Files", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                qBittorrent.deleteTorrent(hash: viewModel.hash, deleteFiles: true)
                viewModel.hash = ""
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
