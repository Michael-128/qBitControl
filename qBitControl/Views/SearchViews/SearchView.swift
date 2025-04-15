import SwiftUI

struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    
    var body: some View {
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
        }
    }
}
