import Foundation

enum TorrentFilterOption: String, CaseIterable, Codable {
    case all
    case running
    case stalledUploading = "stalled_uploading"
    case stalledDownloading = "stalled_downloading"
    case downloading
    case seeding
    case completed
    case stopped
    case active
    case inactive
    case stalled
    case errored
    case checking
    case moving
}
