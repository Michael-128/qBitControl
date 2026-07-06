import XCTest
import SwiftUI
@testable import qBitManager

final class TorrentListHelperViewModelTests: XCTestCase {
    
    @MainActor
    override func setUp() {
        super.setUp()
        qBitData.shared.cacheManager.torrents = [:]
    }
    
    // A clean, subclassed mock client specific to the TorrentListHelperViewModel unit tests
    private class TestTorrentClient: MockTorrentClient {
        var customTorrents: [Torrent]
        
        // Trackers for actions called on client
        var pauseCalledWithHashes: [String]?
        var resumeCalledWithHashes: [String]?
        var deleteCalledWithHash: String?
        var deleteFilesFlag: Bool?
        
        init(torrents: [Torrent]) {
            self.customTorrents = torrents
            super.init()
        }
        
        override func fetchTorrents(
            filter: String?,
            category: String?,
            tag: String?,
            sort: String?,
            reverse: Bool?
        ) async throws -> [Torrent] {
            var results = customTorrents
            
            // 1. Simulate server-side category filtering
            if let category = category {
                results = results.filter { $0.category == category }
            }
            
            // 2. Simulate server-side tag filtering
            if let tag = tag {
                results = results.filter { $0.tags.contains(tag) }
            }
            
            // 3. Simulate server-side state/status filtering
            if let filter = filter, filter != "all" {
                results = results.filter { $0.state == filter }
            }
            
            // 4. Simulate server-side sorting
            if let sort = sort {
                if sort == "name" {
                    results.sort { $0.name < $1.name }
                } else if sort == "size" {
                    results.sort { $0.size < $1.size }
                }
            }
            
            // 5. Simulate server-side reverse ordering
            if let reverse = reverse, reverse {
                results.reverse()
            }
            
            return results
        }
        
        override func pauseTorrents(hashes: [String]) async throws {
            pauseCalledWithHashes = hashes
        }
        
        override func resumeTorrents(hashes: [String]) async throws {
            resumeCalledWithHashes = hashes
        }
        
        override func deleteTorrent(hash: String, deleteFiles: Bool) async throws {
            deleteCalledWithHash = hash
            deleteFilesFlag = deleteFiles
        }
        
        override func deleteTorrents(hashes: [String], deleteFiles: Bool) async throws {
            deleteCalledWithHash = hashes.first
            deleteFilesFlag = deleteFiles
        }
    }
    
    private func getTestTorrents() -> [Torrent] {
        let json = """
        [
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
                "dlspeed": 0,
                "downloaded": 5000000000,
                "downloaded_session": 5000000000,
                "eta": 0,
                "f_l_piece_prio": false,
                "force_start": false,
                "hash": "hash111111111111111111111111111111111111",
                "last_activity": 1600000500,
                "magnet_uri": "",
                "max_ratio": -1.0,
                "max_seeding_time": -1,
                "name": "Ubuntu Linux ISO",
                "num_complete": 100,
                "num_incomplete": 10,
                "num_leechs": 5,
                "num_seeds": 20,
                "priority": 1,
                "progress": 1.0,
                "ratio": 2.0,
                "ratio_limit": -1.0,
                "save_path": "/downloads",
                "seeding_time": 7200,
                "seeding_time_limit": -1,
                "seen_complete": 1600000500,
                "seq_dl": false,
                "size": 5000000000,
                "state": "seeding",
                "super_seeding": false,
                "tags": "linux,distro",
                "time_active": 1000,
                "total_size": 5000000000,
                "tracker": "",
                "up_limit": -1,
                "uploaded": 10000000000,
                "uploaded_session": 1000000000,
                "upspeed": 150000
            },
            {
                "added_on": 1610000000,
                "amount_left": 2000000000,
                "auto_tmm": false,
                "availability": 0.8,
                "category": "books",
                "completed": 0,
                "completion_on": 0,
                "content_path": "/downloads/book1.epub",
                "dl_limit": -1,
                "dlspeed": 500000,
                "downloaded": 100000000,
                "downloaded_session": 100000000,
                "eta": 4000,
                "f_l_piece_prio": false,
                "force_start": false,
                "hash": "hash222222222222222222222222222222222222",
                "last_activity": 1610000100,
                "magnet_uri": "",
                "max_ratio": -1.0,
                "max_seeding_time": -1,
                "name": "Swift Programming Book",
                "num_complete": 10,
                "num_incomplete": 2,
                "num_leechs": 1,
                "num_seeds": 3,
                "priority": 2,
                "progress": 0.05,
                "ratio": 0.0,
                "ratio_limit": -1.0,
                "save_path": "/downloads",
                "seeding_time": 0,
                "seeding_time_limit": -1,
                "seen_complete": 0,
                "seq_dl": false,
                "size": 2000000000,
                "state": "downloading",
                "super_seeding": false,
                "tags": "programming,swift",
                "time_active": 100,
                "total_size": 2000000000,
                "tracker": "",
                "up_limit": -1,
                "uploaded": 0,
                "uploaded_session": 0,
                "upspeed": 0
            }
        ]
        """
        return try! JSONDecoder().decode([Torrent].self, from: json.data(using: .utf8)!)
    }
    
    @MainActor
    func test_initialState_isCorrect() {
        let client = TestTorrentClient(torrents: [])
        let sut = TorrentListHelperViewModel(client: client)
        
        XCTAssertTrue(sut.torrents.isEmpty)
        XCTAssertEqual(sut.searchQuery, "")
        XCTAssertEqual(sut.sort, .name)
        XCTAssertFalse(sut.reverse)
        XCTAssertEqual(sut.filter, .all)
        XCTAssertEqual(sut.category, "All")
        XCTAssertEqual(sut.tag, "All")
        XCTAssertFalse(sut.isTorrentAddView)
        XCTAssertFalse(sut.isSelectionMode)
        XCTAssertTrue(sut.selectedTorrents.isEmpty)
    }
    
