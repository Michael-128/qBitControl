//


import Foundation

struct ServerState: Decodable {
    var alltime_dl: Int64
    var alltime_ul: Int64
    var average_time_queue: Int
    var connection_status: String
    var dht_nodes: Int
    var dl_info_data: Int64
    var dl_info_speed: Int
    var dl_rate_limit: Int
    var free_space_on_disk: Int64
    var global_ratio: String
    var queued_io_jobs: Int
    var queueing: Bool
    var read_cache_hits: String
    var read_cache_overload: String
    var refresh_interval: Int
    var total_buffers_size: Int
    var total_peer_connections: Int
    var total_queued_size: Int
    var total_wasted_session: Int64
    var up_info_data: Int64
    var up_info_speed: Int
    var up_rate_limit: Int
    var use_alt_speed_limits: Bool
    var use_subcategories: Bool
    var write_cache_overload: String

    // Initializer that creates ServerState from PartialServerState using default values for missing fields
    init(from partial: PartialServerState) {
        self.alltime_dl = partial.alltime_dl ?? 0
        self.alltime_ul = partial.alltime_ul ?? 0
        self.average_time_queue = partial.average_time_queue ?? 0
        self.connection_status = partial.connection_status ?? ""
        self.dht_nodes = partial.dht_nodes ?? 0
        self.dl_info_data = partial.dl_info_data ?? 0
        self.dl_info_speed = partial.dl_info_speed ?? 0
        self.dl_rate_limit = partial.dl_rate_limit ?? 0
        self.free_space_on_disk = partial.free_space_on_disk ?? 0
        self.global_ratio = partial.global_ratio ?? "0.00"
        self.queued_io_jobs = partial.queued_io_jobs ?? 0
        self.queueing = partial.queueing ?? false
        self.read_cache_hits = partial.read_cache_hits ?? "0"
        self.read_cache_overload = partial.read_cache_overload ?? "0"
        self.refresh_interval = partial.refresh_interval ?? 0
        self.total_buffers_size = partial.total_buffers_size ?? 0
        self.total_peer_connections = partial.total_peer_connections ?? 0
        self.total_queued_size = partial.total_queued_size ?? 0
        self.total_wasted_session = partial.total_wasted_session ?? 0
        self.up_info_data = partial.up_info_data ?? 0
        self.up_info_speed = partial.up_info_speed ?? 0
        self.up_rate_limit = partial.up_rate_limit ?? 0
        self.use_alt_speed_limits = partial.use_alt_speed_limits ?? false
        self.use_subcategories = partial.use_subcategories ?? false
        self.write_cache_overload = partial.write_cache_overload ?? "0"
    }
    
    mutating func update(from partial: PartialServerState) {
       if let alltime_dl = partial.alltime_dl { self.alltime_dl = alltime_dl }
       if let alltime_ul = partial.alltime_ul { self.alltime_ul = alltime_ul }
       if let average_time_queue = partial.average_time_queue { self.average_time_queue = average_time_queue }
       if let connection_status = partial.connection_status { self.connection_status = connection_status }
       if let dht_nodes = partial.dht_nodes { self.dht_nodes = dht_nodes }
       if let dl_info_data = partial.dl_info_data { self.dl_info_data = dl_info_data }
       if let dl_info_speed = partial.dl_info_speed { self.dl_info_speed = dl_info_speed }
       if let dl_rate_limit = partial.dl_rate_limit { self.dl_rate_limit = dl_rate_limit }
       if let free_space_on_disk = partial.free_space_on_disk { self.free_space_on_disk = free_space_on_disk }
       if let global_ratio = partial.global_ratio { self.global_ratio = global_ratio }
       if let queued_io_jobs = partial.queued_io_jobs { self.queued_io_jobs = queued_io_jobs }
       if let queueing = partial.queueing { self.queueing = queueing }
       if let read_cache_hits = partial.read_cache_hits { self.read_cache_hits = read_cache_hits }
       if let read_cache_overload = partial.read_cache_overload { self.read_cache_overload = read_cache_overload }
       if let refresh_interval = partial.refresh_interval { self.refresh_interval = refresh_interval }
       if let total_buffers_size = partial.total_buffers_size { self.total_buffers_size = total_buffers_size }
       if let total_peer_connections = partial.total_peer_connections { self.total_peer_connections = total_peer_connections }
       if let total_queued_size = partial.total_queued_size { self.total_queued_size = total_queued_size }
       if let total_wasted_session = partial.total_wasted_session { self.total_wasted_session = total_wasted_session }
       if let up_info_data = partial.up_info_data { self.up_info_data = up_info_data }
       if let up_info_speed = partial.up_info_speed { self.up_info_speed = up_info_speed }
       if let up_rate_limit = partial.up_rate_limit { self.up_rate_limit = up_rate_limit }
       if let use_alt_speed_limits = partial.use_alt_speed_limits { self.use_alt_speed_limits = use_alt_speed_limits }
       if let use_subcategories = partial.use_subcategories { self.use_subcategories = use_subcategories }
       if let write_cache_overload = partial.write_cache_overload { self.write_cache_overload = write_cache_overload }
   }
}