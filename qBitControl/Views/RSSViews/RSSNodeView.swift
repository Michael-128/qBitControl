import SwiftUI

struct RSSNodeView: View {
    @State public var rssNode: RSSNode
    
    var body: some View {
        List {
            Section(header: sectionHeader()) {
                ForEach(rssNode.nodes, id: \.id) { node in
                    NavigationLink {
                        RSSNodeView(rssNode: node)
                    } label: {
                        Label(node.title, systemImage: "folder.fill")
                    }.disabled(node.nodes.isEmpty && node.feeds.isEmpty)
                }
                
                ForEach(rssNode.feeds, id: \.id) { feed in
                    NavigationLink {
                        RSSFeedView(rssFeed: feed)
                    } label: {
                        Label(feed.title, systemImage: "dot.radiowaves.up.forward")
                    }
                }
            }
        }.navigationTitle(rssNode.title)
    }
    
    func sectionHeader() -> Text {
        Text(
            "\(!rssNode.nodes.isEmpty ? "\(rssNode.nodes.count) Folders" : "")" +
            "\(!rssNode.feeds.isEmpty ? " • \(rssNode.feeds.count) Feeds" : "")"
        )
    }
}
