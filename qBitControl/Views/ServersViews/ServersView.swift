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
                        Label("Add Server", systemImage: "plus.circle")
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
                Section(header: Text("Demo")) {
                    Button {
                        DemoMode.activate()
                    } label: {
                        HStack {
                            Label("Live Demo", systemImage: "sparkles")
                            Spacer()
                            if serversHelper.activeServerId == "demo" {
                                Image(systemName: "checkmark")
                            }
                        }
                        .foregroundColor(.teal)
                    }
                    .disabled(serversHelper.activeServerId == "demo")
                        }
                        .animation(.default, value: serversHelper.servers.map(\.id))
                    }
            .navigationTitle("Servers")
        }
        .serverSheetAndAlert(activeSheet: $activeSheet, isTroubleConnecting: $isTroubleConnecting)
    }
}
