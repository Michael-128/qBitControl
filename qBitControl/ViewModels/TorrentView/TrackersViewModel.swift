//
//  TrackersViewModel.swift
//  qBitControl
//

import SwiftUI

@MainActor
class TrackersViewModel: ObservableObject {
    private var torrentHash: String
    private let client: TorrentClientProtocol
    
    @Published public var trackers: [Tracker] = []
    
    @Published public var isEditTrackerAlert: Bool = false
    @Published public var isAddTrackerAlert: Bool = false
    
    @Published public var origURL = ""
    @Published public var newURL = ""
    
    @Published private var timer: Timer?
    
    init(torrentHash: String, client: TorrentClientProtocol) {
        self.torrentHash = torrentHash
        self.client = client
        self.getTrackers()
    }
    
    func showEditTrackerPopover(tracker: Tracker) {
        isEditTrackerAlert = true
        origURL = tracker.url
        newURL = tracker.url
    }
    
    func editTracker() {
        Task {
            do {
                try await client.editTrackerURL(hash: torrentHash, origUrl: origURL, newURL: newURL)
                getTrackers()
            } catch {
                print("Failed to edit tracker: \(error)")
            }
        }
    }
    
    func showAddTrackerPopover() {
        isAddTrackerAlert = true
        origURL = ""
        newURL = ""
    }
    
    func addTracker() {
        Task {
            do {
                try await client.addTrackerURL(hash: torrentHash, urls: newURL)
                getTrackers()
            } catch {
                print("Failed to add tracker: \(error)")
            }
        }
    }
    
    func removeTracker(tracker: Tracker) {
        Task {
            do {
                try await client.removeTracker(hash: torrentHash, url: tracker.url)
                getTrackers()
            } catch {
                print("Failed to remove tracker: \(error)")
            }
        }
    }
    
    func getTrackers() {
        Task {
            do {
                let trackersList = try await client.getTrackers(hash: torrentHash)
                self.trackers = trackersList
            } catch {
                print("Failed to fetch trackers: \(error)")
            }
        }
    }
    
    func setRefreshTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.getTrackers()
            }
        }
    }
    
    func removeRefreshTimer() {
        timer?.invalidate()
    }
}
