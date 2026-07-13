//
//  DemoGuardClient.swift
//  qBitControl
//

import Foundation
import SwiftUI

@MainActor
class DemoGuardClient: TorrentClientProtocol {
    
    private let mock: MockTorrentClient
    
    init(mock: MockTorrentClient = MockTorrentClient()) {
        self.mock = mock
    }
    
    private func block(_ action: String) {
        DemoMode.alertMessage.send("\(action) is not available in Demo Mode.")
    }
    
    // MARK: - TorrentTaskActions (Read)
    
    func fetchTorrents(filter: String?, category: String?, tag: String?, sort: String?, reverse: Bool?) async throws -> [Torrent] {
        return try await mock.fetchTorrents(filter: filter, category: category, tag: tag, sort: sort, reverse: reverse)
    }
    
    func getFiles(hash: String) async throws -> [File] {
        return try await mock.getFiles(hash: hash)
    }
    
    func getPeers(hash: String) async throws -> Peers {
        return try await mock.getPeers(hash: hash)
    }
    
    // MARK: - TorrentTaskActions (Write — Blocked)
    
    func pauseTorrent(hash: String) async throws { block("Pause") }
    func pauseTorrents(hashes: [String]) async throws { block("Pause") }
    func pauseAllTorrents() async throws { block("Pause All") }
    func resumeTorrent(hash: String) async throws { block("Resume") }
    func resumeTorrents(hashes: [String]) async throws { block("Resume") }
    func resumeAllTorrents() async throws { block("Resume All") }
    func recheckTorrent(hash: String) async throws { block("Recheck") }
    func recheckTorrents(hashes: [String]) async throws { block("Recheck") }
    func reannounceTorrent(hash: String) async throws { block("Reannounce") }
    func reannounceTorrents(hashes: [String]) async throws { block("Reannounce") }
    func deleteTorrent(hash: String, deleteFiles: Bool) async throws { block("Delete") }
    func deleteTorrents(hashes: [String], deleteFiles: Bool) async throws { block("Delete") }
    func increasePriorityTorrents(hashes: [String]) async throws { block("Move Up") }
    func decreasePriorityTorrents(hashes: [String]) async throws { block("Move Down") }
    func topPriorityTorrents(hashes: [String]) async throws { block("Move to Top") }
    func bottomPriorityTorrents(hashes: [String]) async throws { block("Move to Bottom") }
    func toggleSequentialDownload(hashes: [String]) async throws { block("Toggle Sequential Download") }
    func toggleFLPiecesFirst(hashes: [String]) async throws { block("Toggle First/Last Pieces") }
    func setForceStart(hashes: [String], value: Bool) async throws { block("Force Start") }
    func setLocation(hashes: [String], location: String) async throws { block("Set Location") }
    func setFilePriority(hash: String, ids: String, priority: Int) async throws { block("Set File Priority") }
    
    func setDownloadLimit(hashes: [String], limit: Int) async throws { block("Set Download Limit") }
    func setUploadLimit(hashes: [String], limit: Int) async throws { block("Set Upload Limit") }
    func setShareLimits(hashes: [String], ratioLimit: Float, seedingTimeLimit: Int, inactiveSeedingTimeLimit: Int, shareLimitAction: ShareLimitAction) async throws { block("Set Share Limits") }
    
    func addMagnetTorrent(torrent: URLQueryItem, savePath: String, cookie: String, category: String, tags: String, skipChecking: Bool, paused: Bool, sequentialDownload: Bool, dlLimit: Int, upLimit: Int, ratioLimit: Float, seedingTimeLimit: Int, shareLimitAction: ShareLimitAction) async throws {
        block("Add Torrent")
    }
    
    func addFileTorrent(torrents: [String : Data], savePath: String, cookie: String, category: String, tags: String, skipChecking: Bool, paused: Bool, sequentialDownload: Bool, dlLimit: Int, upLimit: Int, ratioLimit: Float, seedingTimeLimit: Int, shareLimitAction: ShareLimitAction) async throws {
        block("Add Torrent")
    }
    
    // MARK: - TorrentRSSActions (Read)
    
    func getRSSFeeds(withDate: Bool = true) async throws -> RSSNode {
        return try await mock.getRSSFeeds(withDate: withDate)
    }
    
    // MARK: - TorrentRSSActions (Write — Blocked)
    
    func addRSSFeed(url: String, path: String) async throws { block("Add RSS Feed") }
    func addRSSFolder(path: String) async throws { block("Add RSS Folder") }
    func addRSSRemoveItem(path: String) async throws { block("Remove RSS Item") }
    func addRSSRefreshItem(path: String) async throws { block("Refresh RSS Item") }
    func moveRSSItem(itemPath: String, destPath: String) async throws { block("Move RSS Item") }
    
    // MARK: - TorrentCategoryTagActions (Read)
    
    func getCategories() async throws -> [String : Category] {
        return try await mock.getCategories()
    }
    
    func getTags() async throws -> [String] {
        return try await mock.getTags()
    }
    
    // MARK: - TorrentCategoryTagActions (Write — Blocked)
    
    func setCategory(hash: String, category: String) async throws { block("Set Category") }
    func addCategory(category: String, savePath: String?) async throws -> Int { block("Add Category"); return 200 }
    func removeCategory(category: String) async throws -> Int { block("Remove Category"); return 200 }
    func setTag(hash: String, tag: String) async throws -> Bool { block("Set Tag"); return true }
    func unsetTag(hash: String, tag: String) async throws -> Bool { block("Remove Tag"); return true }
    func removeTag(tag: String) async throws -> Int { block("Remove Tag"); return 200 }
    func addTag(tag: String) async throws -> Int { block("Add Tag"); return 200 }
    
    // MARK: - TorrentTrackerActions (Read)
    
    func getTrackers(hash: String) async throws -> [Tracker] {
        return try await mock.getTrackers(hash: hash)
    }
    
    // MARK: - TorrentTrackerActions (Write — Blocked)
    
    func addTrackerURL(hash: String, urls: String) async throws { block("Add Tracker") }
    func editTrackerURL(hash: String, origUrl: String, newURL: String) async throws { block("Edit Tracker") }
    func removeTracker(hash: String, url: String) async throws { block("Remove Tracker") }
    
    // MARK: - TorrentSearchActions (Read)
    
    func getSearchStart(pattern: String, category: String, plugins: Bool = true) async throws -> SearchStartResult {
        return try await mock.getSearchStart(pattern: pattern, category: category, plugins: plugins)
    }
    
    func getSearchResults(id: Int, limit: Int = 500, offset: Int = 0) async throws -> SearchResponse {
        return try await mock.getSearchResults(id: id, limit: limit, offset: offset)
    }
    
    func getSearchPlugins() async throws -> [SearchPlugin] {
        return try await mock.getSearchPlugins()
    }
    
    // MARK: - TorrentServerActions (Read)
    
    func login(username: String, password: String) async throws {
        try await mock.login(username: username, password: password)
    }
    
    func fetchVersion() async throws -> Version {
        return try await mock.fetchVersion()
    }
    
    func getGlobalTransferInfo() async throws -> GlobalTransferInfo {
        return try await mock.getGlobalTransferInfo()
    }
    
    func getMainData(rid: Int = 0) async throws -> MainData {
        return try await mock.getMainData(rid: rid)
    }
    
    func getPreferences() async throws -> qBitPreferences {
        return try await mock.getPreferences()
    }
    
    func setPreferences(json: String) async throws {
        block("Set Preferences")
    }
}