import SwiftUI

struct ChangeTagsView: View {
    @State var torrentHash: String?
    @State var selectedTags: Set<String>
    
    @State private var allTags: [String] = []
    
    public var onTagsChange: ((Set<String>) -> Void)?
    
    init(torrentHash: String, selectedTags: [String]) {
        self.torrentHash = torrentHash
        self.selectedTags = Set(selectedTags)
    }
    
    init(onTagsChange: @escaping (Set<String>) -> Void) {
        self.selectedTags = Set()
        self.onTagsChange = onTagsChange
    }
    
    func removeTag(tag: String) {
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
    
    func addTag(tag: String) {
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
    
    var body: some View {
        VStack {
            Form {
                if allTags.count > 1 {
                    List(allTags, id: \.self) { tag in
                        Button {
                            if selectedTags.contains(tag) {
                                removeTag(tag: tag)
                            } else {
                                addTag(tag: tag)
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
                }
            }
            .navigationTitle("Tags")
        }.onAppear() {
            qBittorrent.getTags(completionHandler: { _tags in
                self.allTags = _tags.sorted()
            })
        }
    }
}
