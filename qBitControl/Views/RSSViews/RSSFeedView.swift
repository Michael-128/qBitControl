import SwiftUI

struct RSSFeedView: View {
    let feedURL: String
    @StateObject private var viewModel: RSSFeedViewModel
    
    init(feedURL: String) {
        self.feedURL = feedURL
        self._viewModel = StateObject(wrappedValue: RSSFeedViewModel(feedURL: feedURL))
    }
    
    var body: some View {
        Group {
            if viewModel.displayedArticles.isEmpty && viewModel.searchQuery.isEmpty {
                VStack {
                    ProgressView()
                    Text("Loading Feed...")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .padding(.top, 8)
                }
            } else {
                List {
                    Section(header: Text("\(viewModel.displayedArticles.count) Articles")) {
                        ForEach(viewModel.displayedArticles, id: \.id) { article in
                            RSSArticleView(article: article) {
                                guard viewModel.selectedArticle == nil else { return }
                                viewModel.selectedArticle = article
                            }
                        }
                    }
                }
                .navigationTitle(viewModel.feedTitle)
            }
        }
        .sheet(item: $viewModel.selectedArticle) { _ in
            if let url = viewModel.selectedTorrentURL {
                TorrentAddView(torrentUrls: .constant([url]))
                    .id(url)
            }
        }
        .searchable(text: $viewModel.searchQuery)
        .onAppear {
            viewModel.startPolling()
        }
        .onDisappear {
            viewModel.stopPolling()
        }
    }
}
