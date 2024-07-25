//
//  Structures.swift
//  qBitControl
//

import Foundation

struct GlobalTransferInfo: Decodable, Identifiable {
    let id = UUID()
    var fetchDate: Date = Date.now
    let dl_info_speed: Int64 // integer     Global download rate (bytes/s)
    let dl_info_data: Int64 // integer     Data downloaded this session (bytes)
    let up_info_speed: Int64 // integer     Global upload rate (bytes/s)
    let up_info_data: Int64 // integer     Data uploaded this session (bytes)
    let dl_rate_limit: Int64 // integer     Download rate limit (bytes/s)
    let up_rate_limit: Int64 // integer     Upload rate limit (bytes/s)
    let dht_nodes: Int64 // integer     DHT nodes connected to
    let connection_status: String // string     Connection status. See possible values here below
    
    enum CodingKeys: CodingKey {
        case dl_info_speed
        case dl_info_data
        case up_info_speed
        case up_info_data
        case dl_rate_limit
        case up_rate_limit
        case dht_nodes
        case connection_status
    }
    
    init(fetchDate: Date, dlspeed: Int64, dldata: Int64, dllimit: Int64, upspeed: Int64, updata: Int64, uplimit: Int64, dhtnodes: Int64, connection_status: String) {
        self.fetchDate = fetchDate
        self.dl_info_speed = dlspeed
        self.dl_info_data = dldata
        self.dl_rate_limit = dllimit
        
        self.up_info_speed = upspeed
        self.up_info_data = updata
        self.up_rate_limit = uplimit
        
        self.dht_nodes = dhtnodes
        self.connection_status = connection_status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.dl_info_data = try container.decode(Int64.self, forKey: .dl_info_data)
        self.dl_info_speed = try container.decode(Int64.self, forKey: .dl_info_speed)
        self.dl_rate_limit = try container.decode(Int64.self, forKey: .dl_rate_limit)
        
        self.up_info_data = try container.decode(Int64.self, forKey: .up_info_data)
        self.up_info_speed = try container.decode(Int64.self, forKey: .up_info_speed)
        self.up_rate_limit = try container.decode(Int64.self, forKey: .up_rate_limit)
        
        self.dht_nodes = try container.decode(Int64.self, forKey: .dht_nodes)
        self.connection_status = try container.decode(String.self, forKey: .connection_status)
    }
}

