//
//  RSSError.swift
//  qBitControl
//

import Foundation

enum RSSError: LocalizedError, Identifiable {
    case invalidURL
    case alreadyExists
    case unauthorized
    case timeout
    case unknown(Int)
    
    var id: String {
        switch self {
        case .invalidURL: return "invalidURL"
        case .alreadyExists: return "alreadyExists"
        case .unauthorized: return "unauthorized"
        case .timeout: return "timeout"
        case .unknown(let code): return "unknown_\(code)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid RSS URL. Please check the address and try again.", comment: "RSS invalid URL error")
        case .alreadyExists:
            return NSLocalizedString("The feed or folder already exists, or the specified path does not exist.", comment: "RSS Conflict error")
        case .unauthorized:
            return NSLocalizedString("Unauthorized. Please re-login to the server.", comment: "RSS unauthorized error")
        case .timeout:
            return NSLocalizedString("Request timed out. Please check your network connection.", comment: "RSS timeout error")
        case .unknown(let statusCode):
            return String(format: NSLocalizedString("Server returned error code %d.", comment: "RSS unknown error"), statusCode)
        }
    }
}
