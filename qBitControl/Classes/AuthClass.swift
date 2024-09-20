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
        let urlString = url
        guard let url = URL(string: "\(url)/api/v2/auth/login") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"

        // Create a properly encoded query string
        let parameters: [String: String] = [
          "username": username,
          "password": password
        ]
        
        let parameterArray = parameters.map { key, value in
           return "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")"
        }
        let bodyString = parameterArray.joined(separator: "&")
        req.httpBody = bodyString.data(using: .utf8)

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 10
        let session = URLSession(configuration: sessionConfiguration)

        await session.reset()

        session.dataTask(with: req) { data, response, error in
          if let response = response as? HTTPURLResponse {
              let cookie = String(String(describing: response.allHeaderFields["Set-Cookie"] ?? "n/a;").split(separator: ";")[0])
              if cookie.contains("SID") {
                  if setCookie {
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


