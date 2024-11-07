import SwiftUI

class RSSNodeViewModel: ObservableObject {
    static public let shared = RSSNodeViewModel()
    
    @Published public var rssRootNode: RSSNode = .init()
    
    init() {
        self.getRssRootNode()
    }
    
    func getRssRootNode() {
        qBittorrent.getRSSFeeds(completionHandler: { RSSNode in
            DispatchQueue.main.async {
                self.rssRootNode = RSSNode
            }
        })
    }
}

