//
//  TorrentDetailsTrackersView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 03/11/2022.
//

import SwiftUI

struct TorrentDetailsTrackersView: View {
    
    @Binding var torrentHash: String
    
    @State private var timer: Timer?
    
    @State private var trackers: [Tracker] = []
    
    func getTrackers() {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/trackers", queryItems: [URLQueryItem(name: "hash", value: torrentHash)])
        
        qBitRequest.requestTrackersJSON(request: request, completionHandler: {
            trackers in
            self.trackers = trackers
        })
    }
    
    var body: some View {
        List {
            Section(header: Text("\(trackers.count) Trackers")) {
                ForEach($trackers, id: \.url) {
                    tracker in
                    TorrentDetailsTrackerRow(tracker: tracker)
                }
            }
            
            .navigationTitle("Trackers")
        }.onAppear() {
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                timer in
                getTrackers()
            }
            getTrackers()
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
