import Foundation
import Combine

@MainActor
class TorrentCacheManager: ObservableObject {
    @Published var torrents: [String: Torrent] = [:]
    
    // Lock expiration timestamps for torrent hashes
    private var lockedHashes: [String: Date] = [:]
    
    func merge(mainData: MainData) {
        let now = Date()
        // Clear expired locks
        lockedHashes = lockedHashes.filter { $0.value > now }
        
        var workingTorrents = self.torrents
        
        // 1. Reset Cache on Full Update
        if mainData.full_update == true {
            workingTorrents.removeAll()
            self.lockedHashes.removeAll()
        }
        
        // 2. Apply Updates & Adds
        if let torrentsUpdate = mainData.torrents {
            for (hash, partial) in torrentsUpdate {
                // SKIP sync updates for optimistically locked torrents
                if let lockExpiration = lockedHashes[hash], lockExpiration > now {
                    continue
                }
                
                if let existing = workingTorrents[hash] {
                    var updated = existing
                    updated.update(from: partial)
                    workingTorrents[hash] = updated
                } else {
                    let newTorrent = Torrent(from: partial, hash: hash)
                    workingTorrents[hash] = newTorrent
                }
            }
        }
        
        // 3. Prune Deleted Torrents
        if let removedHashes = mainData.torrents_removed {
            for hash in removedHashes {
                workingTorrents.removeValue(forKey: hash)
            }
        }
        
        self.torrents = workingTorrents
    }
    
    // Method to apply optimistic updates
    func updateTorrentsOptimistically(hashes: [String], mutation: (inout Torrent) -> Void) {
        let lockExpiration = Date().addingTimeInterval(3.0)
        for hash in hashes {
            if var torrent = torrents[hash] {
                mutation(&torrent)
                torrents[hash] = torrent
                lockedHashes[hash] = lockExpiration
            }
        }
    }
    
    // Method to optimistically delete torrents
    func deleteTorrentsOptimistically(hashes: [String]) {
        let lockExpiration = Date().addingTimeInterval(3.0)
        for hash in hashes {
            torrents.removeValue(forKey: hash)
            lockedHashes[hash] = lockExpiration
        }
    }
}
