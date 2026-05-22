import SwiftUI

struct PreferencesView: View {
    @StateObject private var viewModel = PreferencesViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var hasLoaded = false

    private var saveToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                viewModel.save { success in
                    viewModel.saveSuccess = success
                    viewModel.showSaveAlert = true
                    if success {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                    }
                }
            }
            .disabled(viewModel.isSaving || viewModel.loadFailed)
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading preferences...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else if viewModel.loadFailed {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text("Failed to load preferences")
                            .font(.headline)
                        Text(viewModel.saveError ?? "Unknown error")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            viewModel.load()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    Form {
                        Section {
                            NavigationLink {
                                PrefDownloadsView(vm: viewModel)
                                    .toolbar { saveToolbarItem }
                            } label: {
                                Label("Downloads", systemImage: "arrow.down.circle")
                            }
                            NavigationLink {
                                PrefConnectionView(vm: viewModel)
                                    .toolbar { saveToolbarItem }
                            } label: {
                                Label("Connection", systemImage: "network")
                            }
                            NavigationLink {
                                PrefSpeedView(vm: viewModel)
                                    .toolbar { saveToolbarItem }
                            } label: {
                                Label("Speed", systemImage: "speedometer")
                            }
                            NavigationLink {
                                PrefBitTorrentView(vm: viewModel)
                                    .toolbar { saveToolbarItem }
                            } label: {
                                Label("BitTorrent", systemImage: "bolt.horizontal")
                            }
                            NavigationLink {
                                PrefRSSView(vm: viewModel)
                                    .toolbar { saveToolbarItem }
                            } label: {
                                Label("RSS", systemImage: "dot.radiowaves.up.forward")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Server Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                saveToolbarItem
            }
            .onAppear {
                if !hasLoaded {
                    hasLoaded = true
                    viewModel.load()
                }
            }
        }
        .alert("Save Preferences", isPresented: $viewModel.showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if viewModel.saveSuccess {
                Text("Preferences saved successfully.")
            } else {
                Text(viewModel.saveError ?? "Failed to save preferences.")
            }
        }
    }
}
