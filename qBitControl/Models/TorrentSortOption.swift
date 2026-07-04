import Foundation

enum TorrentSortOption: String, CaseIterable, Codable {
    case addedOn = "added_on"
    case amountLeft = "amount_left"
    case availability
    case category
    case completed
    case completionOn = "completion_on"
    case dlLimit = "dl_limit"
    case dlspeed
    case downloaded
    case downloadedSession = "downloaded_session"
    case eta
    case lastActivity = "last_activity"
    case maxRatio = "max_ratio"
    case maxSeedingTime = "max_seeding_time"
    case name
    case numComplete = "num_complete"
    case numIncomplete = "num_incomplete"
    case numLeechs = "num_leechs"
    case numSeeds = "num_seeds"
    case priority
    case progress
    case ratio
    case ratioLimit = "ratio_limit"
    case seedingTime = "seeding_time"
    case seedingTimeLimit = "seeding_time_limit"
    case size
    case state
    case tags
    case timeActive = "time_active"
    case totalSize = "total_size"
    case upLimit = "up_limit"
    case uploaded
    case uploadedSession = "uploaded_session"
    case upspeed
}
