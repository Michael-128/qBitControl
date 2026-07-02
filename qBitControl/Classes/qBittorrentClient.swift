//
//  qBittorrentClient.swift
//  qBitControl
//

import Foundation

class qBittorrentClient: TorrentClientProtocol {
    private let networkClient: NetworkClient
    private(set) var cookie: String?
    
    enum ClientError: Error {
        case notImplemented
    }
    
    init(networkClient: NetworkClient, cookie: String? = nil) {
        self.networkClient = networkClient
        self.cookie = cookie
    }
    
    // MARK: - TorrentTaskActions
    
    func fetchTorrents(
        filter: String?,
        category: String?,
        tag: String?,
        sort: String?,
        reverse: Bool?
    ) async throws -> [Torrent] {
        var queryItems: [URLQueryItem] = []
        if let filter = filter { queryItems.append(URLQueryItem(name: "filter", value: filter)) }
        if let category = category { queryItems.append(URLQueryItem(name: "category", value: category)) }
        if let tag = tag { queryItems.append(URLQueryItem(name: "tag", value: tag)) }
        if let sort = sort { queryItems.append(URLQueryItem(name: "sort", value: sort)) }
        if let reverse = reverse { queryItems.append(URLQueryItem(name: "reverse", value: String(reverse))) }
        
        return try await networkClient.sendRequest(path: "/api/v2/torrents/info", queryItems: queryItems, cookie: self.cookie)
    }
    
    func pauseTorrent(hash: String) async throws {
        throw ClientError.notImplemented
    }
    
    func pauseTorrents(hashes: [String]) async throws {
        throw ClientError.notImplemented
    }
    
    func pauseAllTorrents() async throws {
        throw ClientError.notImplemented
    }
    
    func resumeTorrent(hash: String) async throws {
        throw ClientError.notImplemented
    }
    
    func resumeTorrents(hashes: [String]) async throws {
        throw ClientError.notImplemented
    }
    
    func resumeAllTorrents() async throws {
        throw ClientError.notImplemented
    }
    
    func recheckTorrent(hash: String) async throws {
        throw ClientError.notImplemented
    }
    
    func recheckTorrents(hashes: [String]) async throws {
        throw ClientError.notImplemented
    }
    
    func reannounceTorrent(hash: String) async throws {
        throw ClientError.notImplemented
    }
    
    func reannounceTorrents(hashes: [String]) async throws {
        throw ClientError.notImplemented
    }
    
    func deleteTorrent(hash: String, deleteFiles: Bool) async throws {
        throw ClientError.notImplemented
    }
    
    func deleteTorrents(hashes: [String], deleteFiles: Bool) async throws {
        throw ClientError.notImplemented
    }
    
    func increasePriorityTorrents(hashes: [String]) async throws {
        throw ClientError.notImplemented
    }
    
    func decreasePriorityTorrents(hashes: [String]) async throws {
        throw ClientError.notImplemented
    }
    
    func topPriorityTorrents(hashes: [String]) async throws {
        throw ClientError.notImplemented
    }
    
    func bottomPriorityTorrents(hashes: [String]) async throws {
        throw ClientError.notImplemented
    }
    
    func toggleSequentialDownload(hashes: [String]) async throws {
        throw ClientError.notImplemented
    }
    
    func toggleFLPiecesFirst(hashes: [String]) async throws {
        throw ClientError.notImplemented
    }
    
    func setForceStart(hashes: [String], value: Bool) async throws {
        throw ClientError.notImplemented
    }
    
    func addMagnetTorrent(
        torrent: URLQueryItem,
        savePath: String = "",
        cookie: String = "",
        category: String = "",
        tags: String = "",
        skipChecking: Bool = false,
        paused: Bool = false,
        sequentialDownload: Bool = false,
        dlLimit: Int = -1,
        upLimit: Int = -1,
        ratioLimit: Float = -1.0,
        seedingTimeLimit: Int = -1
    ) async throws {
        throw ClientError.notImplemented
    }
    
