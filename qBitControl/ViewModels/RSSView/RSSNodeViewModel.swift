//
//  RSSNodeViewModel.swift
//  qBitControl
//

import SwiftUI

@MainActor
class RSSNodeViewModel: ObservableObject {
    static public let shared = RSSNodeViewModel()
    
    @Published public var rssRootNode: RSSNode = .init()
    private var pollingTask: Task<Void, Never>?
    
    private var client: TorrentClientProtocol {
        ServersHelper.shared.client ?? MockTorrentClient()
    }
    
    init() {
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
    
    func addRSSFeed(url: String, path: String) {
        Task {
            do {
                try await client.addRSSFeed(url: url, path: path)
                getRssRootNode()
            } catch {
                print("Failed to add RSS feed: \(error)")
            }
        }
    }
    
    func addRSSFolder(path: String) {
        Task {
            do {
                try await client.addRSSFolder(path: path)
                getRssRootNode()
            } catch {
                print("Failed to add RSS folder: \(error)")
            }
        }
    }
    
    func moveRSSItem(itemPath: String, destPath: String) {
        Task {
            do {
                try await client.moveRSSItem(itemPath: itemPath, destPath: destPath)
                getRssRootNode()
            } catch {
                print("Failed to move RSS item: \(error)")
            }
        }
    }
    
    func addRSSRefreshItem(path: String) {
        Task {
            do {
                try await client.addRSSRefreshItem(path: path)
                getRssRootNode()
            } catch {
                print("Failed to refresh RSS item: \(error)")
            }
        }
    }
    
    func addRSSRemoveItem(path: String) {
        Task {
            do {
                try await client.addRSSRemoveItem(path: path)
                getRssRootNode()
            } catch {
                print("Failed to remove RSS item: \(error)")
            }
        }
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
