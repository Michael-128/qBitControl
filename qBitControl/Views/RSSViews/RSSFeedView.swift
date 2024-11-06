import SwiftUI

struct RSSFeedView: View {
    @State public var rssFeed: RSSFeed
    @State public var searchQuery: String = ""
    
    func filterArticles(_ article: RSSFeed.Article) -> Bool {
        if let title = article.title { return title.contains(searchQuery) }
        return false
    }
    
    var body: some View {
        List {
            if !searchQuery.isEmpty {
                Section(header: Text("\(rssFeed.articles.count { filterArticles($0) }) Articles") ) {
                    ForEach(rssFeed.articles.filter { filterArticles($0) }, id: \.id) { article in
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
    }
}
