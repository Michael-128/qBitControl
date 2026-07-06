//
//  TorrentAddViewModel.swift
//  qBitControl
//

import SwiftUI

enum TorrentType {
    case magnet, file
}

@MainActor
class TorrentAddViewModel: ObservableObject {
    static let defaultCategory = Category(name: "Uncategorized", savePath: "")
    static let defaultTag = "Untagged"

    @Published var torrentType: TorrentType = .file
    public var torrentUrls: [URL]
    private let client: TorrentClientProtocol
    
    @Published var magnetURL: String = ""
    
    @Published var fileURLs: [URL] = []
    @Published var fileNames: [String] = []
    @Published var fileContent: [String: Data] = [:]
    
    var magnetOverride: Bool
    
    @Published var isFileImporter = false
    
    @Published var savePath = ""
    @Published var defaultSavePath = ""
    @Published var autoTmmEnabled = false
    
    @Published var cookie = ""
    @Published var category: Category = defaultCategory
    
    var tags: [String] { Array(selectedTags).sorted(by: <) }
    var tagsString: String { tags.joined(separator: ",") }
    @Published var selectedTags: Set<String> = Set()
    
    @Published var skipChecking = false
    @Published var paused = false
    @Published var sequentialDownload = false
    
    @Published var showAdvancedOptions = false
    
    @Published var showLimits = false
    @Published var downloadLimit = ""
    @Published var uploadLimit = ""
    @Published var ratioLimit = ""
    @Published var seedingTimeLimit = ""
    
    @Published var isAppeared = false
    
    init(torrentUrls: [URL], magnetOverride: Bool = false, client: TorrentClientProtocol) {
        self.torrentUrls = torrentUrls
        self.magnetOverride = magnetOverride
        self.client = client
    }
    
    func getTag() -> String { tags.count > 1 ? "\(tags.count)" + " Tags" : (tags.first ?? "Untagged") }
    
    func checkTorrentType() -> Void {
        if torrentUrls.isEmpty { return }
        
        if torrentUrls.first!.absoluteString.contains("magnet") || magnetOverride {
            self.torrentType = .magnet
            self.magnetURL = self.torrentUrls.first!.absoluteString
        } else {
            self.torrentType = .file
            self.fileURLs = self.torrentUrls
            self.handleTorrentFiles(fileURLs: self.fileURLs)
        }
    }
    
    func handleTorrentFile(fileURL: URL) -> Void {
        let isRemote = fileURL.scheme == "https" || fileURL.scheme == "http"
        
        if fileURL.pathExtension != "torrent" && !isRemote { return }
        
        let fileName = fileURL.lastPathComponent
        
        self.fileNames.append(fileName)
        
        if isRemote {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: fileURL)
                    self.fileContent[fileName] = data
                } catch {
                    print(error)
                }
            }
        } else {
            if fileURL.startAccessingSecurityScopedResource() {
                Task {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        self.fileContent[fileName] = data
                    } catch {
                        print(error)
                    }
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }
        }
    }
    
    func handleTorrentFiles(fileURLs: [URL]) {
        for fileURL in fileURLs {
            handleTorrentFile(fileURL: fileURL)
        }
    }
    
    func handleTorrentFiles(fileURLs: Result<[URL], any Error>) {
        do {
            handleTorrentFiles(fileURLs: try fileURLs.get())
        } catch {
            print(error)
        }
    }
    
    func addTorrent(then dismiss: () -> Void) {
        let category = self.category == Self.defaultCategory ? "" : self.category.name
        
        Task {
            do {
                if self.torrentType == .magnet {
                    try await client.addMagnetTorrent(
                        torrent: URLQueryItem(name: "urls", value: self.magnetURL),
                        savePath: self.savePath,
                        cookie: self.cookie,
                        category: category,
                        tags: self.tagsString,
                        skipChecking: self.skipChecking,
                        paused: self.paused,
                        sequentialDownload: self.sequentialDownload,
                        dlLimit: Int(self.downloadLimit) ?? -1,
                        upLimit: Int(self.uploadLimit) ?? -1,
                        ratioLimit: Float(self.ratioLimit) ?? -1.0,
                        seedingTimeLimit: Int(self.seedingTimeLimit) ?? -1
                    )
                } else {
                    try await client.addFileTorrent(
                        torrents: self.fileContent,
                        savePath: self.savePath,
                        cookie: self.cookie,
                        category: category,
                        tags: self.tagsString,
                        skipChecking: self.skipChecking,
                        paused: self.paused,
                        sequentialDownload: self.sequentialDownload,
                        dlLimit: Int(self.downloadLimit) ?? -1,
                        upLimit: Int(self.uploadLimit) ?? -1,
                        ratioLimit: Float(self.ratioLimit) ?? -1.0,
                        seedingTimeLimit: Int(self.seedingTimeLimit) ?? -1
                    )
                }
            } catch {
                print("Failed to add torrent: \(error)")
            }
        }
        dismiss()
    }
    
    func getSavePath() {
        if(!self.savePath.isEmpty) { return }
        
        Task {
            do {
                let preferences = try await client.getPreferences()
                self.autoTmmEnabled = preferences.auto_tmm_enabled ?? false
                if !self.autoTmmEnabled {
                    self.savePath = preferences.save_path ?? ""
                    self.defaultSavePath = preferences.save_path ?? ""
                }
            } catch {
                print("Failed to get preferences for save path: \(error)")
            }
        }
    }
}
