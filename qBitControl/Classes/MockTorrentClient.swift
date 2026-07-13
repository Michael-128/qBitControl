//
//  MockTorrentClient.swift
//  qBitControl
//

import Foundation

class MockTorrentClient: TorrentClientProtocol {
    
    static let mockVersion = Version(major: 5, minor: 0, patch: 0)
    
    static let mockGlobalTransferInfo = GlobalTransferInfo(
        fetchDate: Date(),
        dlspeed: 1024 * 1024 * 5,
        dldata: 1024 * 1024 * 1024 * 10,
        dllimit: 0,
        upspeed: 1024 * 512,
        updata: 1024 * 1024 * 1024 * 2,
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
        num_downloaded: 500,
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
    
    private let referenceDate: Date
    private var currentRid: Int
    
    init() {
        self.referenceDate = Date()
        self.currentRid = 0
    }
    
    // MARK: - Animated Mock Data Generation
    
    private var elapsed: TimeInterval {
        Date().timeIntervalSince(referenceDate)
    }
    
    private func wave(_ period: Double, min: Double, max: Double, noise: Double = 0.3) -> Int {
        let wave = sin(elapsed * (2 * .pi / period))
        let center = (max + min) / 2
        let amplitude = (max - min) / 2
        let jitter = Double.random(in: 0...1) * noise * amplitude
        return Int(center + wave * amplitude + jitter)
    }
    
    private func generateServerState() -> PartialServerState {
        let dlSpeed = wave(30, min: 0, max: 20_971_520)
        let upSpeed = wave(45, min: 0, max: 6_291_456)
        return PartialServerState(
            alltime_dl: Int64.random(in: 500_000_000_000...1_000_000_000_000),
            alltime_ul: Int64.random(in: 100_000_000_000...300_000_000_000),
            average_time_queue: Int.random(in: 0...5),
            connection_status: "connected",
            dht_nodes: Int.random(in: 200...300),
            dl_info_data: Int64(dlSpeed * 30),
            dl_info_speed: dlSpeed,
            dl_rate_limit: 0,
            free_space_on_disk: Int64.random(in: 50_000_000_000...500_000_000_000),
            global_ratio: String(format: "%.2f", Float.random(in: 0.5...3.0)),
            queued_io_jobs: Int.random(in: 0...3),
            queueing: false,
            read_cache_hits: String(format: "%.1f%%", Float.random(in: 80...99)),
            read_cache_overload: "",
            refresh_interval: 2,
            total_buffers_size: Int.random(in: 1_000...10_000),
            total_peer_connections: Int.random(in: 50...200),
            total_queued_size: Int.random(in: 0...100),
            total_wasted_session: Int64.random(in: 1_000...100_000),
            up_info_data: Int64(upSpeed * 30),
            up_info_speed: upSpeed,
            up_rate_limit: 0,
            use_alt_speed_limits: false,
            use_subcategories: false,
            write_cache_overload: ""
        )
    }
    
    private func generateTorrent(hash: String, name: String, category: String, tags: String,
                                 addedOn: TimeInterval, totalSize: Int64, seedRatio: Float) -> PartialTorrent {
        let t = elapsed
        let now = Int(referenceDate.timeIntervalSince1970) + Int(t)
        
        if hash == "dl_new" {
            let cycle = t.truncatingRemainder(dividingBy: 15)
            let elapsed = Float(cycle) / 15.0
            let prog = min(elapsed, 1.0)
            let completed = Int64(Float(totalSize) * prog)
            let speed = wave(20, min: 512_000, max: 2_048_000)
            return PartialTorrent(
                added_on: now - 600, amount_left: Int(totalSize - completed),
                auto_tmm: false, availability: Float(min(1.0, 0.5 + elapsed)),
                category: category, completed: Int(completed), completion_on: nil,
                content_path: "/Downloads/\(name)", dl_limit: -1, dlspeed: Int64(speed),
                downloaded: completed, downloaded_session: completed,
                eta: max(1, Int(Float(totalSize - completed) / Float(max(speed, 1)))),
                f_l_piece_prio: false, force_start: false,
                last_activity: now, magnet_uri: "magnet:?xt=urn:btih:\(hash)",
                max_ratio: -1.0, max_seeding_time: -1, name: name,
                num_complete: Int.random(in: 10...200), num_incomplete: Int.random(in: 1...20),
                num_leechs: Int.random(in: 1...10), num_seeds: Int.random(in: 10...100),
                priority: 1, progress: prog,
                ratio: totalSize > 0 ? Float(completed) / Float(totalSize) * Float.random(in: 0.5...1.5) : 0,
                ratio_limit: -1.0, save_path: "/downloads/\(category)",
                seeding_time: nil, seeding_time_limit: -1,
                inactive_seeding_time_limit: nil,
                share_limit_action: nil, seen_complete: 0,
                seq_dl: false, size: totalSize, state: prog >= 1.0 ? "uploading" : "downloading",
                super_seeding: false, tags: tags, time_active: Int(t), total_size: totalSize,
                tracker: "udp://tracker.opentrackr.org:1337/announce", up_limit: -1, uploaded: 0,
                uploaded_session: 0, upspeed: 0
            )
        } else if hash == "ck_fedora" {
            let cycle = t.truncatingRemainder(dividingBy: 15) / 15.0
            let prog = Float(cycle)
            let completed = Int64(Float(totalSize) * prog)
            return PartialTorrent(
                added_on: now + Int(addedOn), amount_left: Int(totalSize - completed),
                auto_tmm: false, availability: Float(prog),
                category: category, completed: Int(completed), completion_on: nil,
                content_path: "/Downloads/\(name)",
                dl_limit: -1,
                dlspeed: 0, downloaded: completed, downloaded_session: completed,
                eta: 86_400_000, f_l_piece_prio: false, force_start: false,
                last_activity: now, magnet_uri: "magnet:?xt=urn:btih:\(hash)",
                max_ratio: -1.0, max_seeding_time: -1, name: name,
                num_complete: Int.random(in: 50...500), num_incomplete: 0, num_leechs: 0,
                num_seeds: Int.random(in: 50...300), priority: 1, progress: prog,
                ratio: 0,
                ratio_limit: seedRatio, save_path: "/downloads/\(category)",
                seeding_time: nil, seeding_time_limit: -1,
                inactive_seeding_time_limit: nil,
                share_limit_action: nil,
                seen_complete: now, seq_dl: false, size: totalSize,
                state: "checkingUP",
                super_seeding: false, tags: tags, time_active: Int.random(in: 3600...86400 * 7),
                total_size: totalSize, tracker: "udp://tracker.opentrackr.org:1337/announce",
                up_limit: -1, uploaded: 0, uploaded_session: 0, upspeed: 0
            )
        } else {
            let upSpeed = Int64(wave(15, min: 0, max: 1_048_576))
            let uploaded = Int64(Float(totalSize) * seedRatio * Float.random(in: 0.8...1.2))
            return PartialTorrent(
                added_on: now + Int(addedOn), amount_left: 0,
                auto_tmm: false, availability: 1.0, category: category,
                completed: Int(totalSize), completion_on: now - Int.random(in: 600...3600),
                content_path: "/Downloads/\(name)",
                dl_limit: -1,
                dlspeed: 0, downloaded: totalSize, downloaded_session: totalSize,
                eta: 86_400_000, f_l_piece_prio: false, force_start: false,
                last_activity: now, magnet_uri: "magnet:?xt=urn:btih:\(hash)",
                max_ratio: -1.0, max_seeding_time: -1, name: name,
                num_complete: Int.random(in: 50...500), num_incomplete: 0, num_leechs: 0,
                num_seeds: Int.random(in: 50...300), priority: 1, progress: 1.0,
                ratio: totalSize > 0 ? Float(uploaded) / Float(totalSize) : 0,
                ratio_limit: seedRatio, save_path: "/downloads/\(category)",
                seeding_time: Int.random(in: 3600...86400), seeding_time_limit: -1,
                inactive_seeding_time_limit: nil,
                share_limit_action: nil,
                seen_complete: now, seq_dl: false, size: totalSize,
                state: hash == "sd_debian" ? "uploading" : (upSpeed > 512_000 ? "uploading" : "pausedUP"),
                super_seeding: false, tags: tags, time_active: Int.random(in: 3600...86400 * 7),
                total_size: totalSize, tracker: "udp://tracker.opentrackr.org:1337/announce",
                up_limit: -1, uploaded: uploaded, uploaded_session: uploaded, upspeed: upSpeed
            )
        }
    }
    
    private let mockTorrentDefs: [(hash: String, name: String, category: String, tags: String, addedOn: TimeInterval, totalSize: Int64, ratio: Float)] = [
        ("dl_new",    "Ubuntu 24.04 LTS Desktop", "Linux",  "linux,os",      0,     3_000_000_000, 0),
        ("ck_fedora", "Fedora 41 Workstation",  "Linux",  "linux,fedora", -43200,   2_200_000_000, 0.3),
        ("sd_debian", "Debian 12 NetInstall",      "Linux",  "linux,debian", -3600,   500_000_000, 2.5),
    ]
    
    // MARK: - TorrentTaskActions
    
    func fetchTorrents(
        filter: String?,
        category: String?,
        tag: String?,
        sort: String?,
        reverse: Bool?
    ) async throws -> [Torrent] {
        return mockTorrentDefs.map { def in
            let partial = generateTorrent(hash: def.hash, name: def.name, category: def.category,
                                          tags: def.tags, addedOn: def.addedOn, totalSize: def.totalSize, seedRatio: def.ratio)
            return Torrent(from: partial, hash: def.hash)
        }
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
    func setLocation(hashes: [String], location: String) async throws {}
    
    func setDownloadLimit(hashes: [String], limit: Int) async throws {}
    func setUploadLimit(hashes: [String], limit: Int) async throws {}
    func setShareLimits(hashes: [String], ratioLimit: Float, seedingTimeLimit: Int, inactiveSeedingTimeLimit: Int, shareLimitAction: ShareLimitAction) async throws {}
    
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
        seedingTimeLimit: Int = -1,
        shareLimitAction: ShareLimitAction = .global
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
        seedingTimeLimit: Int = -1,
        shareLimitAction: ShareLimitAction = .global
    ) async throws {}
    
    func getFiles(hash: String) async throws -> [File] {
        return Self.mockFiles
    }
    
    func getPeers(hash: String) async throws -> Peers {
        return Peers(full_update: true, peers: [:])
    }
    
    func setFilePriority(hash: String, ids: String, priority: Int) async throws {}
    
    // MARK: - TorrentRSSActions
    
    func getRSSFeeds(withDate: Bool = true) async throws -> RSSNode {
        let root = RSSNode()
        
        let linuxFeed = RSSFeed(
            url: "https://example.com/linux-isos/rss",
            uid: "001",
            isLoading: false,
            title: "Linux ISOs",
            hasError: false,
            articles: [
                RSSFeed.Article(
                    category: "Linux",
                    title: "Ubuntu 24.04.1 LTS (Noble Numbat)",
                    date: "2026-07-01",
                    link: "https://releases.ubuntu.com/24.04.1",
                    size: "5.8 GiB",
                    torrentURL: "https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-desktop-amd64.iso.torrent",
                    isRead: false
                ),
                RSSFeed.Article(
                    category: "Linux",
                    title: "Fedora 42 Workstation",
                    date: "2026-07-05",
                    link: "https://fedoraproject.org/42",
                    size: "4.2 GiB",
                    torrentURL: "https://torrent.fedoraproject.org/42/Fedora-Workstation-Live-x86_64-42.torrent",
                    isRead: false
                ),
                RSSFeed.Article(
                    category: "Linux",
                    title: "Arch Linux 2026.07.01",
                    date: "2026-07-07",
                    link: "https://archlinux.org/releng/releases/2026.07.01",
                    size: "1.1 GiB",
                    torrentURL: "https://archlinux.org/releng/releases/2026.07.01/torrent",
                    isRead: true
                )
            ]
        )
        root.feeds.append(linuxFeed)
        
        let ossFolder = RSSNode()
        ossFolder.title = "Open-Source Software"
        ossFolder.parent = root
        
        let ossFeed = RSSFeed(
            url: "https://example.com/opensource/rss",
            uid: "003",
            isLoading: false,
            title: "Open Source",
            hasError: false,
            articles: [
                RSSFeed.Article(
                    category: "Software",
                    title: "qBittorrent v5.1.0",
                    date: "2026-07-03",
                    link: "https://www.qbittorrent.org",
                    size: "48 MiB",
                    torrentURL: "https://www.qbittorrent.org/download.torrent",
                    isRead: false
                ),
                RSSFeed.Article(
                    category: "Software",
                    title: "LibreOffice 24.8.0",
                    date: "2026-06-28",
                    link: "https://www.libreoffice.org",
                    size: "352 MiB",
                    torrentURL: "https://www.libreoffice.org/download.torrent",
                    isRead: true
                ),
                RSSFeed.Article(
                    category: "Software",
                    title: "Blender 4.4 LTS",
                    date: "2026-06-15",
                    link: "https://www.blender.org",
                    size: "420 MiB",
                    torrentURL: "https://www.blender.org/download.torrent",
                    isRead: false
                )
            ]
        )
        ossFolder.feeds.append(ossFeed)
        root.nodes.append(ossFolder)
        
        return root
    }
    
    func addRSSFeed(url: String, path: String) async throws {}
    func addRSSFolder(path: String) async throws {}
    func addRSSRemoveItem(path: String) async throws {}
    func addRSSRefreshItem(path: String) async throws {}
    func moveRSSItem(itemPath: String, destPath: String) async throws {}
    
    // MARK: - TorrentCategoryTagActions
    
    func getCategories() async throws -> [String: Category] {
        return ["Linux": Category(name: "Linux", savePath: "/downloads/Linux"),
                "Movies": Self.mockCategory,
                "Arch": Category(name: "Arch", savePath: "/downloads/Arch")]
    }
    
    func setCategory(hash: String, category: String) async throws {}
    
    func addCategory(category: String, savePath: String?) async throws -> Int {
        return 200
    }
    
    func removeCategory(category: String) async throws -> Int {
        return 200
    }
    
    func getTags() async throws -> [String] {
        return ["linux", "os", "video", "4k", "arch", "debian"]
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
        let isFullUpdate = currentRid == 0
        currentRid = rid + 1
        
        var torrents: [String: PartialTorrent] = [:]
        for def in mockTorrentDefs {
            torrents[def.hash] = generateTorrent(
                hash: def.hash, name: def.name, category: def.category,
                tags: def.tags, addedOn: def.addedOn, totalSize: def.totalSize, seedRatio: def.ratio
            )
        }
        
        return MainData(
            rid: currentRid,
            full_update: isFullUpdate,
            server_state: generateServerState(),
            torrents: torrents,
            torrents_removed: nil,
            categories: nil,
            categories_removed: nil,
            tags: nil,
            tags_removed: nil
        )
    }
    
    func getPreferences() async throws -> qBitPreferences {
        return Self.mockPreferences()
    }
}