//
//  LoggedInView.swift
//  qBitControl
//

import SwiftUI

    
struct TorrentListView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var isLoggedIn: Bool
    @StateObject var torrentListModel: TorrentListModel = TorrentListModel()
 
    @State private var isFilterView = false
    
    @State private var torrentUrls: [URL] = []
    
    func openUrl(url: URL) {
        if url.absoluteString.contains("file") || url.absoluteString.contains("magnet") {
            torrentListModel.isTorrentAddView = true
            torrentUrls.append(url)
        }
    }
    
    func listElementLabel(text: LocalizedStringKey, icon: String) -> some View {
        HStack { Image(systemName: icon); Text(text) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Manage")) {
                    Button { torrentListModel.isTorrentAddView.toggle() }
                    label: { listElementLabel(text: "Add Task", icon: "plus.circle") }
                    .searchable(text: $torrentListModel.searchQuery)
                }
    
                TorrentList(viewModel: torrentListModel)
                    .navigationTitle(torrentListModel.category == "None" ? NSLocalizedString("Tasks", comment: "Tasks") : torrentListModel.category.capitalized)
            }
            .toolbar() {
                TorrentListToolbar(torrents: $torrentListModel.torrents, category: $torrentListModel.category, isSelectionMode: $torrentListModel.isSelectionMode, isLoggedIn: $isLoggedIn, isFilterView: $isFilterView, selectedTorrents: $torrentListModel.selectedTorrents)
            }
            .sheet(isPresented: $isFilterView, content: {
                TorrentFilterView(sort: $torrentListModel.sort, reverse: $torrentListModel.reverse, filter: $torrentListModel.filter, category: $torrentListModel.category, tag: $torrentListModel.tag)
            })
            .sheet(isPresented: $torrentListModel.isTorrentAddView, content: {
                TorrentAddView(torrentUrls: $torrentUrls)
            })
            .onOpenURL(perform: openUrl)
        }
    }
}
    

