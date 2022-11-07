//
//  TorrentDetailsTrackersView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 03/11/2022.
//

import SwiftUI

struct TorrentDetailsTrackersView: View {
    
    @Binding var torrentHash: String
    
    @State private var isLoaded = false
    @State private var timer: Timer?
    
    @State private var trackers: [Tracker] = []
    
    func getTrackers() {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/trackers", queryItems: [URLQueryItem(name: "hash", value: torrentHash)])
        
        qBitRequest.requestTrackersJSON(request: request, completionHandler: {
            trackers in
            self.trackers = trackers
            self.isLoaded = true
        })
    }
    
    var body: some View {
        VStack {
            if isLoaded {
                List {
                    Section(header: Text("\(trackers.count) Trackers")) {
                        if trackers.count > 1 {
                            ForEach($trackers, id: \.self) {
                                tracker in
                                TorrentDetailsTrackerRow(tracker: tracker)
                            }
                        } else {
                            Text("No trackers")
                        }
                    }
                    
                    .navigationTitle("Trackers")
                }
            } else {
                ProgressView().progressViewStyle(.circular)
                    .navigationTitle("Trackers")
            }
        }.onAppear() {
            getTrackers()
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                timer in
                getTrackers()
            }
        }.onDisappear() {
            timer?.invalidate()
        }
    }
}

struct TorrentDetailsTrackersView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
