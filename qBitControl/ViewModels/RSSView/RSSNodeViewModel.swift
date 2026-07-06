//
//  RSSNodeViewModel.swift
//  qBitControl
//

import SwiftUI

@MainActor
class RSSNodeViewModel: ObservableObject {
    static public let shared = RSSNodeViewModel()
    
    @Published public var rssRootNode: RSSNode = .init()
    @Published public var activeError: RSSError? = nil
    private var pollingTask: Task<Void, Never>?
    
    private var client: TorrentClientProtocol {
        ServersHelper.shared.client ?? MockTorrentClient()
    }
    
    init() {
        self.getRssRootNode()
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
                    try await Task.sleep(nanoseconds: 30_000_000_000)
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
                self.activeError = self.mapError(error)
            }
        }
    }
    
    func addRSSFolder(path: String) {
        Task {
            do {
                try await client.addRSSFolder(path: path)
                getRssRootNode()
            } catch {
                self.activeError = self.mapError(error)
            }
        }
    }
    
    func moveRSSItem(itemPath: String, destPath: String) {
        Task {
            do {
                try await client.moveRSSItem(itemPath: itemPath, destPath: destPath)
                getRssRootNode()
            } catch {
                self.activeError = self.mapError(error)
            }
        }
    }
    
    func addRSSRefreshItem(path: String) {
        Task {
            do {
                try await client.addRSSRefreshItem(path: path)
                getRssRootNode()
            } catch {
                self.activeError = self.mapError(error)
            }
        }
    }
    
    func addRSSRemoveItem(path: String) {
        Task {
            do {
                try await client.addRSSRemoveItem(path: path)
                getRssRootNode()
            } catch {
                self.activeError = self.mapError(error)
            }
        }
    }
    
    func getRssRootNodeAsync() async {
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
    
    private func mapError(_ error: Error) -> RSSError {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                return .invalidURL
            case .unauthorized:
                return .unauthorized
            case .timeout:
                return .timeout
            case .invalidResponse:
                return .unknown(0)
            case .httpError(let statusCode):
                if statusCode == 409 {
                    return .alreadyExists
                }
                return .unknown(statusCode)
            }
        }
        return .unknown(0)
    }
}
