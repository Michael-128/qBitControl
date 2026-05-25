import Foundation

struct TorrentProperties: Decodable {
    let save_path: String?
    let creation_date: Int?
    let piece_size: Int64?
    let comment: String?
    let total_wasted: Int64?
    let total_uploaded: Int64?
    let total_uploaded_session: Int64?
    let total_downloaded: Int64?
    let total_downloaded_session: Int64?
    let up_limit: Int64?
    let dl_limit: Int64?
    let time_elapsed: Int?
    let seeding_time: Int?
    let nb_connections: Int?
    let nb_connections_limit: Int?
    let share_ratio: Float?
    let addition_date: Int?
    let completion_date: Int?
    let created_by: String?
    let dl_speed_avg: Int64?
    let dl_speed: Int64?
    let eta: Int?
    let last_seen: Int?
    let peers: Int?
    let peers_total: Int?
    let pieces_have: Int?
    let pieces_num: Int?
    let reannounce: Int?
    let seeds: Int?
    let seeds_total: Int?
    let total_size: Int64?
    let up_speed_avg: Int64?
    let up_speed: Int64?
    let isPrivate: Bool?
}

struct PeerLogEntry: Decodable, Identifiable {
    let id: Int
    let ip: String
    let timestamp: Int
    let blocked: Bool
    let reason: String?

    var formattedDate: String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
