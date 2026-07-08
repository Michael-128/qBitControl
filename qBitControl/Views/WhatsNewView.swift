//
//  WhatsNewView.swift
//  qBitControl
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Header
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 8)
                
                Text("What's New in qBitControl")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("Version 1.4.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Features list
            VStack(alignment: .leading, spacing: 24) {
                FeatureRowView(
                    imageName: "arrow.up.arrow.down",
                    imageColor: .blue,
                    title: "93% Less Data Usage",
                    description: "Network traffic is dramatically reduced due to optimized delta syncing."
                )
                
                FeatureRowView(
                    imageName: "chart.line.uptrend.xyaxis",
                    imageColor: .green,
                    title: "Fluid UI & Continuous Charts",
                    description: "Statistics charts & progress indicators now feature fluid animations."
                )
                
                FeatureRowView(
                    imageName: "doc.text.magnifyingglass",
                    imageColor: .orange,
                    title: "In-App Log Viewer",
                    description: "Inspect, search, and export diagnostic logs securely. Sensitive credentials and passwords are automatically redacted."
                )
            }
            .padding(.horizontal, 28)
            
            Spacer()
            
            // Actions
            VStack(spacing: 12) {
                Link(destination: URL(string: "https://patreon.com/michael128")!) {
                    Text("Check Release Notes")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.12))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

private struct FeatureRowView: View {
    let imageName: String
    let imageColor: Color
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: imageName)
                .font(.system(size: 28))
                .foregroundColor(imageColor)
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    WhatsNewView()
}
