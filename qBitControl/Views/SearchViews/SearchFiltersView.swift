import SwiftUI

struct SearchFiltersView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Descending")) {
                    Toggle(isOn: $viewModel.isDescending, label: { Text("Descending") })
                        .onChange(of: viewModel.isDescending) { _ in
                            viewModel.saveFilters()
                        }
                }
                
                Picker("Sort By", selection: $viewModel.sortBy) {
                    ForEach(SearchSortOptions.allCases, id: \.self) { option in
                       Text(LocalizedStringResource(stringLiteral: option.rawValue.capitalized)).tag(option)
                   }
                }.pickerStyle(.inline)
                    .onChange(of: viewModel.sortBy) { _ in
                        viewModel.saveFilters()
                    }
            }.toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}
