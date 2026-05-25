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
    @State private var showCategorySheet = false
    @State private var nameValidError: LocalizedStringKey?
    let isAdd: Bool
    var allFeeds = RSSNodeViewModel.shared.rssRootNode.getAllFeeds()
    
    var body: some View {
        List {
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

                TextField("Must Contain", text: $rule.rule.mustContain)
                TextField("Must Not Contain", text: $rule.rule.mustNotContain)
                if(rule.rule.useRegex) {
                    TextField("Episode Filter", text: $rule.rule.episodeFilter)
                }
                
                Toggle("Using Smart Filter",isOn: $rule.rule.smartFilter)
                Button {
                    showCategorySheet = true
                } label: {
                    HStack {
                        Text("Category")
                        Spacer()
                        Text(rule.rule.assignedCategory.isEmpty ? NSLocalizedString("Uncategorized", comment: "") : rule.rule.assignedCategory)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Toggle("Save Path", isOn: $savePathEnable)

                if(savePathEnable) {
                    TextField("Save To", text: $rule.rule.savePath)
                }
            }
            
            Section(header: Text("Rule Settings")) {
                ForEach(allFeeds) { feed in
                    HStack {
                        if(selectedFeedURLs.contains(feed.url ?? "")) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(feed.title.isEmpty ? "Feed" : feed.title)
                            Text(feed.url ?? "Unknown URL").lineLimit(1)
                                .foregroundColor(.secondary)
                        }
                    }.contentShape(Rectangle())
                        .onTapGesture {
                            if(selectedFeedURLs.contains(feed.url ?? "")) {
                                selectedFeedURLs.remove(feed.url ?? "")
                            } else {
                                selectedFeedURLs.insert(feed.url ?? "")
                            }
                        }
                }
            }
            if !isAdd {
                Section(header: Text("Matching Articles")) {
                    ForEach(rule.filterResult) {
                        Text($0.title)
                    }
                }
            }
        }
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
            loadFilterResult()
        }
        .sheet(isPresented: $showCategorySheet) {
            NavigationView {
                ChangeCategoryView(category: rule.rule.assignedCategory, onCategorySelected: { category in
                    DispatchQueue.main.async {
                        rule.rule.assignedCategory = category.name
                        rule.rule.savePath = category.savePath
                        if !category.savePath.isEmpty {
                            savePathEnable = true
                        }
                        showCategorySheet = false
                    }
                })
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showCategorySheet = false
                        }
                    }
                }
            }
        }
        
    }
    
    private func saveRule() {
        if isAdd, !validateName(){ return }
        rule.rule.affectedFeeds = Array(selectedFeedURLs)
        viewModel.setRSSRule(rule) { success in
            guard success else { return }
            viewModel.getRssRules()
            if isAdd {
                dismiss()
            } else {
                rule.getArticlesMatching()
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
        } else {
            nameValidError = nil
            return true
        }
        return false
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
