import SwiftUI

class RSSViewModel: ObservableObject {
    @Published public var RSSNode: RSSNode = .init()
    @Published public var updateID: UUID = UUID()
    
    init() {
        self.getRSSFeed()
    }
    
    func getRSSFeed() {
        qBittorrent.getRSSFeeds(withDate: true, completionHandler: { RSSNode in
            DispatchQueue.main.async {
                self.RSSNode = RSSNode
                self.updateID = UUID()
            }
        })
    }
}
