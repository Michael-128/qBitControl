import SwiftUI

struct RSSFeedView: View {
    @ObservedObject var rssNodeViewModel = RSSNodeViewModel.shared
    
    @State public var rssFeed: RSSFeed
    @State public var searchQuery: String = ""
    
    func filterArticles(_ article: RSSFeed.Article) -> Bool {
        if let title = article.title { return title.lowercased().contains(searchQuery.lowercased()) }
        return false
    }
    
    var body: some View {
        List {
            if !searchQuery.isEmpty {
                Section(header: Text("\(rssFeed.articles.count) Articles") ) {
                    ForEach(rssFeed.articles.filter(filterArticles), id: \.id) { article in
                        RSSArticleView(article: article)
                    }
                }
            } else {
                Section(header: Text("\(rssFeed.articles.count) Articles")) {
                    ForEach(rssFeed.articles, id: \.id) { article in
                        RSSArticleView(article: article)
                    }
                }
            }
        }
        .navigationTitle(rssFeed.title)
        .searchable(text: $searchQuery)
        .onAppear { if self.rssFeed.title.isEmpty { rssNodeViewModel.getRssRootNode() } }
    }
}
