//
//  TrackersViewModel.swift
//  qBitControl
//

import SwiftUI

@MainActor
class TrackersViewModel: ObservableObject {
    private var torrentHash: String
    private let client: TorrentClientProtocol
    private var isFetchingTrackers = false
    private var needsTrackerRefresh = false
    
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
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "edit_tracker_failed", errorDescription: error.localizedDescription))
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
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "add_tracker_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func removeTracker(tracker: Tracker) {
        Task {
            do {
                try await client.removeTracker(hash: torrentHash, url: tracker.url)
                getTrackers()
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "remove_tracker_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func getTrackers() {
        guard !isFetchingTrackers else {
            needsTrackerRefresh = true
            return
        }
        isFetchingTrackers = true

        Task {
            defer {
                isFetchingTrackers = false
                if needsTrackerRefresh {
                    needsTrackerRefresh = false
                    getTrackers()
                }
            }

            do {
                let trackersList = try await client.getTrackers(hash: torrentHash)
                self.trackers = trackersList
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "fetch_trackers_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func setRefreshTimer() {
        removeRefreshTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, !self.isFetchingTrackers else { return }
                self.getTrackers()
            }
        }
    }
    
    func removeRefreshTimer() {
        timer?.invalidate()
    }
}
