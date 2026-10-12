import XCTest
import Combine
@testable import qBitManager

final class TorrentCacheManagerTests: XCTestCase {
    
    private func createTorrent(hash: String, name: String, progress: Float, dlspeed: Int64) -> Torrent {
        let json = """
        {
            "added_on": 1600000000,
            "amount_left": 0,
            "auto_tmm": false,
            "availability": 1.0,
            "category": "movies",
            "completed": 5000000000,
            "completion_on": 1600000500,
            "content_path": "/downloads/movie1.mkv",
            "dl_limit": -1,
            "dlspeed": \(dlspeed),
            "downloaded": 5000000000,
            "downloaded_session": 5000000000,
            "eta": 0,
            "f_l_piece_prio": false,
            "force_start": false,
            "hash": "\(hash)",
            "last_activity": 1600000500,
            "magnet_uri": "",
            "max_ratio": -1.0,
            "max_seeding_time": -1,
            "name": "\(name)",
            "num_complete": 100,
            "num_incomplete": 10,
            "num_leechs": 5,
            "num_seeds": 20,
            "priority": 1,
            "progress": \(progress),
            "ratio": 2.0,
            "ratio_limit": -1.0,
            "save_path": "/downloads",
            "seeding_time": 7200,
            "seeding_time_limit": -1,
            "inactive_seeding_time_limit": -2,
            "seen_complete": 1600000500,
            "seq_dl": false,
            "size": 5000000000,
            "state": "uploading",
            "super_seeding": false,
            "tags": "linux,distro",
            "time_active": 1000,
            "total_size": 5000000000,
            "tracker": "",
            "up_limit": -1,
            "uploaded": 10000000000,
            "uploaded_session": 1000000000,
            "upspeed": 150000
        }
        """
        return try! JSONDecoder().decode(Torrent.self, from: json.data(using: .utf8)!)
    }
    
    private func createPartialTorrent(progress: Float? = nil, dlspeed: Int64? = nil, name: String? = nil) -> PartialTorrent {
        var dict: [String: Any] = [:]
        if let progress = progress { dict["progress"] = progress }
        if let dlspeed = dlspeed { dict["dlspeed"] = dlspeed }
        if let name = name { dict["name"] = name }
        
        let data = try! JSONSerialization.data(withJSONObject: dict)
        return try! JSONDecoder().decode(PartialTorrent.self, from: data)
    }
    
    @MainActor
    func test_maindata_mergesDeltasCorrectly() {
        let sut = TorrentCacheManager()
        
        // Setup initial cache
        let initialTorrent = createTorrent(hash: "hash123", name: "Ubuntu", progress: 0.1, dlspeed: 0)
        sut.torrents = ["hash123": initialTorrent]
        
        // Create maindata payload with partial torrent diff
        let partial = createPartialTorrent(progress: 0.25, dlspeed: 1000)
        let mainData = MainData(
            rid: 1,
            full_update: false,
            server_state: nil,
            torrents: ["hash123": partial],
            torrents_removed: nil,
            categories: nil,
            categories_removed: nil,
            tags: nil,
            tags_removed: nil
        )
        
        sut.merge(mainData: mainData)
        
        // Assertions
        XCTAssertEqual(sut.torrents.count, 1)
        guard let updated = sut.torrents["hash123"] else {
            XCTFail("Torrent hash123 missing from cache")
            return
        }
        XCTAssertEqual(updated.progress, 0.25)
        XCTAssertEqual(updated.dlspeed, 1000)
        XCTAssertEqual(updated.name, "Ubuntu") // Verify name is preserved
    }
    
    @MainActor
    func test_maindata_removesTorrentsCorrectly() {
        let sut = TorrentCacheManager()
        
        // Setup initial cache
        let torrentA = createTorrent(hash: "hashA", name: "Ubuntu", progress: 0.1, dlspeed: 0)
        let torrentB = createTorrent(hash: "hashB", name: "Debian", progress: 0.5, dlspeed: 0)
        sut.torrents = ["hashA": torrentA, "hashB": torrentB]
        
        let mainData = MainData(
            rid: 1,
            full_update: false,
            server_state: nil,
            torrents: nil,
            torrents_removed: ["hashA"],
            categories: nil,
            categories_removed: nil,
            tags: nil,
            tags_removed: nil
        )
        
        sut.merge(mainData: mainData)
        
        XCTAssertEqual(sut.torrents.count, 1)
        XCTAssertNil(sut.torrents["hashA"])
        XCTAssertNotNil(sut.torrents["hashB"])
    }
    
