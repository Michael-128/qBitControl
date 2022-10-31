//
//  TorrentDetailsListElementView.swift
//  TorrentAttempt
//
//  Created by Michał Grzegoszczyk on 26/10/2022.
//

import SwiftUI

struct ListElementView: View {
    @Binding var label: String
    @Binding var value: String
    
    var body: some View {
        HStack {
            Text("\(label)")
            Spacer()
            Text("\(value)")
                .foregroundColor(Color.gray)
                .lineLimit(1)
        }
    }
}


struct TorrentDetailsListElementPreview: PreviewProvider {
    static var previews: some View {
        ListElementView(label: .constant("Label"), value: .constant("Value"))
    }
}
