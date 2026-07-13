import XCTest
@testable import qBitManager

final class NetworkClientTests: XCTestCase {
    
    // Custom URLProtocol to intercept and mock session requests
    private class MockURLProtocol: URLProtocol {
        static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            guard let handler = MockURLProtocol.requestHandler else {
                XCTFail("Mock request handler not configured.")
                return
            }

            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }

        override func stopLoading() {}
    }

    private var mockSession: URLSession!
    private let baseURL = "http://localhost:8080"
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        mockSession = nil
        super.tearDown()
    }

    struct MockDecodable: Codable, Equatable {
        let value: String
    }

    func testSendRequest_Success_DecodesJSON() async throws {
        // Given
        let expectedResponse = MockDecodable(value: "hello_world")
        let responseData = try JSONEncoder().encode(expectedResponse)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, responseData)
        }

        let client = NetworkClient(baseURL: baseURL, basicAuth: nil, session: mockSession)

        // When
        let result: MockDecodable = try await client.sendRequest(path: "/test", queryItems: [], cookie: nil)

        // Then
        XCTAssertEqual(result, expectedResponse)
    }

    func testSendRequest_Unauthorized_ThrowsError_401() async {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, nil)
        }

        let client = NetworkClient(baseURL: baseURL, basicAuth: nil, session: mockSession)

        // When/Then
        do {
            let _: MockDecodable = try await client.sendRequest(path: "/test", queryItems: [], cookie: nil)
            XCTFail("Expected sendRequest to throw NetworkError.unauthorized, but it succeeded.")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.unauthorized)
        } catch {
            XCTFail("Expected NetworkError.unauthorized, but got \(error)")
        }
    }

    func testSendRequest_Unauthorized_ThrowsError_403() async {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 403,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, nil)
        }

        let client = NetworkClient(baseURL: baseURL, basicAuth: nil, session: mockSession)

        // When/Then
        do {
            let _: MockDecodable = try await client.sendRequest(path: "/test", queryItems: [], cookie: nil)
            XCTFail("Expected sendRequest to throw NetworkError.unauthorized, but it succeeded.")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.unauthorized)
        } catch {
            XCTFail("Expected NetworkError.unauthorized, but got \(error)")
        }
    }

    func testSendRequest_HttpError_ThrowsError() async {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, nil)
        }

        let client = NetworkClient(baseURL: baseURL, basicAuth: nil, session: mockSession)

        // When/Then
        do {
            let _: MockDecodable = try await client.sendRequest(path: "/test", queryItems: [], cookie: nil)
            XCTFail("Expected sendRequest to throw NetworkError.httpError, but it succeeded.")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.httpError(statusCode: 500))
        } catch {
            XCTFail("Expected NetworkError.httpError, but got \(error)")
        }
    }

    func testSendRequest_GET_WhenQueryItemsEmpty() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.absoluteString, "http://localhost:8080/get-route")
            
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try! JSONEncoder().encode(MockDecodable(value: "success"))
            return (response, data)
        }

        let client = NetworkClient(baseURL: baseURL, basicAuth: nil, session: mockSession)

        // When
        let _: MockDecodable = try await client.sendRequest(path: "/get-route", queryItems: [], cookie: nil)
    }

    private func getBodyData(from request: URLRequest) -> Data? {
        if let body = request.httpBody {
            return body
        }
        if let stream = request.httpBodyStream {
            stream.open()
            defer { stream.close() }
            
            var data = Data()
            let bufferSize = 1024
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            defer { buffer.deallocate() }
            
            while stream.hasBytesAvailable {
                let read = stream.read(buffer, maxLength: bufferSize)
                if read > 0 {
                    data.append(buffer, count: read)
                } else if read < 0 {
                    return nil
                } else {
                    break
                }
            }
            return data
        }
        return nil
    }

    func testSendRequest_POST_WithFormUrlEncoded_WhenQueryItemsNotEmpty() async throws {
        // Given
        MockURLProtocol.requestHandler = { [weak self] request in
            guard let self = self else {
                return (HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!, nil)
            }
            
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
            
            if let bodyData = self.getBodyData(from: request), let bodyString = String(data: bodyData, encoding: .utf8) {
                // Should contain sorted or at least matching key-values
                XCTAssertTrue(bodyString.contains("foo=bar"))
                XCTAssertTrue(bodyString.contains("baz=qux"))
            } else {
                XCTFail("POST request body was empty.")
            }

            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try! JSONEncoder().encode(MockDecodable(value: "success"))
            return (response, data)
        }

        let client = NetworkClient(baseURL: baseURL, basicAuth: nil, session: mockSession)

        // When
        let queryItems = [
            URLQueryItem(name: "foo", value: "bar"),
            URLQueryItem(name: "baz", value: "qux")
        ]
        let _: MockDecodable = try await client.sendRequest(path: "/post-route", queryItems: queryItems, cookie: nil)
    }

    func testSendRequest_HeadersAndCookies() async throws {
        // Given
        let basicAuth = Server.BasicAuth("admin", "admin123")
        let expectedCookie = "SID=dummyCookieValue"
        let customHeader = Server.CustomHeader(key: "X-Custom", value: "custom-value")

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Basic \(basicAuth.getAuthString())")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Cookie"), expectedCookie)
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-Custom"), "custom-value")

            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try! JSONEncoder().encode(MockDecodable(value: "headers-verified"))
            return (response, data)
        }

        let client = NetworkClient(baseURL: baseURL, basicAuth: basicAuth, customHeaders: [customHeader], session: mockSession)

        // When
        let _: MockDecodable = try await client.sendRequest(path: "/headers-route", queryItems: [], cookie: expectedCookie)
    }
    
    func testSendRequest_RawStringResponse() async throws {
        // Given
        let rawVersionString = "4.6.5"
        let rawData = rawVersionString.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, rawData)
        }

        let client = NetworkClient(baseURL: baseURL, basicAuth: nil, session: mockSession)

        // When
        let result: String = try await client.sendRequest(path: "/version", queryItems: [], cookie: nil)

        // Then
        XCTAssertEqual(result, rawVersionString)
    }

    func testSendRequest_Timeout() async {
        // Given
        MockURLProtocol.requestHandler = { request in
            Thread.sleep(forTimeInterval: 0.3)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        configuration.timeoutIntervalForRequest = 0.1
        configuration.timeoutIntervalForResource = 0.1
        let mockTimeoutSession = URLSession(configuration: configuration)

        let client = NetworkClient(baseURL: baseURL, basicAuth: nil, session: mockTimeoutSession)

        // When/Then
        do {
            let _: MockDecodable = try await client.sendRequest(path: "/test", queryItems: [], cookie: nil)
            XCTFail("Expected request to timeout, but it succeeded.")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testSendRequest_SSLUntrusted_ThrowsSSLUntrusted() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.serverCertificateUntrusted)
        }
        let client = NetworkClient(baseURL: baseURL, basicAuth: nil, session: mockSession)
        do {
            let _: MockDecodable = try await client.sendRequest(path: "/", queryItems: [], cookie: nil)
            XCTFail("Expected sslUntrusted error")
        } catch {
            XCTAssertEqual(error as? NetworkError, .sslUntrusted)
        }
    }

    func testTaskGroup_TimeoutRace() async {
        // Given/When/Then
        do {
            let _: Bool = try await withThrowingTaskGroup(of: Bool.self) { group in
                group.addTask {
                    try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                    return true
                }
                group.addTask {
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds (wins timeout)
                    throw NetworkError.timeout
                }
                
                let first = try await group.next()
                group.cancelAll()
                return first ?? false
            }
            XCTFail("Expected task group to fail with timeout error")
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.timeout)
        }
    }
    
    func test_networkErrors_haveLocalizedDescriptions() {
        let errors: [NetworkError] = [
            .invalidURL,
            .unauthorized,
            .invalidResponse,
            .httpError(statusCode: 409),
            .httpError(statusCode: 500),
            .timeout,
            .sslUntrusted
        ]
        for error in errors {
            XCTAssertNotNil(error.errorDescription, "\(error) should have an error description")
            XCTAssertFalse(error.errorDescription?.isEmpty ?? true, "\(error) error description should not be empty")
        }
    }
}