struct Torrent: Decodable, Hashable {
    let added_on: Int
    let amount_left: Int
    let auto_tmm: Bool
    let availability: Float
    let category: String
    let completed: Int
    let completion_on: Int
    let content_path: String
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
    let seeding_time: Int
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

struct qBitPreferences: Decodable {
    let locale: String?
    let create_subfolder_enabled: Bool?
    let start_paused_enabled: Bool?
    let auto_delete_mode: Int?
    let preallocate_all: Bool?
    let incomplete_files_ext: Bool?
    let auto_tmm_enabled: Bool?
    let torrent_changed_tmm_enabled: Bool?
    let save_path_changed_tmm_enabled: Bool?
    let category_changed_tmm_enabled: Bool?
    let save_path: String?
    let temp_path_enabled: Bool?
    let temp_path: String?
    //let scan_dirs: [Any]
    let export_dir: String?
    let export_dir_fin: String?
    let mail_notification_enabled: Bool?
    let mail_notification_sender: String?
    let mail_notification_email: String?
    let mail_notification_smtp: String?
    let mail_notification_ssl_enabled: Bool?
    let mail_notification_auth_enabled: Bool?
    let mail_notification_username: String?
    let mail_notification_password: String?
    let autorun_enabled: Bool?
    let autorun_program: String?
    let queueing_enabled: Bool?
    let max_active_downloads: Int?
    let max_active_torrents: Int?
    let max_active_uploads: Int?
    let dont_count_slow_torrents: Bool?
    let slow_torrent_dl_rate_threshold: Int?
    let slow_torrent_ul_rate_threshold: Int?
    let slow_torrent_inactive_timer: Int?
    let max_ratio_enabled: Bool?
    let max_ratio: Float?
    let max_ratio_act: Int?
    let listen_port: Int?
    let upnp: Bool?
    let random_port: Bool?
    let dl_limit: Int?
    let up_limit: Int?
    let max_connec: Int?
    let max_connec_per_torrent: Int?
    let max_uploads: Int?
    let max_uploads_per_torrent: Int?
    let stop_tracker_timeout: Int?
    let enable_piece_extent_affinity: Bool?
    let bittorrent_protocol: Int?
    let limit_utp_rate: Bool?
    let limit_tcp_overhead: Bool?
    let limit_lan_peers: Bool?
    let alt_dl_limit: Int?
    let alt_up_limit: Int?
    let scheduler_enabled: Bool?
    let schedule_from_hour: Int?
    let schedule_from_min: Int?
    let schedule_to_hour: Int?
    let schedule_to_min: Int?
    let scheduler_days: Int?
    let dht: Bool?
    let pex: Bool?
    let lsd: Bool?
    let encryption: Int?
    let anonymous_mode: Bool?
    let proxy_type: String?
    let proxy_ip: String?
    let proxy_port: Int?
    let proxy_peer_connections: Bool?
    let proxy_auth_enabled: Bool?
    let proxy_username: String?
    let proxy_password: String?
    let proxy_torrents_only: Bool?
    let ip_filter_enabled: Bool?
    let ip_filter_path: String?
    let ip_filter_trackers: Bool?
    let web_ui_domain_list: String?
    let web_ui_address: String?
    let web_ui_port: Int?
    let web_ui_upnp: Bool?
    let web_ui_username: String?
    let web_ui_password: String?
    let web_ui_csrf_protection_enabled: Bool?
    let web_ui_clickjacking_protection_enabled: Bool?
    let web_ui_secure_cookie_enabled: Bool?
    let web_ui_max_auth_fail_count: Int?
    let web_ui_ban_duration: Int?
    let web_ui_session_timeout: Int?
    let web_ui_host_header_validation_enabled: Bool?
    let bypass_local_auth: Bool?
    let bypass_auth_subnet_whitelist_enabled: Bool?
    let bypass_auth_subnet_whitelist: String?
    let alternative_webui_enabled: Bool?
    let alternative_webui_path: String?
    let use_https: Bool?
    let ssl_key: String?
    let ssl_cert: String?
    let web_ui_https_key_path: String?
    let web_ui_https_cert_path: String?
    let dyndns_enabled: Bool?
    let dyndns_service: Int?
    let dyndns_username: String?
    let dyndns_password: String?
    let dyndns_domain: String?
    let rss_refresh_interval: Int?
    let rss_max_articles_per_feed: Int?
    let rss_processing_enabled: Bool?
    let rss_auto_downloading_enabled: Bool?
    let rss_download_repack_proper_episodes: Bool?
    let rss_smart_episode_filters: String?
    let add_trackers_enabled: Bool?
    let add_trackers: String?
    let web_ui_use_custom_http_headers_enabled: Bool?
    let web_ui_custom_http_headers: String?
    let max_seeding_time_enabled: Bool?
    let max_seeding_time: Int?
    let announce_ip: String?
    let announce_to_all_tiers: Bool?
    let announce_to_all_trackers: Bool?
    let async_io_threads: Int?
    let banned_IPs: String?
    let checking_memory_use: Int?
    let current_interface_address: String?
    let current_network_interface: String?
    let disk_cache: Int?
    let disk_cache_ttl: Int?
    let embedded_tracker_port: Int?
    let enable_coalesce_read_write: Bool?
    let enable_embedded_tracker: Bool?
    let enable_multi_connections_from_same_ip: Bool?
    let enable_os_cache: Bool?
    let enable_upload_suggestions: Bool?
    let file_pool_size: Int?
    let outgoing_ports_max: Int?
    let outgoing_ports_min: Int?
    let recheck_completed_torrents: Bool?
    let resolve_peer_countries: Bool?
    let save_resume_data_interval: Int?
    let send_buffer_low_watermark: Int?
    let send_buffer_watermark: Int?
    let send_buffer_watermark_factor: Int?
    let socket_backlog_size: Int?
    let upload_choking_algorithm: Int?
    let upload_slots_behavior: Int?
    let upnp_lease_duration: Int?
    let utp_tcp_mixed_mode: Int?
}


struct Server: Codable, Identifiable {
    var id: String = UUID().uuidString
    let name: String
    let url: String
    let username: String
    let password: String
}

struct ServerAction {
    let name: String
    let action: () -> Void
}

struct Peer: Decodable {
    let client: String
    let connection: String
    let country: String
    let country_code: String
    let dl_speed: Int64
    let downloaded: Int64
    let files: String
    let flags: String
    let flags_desc: String
    let ip: String
    let port: Int
    let progress: Double
    let relevance: Double
    let up_speed: Int64
    let uploaded: Int64
}

struct Peers: Decodable {
    let full_update: Bool
    let peers: [String: Peer]
}

struct Tracker: Decodable, Hashable {
    let url: String // Tracker url
    let status: Int // Tracker status. See the table below for possible values
    let tier: Int // Tracker priority tier. Lower tier trackers are tried before higher tiers. Tier numbers are valid when >= 0, < 0 is used as placeholder when tier does not exist for special entries (such as DHT).
    let num_peers: Int // Number of peers for current torrent, as reported by the tracker
    let num_seeds: Int // Number of seeds for current torrent, asreported by the tracker
    let num_leeches: Int // Number of leeches for current torrent, as reported by the tracker
    let num_downloaded: Int // Number of completed downlods for current torrent, as reported by the tracker
    let msg: String // Tracker message (there is no way of knowing what this message is - it's up to tracker admins)
    
    
    /**
     Possible values of status:
     Value      Description
     0             Tracker is disabled (used for DHT, PeX, and LSD)
     1             Tracker has not been contacted yet
     2             Tracker has been contacted and is working
     3             Tracker is updating
     4             Tracker has been contacted, but it is not working (or doesn't send proper replies)
     */
}

struct File: Decodable {
    let index: Int // File index
    let name: String // File name (including relative path)
    let size: Int64 // File size (bytes)
    let progress: Float // File progress (percentage/100)
    let priority: Int // File priority. See possible values here below
    let is_seed: Bool? // True if file is seeding/complete
    let piece_range: [Int]// The first number is the starting piece index and the second number is the ending piece index (inclusive)
    let availability: Float // Percentage of file pieces currently available (percentage/100)
    
