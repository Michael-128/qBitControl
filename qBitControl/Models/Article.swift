//


import Foundation

struct Article: Decodable {
    let category: String
    let id: String
    let torrentURL: String
    let title: String
    let date: Date
    let link: String
    let size: String
    let isRead: Bool?
    
    enum CodingKeys: CodingKey {
        case category
        case id
        case torrentURL
        case title
        case date
        case link
        case size
        case isRead
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.category = try container.decode(String.self, forKey: .category)
        self.id = try container.decode(String.self, forKey: .id)
        self.torrentURL = try container.decode(String.self, forKey: .torrentURL)
        self.title = try container.decode(String.self, forKey: .title)
        
        
        // Example: 06 Nov 2022 15:01:29 +0000
        // dd MMM yyyy HH:mm:ss Z
        let stringDate = try container.decode(String.self, forKey: .date)
        print(stringDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss Z"
        
        self.date = dateFormatter.date(from: stringDate) ?? Date.distantPast
        
        self.link = try container.decode(String.self, forKey: .link)
        self.size = try container.decode(String.self, forKey: .size)
        self.isRead = try? container.decode(Bool.self, forKey: .isRead)
    }
}