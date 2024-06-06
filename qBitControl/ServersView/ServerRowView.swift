//
//  ServerRowView.swift
//  qBitControl
//

import SwiftUI

struct ServerRowView: View {
    @State var id: String
    @State var friendlyName: String
    @State var url: String
    @State var username: String
    @State var password: String
    @Binding var activeServerId: String
    
    public var serversHelper: ServersHelper
    public var refreshServerList: () -> Void
    
    @Binding var isConnecting: [String: Bool]
    @Binding var isLoggedIn: Bool
    
    func getServerName() -> String {
        if (!friendlyName.isEmpty) { return friendlyName } else { return url }
    }
    
    func isServerConnected() -> Bool {
        return (activeServerId == id && isLoggedIn)
    }
    
    func isServerConnecting() -> Bool {
        return isConnecting[id] ?? false
    }
    
    func removeServer() -> Void {
        serversHelper.removeServer(id: id)
        refreshServerList()
    }
    
    var body: some View {
        HStack() {
            Text(getServerName())
            
            Spacer()
            
            if(isServerConnected()) {
                Image(systemName: "checkmark")
            }
            else if(isServerConnecting()) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(.leading, 1)
            }
        }
        .contextMenu() {
            Button(role: .destructive) {
                removeServer()
            } label: {
                Image(systemName: "trash")
                Text("Delete")
            }
        }
    }
}
