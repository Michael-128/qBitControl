//
//  RSSFeedArticleRowView.swift
//  qBitControl
//

import SwiftUI

struct RSSFeedArticleRowView: View {
    
    @State var article: Article
    //@State var isRead = false
    @State private var isDownloadSheet = false
    
    func articleAddView() -> some View {
        NavigationView {
            VStack {
                List {
                    TorrentAddMagnetView(urls: article.torrentURL, openedMagnetURL: .constant(nil), isPresented: $isDownloadSheet)
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
    }
    
    var body: some View {
        VStack {
            Button {
                isDownloadSheet.toggle()
            } label: {
                HStack {
                    Text(article.title)
                    /*if !(article.isRead ?? false) {
                        Text("•")
                            .foregroundColor(.blue)
                            .font(.title)
                    }*/
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
            articleAddView()
        }).contextMenu() {
            Button {
                if let url = URL(string: article.link) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open")
                Image(systemName: "globe")
            }
            
            Button {
                isDownloadSheet = true
            } label: {
                Text("Download")
                Image(systemName: "arrow.down")
            }
        }
    }
}

/*struct RSSFeedArticleRowView_Previews: PreviewProvider {
    static var previews: some View {
        RSSFeedArticleRowView(article: Article(category: "test", id: "2222", torrentURL: "htttps", title: "testtitle", date: Date.now, link: "linklink", size: "222222"))
    }
}*/
