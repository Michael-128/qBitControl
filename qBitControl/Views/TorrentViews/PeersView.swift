//
//  TorrentDetailsPeersView.swift
//  qBitControl
//

import SwiftUI

struct PeersView: View {
    @Binding var torrentHash: String
    
    @State private var peers: [Peer] = []
    @State private var pollingTask: Task<Void, Never>?
    @State private var isLoaded = false
    
    private var client: TorrentClientProtocol {
        ServersHelper.shared.client ?? MockTorrentClient()
    }
    
    func getPeers() {
        Task {
            await getPeersAsync()
        }
    }
    
    private func getPeersAsync() async {
        do {
            let response = try await client.getPeers(hash: torrentHash)
            var refreshedPeers: [Peer] = []
            for (_, value) in response.peers {
                refreshedPeers.append(value)
            }
            refreshedPeers.sort(by: { $0.dl_speed > $1.dl_speed })
            self.peers = refreshedPeers
            self.isLoaded = true
        } catch {
            AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "get_peers_failed", errorDescription: error.localizedDescription))
        }
    }
    
    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                await getPeersAsync()
                do {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
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
        }
        .onAppear() {
            startPolling()
        }
        .onDisappear() {
            stopPolling()
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
