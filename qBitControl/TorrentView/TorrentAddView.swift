//
//  TorrentAddView.swift
//  TorrentAttempt
//
//  Created by Michał Grzegoszczyk on 27/10/2022.
//

import SwiftUI

struct TorrentAddView: View {
    @State private var isMagnet = true
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Picker("Torrent Type", selection: $isMagnet) {
                        Text("Magnet").tag(true)
                        Text("File").tag(false)
                    }
                    .padding(.horizontal, 40.0)
                    .padding(.vertical, 0)
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                }
                
                
                
                if isMagnet {
                    TorrentAddMagnetView(isPresented: $isPresented)
                } else {
                    TorrentAddFileView(isPresented: $isPresented)
                }
            }
            .toolbar() {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

/*struct TorrentAddView_Previews: PreviewProvider {
    static var previews: some View {
        TorrentAddView()
    }
}*/
