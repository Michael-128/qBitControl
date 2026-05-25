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
                            .onSubmit { viewModel.startSearch() }

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

                if !viewModel.searchStatus.isEmpty {
                    Section {
                        HStack {
                            if viewModel.isRunning {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .padding(.trailing, 4)
                            }
                            Text(viewModel.searchStatus)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
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

                if !viewModel.isResponse && !viewModel.isRunning && !viewModel.searchHistory.isEmpty {
                    Section(header: HStack {
                        Text("Recent Searches")
                        Spacer()
                        Button("Clear") { viewModel.clearHistory() }
                            .font(.caption)
                    }) {
                        ForEach(viewModel.searchHistory, id: \.self) { query in
                            Button {
                                viewModel.query = query
                                viewModel.startSearch()
                            } label: {
                                Label(query, systemImage: "clock")
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }

            if !viewModel.isResponse && !viewModel.isRunning && viewModel.searchHistory.isEmpty {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("Search for torrents")
                        .foregroundStyle(.secondary)
                }
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
        }.sheet(isPresented: $viewModel.isTorrentAddSheet) {
            if let url = URL(string: self.viewModel.tappedResult?.fileUrl ?? "") {
                TorrentAddView(torrentUrls: .constant([url]), magnetOverride: true)
            }
        }
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
                Button {
                    qBittorrent.updateSearchPlugins()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { loadPlugins() }
                } label: {
                    Label("Update All Plugins", systemImage: "arrow.clockwise")
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
        .refreshable { loadPlugins() }
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
