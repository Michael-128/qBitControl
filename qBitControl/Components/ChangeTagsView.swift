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
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "get_tags_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func unsetTag(tag: String) {
        selectedTags.remove(tag)
        if let onTagsChange = self.onTagsChange {
            onTagsChange(selectedTags)
        }
        if let hash = self.torrentHash {
            qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: [hash]) { torrent in
                var tagList = torrent.tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                tagList.removeAll { $0 == tag }
                torrent.tags = tagList.joined(separator: ", ")
            }
            Task {
                do {
                    let _ = try await client.unsetTag(hash: hash, tag: tag)
                } catch {
                    AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "unset_tag_failed", errorDescription: error.localizedDescription))
                }
            }
        }
    }
    
    func setTag(tag: String) {
        selectedTags.insert(tag)
        if let onTagsChange = self.onTagsChange {
            onTagsChange(selectedTags)
        }
        if let hash = self.torrentHash {
            qBitData.shared.cacheManager.updateTorrentsOptimistically(hashes: [hash]) { torrent in
                var tagList = torrent.tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                if !tagList.contains(tag) {
                    tagList.append(tag)
                }
                torrent.tags = tagList.joined(separator: ", ")
            }
            Task {
                do {
                    let _ = try await client.setTag(hash: hash, tag: tag)
                } catch {
                    AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "set_tag_failed", errorDescription: error.localizedDescription))
                }
            }
        }
    }
    
    
    func addTag(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        Task {
            do {
                let status = try await client.addTag(tag: trimmed)
                AppLogger.log(.info, SystemEventPayload(category: .torrents, eventName: "add_tag_status", message: "addTag returned status: \(status) for tag: \(trimmed)"))
                if status == 200 || status == 204 {
                    self.getTags()
                }
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "add_tag_failed", errorDescription: error.localizedDescription))
            }
        }
    }
    
    func removeTag(tag: String) {
        Task {
            do {
                let status = try await client.removeTag(tag: tag)
                AppLogger.log(.info, SystemEventPayload(category: .torrents, eventName: "remove_tag_status", message: "removeTag returned status: \(status) for tag: \(tag)"))
                if status == 200 || status == 204 {
                    self.getTags()
                }
            } catch {
                AppLogger.log(.error, GeneralErrorPayload(category: .torrents, eventName: "remove_tag_failed", errorDescription: error.localizedDescription))
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
