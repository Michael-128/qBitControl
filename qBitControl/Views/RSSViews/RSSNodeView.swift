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
                        Label(node.title, systemImage: "folder.fill")
                    }//.disabled(node.nodes.isEmpty && node.feeds.isEmpty)
                }
                
                ForEach(rssNode.feeds, id: \.id) { feed in
                    NavigationLink {
                        RSSFeedView(rssFeed: feed)
                    } label: {
                        Label(feed.title.isEmpty ? "Feed" : feed.title, systemImage: "dot.radiowaves.up.forward")
                    }
                }
            }
        }.navigationTitle(viewModel.rssRootNode.getNode(path: path)!.title)
            .refreshable { refresh() }
            .toolbar { toolbar() }
            .alert("Add Feed", isPresented: $isAddFeedAlert, actions: {
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
            }).alert("Add Folder", isPresented: $isAddFolderAlert, actions: {
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
            })
    }
    
    func sectionHeader() -> Text {
        Text(
            "\(!rssNode.nodes.isEmpty ? "\(rssNode.nodes.count) Folders" : "")" +
            "\(!rssNode.feeds.isEmpty ? " • \(rssNode.feeds.count) Feeds" : "")"
        )
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
    
    func refresh() { viewModel.getRssRootNode() }
}

