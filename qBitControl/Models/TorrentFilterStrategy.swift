//
//  TorrentFilterStrategy.swift
//  qBitControl
//

import Foundation

protocol TorrentFilterStrategy {
    func matches(_ torrent: Torrent, filter: TorrentFilterOption) -> Bool
}

struct QBitTorrentFilterStrategy: TorrentFilterStrategy {
    func matches(_ torrent: Torrent, filter: TorrentFilterOption) -> Bool {
        switch filter {
        case .downloading:
            return torrent.state == "downloading"
                || torrent.state == "stalledDL"
                || torrent.state == "checkingDL"
                || torrent.state == "metaDL"
                || torrent.state == "forcedDL"
                || torrent.state == "allocating"
        case .completed, .seeding:
            return torrent.state == "seeding"
                || torrent.state == "uploading"
                || torrent.state == "stalledUP"
                || torrent.state == "checkingUP"
                || torrent.state == "forcedUP"
                || torrent.state == "queuedUP"
                || torrent.state == "pausedUP"
                || torrent.state == "stoppedUP"
        case .stopped:
            return torrent.state == "pausedDL"
                || torrent.state == "pausedUP"
                || torrent.state == "stoppedDL"
                || torrent.state == "stoppedUP"
        case .active:
            return !torrent.state.contains("paused")
                && !torrent.state.contains("stopped")
                && torrent.state != "error"
                && torrent.state != "missingFiles"
        case .inactive:
            return torrent.dlspeed == 0 && torrent.upspeed == 0
        case .stalled:
            return torrent.state == "stalledDL" || torrent.state == "stalledUP"
        case .stalledDownloading:
            return torrent.state == "stalledDL"
        case .stalledUploading:
            return torrent.state == "stalledUP"
        case .checking:
            return torrent.state == "checkingDL"
                || torrent.state == "checkingUP"
                || torrent.state == "checkingResumeData"
        case .errored:
            return torrent.state == "error" || torrent.state == "missingFiles"
        case .running:
            return !torrent.state.contains("paused") && !torrent.state.contains("stopped")
        case .moving:
            return torrent.state == "moving"
        case .all:
            return true
        }
    }
}
