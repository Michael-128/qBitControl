import SwiftUI

enum ActiveSheet: Identifiable {
    case add
    case edit(serverId: String)
    
    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let serverId):
            return serverId
        }
    }
}

struct ServersView: View {
    @ObservedObject var serversHelper = ServersHelper.shared
    
    @State var activeSheet: ActiveSheet?
    @State var isTroubleConnecting = false
    
    func setActiveSheet(sheet: ActiveSheet) {
        activeSheet = sheet
    }
    
    func sortServers(server1: Server, server2: Server) -> Bool {
        let name1 = server1.name.isEmpty ? server1.url : server1.name
        let name2 = server2.name.isEmpty ? server2.url : server2.name
        
        return name1 < name2
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Manage")) {
                    Button {
                        activeSheet = .add
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Server")
                        }
                    }
                }
                if !serversHelper.servers.isEmpty {
                    Section(header: Text("Server List")) {
                        ForEach(serversHelper.servers.sorted(by: sortServers), id: \.id) { server in
                            Button {
                                serversHelper.connect(server: server, result: { success in
                                    if(!success) { isTroubleConnecting = true }
                                })
                            } label: {
                                ServerRowView(server: server, setActiveSheet: setActiveSheet)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Servers")
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .add:
                ServerAddView()
            case .edit(let serverId):
                ServerAddView(editServerId: serverId)
            }
        }
        .alert(isPresented: $isTroubleConnecting) {
            Alert(title: Text("Couldn't connect to the server."), message: Text("Check if the URL, username and password is correct. Make sure local network access is enabled:\nSettings > Privacy & Security > Local Network > qBitControl"))
        }
    }
}
