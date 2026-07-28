//
//  qBitControltApp.swift
//  qBitControl
//

import SwiftUI

@main
struct qBitControlApp: App {
    init() {
        if CommandLine.arguments.contains("-uitest-8k-mocks") || ProcessInfo.processInfo.environment["MOCK_TORRENT_COUNT"] != nil {
            DemoMode.activate()
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
