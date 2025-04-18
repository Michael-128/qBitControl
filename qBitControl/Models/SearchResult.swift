import Foundation // Required for UUID

struct SearchResult: Decodable, Identifiable {
    var id = UUID()

    let descrLink: String?
    let engineName: String?
    let fileName: String?
    let fileSize: Int64?
    let fileUrl: String?
    let nbLeechers: Int?
    let nbSeeders: Int?
    let pubDate: Int?
    let siteUrl: String?

    private enum CodingKeys: String, CodingKey {
        case descrLink
        case engineName
        case fileName
        case fileSize
        case fileUrl
        case nbLeechers
        case nbSeeders
        case pubDate
        case siteUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        descrLink = try container.decodeIfPresent(String.self, forKey: .descrLink)
        engineName = try container.decodeIfPresent(String.self, forKey: .engineName)
        fileName = try container.decodeIfPresent(String.self, forKey: .fileName)
        fileSize = try container.decodeIfPresent(Int64.self, forKey: .fileSize)
        fileUrl = try container.decodeIfPresent(String.self, forKey: .fileUrl)
        nbLeechers = try container.decodeIfPresent(Int.self, forKey: .nbLeechers)
        nbSeeders = try container.decodeIfPresent(Int.self, forKey: .nbSeeders)
        pubDate = try container.decodeIfPresent(Int.self, forKey: .pubDate)
        siteUrl = try container.decodeIfPresent(String.self, forKey: .siteUrl)
    }
}
