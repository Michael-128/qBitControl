import SwiftUI

class RSSViewModel: ObservableObject {
    @Published public var RSSNode: RSSNode?
    
    init() {
        self.getRSSFeed()
    }
    
    func getRSSFeed() {
        qBittorrent.getRSSFeeds(withDate: true, completionHandler: { RSSNode in
            DispatchQueue.main.async {
                self.RSSNode = RSSNode
            }
        })
    }
}
