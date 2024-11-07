import Foundation

final class RSSNode: Decodable, Identifiable {
    let id = UUID()
    var title = "RSS"
    var nodes: [RSSNode] = []
    var feeds: [RSSFeed] = []
    
    weak var parent: RSSNode?

    func getPath() -> String {
        if let parent = self.parent {
            if parent.getPath().isEmpty {
                return title
            }
            return "\(parent.getPath())\\\(title)"
        }
        if title == "RSS" { return "" }
        return title
    }
    
    func getNode(path: [String]) -> RSSNode? {
        if path.count == 1 && path.first! == self.title { return self }
        
        var newPath = path
        newPath.removeFirst()
        
        for node in nodes {
            if newPath.first! == node.title {
                return node.getNode(path: newPath)
            }
        }
        
        return nil
    }
    
    init() { }
    
    required init(from decoder: any Decoder) throws {
        let decoder = try decoder.singleValueContainer()

        if let feedsOrNodes = try? decoder.decode([String: RSSFeedOrNode].self) {
            for (key, value) in feedsOrNodes {
                switch value {
                case .feed(let feed):
                    feeds.append(feed)
                case .node(let node):
                    node.title = key
                    node.parent = self
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
