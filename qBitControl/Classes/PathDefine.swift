//
//  PathDefine.swift
//  qBitControl
//
//  Created by 南山忆 on 2025/6/19.
//

import Foundation

// MARK: - RSS
extension String {
    static let rssItems = "/api/v2/rss/items"
    static let rssAddFeed = "/api/v2/rss/addFeed"
    static let rssAddFolder = "/api/v2/rss/addFolder"
    static let rssRemoveItem = "/api/v2/rss/removeItem"
    static let rssRefreshItem = "/api/v2/rss/refreshItem"
    static let rssMoveItem = "/api/v2/rss/moveItem"
    static let rssRules = "/api/v2/rss/rules"
    static let rssSetRule = "/api/v2/rss/setRule"
    static let rssRenameRule = "/api/v2/rss/renameRule"
    static let rssRemoveRule = "/api/v2/rss/removeRule"
    static let rssMatchArticles = "/api/v2/rss/matchingArticles"
}
