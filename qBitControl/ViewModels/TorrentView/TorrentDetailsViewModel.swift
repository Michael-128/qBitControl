//
//  TorrentDetailsViewModel.swift
//  qBitControl
//

import SwiftUI

@MainActor
class TorrentDetailsViewModel: ObservableObject {
    @Published public var torrent: Torrent
    
    @Published public var isDeleteAlert: Bool = false
    
    @Published public var isSequentialDownload: Bool = false
    @Published public var isFLPiecesFirst: Bool = false
    
    @Published public var state: State = .resumed
    
    public let formatter: TorrentFormatting
    private let client: TorrentClientProtocol
    
    private var tags: [String] { torrent.tags.split(separator: ", ").map { String($0) } }
    
    let haptics = UIImpactFeedbackGenerator(style: .medium)
    private var timer: Timer?
    
    init(torrent: Torrent, formatter: TorrentFormatting = TorrentFormatter(), client: TorrentClientProtocol) {
        self.torrent = torrent
        self.formatter = formatter
        self.client = client
        self.isSequentialDownload = torrent.seq_dl
        self.isFLPiecesFirst = torrent.f_l_piece_prio
        self.fetchState(state: torrent.state)
    }
    
    func setRefreshTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] timer in
            Task { @MainActor in
                self?.getTorrent()
            }
        }
    }
    
    func removeRefreshTimer() {
        timer?.invalidate()
    }
    
    func getTorrent() {
        Task {
            do {
                let list = try await client.fetchTorrents()
                if let matchingTorrent = list.first(where: { $0.hash == torrent.hash }) {
                    self.torrent = matchingTorrent
                    self.isSequentialDownload = matchingTorrent.seq_dl
                    self.isFLPiecesFirst = matchingTorrent.f_l_piece_prio
                    self.fetchState(state: matchingTorrent.state)
                }
            } catch {
                print("Failed to fetch torrent details: \(error)")
            }
        }
    }
    
    private func fetchState(state: String) {
        let state = formatter.getState(state: state)
        if(state == "Paused") { self.state = .paused }
        else if(torrent.state.contains("forced")) { self.state = .forceStart }
        else { self.state = .resumed }
    }
    
    func getCategory() -> String { torrent.category != "" ? torrent.category : "Uncategorized" }
    func getTags() -> [String] { tags }
    func getTag() -> String { tags.count > 1 ? "\(tags.count) Tags" : (tags.first ?? "Untagged") }
    func getAddedOn() -> String { formatter.getFormatedDate(date: torrent.added_on) }
    func getSize() -> String { "\(formatter.getFormatedSize(size: torrent.size))" }
    func getTotalSize() -> String { "\(formatter.getFormatedSize(size: torrent.total_size))" }
    func getAvailability() -> String { torrent.availability < 0 ? "-" : "\(String(format: "%.1f", torrent.availability*100))%" }
    func getState() -> String { "\(formatter.getState(state: torrent.state))" }
    func getProgress() -> String { "\(String(format: "%.2f", (torrent.progress*100)))%" }
    func getDownloadSpeed() -> String { "\(formatter.getFormatedSize(size: torrent.dlspeed))/s" }
    func getUploadSpeed() -> String { "\(formatter.getFormatedSize(size: torrent.upspeed))/s" }
    func getDownloaded() -> String { "\(formatter.getFormatedSize(size: torrent.downloaded))" }
    func getUploaded() -> String { "\(formatter.getFormatedSize(size: torrent.uploaded))" }
    func getRatio() -> String { "\(String(format:"%.2f", torrent.ratio))" }
    func getDownloadedSession() -> String { "\(formatter.getFormatedSize(size: torrent.downloaded_session))" }
    func getUploadedSession() -> String { "\(formatter.getFormatedSize(size: torrent.uploaded_session))" }
    func getMaxRatio() -> String { "\(torrent.max_ratio > -1 ? String(format:"%.2f", torrent.max_ratio) : NSLocalizedString("None", comment: "None"))" }
    func getDownloadLimit() -> String { "\(torrent.dl_limit > 0 ? formatter.getFormatedSize(size: torrent.dl_limit)+"/s" : NSLocalizedString("None", comment: "None"))" }
    func getUploadLimit() -> String { "\(torrent.up_limit > 0 ? formatter.getFormatedSize(size: torrent.up_limit)+"/s" : NSLocalizedString("None", comment: "None"))" }
    func getETA() -> String { torrent.progress < 1 ? formatter.getFormattedTime(time: torrent.eta) : "-" }
    
    func isPaused() -> Bool { state == .paused }
    func isForceStart() -> Bool { state == .forceStart }
    
    func toggleTorrentPause() {
        haptics.impactOccurred()
        Task {
            do {
                if self.isPaused() {
                    try await client.resumeTorrent(hash: torrent.hash)
                } else {
                    try await client.pauseTorrent(hash: torrent.hash)
                }
                getTorrent()
            } catch {
                print("Failed to toggle torrent pause: \(error)")
            }
        }
    }
    
    func toggleSequentialDownload() {
        Task {
            do {
                try await client.toggleSequentialDownload(hashes: [torrent.hash])
            } catch {
                print("Failed to toggle sequential download: \(error)")
            }
        }
    }
    
    func toggleFLPiecesFirst() {
        Task {
            do {
                try await client.toggleFLPiecesFirst(hashes: [torrent.hash])
            } catch {
                print("Failed to toggle first/last pieces first: \(error)")
            }
        }
    }
    
    func setForceStart(value: Bool) {
        Task {
            do {
                try await client.setForceStart(hashes: [torrent.hash], value: value)
            } catch {
                print("Failed to set force start: \(error)")
            }
        }
    }
    
    func recheckTorrent() {
        haptics.impactOccurred()
        Task {
            do {
                try await client.recheckTorrent(hash: torrent.hash)
            } catch {
                print("Failed to recheck torrent: \(error)")
            }
        }
    }
    
    func reannounceTorrent() {
        haptics.impactOccurred()
        Task {
            do {
                try await client.reannounceTorrent(hash: torrent.hash)
            } catch {
                print("Failed to reannounce torrent: \(error)")
            }
        }
    }
    
    func deleteTorrent() {
        haptics.impactOccurred()
        isDeleteAlert = true
    }
    
    func moveToTopPriority() {
        haptics.impactOccurred()
        Task {
            do {
                try await client.topPriorityTorrents(hashes: [torrent.hash])
            } catch {
                print("Failed to move to top priority: \(error)")
            }
        }
    }
    
    func moveToBottomPriority() {
        haptics.impactOccurred()
        Task {
            do {
                try await client.bottomPriorityTorrents(hashes: [torrent.hash])
            } catch {
                print("Failed to move to bottom priority: \(error)")
            }
        }
    }
    
    func increasePriority() {
        haptics.impactOccurred()
        Task {
            do {
                try await client.increasePriorityTorrents(hashes: [torrent.hash])
            } catch {
                print("Failed to increase priority: \(error)")
            }
        }
    }
    
    func decreasePriority() {
        haptics.impactOccurred()
        Task {
            do {
                try await client.decreasePriorityTorrents(hashes: [torrent.hash])
            } catch {
                print("Failed to decrease priority: \(error)")
            }
        }
    }
    
    func deleteTorrent(then dismiss: DismissAction) {
        Task {
            do {
                try await client.deleteTorrent(hash: torrent.hash, deleteFiles: false)
                dismiss()
            } catch {
                print("Failed to delete torrent: \(error)")
            }
        }
    }
    
    func deleteTorrentWithFiles(then dismiss: DismissAction) {
        Task {
            do {
                try await client.deleteTorrent(hash: torrent.hash, deleteFiles: true)
                dismiss()
            } catch {
                print("Failed to delete torrent with files: \(error)")
            }
        }
    }
    
    enum State {
        case resumed, paused, forceStart
    }
}
