//


import Foundation

struct Server: Codable, Identifiable {
    var id: String = UUID().uuidString
    let name: String
    let url: String
    let username: String
    let password: String
}