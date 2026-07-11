import SwiftUI

struct ServerAdvancedView: View {
    @Binding var basicAuth: Server.BasicAuth?
    @Binding var customHeaders: [Server.CustomHeader]
    
    @State var isBasicAuthEnabled = false
    @State var username = ""
    @State var password = ""
    @State var isCustomHeadersEnabled = false
    @State private var animatedHeaders: [Server.CustomHeader] = []

    var body: some View {
        List {
            Section(footer: Text("Enable if your server is behind a reverse proxy that requires HTTP Basic Authentication.")) {
                Toggle(isOn: $isBasicAuthEnabled.animation(.default)) {
                    Label("Basic Authentication", systemImage: "key")
                }
                .onChange(of: isBasicAuthEnabled) { _ in onChangeHandler() }

                if isBasicAuthEnabled {
                    LabeledContent {
                        TextField("Required", text: $username)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: username) { _ in onChangeHandler() }
                    } label: {
                        Label("Username", systemImage: "person")
                    }
                    .transition(.opacity)
                    LabeledContent {
                        SecureField("Required", text: $password)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: password) { _ in onChangeHandler() }
                    } label: {
                        Label("Password", systemImage: "lock")
                    }
                    .transition(.opacity)
                }
            }

            Section(footer: Text("Additional HTTP headers sent with every request. Use for reverse proxy authentication or zero-trust tunnels.")) {
                Toggle(isOn: $isCustomHeadersEnabled.animation(.default)) {
                    Label("Custom Headers", systemImage: "ellipsis.curlybraces")
                }
                .onChange(of: isCustomHeadersEnabled) { isEnabled in
                    if isEnabled {
                        animatedHeaders = customHeaders
                    } else {
                        withAnimation(.default) { animatedHeaders = [] }
                    }
                }

                if isCustomHeadersEnabled {
                    ForEach($animatedHeaders) { $header in
                        HStack(spacing: 8) {
                            TextField("Key", text: $header.key)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            TextField("Value", text: $header.value)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                        }
                    }
                    .onDelete { indexSet in
                        withAnimation(.default) { animatedHeaders.remove(atOffsets: indexSet) }
                    }

                    Button {
                        withAnimation(.default) { animatedHeaders.append(Server.CustomHeader(key: "", value: "")) }
                    } label: {
                        Label("Add Header", systemImage: "plus")
                    }
                    .transition(.opacity)
                }
            }
        }
        .onAppear { restoreValues() }
        .onChange(of: animatedHeaders) { newHeaders in
            if isCustomHeadersEnabled {
                customHeaders = newHeaders
            }
        }
        .navigationTitle("Advanced")
    }
    
    private func restoreValues() {
        if let basicAuth = self.basicAuth {
            self.isBasicAuthEnabled = true
            self.username = basicAuth.username
            self.password = basicAuth.password
        }
        if !customHeaders.isEmpty {
            self.isCustomHeadersEnabled = true
            self.animatedHeaders = customHeaders
        }
    }
    
    private func onChangeHandler() {
        if isBasicAuthEnabled == false {
            self.basicAuth = nil
            return
        }
        
        if !username.isEmpty && !password.isEmpty {
            self.basicAuth = Server.BasicAuth(username, password)
        } else {
            self.basicAuth = nil
        }
    }
}
