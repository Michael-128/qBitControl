//


import Foundation

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