    @MainActor
    func test_maindata_fullUpdateClearsCache() {
        let sut = TorrentCacheManager()
        
        // Setup initial cache
        let torrentA = createTorrent(hash: "hashA", name: "Ubuntu", progress: 0.1, dlspeed: 0)
        sut.torrents = ["hashA": torrentA]
        
        // Full update containing only a new torrent (hashB)
        let torrentB = createTorrent(hash: "hashB", name: "Debian", progress: 0.8, dlspeed: 500)
        
        // Convert a full Torrent to a JSON and decode it as a PartialTorrent for full update mock
        let torrentBData = try! JSONEncoder().encode(torrentB)
        let partialB = try! JSONDecoder().decode(PartialTorrent.self, from: torrentBData)
        
        let mainData = MainData(
            rid: 1,
            full_update: true,
            server_state: nil,
            torrents: ["hashB": partialB],
            torrents_removed: nil,
            categories: nil,
            categories_removed: nil,
            tags: nil,
            tags_removed: nil
        )
        
        sut.merge(mainData: mainData)
        
        XCTAssertEqual(sut.torrents.count, 1)
        XCTAssertNil(sut.torrents["hashA"])
        XCTAssertNotNil(sut.torrents["hashB"])
    }

    @MainActor
    func test_optimisticUpdate_publishesOneFinalSnapshot() {
        let sut = TorrentCacheManager()
        let torrentA = createTorrent(hash: "hashA", name: "Ubuntu", progress: 0.1, dlspeed: 0)
        let torrentB = createTorrent(hash: "hashB", name: "Debian", progress: 0.5, dlspeed: 0)
        let untouched = createTorrent(hash: "hashC", name: "Fedora", progress: 0.8, dlspeed: 0)
        sut.torrents = ["hashA": torrentA, "hashB": torrentB, "hashC": untouched]

        var snapshots: [[String: Torrent]] = []
        let subscription = sut.$torrents.dropFirst().sink { snapshots.append($0) }
        defer { subscription.cancel() }
        var mutationOrder: [String] = []

        sut.updateTorrentsOptimistically(hashes: ["hashA", "missing", "hashB", "hashA"]) { torrent in
            mutationOrder.append(torrent.hash)
            torrent.priority += 1
        }

        var expectedA = torrentA
        expectedA.priority = 3
        var expectedB = torrentB
        expectedB.priority = 2
        let expected = ["hashA": expectedA, "hashB": expectedB, "hashC": untouched]
        XCTAssertEqual(mutationOrder, ["hashA", "hashB", "hashA"])
        XCTAssertEqual(snapshots, [expected])
        XCTAssertEqual(sut.torrents, expected)
    }

    @MainActor
    func test_optimisticUpdate_publishesOnlyForMatchingHashes() {
        let sut = TorrentCacheManager()
        let torrent = createTorrent(hash: "hashA", name: "Ubuntu", progress: 0.1, dlspeed: 0)
        sut.torrents = ["hashA": torrent]

        var snapshots: [[String: Torrent]] = []
        let subscription = sut.$torrents.dropFirst().sink { snapshots.append($0) }
        defer { subscription.cancel() }

        for hashes in [[], ["missing"]] {
            sut.updateTorrentsOptimistically(hashes: hashes) { _ in
                XCTFail("Mutation should not run without a matching torrent")
            }
            XCTAssertTrue(snapshots.isEmpty)
            XCTAssertEqual(sut.torrents, ["hashA": torrent])
        }

        sut.updateTorrentsOptimistically(hashes: ["hashA"]) { _ in }
        XCTAssertEqual(snapshots, [["hashA": torrent]])
        XCTAssertEqual(sut.torrents, ["hashA": torrent])
    }

