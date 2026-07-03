//
//  RSSNodeViewModel.swift
//  qBitControl
//

import SwiftUI

@MainActor
class RSSNodeViewModel: ObservableObject {
    static public let shared = RSSNodeViewModel(client: ServersHelper.shared.client ?? MockTorrentClient())
    
    @Published public var rssRootNode: RSSNode = .init()
    private var pollingTask: Task<Void, Never>?
    private let client: TorrentClientProtocol
    
    init(client: TorrentClientProtocol) {
        self.client = client
        self.getRssRootNode()
        self.startTimer()
    }
    
    deinit {
        // Can't cancel Task directly in deinit of MainActor class easily, but we have stopTimer
    }
    
    func startTimer() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                await getRssRootNodeAsync()
                do {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                } catch {
                    break
                }
            }
        }
    }
    
    func stopTimer() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    private func getRssRootNodeAsync() async {
        do {
            let node = try await client.getRSSFeeds(withDate: true)
            self.rssRootNode = node
        } catch {
            print("Failed to get RSS feeds: \(error)")
        }
    }
    
    func getRssRootNode() {
        Task {
            await getRssRootNodeAsync()
        }
    }
}
