//


import Foundation

struct PartialServerState: Decodable {
    let alltime_dl: Int64?
    let alltime_ul: Int64?
    let average_time_queue: Int?
    let connection_status: String?
    let dht_nodes: Int?
    let dl_info_data: Int64?
    let dl_info_speed: Int?
    let dl_rate_limit: Int?
    let free_space_on_disk: Int64?
    let global_ratio: String?
    let queued_io_jobs: Int?
    let queueing: Bool?
    let read_cache_hits: String?
    let read_cache_overload: String?
    let refresh_interval: Int?
    let total_buffers_size: Int?
    let total_peer_connections: Int?
    let total_queued_size: Int?
    let total_wasted_session: Int64?
    let up_info_data: Int64?
    let up_info_speed: Int?
    let up_rate_limit: Int?
    let use_alt_speed_limits: Bool?
    let use_subcategories: Bool?
    let write_cache_overload: String?
}