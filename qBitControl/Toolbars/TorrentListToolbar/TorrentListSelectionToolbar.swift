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
    @State private var showCategorySheet = false
    @State private var showMoveAlert = false
    @State private var movePath = ""

    private var selectedHashes: [String] {
        selectedTorrents.compactMap { $0.hash }
    }

    var body: some View {
        VStack(spacing: 8) {
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
                    showCategorySheet = true
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "folder")
                        Text("Category").font(.caption2)
                    }
                }

                Spacer()

                Button {
                    showMoveAlert = true
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "arrow.right.doc.on.clipboard")
                        Text("Move").font(.caption2)
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
        .alert("Move Torrents", isPresented: $showMoveAlert) {
            TextField("Save Path", text: $movePath)
            Button("Move") {
                guard !movePath.isEmpty else { return }
                qBittorrent.setLocationBatch(hashes: selectedHashes, location: movePath)
                isSelectionMode = false
                selectedTorrents.removeAll()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showCategorySheet) {
            NavigationView {
                ChangeCategoryView(category: "", onCategorySelected: { category in
                    qBittorrent.setCategoryBatch(hashes: selectedHashes, category: category.name)
                    showCategorySheet = false
                    isSelectionMode = false
                    selectedTorrents.removeAll()
                })
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showCategorySheet = false }
                    }
                }
            }
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
