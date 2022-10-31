//
//  AuthClass.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 26/10/2022.
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
    
    static func getCookie(ip: String, username: String, password: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(ip)/api/v2/auth/login") else {return}
        
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
        
        URLSession.shared.dataTask(with: req) {
            data, response, error in
            /*if let data = data {
                print(data)
            }*/
            if let response = response as? HTTPURLResponse {
                print(response)
                completion(String(String(describing: response.allHeaderFields["Set-Cookie"] ?? "n/a;").split(separator: ";")[0]))
            }
            if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
    }
}


