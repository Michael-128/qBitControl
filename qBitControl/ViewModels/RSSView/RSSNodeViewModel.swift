import SwiftUI

class RSSNodeViewModel: ObservableObject {
    static public let shared = RSSNodeViewModel()

    @Published public var rssRootNode: RSSNode = .init()
    @Published public var toastMessage: String?
    @Published public var showToast: Bool = false
    private var timer: Timer?

    init() {
        self.getRssRootNode()
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

    func pollUntilLoaded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.getRssRootNode()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let feeds = self.rssRootNode.getAllFeeds()
                let hasError = feeds.contains { $0.hasError == true }
                if hasError {
                    self.toastMessage = String(localized: "Refresh failed")
                } else {
                    self.toastMessage = String(localized: "Refresh completed")
                }
                withAnimation { self.showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { self.showToast = false }
                }
            }
        }
    }
}

