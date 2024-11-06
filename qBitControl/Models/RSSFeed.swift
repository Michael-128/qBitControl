//


import Foundation

struct RSSFeed: Decodable, Identifiable {
    var id: UUID { UUID() }
    let url: String?
    let uid: String?
    let isLoading: Bool?
    let title: String
    let hasError: Bool?
    let articles: [Article]
    
    struct Article: Decodable, Identifiable {
        var id: UUID { UUID() }
        let category: String?
        let title: String?
        let date: String?
        let link: String?
        let size: String?
        let torrentURL: String?
        let isRead: Bool?
    }
}

