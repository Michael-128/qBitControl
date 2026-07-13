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
                let str = url.absoluteString
                if str.contains("magnet:") || str.hasSuffix(".torrent") {
                    TorrentAddView(torrentUrls: .constant([url]))
                        .id(url)
                } else {
                    NavigationView {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundColor(.red)
                            Text("This RSS link is not a .torrent file or magnet URL.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                        .navigationTitle("Unsupported Link")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") {
                                    viewModel.selectedArticle = nil
                                }
                            }
                        }
                    }
                }
            } else {
                NavigationView {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .foregroundColor(.red)
                        Text("This article does not contain a torrent link.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    .navigationTitle("No Torrent")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                viewModel.selectedArticle = nil
                            }
                        }
                    }
                }
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
