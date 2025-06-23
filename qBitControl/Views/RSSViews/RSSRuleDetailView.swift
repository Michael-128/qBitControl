//
//  RSSRuleDetailView.swift
//  qBitControl
//
//  Created by 南山忆 on 2025/6/19.
//

import SwiftUI

struct RSSRuleDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel = RSSRulesViewModel.shared
    @ObservedObject var rule: RSSRuleModel
    @State private var selectedFeedURLs = Set<String>()
    @State private var savePathEnable = false
    @State private var editMode: EditMode = .inactive
    @State private var nameValidError: LocalizedStringKey?
    let isAdd: Bool
    var allFeeds = RSSNodeViewModel.shared.rssRootNode.getAllFeeds()
    
    var body: some View {
        List(selection: $selectedFeedURLs) {
            Section(header: Text("Rule Definition")) {
                if isAdd {
                    VStack(alignment: .leading) {
                        Text("Rule Name:")
                        TextField("Rule Name:", text: $rule.title, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: rule.title) { newValue in
                                validateName()
                            }
                        if let error = nameValidError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .transition(.opacity)
                        }
                    }
                }
                Toggle("Using Regular Expressions",isOn: $rule.rule.useRegex)
                RSSEditView(title: "Must Contain:", placeholder: "Must Contain:", text: $rule.rule.mustContain)
                RSSEditView(title: "Must Not Contain:", placeholder: "Must Not Contain:", text: $rule.rule.mustNotContain)
                RSSEditView(title: "Episode Filter:", placeholder: "Episode Filter:", text: $rule.rule.episodeFilter)
                Toggle("Using Smart Filter",isOn: $rule.rule.smartFilter)
                Toggle("Save Path", isOn: $savePathEnable)
                TextField("Save To", text: $rule.rule.savePath, axis: .vertical)
                    .disabled(!savePathEnable)
                    .opacity(savePathEnable ? 1.0 : 0.6)
                    .textFieldStyle(.roundedBorder)
            }
            
            Section(header: Text("Rule Settings")) {
                ForEach(allFeeds) { feed in
                    VStack(alignment: .leading) {
                        Text(feed.title.isEmpty ? "Feed" : feed.title)
                        Text(feed.url ?? "Unknown URL").lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .environment(\.editMode, $editMode)
            if !isAdd {
                Section(header: Text("Matching Articles")) {
                    ForEach(rule.filterResult) {
                        Text($0.title)
                    }
                }
            }
        }
        .environment(\.editMode, $editMode)
        .navigationTitle(isAdd ? NSLocalizedString("Add RSS Rule", comment: "")  : rule.title)
        .toolbar {
            isAdd ? Button("Add") {
                saveRule()
            } : Button("Submit") {
                saveRule()
            }
        }
        .onAppear {
            savePathEnable = !rule.rule.savePath.isEmpty
            selectedFeedURLs = Set(rule.rule.affectedFeeds)
            editMode = .active
            loadFilterResult()
        }
        
    }
    
    private func saveRule() {
        guard validateName() else { return }
        rule.rule.affectedFeeds = Array(selectedFeedURLs)
        viewModel.setRSSRule(rule) { success in
            if success {
                rule.getArticlesMatching()
                viewModel.getRssRules()
                if isAdd { dismiss() }
            }
        }
    }
    
    private func loadFilterResult() {
        rule.getArticlesMatching()
    }
    
    @discardableResult
    private func validateName() -> Bool {
        if rule.title.isEmpty {
            nameValidError = "Rule name cannot be empty"
        } else if viewModel.rssRules.contains(where: { $0.title == rule.title }) {
            nameValidError = "Rule name already exists"
        } else {
            nameValidError = nil
            return true
        }
        return false
    }
}

struct RSSEditView: View {
    let title: LocalizedStringKey
    let placeholder: LocalizedStringKey
    let text: Binding<String>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            TextField(placeholder, text: text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct RSSMatchItemView: View {
    let text: String
    var body: some View {
        Text(text)
            .disabled(true)
    }
}

#Preview {
    RSSRuleDetailView(rule: RSSRuleModel(title: "Example Rule", rule: RSSRule(mustContain: " .*(?=.*BT)(?=.*(仙逆|遮天|吞噬星空|不良人|神印王座|完美世界|斗破苍穹|一念永恒))(?=.*\\b([0-3](\\.\\d{1,3})?)\\b[gG][bB]?\\b).*(4K|2160P).*", mustNotContain: "test")), isAdd: false)
}
