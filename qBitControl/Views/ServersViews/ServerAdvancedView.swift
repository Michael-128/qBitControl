import SwiftUI

struct ServerAdvancedView: View {
    @Binding var basicAuth: Server.BasicAuth?
    
    @State var isBasicAuthEnabled: Bool = false
    @State var username = ""
    @State var password = ""
    
    var body: some View {
        List {
            Section(header: Text("Basic Authentication")) {
                self.basicAuthView()
            }
        }.onAppear { self.restoreValues() }
    }
    
    @ViewBuilder
    private func basicAuthView() -> some View {
        Toggle("Basic Authentication", isOn: self.$isBasicAuthEnabled)
            .onChange(of: isBasicAuthEnabled) { _ in self.onChangeHandler() }
        
        if(self.isBasicAuthEnabled) {
            TextField("Username", text: self.$username)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onChange(of: username) { _ in self.onChangeHandler() }
            SecureField("Password", text: self.$password)
                .onChange(of: password) { _ in self.onChangeHandler() }
        }
    }
    
    private func restoreValues() {
        if let basicAuth = self.basicAuth {
            self.isBasicAuthEnabled = true
            self.username = basicAuth.username
            self.password = basicAuth.password
        }
    }
    
    private func onChangeHandler() {
        if(self.isBasicAuthEnabled == false) {
            self.basicAuth = nil
            return
        }
        
        if(!username.isEmpty && !password.isEmpty) {
            self.basicAuth = Server.BasicAuth(username, password)
        }
    }
}
