import SwiftUI

struct ChangePathView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var path: String
    let torrentHash: String
    
    func setPath() {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/setLocation", queryItems: [
            URLQueryItem(name: "hashes", value: torrentHash),
            URLQueryItem(name: "location", value: path)
        ])
        
        qBitRequest.requestTorrentManagement(request: request, statusCode: {
            code in
            print("Code: \(code ?? -1)")
        })
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
