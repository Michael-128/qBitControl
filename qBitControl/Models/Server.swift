//


import Foundation

struct Server: Codable, Identifiable {
    var id: String = UUID().uuidString
    let name: String
    let url: String
    let username: String
    let password: String
    let basicAuth: BasicAuth?
    var customHeaders: [CustomHeader] = []

    enum CodingKeys: String, CodingKey {
        case id, name, url, username, password, basicAuth, customHeaders
    }

    init(id: String = UUID().uuidString, name: String, url: String, username: String, password: String, basicAuth: BasicAuth? = nil, customHeaders: [CustomHeader] = []) {
        self.id = id
        self.name = name
        self.url = url
        self.username = username
        self.password = password
        self.basicAuth = basicAuth
        self.customHeaders = customHeaders
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        username = try container.decode(String.self, forKey: .username)
        password = try container.decode(String.self, forKey: .password)
        basicAuth = try container.decodeIfPresent(BasicAuth.self, forKey: .basicAuth)
        customHeaders = try container.decodeIfPresent([CustomHeader].self, forKey: .customHeaders) ?? []
    }

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

    struct CustomHeader: Codable, Identifiable, Equatable {
        var id: String = UUID().uuidString
        var key: String
        var value: String

        enum CodingKeys: String, CodingKey {
            case id, key, value
        }

        init(id: String = UUID().uuidString, key: String, value: String) {
            self.id = id
            self.key = key
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
            key = try container.decode(String.self, forKey: .key)
            value = try container.decode(String.self, forKey: .value)
        }
    }
}
