//


import Foundation

struct MainData: Decodable {
    let rid: Int
    let full_update: Bool?
    let server_state: PartialServerState?
    let torrents: [String: PartialTorrent]?
    let torrents_removed: [String]?
    let categories: [String: Category]?
    let categories_removed: [String]?
    let tags: [String]?
    let tags_removed: [String]?
}