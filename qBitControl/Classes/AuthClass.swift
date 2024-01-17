//
//  AuthClass.swift
//  qBitControl
//

import SwiftUI

class Auth {
    static private var cookies: [String: String] = [:]
    
    static func getCookie(id: String) -> String {
        return cookies[id] ?? ""
    }
    
    static func setCookie(id: String, cookie: String) {
        cookies[id] = cookie
    }
    
    static func getCookie(url: String, username: String, password: String, isSuccess: @escaping (Bool) -> Void, setCookie: Bool = true) async {
        let urlString = url;
        guard let url = URL(string: "\(url)/api/v2/auth/login") else {return}
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"

        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "username", value: "\(username)"),
            URLQueryItem(name: "password", value: "\(password)")
        ]
        
        let bodyString = urlComponents.string
        guard let bodyString = bodyString?.suffix((bodyString?.count ?? 1) - 1) else { return }
        let data = bodyString.data(using: .utf8)
        req.httpBody = data
        
        let sessionConfiguration = URLSessionConfiguration.default
        
        sessionConfiguration.timeoutIntervalForRequest = 10
        
        let session = URLSession(configuration: sessionConfiguration)
        
        await session.reset()
        
        session.dataTask(with: req) {
            data, response, error in
            /*if let data = data {
                print(data)
            }*/
            if let response = response as? HTTPURLResponse {
                let cookie = String(String(describing: response.allHeaderFields["Set-Cookie"] ?? "n/a;").split(separator: ";")[0])
                if(cookie.contains("SID")) {
                    if(setCookie) {
                        qBittorrent.setURL(url: urlString)
                        qBittorrent.setCookie(cookie: cookie)
                    }
                    isSuccess(true)
                } else {
                    isSuccess(false)
                }
            }
            if let error = error {
                print(error.localizedDescription)
                isSuccess(false)
            }
        }.resume()
    }
}


