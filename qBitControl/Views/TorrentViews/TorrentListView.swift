//
//  LoggedInView.swift
//  qBitControl
//

import SwiftUI

    
struct TorrentListView: View {
    @StateObject var torrentListHelperViewModel: TorrentListHelperViewModel = .init()
    @State private var torrentUrls: [URL] = []
    
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
                    .searchable(text: $torrentListHelperViewModel.searchQuery)
                }
    
                TorrentListHelperView(viewModel: torrentListHelperViewModel)
                    .navigationTitle(torrentListHelperViewModel.category == "All" ? NSLocalizedString("Tasks", comment: "Tasks") : torrentListHelperViewModel.category.capitalized)
            }
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(.visible, for: .bottomBar)
            .toolbar() {
                TorrentListToolbar(viewModel: torrentListHelperViewModel)
            }.alert("Confirm Deletion", isPresented: $torrentListHelperViewModel.isDeleteSelectedAlert, actions: {
                deleteAlert()
            })
            .sheet(isPresented: $torrentListHelperViewModel.isFilterView, content: {
                FiltersMenuView(sort: $torrentListHelperViewModel.sort, reverse: $torrentListHelperViewModel.reverse, filter: $torrentListHelperViewModel.filter, category: $torrentListHelperViewModel.category, tag: $torrentListHelperViewModel.tag)
            })
            .sheet(isPresented: $torrentListHelperViewModel.isTorrentAddView, content: {
                TorrentAddView(torrentUrls: $torrentUrls)
            })
            .onOpenURL(perform: openUrl)
        }
    }
    
    @ViewBuilder
    func deleteAlert() -> some View {
        Button("Delete Selected Tasks", role: .destructive) {
            torrentListHelperViewModel.deleteSelectedTorrents(isDeleteFiles: false)
        }
        Button("Delete Selected Tasks with Files", role: .destructive) {
            torrentListHelperViewModel.deleteSelectedTorrents(isDeleteFiles: true)
        }
    }
}
    