    @MainActor
    func test_getTorrents_populatesData() async {
        let mockTorrents = getTestTorrents()
        let client = TestTorrentClient(torrents: mockTorrents)
        let sut = TorrentListHelperViewModel(client: client)
        
        await sut.getTorrents()
        
        XCTAssertEqual(sut.torrents.count, 2)
        XCTAssertEqual(sut.filteredTorrents.count, 2)
    }
    
    @MainActor
    func test_filtering_bySearchQuery() async {
        let mockTorrents = getTestTorrents()
        let client = TestTorrentClient(torrents: mockTorrents)
        let sut = TorrentListHelperViewModel(client: client)
        
        await sut.getTorrents()
        
        // Filter by query matches name "Swift" case-insensitively
        sut.searchQuery = "swift"
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents.count, 1)
        XCTAssertEqual(sut.filteredTorrents.first?.name, "Swift Programming Book")
        
        // Filter by query matches name "Linux"
        sut.searchQuery = "Linux"
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents.count, 1)
        XCTAssertEqual(sut.filteredTorrents.first?.name, "Ubuntu Linux ISO")
    }
    
    @MainActor
    func test_filtering_byCategory() async {
        let mockTorrents = getTestTorrents()
        let client = TestTorrentClient(torrents: mockTorrents)
        let sut = TorrentListHelperViewModel(client: client)
        
        await sut.getTorrents()
        
        sut.category = "books"
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents.count, 1)
        XCTAssertEqual(sut.filteredTorrents.first?.category, "books")
        
        sut.category = "movies"
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents.count, 1)
        XCTAssertEqual(sut.filteredTorrents.first?.category, "movies")
        
        sut.category = "All"
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents.count, 2)
    }
    
    @MainActor
    func test_filtering_byTag() async {
        let mockTorrents = getTestTorrents()
        let client = TestTorrentClient(torrents: mockTorrents)
        let sut = TorrentListHelperViewModel(client: client)
        
        await sut.getTorrents()
        
        sut.tag = "swift"
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents.count, 1)
        XCTAssertEqual(sut.filteredTorrents.first?.name, "Swift Programming Book")
        
        sut.tag = "linux"
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents.count, 1)
        XCTAssertEqual(sut.filteredTorrents.first?.name, "Ubuntu Linux ISO")
        
        sut.tag = "All"
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents.count, 2)
    }
    
    @MainActor
    func test_filtering_byState() async {
        let mockTorrents = getTestTorrents()
        let client = TestTorrentClient(torrents: mockTorrents)
        let sut = TorrentListHelperViewModel(client: client)
        
        await sut.getTorrents()
        
        sut.filter = .seeding
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents.count, 1)
        XCTAssertEqual(sut.filteredTorrents.first?.state, "seeding")
        
        sut.filter = .downloading
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents.count, 1)
        XCTAssertEqual(sut.filteredTorrents.first?.state, "downloading")
    }
    
    @MainActor
    func test_sorting_byNameAndSize() async {
        let mockTorrents = getTestTorrents()
        let client = TestTorrentClient(torrents: mockTorrents)
        let sut = TorrentListHelperViewModel(client: client)
        
        await sut.getTorrents()
        
        // Default sort is "name" (Ubuntu Linux ISO (U) vs Swift Programming Book (S))
        sut.sort = .name
        sut.reverse = false
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents[0].name, "Swift Programming Book")
        XCTAssertEqual(sut.filteredTorrents[1].name, "Ubuntu Linux ISO")
        
        // Reverse sort is name descending
        sut.reverse = true
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents[0].name, "Ubuntu Linux ISO")
        XCTAssertEqual(sut.filteredTorrents[1].name, "Swift Programming Book")
        
        // Sort by size ascending (2GB first, then 5GB)
        sut.sort = .size
        sut.reverse = false
        await sut.getTorrents()
        XCTAssertEqual(sut.filteredTorrents[0].size, 2000000000)
        XCTAssertEqual(sut.filteredTorrents[1].size, 5000000000)
    }
    
    @MainActor
    func test_actions_triggerClientCalls() async {
        let mockTorrents = getTestTorrents()
        let client = TestTorrentClient(torrents: mockTorrents)
        let sut = TorrentListHelperViewModel(client: client)
        
        // 1. Test single pause action
        sut.pauseTorrents(hashes: ["hash111111111111111111111111111111111111"])
        // Wait a tiny fraction for Task to run
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(client.pauseCalledWithHashes, ["hash111111111111111111111111111111111111"])
        
        // 2. Test single resume action
        sut.resumeTorrents(hashes: ["hash222222222222222222222222222222222222"])
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(client.resumeCalledWithHashes, ["hash222222222222222222222222222222222222"])
        
        // 3. Test single delete action (without files)
        sut.deleteTorrents(hashes: ["hash111111111111111111111111111111111111"], deleteFiles: false)
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(client.deleteCalledWithHash, "hash111111111111111111111111111111111111")
        XCTAssertEqual(client.deleteFilesFlag, false)
        
        // 4. Test multi delete selected torrents
        sut.selectedTorrents = [mockTorrents[0].hash, mockTorrents[1].hash]
        sut.deleteSelectedTorrents(isDeleteFiles: true)
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertNotNil(client.deleteCalledWithHash)
        XCTAssertEqual(client.deleteFilesFlag, true)
    }
}
