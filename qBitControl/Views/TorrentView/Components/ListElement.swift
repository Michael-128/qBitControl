//

import SwiftUI

struct ListElement: View {
    public var label: LocalizedStringKey
    public var value: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var buttonTextColor = Color.white
    
    var body: some View {
        Button(action: {UIPasteboard.general.string = "\(value)"}) {
            HStack {
                Text(label)
                Spacer()
                Text("\(value)")
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
            }
        }.foregroundColor(buttonTextColor)
            .onAppear {
                switch(colorScheme) {
                case .dark:
                    buttonTextColor = Color.white
                case .light:
                    buttonTextColor = Color.black
                }
            }
            .onChange(of: colorScheme) {
                colorScheme in
                
                switch(colorScheme) {
                case .dark:
                    buttonTextColor = Color.white
                case .light:
                    buttonTextColor = Color.black
                }
            }
    }
}
