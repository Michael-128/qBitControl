//
//  ServerAddView.swift
//  qBitControl
//

import SwiftUI

struct ServerAddView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: ServerAddViewModel
    
    init(serversHelper: ServersHelper) {
        _viewModel = StateObject(wrappedValue: ServerAddViewModel(serversHelper: serversHelper))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Information")) {
                    TextField("Server Name (optional)", text: $viewModel.friendlyName)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    TextField("http(s)://IP:PORT", text: $viewModel.url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    TextField("Username", text: $viewModel.username)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    SecureField("Password", text: $viewModel.password)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Toggle(isOn: $viewModel.isCheckConnection, label: {
                        Text("Check Connection")
                    })
                }
                
                Section {
                    Button {
                        viewModel.addServer(dismiss: dismiss)
                    } label: {
                        Spacer()
                        Text("ADD")
                            .fontWeight(.bold)
                        Spacer()
                    }.buttonStyle(.borderedProminent)
                }.listRowBackground(Color.blue)
            }
            .alert(isPresented: $viewModel.isInvalidAlert) {
                Alert(title: Text("Invalid server information"), message: Text(viewModel.invalidAlertMessage))
            }
            .toolbar() {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            .navigationTitle("Add Server")
        }
    }
}
