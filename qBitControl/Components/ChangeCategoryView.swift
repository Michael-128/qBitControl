import SwiftUI

struct ChangeCategoryView: View {
    
    @State var torrentHash: String
    
    @State private var categories: [Category] = []

    @State var category: String

    
    var body: some View {
        VStack {
            Form {
                if categories.count > 1 {
                    Picker("Categories", selection: $category) {
                        Text("Uncategorized").tag("")
                        ForEach(categories, id: \.self) { category in
                            Text(category.name).tag(category.name)
                        }
                    }.pickerStyle(.inline)
                }
            }
            .navigationTitle("Categories")
        }.onAppear() {
            qBittorrent.getCategories(completionHandler: { _categories in
                var categories = _categories.map { $0.value }
                categories.sort { $0.name < $1.name }
                
                self.categories = categories
            })
        }.onChange(of: category) { category in
            qBittorrent.setCategory(hash: torrentHash, category: category)
        }
    }
}
