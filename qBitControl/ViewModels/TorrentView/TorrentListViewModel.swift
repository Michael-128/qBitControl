import SwiftUI

class TorrentListViewModel: ObservableObject {
    @ObservedObject private var torrentListHelperViewModel: TorrentListHelperViewModel
    
    @Published public var isFilterSheet = false
    @Published public var torrentUrls: [URL] = []
    
    init(_ torrentListHelperViewModel: TorrentListHelperViewModel) {
        self.torrentListHelperViewModel = torrentListHelperViewModel
    }
    
    func openUrl(url: URL) {
        if url.absoluteString.contains("file") || url.absoluteString.contains("magnet") {
            torrentListHelperViewModel.isTorrentAddView = true
            torrentUrls.append(url)
        }
    }
    
    func toggleTorrentAddView() {
        self.torrentListHelperViewModel.isTorrentAddView.toggle()
    }
}

