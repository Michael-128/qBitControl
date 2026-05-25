import SwiftUI

struct SearchRowView: View {
    let result: SearchResult
    let onTap: (SearchResult) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(result.fileName ?? "")
                .lineLimit(2)
            HStack(spacing: 3) {
                Text(qBittorrent.getFormatedSize(size: result.fileSize ?? 0))
                Text("•")
                Image(systemName: "arrow.up")
                Text("\(result.nbSeeders ?? 0)")
                Text("•")
                Image(systemName: "arrow.down")
                Text("\(result.nbLeechers ?? 0)")
                if let engine = result.engineName, !engine.isEmpty {
                    Text("•")
                    Text(engine)
                }
                Spacer()
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.onTap(result)
        }
        .contextMenu {
            Button {
                self.onTap(result)
            } label: {
                Label("Download", systemImage: "arrow.down.circle")
            }
            if let fileUrl = result.fileUrl, !fileUrl.isEmpty {
                Button {
                    UIPasteboard.general.string = fileUrl
                } label: {
                    Label("Copy Link", systemImage: "doc.on.doc")
                }
            }
            if let descrLink = result.descrLink, !descrLink.isEmpty {
                Button {
                    if let url = URL(string: descrLink) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open in Browser", systemImage: "safari")
                }
            }
        }
    }
}