    @MainActor
    func test_optimisticDelete_publishesOneFinalSnapshot() {
        let sut = TorrentCacheManager()
        let torrentA = createTorrent(hash: "hashA", name: "Ubuntu", progress: 0.1, dlspeed: 0)
        let torrentB = createTorrent(hash: "hashB", name: "Debian", progress: 0.5, dlspeed: 0)
        let untouched = createTorrent(hash: "hashC", name: "Fedora", progress: 0.8, dlspeed: 0)
        sut.torrents = ["hashA": torrentA, "hashB": torrentB, "hashC": untouched]

        var snapshots: [[String: Torrent]] = []
        let subscription = sut.$torrents.dropFirst().sink { snapshots.append($0) }
        defer { subscription.cancel() }

        sut.deleteTorrentsOptimistically(hashes: ["hashA", "missing", "hashB", "hashA"])

        XCTAssertEqual(snapshots, [["hashC": untouched]])
        XCTAssertEqual(sut.torrents, ["hashC": untouched])
    }

    @MainActor
    func test_optimisticDelete_publishesOnlyForNonemptyInput() {
        let sut = TorrentCacheManager()
        let torrent = createTorrent(hash: "hashA", name: "Ubuntu", progress: 0.1, dlspeed: 0)
        sut.torrents = ["hashA": torrent]

        var snapshots: [[String: Torrent]] = []
        let subscription = sut.$torrents.dropFirst().sink { snapshots.append($0) }
        defer { subscription.cancel() }

        sut.deleteTorrentsOptimistically(hashes: [])
        XCTAssertTrue(snapshots.isEmpty)

        sut.deleteTorrentsOptimistically(hashes: ["missingA", "missingB"])
        XCTAssertEqual(snapshots, [["hashA": torrent]])
        XCTAssertEqual(sut.torrents, ["hashA": torrent])
    }

    @MainActor
    func test_optimisticUpdate_locksOnlyExistingHashes() {
        let sut = TorrentCacheManager()
        sut.torrents = [
            "hashA": createTorrent(hash: "hashA", name: "Ubuntu", progress: 0.1, dlspeed: 0),
            "hashB": createTorrent(hash: "hashB", name: "Debian", progress: 0.5, dlspeed: 0)
        ]

        let mainData = MainData(
            rid: 1,
            full_update: false,
            server_state: nil,
            torrents: [
                "hashA": createPartialTorrent(name: "Server A"),
                "hashB": createPartialTorrent(name: "Server B"),
                "missing": createPartialTorrent(name: "New torrent")
            ],
            torrents_removed: nil,
            categories: nil,
            categories_removed: nil,
            tags: nil,
            tags_removed: nil
        )
        sut.updateTorrentsOptimistically(hashes: ["hashA", "missing"]) { torrent in
            torrent.name = "Optimistic"
        }
        sut.merge(mainData: mainData)

        XCTAssertEqual(sut.torrents["hashA"]?.name, "Optimistic")
        XCTAssertEqual(sut.torrents["hashB"]?.name, "Server B")
        XCTAssertEqual(sut.torrents["missing"]?.name, "New torrent")
    }

    @MainActor
    func test_optimisticDelete_locksEveryRequestedHash() {
        let sut = TorrentCacheManager()
        sut.torrents = [
            "hashA": createTorrent(hash: "hashA", name: "Ubuntu", progress: 0.1, dlspeed: 0),
            "hashB": createTorrent(hash: "hashB", name: "Debian", progress: 0.5, dlspeed: 0)
        ]

        let mainData = MainData(
            rid: 1,
            full_update: false,
            server_state: nil,
            torrents: [
                "hashA": createPartialTorrent(name: "Server A"),
                "hashB": createPartialTorrent(name: "Server B"),
                "missing": createPartialTorrent(name: "New torrent")
            ],
            torrents_removed: nil,
            categories: nil,
            categories_removed: nil,
            tags: nil,
            tags_removed: nil
        )
        sut.deleteTorrentsOptimistically(hashes: ["hashA", "missing"])
        sut.merge(mainData: mainData)

        XCTAssertNil(sut.torrents["hashA"])
        XCTAssertEqual(sut.torrents["hashB"]?.name, "Server B")
        XCTAssertNil(sut.torrents["missing"])
    }
}
