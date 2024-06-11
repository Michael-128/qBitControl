//
//  TorrentPeersDetailsView.swift
//  qBitControl
//

import SwiftUI

struct TorrentPeersDetailsView: View {
    
    @Binding var peer: Peer
    
    var body: some View {
        List {
            Section(header: Text("Information")) {
                ListElement(label: "Client", value: peer.client)
                ListElement(label: "Country", value: peer.country)
                ListElement(label: "IP", value: peer.ip)
                ListElement(label: "Port", value: "\(peer.port)")
                ListElement(label: "Connection", value: peer.connection)
                ListElement(label: "Files", value: peer.files)
                ListElement(label: "Flags", value: peer.flags)
            }
            
            Section(header: Text("Activity")) {
                ListElement(label: "Progress", value: "\(String(format: "%.1f", peer.progress*100))%")
                ListElement(label: "Relevance", value: "\(String(format: "%.1f", peer.relevance*100))%")
                
                ListElement(label: "Download Speed", value: "\(qBittorrent.getFormatedSize(size: peer.dl_speed))/s")
                ListElement(label: "Downloaded", value: "\(qBittorrent.getFormatedSize(size: peer.downloaded))")
                
                ListElement(label: "Upload Speed", value: "\(qBittorrent.getFormatedSize(size: peer.up_speed))/s")
                ListElement(label: "Uploaded", value: "\(qBittorrent.getFormatedSize(size: peer.uploaded))")
            }
            
            .navigationTitle("Peer Details")
        }
    }
}
