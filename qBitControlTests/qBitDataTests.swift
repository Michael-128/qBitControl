import XCTest
@testable import qBitManager

final class qBitDataTests: XCTestCase {
    
    private class MockDelayClient: MockTorrentClient {
        var fetchCount = 0
        var delayNanoseconds: UInt64 = 50_000_000 // 50 milliseconds
        var shouldThrow = false
        
        override func getMainData(rid: Int = 0) async throws -> MainData {
            fetchCount += 1
            try await Task.sleep(nanoseconds: delayNanoseconds)
            if shouldThrow {
                throw NetworkError.timeout
            }
            return MainData(
                rid: rid,
                full_update: true,
                server_state: nil,
                torrents: nil,
                torrents_removed: nil,
                categories: nil,
                categories_removed: nil,
                tags: nil,
                tags_removed: nil
            )
        }
    }
    
    @MainActor
    override func setUp() {
        super.setUp()
        qBitData.shared.connectionStatus = .connected
        qBitData.shared.stopPolling()
        ServersHelper.shared.client = nil
        ServersHelper.shared.isLoggedIn = false
    }
    
    @MainActor
    override func tearDown() {
        ServersHelper.shared.client = nil
        ServersHelper.shared.isLoggedIn = false
        super.tearDown()
    }
    
    @MainActor
    func test_initialState_isConnected() {
        XCTAssertEqual(qBitData.shared.connectionStatus, .connected)
    }
    
    @MainActor
    func test_getMainData_whenNotLoggedIn_doesNotFetchAndStaysConnected() async {
        let mockClient = MockDelayClient()
        ServersHelper.shared.client = mockClient
        ServersHelper.shared.isLoggedIn = false
        
        await qBitData.shared.getMainData()
        
        XCTAssertEqual(mockClient.fetchCount, 0)
        XCTAssertEqual(qBitData.shared.connectionStatus, .connected)
    }
    
    @MainActor
    func test_getMainData_onSuccess_setsStatusToConnected() async {
        let mockClient = MockDelayClient()
        ServersHelper.shared.client = mockClient
        ServersHelper.shared.isLoggedIn = true
        qBitData.shared.connectionStatus = .offline
        
        await qBitData.shared.getMainData()
        
        XCTAssertEqual(mockClient.fetchCount, 1)
        XCTAssertEqual(qBitData.shared.connectionStatus, .connected)
    }
    
    @MainActor
    func test_getMainData_onFailure_setsStatusToOffline() async {
        let mockClient = MockDelayClient()
        mockClient.shouldThrow = true
        ServersHelper.shared.client = mockClient
        ServersHelper.shared.isLoggedIn = true
        
        await qBitData.shared.getMainData()
        
        XCTAssertEqual(mockClient.fetchCount, 1)
        XCTAssertEqual(qBitData.shared.connectionStatus, .offline)
    }
    
    @MainActor
    func test_getMainData_preventsConcurrentFetches() async {
        let mockClient = MockDelayClient()
        mockClient.delayNanoseconds = 100_000_000 // 100ms
        ServersHelper.shared.client = mockClient
        ServersHelper.shared.isLoggedIn = true
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await qBitData.shared.getMainData()
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: 20_000_000) // Sleep 20ms
                await qBitData.shared.getMainData()
            }
            await group.waitForAll()
        }
        
        XCTAssertEqual(mockClient.fetchCount, 1)
        
        await qBitData.shared.getMainData()
        XCTAssertEqual(mockClient.fetchCount, 2)
    }
}
