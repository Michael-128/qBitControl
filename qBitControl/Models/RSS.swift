//


import Foundation

struct RSS: Decodable {
    let url: String
    let uid: String
    let isLoading: Bool
    let title: String
    let hasError: Bool
    let articles: [Article]
    
    
    enum CodingKeys: CodingKey {
        case url
        case uid
        case isLoading
        case title
        case hasError
        case articles
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.url = try container.decode(String.self, forKey: .url)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.isLoading = try container.decode(Bool.self, forKey: .isLoading)
        self.title = try container.decode(String.self, forKey: .title)
        self.hasError = try container.decode(Bool.self, forKey: .hasError)
        self.articles = try container.decode([Article].self, forKey: .articles).sorted(by: { $0.date > $1.date })
    }
}