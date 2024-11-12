import SwiftUI

struct RSSNodeView: View {
    @State public var path: [String]
    @ObservedObject var viewModel = RSSNodeViewModel.shared
    var rssNode: RSSNode { viewModel.rssRootNode.getNode(path: path)! }
    
    @State private var isAddFeedAlert: Bool = false
    @State private var isAddFolderAlert: Bool = false
    
    @State private var newFeedURL = ""
    @State private var newFolderName = ""

    var body: some View {
        List {
            Section(header: sectionHeader()) {
                ForEach(rssNode.nodes, id: \.id) { node in
                    NavigationLink {
                        RSSNodeView(path: path + [node.title])
                    } label: {
                        Label(node.title, systemImage: "folder.fill").contextMenu(menuItems: { itemContextMenu(itemTitle: node.title, isFolder: true) })
                    }
                }
                
                ForEach(rssNode.feeds, id: \.id) { feed in
                    NavigationLink {
                        RSSFeedView(rssFeed: feed)
                    } label: {
                        Label(feed.title.isEmpty ? "Feed" : feed.title, systemImage: "dot.radiowaves.up.forward").contextMenu(menuItems: { itemContextMenu(itemTitle: feed.title) })
                    }
                }
            }
        }.navigationTitle(viewModel.rssRootNode.getNode(path: path)!.title)
            .refreshable { refresh() }
            .toolbar { toolbar() }
            .alert("Add Feed", isPresented: $isAddFeedAlert, actions: { addFeedAlert() })
            .alert("Add Folder", isPresented: $isAddFolderAlert, actions: { addFolderAlert() })
    }
    
    func sectionHeader() -> Text {
        var header: [String] = []
        if(!rssNode.nodes.isEmpty) { header.append("\(rssNode.nodes.count) Folders") }
        if(!rssNode.feeds.isEmpty) { header.append("\(rssNode.feeds.count) Feeds") }
        
        return Text(header.joined(separator: " • "))
    }
    
    func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button { isAddFeedAlert = true } label: { Label("Add Feed", systemImage: "dot.radiowaves.up.forward") }
                Button { isAddFolderAlert = true } label: { Label("Add Folder", systemImage: "folder.badge.plus") }
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    func addFeedAlert() -> some View {
        VStack {
            TextField("URL", text: $newFeedURL)
            Button("Add") {
                if self.newFeedURL.isEmpty { return }
                var path = self.path + [newFeedURL]
                path.removeFirst()
                qBittorrent.addRSSFeed(url: newFeedURL, path: path.joined(separator: "\\"))
                newFeedURL = ""
                refresh()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    func addFolderAlert() -> some View {
        VStack {
            TextField("Name", text: $newFolderName)
            Button("Add") {
                let path = rssNode.getPath()
                if path.isEmpty {
                    qBittorrent.addRSSFolder(path: newFolderName)
                } else {
                    qBittorrent.addRSSFolder(path: rssNode.getPath() + "\\" + newFolderName)
                }
                newFolderName = ""
                refresh()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    func itemContextMenu(itemTitle: String, isFolder: Bool = false) -> some View {
        VStack {
            if !isFolder {
                Button {
                    var path = self.path + [itemTitle]
                    path.removeFirst()
                    print(path.joined(separator: "\\"))
                    qBittorrent.addRSSRefreshItem(path: path.joined(separator: "\\"))
                } label: { Label("Refresh", systemImage: "arrow.clockwise") }
            }
            Button(role: .destructive) {
                var path = self.path + [itemTitle]
                path.removeFirst()
                qBittorrent.addRSSRemoveItem(path: path.joined(separator: "\\"))
            } label: { Label("Remove", systemImage: "trash") }
        }
    }
    
    func refresh() { viewModel.getRssRootNode() }
}

