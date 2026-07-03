//
//  RSSViewModel.swift
//  qBitControl
//

import SwiftUI

@MainActor
class RSSViewModel: ObservableObject {
    @Published public var RSSNode: RSSNode = .init()
    @Published public var updateID: UUID = UUID()
    private let client: TorrentClientProtocol
    
    init(client: TorrentClientProtocol) {
        self.client = client
        self.getRSSFeed()
    }
    
    func getRSSFeed() {
        Task {
            do {
                let node = try await client.getRSSFeeds(withDate: true)
                self.RSSNode = node
                self.updateID = UUID()
            } catch {
                print("Failed to get RSS feeds: \(error)")
            }
        }
    }
}
