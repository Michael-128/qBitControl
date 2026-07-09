//
//  DemoMode.swift
//  qBitControl
//

import Foundation
import Combine
import SwiftUI

@MainActor
enum DemoMode {
    
    static let alertMessage = CurrentValueSubject<String?, Never>(nil)
    
    static func activate() {
        let mockClient = MockTorrentClient()
        let guardClient = DemoGuardClient(mock: mockClient)
        ServersHelper.shared.client = guardClient
        ServersHelper.shared.activeServerId = "demo"
        ServersHelper.shared.isLoggedIn = true
        
        Task {
            await ServersHelper.shared.fetchMetadata()
            qBitData.shared.resetTransferHistory()
            await qBitData.shared.getMainData()
        }
    }
    
    static func deactivate() {
        ServersHelper.shared.activeServerId = nil
        ServersHelper.shared.client = nil
        ServersHelper.shared.isLoggedIn = false
        ServersHelper.shared.clearCache()
    }
}