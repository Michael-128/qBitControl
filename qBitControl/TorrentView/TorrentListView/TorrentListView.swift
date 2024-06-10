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

    @State private var openedMagnetURL: String?
    @State private var openedFileURL: [URL] = []
    
    func openUrl(url: URL) {
        if url.absoluteString.contains("file") {
            torrentListModel.isTorrentAddView = true
            openedFileURL.append(url)
        }
        
        if url.absoluteString.contains("magnet") {
            torrentListModel.isTorrentAddView = true
            openedMagnetURL = url.absoluteString
        }
    }
    
    func listElementLabel(text: String, icon: String) -> some View {
        HStack { Image(systemName: text); Text(icon) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Manage")) {
                    Button { torrentListModel.isTorrentAddView.toggle() }
                    label: { listElementLabel(text: "plus.circle", icon: "Add Task") }
                    .searchable(text: $torrentListModel.searchQuery)
                }
    
                TorrentList(viewModel: torrentListModel)
                .navigationTitle(torrentListModel.category == "None" ? "Tasks" : torrentListModel.category.capitalized)
            }.toolbar() {
                TorrentListToolbar(torrents: $torrentListModel.torrents, category: $torrentListModel.category, isSelectionMode: $torrentListModel.isSelectionMode, isLoggedIn: $isLoggedIn, isFilterView: $isFilterView, selectedTorrents: $torrentListModel.selectedTorrents)
            }
            .sheet(isPresented: $isFilterView, content: {
                TorrentFilterView(sort: $torrentListModel.sort, reverse: $torrentListModel.reverse, filter: $torrentListModel.filter, category: $torrentListModel.category, tag: $torrentListModel.tag)
            })
            .sheet(isPresented: $torrentListModel.isTorrentAddView, content: {
                TorrentAddView(isPresented: $torrentListModel.isTorrentAddView, openedMagnetURL: $openedMagnetURL, openedFileURL: $openedFileURL)
            }).onOpenURL(perform: { url in
                openUrl(url: url)
            })
        }
    }
}
    

