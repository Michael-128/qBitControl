import SwiftUI

class TorrentDetailsViewModel: ObservableObject {
    @Published public var torrent: Torrent
    @Published public var isDeleteAlert: Bool = false
    
    private var timer: Timer?
    
    init(torrent: Torrent) {
        self.torrent = torrent
    }
    
    func getTorrent() {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/info", queryItems: [URLQueryItem(name:"hashes", value: torrent.hash)])
        
        qBitRequest.requestTorrentListJSON(request: request) {
            torrent in
            if let torrent = torrent.first {
                self.torrent = torrent
            }
        }
    }
}
