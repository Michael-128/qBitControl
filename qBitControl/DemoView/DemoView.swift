//

import SwiftUI

struct DemoView: View {

    @Binding public var isDemo: Bool
    
    func generateTorrents() -> [Torrent] {
        var torrents: [Torrent] = []
        

        torrents.append(Torrent(added_on: 1701533736, amount_left: 0, auto_tmm: false, availability: 0, category: "Category 1", completed: 0, completion_on: 1701533736, content_path: "/task1", dl_limit: 0, dlspeed: 0, downloaded: 0, downloaded_session: 0, eta: 0, f_l_piece_prio: false, force_start: false, hash: "hash", last_activity: 1701533736, magnet_uri: "", max_ratio: 0, max_seeding_time: 0, name: "Task 1", num_complete: 0, num_incomplete: 0, num_leechs: 0, num_seeds: 0, priority: 0, progress: 1, ratio: 0, ratio_limit: 0, save_path: "", seeding_time: 0, seeding_time_limit: 0, seen_complete: 0, seq_dl: false, size: 8*1024*1024*1024, state: "uploading", super_seeding: false, tags: "None", time_active: 0, total_size: 8*1024*1024*1024, tracker: "None", up_limit: 0, uploaded: 0, uploaded_session: 0, upspeed: 0))
        
        torrents.append(Torrent(added_on: 1701533736, amount_left: 2312312, auto_tmm: false, availability: 1, category: "Category 2", completed: 9, completion_on: 1701533736, content_path: "/task2", dl_limit: 0, dlspeed: 0, downloaded: 0, downloaded_session: 342, eta: 2342, f_l_piece_prio: false, force_start: false, hash: "hash", last_activity: 1701533736, magnet_uri: "", max_ratio: 1.2, max_seeding_time: 0, name: "Task 2", num_complete: 0, num_incomplete: 0, num_leechs: 1, num_seeds: 1, priority: 1, progress: 1/3, ratio: 0.9, ratio_limit: 0.9, save_path: "", seeding_time: 1, seeding_time_limit: 1, seen_complete: 1, seq_dl: false, size: 2123123, state: "downloading", super_seeding: false, tags: "None", time_active: 23123, total_size: 123123, tracker: "None", up_limit: 123, uploaded: 123, uploaded_session: 234, upspeed: 23442))
        
        torrents.append(Torrent(added_on: 1701533736, amount_left: 1000, auto_tmm: false, availability: 1, category: "Category 3", completed: 9, completion_on: 1701533736, content_path: "/task3", dl_limit: 0, dlspeed: 0, downloaded: 0, downloaded_session: 342, eta: 2342, f_l_piece_prio: false, force_start: false, hash: "hash", last_activity: 1701533736, magnet_uri: "", max_ratio: 1.2, max_seeding_time: 0, name: "Task 3", num_complete: 0, num_incomplete: 0, num_leechs: 1, num_seeds: 1, priority: 1, progress: 1/5, ratio: 0.9, ratio_limit: 0.9, save_path: "", seeding_time: 1, seeding_time_limit: 1, seen_complete: 1, seq_dl: false, size: 2123123, state: "checkingUP", super_seeding: false, tags: "None", time_active: 23123, total_size: 123123, tracker: "None", up_limit: 123, uploaded: 123, uploaded_session: 234, upspeed: 23442))
        
        torrents.append(Torrent(added_on: 1701533736, amount_left: 1000, auto_tmm: false, availability: 1, category: "Category 4", completed: 9, completion_on: 1701533736, content_path: "/task4", dl_limit: 0, dlspeed: 0, downloaded: 0, downloaded_session: 342, eta: 2342, f_l_piece_prio: false, force_start: false, hash: "hash", last_activity: 1701533736, magnet_uri: "", max_ratio: 1.2, max_seeding_time: 0, name: "Task 4", num_complete: 0, num_incomplete: 0, num_leechs: 1, num_seeds: 1, priority: 1, progress: 0.9, ratio: 0.9, ratio_limit: 0.9, save_path: "", seeding_time: 1, seeding_time_limit: 1, seen_complete: 1, seq_dl: false, size: 2123123, state: "pausedDL", super_seeding: false, tags: "None", time_active: 23123, total_size: 123123, tracker: "None", up_limit: 123, uploaded: 123, uploaded_session: 234, upspeed: 23442))
    
    

        return torrents
    }

    var body: some View {
        TorrentListViewDemo(torrents: generateTorrents(), isDemo: $isDemo)
    }
}

#Preview {
    DemoView(isDemo: .constant(true))
}
