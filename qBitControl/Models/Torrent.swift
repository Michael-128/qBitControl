//


import Foundation

struct Torrent: Decodable, Hashable {
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

    static func == (lhs: Torrent, rhs: Torrent) -> Bool {
        lhs.hash == rhs.hash &&
        lhs.dlspeed == rhs.dlspeed &&
        lhs.upspeed == rhs.upspeed &&
        lhs.progress == rhs.progress &&
        lhs.state == rhs.state &&
        lhs.eta == rhs.eta &&
        lhs.num_seeds == rhs.num_seeds &&
        lhs.num_leechs == rhs.num_leechs &&
        lhs.ratio == rhs.ratio &&
        lhs.uploaded == rhs.uploaded &&
        lhs.downloaded == rhs.downloaded &&
        lhs.category == rhs.category &&
        lhs.tags == rhs.tags
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }

    mutating func update(from partial: PartialTorrent) {
        if let v = partial.added_on { added_on = v }
        if let v = partial.amount_left { amount_left = v }
        if let v = partial.auto_tmm { auto_tmm = v }
        if let v = partial.availability { availability = v }
        if let v = partial.category { category = v }
        if let v = partial.completed { completed = v }
        if let v = partial.completion_on { completion_on = v }
        if let v = partial.content_path { content_path = v }
        if let v = partial.dl_limit { dl_limit = v }
        if let v = partial.dlspeed { dlspeed = v }
        if let v = partial.downloaded { downloaded = v }
        if let v = partial.downloaded_session { downloaded_session = v }
        if let v = partial.eta { eta = v }
        if let v = partial.f_l_piece_prio { f_l_piece_prio = v }
        if let v = partial.force_start { force_start = v }
        if let v = partial.last_activity { last_activity = v }
        if let v = partial.magnet_uri { magnet_uri = v }
        if let v = partial.max_ratio { max_ratio = v }
        if let v = partial.max_seeding_time { max_seeding_time = v }
        if let v = partial.name { name = v }
        if let v = partial.num_complete { num_complete = v }
        if let v = partial.num_incomplete { num_incomplete = v }
        if let v = partial.num_leechs { num_leechs = v }
        if let v = partial.num_seeds { num_seeds = v }
        if let v = partial.priority { priority = v }
        if let v = partial.progress { progress = v }
        if let v = partial.ratio { ratio = v }
        if let v = partial.ratio_limit { ratio_limit = v }
        if let v = partial.save_path { save_path = v }
        if let v = partial.seeding_time { seeding_time = v }
        if let v = partial.seeding_time_limit { seeding_time_limit = v }
        if let v = partial.seen_complete { seen_complete = v }
        if let v = partial.seq_dl { seq_dl = v }
        if let v = partial.size { size = v }
        if let v = partial.state { state = v }
        if let v = partial.super_seeding { super_seeding = v }
        if let v = partial.tags { tags = v }
        if let v = partial.time_active { time_active = v }
        if let v = partial.total_size { total_size = v }
        if let v = partial.tracker { tracker = v }
        if let v = partial.up_limit { up_limit = v }
        if let v = partial.uploaded { uploaded = v }
        if let v = partial.uploaded_session { uploaded_session = v }
        if let v = partial.upspeed { upspeed = v }
    }

    init?(hash: String, from partial: PartialTorrent) {
        self.hash = hash
        self.added_on = partial.added_on ?? 0
        self.amount_left = partial.amount_left ?? 0
        self.auto_tmm = partial.auto_tmm ?? false
        self.availability = partial.availability ?? 0
        self.category = partial.category ?? ""
        self.completed = partial.completed ?? 0
        self.completion_on = partial.completion_on ?? 0
        self.content_path = partial.content_path
        self.dl_limit = partial.dl_limit ?? 0
        self.dlspeed = partial.dlspeed ?? 0
        self.downloaded = partial.downloaded ?? 0
        self.downloaded_session = partial.downloaded_session ?? 0
        self.eta = partial.eta ?? 0
        self.f_l_piece_prio = partial.f_l_piece_prio ?? false
        self.force_start = partial.force_start ?? false
        self.last_activity = partial.last_activity ?? 0
        self.magnet_uri = partial.magnet_uri ?? ""
        self.max_ratio = partial.max_ratio ?? -1
        self.max_seeding_time = partial.max_seeding_time ?? -1
        self.name = partial.name ?? ""
        self.num_complete = partial.num_complete ?? 0
        self.num_incomplete = partial.num_incomplete ?? 0
        self.num_leechs = partial.num_leechs ?? 0
        self.num_seeds = partial.num_seeds ?? 0
        self.priority = partial.priority ?? 0
        self.progress = partial.progress ?? 0
        self.ratio = partial.ratio ?? 0
        self.ratio_limit = partial.ratio_limit ?? -1
        self.save_path = partial.save_path ?? ""
        self.seeding_time = partial.seeding_time
        self.seeding_time_limit = partial.seeding_time_limit ?? -1
        self.seen_complete = partial.seen_complete ?? 0
        self.seq_dl = partial.seq_dl ?? false
        self.size = partial.size ?? 0
        self.state = partial.state ?? "unknown"
        self.super_seeding = partial.super_seeding ?? false
        self.tags = partial.tags ?? ""
        self.time_active = partial.time_active ?? 0
        self.total_size = partial.total_size ?? 0
        self.tracker = partial.tracker ?? ""
        self.up_limit = partial.up_limit ?? 0
        self.uploaded = partial.uploaded ?? 0
        self.uploaded_session = partial.uploaded_session ?? 0
        self.upspeed = partial.upspeed ?? 0
    }
}