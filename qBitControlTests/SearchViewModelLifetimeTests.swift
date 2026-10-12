import XCTest
@testable import qBitManager

final class SearchViewModelLifetimeTests: XCTestCase {
    @MainActor
    func testPollingReleasesOwnerAfterActiveResultsFinish() async {
        let resultsRequested = expectation(description: "Search results requested")
        let deallocated = expectation(description: "Search view model deallocated")
        let requests = SearchRequests(resultsRequested: resultsRequested)
        let client = TestTorrentClient(requests: requests)
        var viewModel: TrackedSearchViewModel? = TrackedSearchViewModel(client: client, deallocated: deallocated)
        weak var weakViewModel = viewModel

        viewModel?.query = "ubuntu"
        viewModel?.startSearch()
        await fulfillment(of: [resultsRequested], timeout: 1.0)

        viewModel = nil
        await requests.releaseResults()
        await fulfillment(of: [deallocated], timeout: 1.0)
        XCTAssertNil(weakViewModel)

        // Also clean up the polling task when this test runs against the old implementation.
        weakViewModel?.endSearch()
        await requests.finish()
    }

    @MainActor
    func testPollingReleasesOwnerAfterDelayedStartFinishes() async {
        let startRequested = expectation(description: "Search start requested")
        let deallocated = expectation(description: "Search view model deallocated")
        let requests = SearchRequests(startRequested: startRequested)
        let client = TestTorrentClient(requests: requests)
        var viewModel: TrackedSearchViewModel? = TrackedSearchViewModel(client: client, deallocated: deallocated)
        weak var weakViewModel = viewModel

        viewModel?.query = "ubuntu"
        viewModel?.startSearch()
        await fulfillment(of: [startRequested], timeout: 1.0)

        viewModel = nil
        await requests.releaseStart()
        await fulfillment(of: [deallocated], timeout: 1.0)
        XCTAssertNil(weakViewModel)

        weakViewModel?.endSearch()
        await requests.finish()
    }

    private final class TrackedSearchViewModel: SearchViewModel {
        private let deallocated: XCTestExpectation

        init(client: TorrentClientProtocol, deallocated: XCTestExpectation) {
            self.deallocated = deallocated
            super.init(client: client)
        }

        deinit {
            deallocated.fulfill()
        }
    }

    private final class TestTorrentClient: MockTorrentClient {
        private let requests: SearchRequests

        init(requests: SearchRequests) {
            self.requests = requests
            super.init()
        }

        override func getSearchStart(pattern: String, category: String, plugins: Bool) async throws -> SearchStartResult {
            return await requests.start()
        }

        override func getSearchResults(id: Int, limit: Int, offset: Int) async throws -> SearchResponse {
            return await requests.results()
        }

        override func getSearchPlugins() async throws -> [SearchPlugin] {
            return []
        }
    }

    private actor SearchRequests {
        private let startRequested: XCTestExpectation?
        private let resultsRequested: XCTestExpectation?
        private var startContinuation: CheckedContinuation<Void, Never>?
        private var resultsContinuation: CheckedContinuation<Void, Never>?
        private var isStartReleased = false
        private var areResultsReleased = false
        private var isFinished = false

        init(startRequested: XCTestExpectation? = nil, resultsRequested: XCTestExpectation? = nil) {
            self.startRequested = startRequested
            self.resultsRequested = resultsRequested
        }

        func start() async -> SearchStartResult {
            if let startRequested = startRequested, !isStartReleased {
                await withCheckedContinuation { continuation in
                    startContinuation = continuation
                    startRequested.fulfill()
                }
            }
            return SearchStartResult(id: 1)
        }

        func results() async -> SearchResponse {
            if let resultsRequested = resultsRequested, !areResultsReleased {
                await withCheckedContinuation { continuation in
                    resultsContinuation = continuation
                    resultsRequested.fulfill()
                }
            }
            return SearchResponse(results: [], status: isFinished ? "Stopped" : "Running", total: 0)
        }

        func releaseStart() {
            isStartReleased = true
            startContinuation?.resume()
            startContinuation = nil
        }

        func releaseResults() {
            areResultsReleased = true
            resultsContinuation?.resume()
            resultsContinuation = nil
        }

        func finish() {
            isFinished = true
            releaseStart()
            releaseResults()
        }
    }
}
