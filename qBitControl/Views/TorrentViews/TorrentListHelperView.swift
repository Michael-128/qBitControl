//

import SwiftUI

struct TorrentListHelperView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhaseEnv
    
    @ObservedObject var viewModel: TorrentListHelperViewModel
    var formatter: TorrentFormatting = TorrentFormatter()
    
    var body: some View {
        Section(header: torrentListHeader()) {
            ForEach(viewModel.filteredTorrents, id: \.hash) { torrent in torrentRowView(torrent: torrent) }
        }
        .onAppear { viewModel.getInitialTorrents() }
        .onDisappear { viewModel.stopTimer() }
        .onChange(of: scenePhaseEnv) { phase in viewModel.scenePhase = phase }
        .alert("Delete Task", isPresented: $viewModel.isDeleteAlert) { deleteAlertView() }
    }
    
    // Helper Views
    
    // Torrent List
    
    func torrentListHeader() -> some View {
        HStack(spacing: 3) {
            Text("\(viewModel.filteredTorrents.count) " + NSLocalizedString("Tasks", comment: ""))
            Text("•")
            Image(systemName: "arrow.down")
            Text("\( formatter.getFormatedSize(size: viewModel.filteredTorrents.compactMap({$0.dlspeed}).reduce(0, +)) )/s")
            Text("•")
            Image(systemName: "arrow.up")
            Text("\( formatter.getFormatedSize(size: viewModel.filteredTorrents.compactMap({$0.upspeed}).reduce(0, +)) )/s")
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
            TorrentRowView(name: torrent.name, progress: torrent.progress, state: torrent.state, dlspeed: torrent.dlspeed, upspeed: torrent.upspeed, ratio: torrent.ratio, size: torrent.size)
            .contextMenu() { torrentRowContextMenu(torrent: torrent) }
        }
    }
    
    func torrentSelectionModeRowView(torrent: Torrent) -> some View {
        let isTorrentSelected = viewModel.selectedTorrents.contains(torrent)
        
        return HStack {
            Image(systemName: isTorrentSelected ? "checkmark.circle.fill" : "circle")
                .scaleEffect(1.25)
                .foregroundStyle(isTorrentSelected ? Color(.blue) : Color(.gray))
            
            TorrentRowView(
                name: torrent.name,
                progress: torrent.progress,
                state: torrent.state,
                dlspeed: torrent.dlspeed,
                upspeed: torrent.upspeed,
                ratio: torrent.ratio,
                size: torrent.size
            )
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                if isTorrentSelected {
                    viewModel.selectedTorrents.remove(torrent)
                } else {
                    viewModel.selectedTorrents.insert(torrent)
                }
            }
        }
    }
    
    
    // Context Menu
    
    func torrentRowQueueControls(torrent: Torrent) -> some View {
        var isQueueingEnabled = false
        
        if let preferences = ServersHelper.shared.preferences { isQueueingEnabled = preferences.queueing_enabled ?? false }
        
        if(isQueueingEnabled) {
            return AnyView(Section(header: Text("Queue")) {
                Button { viewModel.increasePriority(hashes: [torrent.hash]) }
                label: { MenuControlsLabelView(text: "Move Up", icon: "arrow.up") }
                
                Button { viewModel.decreasePriority(hashes: [torrent.hash]) }
                label: { MenuControlsLabelView(text: "Move Down", icon: "arrow.down") }
            })
        }
        
        return AnyView(EmptyView())
     }
     
     func torrentRowManageControls(torrent: Torrent) -> some View {
        let isTorrentPaused = formatter.getState(state: torrent.state).contains("Paused")
        
        return Section(header: Text("Manage")) {
            Button { if isTorrentPaused { viewModel.resumeTorrents(hashes: [torrent.hash]) } else { viewModel.pauseTorrents(hashes: [torrent.hash]) } }
            label: { MenuControlsLabelView(text: isTorrentPaused ? "Resume" : "Pause", icon: isTorrentPaused ? "play" : "pause") }
            
            Button { viewModel.recheckTorrents(hashes: [torrent.hash]) }
            label: { MenuControlsLabelView(text: "Recheck", icon: "magnifyingglass") }
            
            Button { viewModel.reannounceTorrents(hashes: [torrent.hash]) }
            label: { MenuControlsLabelView(text: "Reannounce", icon: "circle.dashed") }
            
            Button(role: .destructive) { viewModel.deleteTorrent(torrent: torrent) }
            label: { MenuControlsLabelView(text: "Delete", icon: "trash") }
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
                viewModel.deleteTorrents(hashes: [viewModel.hash], deleteFiles: false)
                viewModel.hash = ""
            }
            Button("Delete Task with Files", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                viewModel.deleteTorrents(hashes: [viewModel.hash], deleteFiles: true)
                viewModel.hash = ""
            }
            Button("Cancel", role: .cancel) {}
        }
     }
}
