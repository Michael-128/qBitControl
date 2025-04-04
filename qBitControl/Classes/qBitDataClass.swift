//
import SwiftUI
import Foundation

class qBitData: ObservableObject {
    static let shared = qBitData()
    
    var rid = 0
    @Published var serverState: ServerState?
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
        qBittorrent.getMainData(rid: rid) { mainData in
            DispatchQueue.main.async {
                self.rid = mainData.rid
                
                if let partialServerState = mainData.server_state {
                    if let existingServerState = self.serverState {
                        // Update existing ServerState with new data
                        var updatedServerState = existingServerState
                        updatedServerState.update(from: partialServerState)
                        self.serverState = updatedServerState
                    } else if let newServerState = ServerState(from: partialServerState) {
                        // Create a new ServerState if none exists
                        self.serverState = newServerState
                    }
                    
                    
                    let newDlTransferInfo = TransferInfo(fetchDate: Date(), info_speed: partialServerState.dl_info_speed ?? 0)
                    self.dlTransferData.append(newDlTransferInfo)
                    
                    // Limit the history to the last 30 entries
                    if self.dlTransferData.count > 20 { self.dlTransferData.removeFirst(self.dlTransferData.count - 20) }
                    
                    let newUpTransferInfo = TransferInfo(fetchDate: Date(), info_speed: partialServerState.up_info_speed ?? 0)
                    self.upTransferData.append(newUpTransferInfo)
                    
                    // Limit the history to the last 30 entries
                    if self.upTransferData.count > 20 { self.upTransferData.removeFirst(self.upTransferData.count - 20) }
                }
            }
        }
    }
}
