//
//  ConnectionBannerView.swift
//  qBitControl
//

import SwiftUI

struct ConnectionBannerView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.footnote)
            
            Text("Offline. Check your connection.")
                .font(.footnote)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(Color.blue)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        )
        .padding(.bottom, 12)
    }
}
