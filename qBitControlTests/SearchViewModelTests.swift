import XCTest
import Combine
@testable import qBitManager

final class SearchViewModelTests: XCTestCase {
    private actor SearchRequests {
        private var nextID = 41
        private var isClosed = false
        private var pendingResults: [Int: [CheckedContinuation<SearchResponse, Error>]] = [:]
        private var pendingStops: [CheckedContinuation<Void, Error>] = []
        private(set) var stoppedIDs: [Int] = []
        private let resultRequested: (Int) -> Void
        private let resultReturned: (Int) -> Void
        private let stopRequested: (Int) -> Void
        private let stopReturned: () -> Void
        private let delayStop: Bool

        init(
            resultRequested: @escaping (Int) -> Void = { _ in },
            resultReturned: @escaping (Int) -> Void = { _ in },
            stopRequested: @escaping (Int) -> Void = { _ in },
            stopReturned: @escaping () -> Void = {},
            delayStop: Bool = false
        ) {
            self.resultRequested = resultRequested
            self.resultReturned = resultReturned
            self.stopRequested = stopRequested
            self.stopReturned = stopReturned
            self.delayStop = delayStop
        }

        func start() throws -> SearchStartResult {
            guard !isClosed else { throw CancellationError() }
            defer { nextID += 1 }
            return SearchStartResult(id: nextID)
        }

        func results(id: Int) async throws -> SearchResponse {
            guard !isClosed else { throw CancellationError() }
            // A transport can finish an in-flight request after its caller cancels.
            let response: SearchResponse = try await withCheckedThrowingContinuation { continuation in
                pendingResults[id, default: []].append(continuation)
                resultRequested(id)
            }
            resultReturned(id)
            return response
        }

        func stop(id: Int) async throws {
            guard !isClosed else { throw CancellationError() }
            stoppedIDs.append(id)
            defer { stopReturned() }
            if delayStop {
                try await withCheckedThrowingContinuation { continuation in
                    pendingStops.append(continuation)
                    stopRequested(id)
                }
            } else {
                stopRequested(id)
            }
        }

        func completeResults(id: Int, response: SearchResponse) {
            let continuations = pendingResults.removeValue(forKey: id) ?? []
            for continuation in continuations {
                continuation.resume(returning: response)
            }
        }

        func failStop() {
            let continuations = pendingStops
            pendingStops.removeAll()
            for continuation in continuations {
                continuation.resume(throwing: NetworkError.httpError(statusCode: 404))
            }
        }

        func finishPendingRequests() {
            isClosed = true
            let results = pendingResults.values.flatMap { $0 }
            pendingResults.removeAll()
            for continuation in results {
                continuation.resume(throwing: CancellationError())
            }
            let stops = pendingStops
            pendingStops.removeAll()
            for continuation in stops {
                continuation.resume()
            }
        }
    }

    private class SearchClient: MockTorrentClient {
        let requests: SearchRequests

        init(requests: SearchRequests) {
            self.requests = requests
            super.init()
        }

        override func getSearchStart(pattern: String, category: String, plugins: Bool) async throws -> SearchStartResult {
            try await requests.start()
        }

        override func getSearchResults(id: Int, limit: Int, offset: Int) async throws -> SearchResponse {
            try await requests.results(id: id)
        }

        override func stopSearch(id: Int) async throws {
            try await requests.stop(id: id)
        }

        override func getSearchPlugins() async throws -> [SearchPlugin] {
            []
        }
    }