    /**
     Possible values of priority:
     Value      Description
     0             Do not download
     1             Normal priority
     6             High priority
     7             Maximal priority
     */
}

struct Article: Decodable {
    let category: String
    let id: String
    let torrentURL: String
    let title: String
    let date: Date
    let link: String
    let size: String
    let isRead: Bool?
    
    enum CodingKeys: CodingKey {
        case category
        case id
        case torrentURL
        case title
        case date
        case link
        case size
        case isRead
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.category = try container.decode(String.self, forKey: .category)
        self.id = try container.decode(String.self, forKey: .id)
        self.torrentURL = try container.decode(String.self, forKey: .torrentURL)
        self.title = try container.decode(String.self, forKey: .title)
        
        
        // Example: 06 Nov 2022 15:01:29 +0000
        // dd MMM yyyy HH:mm:ss Z
        let stringDate = try container.decode(String.self, forKey: .date)
        print(stringDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss Z"
        
        self.date = dateFormatter.date(from: stringDate) ?? Date.distantPast
        
        self.link = try container.decode(String.self, forKey: .link)
        self.size = try container.decode(String.self, forKey: .size)
        self.isRead = try? container.decode(Bool.self, forKey: .isRead)
    }
}

struct RSS: Decodable {
    let url: String
    let uid: String
    let isLoading: Bool
    let title: String
    let hasError: Bool
    let articles: [Article]
    
    
    enum CodingKeys: CodingKey {
        case url
        case uid
        case isLoading
        case title
        case hasError
        case articles
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.url = try container.decode(String.self, forKey: .url)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.isLoading = try container.decode(Bool.self, forKey: .isLoading)
        self.title = try container.decode(String.self, forKey: .title)
        self.hasError = try container.decode(Bool.self, forKey: .hasError)
        self.articles = try container.decode([Article].self, forKey: .articles).sorted(by: { $0.date > $1.date })
    }
}

struct AlertIdentifier: Identifiable {
    enum Choice {
        case resumeAll, pauseAll, logOut
    }

    var id: Choice
}

struct Category: Decodable, Hashable {
    let name: String
    let savePath: String
}
