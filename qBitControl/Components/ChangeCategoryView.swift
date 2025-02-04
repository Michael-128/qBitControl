import SwiftUI

struct ChangeCategoryView: View {
    
    @State var torrentHash: String
    
    @State private var categories: [Category] = []

    @State var category: String
    
    @State private var showAddCategoryAlert = false
    @State private var newCategoryName = ""
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Add Category")) {
                    Button {
                        showAddCategoryAlert = true
                    } label: {
                        Label("Add Category", systemImage: "plus.circle")
                    }.alert("Add New Category", isPresented: $showAddCategoryAlert, actions: {
                        TextField("Category Name", text: $newCategoryName)
                        Button("Add", action: {
                            // Add category
                            print(newCategoryName)
                            newCategoryName = ""
                        })
                        Button("Cancel", role: .cancel, action: {
                            newCategoryName = ""
                        })
                    })
                }
                
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