    @MainActor
    func testEndSearch_StopsCapturedIDOnceAndPreservesResults() async throws {
        let stopRequested = expectation(description: "Stop requested once")
        stopRequested.assertForOverFulfill = true
        let requests = SearchRequests(stopRequested: { _ in stopRequested.fulfill() })
        let sut = SearchViewModel(client: SearchClient(requests: requests))
        let result = try JSONDecoder().decode(SearchResult.self, from: Data(#"{"fileName":"Ubuntu.iso"}"#.utf8))
        sut.searchId = 41
        sut.latestResponse = SearchResponse(results: [result], status: "Running", total: 1)

        sut.endSearch()

        XCTAssertNil(sut.searchId)
        XCTAssertFalse(sut.isRunning)
        XCTAssertEqual(sut.latestResponse?.total, 1)
        XCTAssertEqual(sut.latestResults.map(\.id), [result.id])
        sut.endSearch()
        // The command must use the old ID even if another search is now active.
        sut.searchId = 42
        await fulfillment(of: [stopRequested], timeout: 1.0)

        let stoppedIDs = await requests.stoppedIDs
        XCTAssertEqual(stoppedIDs, [41])
        XCTAssertEqual(sut.searchId, 42)
        await requests.finishPendingRequests()
    }

    @MainActor
    func testEndSearch_WithoutIDDoesNotSendStop() async {
        let stopRequested = expectation(description: "No stop without an active search")
        stopRequested.isInverted = true
        let requests = SearchRequests(stopRequested: { _ in stopRequested.fulfill() })
        let sut = SearchViewModel(client: SearchClient(requests: requests))

        sut.endSearch()

        XCTAssertFalse(sut.isRunning)
        await fulfillment(of: [stopRequested], timeout: 0.1)
        await requests.finishPendingRequests()
    }

    @MainActor
    func testNaturalCompletion_PublishesFinalResultsWithoutSendingStop() async {
        let resultRequested = expectation(description: "Search results requested")
        let stopped = expectation(description: "Local search completed")
        let stopRequested = expectation(description: "Natural completion needs no stop command")
        stopRequested.isInverted = true
        let requests = SearchRequests(
            resultRequested: { _ in resultRequested.fulfill() },
            stopRequested: { _ in stopRequested.fulfill() }
        )
        let sut = SearchViewModel(client: SearchClient(requests: requests))
        let subscription = sut.$searchId.dropFirst().filter { $0 == nil }.prefix(1).sink { _ in
            stopped.fulfill()
        }
        defer { subscription.cancel() }
        sut.query = "Ubuntu"
        sut.startSearch()
        await fulfillment(of: [resultRequested], timeout: 1.0)

        await requests.completeResults(id: 41, response: SearchResponse(results: [], status: "Stopped", total: 7))

        await fulfillment(of: [stopped], timeout: 1.0)
        XCTAssertFalse(sut.isRunning)
        XCTAssertEqual(sut.latestResponse?.status, "Stopped")
        XCTAssertEqual(sut.latestResponse?.total, 7)
        await fulfillment(of: [stopRequested], timeout: 0.1)
        await requests.finishPendingRequests()
    }

    @MainActor
    func testEndSearch_IgnoresLateResultsFromCancelledSearch() async {
        let firstRequested = expectation(description: "Old search results requested")
        let secondRequested = expectation(description: "New search results requested")
        let oldResultReturned = expectation(description: "Cancelled request returned a terminal response")
        let requests = SearchRequests(
            resultRequested: { id in
                (id == 41 ? firstRequested : secondRequested).fulfill()
            },
            resultReturned: { id in
                if id == 41 { oldResultReturned.fulfill() }
            }
        )
        let sut = SearchViewModel(client: SearchClient(requests: requests))
        sut.query = "Ubuntu"
        sut.startSearch()
        await fulfillment(of: [firstRequested], timeout: 1.0)
        sut.endSearch()
        sut.startSearch()
        await fulfillment(of: [secondRequested], timeout: 1.0)
        sut.latestResponse = SearchResponse(results: [], status: "Running", total: 11)

        let stalePublication = expectation(description: "Old results must not be published")
        stalePublication.isInverted = true
        let staleCompletion = expectation(description: "Old results must not end the new search")
        staleCompletion.isInverted = true
        let resultSubscription = sut.$latestResponse.dropFirst().sink { _ in stalePublication.fulfill() }
        let idSubscription = sut.$searchId.dropFirst().sink { _ in staleCompletion.fulfill() }

        await requests.completeResults(id: 41, response: SearchResponse(results: [], status: "Stopped", total: 99))

        await fulfillment(of: [oldResultReturned], timeout: 1.0)
        await fulfillment(of: [stalePublication, staleCompletion], timeout: 0.1)
        XCTAssertEqual(sut.searchId, 42)
        XCTAssertEqual(sut.latestResponse?.total, 11)
        resultSubscription.cancel()
        idSubscription.cancel()
        sut.endSearch()
        await requests.finishPendingRequests()
    }

    @MainActor
    func testEndSearch_StopFailureDoesNotChangeNewSearch() async {
        let firstRequested = expectation(description: "Old search results requested")
        let secondRequested = expectation(description: "New search results requested")
        let stopRequested = expectation(description: "Old search stop requested once")
        stopRequested.assertForOverFulfill = true
        let stopReturned = expectation(description: "Old search stop failed")
        let requests = SearchRequests(
            resultRequested: { id in
                (id == 41 ? firstRequested : secondRequested).fulfill()
            },
            stopRequested: { _ in stopRequested.fulfill() },
            stopReturned: { stopReturned.fulfill() },
            delayStop: true
        )
        let sut = SearchViewModel(client: SearchClient(requests: requests))
        sut.query = "Ubuntu"
        sut.startSearch()
        await fulfillment(of: [firstRequested], timeout: 1.0)
        sut.endSearch()
        XCTAssertFalse(sut.isRunning)
        await fulfillment(of: [stopRequested], timeout: 1.0)
        sut.startSearch()
        await fulfillment(of: [secondRequested], timeout: 1.0)
        sut.latestResponse = SearchResponse(results: [], status: "Running", total: 11)

        let stateChanged = expectation(description: "Stop failure must not change the new search")
        stateChanged.isInverted = true
        let resultSubscription = sut.$latestResponse.dropFirst().sink { _ in stateChanged.fulfill() }
        let idSubscription = sut.$searchId.dropFirst().sink { _ in stateChanged.fulfill() }

        await requests.failStop()

        await fulfillment(of: [stopReturned], timeout: 1.0)
        await fulfillment(of: [stateChanged], timeout: 0.1)
        XCTAssertEqual(sut.searchId, 42)
        XCTAssertEqual(sut.latestResponse?.total, 11)
        let stoppedIDs = await requests.stoppedIDs
        XCTAssertEqual(stoppedIDs, [41])
        resultSubscription.cancel()
        idSubscription.cancel()
        // Finish the current search naturally so cleanup sends no second stop.
        let finished = expectation(description: "New search completed")
        let completionSubscription = sut.$searchId.dropFirst().filter { $0 == nil }.prefix(1).sink { _ in
            finished.fulfill()
        }
        await requests.completeResults(id: 42, response: SearchResponse(results: [], status: "Stopped", total: 11))
        await fulfillment(of: [finished], timeout: 1.0)
        completionSubscription.cancel()
        await requests.finishPendingRequests()
    }
}
