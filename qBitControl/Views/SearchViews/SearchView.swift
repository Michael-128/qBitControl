import SwiftUI

struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    
    var body: some View {
        ZStack {
            List {
                Section(header: Text("Search")) {
                    HStack {
                        TextField("Search", text: $viewModel.query)
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .keyboardType(.default)
                        
                        if !viewModel.isRunning {
                            Button {
                                viewModel.startSearch()
                            } label: {
                                Text("Start")
                            }
                        } else {
                            Button {
                                viewModel.endSearch()
                            } label: {
                                Text("Stop")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    
                    Picker("Category", selection: $viewModel.category) {
                        ForEach(self.viewModel.categoriesArray, id: \.self) { category in
                            Text(LocalizedStringKey(category.name)).tag(category)
                        }
                    }
                }
                
                if viewModel.isResponse {
                    Section(header: Text("\(viewModel.lastestTotal)") + Text(" ") + Text("results")) {
                        ForEach(viewModel.latestResults, id: \.id) { result in
                            SearchRowView(result: result, onTap: self.viewModel.onRowTap)
                        }
                    }
                }
            }
            
            if !viewModel.isResponse {
                VStack {
                    Text("No results")
                }.foregroundStyle(.gray)
            }
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.viewModel.isFilterSheet.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }.sheet(isPresented: $viewModel.isFilterSheet) {
            SearchFiltersView(viewModel: viewModel)
        }.sheet(isPresented: $viewModel.isTorrentAddSheet) { if let url = URL(string: self.viewModel.tappedResult?.fileUrl ?? "") { TorrentAddView(torrentUrls: .constant([url]), magnetOverride: true) } }
    }
}
