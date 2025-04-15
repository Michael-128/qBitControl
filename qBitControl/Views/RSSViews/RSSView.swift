//
//  RSSView.swift
//  qBitControl
//

import SwiftUI

struct RSSView: View {
    var body: some View {
        VStack {
            NavigationStack {                
                RSSNodeView(path: ["RSS"])
            }
        }
    }
}
