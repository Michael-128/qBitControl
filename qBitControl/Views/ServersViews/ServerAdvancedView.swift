import SwiftUI

struct ServerAdvancedView: View {
    @Binding var basicAuth: Server.BasicAuth?
    
    @State var isBasicAuthEnabled = false
    @State var username = ""
    @State var password = ""
    
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
        }
        .onAppear { restoreValues() }
        .navigationTitle("Advanced")
    }
    
    private func restoreValues() {
        if let basicAuth = self.basicAuth {
            self.isBasicAuthEnabled = true
            self.username = basicAuth.username
            self.password = basicAuth.password
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
