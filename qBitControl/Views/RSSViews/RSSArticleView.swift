import SwiftUI

struct RSSArticleView: View {
    @State var article: RSSFeed.Article
    var feedTitle: String = ""
    @State var isTorrentAddSheet: Bool = false

    var body: some View {
        Button {
            isTorrentAddSheet.toggle()
        } label: {
            HStack {
                if article.isRead == false {
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                }
                VStack(alignment: .leading) {
                    HStack {
                        Text(article.title ?? "No Title").lineLimit(2)
                        Spacer()
                    }
                    if let description = article.description {
                        HStack(spacing: 3) {
                            Text(description)
                            Spacer()
                        }
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .lineLimit(1)
                    }
                }
            }
            .foregroundColor(.primary)
            .sheet(isPresented: $isTorrentAddSheet) {
                if let url = URL(string: article.torrentURL ?? article.link ?? "") {
                    TorrentAddView(torrentUrls: .constant([url]))
                }
            }
        }
        .contextMenu {
            Button {
                isTorrentAddSheet = true
            } label: {
                Label("Download", systemImage: "arrow.down.circle")
            }
            Button {
                if let id = article.title {
                    qBittorrent.markRSSAsRead(itemPath: feedTitle, articleId: id)
                }
            } label: {
                Label("Mark as Read", systemImage: "envelope.open")
            }
            if let link = article.link, let url = URL(string: link) {
                Button {
                    UIApplication.shared.open(url)
                } label: {
                    Label("Open in Browser", systemImage: "safari")
                }
            }
            if let torrentURL = article.torrentURL {
                Button {
                    UIPasteboard.general.string = torrentURL
                } label: {
                    Label("Copy Link", systemImage: "doc.on.doc")
                }
            }
        }
    }
}
