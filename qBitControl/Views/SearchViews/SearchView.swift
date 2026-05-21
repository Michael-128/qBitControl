import SwiftUI

struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()

    var body: some View {
        ZStack {
            List {
                Section(header: Text("Search")) {
                    HStack {
                        TextField("Search", text: $viewModel.query)
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .keyboardType(.default)

                        if !viewModel.isRunning {
                            Button {
                                viewModel.startSearch()
                            } label: {
                                Text("Start")
                            }
                        } else {
                            Button {
                                viewModel.endSearch()
                            } label: {
                                Text("Stop")
                                    .foregroundStyle(.red)
                            }
                        }
                    }

                    Picker("Category", selection: $viewModel.category) {
                        ForEach(self.viewModel.categoriesArray, id: \.self) { category in
                            Text(LocalizedStringKey(category.name)).tag(category)
                        }
                    }
                }

                if viewModel.isResponse {
                    Section(header: Text("\(viewModel.lastestTotal)") + Text(" ") + Text("results")) {
                        ForEach(viewModel.latestResults, id: \.id) { result in
                            SearchRowView(result: result, onTap: self.viewModel.onRowTap)
                        }
                    }
                }
            }

            if !viewModel.isResponse {
                VStack {
                    Text("No results")
                }.foregroundStyle(.gray)
            }
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    NavigationLink {
                        SearchPluginsView()
                    } label: {
                        Image(systemName: "puzzlepiece.extension")
                    }
                    Button {
                        self.viewModel.isFilterSheet.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }.sheet(isPresented: $viewModel.isFilterSheet) {
            SearchFiltersView(viewModel: viewModel)
        }.sheet(isPresented: $viewModel.isTorrentAddSheet) { if let url = URL(string: self.viewModel.tappedResult?.fileUrl ?? "") { TorrentAddView(torrentUrls: .constant([url]), magnetOverride: true) } }
    }
}

struct SearchPluginsView: View {
    @State private var plugins: [SearchPlugin] = []
    @State private var isLoading = true
    @State private var showInstallAlert = false
    @State private var installURL = ""

    var body: some View {
        List {
            Section {
                Button {
                    showInstallAlert = true
                } label: {
                    Label("Install Plugin", systemImage: "plus.circle")
                }
            }

            Section(header: Text("\(plugins.count) Plugins")) {
                ForEach(plugins, id: \.self) { plugin in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(plugin.fullName ?? plugin.name ?? "Unknown")
                            if let version = plugin.version {
                                Text("v\(version)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { plugin.enabled ?? false },
                            set: { newValue in
                                if let name = plugin.name {
                                    qBittorrent.enableSearchPlugin(plugins: [name], enable: newValue)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { loadPlugins() }
                                }
                            }
                        ))
                        .labelsHidden()
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let name = plugin.name {
                                qBittorrent.uninstallSearchPlugin(names: [name])
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { loadPlugins() }
                            }
                        } label: {
                            Label("Uninstall", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Search Plugins")
        .overlay { if isLoading { ProgressView() } }
        .onAppear { loadPlugins() }
        .alert("Install Plugin", isPresented: $showInstallAlert) {
            TextField("Plugin URL", text: $installURL)
            Button("Install") {
                guard !installURL.isEmpty else { return }
                qBittorrent.installSearchPlugin(sources: [installURL])
                installURL = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { loadPlugins() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter the URL of the plugin to install.")
        }
    }

    private func loadPlugins() {
        isLoading = true
        qBittorrent.getSearchPlugins { result in
            DispatchQueue.main.async {
                plugins = result.sorted { ($0.fullName ?? "") < ($1.fullName ?? "") }
                isLoading = false
            }
        }
    }
}
