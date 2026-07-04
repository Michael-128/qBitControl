import Foundation
import Combine

@MainActor
class TorrentCacheManager: ObservableObject {
    @Published var torrents: [String: Torrent] = [:]
    
    func merge(mainData: MainData) {
        // 1. Reset Cache on Full Update
        if mainData.full_update == true {
            self.torrents.removeAll()
        }
        
        // 2. Apply Updates & Adds
        if let torrentsUpdate = mainData.torrents {
            for (hash, partial) in torrentsUpdate {
                if let existing = self.torrents[hash] {
                    var updated = existing
                    updated.update(from: partial)
                    self.torrents[hash] = updated
                } else {
                    let newTorrent = Torrent(from: partial, hash: hash)
                    self.torrents[hash] = newTorrent
                }
            }
        }
        
        // 3. Prune Deleted Torrents
        if let removedHashes = mainData.torrents_removed {
            for hash in removedHashes {
                self.torrents.removeValue(forKey: hash)
            }
        }
    }
}
