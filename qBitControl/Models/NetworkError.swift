//
//  NetworkError.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 17/06/2025.
//

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case noData
    case decodingError(Error)
    case networkError(Error)
}
