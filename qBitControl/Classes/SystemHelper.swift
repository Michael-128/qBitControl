//
//  SystemHelper.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 28/09/2025.
//

class SystemHelper {
    public static let instance = SystemHelper()
    
    public var isLiquidGlass: Bool {
        if #available(iOS 26.0, *) {
            return true
        } else {
            return false
        }
    }
}
