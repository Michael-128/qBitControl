//
//  TorrentClientProtocol.swift
//  qBitControl
//

import Foundation

// MARK: - TorrentTaskActions
protocol TorrentTaskActions {
    func pauseTorrent(hash: String) async throws
    func pauseTorrents(hashes: [String]) async throws
    func pauseAllTorrents() async throws
    
    func resumeTorrent(hash: String) async throws
    func resumeTorrents(hashes: [String]) async throws
    func resumeAllTorrents() async throws
    
    func recheckTorrent(hash: String) async throws
    func recheckTorrents(hashes: [String]) async throws
    
    func reannounceTorrent(hash: String) async throws
    func reannounceTorrents(hashes: [String]) async throws
    
    func deleteTorrent(hash: String, deleteFiles: Bool) async throws
    func deleteTorrents(hashes: [String], deleteFiles: Bool) async throws
    
    func increasePriorityTorrents(hashes: [String]) async throws
    func decreasePriorityTorrents(hashes: [String]) async throws
    func topPriorityTorrents(hashes: [String]) async throws
    func bottomPriorityTorrents(hashes: [String]) async throws
    
    func toggleSequentialDownload(hashes: [String]) async throws
    func toggleFLPiecesFirst(hashes: [String]) async throws
    func setForceStart(hashes: [String], value: Bool) async throws
    
    func addMagnetTorrent(
        torrent: URLQueryItem,
        savePath: String,
        cookie: String,
        category: String,
        tags: String,
        skipChecking: Bool,
        paused: Bool,
        sequentialDownload: Bool,
        dlLimit: Int,
        upLimit: Int,
        ratioLimit: Float,
        seedingTimeLimit: Int
    ) async throws
    
    func addFileTorrent(
        torrents: [String: Data],
        savePath: String,
        cookie: String,
        category: String,
        tags: String,
        skipChecking: Bool,
        paused: Bool,
        sequentialDownload: Bool,
        dlLimit: Int,
        upLimit: Int,
        ratioLimit: Float,
        seedingTimeLimit: Int
    ) async throws
}

// MARK: - TorrentRSSActions
protocol TorrentRSSActions {
    func getRSSFeeds(withDate: Bool) async throws -> RSSNode
    func addRSSFeed(url: String, path: String) async throws
    func addRSSFolder(path: String) async throws
    func addRSSRemoveItem(path: String) async throws
    func addRSSRefreshItem(path: String) async throws
    func moveRSSItem(itemPath: String, destPath: String) async throws
}

// MARK: - TorrentCategoryTagActions
protocol TorrentCategoryTagActions {
    func getCategories() async throws -> [String: Category]
    func setCategory(hash: String, category: String) async throws
    func addCategory(category: String, savePath: String?) async throws -> Int
    func removeCategory(category: String) async throws -> Int
    
    func getTags() async throws -> [String]
    func setTag(hash: String, tag: String) async throws -> Bool
    func unsetTag(hash: String, tag: String) async throws -> Bool
    func removeTag(tag: String) async throws -> Int
    func addTag(tag: String) async throws -> Int
}

// MARK: - TorrentTrackerActions
protocol TorrentTrackerActions {
    func getTrackers(hash: String) async throws -> [Tracker]
    func addTrackerURL(hash: String, urls: String) async throws
    func editTrackerURL(hash: String, origUrl: String, newURL: String) async throws
    func removeTracker(hash: String, url: String) async throws
}

// MARK: - TorrentSearchActions
protocol TorrentSearchActions {
    func getSearchStart(pattern: String, category: String, plugins: Bool) async throws -> SearchStartResult
    func getSearchResults(id: Int, limit: Int, offset: Int) async throws -> SearchResponse
    func getSearchPlugins() async throws -> [SearchPlugin]
}

// MARK: - TorrentServerActions
protocol TorrentServerActions {
    func login(username: String, password: String) async throws
    func fetchVersion() async throws -> Version
    func getGlobalTransferInfo() async throws -> GlobalTransferInfo
    func getMainData(rid: Int) async throws -> MainData
    func getPreferences() async throws -> qBitPreferences
}

// MARK: - TorrentClientProtocol
typealias TorrentClientProtocol = TorrentTaskActions & TorrentRSSActions & TorrentCategoryTagActions & TorrentTrackerActions & TorrentSearchActions & TorrentServerActions
