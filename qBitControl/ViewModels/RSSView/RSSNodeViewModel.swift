import SwiftUI

class RSSNodeViewModel: ObservableObject {
    static public let shared = RSSNodeViewModel()
    
    @Published public var rssRootNode: RSSNode = .init()
    private var timer: Timer?
    
    init() {
        self.getRssRootNode()
        self.startTimer()
    }
    
    deinit {
        self.stopTimer()
    }
    
    func startTimer() { timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in self.getRssRootNode() }) }
    func stopTimer() { timer?.invalidate() }
    
    func getRssRootNode() {
        qBittorrent.getRSSFeeds(completionHandler: { RSSNode in
            DispatchQueue.main.async {
                self.rssRootNode = RSSNode
            }
        })
    }
}

