import SwiftUI

class TrackersViewModel: ObservableObject {
    private var torrentHash: String
    @Published public var trackers: [Tracker] = []
    
    @Published public var isEditTrackerAlert: Bool = false
    @Published public var isAddTrackerAlert: Bool = false
    
    @Published public var origURL = ""
    @Published public var newURL = ""
    
    @Published private var timer: Timer?
    
    init(torrentHash: String) {
        self.torrentHash = torrentHash
        self.getTrackers()
    }
    
    func showEditTrackerPopover(tracker: Tracker) {
        isEditTrackerAlert = true
        origURL = tracker.url
        newURL = tracker.url
    }
    
    func editTracker() {
        qBittorrent.editTrackerURL(hash: torrentHash, origUrl: origURL, newURL: newURL)
    }
    
    func showAddTrackerPopover() {
        isAddTrackerAlert = true
        origURL = ""
        newURL = ""
    }
    
    func addTracker() {
        qBittorrent.addTrackerURL(hash: torrentHash, urls: newURL)
    }
    
    func removeTracker(tracker: Tracker) {
        qBittorrent.removeTracker(hash: torrentHash, url: tracker.url)
    }
    
    func getTrackers() {
        qBittorrent.getTrackers(hash: torrentHash) {
            trackers in
            DispatchQueue.main.async {
                self.trackers = trackers
            }
        }
    }
    
    func setRefreshTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            self.getTrackers()
        }
    }
    
    func removeRefreshTimer() {
        timer?.invalidate()
    }
}
