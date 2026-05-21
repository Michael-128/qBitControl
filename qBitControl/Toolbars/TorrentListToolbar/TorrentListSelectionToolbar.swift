//

import SwiftUI

struct TorrentListSelectionToolbar: ToolbarContent {
    @Binding public var torrents: [Torrent]

    @Binding public var isSelectionMode: Bool

    @Binding public var selectedTorrents: Set<Torrent>

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if(selectedTorrents.count == torrents.count) {
                Button {
                    selectedTorrents.removeAll()
                } label: {
                    Text("Deselect All")
                }
            } else {
                Button {
                    torrents.forEach {
                        torrent in
                        selectedTorrents.insert(torrent)
                    }
                } label: {
                    Text("Select All")
                }
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isSelectionMode = false
                selectedTorrents.removeAll()
            } label: {
                Text("Done")
                    .fontWeight(.bold)
            }
        }
    }
}

struct TorrentSelectionBottomBar: View {
    @Binding var selectedTorrents: Set<Torrent>
    @Binding var isSelectionMode: Bool
    @State private var isAlertDeleteSelected = false

    private var selectedHashes: [String] {
        selectedTorrents.compactMap { $0.hash }
    }

    var body: some View {
        HStack {
            Button {
                qBittorrent.resumeTorrents(hashes: selectedHashes)
                isSelectionMode = false
                selectedTorrents.removeAll()
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "play.fill")
                    Text("Resume").font(.caption2)
                }
            }

            Spacer()

            Button {
                qBittorrent.pauseTorrents(hashes: selectedHashes)
                isSelectionMode = false
                selectedTorrents.removeAll()
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "pause.fill")
                    Text("Pause").font(.caption2)
                }
            }

            Spacer()

            Button {
                qBittorrent.recheckTorrents(hashes: selectedHashes)
                isSelectionMode = false
                selectedTorrents.removeAll()
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "arrow.clockwise")
                    Text("Recheck").font(.caption2)
                }
            }

            Spacer()

            Button {
                qBittorrent.reannounceTorrents(hashes: selectedHashes)
                isSelectionMode = false
                selectedTorrents.removeAll()
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("Announce").font(.caption2)
                }
            }

            Spacer()

            Button {
                isAlertDeleteSelected = true
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "trash.fill")
                    Text("Delete").font(.caption2)
                }.foregroundStyle(.red)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .modifier(GlassBackgroundModifier())
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .alert("Confirm Deletion", isPresented: $isAlertDeleteSelected) {
            Button("Delete Selected Tasks", role: .destructive) {
                qBittorrent.deleteTorrents(hashes: selectedHashes)
                isSelectionMode = false
                selectedTorrents.removeAll()
            }
            Button("Delete Selected Tasks with Files", role: .destructive) {
                qBittorrent.deleteTorrents(hashes: selectedHashes, deleteFiles: true)
                isSelectionMode = false
                selectedTorrents.removeAll()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

private struct GlassBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: Capsule())
        } else {
            content.background(.regularMaterial, in: Capsule())
        }
    }
}
