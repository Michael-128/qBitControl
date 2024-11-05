//
//  RSSView.swift
//  qBitControl
//

import SwiftUI

struct RSSView: View {
    
    @State private var RSSFeeds: [RSS] = []
    @State private var isLoaded = false
    
    func getRSSFeed() {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/rss/items", queryItems: [URLQueryItem(name: "withData", value: "true")])
        
        qBitRequest.requestRSSFeedJSON(request: request, completion: {
            RSSFeeds in
            self.RSSFeeds = []
            for (_, feed) in RSSFeeds.sorted(by: { $0.key < $1.key }) {
                self.RSSFeeds.append(feed)
            }
            
            isLoaded = true
        })
    }
    
    var body: some View {
        VStack {
            NavigationView {
                if isLoaded {

                    List {
                        Section(header: Text("\(RSSFeeds.count) Feeds")/*, footer: Text("Folders are not supported! Feeds that are nested inside of folders will not be visible.")*/) {
                            ForEach(RSSFeeds, id: \.uid) {
                                feed in
                                
                                NavigationLink {
                                    RSSFeedArticlesView(feedTitle: feed.title, articles: feed.articles)
                                } label: {
                                    Text("\(feed.title)")
                                }
                            }
                        }
                    }
                    
                    .navigationTitle("Feeds")
                } else {
                    ProgressView().progressViewStyle(.circular)
                        .navigationTitle("Feeds")
                }
            }
        }.onAppear() {
            getRSSFeed()
        }
    }
}

struct RSSView_Previews: PreviewProvider {
    static var previews: some View {
        RSSView()
    }
}
