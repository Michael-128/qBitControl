//
//  RSSView.swift
//  qBitControl
//

import SwiftUI

struct RSSView: View {
    @ObservedObject private var viewModel = RSSViewModel()
    
    var body: some View {
        VStack {
            if let rssNode = viewModel.RSSNode {
                NavigationStack {
                    RSSNodeView(rssNode: rssNode)
                }
            }
        }.navigationTitle("Feeds")
    }
}
