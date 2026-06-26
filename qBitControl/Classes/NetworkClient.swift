//
//  NetworkClient.swift
//  qBitControl
//

import Foundation

/// Custom errors thrown by `NetworkClient`.
enum NetworkError: Error, Equatable {
    case invalidURL
    case unauthorized
    case invalidResponse
    case httpError(statusCode: Int)
}

/// A stateless actor responsible for executing generic asynchronous HTTP requests.
actor NetworkClient {
    private let baseURL: String
    private let basicAuth: Server.BasicAuth?
    private let session: URLSession

    /// Initializes a new stateless network client.
    /// - Parameters:
    ///   - baseURL: The base server URL.
    ///   - basicAuth: Optional basic authentication credentials.
    ///   - session: The `URLSession` instance to use (supports Dependency Injection for testability).
    init(baseURL: String, basicAuth: Server.BasicAuth?, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.basicAuth = basicAuth
        self.session = session
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

        // 3. Configure headers: Basic Auth and Cookies
        if let basicAuth = basicAuth {
            request.setValue("Basic \(basicAuth.getAuthString())", forHTTPHeaderField: "Authorization")
        }

        if let cookie = cookie {
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
        }

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
            // Throw native URL/network errors directly
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
                    return decoded
                }
                if let rawString = String(data: data, encoding: .utf8) as? T {
                    return rawString
                }
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            // Throw decoding errors directly to be handled natively
            throw error
        }
    }
}
