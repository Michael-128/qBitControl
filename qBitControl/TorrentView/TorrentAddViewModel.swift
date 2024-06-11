import SwiftUI

enum TorrentType {
    case magnet, file
}

class TorrentAddViewModel: ObservableObject {
    @Published var torrentType: TorrentType = .file
    public var torrentUrls: [URL]
    
    @Published var magnetURL: String = ""
    
    @Published var fileURLs: [URL] = []
    @Published var fileNames: [String] = []
    @Published var fileContent: [String: Data] = [:]
    
    @Published var isFileImporter = false
    
    @Published var savePath = ""
    @Published var defaultSavePath = ""
    
    @Published var cookie = ""
    @Published var category = ""
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
    
    @Published var categoriesArr = ["None"]
    @Published var categoriesPaths = ["None": ""]
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
        if fileURL.pathExtension != "torrent" { return }
        
        let fileName = fileURL.lastPathComponent
        
        DispatchQueue.main.async {
            self.fileNames.append(fileName)
        }
        
        if fileURL.startAccessingSecurityScopedResource() {
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
                qBittorrent.addMagnetTorrent(torrent: URLQueryItem(name: "urls", value: self.magnetURL), savePath: self.savePath, cookie: self.cookie, category: self.category, tags: self.tags, skipChecking: self.skipChecking, paused: self.paused, sequentialDownload: self.sequentialDownload, dlLimit: Int(self.downloadLimit) ?? -1, upLimit: Int(self.uploadLimit) ?? -1, ratioLimit: Float(self.ratioLimit) ?? -1.0, seedingTimeLimit: Int(self.seedingTimeLimit) ?? -1)
            } else {
                qBittorrent.addFileTorrent(torrents: self.fileContent, savePath: self.savePath, cookie: self.cookie, category: self.category, tags: self.tags, skipChecking: self.skipChecking, paused: self.paused, sequentialDownload: self.sequentialDownload, dlLimit: Int(self.downloadLimit) ?? -1, upLimit: Int(self.uploadLimit) ?? -1, ratioLimit: Float(self.ratioLimit) ?? -1.0, seedingTimeLimit: Int(self.seedingTimeLimit) ?? -1)
            }
        }
        dismiss()
    }
    
    func getSavePath() {
        qBittorrent.getPreferences(completionHandler: { preferences in
            DispatchQueue.main.async {
                self.savePath = preferences.save_path ?? ""
                self.defaultSavePath = preferences.save_path ?? ""
            }
        })
    }
    
    func getCategories() {
        qBittorrent.getCategories(completionHandler: { categories in
            DispatchQueue.main.async {
                for (key, value) in categories {
                    self.categoriesArr.append(key)
                    self.categoriesPaths[key] = value["savePath"] ?? ""
                }
                
                if self.category != "None", let savePath = self.categoriesPaths[self.category], !savePath.isEmpty {
                    self.savePath = savePath
                }
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
