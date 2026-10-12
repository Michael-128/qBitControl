import XCTest
import Combine
@testable import qBitManager

final class TrackersViewModelTests: XCTestCase {
    @MainActor
    func test_getTrackers_coalescesConcurrentRefreshes() async {
        let firstRead = expectation(description: "Initial read started")
        let trailingRead = expectation(description: "Trailing read started")
        let overlappingRead = expectation(description: "Reads must not overlap")
        overlappingRead.isInverted = true
        let extraRead = expectation(description: "Only one trailing read is needed")
        extraRead.isInverted = true
        let probe = TrackerRequestProbe(
            readStarts: [firstRead, trailingRead],
            overlappingRead: overlappingRead,
            extraRead: extraRead
        )
        addTeardownBlock { await probe.stop() }
        let sut = TrackersViewModel(torrentHash: "torrent-hash", client: TestTorrentClient(probe: probe))

        // These calls happen before the initial read task can enter the main actor.
        for _ in 0..<3 {
            sut.getTrackers()
        }

        await fulfillment(of: [firstRead], timeout: 1.0)
        await fulfillment(of: [overlappingRead], timeout: 1.0)
        let blocked = await probe.snapshot()
        XCTAssertEqual(blocked.hashes, ["torrent-hash"])
        XCTAssertEqual(blocked.maxActiveReads, 1)

        let published = expectation(description: "Trailing trackers published")
        let expectedTrackers = [MockTorrentClient.mockTracker]
        let subscription = sut.$trackers
            .dropFirst()
            .filter { $0 == expectedTrackers }
            .prefix(1)
            .sink { _ in published.fulfill() }
        defer { subscription.cancel() }

        await probe.completeRead(1, with: .success([]))
        await fulfillment(of: [trailingRead], timeout: 1.0)
        await probe.completeRead(2, with: .success(expectedTrackers))
        await fulfillment(of: [published], timeout: 1.0)
        await fulfillment(of: [extraRead], timeout: 1.0)

        let finished = await probe.snapshot()
        XCTAssertEqual(finished.hashes, ["torrent-hash", "torrent-hash"])
        XCTAssertEqual(finished.maxActiveReads, 1)
        XCTAssertEqual(sut.trackers, expectedTrackers)
    }

    @MainActor
    func test_successfulMutations_refreshAfterReadFailure() async {
        let firstRead = expectation(description: "Initial read started")
        let trailingRead = expectation(description: "Refresh after failed read started")
        let laterRead = expectation(description: "Later independent read started")
        let overlappingRead = expectation(description: "Mutation refreshes must not overlap")
        overlappingRead.isInverted = true
        let extraRead = expectation(description: "Mutations share one trailing refresh")
        extraRead.isInverted = true
        let probe = TrackerRequestProbe(
            readStarts: [firstRead, trailingRead, laterRead],
            overlappingRead: overlappingRead,
            extraRead: extraRead
        )
        addTeardownBlock { await probe.stop() }
        let sut = ObservedTrackersViewModel(torrentHash: "torrent-hash", client: TestTorrentClient(probe: probe))
        await fulfillment(of: [firstRead], timeout: 1.0)

        let mutationRefreshes = expectation(description: "Each successful mutation requested refresh")
        mutationRefreshes.expectedFulfillmentCount = 3
        sut.onRefreshRequested = { mutationRefreshes.fulfill() }
        sut.origURL = MockTorrentClient.mockTracker.url
        sut.newURL = "https://tracker.example/announce"
        sut.editTracker()
        sut.addTracker()
        sut.removeTracker(tracker: MockTorrentClient.mockTracker)
        await fulfillment(of: [mutationRefreshes], timeout: 1.0)
        sut.onRefreshRequested = nil
        await fulfillment(of: [overlappingRead], timeout: 1.0)

        let blocked = await probe.snapshot()
        XCTAssertEqual(blocked.mutations.sorted(), ["add", "edit", "remove"])
        XCTAssertEqual(blocked.hashes, ["torrent-hash"])

        let published = expectation(description: "Mutation refresh published trackers")
        let expectedTrackers = [MockTorrentClient.mockTracker]
        let subscription = sut.$trackers
            .dropFirst()
            .filter { $0 == expectedTrackers }
            .prefix(1)
            .sink { _ in published.fulfill() }
        defer { subscription.cancel() }

        await probe.completeRead(1, with: .failure(URLError(.timedOut)))
        await fulfillment(of: [trailingRead], timeout: 1.0)
        await probe.completeRead(2, with: .success(expectedTrackers))
        await fulfillment(of: [published], timeout: 1.0)
        XCTAssertEqual(sut.trackers, expectedTrackers)

        let laterPublication = expectation(description: "Later read published trackers")
        let laterSubscription = sut.$trackers
            .dropFirst()
            .filter { $0.isEmpty }
            .prefix(1)
            .sink { _ in laterPublication.fulfill() }
        defer { laterSubscription.cancel() }

        sut.getTrackers()
        await fulfillment(of: [laterRead], timeout: 1.0)
        await probe.completeRead(3, with: .success([]))
        await fulfillment(of: [laterPublication], timeout: 1.0)
        await fulfillment(of: [extraRead], timeout: 1.0)

        let finished = await probe.snapshot()
        XCTAssertEqual(finished.hashes, ["torrent-hash", "torrent-hash", "torrent-hash"])
        XCTAssertEqual(finished.maxActiveReads, 1)
        XCTAssertTrue(sut.trackers.isEmpty)
    }

