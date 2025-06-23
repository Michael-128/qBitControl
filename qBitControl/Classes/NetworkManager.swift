//
//  NetworkManager.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 17/06/2025.
//

import Foundation

class NetworkManager: NSObject, URLSessionTaskDelegate {
    private var allowUntrusted: Bool = false
    private var basicAuth: Server.BasicAuth?
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        
        if let basicAuth = basicAuth {
            let authString = basicAuth.getAuthString()
            configuration.httpAdditionalHeaders = [
                "Authorization": "Basic \(authString)"
            ]
        }

        return URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: OperationQueue()
        )
    }()
    
    override init() {
        super.init()
    }
    
    init(basicAuth: Server.BasicAuth) {
        super.init()
        self.basicAuth = basicAuth
    }

    // MARK: - URLSessionTaskDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        // Check if the challenge is for server trust evaluation
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            // If it's a different kind of challenge, perform default handling.
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // If our policy is to allow untrusted certificates, we proceed.
        if allowUntrusted {
            // Get the server's certificate from the trust object.
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            // Create a credential object from the server trust, effectively trusting it.
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // If we're not allowing untrusted certs, let the default evaluation fail.
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    // MARK: - Request Builders
    private func prepareURLRequest(path: String, queryItems: [URLQueryItem]) -> URLRequest {
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
    
    private func prepareURLRequest(path: String) -> URLRequest {
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

    // MARK: - Public Request Method
    public func performRequest(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "HTTPError", code: statusCode, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoDataError", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    public func performDataRequest<T: Decodable>(
        request: URLRequest,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        self.session.dataTask(with: request) { data, response, error in
            
            // 1. Handle network-level errors (e.g., no internet)
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            // 2. Check for a valid HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse(statusCode: 0)))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
                return
            }

            // 3. Ensure we have data
            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            // 4. Attempt to decode the data into the generic type `T`
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch let decodingError {
                // Print the error for debugging purposes
                print("Decoding Error: \(decodingError)")
                completion(.failure(.decodingError(decodingError)))
            }
        }.resume()
    }
    
    public func performDataRequest<T: Decodable>(
        path: String,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        self.performDataRequest(
            request: self.prepareURLRequest(path: path),
            decodingType: decodingType,
            completion: completion
        )
    }
    
    public func performDataRequest<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem],
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        self.performDataRequest(
            request: self.prepareURLRequest(path: path, queryItems: queryItems),
            decodingType: decodingType,
            completion: completion
        )
    }
}
