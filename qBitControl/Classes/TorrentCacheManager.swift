import Foundation
import Combine

@MainActor
class TorrentCacheManager: ObservableObject {
    @Published var torrents: [String: Torrent] = [:]
    
    func merge(mainData: MainData) {
        // Empty stub for TDD compilation
    }
}
