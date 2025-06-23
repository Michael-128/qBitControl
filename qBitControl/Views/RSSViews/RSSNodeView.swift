import SwiftUI

struct RSSNodeView: View {
    @State public var path: [String]
    @ObservedObject var viewModel = RSSNodeViewModel.shared
    var rssNode: RSSNode { viewModel.rssRootNode.getNode(path: path)! }
    
    @State private var isAddFeedAlert: Bool = false
    @State private var isAddFolderAlert: Bool = false
    @State private var isRenameAlert: Bool = false
    
    @State private var newFeedURL = ""
    @State private var newFolderName = ""
    @State private var newRenameName = ""
    @State private var oldRenamePath = ""
    
    var isRootView: Bool {
        self.path.count == 1
    }
    
    func getItemPath(item: String) -> String {
        var path = self.path + [item]
        path.removeFirst()
        return path.joined(separator: "\\")
    }
    
    var body: some View {
        List {
            if isRootView {
                Section(header: Text("Actions")) {
                    NavigationLink {
                        SearchView()
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    NavigationLink {
                        RSSRulesView()
                    } label: {
                        Label("Download Rules", systemImage: "pencil.and.ruler")
                    }
                }
            }
            
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
            .alert("New Name", isPresented: $isRenameAlert, actions: { renameAlert() })
    }
    
    func sectionHeader() -> Text {
        var header: [String] = []
        if(!rssNode.nodes.isEmpty) { header.append("\(rssNode.nodes.count)" + " " + String(localized: "Folders")) }
        if(!rssNode.feeds.isEmpty) { header.append("\(rssNode.feeds.count)" + " " + String(localized: "Feeds")) }
        
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
    
    func renameAlert() -> some View {
        VStack {
            TextField("Name", text: $newRenameName)
            Button("Save") {
                let newRenamePath = self.getItemPath(item: newRenameName)
                qBittorrent.moveRSSItem(itemPath: oldRenamePath, destPath: newRenamePath)
                
                oldRenamePath = ""
                newRenameName = ""
                refresh()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    func itemContextMenu(itemTitle: String, isFolder: Bool = false) -> some View {
        VStack {
            if !isFolder {
                Button {
                    qBittorrent.addRSSRefreshItem(path: self.getItemPath(item: itemTitle))
                } label: { Label("Refresh", systemImage: "arrow.clockwise") }
            }
            Button {
                self.newRenameName = itemTitle
                self.oldRenamePath = self.getItemPath(item: itemTitle)
                self.isRenameAlert.toggle()
            } label: { Label("Rename", systemImage: "pencil") }
            Button {
                UIPasteboard.general.string = self.feed(for: itemTitle)?.url
            } label: {
                Label("Copy URL", systemImage: "arrow.up.page.on.clipboard")
            }
            Button(role: .destructive) {
                qBittorrent.addRSSRemoveItem(path: self.getItemPath(item: itemTitle))
            } label: { Label("Remove", systemImage: "trash") }
        }
    }
    
    func feed(for title: String) -> RSSFeed? {
        return rssNode.feeds.first(where: { $0.title == title })
    }
    
    func refresh() { viewModel.getRssRootNode() }
}

