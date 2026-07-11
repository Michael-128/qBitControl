//
//  NetworkClient.swift
//  qBitControl
//

import Foundation

/// Custom errors thrown by `NetworkClient`.
enum NetworkError: Error, Equatable, LocalizedError {
    case invalidURL
    case unauthorized
    case invalidResponse
    case httpError(statusCode: Int)
    case timeout
    case sslUntrusted

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .unauthorized:
            return "Unauthorized (401/403)"
        case .invalidResponse:
            return "Invalid Server Response"
        case .httpError(let statusCode):
            return "HTTP Error \(statusCode)"
        case .timeout:
            return "Request Timeout"
        case .sslUntrusted:
            return "SSL Certificate Untrusted"
        }
    }
}

/// A stateless actor responsible for executing generic asynchronous HTTP requests.
actor NetworkClient {
    nonisolated let baseURL: String
    private let basicAuth: Server.BasicAuth?
    private let customHeaders: [Server.CustomHeader]
    private let session: URLSession

    private final class SelfSignedDelegate: NSObject, URLSessionDelegate {
        func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                  let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.performDefaultHandling, nil)
                return
            }
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }

    init(baseURL: String, basicAuth: Server.BasicAuth?, customHeaders: [Server.CustomHeader] = [], allowSelfSignedCert: Bool = false, session: URLSession? = nil) {
        self.baseURL = baseURL
        self.basicAuth = basicAuth
        self.customHeaders = customHeaders

        if let session = session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 15.0
            config.timeoutIntervalForResource = 15.0
            if allowSelfSignedCert {
                self.session = URLSession(configuration: config, delegate: SelfSignedDelegate(), delegateQueue: nil)
            } else {
                self.session = URLSession(configuration: config)
            }
        }
    }

    /// Applies stored custom headers, Basic Auth, and cookie to a URLRequest.
    private func applyHeaders(to request: inout URLRequest, cookie: String?) {
        for header in customHeaders where !header.key.isEmpty {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        if let basicAuth = basicAuth {
            request.setValue("Basic \(basicAuth.getAuthString())", forHTTPHeaderField: "Authorization")
        }
        if let cookie = cookie {
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
        }
    }

    /// Sends an HTTP request and decodes the response to a generic `Decodable` type.
    /// - Parameters:
    ///   - path: The URL path relative to the base URL.
    ///   - queryItems: An array of URL query items. If not empty, the request will be executed as a POST request
    ///                 with form-urlencoded body payload. If empty, the request executes as a GET request.
    ///   - cookie: Optional cookie header string.
    /// - Returns: The decoded response of type `T`.
    /// Sends an HTTP request and returns both the decoded response and the HTTPURLResponse.
    func sendRequestWithResponse<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem],
        cookie: String?
    ) async throws -> (T, HTTPURLResponse) {
        // 1. Construct the complete URL
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)

        // 2. Configure HTTP method and query/body parameters
        if queryItems.isEmpty {
            request.httpMethod = "GET"
        } else {
            request.httpMethod = "POST"
            
            var urlComponents = URLComponents()
            urlComponents.queryItems = queryItems
            if let bodyString = urlComponents.string {
                // Strips the leading '?' from the URLComponents string representation
                let bodyPayload = bodyString.hasPrefix("?") ? String(bodyString.dropFirst()) : bodyString
                request.httpBody = bodyPayload.data(using: .utf8)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
        }

        // 3. Configure request headers
        applyHeaders(to: &request, cookie: cookie)

        // 4. Execute request using the injected URLSession (with backwards compatibility)
        let data: Data
        let response: URLResponse
        do {
            if #available(macOS 12.0, iOS 15.0, *) {
                (data, response) = try await session.data(for: request)
            } else {
                (data, response) = try await withCheckedThrowingContinuation { continuation in
                    let task = session.dataTask(with: request) { data, response, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let data = data, let response = response {
                            continuation.resume(returning: (data, response))
                        } else {
                            continuation.resume(throwing: URLError(.unknown))
                        }
                    }
                    task.resume()
                }
            }
        } catch {
            if let urlError = error as? URLError, urlError.code == .serverCertificateUntrusted || urlError.code == .serverCertificateHasBadDate || urlError.code == .serverCertificateNotYetValid || urlError.code == .serverCertificateHasUnknownRoot {
                throw NetworkError.sslUntrusted
            }
            throw error
        }

        // 5. Handle HTTP response and status codes
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        let statusCode = httpResponse.statusCode
        if statusCode == 401 || statusCode == 403 {
            throw NetworkError.unauthorized
        }

        guard (200...299).contains(statusCode) else {
            throw NetworkError.httpError(statusCode: statusCode)
        }

        // 6. Decode response (specifically handle raw String fallback if T is String)
        do {
            if T.self == String.self {
                if let decoded = try? JSONDecoder().decode(T.self, from: data) {
                    return (decoded, httpResponse)
                }
                if let rawString = String(data: data, encoding: .utf8) as? T {
                    return (rawString, httpResponse)
                }
            }
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return (decoded, httpResponse)
        } catch {
            // Throw decoding errors directly to be handled natively
            throw error
        }
    }

    /// Sends an HTTP request and decodes the response to a generic `Decodable` type.
    /// - Parameters:
    ///   - path: The URL path relative to the base URL.
    ///   - queryItems: An array of URL query items. If not empty, the request will be executed as a POST request
    ///                 with form-urlencoded body payload. If empty, the request executes as a GET request.
    ///   - cookie: Optional cookie header string.
    /// - Returns: The decoded response of type `T`.
    func sendRequest<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem],
        cookie: String?
    ) async throws -> T {
        let (decoded, _): (T, HTTPURLResponse) = try await sendRequestWithResponse(path: path, queryItems: queryItems, cookie: cookie)
        return decoded
    }

    /// Uploads files using multipart/form-data asynchronously without loading massive files entirely into memory.
    func uploadMultipart<T: Decodable>(
        path: String,
        files: [String: Data],
        params: [String: String],
        cookie: String?
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw NetworkError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        let fileHandle = try FileHandle(forWritingTo: fileURL)

        // 1. Write params
        for (name, value) in params {
            let paramStr = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(value)\r\n"
            if let paramData = paramStr.data(using: .utf8) {
                fileHandle.write(paramData)
            }
        }

        // 2. Write files
        for (fileName, fileData) in files {
            let header = "--\(boundary)\r\nContent-Disposition: form-data; name=\"torrents\"; filename=\"\(fileName)\"\r\nContent-Type: application/x-bittorrent\r\n\r\n"
            if let headerData = header.data(using: .utf8) {
                fileHandle.write(headerData)
            }
            fileHandle.write(fileData)
            if let boundaryEndData = "\r\n".data(using: .utf8) {
                fileHandle.write(boundaryEndData)
            }
        }

        // 3. Write footer
        let footer = "--\(boundary)--\r\n"
        if let footerData = footer.data(using: .utf8) {
            fileHandle.write(footerData)
        }
        
        if #available(macOS 10.15, iOS 13.0, *) {
            try fileHandle.close()
        } else {
            fileHandle.closeFile()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // 4. Configure request headers
        applyHeaders(to: &request, cookie: cookie)

        // 5. Execute upload
        let data: Data
        let response: URLResponse
        do {
            if #available(macOS 12.0, iOS 15.0, *) {
                (data, response) = try await session.upload(for: request, fromFile: fileURL)
            } else {
                (data, response) = try await withCheckedThrowingContinuation { continuation in
                    let task = session.uploadTask(with: request, fromFile: fileURL) { data, response, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let data = data, let response = response {
                            continuation.resume(returning: (data, response))
                        } else {
                            continuation.resume(throwing: URLError(.unknown))
                        }
                    }
                    task.resume()
                }
            }
        } catch {
            try? FileManager.default.removeItem(at: fileURL)
            throw error
        }

        try? FileManager.default.removeItem(at: fileURL)

        // 6. Handle HTTP response and status codes
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        let statusCode = httpResponse.statusCode
        if statusCode == 401 || statusCode == 403 {
            throw NetworkError.unauthorized
        }
        guard (200...299).contains(statusCode) else {
            throw NetworkError.httpError(statusCode: statusCode)
        }

        // 7. Decode response (specifically handle raw String fallback if T is String)
        if T.self == String.self {
            if let decoded = try? JSONDecoder().decode(T.self, from: data) {
                return decoded
            }
            if let rawString = String(data: data, encoding: .utf8) as? T {
                return rawString
            }
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
