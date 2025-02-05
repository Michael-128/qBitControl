import SwiftUI

struct ChangeTagsView: View {
    @State var torrentHash: String?
    @State var selectedTags: Set<String>
    
    @State private var allTags: [String] = []
    
    public var onTagsChange: ((Set<String>) -> Void)?
    
    @State private var showAddTagAlert = false
    @State private var newTagName = ""
    
    init(torrentHash: String, selectedTags: [String]) {
        self.torrentHash = torrentHash
        self.selectedTags = Set(selectedTags)
    }
    
    init(selectedTags: Set<String>, onTagsChange: @escaping (Set<String>) -> Void) {
        self.selectedTags = selectedTags
        self.onTagsChange = onTagsChange
    }
    
    func getTags() {
        qBittorrent.getTags(completionHandler: { tags in
            self.allTags = tags.sorted()
        })
    }
    
    func unsetTag(tag: String) {
        if let hash = self.torrentHash {
            qBittorrent.unsetTag(hash: hash, tag: tag, result: { isSuccess in
                if(isSuccess) { selectedTags.remove(tag) }
            })
        } else {
            selectedTags.remove(tag)
        }
        
        if let onTagsChange = self.onTagsChange {
            onTagsChange(selectedTags)
        }
    }
    
    func setTag(tag: String) {
        if let hash = self.torrentHash {
            qBittorrent.setTag(hash: hash, tag: tag, result: { isSuccess in
                if(isSuccess) { selectedTags.insert(tag) }
            })
        } else {
            selectedTags.insert(tag)
        }
        
        if let onTagsChange = self.onTagsChange {
            onTagsChange(selectedTags)
        }
    }
    
    func addTag() {
        qBittorrent.addTag(tag: newTagName, then: { status in
            if(status == 200) {
                self.getTags()
            }
        })
    }
    
    func removeTag(tag: String) {
        qBittorrent.removeTag(tag: tag, then: { status in
            if(status == 200) {
                self.getTags()
                self.clearSelectedTags()
            }
        })
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
                            self.addTag()
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
