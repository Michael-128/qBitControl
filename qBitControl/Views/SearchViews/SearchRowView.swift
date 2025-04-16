import SwiftUI

struct SearchRowView: View {
    let result: SearchResult
    @State private var isTorrentAddSheet: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text(result.fileName ?? "")
                    .lineLimit(2)
                Spacer()
            }
            HStack(spacing: 3) {
                Text(qBittorrent.getFormatedSize(size: result.fileSize ?? 0))
                Text("•")
                Group {
                    Image(systemName: "square.and.arrow.up")
                    Text("\(result.nbSeeders ?? 0)")
                }
                Text("•")
                Group {
                    Image(systemName: "square.and.arrow.down")
                    Text("\(result.nbLeechers ?? 0)")
                }
                Spacer()
            }.font(.footnote)
                .foregroundStyle(Color.gray)
        }.contentShape(Rectangle())
            .onTapGesture {
                self.isTorrentAddSheet.toggle()
            }.sheet(isPresented: $isTorrentAddSheet) { if let url = URL(string: result.fileUrl ?? "") { TorrentAddView(torrentUrls: .constant([url]), magnetOverride: true) } }
    }
}
