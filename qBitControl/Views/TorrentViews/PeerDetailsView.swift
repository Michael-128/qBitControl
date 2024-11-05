//
//  TorrentPeersDetailsView.swift
//  qBitControl
//

import SwiftUI

struct PeerDetailsView: View {
    
    @Binding var peer: Peer
    
    var body: some View {
        List {
            Section(header: Text("Information")) {
                CustomLabelView(label: "Client", value: peer.client)
                CustomLabelView(label: "Country", value: peer.country)
                CustomLabelView(label: "IP", value: peer.ip)
                CustomLabelView(label: "Port", value: "\(peer.port)")
                CustomLabelView(label: "Connection", value: peer.connection)
                CustomLabelView(label: "Files", value: peer.files)
                CustomLabelView(label: "Flags", value: peer.flags)
            }
            
            Section(header: Text("Activity")) {
                CustomLabelView(label: "Progress", value: "\(String(format: "%.1f", peer.progress*100))%")
                CustomLabelView(label: "Relevance", value: "\(String(format: "%.1f", peer.relevance*100))%")
                
                CustomLabelView(label: "Download Speed", value: "\(qBittorrent.getFormatedSize(size: peer.dl_speed))/s")
                CustomLabelView(label: "Downloaded", value: "\(qBittorrent.getFormatedSize(size: peer.downloaded))")
                
                CustomLabelView(label: "Upload Speed", value: "\(qBittorrent.getFormatedSize(size: peer.up_speed))/s")
                CustomLabelView(label: "Uploaded", value: "\(qBittorrent.getFormatedSize(size: peer.uploaded))")
            }
            
            .navigationTitle("Peer Details")
        }
    }
}
