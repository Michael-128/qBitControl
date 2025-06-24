//
//  RSSRule.swift
//  qBitControl
//
//  Created by 南山忆 on 2025/6/19.
//

import Foundation

struct RSSRule: Codable {
    var enabled: Bool = false
    var mustContain: String = ""
    var mustNotContain: String = ""
    var useRegex: Bool = false
    var episodeFilter: String = ""
    var smartFilter: Bool = false
    var previouslyMatchedEpisodes: [String] = []
    var affectedFeeds: [String] = []
    var ignoreDays: Int = 0
    var lastMatch: String = ""
    var addPaused: Bool = false
    var assignedCategory: String = ""
    var savePath: String = ""
    
    init(
        enabled: Bool = false,
         mustContain: String = "",
         mustNotContain: String = "",
         useRegex: Bool = false,
         episodeFilter: String = "",
         smartFilter: Bool = false,
         previouslyMatchedEpisodes: [String] = [],
         affectedFeeds: [String] = [],
         ignoreDays: Int = 0,
         lastMatch: String = "",
         addPaused: Bool = false,
         assignedCategory: String = "",
         savePath: String = ""
    ) {
        self.enabled = enabled
        self.mustContain = mustContain
        self.mustNotContain = mustNotContain
        self.useRegex = useRegex
        self.episodeFilter = episodeFilter
        self.smartFilter = smartFilter
        self.previouslyMatchedEpisodes = previouslyMatchedEpisodes
        self.affectedFeeds = affectedFeeds
        self.ignoreDays = ignoreDays
        self.lastMatch = lastMatch
        self.addPaused = addPaused
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled) ?? false
        self.mustContain = try container.decodeIfPresent(String.self, forKey: .mustContain) ?? ""
        self.mustNotContain = try container.decodeIfPresent(String.self, forKey: .mustNotContain) ?? ""
        self.useRegex = try container.decodeIfPresent(Bool.self, forKey: .useRegex) ?? false
        self.episodeFilter = try container.decodeIfPresent(String.self, forKey: .episodeFilter) ?? ""
        self.smartFilter = try container.decodeIfPresent(Bool.self, forKey: .smartFilter) ?? false
        self.previouslyMatchedEpisodes = try container.decodeIfPresent([String].self, forKey: .previouslyMatchedEpisodes) ?? []
        self.affectedFeeds = try container.decodeIfPresent([String].self, forKey: .affectedFeeds) ?? []
        self.ignoreDays = try container.decodeIfPresent(Int.self, forKey: .ignoreDays) ?? 0
        self.lastMatch = try container.decodeIfPresent(String.self, forKey: .lastMatch) ?? ""
        self.addPaused = try container.decodeIfPresent(Bool.self, forKey: .addPaused) ?? false
        self.assignedCategory = try container.decodeIfPresent(String.self, forKey: .assignedCategory) ?? ""
        self.savePath = try container.decodeIfPresent(String.self, forKey: .savePath) ?? ""
    }
    
    static let defaultAdd = RSSRule(enabled: true)
}

class RSSRuleModel: ObservableObject, Identifiable {
    struct RSSMatchItem: Identifiable {
        let id = UUID()
        var type: String
        var title: String
    }
    
    let id = UUID()
    var title: String = ""
    @Published var rule: RSSRule
    @Published var filterResult: [RSSMatchItem] = []
    private var isLoading: Bool = false
    
    init(title: String, rule: RSSRule) {
        self.title = title
        self.rule = rule
    }
    
    static func defauleAddRule() -> RSSRuleModel {
        RSSRuleModel(title: "", rule: .defaultAdd)
    }
    
    func getArticlesMatching() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            let result = await qBittorrent.getArticlesMatching(name: title)
            let items = result.flatMap { key, value in
                value.map { RSSMatchItem(type: key, title: $0) }
            }
            await MainActor.run {
                isLoading = false
                filterResult = items
            }
        }
    }
}
