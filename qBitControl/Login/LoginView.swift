//
//  ContentView.swift
//  qBitControl
//

import SwiftUI

struct LoginView: View {
    @State private var cookie1 = qBittorrent.getCookie()
    
    @Binding var isLoggedIn: Bool {
        didSet {

            let server = defaults.value(forKey: "server") as? Data
         
            if let server = server {
                let decoder = JSONDecoder()
                
                do {
                    let server = try decoder.decode(Server.self, from: server)
                    
                    URL = server.url
                    username = server.username
                    
                    if(server.isRemember) {
                        password = server.password
                    }
                    
                    isRemember = server.isRemember
                } catch let error {
                    print(error)
                    return
                }
            }
        }
    }
    @State private var isLoginFailed = false
    
    @State private var defaults = UserDefaults.standard
    
    @State private var URL: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isRemember: Bool = false
    
    @State private var isLoading: Bool = true
    @State private var isTroubleConnecting: Bool = false
    @State private var isConnecting: Bool = false
    @State private var isAutoLoggingIn: Bool = true
    
    
    func saveCredentials() -> Void {
        let server = Server(name: URL, url: URL, username: username, password: password, isRemember: isRemember)
        
        let encoder = JSONEncoder()
        
        do {
            defaults.setValue(try encoder.encode(server), forKey: "server")
        } catch let error {
            print("server set error")
            print(error)
        }
    }
    
    func logIn() -> Void {
        isConnecting = true
        Task {
            await Auth.getCookie(url: URL, username: username, password: password, isSuccess: {
                    isSuccess in
                    
                    if(isSuccess) {
                        saveCredentials()
                        isLoggedIn = true
                    } else {
                        isTroubleConnecting = true
                    }
                    
                    isConnecting = false
                }
            )
            
            isAutoLoggingIn = false
        }
    }
    
    func loadServerData() -> Void {
        let server = defaults.value(forKey: "server") as? Data
        
        if let server = server {
            let decoder = JSONDecoder()
            
            do {
                let server = try decoder.decode(Server.self, from: server)
                
                URL = server.url
                username = server.username
                
                if(server.isRemember) {
                    password = server.password
                }
                
                isRemember = server.isRemember
            } catch let error {
                print(error)
                isLoading = false
                return
            }
        }
        
        isLoading = false
    }
    
    func autoLogIn() -> Void {
        if(!qBittorrent.isCookie()) {
            logIn()
        } else {
            isAutoLoggingIn = false
        }
    }
    
    var body: some View {
        NavigationStack {
            if(isLoading || isAutoLoggingIn) {
                Spacer()
                Text("qBitControl").font(.largeTitle)
                Spacer()
            } else {
                Group {
                    //Text("qBitControl").font(.largeTitle)
                    
                    List {
                        Section {
                            TextField("URL", text: $URL)
                                .keyboardType(.URL)
                            TextField("Username", text: $username)
                            SecureField("Password", text: $password)
                            Toggle("Remember Me", isOn: $isRemember)
                        }
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        Section {
                            if(!isConnecting) {
                                Button {
                                    logIn()
                                } label: {
                                    Text("Log in")
                                }
                            } else {
                                Text("Logging in...").foregroundStyle(Color(.gray))
                            }
                        }
                    }.navigationTitle("qBitControl")
                }
            }
        }.onAppear() {
            loadServerData()
            autoLogIn()
        }.alert(isPresented: $isTroubleConnecting, content: {
            Alert(title: Text("Couldn't connect to the server."), message: Text("Check if the URL, username and password is correct. Make sure local network access is enabled:\nSettings > Privacy & Security > Local Network > qBitControl"))
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
