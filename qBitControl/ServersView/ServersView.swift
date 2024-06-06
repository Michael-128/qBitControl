import SwiftUI

struct ServersView: View {
    @StateObject private var viewModel: ServersViewModel

    init(isLoggedIn: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: ServersViewModel(isLoggedIn: isLoggedIn))
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Manage")) {
                    Button {
                        viewModel.isServerAddView.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Server")
                        }
                    }
                }
                if !viewModel.servers.isEmpty {
                    Section(header: Text("Server List")) {
                        ForEach(viewModel.servers, id: \.id) { server in
                            Button {
                                viewModel.connectToServer(server: server)
                            } label: {
                                ServerRowView(id: server.id, friendlyName: server.name, url: server.url, username: server.username, password: server.password, activeServerId: $viewModel.activeServerId, serversHelper: viewModel.serversHelper, refreshServerList: viewModel.refreshServerList, isConnecting: $viewModel.isConnecting, isLoggedIn: $viewModel.isLoggedIn)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Servers")
        }
        .sheet(isPresented: $viewModel.isServerAddView) {
            ServerAddView(serversHelper: viewModel.serversHelper)
        }
        .onChange(of: viewModel.isServerAddView) { isServerAddView in
            if !isServerAddView {
                viewModel.refreshServerList()
            }
        }
        .onAppear {
            viewModel.refreshServerList()
            viewModel.refreshActiveServer()
        }
        .alert(isPresented: $viewModel.isTroubleConnecting) {
            Alert(title: Text("Couldn't connect to the server."), message: Text("Check if the URL, username and password is correct. Make sure local network access is enabled:\nSettings > Privacy & Security > Local Network > qBitControl"))
        }
    }
}
