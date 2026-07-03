import SwiftUI

struct ChangeCategoryView: View {
    @State var torrentHash: String?
    @State private var categories: [Category] = []
    @State var category: String
    
    private var client: TorrentClientProtocol {
        ServersHelper.shared.client ?? MockTorrentClient()
    }
    
    let defaultCategory: Category = Category(name: NSLocalizedString("Uncategorized", comment: ""), savePath: "")
    func isDefaultCategorySelected(currentCategory: String) -> Bool {
        return currentCategory == defaultCategory.name && category == ""
    }
    
    @State private var showAddCategoryAlert = false
    @State private var newCategoryName = ""
    
    public var onCategoryChange: ((Category) -> Void)?
    
    init(torrentHash: String? = nil, category: String, onCategoryChange: ((Category) -> Void)? = nil) {
        self._torrentHash = State(initialValue: torrentHash)
        self._category = State(initialValue: category)
        self.onCategoryChange = onCategoryChange
    }
    
    private func getCategories() {
        Task {
            do {
                let _categories = try await client.getCategories()
                var categories = _categories.map { $0.value }
                categories.sort { $0.name < $1.name }
                categories.insert(defaultCategory, at: 0)
                self.categories = categories
                clearSelectedCategories()
                // Update global metadata cache
                ServersHelper.shared.categories = _categories
            } catch {
                print("Failed to get categories: \(error)")
            }
        }
    }
    
    private func clearSelectedCategories() {
        if let onCategoryChange = self.onCategoryChange {
            if !categories.map({ $0.name }).contains(category) {
                onCategoryChange(defaultCategory)
            }
        }
    }
    
    private func addCategory(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        Task {
            do {
                let status = try await client.addCategory(category: trimmed, savePath: nil)
                if status == 200 || status == 204 {
                    self.getCategories()
                }
            } catch {
                print("Failed to add category: \(error)")
            }
        }
    }
    
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
                            self.addCategory(name: newCategoryName)
                            newCategoryName = ""
                        })
                        Button("Cancel", role: .cancel, action: {
                            newCategoryName = ""
                        })
                    })
                }
                
                if categories.count > 1 {
                    Section(header: Text("Categories")) {
                        List {
                            ForEach(categories, id: \.self) { category in
                                Button {
                                    if(self.category != category.name) { self.category = category.name }
                                } label: {
                                    HStack {
                                        Text(category.name)
                                            .foregroundStyle(.foreground)
                                        Spacer()
                                        if(self.category == category.name || isDefaultCategorySelected(currentCategory: category.name)) {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: { offsets in
                                for index in offsets {
                                    let categoryName = categories[index].name
                                    Task {
                                        do {
                                            let _ = try await client.removeCategory(category: categoryName)
                                            ServersHelper.shared.refreshCategories()
                                        } catch {
                                            print("Failed to remove category: \(error)")
                                        }
                                    }
                                }
                                
                                categories.remove(atOffsets: offsets)
                                self.clearSelectedCategories()
                            })
                        }
                    }
                }
            }
            .navigationTitle("Categories")
        }.onAppear() {
            self.getCategories()
        }.onChange(of: category) { category in
            if let onCategoryChange = self.onCategoryChange, let categoryObj = categories.first(where: { $0.name == category }) { onCategoryChange(categoryObj) }
            if let hash = self.torrentHash {
                Task {
                    do {
                        try await client.setCategory(hash: hash, category: category == defaultCategory.name ? "" : category)
                    } catch {
                        print("Failed to set category: \(error)")
                    }
                }
            }
        }
    }
}
