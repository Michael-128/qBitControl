//
//  Log.swift
//  qBitControl
//
//  Created by 南山忆 on 2025/6/23.
//

import Foundation

func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
#if DEBUG
    let fileName = (file as NSString).lastPathComponent
    let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
    print("[\(timestamp)] [\(fileName):\(line) \(function)] \(message)")
#endif
}
