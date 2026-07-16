//
//  ServerRowView.swift
//  qBitControl
//

import SwiftUI

struct ServerRowView: View {
    @ObservedObject var serversHelper = ServersHelper.shared
    let server: Server
    let setActiveSheet: (ActiveSheet) -> Void
    
    var body: some View {
        HStack() {
            Label(server.name.isEmpty ? server.url : server.name, systemImage: "server.rack")

            Spacer()
            
            if(serversHelper.activeServerId == server.id) {
                Image(systemName: "checkmark")
            }
            else if(serversHelper.connectingServerId == server.id) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(.leading, 1)
            }
        }
        .contextMenu() {
            Button {
                setActiveSheet(.edit(serverId: server.id))
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                serversHelper.removeServer(id: server.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