    func addFileTorrent(
        torrents: [String: Data],
        savePath: String = "",
        cookie: String = "",
        category: String = "",
        tags: String = "",
        skipChecking: Bool = false,
        paused: Bool = false,
        sequentialDownload: Bool = false,
        dlLimit: Int = -1,
        upLimit: Int = -1,
        ratioLimit: Float = -1.0,
        seedingTimeLimit: Int = -1
    ) async throws {
        throw ClientError.notImplemented
    }
    
    // MARK: - TorrentRSSActions
    
    func getRSSFeeds(withDate: Bool = true) async throws -> RSSNode {
        throw ClientError.notImplemented
    }
    
    func addRSSFeed(url: String, path: String) async throws {
        throw ClientError.notImplemented
    }
    
    func addRSSFolder(path: String) async throws {
        throw ClientError.notImplemented
    }
    
    func addRSSRemoveItem(path: String) async throws {
        throw ClientError.notImplemented
    }
    
    func addRSSRefreshItem(path: String) async throws {
        throw ClientError.notImplemented
    }
    
    func moveRSSItem(itemPath: String, destPath: String) async throws {
        throw ClientError.notImplemented
    }
    
    // MARK: - TorrentCategoryTagActions
    
    func getCategories() async throws -> [String: Category] {
        throw ClientError.notImplemented
    }
    
    func setCategory(hash: String, category: String) async throws {
        throw ClientError.notImplemented
    }
    
    func addCategory(category: String, savePath: String?) async throws -> Int {
        throw ClientError.notImplemented
    }
    
    func removeCategory(category: String) async throws -> Int {
        throw ClientError.notImplemented
    }
    
    func getTags() async throws -> [String] {
        throw ClientError.notImplemented
    }
    
    func setTag(hash: String, tag: String) async throws -> Bool {
        throw ClientError.notImplemented
    }
    
    func unsetTag(hash: String, tag: String) async throws -> Bool {
        throw ClientError.notImplemented
    }
    
    func removeTag(tag: String) async throws -> Int {
        throw ClientError.notImplemented
    }
    
    func addTag(tag: String) async throws -> Int {
        throw ClientError.notImplemented
    }
    
    // MARK: - TorrentTrackerActions
    
    func getTrackers(hash: String) async throws -> [Tracker] {
        throw ClientError.notImplemented
    }
    
    func addTrackerURL(hash: String, urls: String) async throws {
        throw ClientError.notImplemented
    }
    
    func editTrackerURL(hash: String, origUrl: String, newURL: String) async throws {
        throw ClientError.notImplemented
    }
    
    func removeTracker(hash: String, url: String) async throws {
        throw ClientError.notImplemented
    }
    
    // MARK: - TorrentSearchActions
    
    func getSearchStart(pattern: String, category: String, plugins: Bool = true) async throws -> SearchStartResult {
        throw ClientError.notImplemented
    }
    
    func getSearchResults(id: Int, limit: Int = 500, offset: Int = 0) async throws -> SearchResponse {
        throw ClientError.notImplemented
    }
    
    func getSearchPlugins() async throws -> [SearchPlugin] {
        throw ClientError.notImplemented
    }
    
    // MARK: - TorrentServerActions
    
    func login(username: String, password: String) async throws {
        let (_, response): (String, HTTPURLResponse) = try await networkClient.sendRequestWithResponse(
            path: "/api/v2/auth/login",
            queryItems: [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password)
            ],
            cookie: nil
        )
        
        if let setCookieHeader = response.value(forHTTPHeaderField: "Set-Cookie") {
            let components = setCookieHeader.split(separator: ";")
            if let firstComponent = components.first {
                let cookieStr = String(firstComponent)
                if cookieStr.contains("SID") {
                    self.cookie = cookieStr
                    return
                }
            }
        }
        
        throw NetworkError.unauthorized
    }
    
    func fetchVersion() async throws -> Version {
        throw ClientError.notImplemented
    }
    
    func getGlobalTransferInfo() async throws -> GlobalTransferInfo {
        throw ClientError.notImplemented
    }
    
    func getMainData(rid: Int = 0) async throws -> MainData {
        throw ClientError.notImplemented
    }
    
    func getPreferences() async throws -> qBitPreferences {
        throw ClientError.notImplemented
    }
}
