struct SearchResponse: Decodable {
    let results: [SearchResult]
    let status: String
    let total: Int
}
