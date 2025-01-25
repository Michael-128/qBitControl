import SwiftUI

struct ChangeTagsView: View {
    @State var torrentHash: String
    @State var selectedTags: Set<String>
    
    @State private var allTags: [String] = []
    
    init(torrentHash: String, selectedTags: [String]) {
        self.torrentHash = torrentHash
        self.selectedTags = Set(selectedTags)
    }
    
    func removeTag(tag: String) {
        qBittorrent.unsetTag(hash: self.torrentHash, tag: tag, result: { isSuccess in
            if(isSuccess) { selectedTags.remove(tag) }
        })
    }
    
    func addTag(tag: String) {
        qBittorrent.setTag(hash: self.torrentHash, tag: tag, result: { isSuccess in
            if(isSuccess) { selectedTags.insert(tag) }
        })
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
