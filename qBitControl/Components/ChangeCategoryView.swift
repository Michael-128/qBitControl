import SwiftUI

struct ChangeCategoryView: View {
    
    @State var torrentHash: String
    
    @State private var categories: [Category] = []

    @State var category: String

    
    var body: some View {
        VStack {
            Form {
                if categories.count > 1 {
                    Picker("Categories", selection: $category) {
                        Text("None").tag("")
                        ForEach(categories, id: \.self) { category in
                            Text(category.name).tag(category.name)
                        }
                    }.pickerStyle(.inline)
                }
                
                /*Button {
                    // link to management view
                } label: {
                    Text("Manage Categories")
                        .frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                    .listRowBackground(Color.blue)*/
            }
            .navigationTitle("Categories")
        }.onAppear() {
            qBittorrent.getCategories(completionHandler: { response in
                // Append sorted list of Category objects to ensure "None" always appears at the top
                self.categories.append(contentsOf: response.map { $1 }.sorted { $0.name < $1.name })
            })
        }.onChange(of: category) {
            category in
            let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/setCategory", queryItems: [
                URLQueryItem(name: "hashes", value: torrentHash),
                URLQueryItem(name: "category", value: category)
            ])
            
            qBitRequest.requestTorrentManagement(request: request, statusCode: {
                code in
            })
        }
    }
}
