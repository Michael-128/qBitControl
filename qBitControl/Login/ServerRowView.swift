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
    
    var body: some View {
        HStack() {
            if friendlyName != "" {
                Text(friendlyName)
            } else {
                Text(url)
            }
            
            if(activeServerId == id) {
                Spacer()
                Image(systemName: "checkmark")
            } else if isConnecting[id] ?? false {
                Spacer()
                ProgressView().progressViewStyle(.circular)
                    .padding(.leading, 1)
            }
        }
        .contextMenu() {
            Button(role: .destructive) {
                serversHelper.removeServer(id: id)
                refreshServerList()
            } label: {
                Image(systemName: "trash")
                Text("Delete")
            }
        }
    }
}

struct ServerRowView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
