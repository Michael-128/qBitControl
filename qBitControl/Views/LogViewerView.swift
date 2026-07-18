//
//  LogViewerView.swift
//  qBitControl
//

import SwiftUI

struct LogViewerView: View {
    @State private var logContent: String = ""
    @State private var filterQuery: String = ""
    @State private var selectedLevel: LogLevelFilter = .all
    @State private var exportItem: LogExportItem? = nil
    
    enum LogLevelFilter: String, CaseIterable {
        case all = "ALL"
        case debug = "DEBUG"
        case info = "INFO"
        case warn = "WARN"
        case error = "ERROR"
    }
    
    var filteredLogLines: [String] {
        let lines = logContent.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return lines.filter { line in
            let matchesFilter = selectedLevel == .all || line.contains("[\(selectedLevel.rawValue)]")
            let matchesSearch = filterQuery.isEmpty || line.localizedCaseInsensitiveContains(filterQuery)
            return matchesFilter && matchesSearch
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Level", selection: $selectedLevel) {
                    ForEach(LogLevelFilter.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if filteredLogLines.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No logs found matching criteria.")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 6) {
                            ForEach(filteredLogLines.indices, id: \.self) { index in
                                let line = filteredLogLines[index]
                                Text(line)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(colorForLine(line))
                                    .padding(.horizontal, 12)
                                    .textSelection(.enabled)
                            }
                        }
                        .padding(.vertical, 8)
                    }
            }
        }
        .navigationTitle("Application Logs")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $filterQuery, prompt: "Search logs...")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            Task {
                                await LogStore.shared.clearAllLogs()
                                await refreshLogs()
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                        
                        Button {
                            Task {
                                if let url = await LogStore.shared.exportCombinedLogsURL() {
                                    self.exportItem = LogExportItem(url: url)
                                }
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .task {
                await refreshLogs()
            }
            .sheet(item: $exportItem) { item in
                ActivityViewController(activityItems: [item.url])
            }
        }
    }
    
    private func refreshLogs() async {
        let content = await LogStore.shared.loadAllLogs()
        await MainActor.run {
            self.logContent = content
        }
    }
    
    private func colorForLine(_ line: String) -> Color {
        if line.contains("[ERROR]") {
            return .red
        } else if line.contains("[WARN]") {
            return .orange
        } else if line.contains("[DEBUG]") {
            return .gray
        } else {
            return .primary
        }
    }
}

struct LogExportItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
