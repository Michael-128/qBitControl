import Foundation

enum TorrentFilterOption: String, CaseIterable, Codable {
    case all
    case resumed
    case stalledUploading = "stalled_uploading"
    case stalledDownloading = "stalled_downloading"
    case downloading
    case seeding
    case completed
    case paused
    case active
    case inactive
    case stalled
    case errored
    case checking
}
