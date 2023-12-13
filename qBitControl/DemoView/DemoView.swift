//

import SwiftUI

struct DemoView: View {
    @Binding public var isDemo: Bool
    
    var body: some View {
        TorrentListDemo(torrents: .constant([
            Torrent(added_on: Int(Date.now.timeIntervalSince1970), amount_left: 0, auto_tmm: false, availability: 100, category: "OS", completed: 0, completion_on: 0, content_path: "", dl_limit: 0, dlspeed: 0, downloaded: 0, downloaded_session: 0, eta: 0, f_l_piece_prio: false, force_start: false, hash: "hash1", last_activity: 0, magnet_uri: "", max_ratio: 0, max_seeding_time: 0, name: "Task 1", num_complete: 0, num_incomplete: 0, num_leechs: 0, num_seeds: 0, priority: 0, progress: 1, ratio: 1, ratio_limit: 0, save_path: "", seeding_time: 0, seeding_time_limit: 0, seen_complete: 0, seq_dl: false, size: 299000, state: "uploading", super_seeding: false, tags: "OS", time_active: 0, total_size: 299000, tracker: "", up_limit: 0, uploaded: 0, uploaded_session: 0, upspeed: 100000),
            Torrent(added_on: Int(Date.now.timeIntervalSince1970), amount_left: 0, auto_tmm: false, availability: 100, category: "Software", completed: 0, completion_on: 0, content_path: "", dl_limit: 0, dlspeed: 9000000, downloaded: 0, downloaded_session: 0, eta: 0, f_l_piece_prio: false, force_start: false, hash: "hash2", last_activity: 0, magnet_uri: "", max_ratio: 0, max_seeding_time: 0, name: "Task 2", num_complete: 0, num_incomplete: 0, num_leechs: 0, num_seeds: 0, priority: 0, progress: 0.5, ratio: 1, ratio_limit: 0, save_path: "", seeding_time: 0, seeding_time_limit: 0, seen_complete: 0, seq_dl: false, size: 299000, state: "downloading", super_seeding: false, tags: "Utilities", time_active: 0, total_size: 299000, tracker: "", up_limit: 0, uploaded: 0, uploaded_session: 0, upspeed: 200000),
            Torrent(added_on: Int(Date.now.timeIntervalSince1970), amount_left: 0, auto_tmm: false, availability: 100, category: "Misc", completed: 0, completion_on: 0, content_path: "", dl_limit: 0, dlspeed: 0, downloaded: 0, downloaded_session: 0, eta: 0, f_l_piece_prio: false, force_start: false, hash: "hash3", last_activity: 0, magnet_uri: "", max_ratio: 0, max_seeding_time: 0, name: "Task 3", num_complete: 0, num_incomplete: 0, num_leechs: 0, num_seeds: 0, priority: 0, progress: 0.72, ratio: 1, ratio_limit: 0, save_path: "", seeding_time: 0, seeding_time_limit: 0, seen_complete: 0, seq_dl: false, size: 299000, state: "pausedDL", super_seeding: false, tags: "Data", time_active: 0, total_size: 299000, tracker: "", up_limit: 0, uploaded: 0, uploaded_session: 0, upspeed: 0),
        ]), isLoggedIn: $isDemo)
    }
}
