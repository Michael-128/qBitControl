import Foundation
import Combine

@MainActor
class TorrentCacheManager: ObservableObject {
    @Published var torrents: [String: Torrent] = [:]

    // Lock expiration timestamps for torrent hashes
    private var lockedHashes: [String: Date] = [:]

    // Each assignment to the @Published `torrents` re-runs every subscriber
    // (the torrent list re-filters and re-sorts the whole list), so every method
    // below mutates a local copy and publishes it exactly once.

    func merge(mainData: MainData) {
        let now = Date()
        // Clear expired locks
        lockedHashes = lockedHashes.filter { $0.value > now }

        var newTorrents = self.torrents

        // 1. Reset Cache on Full Update
        if mainData.full_update == true {
            newTorrents.removeAll(keepingCapacity: true)
            self.lockedHashes.removeAll()
        }

        // 2. Apply Updates & Adds
        if let torrentsUpdate = mainData.torrents {
            for (hash, partial) in torrentsUpdate {
                // SKIP sync updates for optimistically locked torrents
                if let lockExpiration = lockedHashes[hash], lockExpiration > now {
                    continue
                }

                if var existing = newTorrents[hash] {
                    existing.update(from: partial)
                    newTorrents[hash] = existing
                } else {
                    newTorrents[hash] = Torrent(from: partial, hash: hash)
                }
            }
        }

        // 3. Prune Deleted Torrents
        if let removedHashes = mainData.torrents_removed {
            for hash in removedHashes {
                newTorrents.removeValue(forKey: hash)
            }
        }

        self.torrents = newTorrents
    }

    // Method to apply optimistic updates
    func updateTorrentsOptimistically(hashes: [String], mutation: (inout Torrent) -> Void) {
        let lockExpiration = Date().addingTimeInterval(3.0)
        var newTorrents = self.torrents
        for hash in hashes {
            if var torrent = newTorrents[hash] {
                mutation(&torrent)
                newTorrents[hash] = torrent
                lockedHashes[hash] = lockExpiration
            }
        }
        self.torrents = newTorrents
    }

    // Method to optimistically delete torrents
    func deleteTorrentsOptimistically(hashes: [String]) {
        let lockExpiration = Date().addingTimeInterval(3.0)
        var newTorrents = self.torrents
        for hash in hashes {
            newTorrents.removeValue(forKey: hash)
            lockedHashes[hash] = lockExpiration
        }
        self.torrents = newTorrents
    }
}
