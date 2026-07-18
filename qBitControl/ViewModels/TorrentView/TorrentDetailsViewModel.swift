//
//  TorrentDetailsViewModel.swift
//  qBitControl
//

import SwiftUI
import Combine

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
    private var cancellables = Set<AnyCancellable>()
    
    init(torrent: Torrent, formatter: TorrentFormatting = TorrentFormatter(), client: TorrentClientProtocol) {
        self.torrent = torrent
        self.formatter = formatter
        self.client = client
        self.isSequentialDownload = torrent.seq_dl
        self.isFLPiecesFirst = torrent.f_l_piece_prio
        self.fetchState(state: torrent.state)
        
        // Observe global cache updates reactively
        qBitData.shared.cacheManager.$torrents
            .compactMap { $0[torrent.hash] }
            .receive(on: RunLoop.main)
            .sink { [weak self] updatedTorrent in
                self?.torrent = updatedTorrent
                self?.isSequentialDownload = updatedTorrent.seq_dl
                self?.isFLPiecesFirst = updatedTorrent.f_l_piece_prio
                self?.fetchState(state: updatedTorrent.state)
            }
            .store(in: &cancellables)
    }
    
    func setRefreshTimer() {
        // No-op: Observing the cache manager removes the need for active details view polling
    }
    
    func removeRefreshTimer() {
        // No-op
    }
    
    func getTorrent() {
        if let matchingTorrent = qBitData.shared.cacheManager.torrents[torrent.hash] {
            self.torrent = matchingTorrent
            self.isSequentialDownload = matchingTorrent.seq_dl
            self.isFLPiecesFirst = matchingTorrent.f_l_piece_prio
            self.fetchState(state: matchingTorrent.state)
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
    func getRatioLimit() -> String {
        if torrent.ratio_limit == -2 {
            return NSLocalizedString("Global", comment: "")
        } else if torrent.ratio_limit == -1 {
            return NSLocalizedString("Unlimited", comment: "")
        } else if torrent.ratio_limit >= 0 {
            return String(format: "%.2f", torrent.ratio_limit)
        }
        return NSLocalizedString("None", comment: "")
    }
    func getDownloadLimit() -> String { "\(torrent.dl_limit > 0 ? formatter.getFormatedSize(size: torrent.dl_limit)+"/s" : NSLocalizedString("None", comment: "None"))" }
    func getUploadLimit() -> String { "\(torrent.up_limit > 0 ? formatter.getFormatedSize(size: torrent.up_limit)+"/s" : NSLocalizedString("None", comment: "None"))" }
    func getSeedingTimeLimit() -> String {
        if torrent.seeding_time_limit == -2 {
            return NSLocalizedString("Global", comment: "")
        } else if torrent.seeding_time_limit == -1 {
            return NSLocalizedString("Unlimited", comment: "")
        } else if torrent.seeding_time_limit >= 0 {
            return "\(torrent.seeding_time_limit) min"
        }
        return NSLocalizedString("None", comment: "")
    }
    func getInactiveSeedingTimeLimit() -> String {
        if torrent.inactive_seeding_time_limit == -2 {
            return NSLocalizedString("Global", comment: "")
        } else if torrent.inactive_seeding_time_limit == -1 {
            return NSLocalizedString("Unlimited", comment: "")
        } else if torrent.inactive_seeding_time_limit >= 0 {
            return "\(torrent.inactive_seeding_time_limit) min"
        }
        return NSLocalizedString("None", comment: "")
    }
    func getShareLimitAction() -> String {
        if let actionRaw = torrent.share_limit_action,
           let action = ShareLimitAction(rawValue: actionRaw) {
            return action.displayName
        }
        return NSLocalizedString("None", comment: "")
    }
    func getETA() -> String { torrent.progress < 1 ? formatter.getFormattedTime(time: torrent.eta) : "-" }
    
    func isPaused() -> Bool { state == .paused }
    func isForceStart() -> Bool { state == .forceStart }
    
    func toggleTorrentPause() {
        haptics.impactOccurred()
        let isCurrentlyPaused = self.isPaused()
        
        if isCurrentlyPaused {
            self.torrent.applyResume()
        } else {
            self.torrent.applyPause()
        }
        self.fetchState(state: torrent.state)
        
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: [torrent.hash]) { torrent in
            isCurrentlyPaused ? torrent.applyResume() : torrent.applyPause()
        }
        
        Task {
            do {
                if isCurrentlyPaused {
                    try await client.resumeTorrent(hash: torrent.hash)
                } else {
                    try await client.pauseTorrent(hash: torrent.hash)
                }
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "toggle_torrent_pause_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func toggleSequentialDownload() {
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: [torrent.hash]) { torrent in
            torrent.seq_dl = isSequentialDownload
        }
        Task {
            do {
                try await client.toggleSequentialDownload(hashes: [torrent.hash])
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "toggle_sequential_download_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func toggleFLPiecesFirst() {
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: [torrent.hash]) { torrent in
            torrent.f_l_piece_prio = isFLPiecesFirst
        }
        Task {
            do {
                try await client.toggleFLPiecesFirst(hashes: [torrent.hash])
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "toggle_first_last_pieces_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func setForceStart(value: Bool) {
        if value {
            self.torrent.applyForceStart()
        } else {
            self.torrent.applyForceStartStop()
        }
        self.fetchState(state: torrent.state)
        
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: [torrent.hash]) { torrent in
            value ? torrent.applyForceStart() : torrent.applyForceStartStop()
        }
        
        Task {
            do {
                try await client.setForceStart(hashes: [torrent.hash], value: value)
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "set_force_start_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func recheckTorrent() {
        haptics.impactOccurred()
        self.torrent.applyRecheck()
        self.fetchState(state: torrent.state)
        
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: [torrent.hash]) { torrent in
            torrent.applyRecheck()
        }
        
        Task {
            do {
                try await client.recheckTorrent(hash: torrent.hash)
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "recheck_torrent_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func reannounceTorrent() {
        haptics.impactOccurred()
        Task {
            do {
                try await client.reannounceTorrent(hash: torrent.hash)
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "reannounce_torrent_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func deleteTorrent() {
        haptics.impactOccurred()
        isDeleteAlert = true
    }
    
    func moveToTopPriority() {
        haptics.impactOccurred()
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: [torrent.hash]) { torrent in
            torrent.priority = 1
        }
        Task {
            do {
                try await client.topPriorityTorrents(hashes: [torrent.hash])
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "move_to_top_priority_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func moveToBottomPriority() {
        haptics.impactOccurred()
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: [torrent.hash]) { torrent in
            torrent.priority = 999
        }
        Task {
            do {
                try await client.bottomPriorityTorrents(hashes: [torrent.hash])
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "move_to_bottom_priority_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func increasePriority() {
        haptics.impactOccurred()
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: [torrent.hash]) { torrent in
            torrent.priority = max(1, torrent.priority - 1)
        }
        Task {
            do {
                try await client.increasePriorityTorrents(hashes: [torrent.hash])
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "increase_priority_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func decreasePriority() {
        haptics.impactOccurred()
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: [torrent.hash]) { torrent in
            torrent.priority = torrent.priority + 1
        }
        Task {
            do {
                try await client.decreasePriorityTorrents(hashes: [torrent.hash])
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "decrease_priority_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func deleteTorrent(then dismiss: DismissAction) {
        qBitData.shared.cacheManager.deleteTorrentsOptimistically(hashes: [torrent.hash])
        Task {
            do {
                try await client.deleteTorrent(hash: torrent.hash, deleteFiles: false)
                dismiss()
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "delete_torrent_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func deleteTorrentWithFiles(then dismiss: DismissAction) {
        qBitData.shared.cacheManager.deleteTorrentsOptimistically(hashes: [torrent.hash])
        Task {
            do {
                try await client.deleteTorrent(hash: torrent.hash, deleteFiles: true)
                dismiss()
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "delete_torrent_with_files_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func updateTorrentLimits(
        dlLimitKiB: Int64,
        upLimitKiB: Int64,
        ratioLimit: Float,
        seedingTimeLimit: Int,
        inactiveSeedingTimeLimit: Int,
        shareLimitAction: ShareLimitAction
    ) {
        let dlBytes = dlLimitKiB > 0 ? dlLimitKiB * 1024 : -1
        let upBytes = upLimitKiB > 0 ? upLimitKiB * 1024 : -1
        
        torrent.dl_limit = dlBytes
        torrent.up_limit = upBytes
        torrent.ratio_limit = ratioLimit
        torrent.seeding_time_limit = seedingTimeLimit
        torrent.inactive_seeding_time_limit = inactiveSeedingTimeLimit
        torrent.share_limit_action = shareLimitAction.rawValue
        
        qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: [torrent.hash]) { torrent in
            torrent.dl_limit = dlBytes
            torrent.up_limit = upBytes
            torrent.ratio_limit = ratioLimit
            torrent.seeding_time_limit = seedingTimeLimit
            torrent.inactive_seeding_time_limit = inactiveSeedingTimeLimit
            torrent.share_limit_action = shareLimitAction.rawValue
        }
        
        Task {
            do {
                try await client.setDownloadLimit(hashes: [torrent.hash], limit: Int(dlBytes))
                try await client.setUploadLimit(hashes: [torrent.hash], limit: Int(upBytes))
                try await client.setShareLimits(
                    hashes: [torrent.hash],
                    ratioLimit: ratioLimit,
                    seedingTimeLimit: seedingTimeLimit,
                    inactiveSeedingTimeLimit: inactiveSeedingTimeLimit,
                    shareLimitAction: shareLimitAction
                )
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "update_limits_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    enum State {
        case resumed, paused, forceStart
    }
}
