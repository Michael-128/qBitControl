//
//  qBitRequestClass.swift
//  qBitControl
//

import Foundation


class qBitRequest {
    static private var basicAuth: Server.BasicAuth?
    
    static func setBasicAuth(auth: Server.BasicAuth?) {
        self.basicAuth = auth
    }
    
    private static func getSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        
        if let basicAuth = qBitRequest.basicAuth {
            // Set the auth header
            configuration.httpAdditionalHeaders = [
                "Authorization": "Basic \(basicAuth.getAuthString())"
            ]
        }
        
        // Return a new session with this configuration
        return URLSession(configuration: configuration)
    }
    
    static func prepareURLRequest(path: String, queryItems: [URLQueryItem]) -> URLRequest {
        let cookie = qBittorrent.getCookie()
        let url = qBittorrent.getURL()
        if(cookie == "n/a") {print("Invalid cookie!")}
        
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
        if(cookie == "n/a") {print("Invalid cookie!")}
        
        guard let url = URL(string: "\(url)\(path)") else {fatalError("Invalid URL!")}
        
        let jar = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": cookie] // Or ["Set-Cookie": "key=value, key2=value2"] for multiple cookies
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
        jar.setCookies(cookies, for: url, mainDocumentURL: url)
        
        let req = URLRequest(url: url)
        
        return req
    }
    
    static func requestTorrentListJSON(request: URLRequest, completionHandler: @escaping ([Torrent]) -> Void) {
        self.getSession().dataTask(with: request) {
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
    
    static func requestUniversal(request: URLRequest) {
        self.getSession().dataTask(with: request) {
                data, response, error in
        }.resume()
    }
    
    static func requestTorrentManagement(request: URLRequest, statusCode: @escaping (Int?) -> Void) {
        self.getSession().dataTask(with: request) {
                data, response, error in
            if let response = response as? HTTPURLResponse {
                statusCode(response.statusCode)
                return
            }
            statusCode(nil)
        }.resume()
    }
    
    static func requestPreferencesJSON(request: URLRequest, completionHandler: @escaping (qBitPreferences) -> Void) {
        self.getSession().dataTask(with: request) {
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
    
    static func requestSearchStart(request: URLRequest, completionHandler: @escaping (SearchStartResult) -> Void) {
        self.getSession().dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(SearchStartResult.self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    static func requestSearchResults(request: URLRequest, completionHandler: @escaping (SearchResponse) -> Void) {
        self.getSession().dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(SearchResponse.self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    static func requestSearchPlugins(request: URLRequest, completionHandler: @escaping ([SearchPlugin]) -> Void) {
        self.getSession().dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode([SearchPlugin].self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    static func requestGlobalTransferInfo(request: URLRequest, completionHandler: @escaping (GlobalTransferInfo) -> Void) {
        self.getSession().dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(GlobalTransferInfo.self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    static func requestMainData(request: URLRequest, completionHandler: @escaping (MainData) -> Void) {
        self.getSession().dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(MainData.self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    
    static func requestPeersJSON(request: URLRequest, completionHandler: @escaping (Peers) -> Void) {
        self.getSession().dataTask(with: request) {
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
        self.getSession().dataTask(with: request) {
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
        self.getSession().dataTask(with: request) {
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
    
    static func requestCategoriesJSON(request: URLRequest, completionHandler: @escaping ([String: Category]) -> Void) {
        self.getSession().dataTask(with: request) {
                data, response, error in
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode([String: Category].self, from: data)
                        completionHandler(json)
                    } catch {
                        print(error)
                    }
                }
        }.resume()
    }
    
    static func requestVersion(request: URLRequest, completionHandler: @escaping (Version) -> Void) {
        self.getSession().dataTask(with: request) {
                data, response, error in
                if let data = data, let versionData = String(data: data, encoding: .utf8)  {
                    let versionString = versionData.filter { "0123456789.".contains($0) }
                    let versionParts = versionString.split(separator: ".").map { Int($0) ?? 0 }
                    if versionParts.count >= 3 {
                        let versionModel = Version(major: versionParts[0], minor: versionParts[1], patch: versionParts[2])
                        completionHandler(versionModel)
                    }
                }
        }.resume()
    }
    
    static func requestTagsJSON(request: URLRequest, completionHandler: @escaping ([String]) -> Void) {
        self.getSession().dataTask(with: request) {
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
    
    static func requestRSSFeedJSON(request: URLRequest, completion: @escaping (RSSNode) -> Void) {
        self.getSession().dataTask(with: request) {
            data, response, error in
                
            if let data = data {
                do {
                    try completion(JSONDecoder().decode(RSSNode.self, from: data))
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    static func requestCommonData(request: URLRequest) async -> QBResult<Data, Error> {
        do {
            let response = try await URLSession.shared.data(for: request)
            return .success(response.0)
        } catch {
            return .failure(error)
        }
    }

}

enum QBResult<data, error: Error> {
    case success(data)
    case failure(error)
}
