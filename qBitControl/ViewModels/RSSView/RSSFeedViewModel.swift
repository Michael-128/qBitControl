//
//  RSSFeedViewModel.swift
//  qBitControl
//

import SwiftUI
import Combine

@MainActor
class RSSFeedViewModel: ObservableObject {
    private let feedURL: String
    private let rssNodeViewModel = RSSNodeViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private var pollingTask: Task<Void, Never>?
    
    @Published public var searchQuery: String = ""
    @Published public var selectedArticle: RSSFeed.Article? = nil
    
    @Published public var feedTitle: String = ""
    @Published public var displayedArticles: [RSSFeed.Article] = []
    @Published public var isLoading: Bool = false
    
    init(feedURL: String) {
        self.feedURL = feedURL
        
        // Set up dynamic Combine bindings
        Publishers.CombineLatest(
            rssNodeViewModel.$rssRootNode,
            $searchQuery
        )
        .sink { [weak self] rootNode, query in
            guard let self = self else { return }
            if let feed = rootNode.getFeed(url: self.feedURL) {
                self.feedTitle = feed.title
                
                if query.isEmpty {
                    self.displayedArticles = feed.articles
                } else {
                    self.displayedArticles = feed.articles.filter { article in
                        if let title = article.title {
                            return title.lowercased().contains(query.lowercased())
                        }
                        return false
                    }
                }
            }
        }
        .store(in: &cancellables)
    }
    
    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                // Poll by requesting root node refresh from RSSNodeViewModel
                await rssNodeViewModel.getRssRootNodeAsync()
                do {
                    try await Task.sleep(nanoseconds: 30_000_000_000)
                } catch {
                    break
                }
            }
        }
    }
    
    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    var selectedTorrentURL: URL? {
        guard let article = selectedArticle else { return nil }
        return URL(string: article.torrentURL ?? article.link ?? "")
    }
}
