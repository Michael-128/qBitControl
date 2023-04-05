//
//  qBitRequestClass.swift
//  qBitControl
//

import Foundation


class qBitRequest {
    static func prepareURLRequest(path: String, queryItems: [URLQueryItem]) -> URLRequest {
        let cookie = qBittorrent.getCookie()
        let url = qBittorrent.getURL()
        if(cookie == "n/a") {fatalError("Invalid cookie!")}
        
        guard let url = URL(string: "\(url)\(path)") else {fatalError("Invalid URL!")}
        
        let jar = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": cookie] // Or ["Set-Cookie": "key=value, key2=value2"] for multiple cookies
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
        jar.setCookies(cookies, for: url, mainDocumentURL: url)
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        
        var urlComponents = URLComponents()
        urlComponents.queryItems = queryItems
        
        let bodyString = urlComponents.string
        guard let bodyString = bodyString?.suffix((bodyString?.count ?? 1) - 1) else { fatalError("Invalid request body!") }
        let data = bodyString.data(using: .utf8)
        req.httpBody = data
        
        return req
    }
    
    static func prepareURLRequest(path: String) -> URLRequest {
        let cookie = qBittorrent.getCookie()
        let url = qBittorrent.getURL()
        if(cookie == "n/a") {fatalError("Invalid cookie!")}
        
        guard let url = URL(string: "\(url)\(path)") else {fatalError("Invalid URL!")}
        
        let jar = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": cookie] // Or ["Set-Cookie": "key=value, key2=value2"] for multiple cookies
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
        jar.setCookies(cookies, for: url, mainDocumentURL: url)
        
        let req = URLRequest(url: url)
        
        return req
    }
    
    static func requestTorrentListJSON(request: URLRequest, completionHandler: @escaping ([Torrent]) -> Void) {
        URLSession.shared.dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode([Torrent].self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    static func requestTorrentManagement(request: URLRequest) {
        URLSession.shared.dataTask(with: request) {
                data, response, error in
        }.resume()
    }
    
    static func requestTorrentManagement(request: URLRequest, statusCode: @escaping (Int?) -> Void) {
        URLSession.shared.dataTask(with: request) {
                data, response, error in
            if let response = response as? HTTPURLResponse {
                statusCode(response.statusCode)
                return
            }
            statusCode(nil)
        }.resume()
    }
    
    static func requestPreferencesJSON(request: URLRequest, completionHandler: @escaping (qBitPreferences) -> Void) {
        URLSession.shared.dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(qBitPreferences.self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    static func requestPeersJSON(request: URLRequest, completionHandler: @escaping (Peers) -> Void) {
        URLSession.shared.dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(Peers.self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    static func requestTrackersJSON(request: URLRequest, completionHandler: @escaping ([Tracker]) -> Void) {
        URLSession.shared.dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode([Tracker].self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    static func requestFilesJSON(request: URLRequest, completionHandler: @escaping ([File]) -> Void) {
        URLSession.shared.dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode([File].self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    static func requestCategoriesJSON(request: URLRequest, completionHandler: @escaping ([String: [String: String]]) -> Void) {
        URLSession.shared.dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode([String: [String: String]].self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    static func requestTagsJSON(request: URLRequest, completionHandler: @escaping ([String]) -> Void) {
        URLSession.shared.dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode([String].self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    static func requestRSSFeedJSON(request: URLRequest, completion: @escaping ([String: RSS]) -> Void) {
        URLSession.shared.dataTask(with: request) {
                data, response, error in
                
            if let data = data {
                do {
                    try completion(JSONDecoder().decode([String: RSS].self, from: data))
                } catch {
                    print(error)
                }
            }
        }.resume()
    }

}
