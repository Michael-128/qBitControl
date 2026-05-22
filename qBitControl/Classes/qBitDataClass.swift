//
import SwiftUI
import Foundation

class qBitData: ObservableObject {
    static let shared = qBitData()

    var rid = 0
    @Published var serverState: ServerState?
    @Published var torrents: [String: Torrent] = [:]
    @Published var sortedTorrents: [Torrent] = []
    @Published var dlTransferData: [TransferInfo] = []
    @Published var upTransferData: [TransferInfo] = []

    private var timer: Timer?
    private var fetchInterval: TimeInterval = 2

    init() {
        let date = Date()

        for n in stride(from: -30, to: 0, by: 2) {
            dlTransferData.append(TransferInfo(fetchDate: date.addingTimeInterval(Double(n)), info_speed: 0))
            upTransferData.append(TransferInfo(fetchDate: date.addingTimeInterval(Double(n)), info_speed: 0))
        }

        self.getMainData()

        timer = Timer.scheduledTimer(withTimeInterval: fetchInterval, repeats: true) {
            _ in
            self.getMainData()
        }
    }

    func getMainData() {
        qBittorrent.getMainData(rid: rid) { result in
            DispatchQueue.main.async {
                guard case .success(let mainData) = result else {
                    if case .failure(let error) = result {
                       print("Error: \(error)")
                    }
                    return
                }

                self.rid = mainData.rid

                if mainData.full_update == true {
                    self.torrents.removeAll()
                }

                if let changedTorrents = mainData.torrents {
                    for (hash, partial) in changedTorrents {
                        if var existing = self.torrents[hash] {
                            existing.update(from: partial)
                            self.torrents[hash] = existing
                        } else {
                            if let torrent = Torrent(hash: hash, from: partial) {
                                self.torrents[hash] = torrent
                            }
                        }
                    }
                }

                if let removed = mainData.torrents_removed {
                    for hash in removed {
                        self.torrents.removeValue(forKey: hash)
                    }
                }

                self.sortedTorrents = Array(self.torrents.values)

                if let partialServerState = mainData.server_state {
                    if let existingServerState = self.serverState {
                        var updatedServerState = existingServerState
                        updatedServerState.update(from: partialServerState)
                        self.serverState = updatedServerState
                    } else if let newServerState = ServerState(from: partialServerState) {
                        self.serverState = newServerState
                    }

                    let newDlTransferInfo = TransferInfo(fetchDate: Date(), info_speed: partialServerState.dl_info_speed ?? 0)
                    self.dlTransferData.append(newDlTransferInfo)
                    if self.dlTransferData.count > 20 { self.dlTransferData.removeFirst(self.dlTransferData.count - 20) }

                    let newUpTransferInfo = TransferInfo(fetchDate: Date(), info_speed: partialServerState.up_info_speed ?? 0)
                    self.upTransferData.append(newUpTransferInfo)
                    if self.upTransferData.count > 20 { self.upTransferData.removeFirst(self.upTransferData.count - 20) }
                }
            }
        }
    }
}
