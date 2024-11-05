//
//  TorrentDetailsTrackersView.swift
//  qBitControl
//

import SwiftUI

struct TrackersView: View {
    @ObservedObject var viewModel: TrackersViewModel
    
    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Manage")) {
                    Button {
                        viewModel.showAddTrackerPopover()
                    } label: {
                        Label("Add Tracker", systemImage: "plus.circle")
                    }
                }
                
                Section(header: Text("\($viewModel.trackers.count)" + " " + NSLocalizedString("Trackers", comment: ""))) {
                    ForEach($viewModel.trackers, id: \.url) { tracker in
                        TrackerRow(tracker: tracker)
                            .contextMenu {
                                if !["** [DHT] **", "** [PeX] **", "** [LSD] **"].contains(tracker.wrappedValue.url) {
                                    Button {
                                        viewModel.showEditTrackerPopover(tracker: tracker.wrappedValue)
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }

                                    Button(role: .destructive) {
                                        viewModel.removeTracker(tracker: tracker.wrappedValue)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                    }
                }
            }
                
            .navigationTitle("Trackers")
        }.onAppear() {
            viewModel.setRefreshTimer()
        }.onDisappear() {
            viewModel.removeRefreshTimer()
        }.alert("Edit Tracker", isPresented: $viewModel.isEditTrackerAlert, actions: {
            VStack {
                TextField("New URL", text: $viewModel.newURL)
                Button("Save") {
                    viewModel.editTracker()
                }
                Button("Cancel", role: .cancel) {}
            }
        }).alert("Add Tracker", isPresented: $viewModel.isAddTrackerAlert, actions: {
            TextField("URL", text: $viewModel.newURL)
            Button("Add") {
                viewModel.addTracker()
            }
            Button("Cancel", role: .cancel) { viewModel.isAddTrackerAlert = false }
        })
    }
}
