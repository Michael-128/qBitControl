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
        
        // 1. Reset Cache on Full Update
        if mainData.full_update == true {
            self.torrents.removeAll()
            self.lockedHashes.removeAll()
        }
        
        // 2. Apply Updates & Adds
        if let torrentsUpdate = mainData.torrents {
            for (hash, partial) in torrentsUpdate {
                // SKIP sync updates for optimistically locked torrents
                if let lockExpiration = lockedHashes[hash], lockExpiration > now {
                    continue
                }
                
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
    
    // Method to apply optimistic updates
    func updateTorrentsOptimistically(hashes: [String], mutation: (inout Torrent) -> Void) {
        let lockExpiration = Date().addingTimeInterval(3.0)
        var updatedTorrents = torrents
        var didUpdate = false
        for hash in hashes {
            if var torrent = updatedTorrents[hash] {
                mutation(&torrent)
                updatedTorrents[hash] = torrent
                lockedHashes[hash] = lockExpiration
                didUpdate = true
            }
        }
        if didUpdate {
            torrents = updatedTorrents
        }
    }
    
    // Method to optimistically delete torrents
    func deleteTorrentsOptimistically(hashes: [String]) {
        guard !hashes.isEmpty else {
            return
        }
        let lockExpiration = Date().addingTimeInterval(3.0)
        var updatedTorrents = torrents
        for hash in hashes {
            updatedTorrents.removeValue(forKey: hash)
            lockedHashes[hash] = lockExpiration
        }
        torrents = updatedTorrents
    }
}
