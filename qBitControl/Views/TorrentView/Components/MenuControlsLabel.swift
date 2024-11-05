//

import SwiftUI

struct MenuControlsLabel: View {
    let text: LocalizedStringKey
    let icon: String
    
    var body: some View {
        HStack {
            Text(text)
            Image(systemName: icon)
        }
    }
}
