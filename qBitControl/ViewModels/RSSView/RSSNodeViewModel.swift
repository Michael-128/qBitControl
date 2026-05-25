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
        print("[RSS] pollUntilLoaded started, will fetch in 5s")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            print("[RSS] Fetching RSS data after refresh...")
            self.getRssRootNode()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let feeds = self.rssRootNode.getAllFeeds()
                print("[RSS] Poll result: \(feeds.count) feeds")
                for feed in feeds {
                    print("[RSS]   '\(feed.title)': hasError=\(feed.hasError ?? false), isLoading=\(feed.isLoading ?? false)")
                }
                let hasError = feeds.contains { $0.hasError == true }
                if hasError {
                    self.toastMessage = String(localized: "Refresh failed")
                } else {
                    self.toastMessage = String(localized: "Refresh completed")
                }
                withAnimation { self.showToast = true }
                print("[RSS] Toast message set to: \(self.toastMessage ?? "nil")")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { self.showToast = false }
                }
            }
        }
    }
}

