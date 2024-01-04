//
//  LoggedInView.swift
//  qBitControl
//

import SwiftUI

    
struct TorrentListView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State public var torrents: [Torrent] = Array()
    
    @State private var searchQuery = ""
    @State private var sort = "name"
    @State private var reverse = false
    @State private var filter = "all"
    @State private var category: String = "None"
    @State private var tag: String = "None"
    
    @State private var totalDlSpeed = 0
    @State private var totalUpSpeed = 0
    
    @State private var isTorrentAddView = false
    @State private var isFilterView = false
    @State private var isDeleteAlert = false
    
    @Binding var isLoggedIn: Bool
    
    let defaults = UserDefaults.standard
    
    @State private var isSelectionMode: Bool = false
    @State private var selectedTorrents = Set<Torrent>()
    
    @State private var openedMagnetURL: String?
    @State private var openedFileURL: [URL] = []
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Manage")) {
                    Button {
                        isTorrentAddView.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Task")
                        }
                    }.searchable(text: $searchQuery)
                }
    
                TorrentList(torrents: $torrents, searchQuery: $searchQuery, sort: $sort, reverse: $reverse, filter: $filter, category: $category, tag: $tag, isTorrentAddView: $isTorrentAddView, isSelectionMode: $isSelectionMode, selectedTorrents: $selectedTorrents)
                
                .navigationTitle(category == "None" ? "Tasks" : category.capitalized)
            }.toolbar() {
                TorrentListToolbar(torrents: $torrents, category: $category, isSelectionMode: $isSelectionMode, isLoggedIn: $isLoggedIn, isFilterView: $isFilterView, selectedTorrents: $selectedTorrents)
            }
            .sheet(isPresented: $isFilterView, content: {
                TorrentFilterView(sort: $sort, reverse: $reverse, filter: $filter, category: $category, tag: $tag)
            })
            .sheet(isPresented: $isTorrentAddView, content: {
                TorrentAddView(isPresented: $isTorrentAddView, openedMagnetURL: $openedMagnetURL, openedFileURL: $openedFileURL)
            }).onOpenURL(perform: { url in
                if url.absoluteString.contains("file") {
                    isTorrentAddView = true
                    openedFileURL.append(url)
                    print(url)
                }
                
                if url.absoluteString.contains("magnet") {
                    isTorrentAddView = true
                    openedMagnetURL = url.absoluteString
                }
            })
        }
    }
}
    

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
