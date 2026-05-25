import SwiftUI

struct ChangeCategoryView: View {
    @State var torrentHash: String?
    @State private var categories: [Category] = []
    @State public var category: String

    let defaultCategory: Category = Category(name: NSLocalizedString("Uncategorized", comment: ""), savePath: "")
    func isDefaultCategorySelected(currentCategory: String) -> Bool {
        return currentCategory == defaultCategory.name && category == ""
    }

    @State private var showAddCategorySheet = false
    @State private var newCategoryName = ""
    @State private var newCategorySavePath = "/downloads"

    @State private var showEditSheet = false
    @State private var editingCategory: Category?
    @State private var editName = ""
    @State private var editSavePath = ""

    public var onCategoryChange: ((Category) -> Void)?
    public var onCategorySelected: ((Category) -> Void)?

    private var existingPaths: [String] {
        let paths = categories
            .map { $0.savePath }
            .filter { !$0.isEmpty }
        return Array(Set(paths)).sorted()
    }

    private func getCategories() {
        qBittorrent.getCategories(completionHandler: { _categories in
            var categories = _categories.map { $0.value }
            categories.sort { $0.name < $1.name }
            categories.insert(defaultCategory, at: 0)
            self.categories = categories
            clearSelectedCategories()
        })
    }

    private func clearSelectedCategories() {
        if let onCategoryChange = self.onCategoryChange {
            if !categories.map({ $0.name }).contains(category) {
                onCategoryChange(defaultCategory)
            }
        }
    }

    private func openEditSheet(for cat: Category) {
        editingCategory = cat
        editName = cat.name
        editSavePath = cat.savePath
        showEditSheet = true
    }

    private func saveEdit() {
        guard let editing = editingCategory else { return }
        let nameChanged = editName != editing.name
        let pathChanged = editSavePath != editing.savePath

        guard nameChanged || pathChanged else {
            showEditSheet = false
            return
        }

        qBittorrent.editCategory(
            name: editing.name,
            newName: nameChanged ? editName : nil,
            newSavePath: pathChanged ? editSavePath : nil,
            then: { status in
                if status == 200 {
                    DispatchQueue.main.async {
                        self.getCategories()
                    }
                }
            }
        )
        showEditSheet = false
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Add Category")) {
                    Button {
                        showAddCategorySheet = true
                    } label: {
                        Label("Add Category", systemImage: "plus.circle")
                    }
                }

                if categories.count > 1 {
                    Section(header: Text("Categories")) {
                        List {
                            ForEach(categories, id: \.self) { cat in
                                HStack {
                                    Button {
                                        if self.category != cat.name {
                                            self.category = cat.name
                                        }
                                        if let onCategorySelected = self.onCategorySelected {
                                            let selected = cat.name == defaultCategory.name ? Category(name: "", savePath: "") : cat
                                            onCategorySelected(selected)
                                        }
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(cat.name)
                                                    .foregroundStyle(.foreground)
                                                if !cat.savePath.isEmpty {
                                                    Text(cat.savePath)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                            Spacer()
                                            if self.category == cat.name || isDefaultCategorySelected(currentCategory: cat.name) {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.accentColor)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)

                                    if cat.name != defaultCategory.name {
                                        Button {
                                            openEditSheet(for: cat)
                                        } label: {
                                            Image(systemName: "pencil")
                                                .foregroundColor(.secondary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .onDelete(perform: { offsets in
                                for index in offsets {
                                    let category = categories[index].name
                                    qBittorrent.removeCategory(category: category, then: { status in print(status) })
                                }

                                categories.remove(atOffsets: offsets)
                                self.clearSelectedCategories()
                            })
                        }
                    }
                }
            }
            .navigationTitle("Categories")
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationView {
                Form {
                    Section(header: Text("Category Name")) {
                        TextField("Name", text: $editName)
                    }
                    Section(header: Text("Save Path")) {
                        TextField("Save Path", text: $editSavePath)
                    }
                }
                .navigationTitle("Edit Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showEditSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveEdit()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddCategorySheet) {
            NavigationView {
                Form {
                    Section(header: Text("Category Name")) {
                        TextField("Name", text: $newCategoryName)
                    }
                    Section(header: Text("Save Path")) {
                        TextField("/downloads", text: $newCategorySavePath)
                    }
                    if !existingPaths.isEmpty {
                        Section(header: Text("Existing Paths")) {
                            ForEach(existingPaths, id: \.self) { (path: String) in
                                Button {
                                    newCategorySavePath = path
                                } label: {
                                    HStack {
                                        Image(systemName: "folder")
                                            .foregroundStyle(.secondary)
                                        Text(path)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        if newCategorySavePath == path {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Add Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            newCategoryName = ""
                            newCategorySavePath = "/downloads"
                            showAddCategorySheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            guard !newCategoryName.isEmpty else { return }
                            let path = newCategorySavePath.isEmpty ? nil : newCategorySavePath
                            qBittorrent.addCategory(category: newCategoryName, savePath: path, then: { status in
                                if status == 200 {
                                    DispatchQueue.main.async { self.getCategories() }
                                }
                            })
                            newCategoryName = ""
                            newCategorySavePath = "/downloads"
                            showAddCategorySheet = false
                        }
                        .disabled(newCategoryName.isEmpty)
                    }
                }
            }
        }
        .onAppear() {
            print(category)
            self.getCategories()
        }
        .onChange(of: category) { category in
            if let onCategoryChange = self.onCategoryChange, let category = categories.first(where: { $0.name == category }) { onCategoryChange(category) }
            if let hash = self.torrentHash { qBittorrent.setCategory(hash: hash, category: category == defaultCategory.name ? "" : category) }
        }
    }
}
