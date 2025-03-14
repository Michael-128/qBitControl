//
//  TorrentDetailsPeersView.swift
//  qBitControl
//

import SwiftUI

struct PeersView: View {
    @Binding var torrentHash: String
    
    @State private var peers: [Peer] = []
    @State private var timer: Timer?
    @State private var isLoaded = false
    
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
            self.isLoaded = true
        })
    }
    
    var body: some View {
        VStack {
            if isLoaded {
                List {
                    Section(header: Text("\(peers.count) " + NSLocalizedString("Peers", comment: ""))) {
                        ForEach($peers, id: \.ip) {
                            peer in
                            PeerRowView(peer: peer)
                        }
                    }
                    
                    .navigationTitle("Peers")
                }
            } else {
                ProgressView().progressViewStyle(.circular)
                    .navigationTitle("Peers")
            }
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
            PeerRowView(peer: .constant(Peer(client: "example client", connection: "BT", country: "Poland", country_code: "pl", dl_speed: 10000, downloaded: 100000, files: "example file", flags: "e", flags_desc: "e", ip: "192.168.1.1", port: 22222, progress: 1, relevance: 1, up_speed: 10000, uploaded: 10000)))
        }
    }
}
