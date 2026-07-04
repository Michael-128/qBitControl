//


import Foundation

struct Torrent: Codable, Hashable {
    var added_on: Int
    var amount_left: Int
    var auto_tmm: Bool
    var availability: Float
    var category: String
    var completed: Int
    var completion_on: Int
    var content_path: String?
    var dl_limit: Int64
    var dlspeed: Int64
    var downloaded: Int64
    var downloaded_session: Int64
    var eta: Int
    var f_l_piece_prio: Bool
    var force_start: Bool
    let hash: String
    var last_activity: Int
    var magnet_uri: String
    var max_ratio: Float
    var max_seeding_time: Int
    var name: String
    var num_complete: Int
    var num_incomplete: Int
    var num_leechs: Int
    var num_seeds: Int
    var priority: Int
    var progress: Float
    var ratio: Float
    var ratio_limit: Float
    var save_path: String
    var seeding_time: Int?
    var seeding_time_limit: Int
    var seen_complete: Int
    var seq_dl: Bool
    var size: Int64
    var state: String
    var super_seeding: Bool
    var tags: String
    var time_active: Int
    var total_size: Int64
    var tracker: String
    var up_limit: Int64
    var uploaded: Int64
    var uploaded_session: Int64
    var upspeed: Int64
}