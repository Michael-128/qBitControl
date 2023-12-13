//
//  TorrentDetailsPeersView.swift
//  qBitControl
//

import SwiftUI

struct TorrentPeersDemo: View {
    @Binding var torrentHash: String
    
    @State private var peers: [Peer] = []
    @State private var timer: Timer?
    @State private var isLoaded = true
    
    var body: some View {
        VStack {
            if isLoaded {
                List {
                    Section(header: Text("3 peers")) {
                        TorrentDetailsPeersRowView(peer: .constant(Peer(client: "example client", connection: "BT", country: "Poland", country_code: "pl", dl_speed: 10000, downloaded: 100000, files: "example file", flags: "e", flags_desc: "e", ip: "192.168.1.1", port: 22222, progress: 1, relevance: 1, up_speed: 10000, uploaded: 10000)))
                        TorrentDetailsPeersRowView(peer: .constant(Peer(client: "example client", connection: "BT", country: "Netherlands", country_code: "nl", dl_speed: 10000, downloaded: 100000, files: "example file", flags: "e", flags_desc: "e", ip: "192.168.1.1", port: 22222, progress: 1, relevance: 1, up_speed: 10000, uploaded: 10000)))
                        TorrentDetailsPeersRowView(peer: .constant(Peer(client: "example client", connection: "BT", country: "Germany", country_code: "de", dl_speed: 10000, downloaded: 100000, files: "example file", flags: "e", flags_desc: "e", ip: "192.168.1.1", port: 22222, progress: 1, relevance: 1, up_speed: 10000, uploaded: 10000)))
                    }
                    
                    .navigationTitle("Peers")
                }
            } else {
                ProgressView().progressViewStyle(.circular)
                    .navigationTitle("Peers")
            }
        }
    }
}
