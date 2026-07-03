import SwiftUI

struct ChangeTagsView: View {
    @State var torrentHash: String?
    @State var selectedTags: Set<String>
    @State private var allTags: [String] = []
    
    public var onTagsChange: ((Set<String>) -> Void)?
    
    @State private var showAddTagAlert = false
    @State private var newTagName = ""
    
    private var client: TorrentClientProtocol {
        ServersHelper.shared.client ?? MockTorrentClient()
    }
    
    init(torrentHash: String, selectedTags: [String]) {
        self.torrentHash = torrentHash
        self.selectedTags = Set(selectedTags)
    }
    
    init(selectedTags: Set<String>, onTagsChange: @escaping (Set<String>) -> Void) {
        self.selectedTags = selectedTags
        self.onTagsChange = onTagsChange
    }
    
    func getTags() {
        Task {
            do {
                let tags = try await client.getTags()
                self.allTags = tags.sorted()
                self.clearSelectedTags()
                // Update global metadata cache
                ServersHelper.shared.tags = tags
            } catch {
                print("Failed to get tags: \(error)")
            }
        }
    }
    
    func unsetTag(tag: String) {
        if let hash = self.torrentHash {
            Task {
                do {
                    let success = try await client.unsetTag(hash: hash, tag: tag)
                    if success {
                        selectedTags.remove(tag)
                        if let onTagsChange = self.onTagsChange {
                            onTagsChange(selectedTags)
                        }
                    }
                } catch {
                    print("Failed to unset tag: \(error)")
                }
            }
        } else {
            selectedTags.remove(tag)
            if let onTagsChange = self.onTagsChange {
                onTagsChange(selectedTags)
            }
        }
    }
    
    func setTag(tag: String) {
        if let hash = self.torrentHash {
            Task {
                do {
                    let success = try await client.setTag(hash: hash, tag: tag)
                    if success {
                        selectedTags.insert(tag)
                        if let onTagsChange = self.onTagsChange {
                            onTagsChange(selectedTags)
                        }
                    }
                } catch {
                    print("Failed to set tag: \(error)")
                }
            }
        } else {
            selectedTags.insert(tag)
            if let onTagsChange = self.onTagsChange {
                onTagsChange(selectedTags)
            }
        }
    }
    
    func addTag(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        Task {
            do {
                let status = try await client.addTag(tag: trimmed)
                print("[ChangeTagsView] addTag returned status: \(status) for tag: \(trimmed)")
                if status == 200 || status == 204 {
                    self.getTags()
                }
            } catch {
                print("[ChangeTagsView] Failed to add tag: \(error)")
            }
        }
    }
    
    func removeTag(tag: String) {
        Task {
            do {
                let status = try await client.removeTag(tag: tag)
                print("[ChangeTagsView] removeTag returned status: \(status) for tag: \(tag)")
                if status == 200 || status == 204 {
                    self.getTags()
                }
            } catch {
                print("[ChangeTagsView] Failed to remove tag: \(error)")
            }
        }
    }
    
    func clearSelectedTags() {
        if let onTagsChange = self.onTagsChange {
            self.selectedTags = self.selectedTags.filter { tag in
                return self.allTags.contains(tag)
            }
            onTagsChange(selectedTags)
        }
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Add Tag")) {
                    Button {
                        showAddTagAlert = true
                    } label: {
                        Label("Add Tag", systemImage: "plus.circle")
                    }.alert("Add New Tag", isPresented: $showAddTagAlert, actions: {
                        TextField("Tag Name", text: $newTagName)
                        Button("Add", action: {
                            self.addTag(name: newTagName)
                            newTagName = ""
                        })
                        Button("Cancel", role: .cancel, action: {
                            newTagName = ""
                        })
                    })
                }
                
                if allTags.count > 1 {
                    Section {
                        List {
                            ForEach(allTags, id: \.self) { tag in
                                Button {
                                    if selectedTags.contains(tag) {
                                        unsetTag(tag: tag)
                                    } else {
                                        setTag(tag: tag)
                                    }
                                } label: {
                                    HStack {
                                        Text(tag)
                                            .foregroundStyle(.foreground)
                                        Spacer()
                                        if selectedTags.contains(tag) {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: { atOffsets in
                                atOffsets.forEach { index in
                                    self.removeTag(tag: self.allTags[index])
                                }
                                self.allTags.remove(atOffsets: atOffsets)
                            })
                        }
                    }
                }
            }
            .navigationTitle("Tags")
        }.onAppear() {
            self.getTags()
        }
    }
}
