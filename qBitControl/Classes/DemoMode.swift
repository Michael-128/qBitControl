//
//  DemoMode.swift
//  qBitControl
//

import Foundation
import SwiftUI

@MainActor
enum DemoMode {
    
    static func activate() {
        let mockClient = MockTorrentClient()
        ServersHelper.shared.client = mockClient
        ServersHelper.shared.isLoggedIn = true
        
        Task {
            await ServersHelper.shared.fetchMetadata()
            qBitData.shared.resetTransferHistory()
            await qBitData.shared.getMainData()
        }
    }
    
    static func deactivate() {
        ServersHelper.shared.client = nil
        ServersHelper.shared.isLoggedIn = false
        ServersHelper.shared.clearCache()
    }
}