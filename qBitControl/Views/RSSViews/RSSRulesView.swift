//
//  RSSRulesView.swift
//  qBitControl
//
//  Created by 南山忆 on 2025/6/19.
//

import SwiftUI

struct RSSRulesView: View {
    @ObservedObject var viewModel = RSSRulesViewModel.shared
    @State private var showRenameAlert: Bool = false
    @State private var showAddRuleView: Bool = false
    @State private var newName: String = ""
    @State var currentName: String = ""
    var body: some View {
        List {
            Section(header: Text("Download Rules")) {
                ForEach(viewModel.rssRules) { rule in
                    NavigationLink {
                        RSSRuleDetailView(rule: rule, isAdd: false)
                    } label: {
                        Toggle(rule.title, isOn: Binding(get: {
                            rule.rule.enabled
                        }, set: {
                            rule.rule.enabled = $0
                        }))
                        .onChange(of: rule.rule.enabled) { _ in
                            viewModel.setRSSRule(rule)
                        }
                    }.contextMenu {
                        ruleItemMenu(name: rule.title)
                    }
                }
            }
        }.navigationTitle(viewModel.title)
            .toolbar {
                Button {
                    showAddRuleView.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
            .refreshable { refresh() }
            .sheet(
                isPresented: $showAddRuleView,
                content: {
                    NavigationView {
                        RSSRuleDetailView(
                            rule: RSSRuleModel(
                                title: "",
                                rule: .defaultAdd
                            ),
                            isAdd: true
                        )
                    }
                }
            )
            .alert(
                "Rename Rule",
                isPresented: $showRenameAlert,
                actions: { renameAlert() }
            )

    }

    private func refresh() {
        viewModel.getRssRules()
    }

    private func ruleItemMenu(name: String) -> some View {
        VStack {
            Button {
                currentName = name
                showRenameAlert.toggle()
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            Button(role: .destructive) {
                viewModel.removeRSSRule(name)
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }

    private func renameAlert() -> some View {
        VStack {
            TextField("Rule Name", text: $newName)
            Button("Rename") {
                viewModel.renameRSSRule(currentName, newName: newName)
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    //    RSSRulesView()
}
