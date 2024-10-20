//
//  TorrentDetailsTrackersView.swift
//  qBitControl
//

import SwiftUI

struct TorrentDetailsTrackersView: View {
    @Binding var torrentHash: String
    
    @State private var isLoaded = false

    @State private var showingEditAlert = false
    @State private var origURL = ""
    @State private var newURL = ""  

    @State private var timer: Timer?
    
    @State private var trackers: [Tracker] = []

    var body: some View {
        VStack {
            List {
                Section(header: Text("\(trackers.count)" + " " + NSLocalizedString("Trackers", comment: ""))) {
                    if !trackers.isEmpty {
                        ForEach($trackers, id: \.self) { tracker in
                            TorrentDetailsTrackerRow(tracker: tracker)
                                .contextMenu {
                                    if !["** [DHT] **", "** [PeX] **", "** [LSD] **"].contains(tracker.wrappedValue.url) {
                                        Button {
                                            showingEditAlert = true
                                            origURL = tracker.wrappedValue.url
                                            newURL = tracker.wrappedValue.url
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }

                                        Button(role: .destructive) {
                                            qBittorrent.removeTracker(hash: torrentHash, url: tracker.wrappedValue.url)
                                        } label: {
                                            Label("Remove", systemImage: "trash")
                                        }
                                    }
                                }
                        }
                    } else {
                        Text("No trackers")
                    }
                }
            }
                
            .navigationTitle("Trackers")
        }.onAppear() {
            qBittorrent.getTrackers(hash: torrentHash) {
                trackers in
                self.trackers = trackers
                self.isLoaded = true
            }
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                timer in
                qBittorrent.getTrackers(hash: torrentHash) {
                    trackers in
                    self.trackers = trackers
                }
            }
        }.onDisappear() {
            timer?.invalidate()
        }.alert("Edit Tracker", isPresented: $showingEditAlert) {
            TextField("New URL", text: $newURL)
            Button("Save") {
                qBittorrent.editTrackerURL(hash: torrentHash, origUrl: origURL, newURL: newURL)
            }
            Button("Cancel", role: .cancel) {
                showingEditAlert = false
            }
        }
    }
}



