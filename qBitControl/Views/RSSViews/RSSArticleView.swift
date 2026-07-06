import SwiftUI

struct RSSArticleView: View {
    let article: RSSFeed.Article
    let onTap: () -> Void
    
    var body: some View {
        VStack {
            HStack { Text(article.title ?? "No Title").lineLimit(2); Spacer() }
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
