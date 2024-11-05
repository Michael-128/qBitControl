//


import Foundation

struct MainData: Decodable {
    let rid: Int
    let full_update: Bool?
    let server_state: PartialServerState?
}