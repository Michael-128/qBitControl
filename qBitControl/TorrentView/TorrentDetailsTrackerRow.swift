//
//  TorrentDetailsTrackerRow.swift
//  qBitControl
//

import SwiftUI

struct TorrentDetailsTrackerRow: View {
    
    @Binding var tracker: Tracker
    
    func getStatus(status: Int) -> String {
        switch status {
        case 0:
            return "Disabled"
        case 1:
            return "Not contacted yet"
        case 2:
            return "Working"
        case 3:
            return "Updating"
        case 4:
            return "Not working"
        default:
            return "Unknown"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(tracker.url)
                Spacer()
            }
            HStack(spacing: 3) {
                Group {
                    if tracker.msg == "" {
                        Text(getStatus(status: tracker.status))
                    } else {
                        Text(tracker.msg.capitalized)
                    }
                }
                if tracker.status == 2 {
                    Group {
                        Text("•")
                        Image(systemName: "square.and.arrow.up")
                        Text("\(tracker.num_seeds)")
                        Text("•")
                    }
                    Group {
                        Image(systemName: "arrow.up.and.down")
                        Text("\(tracker.num_leeches)")
                        Text("•")
                    }
                    Group {
                        Image(systemName: "person.2")
                        Text("\(tracker.num_peers)")
                    }
                }
                Spacer()
            }.foregroundColor(Color.gray)
                .lineLimit(1)
                .font(.footnote)
        }
    }
}

struct TorrentDetailsTrackerRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TorrentDetailsTrackerRow(tracker: .constant(Tracker(url: "http://example.com/announce", status: 1, tier: 1, num_peers: 100, num_seeds: 100, num_leeches: 10, num_downloaded: 1000, msg: "Tracker available")))
        }
    }
}
