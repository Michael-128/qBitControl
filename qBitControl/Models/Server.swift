//


import Foundation

struct Server: Codable, Identifiable {
    var id: String = UUID().uuidString
    let name: String
    let url: String
    let username: String
    let password: String
    let basicAuth: BasicAuth?
    
    struct BasicAuth: Codable {
        let username: String
        let password: String
        
        init(_ username: String, _ password: String) {
            self.username = username
            self.password = password
        }
        
        func getAuthString() -> String {
            let authString = "\(username):\(password)".data(using: .utf8)!
            return authString.base64EncodedString()
        }
    }
}
