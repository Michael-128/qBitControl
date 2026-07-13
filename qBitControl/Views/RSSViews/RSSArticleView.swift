import SwiftUI

struct RSSArticleView: View {
    let article: RSSFeed.Article
    let onTap: () -> Void
    
    private var hasValidTorrentLink: Bool {
        let url = article.torrentURL ?? article.link ?? ""
        if url.isEmpty { return false }
        if url.contains("magnet:") || url.hasSuffix(".torrent") { return true }
        return false
    }
    
    var body: some View {
        VStack {
            HStack {
                if !hasValidTorrentLink {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
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
        .foregroundColor(.primary)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
