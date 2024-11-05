//


import Foundation

struct Torrent: Decodable, Hashable {
    let added_on: Int
    let amount_left: Int
    let auto_tmm: Bool
    let availability: Float
    let category: String
    let completed: Int
    let completion_on: Int
    let content_path: String?
    let dl_limit: Int64
    let dlspeed: Int64
    let downloaded: Int64
    let downloaded_session: Int64
    let eta: Int
    let f_l_piece_prio: Bool
    let force_start: Bool
    let hash: String
    let last_activity: Int
    let magnet_uri: String
    let max_ratio: Float
    let max_seeding_time: Int
    let name: String
    let num_complete: Int
    let num_incomplete: Int
    let num_leechs: Int
    let num_seeds: Int
    let priority: Int
    let progress: Float
    let ratio: Float
    let ratio_limit: Float
    let save_path: String
    let seeding_time: Int?
    let seeding_time_limit: Int
    let seen_complete: Int
    let seq_dl: Bool
    let size: Int64
    var state: String
    let super_seeding: Bool
    let tags: String
    let time_active: Int
    let total_size: Int64
    let tracker: String
    let up_limit: Int64
    let uploaded: Int64
    let uploaded_session: Int64
    let upspeed: Int64
}