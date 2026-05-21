//
//  LoggedInView.swift
//  qBitControl
//

import SwiftUI

    
struct TorrentListView: View {
    @StateObject var torrentListHelperViewModel: TorrentListHelperViewModel = .init()
    @State private var isFilterView = false
    @State private var torrentUrls: [URL] = []
    @State private var isAltSpeedEnabled = false
    
    func openUrl(url: URL) {
        if url.absoluteString.contains("file") || url.absoluteString.contains("magnet") {
            torrentListHelperViewModel.isTorrentAddView = true
            torrentUrls.append(url)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Manage")) {
                    Button { torrentListHelperViewModel.isTorrentAddView.toggle() }
                    label: { Label("Add Task", systemImage: "plus.circle") }
                    Button {
                        qBittorrent.toggleSpeedLimitsMode()
                        isAltSpeedEnabled.toggle()
                    } label: {
                        Label(isAltSpeedEnabled ? "Disable Alt Speed" : "Enable Alt Speed",
                              systemImage: isAltSpeedEnabled ? "tortoise.fill" : "tortoise")
                    }
                }

                TorrentListHelperView(viewModel: torrentListHelperViewModel)
            }
            .navigationTitle(torrentListHelperViewModel.category == "All" ? NSLocalizedString("Tasks", comment: "Tasks") : torrentListHelperViewModel.category.capitalized)
            .searchable(text: $torrentListHelperViewModel.searchQuery)
            .toolbar() {
                TorrentListToolbar(torrents: $torrentListHelperViewModel.torrents, category: $torrentListHelperViewModel.category, isSelectionMode: $torrentListHelperViewModel.isSelectionMode, isFilterView: $isFilterView, selectedTorrents: $torrentListHelperViewModel.selectedTorrents)
            }
            .safeAreaInset(edge: .bottom) {
                if torrentListHelperViewModel.isSelectionMode && !torrentListHelperViewModel.selectedTorrents.isEmpty {
                    TorrentSelectionBottomBar(
                        selectedTorrents: $torrentListHelperViewModel.selectedTorrents,
                        isSelectionMode: $torrentListHelperViewModel.isSelectionMode
                    )
                }
            }
            .sheet(isPresented: $isFilterView, content: {
                FiltersMenuView(sort: $torrentListHelperViewModel.sort, reverse: $torrentListHelperViewModel.reverse, filter: $torrentListHelperViewModel.filter, category: $torrentListHelperViewModel.category, tag: $torrentListHelperViewModel.tag)
            })
            .sheet(isPresented: $torrentListHelperViewModel.isTorrentAddView, content: {
                TorrentAddView(torrentUrls: $torrentUrls)
            })
            .onOpenURL(perform: openUrl)
            .onAppear {
                qBittorrent.getSpeedLimitsMode { enabled in
                    isAltSpeedEnabled = enabled
                }
            }
        }
    }
}
    
