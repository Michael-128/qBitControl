//
//  qBittorrentClient.swift
//  qBitControl
//

import Foundation

class qBittorrentClient: TorrentClientProtocol {
    private let networkClient: NetworkClient
    private(set) var cookie: String?
    private var version = Version(major: 0, minor: 0, patch: 0)
    
    enum ClientError: Error {
        case notImplemented
    }
    
    init(networkClient: NetworkClient, cookie: String? = nil) {
        self.networkClient = networkClient
        self.cookie = cookie
        
        // Prefetch version in background if cookie is already present
        if cookie != nil {
            Task {
                do {
                    self.version = try await fetchVersion()
                } catch {
                    print("Failed to prefetch version: \(error)")
                }
            }
        }
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
        let suffix = self.version.major == 5 ? "stop" : "pause"
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/\(suffix)",
            queryItems: [URLQueryItem(name: "hashes", value: hash)],
            cookie: self.cookie
        )
    }
    
    func pauseTorrents(hashes: [String]) async throws {
        let suffix = self.version.major == 5 ? "stop" : "pause"
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/\(suffix)",
            queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))],
            cookie: self.cookie
        )
    }
    
    func pauseAllTorrents() async throws {
        try await pauseTorrent(hash: "all")
    }
    
    func resumeTorrent(hash: String) async throws {
        let suffix = self.version.major == 5 ? "start" : "resume"
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/\(suffix)",
            queryItems: [URLQueryItem(name: "hashes", value: hash)],
            cookie: self.cookie
        )
    }
    
    func resumeTorrents(hashes: [String]) async throws {
        let suffix = self.version.major == 5 ? "start" : "resume"
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/\(suffix)",
            queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))],
            cookie: self.cookie
        )
    }
    
    func resumeAllTorrents() async throws {
        try await resumeTorrent(hash: "all")
    }
    
    func recheckTorrent(hash: String) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/recheck",
            queryItems: [URLQueryItem(name: "hashes", value: hash)],
            cookie: self.cookie
        )
    }
    
    func recheckTorrents(hashes: [String]) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/recheck",
            queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))],
            cookie: self.cookie
        )
    }
    
    func reannounceTorrent(hash: String) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/reannounce",
            queryItems: [URLQueryItem(name: "hashes", value: hash)],
            cookie: self.cookie
        )
    }
    
    func reannounceTorrents(hashes: [String]) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/reannounce",
            queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))],
            cookie: self.cookie
        )
    }
    
    func deleteTorrent(hash: String, deleteFiles: Bool) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/delete",
            queryItems: [
                URLQueryItem(name: "hashes", value: hash),
                URLQueryItem(name: "deleteFiles", value: String(deleteFiles))
            ],
            cookie: self.cookie
        )
    }
    
    func deleteTorrents(hashes: [String], deleteFiles: Bool) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/delete",
            queryItems: [
                URLQueryItem(name: "hashes", value: hashes.joined(separator: "|")),
                URLQueryItem(name: "deleteFiles", value: String(deleteFiles))
            ],
            cookie: self.cookie
        )
    }
    
    func increasePriorityTorrents(hashes: [String]) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/increasePrio",
            queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))],
            cookie: self.cookie
        )
    }
    
    func decreasePriorityTorrents(hashes: [String]) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/decreasePrio",
            queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))],
            cookie: self.cookie
        )
    }
    
    func topPriorityTorrents(hashes: [String]) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/topPrio",
            queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))],
            cookie: self.cookie
        )
    }
    
    func bottomPriorityTorrents(hashes: [String]) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/bottomPrio",
            queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))],
            cookie: self.cookie
        )
    }
    
    func toggleSequentialDownload(hashes: [String]) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/toggleSequentialDownload",
            queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))],
            cookie: self.cookie
        )
    }
    
    func toggleFLPiecesFirst(hashes: [String]) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/toggleFirstLastPiecePrio",
            queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))],
            cookie: self.cookie
        )
    }
    
    func setForceStart(hashes: [String], value: Bool) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/setForceStart",
            queryItems: [
                URLQueryItem(name: "hashes", value: hashes.joined(separator: "|")),
                URLQueryItem(name: "value", value: String(value))
            ],
            cookie: self.cookie
        )
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
        var queryItems: [URLQueryItem] = [torrent]
        if savePath != "" { queryItems.append(URLQueryItem(name: "savepath", value: savePath)) }
        if cookie != "" { queryItems.append(URLQueryItem(name: "cookie", value: cookie)) }
        if category != "" { queryItems.append(URLQueryItem(name: "category", value: category)) }
        if tags != "" { queryItems.append(URLQueryItem(name: "tags", value: tags)) }
        if skipChecking { queryItems.append(URLQueryItem(name: "skip_checking", value: "true")) }
        if paused {
            let suffix = self.version.major == 5 ? "stopped" : "paused"
            queryItems.append(URLQueryItem(name: suffix, value: "true"))
        }
        if dlLimit > 0 { queryItems.append(URLQueryItem(name: "dlLimit", value: "\(dlLimit)")) }
        if upLimit > 0 { queryItems.append(URLQueryItem(name: "upLimit", value: "\(upLimit)")) }
        if ratioLimit > 0 { queryItems.append(URLQueryItem(name: "ratioLimit", value: "\(ratioLimit)")) }
        if seedingTimeLimit > 0 { queryItems.append(URLQueryItem(name: "seedingTimeLimit", value: "\(seedingTimeLimit)")) }
        if sequentialDownload { queryItems.append(URLQueryItem(name: "sequentialDownload", value: "true")) }
        
        let _: String = try await networkClient.sendRequest(path: "/api/v2/torrents/add", queryItems: queryItems, cookie: self.cookie)
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
        var params: [String: String] = [:]
        if savePath != "" { params["savepath"] = savePath }
        if cookie != "" { params["cookie"] = cookie }
        if category != "" { params["category"] = category }
        if tags != "" { params["tags"] = tags }
        if skipChecking { params["skip_checking"] = "true" }
        if paused {
            let suffix = self.version.major == 5 ? "stopped" : "paused"
            params[suffix] = "true"
        }
        if dlLimit > 0 { params["dlLimit"] = "\(dlLimit)" }
        if upLimit > 0 { params["upLimit"] = "\(upLimit)" }
        if ratioLimit > 0 { params["ratioLimit"] = "\(ratioLimit)" }
        if seedingTimeLimit > 0 { params["seedingTimeLimit"] = "\(seedingTimeLimit)" }
        if sequentialDownload { params["sequentialDownload"] = "true" }

        let _: String = try await networkClient.uploadMultipart(
            path: "/api/v2/torrents/add",
            files: torrents,
            params: params,
            cookie: self.cookie
        )
    }
    
    func getFiles(hash: String) async throws -> [File] {
        return try await networkClient.sendRequest(
            path: "/api/v2/torrents/files",
            queryItems: [URLQueryItem(name: "hash", value: hash)],
            cookie: self.cookie
        )
    }
    
    func setFilePriority(hash: String, ids: String, priority: Int) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/filePrio",
            queryItems: [
                URLQueryItem(name: "hash", value: hash),
                URLQueryItem(name: "id", value: ids),
                URLQueryItem(name: "priority", value: String(priority))
            ],
            cookie: self.cookie
        )
    }
    
    // MARK: - TorrentRSSActions
    
    func getRSSFeeds(withDate: Bool = true) async throws -> RSSNode {
        return try await networkClient.sendRequest(
            path: "/api/v2/rss/items",
            queryItems: [URLQueryItem(name: "withData", value: String(withDate))],
            cookie: self.cookie
        )
    }
    
    func addRSSFeed(url: String, path: String) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/rss/addFeed",
            queryItems: [
                URLQueryItem(name: "url", value: url),
                URLQueryItem(name: "path", value: path)
            ],
            cookie: self.cookie
        )
    }
    
    func addRSSFolder(path: String) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/rss/addFolder",
            queryItems: [URLQueryItem(name: "path", value: path)],
            cookie: self.cookie
        )
    }
    
    func addRSSRemoveItem(path: String) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/rss/removeItem",
            queryItems: [URLQueryItem(name: "path", value: path)],
            cookie: self.cookie
        )
    }
    
    func addRSSRefreshItem(path: String) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/rss/refreshItem",
            queryItems: [URLQueryItem(name: "path", value: path)],
            cookie: self.cookie
        )
    }
    
    func moveRSSItem(itemPath: String, destPath: String) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/rss/moveItem",
            queryItems: [
                URLQueryItem(name: "itemPath", value: itemPath),
                URLQueryItem(name: "destPath", value: destPath)
            ],
            cookie: self.cookie
        )
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
        return try await networkClient.sendRequest(
            path: "/api/v2/torrents/trackers",
            queryItems: [URLQueryItem(name: "hash", value: hash)],
            cookie: self.cookie
        )
    }
    
    func addTrackerURL(hash: String, urls: String) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/addTrackers",
            queryItems: [
                URLQueryItem(name: "hash", value: hash),
                URLQueryItem(name: "urls", value: urls)
            ],
            cookie: self.cookie
        )
    }
    
    func editTrackerURL(hash: String, origUrl: String, newURL: String) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/editTracker",
            queryItems: [
                URLQueryItem(name: "hash", value: hash),
                URLQueryItem(name: "origUrl", value: origUrl),
                URLQueryItem(name: "newUrl", value: newURL)
            ],
            cookie: self.cookie
        )
    }
    
    func removeTracker(hash: String, url: String) async throws {
        let _: String = try await networkClient.sendRequest(
            path: "/api/v2/torrents/removeTrackers",
            queryItems: [
                URLQueryItem(name: "hash", value: hash),
                URLQueryItem(name: "urls", value: url)
            ],
            cookie: self.cookie
        )
    }
    
    // MARK: - TorrentSearchActions
    
    func getSearchStart(pattern: String, category: String, plugins: Bool = true) async throws -> SearchStartResult {
        return try await networkClient.sendRequest(
            path: "/api/v2/search/start",
            queryItems: [
                URLQueryItem(name: "pattern", value: pattern),
                URLQueryItem(name: "category", value: category),
                URLQueryItem(name: "plugins", value: String(plugins))
            ],
            cookie: self.cookie
        )
    }
    
    func getSearchResults(id: Int, limit: Int = 500, offset: Int = 0) async throws -> SearchResponse {
        return try await networkClient.sendRequest(
            path: "/api/v2/search/results",
            queryItems: [
                URLQueryItem(name: "id", value: String(id)),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset))
            ],
            cookie: self.cookie
        )
    }
    
    func getSearchPlugins() async throws -> [SearchPlugin] {
        return try await networkClient.sendRequest(
            path: "/api/v2/search/plugins",
            queryItems: [],
            cookie: self.cookie
        )
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
                    
                    // Fetch and store version after successful login
                    do {
                        self.version = try await fetchVersion()
                    } catch {
                        print("Failed to fetch version on login: \(error)")
                    }
                    return
                }
            }
        }
        
        throw NetworkError.unauthorized
    }
    
    func fetchVersion() async throws -> Version {
        let versionStr: String = try await networkClient.sendRequest(
            path: "/api/v2/app/version",
            queryItems: [],
            cookie: self.cookie
        )
        let cleaned = versionStr.hasPrefix("v") ? String(versionStr.dropFirst()) : versionStr
        let components = cleaned.split(separator: ".").compactMap { Int($0) }
        let major = components.count > 0 ? components[0] : 0
        let minor = components.count > 1 ? components[1] : 0
        let patch = components.count > 2 ? components[2] : 0
        return Version(major: major, minor: minor, patch: patch)
    }
    
    func getGlobalTransferInfo() async throws -> GlobalTransferInfo {
        return try await networkClient.sendRequest(
            path: "/api/v2/transfer/info",
            queryItems: [],
            cookie: self.cookie
        )
    }
    
    func getMainData(rid: Int = 0) async throws -> MainData {
        return try await networkClient.sendRequest(
            path: "/api/v2/sync/maindata",
            queryItems: [URLQueryItem(name: "rid", value: "\(rid)")],
            cookie: self.cookie
        )
    }
    
    func getPreferences() async throws -> qBitPreferences {
        return try await networkClient.sendRequest(
            path: "/api/v2/app/preferences",
            queryItems: [],
            cookie: self.cookie
        )
    }
}
