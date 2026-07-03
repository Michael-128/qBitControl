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
    
    static let mockFile = File(
        index: 0,
        name: "debian-12.0.0-amd64-netinst.iso",
        size: 397410304,
        progress: 1.0,
        priority: 1,
        is_seed: true,
        piece_range: [0, 100],
        availability: 1.0
    )
    
    static let mockFiles = [mockFile]
    
    static func mockPreferences() -> qBitPreferences {
        let json = "{}"
        return try! JSONDecoder().decode(qBitPreferences.self, from: json.data(using: .utf8)!)
    }
    
    static let mockTorrents: [Torrent] = {
        let json = """
        [
            {
                "added_on": 1682347623,
                "amount_left": 0,
                "auto_tmm": false,
                "availability": 1.0,
                "category": "Movies",
                "completed": 1000000000,
                "completion_on": 1682348000,
                "content_path": "/Downloads/Movies/ubuntu.iso",
                "dl_limit": -1,
                "dlspeed": 0,
                "downloaded": 1000000000,
                "downloaded_session": 1000000000,
                "eta": 8640000,
                "f_l_piece_prio": false,
                "force_start": false,
                "hash": "1a2b3c4d5e6f7g8h9i0j",
                "last_activity": 1682348000,
                "magnet_uri": "magnet:?xt=urn:btih:1a2b3c4d5e6f7g8h9i0j",
                "max_ratio": -1.0,
                "max_seeding_time": -1,
                "name": "Ubuntu 22.04 LTS Desktop",
                "num_complete": 150,
                "num_incomplete": 5,
                "num_leechs": 5,
                "num_seeds": 150,
                "priority": 1,
                "progress": 1.0,
                "ratio": 1.5,
                "ratio_limit": -1.0,
                "save_path": "/Downloads/Movies",
                "seeding_time": 3600,
                "seeding_time_limit": -1,
                "seen_complete": 1682348000,
                "seq_dl": false,
                "size": 1000000000,
                "state": "seeding",
                "super_seeding": false,
                "tags": "linux,os",
                "time_active": 7200,
                "total_size": 1000000000,
                "tracker": "udp://tracker.opentrackr.org:1337/announce",
                "up_limit": -1,
                "uploaded": 1500000000,
                "uploaded_session": 1500000000,
                "upspeed": 512000
            },
            {
                "added_on": 1682349000,
                "amount_left": 500000000,
                "auto_tmm": false,
                "availability": 0.8,
                "category": "All",
                "completed": 500000000,
                "completion_on": 0,
                "content_path": "/Downloads/debian.iso",
                "dl_limit": -1,
                "dlspeed": 1024000,
                "downloaded": 500000000,
                "downloaded_session": 500000000,
                "eta": 488,
                "f_l_piece_prio": false,
                "force_start": false,
                "hash": "2b3c4d5e6f7g8h9i0j1a",
                "last_activity": 1682349500,
                "magnet_uri": "magnet:?xt=urn:btih:2b3c4d5e6f7g8h9i0j1a",
                "max_ratio": -1.0,
                "max_seeding_time": -1,
                "name": "Debian GNU/Linux 12 NetInstall",
                "num_complete": 80,
                "num_incomplete": 12,
                "num_leechs": 12,
                "num_seeds": 80,
                "priority": 2,
                "progress": 0.5,
                "ratio": 0.0,
                "ratio_limit": -1.0,
                "save_path": "/Downloads",
                "seeding_time": 0,
                "seeding_time_limit": -1,
                "seen_complete": 0,
                "seq_dl": false,
                "size": 1000000000,
                "state": "downloading",
                "super_seeding": false,
                "tags": "linux,debian",
                "time_active": 500,
                "total_size": 1000000000,
                "tracker": "udp://tracker.opentrackr.org:1337/announce",
                "up_limit": -1,
                "uploaded": 0,
                "uploaded_session": 0,
                "upspeed": 0
            }
        ]
        """
        return try! JSONDecoder().decode([Torrent].self, from: json.data(using: .utf8)!)
    }()
    
    init() {}
    
    // MARK: - TorrentTaskActions
    
    func fetchTorrents(
        filter: String?,
        category: String?,
        tag: String?,
        sort: String?,
        reverse: Bool?
    ) async throws -> [Torrent] {
        return Self.mockTorrents
    }
    
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
    
    func getFiles(hash: String) async throws -> [File] {
        return Self.mockFiles
    }
    
    func setFilePriority(hash: String, ids: String, priority: Int) async throws {}
    
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
