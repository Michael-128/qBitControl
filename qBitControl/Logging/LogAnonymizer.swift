//
//  LogAnonymizer.swift
//  qBitControl
//

import Foundation

struct LogAnonymizer {
    
    private static let passwordQueryRegex = try? NSRegularExpression(
        pattern: #"(password|pwd|pass|secret|sid|token)=([^&\s]+)"#,
        options: .caseInsensitive
    )
    
    private static let basicAuthHeaderRegex = try? NSRegularExpression(
        pattern: #"Authorization:\s*Basic\s*([a-zA-Z0-9+/=]+)"#,
        options: .caseInsensitive
    )
    
    private static let urlCredentialsRegex = try? NSRegularExpression(
        pattern: #"(https?://)([^:\s]+):([^@\s]+)@"#,
        options: .caseInsensitive
    )
    
    static func anonymize(_ text: String) -> String {
        var result = text
        
        // 1. Redact query parameter credentials
        if let regex = passwordQueryRegex {
            let nsRange = NSRange(result.startIndex..<result.endIndex, in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: nsRange,
                withTemplate: "$1=[REDACTED]"
            )
        }
        
        // 2. Redact HTTP basic auth headers
        if let regex = basicAuthHeaderRegex {
            let nsRange = NSRange(result.startIndex..<result.endIndex, in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: nsRange,
                withTemplate: "Authorization: Basic [REDACTED]"
            )
        }
        
        // 3. Redact inline credentials in URLs
        if let regex = urlCredentialsRegex {
            let nsRange = NSRange(result.startIndex..<result.endIndex, in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: nsRange,
                withTemplate: "$1$2:[REDACTED]@"
            )
        }
        
        return result
    }
}
