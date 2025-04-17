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
                        
                        Button {
                            viewModel.startSearch()
                        } label: {
                            if viewModel.isRunning {
                                Text("Running...")
                                    .foregroundStyle(.gray)
                            } else {
                                Text("Start")
                            }
                        }
                    }
                }
                
                if viewModel.isResponse {
                    Section(header: Text("\(viewModel.lastestTotal)" + " " + "results")) {
                        ForEach(viewModel.latestResults, id: \.hashValue) { result in
                            SearchRowView(result: result)
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
        }
    }
}
