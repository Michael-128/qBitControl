//
//  RSSFeedArticleRowView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 08/11/2022.
//

import SwiftUI

struct RSSFeedArticleRowView: View {
    
    @State var article: Article
    @State private var isDownloadSheet = false
    
    var body: some View {
        VStack {
            Button {
                isDownloadSheet.toggle()
            } label: {
                HStack {
                    Text(article.title)
                    Spacer()
                }
                HStack(spacing: 3) {
                    Text(article.category)
                    Text("•")
                    Text(article.size)
                    Text("•")
                    Text("\(article.date.formatted(.dateTime.day(.defaultDigits).month(.abbreviated).year(.twoDigits).hour().minute()))")
                    Spacer()
                }.foregroundColor(Color.gray)
                    .font(.footnote)
                    .lineLimit(1)
            }.foregroundColor(Color.primary)
        }.sheet(isPresented: $isDownloadSheet, content: {
            NavigationView {
                VStack {
                    List {
                        TorrentAddMagnetView(urls: article.torrentURL, isPresented: $isDownloadSheet)
                    }
                    .navigationTitle("Link")
                }.toolbar() {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            isDownloadSheet = false
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
            }
        })
    }
}

/*struct RSSFeedArticleRowView_Previews: PreviewProvider {
    static var previews: some View {
        RSSFeedArticleRowView(article: Article(category: "test", id: "2222", torrentURL: "htttps", title: "testtitle", date: Date.now, link: "linklink", size: "222222"))
    }
}*/
