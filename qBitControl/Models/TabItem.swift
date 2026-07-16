//
//  TabItem.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 01/10/2025.
//
import SwiftUI

struct TabItem {
    let label: String
    let systemImage: String
    let value: Tab
    let content: () -> AnyView
    var resetsOnServerChange: Bool = true
    
    enum Tab {
        case tasks
        case rss
        case stats
        case servers
        case settings
        case search
    }
}
