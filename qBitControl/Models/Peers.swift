//


import Foundation

struct Peers: Decodable {
    let full_update: Bool
    let peers: [String: Peer]
}