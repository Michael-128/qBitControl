import SwiftUI

struct RSSFeedView: View {
    @ObservedObject var rssNodeViewModel = RSSNodeViewModel.shared
    
    @State public var rssFeed: RSSFeed
    @State public var searchQuery: String = ""
    
    var searchResults: [RSSFeed.Article] {
        if searchQuery.isEmpty{
            return rssFeed.articles
        } else {
            return rssFeed.articles.filter { $0.title?.lowercased().contains(searchQuery.lowercased()) ?? false }
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("\(rssFeed.articles.count) Articles") ) {
                ForEach(searchResults, id: \.id) { article in
                    RSSArticleView(article: article)
                }
            }
        }
        .navigationTitle(rssFeed.title)
        .searchable(text: $searchQuery)
        .onAppear { if self.rssFeed.title.isEmpty { rssNodeViewModel.getRssRootNode() } }
    }
}
