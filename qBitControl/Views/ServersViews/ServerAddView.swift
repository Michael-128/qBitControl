//
//  ServerAddView.swift
//  qBitControl
//

import SwiftUI

struct ServerAddView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: ServerAddViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: ServerAddViewModel())
    }
    
    init(editServerId: String) {
        _viewModel = StateObject(wrappedValue: ServerAddViewModel(editServerId: editServerId))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    LabeledContent {
                        TextField("http(s)://IP:PORT", text: $viewModel.url)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("URL", systemImage: "globe")
                    }
                    LabeledContent {
                        TextField("Required", text: $viewModel.username)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Username", systemImage: "person")
                    }
                    LabeledContent {
                        SecureField("Required", text: $viewModel.password)
                            .autocorrectionDisabled()
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Password", systemImage: "lock")
                    }
                }
                
                Section(footer: Text("A name helps identify this server in your server list.")) {
                    LabeledContent {
                        TextField("Optional", text: $viewModel.friendlyName)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Name", systemImage: "tag")
                    }
                }
                
                Section {
                    NavigationLink {
                        ServerAdvancedView(basicAuth: $viewModel.basicAuth)
                    } label: {
                        Label("Advanced", systemImage: "gearshape")
                    }
                }
            }
            .alert("Invalid server information", isPresented: $viewModel.isInvalidAlert) {
                Button("OK") { viewModel.alertDismissed() }
            } message: {
                Text(viewModel.invalidAlertMessage)
            }
            .alert("Connection failed", isPresented: $viewModel.isConnectionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Save Anyway") { viewModel.saveAnyway(dismiss: dismiss) }
            } message: {
                Text("Could not connect to the server. Check your URL and credentials.")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.addServer(dismiss: dismiss)
                    } label: {
                        if viewModel.isCheckingConnection {
                            ProgressView()
                        } else {
                            Text(viewModel.editServerId != nil ? "Save" : "Add")
                        }
                    }
                    .disabled(viewModel.isCheckingConnection)
                }
            }
            .navigationTitle(viewModel.editServerId != nil ? "Edit Server" : "Add Server")
        }
    }
}
