import SwiftUI

enum TorrentType {
    case magnet, file
}

class TorrentAddViewModel: ObservableObject {
    static let defaultCategory = Category(name: "None", savePath: "")

    @Published var torrentType: TorrentType = .file
    public var torrentUrls: [URL]
    
    @Published var magnetURL: String = ""
    
    @Published var fileURLs: [URL] = []
    @Published var fileNames: [String] = []
    @Published var fileContent: [String: Data] = [:]
    
    @Published var isFileImporter = false
    
    @Published var savePath = ""
    @Published var defaultSavePath = ""
    @Published var autoTmmEnabled = false
    
    @Published var cookie = ""
    @Published var category: Category = defaultCategory
    @Published var tags = ""
    
    @Published var skipChecking = false
    @Published var paused = false
    @Published var sequentialDownload = false
    
    @Published var showAdvancedOptions = false
    
    @Published var showLimits = false
    @Published var downloadLimit = ""
    @Published var uploadLimit = ""
    @Published var ratioLimit = ""
    @Published var seedingTimeLimit = ""
    
    @Published var categories: [Category] = [defaultCategory]
    @Published var tagsArr: [String] = ["None"]
    
    init(torrentUrls: [URL]) {
        self.torrentUrls = torrentUrls
    }
    
    func checkTorrentType() -> Void {
        if torrentUrls.isEmpty { return }
        
        if torrentUrls.first!.absoluteString.contains("magnet") {
            DispatchQueue.main.async {
                self.torrentType = .magnet
                self.magnetURL = self.torrentUrls.first!.absoluteString
            }
        } else {
            DispatchQueue.main.async {
                self.torrentType = .file
                self.fileURLs = self.torrentUrls
                
                self.handleTorrentFiles(fileURLs: self.fileURLs)
            }
        }
    }
    
    func handleTorrentFile(fileURL: URL) -> Void {
        let isRemote = fileURL.scheme == "https" || fileURL.scheme == "http"
        
        if fileURL.pathExtension != "torrent" && !isRemote { return }
        
        let fileName = fileURL.lastPathComponent
        
        DispatchQueue.main.async {
            self.fileNames.append(fileName)
        }
        
        if fileURL.startAccessingSecurityScopedResource() || isRemote {
            Task {
                do {
                    let data = try Data(contentsOf: fileURL)
                    DispatchQueue.main.async {
                        self.fileContent[fileName] = data
                    }
                } catch {
                    print(error)
                }
                fileURL.stopAccessingSecurityScopedResource()
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
        DispatchQueue.main.async {
            if self.torrentType == .magnet {
                qBittorrent.addMagnetTorrent(torrent: URLQueryItem(name: "urls", value: self.magnetURL), savePath: self.savePath, cookie: self.cookie, category: self.category.name, tags: self.tags, skipChecking: self.skipChecking, paused: self.paused, sequentialDownload: self.sequentialDownload, dlLimit: Int(self.downloadLimit) ?? -1, upLimit: Int(self.uploadLimit) ?? -1, ratioLimit: Float(self.ratioLimit) ?? -1.0, seedingTimeLimit: Int(self.seedingTimeLimit) ?? -1)
            } else {
                qBittorrent.addFileTorrent(torrents: self.fileContent, savePath: self.savePath, cookie: self.cookie, category: self.category.name, tags: self.tags, skipChecking: self.skipChecking, paused: self.paused, sequentialDownload: self.sequentialDownload, dlLimit: Int(self.downloadLimit) ?? -1, upLimit: Int(self.uploadLimit) ?? -1, ratioLimit: Float(self.ratioLimit) ?? -1.0, seedingTimeLimit: Int(self.seedingTimeLimit) ?? -1)
            }
        }
        dismiss()
    }
    
    func getSavePath() {
        qBittorrent.getPreferences(completionHandler: { preferences in
            DispatchQueue.main.async {
                self.autoTmmEnabled = preferences.auto_tmm_enabled ?? false
                
                if !self.autoTmmEnabled {
                    self.savePath = preferences.save_path ?? ""
                    self.defaultSavePath = preferences.save_path ?? ""
                }
            }
        })
    }
    
    func getCategories() {
        qBittorrent.getCategories(completionHandler: { response in
            DispatchQueue.main.async {
                // Append sorted list of Category objects to ensure "None" always appears at the top
                self.categories = response.map { $1 }.sorted { $0.name < $1.name }
            }
        })
    }
    
    func getTags() {
        qBittorrent.getTags(completionHandler: { tags in
            DispatchQueue.main.async {
                self.tagsArr.append(contentsOf: tags)
            }
        })
    }
}
