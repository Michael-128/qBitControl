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
    
    private var isFetching = false
    private var latestDlSpeed = 0
    private var latestUpSpeed = 0
    
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
                // Trigger the network call in the background on the MainActor
                Task { @MainActor in
                    await self.getMainData()
                }
                
                // Immediately append the latest known speed to the timeline history
                self.appendTransferInfo()
                
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
        self.latestDlSpeed = 0
        self.latestUpSpeed = 0
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
        
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }
        
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
                
                self.latestDlSpeed = partialServerState.dl_info_speed ?? 0
                self.latestUpSpeed = partialServerState.up_info_speed ?? 0
            }
            self.connectionStatus = .connected
        } catch {
            AppLogger.log(.error, GeneralErrorPayload(category: .system, eventName: "telemetry_fetch_failed", errorDescription: error.localizedDescription))
            
            self.latestDlSpeed = 0
            self.latestUpSpeed = 0
            self.rid = 0 // Reset rid on network failure to force full update on recovery
            
            if let networkError = error as? NetworkError, networkError == .unauthorized {
                do {
                    try await ServersHelper.shared.reauthenticate()
                } catch {
                    // Silent reauth failed. Permanent failure is handled in reauthenticate()
                }
            } else if self.connectionStatus == .offline {
                // Already offline — attempt recovery by creating a fresh URLSession client
                await ServersHelper.shared.refreshClient()
            }
            
            self.connectionStatus = .offline
        }
    }
    
    private func appendTransferInfo() {
        let dlPoint = TransferInfo(fetchDate: Date(), info_speed: latestDlSpeed)
        self.dlTransferData.append(dlPoint)
        if self.dlTransferData.count > 20 { self.dlTransferData.removeFirst(self.dlTransferData.count - 20) }
        
        let upPoint = TransferInfo(fetchDate: Date(), info_speed: latestUpSpeed)
        self.upTransferData.append(upPoint)
        if self.upTransferData.count > 20 { self.upTransferData.removeFirst(self.upTransferData.count - 20) }
    }
}
