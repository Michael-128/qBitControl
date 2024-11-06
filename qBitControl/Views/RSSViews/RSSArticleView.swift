import SwiftUI

struct RSSArticleView: View {
    @State var article: RSSFeed.Article
    @State var isTorrentAddSheet: Bool = false
    
    var body: some View {
        Button { isTorrentAddSheet.toggle() } label: {
            VStack {
                HStack { Text(article.title ?? "No Title").lineLimit(2); Spacer() }
                HStack(spacing: 3) {
                    if let category = article.category { Text(category) }
                    if let size = article.size {
                        Text("•")
                        Text(size)
                    }
                    Spacer()
                }
                .foregroundColor(.secondary)
                .font(.footnote)
                .lineLimit(1)
            }
                .foregroundColor(.primary)
                .sheet(isPresented: $isTorrentAddSheet) { if let url = URL(string: article.torrentURL ?? article.link ?? "") { TorrentAddView(torrentUrls: .constant([url])) } }
        }
    }
}
