//

import SwiftUI

struct CustomLabelView: View {
    public var label: LocalizedStringKey
    public var value: String
    
    var body: some View {
        Button(action: {UIPasteboard.general.string = "\(value)"}) {
            HStack {
                Text(label)
                Spacer()
                Text(NSLocalizedString(value, comment: ""))
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
            }
        }.foregroundColor(.primary)
    }
}
