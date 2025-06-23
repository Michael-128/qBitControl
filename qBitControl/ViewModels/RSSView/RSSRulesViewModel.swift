//
//  RSSRulesViewModel.swift
//  qBitControl
//
//  Created by 南山忆 on 2025/6/19.
//

import Foundation

class RSSRulesViewModel: ObservableObject {
    static public let shared = RSSRulesViewModel()
    @Published public var rssRules: [RSSRuleModel] = []
    var title: String = "RSS Rules"
    var isLoading: Bool = false
    init() {
        getRssRules()
    }

    func getRssRules() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            let rules = await qBittorrent.getRSSRules()
            let result = rules.map {
                RSSRuleModel(title: $0.key, rule: $0.value)
            }.sorted { $0.title < $1.title }
            await MainActor.run {
                isLoading = false
                rssRules = result
            }
        }
    }

    func setRSSRule(_ rule: RSSRuleModel, completed: ((Bool) -> Void)? = nil) {
        guard !isLoading else { return }
        isLoading = true
        Task {
            let success = await qBittorrent.setRSSRule(rule: rule)
            await MainActor.run {
                isLoading = false
                completed?(success)
            }
        }
    }

    func removeRSSRule(_ name: String) {
        guard !isLoading else { return }
        isLoading = true
        Task {
            _ = await qBittorrent.removeRSSRule(name: name)
            await MainActor.run {
                isLoading = false
                if let index = rssRules.firstIndex(where: { $0.title == name }) {
                    rssRules.remove(at: index)
                }
            }
        }
    }

    func renameRSSRule(_ name: String, newName: String) {
        guard !isLoading else { return }
        isLoading = true
        Task {
            let success = await qBittorrent.renameRSSRule(name: name, newName: newName)
            await MainActor.run {
                isLoading = false
                if success {
                    var rules = rssRules.filter { $0.title != name }
                    let rule = rssRules.first { $0.title == name }
                    rule?.title = newName
                    if let rule { rules.append(rule) }
                    rssRules = rules.sorted { $0.title < $1.title }
                }
            }
        }
    }

}
