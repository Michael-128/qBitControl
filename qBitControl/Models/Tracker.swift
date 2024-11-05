//


import Foundation

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