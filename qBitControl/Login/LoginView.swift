//
//  ContentView.swift
//  qBitControl
//

import SwiftUI

struct LoginView: View {
    @State private var cookie1 = qBittorrent.getCookie()
    @Binding var isLoggedIn: Bool
    @State private var isLoginFailed = false
    
    @State private var defaults = UserDefaults.standard
    
    @State private var URL: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var isLoading: Bool = true
    @State private var isTroubleConnecting: Bool = false
    
    
    var body: some View {
        VStack {
            if(isLoading) {
                Spacer()
                Text("qBitControl").font(.largeTitle)
                Spacer()
            } else {
                Group {
                    Spacer(minLength: 40)
                    
                    Text("qBitControl").font(.largeTitle)
                    
                    List {
                        TextField("URL", text: $URL)
                        TextField("Username", text: $username)
                        SecureField("Password", text: $password)
                        
                        Button {
                            Auth.getCookie(ip: URL, username: username, password: password, completion: {
                                    cookie in
                                    
                                    if cookie.contains("SID") {
                                        qBittorrent.setURL(url: URL)
                                        qBittorrent.setCookie(cookie: cookie)
                                        
                                        let server = Server(name: "main", ip: URL, username: username, password: password)
                                        
                                        let encoder = JSONEncoder()
                                        
                                        do {
                                            defaults.setValue(try encoder.encode(server), forKey: "server")
                                        } catch let error {
                                            print(error)
                                            return
                                        }
                                        
                                        isLoggedIn = true
                                    }
                                    
                                    if cookie.contains("error") {
                                        isTroubleConnecting = true
                                    }
                                }
                            )
                        } label: {
                            Text("Log in")
                        }
                    }
                }
            }
        }.onAppear() {
            let server = defaults.value(forKey: "server") as? Data
            
            if let server = server {
                let decoder = JSONDecoder()
                
                do {
                    let server = try decoder.decode(Server.self, from: server)
                    
                    URL = server.ip
                    username = server.username
                    
                    Auth.getCookie(ip: URL, username: username, password: server.password, completion: {
                        cookie in
                        
                        if cookie.contains("SID") {
                            qBittorrent.setURL(url: URL)
                            qBittorrent.setCookie(cookie: cookie)
                            isLoggedIn = true
                        }
                        
                        if cookie.contains("error") {
                            isTroubleConnecting = true
                        }
                        
                        
                    })
                    } catch let error {
                        print(error)
                        return
                    }
            }
            
            isLoading = false
        }.alert(isPresented: $isTroubleConnecting, content: {
            Alert(title: Text("Couldn't connect to the server."), message: Text("Make sure the URL, username and password are correct"))
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
