//
//  qBitDataClass.swift
//  qBitControl
//

import SwiftUI
import Foundation

@MainActor
class qBitData: ObservableObject {
    static let shared = qBitData()
    
    var rid = 0
    @Published var serverState: ServerState?
    @Published var dlTransferData: [TransferInfo] = []
    @Published var upTransferData: [TransferInfo] = []
    @Published var connectionStatus: ConnectionStatus = .connected
    let cacheManager = TorrentCacheManager()
    
    private var pollingTask: Task<Void, Never>?
    private var fetchInterval: UInt64 = 2_000_000_000 // 2 seconds
    
    init() {
        let date = Date()
        
        for n in stride(from: -30, to: 0, by: 2) {
            dlTransferData.append(TransferInfo(fetchDate: date.addingTimeInterval(Double(n)), info_speed: 0))
            upTransferData.append(TransferInfo(fetchDate: date.addingTimeInterval(Double(n)), info_speed: 0))
        }
        
        self.startPolling()
    }
    
    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                await self.getMainData()
                do {
                    try await Task.sleep(nanoseconds: fetchInterval)
                } catch {
                    break
                }
            }
        }
    }
    
    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    func resetTransferHistory() {
        let date = Date()
        self.dlTransferData.removeAll()
        self.upTransferData.removeAll()
        for n in stride(from: -30, to: 0, by: 2) {
            self.dlTransferData.append(TransferInfo(fetchDate: date.addingTimeInterval(Double(n)), info_speed: 0))
            self.upTransferData.append(TransferInfo(fetchDate: date.addingTimeInterval(Double(n)), info_speed: 0))
        }
        self.serverState = nil
    }
    
    func getMainData() async {
        guard let client = ServersHelper.shared.client, ServersHelper.shared.isLoggedIn else {
            if self.connectionStatus != .connected {
                self.connectionStatus = .connected
            }
            return
        }
        
        do {
            let mainData = try await client.getMainData(rid: rid)
            self.rid = mainData.rid
            
            self.cacheManager.merge(mainData: mainData)
            
            if let partialServerState = mainData.server_state {
                if let existingServerState = self.serverState {
                    // Update existing ServerState with new data
                    var updatedServerState = existingServerState
                    updatedServerState.update(from: partialServerState)
                    self.serverState = updatedServerState
                } else {
                    // Create a new ServerState if none exists
                    self.serverState = ServerState(from: partialServerState)
                }
                
                let newDlTransferInfo = TransferInfo(fetchDate: Date(), info_speed: partialServerState.dl_info_speed ?? 0)
                self.dlTransferData.append(newDlTransferInfo)
                
                // Limit the history to the last 20 entries
                if self.dlTransferData.count > 20 { self.dlTransferData.removeFirst(self.dlTransferData.count - 20) }
                
                let newUpTransferInfo = TransferInfo(fetchDate: Date(), info_speed: partialServerState.up_info_speed ?? 0)
                self.upTransferData.append(newUpTransferInfo)
                
                // Limit the history to the last 20 entries
                if self.upTransferData.count > 20 { self.upTransferData.removeFirst(self.upTransferData.count - 20) }
            }
            self.connectionStatus = .connected
        } catch {
            print("Telemetry fetch failed: \(error)")
            self.connectionStatus = .offline
        }
    }
}
