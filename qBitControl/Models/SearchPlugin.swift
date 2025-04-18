import Foundation

struct SearchPlugin: Hashable, Decodable {
    let enabled: Bool?
    let fullName: String?
    let name: String?
    let supportedCategories: [SearchCategory]?
    let url: String?
    let version: String?
}
