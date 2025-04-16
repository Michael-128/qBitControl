import Foundation

struct SearchResult: Decodable, Hashable {
    let descrLink: String?
    let engineName: String?
    let fileName: String?
    let fileSize: Int64?
    let fileUrl: String?
    let nbLeechers: Int?
    let nbSeeders: Int?
    let pubDate: Int?
    let siteUrl: String?
}
