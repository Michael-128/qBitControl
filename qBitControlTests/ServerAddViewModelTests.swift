import XCTest
@testable import qBitManager

final class ServerAddViewModelTests: XCTestCase {

    @MainActor
    override func setUp() {
        super.setUp()
        ServersHelper.shared.servers = []
        ServersHelper.shared.recentServers = []
    }

    @MainActor
    override func tearDown() {
        ServersHelper.shared.servers = []
        ServersHelper.shared.recentServers = []
        ServersHelper.shared.activeServerId = nil
        super.tearDown()
    }

    func test_init_default_hasNilEditServerId() {
        let vm = ServerAddViewModel()
        XCTAssertNil(vm.editServerId)
    }

    @MainActor
    func test_initWithEditServerId_loadsExistingServerData() {
        let server = Server(
            id: "edit-1",
            name: "My Server",
            url: "https://myserver.com",
            username: "admin",
            password: "secret",
            basicAuth: Server.BasicAuth("ba_user", "ba_pass"),
            customHeaders: [Server.CustomHeader(key: "X-Header", value: "val")],
            allowSelfSignedCert: true
        )
        ServersHelper.shared.servers = [server]

        let vm = ServerAddViewModel(editServerId: "edit-1")

        XCTAssertEqual(vm.editServerId, "edit-1")
        XCTAssertEqual(vm.friendlyName, "My Server")
        XCTAssertEqual(vm.url, "https://myserver.com")
        XCTAssertEqual(vm.username, "admin")
        XCTAssertEqual(vm.password, "secret")
        XCTAssertEqual(vm.basicAuth?.username, "ba_user")
        XCTAssertEqual(vm.basicAuth?.password, "ba_pass")
        XCTAssertEqual(vm.customHeaders.count, 1)
        XCTAssertEqual(vm.customHeaders.first?.key, "X-Header")
        XCTAssertTrue(vm.allowSelfSignedCert)
    }

    @MainActor
    func test_makeServer_preservesId_onEdit() {
        let server = Server(id: "edit-1", name: "Original", url: "https://a.com", username: "u", password: "p")
        ServersHelper.shared.servers = [server]

        let vm = ServerAddViewModel(editServerId: "edit-1")
        vm.friendlyName = "Updated Name"
        vm.url = "https://updated.com"

        let newServer = vm.makeServer()

        XCTAssertEqual(newServer.id, "edit-1")
        XCTAssertEqual(newServer.name, "Updated Name")
        XCTAssertEqual(newServer.url, "https://updated.com")
    }

    func test_makeServer_generatesDistinctIds_forNewServer() {
        let vm = ServerAddViewModel()
        vm.url = "https://new.com"

        let s1 = vm.makeServer()
        let s2 = vm.makeServer()

        XCTAssertNotEqual(s1.id, s2.id)
    }

    func test_validateInputs_rejectsUrlWithoutProtocol() {
        let vm = ServerAddViewModel()
        vm.url = "example.com"

        XCTAssertFalse(vm.validateInputs())
        XCTAssertTrue(vm.isInvalidAlert)
    }

    func test_validateInputs_acceptsHttpUrl() {
        let vm = ServerAddViewModel()
        vm.url = "http://example.com"

        XCTAssertTrue(vm.validateInputs())
    }

    func test_validateInputs_acceptsHttpsUrl() {
        let vm = ServerAddViewModel()
        vm.url = "https://example.com"

        XCTAssertTrue(vm.validateInputs())
    }

    func test_sanitizeInputs_removesTrailingSlashes() {
        let vm = ServerAddViewModel()
        vm.url = "https://example.com///"

        vm.sanitizeInputs()

        XCTAssertEqual(vm.url, "https://example.com")
    }

    func test_sanitizeInputs_keepsUrlWithoutTrailingSlashes() {
        let vm = ServerAddViewModel()
        vm.url = "https://example.com/path"

        vm.sanitizeInputs()

        XCTAssertEqual(vm.url, "https://example.com/path")
    }

    func test_isLanHost_localhost() {
        let vm = ServerAddViewModel()
        vm.url = "http://localhost:8080"

        XCTAssertTrue(vm.isLanHost)
    }

    func test_isLanHost_dotLocal() {
        let vm = ServerAddViewModel()
        vm.url = "https://nas.local"

        XCTAssertTrue(vm.isLanHost)
    }

    func test_isLanHost_private192168() {
        let vm = ServerAddViewModel()
        vm.url = "https://192.168.1.100"

        XCTAssertTrue(vm.isLanHost)
    }

    func test_isLanHost_private10() {
        let vm = ServerAddViewModel()
        vm.url = "https://10.0.0.1"

        XCTAssertTrue(vm.isLanHost)
    }

    func test_isLanHost_private172() {
        let vm = ServerAddViewModel()
        vm.url = "https://172.16.0.1"

        XCTAssertTrue(vm.isLanHost)
    }

    func test_isLanHost_publicIp() {
        let vm = ServerAddViewModel()
        vm.url = "https://8.8.8.8"

        XCTAssertFalse(vm.isLanHost)
    }

    func test_buildConnectionErrorMessage_basic() {
        let vm = ServerAddViewModel()
        vm.url = "https://example.com"

        let error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Connection refused"])
        let message = vm.buildConnectionErrorMessage(from: error)

        XCTAssertTrue(message.contains("Connection refused"))
    }

    func test_buildConnectionErrorMessage_noError() {
        let vm = ServerAddViewModel()
        vm.url = "https://example.com"

        let message = vm.buildConnectionErrorMessage(from: nil)

        XCTAssertEqual(message, "Could not connect to the server.")
    }

    func test_buildConnectionErrorMessage_lanHostWithCannotConnect() {
        let vm = ServerAddViewModel()
        vm.url = "http://192.168.1.1"

        let error = URLError(.cannotConnectToHost)
        let message = vm.buildConnectionErrorMessage(from: error)

        XCTAssertTrue(message.contains("local network access"))
    }

    func test_showAlert_queuesMessages() {
        let vm = ServerAddViewModel()

        vm.showAlert(message: "First error")
        XCTAssertTrue(vm.isInvalidAlert)
        XCTAssertEqual(vm.invalidAlertMessage, "First error")

        vm.showAlert(message: "Second error")

        vm.isInvalidAlert = false
        vm.alertDismissed()

        let expectation = self.expectation(description: "alert presented after dismiss")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(vm.isInvalidAlert)
            XCTAssertEqual(vm.invalidAlertMessage, "Second error")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
