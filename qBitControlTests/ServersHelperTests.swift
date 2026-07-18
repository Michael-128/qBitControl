import XCTest
@testable import qBitManager

@MainActor
final class ServersHelperTests: XCTestCase {

    private var testDefaults: UserDefaults!
    private var suiteName: String!
    private var sut: ServersHelper!

    override func setUp() {
        super.setUp()
        suiteName = "ServersHelperTests_\(UUID().uuidString)"
        testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)
        sut = ServersHelper(defaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: suiteName)
        testDefaults = nil
        super.tearDown()
    }

    private func makeServer(id: String, name: String, url: String = "https://example.com") -> Server {
        Server(id: id, name: name, url: url, username: "user", password: "pass")
    }

    func test_addServer_appendsAndPersists() {
        let server = makeServer(id: "s1", name: "Test")
        sut.addServer(server: server)

        XCTAssertEqual(sut.servers.count, 1)
        XCTAssertEqual(sut.servers.first?.id, "s1")

        let newSut = ServersHelper(defaults: testDefaults)
        XCTAssertEqual(newSut.servers.count, 1)
        XCTAssertEqual(newSut.servers.first?.id, "s1")
    }

    func test_updateServer_replacesInPlace() {
        let s1 = makeServer(id: "s1", name: "Original")
        sut.addServer(server: s1)

        let updated = makeServer(id: "s1", name: "Updated")
        sut.updateServer(updated)

        XCTAssertEqual(sut.servers.count, 1)
        XCTAssertEqual(sut.servers.first?.name, "Updated")
    }

    func test_updateServer_preservesRecents() {
        let s1 = makeServer(id: "s1", name: "One")
        let s2 = makeServer(id: "s2", name: "Two")
        sut.addServer(server: s1)
        sut.addServer(server: s2)

        sut.appendToRecent(serverId: "s1")
        sut.appendToRecent(serverId: "s2")

        let updated = makeServer(id: "s1", name: "One Updated")
        sut.updateServer(updated)

        XCTAssertEqual(sut.recentServers.count, 2)
        XCTAssertTrue(sut.recentServers.contains(where: { $0.name == "One Updated" }))
        XCTAssertTrue(sut.recentServers.contains(where: { $0.name == "Two" }))
    }

    func test_appendToRecent_capsAtThree() {
        let servers = (0..<4).map { makeServer(id: "s\($0)", name: "Server \($0)") }
        for s in servers {
            sut.addServer(server: s)
            sut.appendToRecent(serverId: s.id)
        }

        XCTAssertEqual(sut.recentServers.count, 3)
        XCTAssertEqual(sut.recentServers.first?.id, "s3")
        XCTAssertFalse(sut.recentServers.contains(where: { $0.id == "s0" }))
    }

    func test_appendToRecent_movesExistingToFront() {
        let s1 = makeServer(id: "s1", name: "One")
        let s2 = makeServer(id: "s2", name: "Two")
        let s3 = makeServer(id: "s3", name: "Three")
        sut.addServer(server: s1)
        sut.addServer(server: s2)
        sut.addServer(server: s3)

        sut.appendToRecent(serverId: "s3")
        sut.appendToRecent(serverId: "s2")
        sut.appendToRecent(serverId: "s1")

        sut.appendToRecent(serverId: "s2")

        XCTAssertEqual(sut.recentServers.count, 3)
        XCTAssertEqual(sut.recentServers[0].id, "s2")
        XCTAssertEqual(sut.recentServers[1].id, "s1")
        XCTAssertEqual(sut.recentServers[2].id, "s3")
    }

    func test_removeFromRecent_removesServerAndPersists() {
        let s1 = makeServer(id: "s1", name: "One")
        let s2 = makeServer(id: "s2", name: "Two")
        sut.addServer(server: s1)
        sut.addServer(server: s2)

        sut.appendToRecent(serverId: "s1")
        sut.appendToRecent(serverId: "s2")

        sut.removeFromRecent(id: "s1")

        XCTAssertEqual(sut.recentServers.count, 1)
        XCTAssertEqual(sut.recentServers.first?.id, "s2")

        let ids = testDefaults.stringArray(forKey: "recentServers")
        XCTAssertEqual(ids, ["s2"])
    }

    func test_removeServer_alsoRemovesFromRecents() {
        let s1 = makeServer(id: "s1", name: "One")
        sut.addServer(server: s1)
        sut.appendToRecent(serverId: "s1")

        sut.removeServer(id: "s1")

        XCTAssertEqual(sut.servers.count, 0)
        XCTAssertEqual(sut.recentServers.count, 0)
    }

    func test_loadRecentServers_filtersDeletedServerIds() {
        let s1 = makeServer(id: "s1", name: "One")
        sut.addServer(server: s1)
        sut.appendToRecent(serverId: "s1")

        var ids = testDefaults.stringArray(forKey: "recentServers") ?? []
        ids.append("nonexistent")
        testDefaults.set(ids, forKey: "recentServers")

        sut.loadRecentServers()

        XCTAssertEqual(sut.recentServers.count, 1)
        XCTAssertEqual(sut.recentServers.first?.id, "s1")
    }

    func test_getServer_findsById() {
        let server = makeServer(id: "find-me", name: "Target")
        sut.addServer(server: server)

        let found = sut.getServer(id: "find-me")
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "Target")
    }

    func test_getServer_returnsNilForMissingId() {
        let found = sut.getServer(id: "missing")
        XCTAssertNil(found)
    }
}
