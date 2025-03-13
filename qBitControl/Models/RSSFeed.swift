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
        
        var description: String? {
            var components: [String] = []
            if let category = self.category { components.append(category) }
            if let size = self.size { components.append(size) }
            
            let result = components.joined(separator: " • ")
            return result.isEmpty ? nil : result
        }
    }
}

