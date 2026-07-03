import SwiftUI

struct ChangePathView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var path: String
    let torrentHash: String
    
    private var client: TorrentClientProtocol {
        ServersHelper.shared.client ?? MockTorrentClient()
    }
    
    func setPath() {
        Task {
            do {
                try await client.setLocation(hashes: [torrentHash], location: path)
            } catch {
                print("Failed to set location: \(error)")
            }
        }
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Save Path", text: $path, axis: .vertical)
                    .lineLimit(1...5)
            }
            
            Section {
                Button {
                    setPath()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Update")
                }
            }
        }.navigationTitle("Save Path")
    }
}
