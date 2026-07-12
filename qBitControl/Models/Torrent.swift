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
    var inactive_seeding_time_limit: Int
    var share_limit_action: String?
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
    
    mutating func update(from partial: PartialTorrent) {
        if let value = partial.added_on { self.added_on = value }
        if let value = partial.amount_left { self.amount_left = value }
        if let value = partial.auto_tmm { self.auto_tmm = value }
        if let value = partial.availability { self.availability = value }
        if let value = partial.category { self.category = value }
        if let value = partial.completed { self.completed = value }
        if let value = partial.completion_on { self.completion_on = value }
        if let value = partial.content_path { self.content_path = value }
        if let value = partial.dl_limit { self.dl_limit = value }
        if let value = partial.dlspeed { self.dlspeed = value }
        if let value = partial.downloaded { self.downloaded = value }
        if let value = partial.downloaded_session { self.downloaded_session = value }
        if let value = partial.eta { self.eta = value }
        if let value = partial.f_l_piece_prio { self.f_l_piece_prio = value }
        if let value = partial.force_start { self.force_start = value }
        if let value = partial.last_activity { self.last_activity = value }
        if let value = partial.magnet_uri { self.magnet_uri = value }
        if let value = partial.max_ratio { self.max_ratio = value }
        if let value = partial.max_seeding_time { self.max_seeding_time = value }
        if let value = partial.name { self.name = value }
        if let value = partial.num_complete { self.num_complete = value }
        if let value = partial.num_incomplete { self.num_incomplete = value }
        if let value = partial.num_leechs { self.num_leechs = value }
        if let value = partial.num_seeds { self.num_seeds = value }
        if let value = partial.priority { self.priority = value }
        if let value = partial.progress { self.progress = value }
        if let value = partial.ratio { self.ratio = value }
        if let value = partial.ratio_limit { self.ratio_limit = value }
        if let value = partial.save_path { self.save_path = value }
        if let value = partial.seeding_time { self.seeding_time = value }
        if let value = partial.seeding_time_limit { self.seeding_time_limit = value }
        if let value = partial.inactive_seeding_time_limit { self.inactive_seeding_time_limit = value }
        if let value = partial.share_limit_action { self.share_limit_action = value }
        if let value = partial.seen_complete { self.seen_complete = value }
        if let value = partial.seq_dl { self.seq_dl = value }
        if let value = partial.size { self.size = value }
        if let value = partial.state { self.state = value }
        if let value = partial.super_seeding { self.super_seeding = value }
        if let value = partial.tags { self.tags = value }
        if let value = partial.time_active { self.time_active = value }
        if let value = partial.total_size { self.total_size = value }
        if let value = partial.tracker { self.tracker = value }
        if let value = partial.up_limit { self.up_limit = value }
        if let value = partial.uploaded { self.uploaded = value }
        if let value = partial.uploaded_session { self.uploaded_session = value }
        if let value = partial.upspeed { self.upspeed = value }
    }
}

extension Torrent {
    init(hash: String) {
        self.hash = hash
        self.added_on = 0
        self.amount_left = 0
        self.auto_tmm = false
        self.availability = 0.0
        self.category = ""
        self.completed = 0
        self.completion_on = 0
        self.content_path = nil
        self.dl_limit = 0
        self.dlspeed = 0
        self.downloaded = 0
        self.downloaded_session = 0
        self.eta = 0
        self.f_l_piece_prio = false
        self.force_start = false
        self.last_activity = 0
        self.magnet_uri = ""
        self.max_ratio = 0.0
        self.max_seeding_time = 0
        self.name = ""
        self.num_complete = 0
        self.num_incomplete = 0
        self.num_leechs = 0
        self.num_seeds = 0
        self.priority = 0
        self.progress = 0.0
        self.ratio = 0.0
        self.ratio_limit = 0.0
        self.save_path = ""
        self.seeding_time = nil
        self.seeding_time_limit = 0
        self.inactive_seeding_time_limit = -2
        self.share_limit_action = nil
        self.seen_complete = 0
        self.seq_dl = false
        self.size = 0
        self.state = ""
        self.super_seeding = false
        self.tags = ""
        self.time_active = 0
        self.total_size = 0
        self.tracker = ""
        self.up_limit = 0
        self.uploaded = 0
        self.uploaded_session = 0
        self.upspeed = 0
    }
    
    init(from partial: PartialTorrent, hash: String) {
        self.init(hash: hash)
        self.update(from: partial)
    }
}