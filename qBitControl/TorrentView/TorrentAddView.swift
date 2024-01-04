//
//  TorrentAddView.swift
//  qBitControl
//

import SwiftUI

enum TorrentType {
    case magnet, file
}

struct TorrentAddView: View {
    @State private var torrentType: TorrentType = .file
    @Binding var isPresented: Bool
    
    @Binding public var openedMagnetURL: String?
    @Binding public var openedFileURL: [URL]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Picker("Task Type", selection: $torrentType) {
                        Text("File").tag(TorrentType.file)
                        Text("URL").tag(TorrentType.magnet)
                    }
                    .padding(.horizontal, 40.0)
                    .padding(.vertical, 0)
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                }
                
                
                
                if torrentType == .magnet {
                    TorrentAddMagnetView(openedMagnetURL: $openedMagnetURL, isPresented: $isPresented)
                } else {
                    TorrentAddFileView(isPresented: $isPresented, openedFileURL: $openedFileURL)
                }
            }.onAppear() {
                if (openedMagnetURL != nil) {
                    torrentType = .magnet
                }
            }.toolbar() {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        openedMagnetURL = nil
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
