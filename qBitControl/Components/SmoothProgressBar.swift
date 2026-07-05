import SwiftUI

struct SmoothProgressBar: View {
    let progress: Double  // 0.0 ... 1.0
    let dlSpeed: Int64
    let totalSize: Int64
    let state: String
    
    @State private var animate = false
    
    private var formatter: TorrentFormatting = TorrentFormatter()
    
    init(progress: Double, dlSpeed: Int64, totalSize: Int64, state: String) {
        self.progress = progress
        self.dlSpeed = dlSpeed
        self.totalSize = totalSize
        self.state = state
    }
    
    private var stateColor: Color {
        formatter.getStateColor(state: state)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track background
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(uiColor: .systemGray5))
                
                // Fill bar
                stateColor
                    .mask(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .frame(width: geo.size.width * CGFloat(progress))
                            .animation(animate ? .linear(duration: 2.0) : nil, value: progress)
                    }
            }
        }
        .frame(height: 4)
        .onAppear {
            // Enable animations after the initial layout pass
            DispatchQueue.main.async {
                animate = true
            }
        }
    }
}
