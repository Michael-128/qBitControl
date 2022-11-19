//
//  RSSFeedArticlesView.swift
//  qBitControl
//
//  Created by Michał Grzegoszczyk on 08/11/2022.
//

import SwiftUI

struct RSSFeedArticlesView: View {
    
    @State var feedTitle: String
    @State var articles: [Article]
    
    var body: some View {
        List {
            ForEach(articles, id: \.id) {
                article in
                RSSFeedArticleRowView(article: article)
            }
        }
        .navigationTitle(feedTitle)
    }
}

/*struct RSSFeedArticlesView_Previews: PreviewProvider {
    static var previews: some View {
        //RSSFeedArticlesView()
    }
}*/
