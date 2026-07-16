import SwiftUI

struct SettingsView: View {
    @ObservedObject var serversHelper = ServersHelper.shared

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Servers")) {
                    if !serversHelper.recentServers.isEmpty {
                        ForEach(serversHelper.recentServers, id: \.id) { server in
                            Button {
                                serversHelper.connect(server: server)
                            } label: {
                                ServerRowView(server: server, setActiveSheet: { _ in })
                            }
                        }
                        .animation(.default, value: serversHelper.recentServers.map(\.id))
                    }
                    NavigationLink {
                        ServersView()
                    } label: {
                        Label("Manage Servers", systemImage: "ellipsis")
                    }
                }

                Section(header: Text("App")) {
                    NavigationLink {
                        LogViewerView()
                    } label: {
                        Label("Logs", systemImage: "doc.text")
                    }
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
