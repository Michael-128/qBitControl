//
//  TorrentDetailsPeersView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 02/11/2022.
//

import SwiftUI

struct TorrentDetailsPeersView: View {
    @Binding var torrentHash: String
    
    @State private var peers: [Peer] = []
    @State private var timer: Timer?
    
    func getPeers() {
        var refreshedPeers: [Peer] = []
        
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/sync/torrentPeers", queryItems: [URLQueryItem(name: "hash", value: torrentHash)])
        
        qBitRequest.requestPeersJSON(request: request, completionHandler: {
            peers in
            for (_, value) in peers.peers {
                refreshedPeers.append(value)
            }
            refreshedPeers.sort(by: {$0.dl_speed > $1.dl_speed})
            self.peers = refreshedPeers
        })
    }
    
    var body: some View {
        List {
            Section(header: Text("\(peers.count) peers")) {
                ForEach($peers, id: \.ip) {
                    peer in
                    TorrentDetailsPeersRowView(peer: peer)
                }
            }
            
            .navigationTitle("Peers")
        }.onAppear() {
            getPeers()
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                timer in
                getPeers()
            }
        }.onDisappear() {
            timer?.invalidate()
        }
    }
}

struct TorrentDetailsPeersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TorrentDetailsPeersRowView(peer: .constant(Peer(client: "example client", connection: "BT", country: "Poland", country_code: "pl", dl_speed: 10000, downloaded: 100000, files: "example file", flags: "e", flags_desc: "e", ip: "192.168.1.1", port: 22222, progress: 1, relevance: 1, up_speed: 10000, uploaded: 10000)))
        }
    }
}
