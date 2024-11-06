import Foundation

final class RSSNode: Decodable, Identifiable {
    let id = UUID()
    var title = "RSS"
    var nodes: [RSSNode] = []
    var feeds: [RSSFeed] = []

    required init(from decoder: any Decoder) throws {
        let decoder = try decoder.singleValueContainer()

        if let feedsOrNodes = try? decoder.decode([String: RSSFeedOrNode].self) {
            for (key, value) in feedsOrNodes {
                switch value {
                case .feed(let feed):
                    feeds.append(feed)
                case .node(let node):
                    node.title = key
                    nodes.append(node)
                case .empty:
                    continue
                }
            }
        }
        
        nodes.sort(by: { node1, node2 in node1.title < node2.title })
        feeds.sort(by: { feed1, feed2 in feed1.title < feed2.title })
    }
    
    enum RSSFeedOrNode: Decodable {
        case feed(RSSFeed)
        case node(RSSNode)
        case empty

        init(from decoder: any Decoder) throws {
            let decoder = try decoder.singleValueContainer()

            if let feed = try? decoder.decode(RSSFeed.self) {
                self = .feed(feed)
                return
            }

            if let node = try? decoder.decode(RSSNode.self) {
                self = .node(node)
                return
            }

            self = .empty
            return
        }
    }
}
