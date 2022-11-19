//
//  TorrentPeersDetailsView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 02/11/2022.
//

import SwiftUI

struct TorrentPeersDetailsView: View {
    
    @Binding var peer: Peer
    
    func listElement(label: String, value: String) -> some View {
        Button(action: {UIPasteboard.general.string = "\(value)"}) {
            HStack {
                Text("\(label)")
                Spacer()
                Text("\(value)")
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
            }
        }.foregroundColor(Color.primary)
    }
    
    var body: some View {
        List {
            Section(header: Text("Information")) {
                listElement(label: "Client", value: peer.client)
                listElement(label: "Country", value: peer.country)
                listElement(label: "IP", value: peer.ip)
                listElement(label: "Port", value: "\(peer.port)")
                listElement(label: "Connection", value: peer.connection)
                listElement(label: "Files", value: peer.files)
                listElement(label: "Flags", value: peer.flags)
            }
            
            Section(header: Text("Activity")) {
                listElement(label: "Progress", value: "\(String(format: "%.1f", peer.progress*100))%")
                listElement(label: "Relevance", value: "\(String(format: "%.1f", peer.relevance*100))%")
                
                listElement(label: "Download Speed", value: "\(qBittorrent.getFormatedSize(size: peer.dl_speed))/s")
                listElement(label: "Downloaded", value: "\(qBittorrent.getFormatedSize(size: peer.downloaded))")
                
                listElement(label: "Upload Speed", value: "\(qBittorrent.getFormatedSize(size: peer.up_speed))/s")
                listElement(label: "Uploaded", value: "\(qBittorrent.getFormatedSize(size: peer.uploaded))")
            }
            
            .navigationTitle("Peer Details")
        }
    }
}
