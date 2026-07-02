//
//  MockTorrentClient.swift
//  qBitControl
//

import Foundation

class MockTorrentClient: TorrentClientProtocol {
    
    // Static mock helpers
    static let mockVersion = Version(major: 5, minor: 0, patch: 0)
    
    static let mockGlobalTransferInfo = GlobalTransferInfo(
        fetchDate: Date(),
        dlspeed: 1024 * 1024 * 5, // 5 MB/s
        dldata: 1024 * 1024 * 1024 * 10, // 10 GB
        dllimit: 0,
        upspeed: 1024 * 512, // 512 KB/s
        updata: 1024 * 1024 * 1024 * 2, // 2 GB
        uplimit: 0,
        dhtnodes: 234,
        connection_status: "connected"
    )
    
    static let mockCategory = Category(name: "Movies", savePath: "/Downloads/Movies")
    
    static let mockTracker = Tracker(
        url: "udp://tracker.coppersurfer.tk:6969/announce",
        status: 2,
        tier: 0,
        num_peers: 42,
        num_seeds: 18,
        num_leeches: 24,
        num_downloaded: 1500,
        msg: "Working"
    )
    
    static let mockSearchPlugin = SearchPlugin(
        enabled: true,
        fullName: "The Pirate Bay",
        name: "piratebay",
        supportedCategories: [SearchCategory(name: "All", id: "all")],
        url: "https://thepiratebay.org",
        version: "1.2.3"
    )
    
    static func mockPreferences() -> qBitPreferences {
        let json = "{}"
        return try! JSONDecoder().decode(qBitPreferences.self, from: json.data(using: .utf8)!)
    }
    
    init() {}
    
    // MARK: - TorrentTaskActions
    
    func pauseTorrent(hash: String) async throws {}
    func pauseTorrents(hashes: [String]) async throws {}
    func pauseAllTorrents() async throws {}
    
    func resumeTorrent(hash: String) async throws {}
    func resumeTorrents(hashes: [String]) async throws {}
    func resumeAllTorrents() async throws {}
    
    func recheckTorrent(hash: String) async throws {}
    func recheckTorrents(hashes: [String]) async throws {}
    
    func reannounceTorrent(hash: String) async throws {}
    func reannounceTorrents(hashes: [String]) async throws {}
    
    func deleteTorrent(hash: String, deleteFiles: Bool) async throws {}
    func deleteTorrents(hashes: [String], deleteFiles: Bool) async throws {}
    
    func increasePriorityTorrents(hashes: [String]) async throws {}
    func decreasePriorityTorrents(hashes: [String]) async throws {}
    func topPriorityTorrents(hashes: [String]) async throws {}
    func bottomPriorityTorrents(hashes: [String]) async throws {}
    
    func toggleSequentialDownload(hashes: [String]) async throws {}
    func toggleFLPiecesFirst(hashes: [String]) async throws {}
    func setForceStart(hashes: [String], value: Bool) async throws {}
    
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
    ) async throws {}
    
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
    ) async throws {}
    
    // MARK: - TorrentRSSActions
    
    func getRSSFeeds(withDate: Bool = true) async throws -> RSSNode {
        return RSSNode()
    }
    
    func addRSSFeed(url: String, path: String) async throws {}
    func addRSSFolder(path: String) async throws {}
    func addRSSRemoveItem(path: String) async throws {}
    func addRSSRefreshItem(path: String) async throws {}
    func moveRSSItem(itemPath: String, destPath: String) async throws {}
    
    // MARK: - TorrentCategoryTagActions
    
    func getCategories() async throws -> [String: Category] {
        return ["Movies": Self.mockCategory]
    }
    
    func setCategory(hash: String, category: String) async throws {}
    
    func addCategory(category: String, savePath: String?) async throws -> Int {
        return 200
    }
    
    func removeCategory(category: String) async throws -> Int {
        return 200
    }
    
    func getTags() async throws -> [String] {
        return ["tag1", "tag2", "tag3"]
    }
    
    func setTag(hash: String, tag: String) async throws -> Bool {
        return true
    }
    
    func unsetTag(hash: String, tag: String) async throws -> Bool {
        return true
    }
    
    func removeTag(tag: String) async throws -> Int {
        return 200
    }
    
    func addTag(tag: String) async throws -> Int {
        return 200
    }
    
    // MARK: - TorrentTrackerActions
    
    func getTrackers(hash: String) async throws -> [Tracker] {
        return [Self.mockTracker]
    }
    
    func addTrackerURL(hash: String, urls: String) async throws {}
    func editTrackerURL(hash: String, origUrl: String, newURL: String) async throws {}
    func removeTracker(hash: String, url: String) async throws {}
    
    // MARK: - TorrentSearchActions
    
    func getSearchStart(pattern: String, category: String, plugins: Bool = true) async throws -> SearchStartResult {
        return SearchStartResult(id: 1)
    }
    
    func getSearchResults(id: Int, limit: Int = 500, offset: Int = 0) async throws -> SearchResponse {
        return SearchResponse(results: [], status: "Success", total: 0)
    }
    
    func getSearchPlugins() async throws -> [SearchPlugin] {
        return [Self.mockSearchPlugin]
    }
    
    // MARK: - TorrentServerActions
    
    func login(username: String, password: String) async throws {}
    
    func fetchVersion() async throws -> Version {
        return Self.mockVersion
    }
    
    func getGlobalTransferInfo() async throws -> GlobalTransferInfo {
        return Self.mockGlobalTransferInfo
    }
    
    func getMainData(rid: Int = 0) async throws -> MainData {
        return MainData(rid: rid, full_update: true, server_state: nil)
    }
    
    func getPreferences() async throws -> qBitPreferences {
        return Self.mockPreferences()
    }
}