    @MainActor
    private class ObservedTrackersViewModel: TrackersViewModel {
        var onRefreshRequested: (() -> Void)?

        override func getTrackers() {
            super.getTrackers()
            onRefreshRequested?()
        }
    }

    private class TestTorrentClient: MockTorrentClient {
        let probe: TrackerRequestProbe

        init(probe: TrackerRequestProbe) {
            self.probe = probe
            super.init()
        }

        override func getTrackers(hash: String) async throws -> [Tracker] {
            return try await probe.read(hash: hash)
        }

        override func editTrackerURL(hash: String, origUrl: String, newURL: String) async throws {
            await probe.recordMutation("edit")
        }

        override func addTrackerURL(hash: String, urls: String) async throws {
            await probe.recordMutation("add")
        }

        override func removeTracker(hash: String, url: String) async throws {
            await probe.recordMutation("remove")
        }
    }

    private actor TrackerRequestProbe {
        let readStarts: [XCTestExpectation]
        let overlappingRead: XCTestExpectation
        let extraRead: XCTestExpectation
        private var hashes: [String] = []
        private var mutations: [String] = []
        private var activeReads = 0
        private var maxActiveReads = 0
        private var pendingReads: [Int: CheckedContinuation<[Tracker], Error>] = [:]
        private var stopped = false

        init(readStarts: [XCTestExpectation], overlappingRead: XCTestExpectation, extraRead: XCTestExpectation) {
            self.readStarts = readStarts
            self.overlappingRead = overlappingRead
            self.extraRead = extraRead
        }

        func read(hash: String) async throws -> [Tracker] {
            guard !stopped else { throw CancellationError() }
            hashes.append(hash)
            let readNumber = hashes.count
            activeReads += 1
            maxActiveReads = max(maxActiveReads, activeReads)
            defer { activeReads -= 1 }
            if activeReads > 1 {
                overlappingRead.fulfill()
            }
            guard readNumber <= readStarts.count else {
                extraRead.fulfill()
                throw CancellationError()
            }
            return try await withCheckedThrowingContinuation { continuation in
                pendingReads[readNumber] = continuation
                readStarts[readNumber - 1].fulfill()
            }
        }

        func completeRead(_ number: Int, with result: Result<[Tracker], Error>) {
            pendingReads.removeValue(forKey: number)?.resume(with: result)
        }

        func recordMutation(_ name: String) {
            mutations.append(name)
        }

        func snapshot() -> (hashes: [String], mutations: [String], maxActiveReads: Int) {
            return (hashes, mutations, maxActiveReads)
        }

        func stop() {
            stopped = true
            let continuations = Array(pendingReads.values)
            pendingReads.removeAll()
            for continuation in continuations {
                continuation.resume(throwing: CancellationError())
            }
        }
    }
}
