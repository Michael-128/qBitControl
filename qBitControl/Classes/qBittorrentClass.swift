//
//  qBittorrentClass.swift
//  qBitControl
//

import Foundation
import SwiftUI


class qBittorrent {
    static private var cookie = "n/a"
    static private var url = "http://0.0.0.0"
    static private var preferences: qBitPreferences?
    static private var version: Version = Version(major: 0, minor: 0, patch: 0)
    static private var networkManager: NetworkManager = .init()
    
    static func initialize() {
        self.fetchVersion()
    }
    
    static func savePreferences() {
        if(!isCookie()) { return; }
        
        getPreferences(completionHandler: {
            result in
            switch(result) {
            case .success(let preferences):
                self.preferences = preferences;
            case .failure(let networkError):
                print(networkError)
            }
        })
    }
    
    static func getSavedPreferences() -> qBitPreferences? {
        return preferences;
    }
    
    static func setURL(url: String) {
        self.url = url
    }
    
    static func getURL() -> String {
        return url
    }
    
    static func setCookie(cookie: String) -> Void {
        self.cookie = cookie
        savePreferences();
    }
    
    static func getCookie() -> String {
        return cookie
    }
    
    static func isCookie() -> Bool {
        if(cookie != "n/a") {
            return true
        }
        
        return false
    }
    
    static private func setVersion(version: Version) {
        self.version = version
    }
    
    static func fetchVersion() {
        let path = "/api/v2/app/version"
        
        let request = qBitRequest.prepareURLRequest(path: path)
        
        qBitRequest.requestVersion(request: request, completionHandler: { version in
            Self.setVersion(version: version)
        })
    }
    
    static func getVersion() -> Version {
        return self.version
    }
 
    static func getState(state: String) -> String {
        switch state {
        case "error":
            return "Error"
        case "missingFiles":
            return "Missing Files"
        case "uploading":
            return "Seeding"
        case "pausedUP", "stoppedUP":
            return "Paused"
        case "queuedUP":
            return "Queued"
        case "stalledUP":
            return "Seeding"
        case "checkingUP":
            return "Checking"
        case "forcedUP":
            return "Forced Seeding"
        case "allocating":
            return "Allocating space"
        case "downloading":
            return "Downloading"
        case "metaDL":
            return "Downloading"
        case "pausedDL", "stoppedDL":
            return "Paused"
        case "queuedDL":
            return "Queued"
        case "stalledDL":
            return "Downloading"
        case "checkingDL":
            return "Checking"
        case "forcedDL":
            return "Forced Download"
        case "checkingResumeData":
            return "Resuming"
        case "moving":
            return "Moving"
        default:
            return "Unknown State"
        }
    }
    
    static func getStateIcon(state: String) -> String {
        
        let errorIcon = "multiply.circle"
        let downloadIcon = "arrow.down.circle"
        let uploadIcon = "arrow.up.circle"
        let checkingIcon = "gearshape.circle"
        let pauseIcon = "pause.circle"
        let metadataDownloadIcon = "info.circle"
        let movingIcon = "folder.circle"
        let queuedIcon = "clock"
        
        switch state {
        case "error":
            return errorIcon
        case "missingFiles":
            return errorIcon
        case "uploading":
            return uploadIcon
        case "pausedUP", "stoppedUP":
            return pauseIcon
        case "queuedUP":
            return queuedIcon
        case "stalledUP":
            return uploadIcon
        case "checkingUP":
            return checkingIcon
        case "forcedUP":
            return uploadIcon
        case "allocating":
            return checkingIcon
        case "downloading":
            return downloadIcon
        case "metaDL":
            return metadataDownloadIcon
        case "pausedDL", "stoppedDL":
            return pauseIcon
        case "queuedDL":
            return queuedIcon
        case "stalledDL":
            return downloadIcon
        case "checkingDL":
            return checkingIcon
        case "forcedDL":
            return downloadIcon
        case "checkingResumeData":
            return checkingIcon
        case "moving":
            return movingIcon
        default:
            return errorIcon
        }

    }
    
    static func getStateColor(state: String) -> Color {
        
        let errorColor = Color.red
        let pausedColor = Color.yellow
        let seedingColor = Color.blue
        let downloadingColor = Color.green
        let checkingColor = pausedColor
        let movingColor = pausedColor
        
        switch state {
        case "error":
            return errorColor
        case "missingFiles":
            return errorColor
        case "uploading":
            return seedingColor
        case "pausedUP", "stoppedUP":
            return pausedColor
        case "queuedUP":
            return pausedColor
        case "stalledUP":
            return seedingColor
        case "checkingUP":
            return checkingColor
        case "forcedUP":
            return seedingColor
        case "allocating":
            return checkingColor
        case "downloading":
            return downloadingColor
        case "metaDL":
            return downloadingColor
        case "pausedDL", "stoppedDL":
            return pausedColor
        case "queuedDL":
            return pausedColor
        case "stalledDL":
            return downloadingColor
        case "checkingDL":
            return checkingColor
        case "forcedDL":
            return downloadingColor
        case "checkingResumeData":
            return checkingColor
        case "moving":
            return movingColor
        default:
            return errorColor
        }

    }
    
    static func getFormatedSize(size: Int64) -> String {
        let formater = ByteCountFormatter()
        formater.isAdaptive = true
        formater.countStyle = ByteCountFormatter.CountStyle.binary
        return formater.string(fromByteCount: size)
    }
    
    static func getFormatedSize(size: Int) -> String {
        let formater = ByteCountFormatter()
        formater.isAdaptive = true
        formater.countStyle = ByteCountFormatter.CountStyle.binary
        return formater.string(fromByteCount: Int64(size))
    }
    
    static func getFormatedDate(date: Int) -> String {
        let fullDate = Date(timeIntervalSince1970: TimeInterval(date))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: fullDate)
    }
    
    static func getFormattedTime(time: Int) -> String {
        let days = time / (24 * 60 * 60)
        let hours = (time / (60 * 60)) % 24
        let minutes = (time / 60) % 60
        let seconds = time % 60
        
        var components: [String] = []
        
        if days > 0 {
           components.append("\(days)d")
           components.append("\(hours)h")
       } else if hours > 0 {
           components.append("\(hours)h")
           components.append("\(minutes)m")
       } else if minutes > 0 {
           components.append("\(minutes)m")
           components.append("\(seconds)s")
       } else {
           components.append("\(seconds)s")
       }
       
       return components.joined(separator: " ")
    }

    
    static func getGlobalTransferInfo(completionHandler: @escaping (Result<GlobalTransferInfo, NetworkError>) -> Void) {
        networkManager.performDataRequest(path: "/api/v2/transfer/info", decodingType: GlobalTransferInfo.self, completion: completionHandler)
    }
    
    static func getMainData(rid: Int = 0, completionHandler: @escaping (Result<MainData, NetworkError>) -> Void) {
        networkManager.performDataRequest(path: "/api/v2/sync/maindata", queryItems: [URLQueryItem(name: "rid", value: "\(rid)")], decodingType: MainData.self, completion: completionHandler)
    }
    
    static func getPreferences(completionHandler: @escaping (Result<qBitPreferences, NetworkError>) -> Void) {
        networkManager.performDataRequest(path: "/api/v2/app/preferences", decodingType: qBitPreferences.self, completion: completionHandler)
    }
    
    static func getSearchStart(pattern: String, category: String, plugins: Bool = true, completionHandler: @escaping (SearchStartResult) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/search/start", queryItems: [
            URLQueryItem(name: "pattern", value: pattern),
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "plugins", value: plugins ? "enabled" : "disabled")
        ])
        
        qBitRequest.requestSearchStart(request: request, completionHandler: completionHandler)
    }
    
    static func getSearchResults(id: Int, limit: Int = 500, offset: Int = 0, completionHandler: @escaping (SearchResponse) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/search/results", queryItems: [
            URLQueryItem(name: "id", value: "\(id)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ])
        
        qBitRequest.requestSearchResults(request: request, completionHandler: completionHandler)
    }
    
    static func getSearchPlugins(completionHandler: @escaping ([SearchPlugin]) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/search/plugins")
        
        qBitRequest.requestSearchPlugins(request: request, completionHandler: completionHandler)
    }
    
    static func getCategories(completionHandler: @escaping ([String: Category]) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/categories")
        
        qBitRequest.requestCategoriesJSON(request: request, completionHandler: completionHandler)
    }
    
    static func setCategory(hash: String, category: String) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/setCategory", queryItems: [
            URLQueryItem(name: "hashes", value: hash),
            URLQueryItem(name: "category", value: category)
        ])
        
        qBitRequest.requestTorrentManagement(request: request, statusCode: {_ in})
    }
    
    static func addCategory(category: String, savePath: String?, then callback: ((Int) -> Void)?) {
        var params = [ URLQueryItem(name: "category", value: category) ]
        
        if let savePath = savePath {
            params.append(URLQueryItem(name: "savePath", value: savePath))
        }
        
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/createCategory", queryItems: params)
        
        if let callback = callback {
            qBitRequest.requestTorrentManagement(request: request, statusCode: {status in callback(status ?? 0)})
        } else {
            qBitRequest.requestTorrentManagement(request: request, statusCode: {_ in})
        }
    }
    
    static func removeCategory(category: String, then callback: ((Int) -> Void)?) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/removeCategories", queryItems: [
            URLQueryItem(name: "categories", value: category)
        ])
        
        if let callback = callback {
            qBitRequest.requestTorrentManagement(request: request, statusCode: {status in callback(status ?? 0)})
        } else {
            qBitRequest.requestTorrentManagement(request: request, statusCode: {_ in})
        }
    }
    
    static func getTags(completionHandler: @escaping ([String]) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/tags")
        
        qBitRequest.requestTagsJSON(request: request, completionHandler: completionHandler)
    }
    
    static func setTag(hash: String, tag: String, result: @escaping (Bool) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/addTags", queryItems: [
            URLQueryItem(name: "hashes", value: hash),
            URLQueryItem(name: "tags", value: tag)
        ])
        
        qBitRequest.requestTorrentManagement(request: request, statusCode: {code in result((code == 200))})
    }
    
    static func unsetTag(hash: String, tag: String, result: @escaping (Bool) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/removeTags", queryItems: [
            URLQueryItem(name: "hashes", value: hash),
            URLQueryItem(name: "tags", value: tag)
        ])
        
        qBitRequest.requestTorrentManagement(request: request, statusCode: {code in result((code == 200))})
    }
    
    static func removeTag(tag: String, then callback: ((Int) -> Void)?) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/deleteTags", queryItems: [
            URLQueryItem(name: "tags", value: tag)
        ])
        
        if let callback = callback {
            qBitRequest.requestTorrentManagement(request: request, statusCode: {status in callback(status ?? 0)})
        } else {
            qBitRequest.requestTorrentManagement(request: request, statusCode: {_ in})
        }
    }
    
    static func addTag(tag: String, then callback: ((Int) -> Void)?) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/createTags", queryItems: [
            URLQueryItem(name: "tags", value: tag)
        ])
        
        if let callback = callback {
            qBitRequest.requestTorrentManagement(request: request, statusCode: {status in callback(status ?? 0)})
        } else {
            qBitRequest.requestTorrentManagement(request: request, statusCode: {_ in})
        }
    }
    
    static func pauseTorrent(hash: String) {
        // qBittorrent 5.0.0 changes pause route to stop and resume to start
        let suffix = self.version.major == 5 ? "stop" : "pause"
        let path = "/api/v2/torrents/\(suffix)"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hash)])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func pauseTorrents(hashes: [String]) {
        let path = "/api/v2/torrents/pause"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func pauseAllTorrents() {
        pauseTorrent(hash: "all")
    }
    
    static func resumeTorrent(hash: String) {
        // qBittorrent 5.0.0 changes pause route to stop and resume to start
        let suffix = self.version.major == 5 ? "start" : "resume"
        let path = "/api/v2/torrents/\(suffix)"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hash)])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func resumeTorrents(hashes: [String]) {
        let path = "/api/v2/torrents/resume"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func resumeAllTorrents() {
        resumeTorrent(hash: "all")
    }
    
    static func recheckTorrent(hash: String) {
        let path = "/api/v2/torrents/recheck"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hash)])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func recheckTorrents(hashes: [String]) {
        let path = "/api/v2/torrents/recheck"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func reannounceTorrent(hash: String) {
        let path = "/api/v2/torrents/reannounce"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hash)])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func reannounceTorrents(hashes: [String]) {
        let path = "/api/v2/torrents/reannounce"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func deleteTorrent(hash: String, deleteFiles: Bool) {
        let path = "/api/v2/torrents/delete"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hash), URLQueryItem(name: "deleteFiles", value: "\(deleteFiles)")])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func deleteTorrents(hashes: [String], deleteFiles: Bool) {
        let path = "/api/v2/torrents/delete"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|")), URLQueryItem(name: "deleteFiles", value: "\(deleteFiles)")])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func deleteTorrent(hash: String) {
        let path = "/api/v2/torrents/delete"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hash), URLQueryItem(name: "deleteFiles", value: "false")])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func deleteTorrents(hashes: [String]) {
        let path = "/api/v2/torrents/delete"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|")), URLQueryItem(name: "deleteFiles", value: "false")])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func increasePriorityTorrents(hashes: [String]) {
        let path = "/api/v2/torrents/increasePrio"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func decreasePriorityTorrents(hashes: [String]) {
        let path = "/api/v2/torrents/decreasePrio"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func topPriorityTorrents(hashes: [String]) {
        let path = "/api/v2/torrents/topPrio"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func bottomPriorityTorrents(hashes: [String]) {
        let path = "/api/v2/torrents/bottomPrio"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func toggleSequentialDownload(hashes: [String]) {
        let path = "/api/v2/torrents/toggleSequentialDownload"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func toggleFLPiecesFirst(hashes: [String]) {
        let path = "/api/v2/torrents/toggleFirstLastPiecePrio"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func setForceStart(hashes: [String], value: Bool) {
        let path = "/api/v2/torrents/setForceStart"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|")), URLQueryItem(name: "value", value: "\(value)")])
        
        qBitRequest.requestUniversal(request: request)
    }

    static func getTrackers(hash: String, completionHandler: @escaping ([Tracker]) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/trackers", queryItems: [URLQueryItem(name: "hash", value: hash)])
        
        qBitRequest.requestTrackersJSON(request: request, completionHandler: completionHandler)
    }
    
    static func getRSSFeeds(withDate: Bool = true, completionHandler: @escaping (RSSNode) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/rss/items", queryItems: [URLQueryItem(name: "withData", value: "true")])
        
        qBitRequest.requestRSSFeedJSON(request: request, completion: { RSSNodes in completionHandler(RSSNodes) })
    }
    
    static func addRSSFeed(url: String, path: String) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/rss/addFeed", queryItems: [URLQueryItem(name: "url", value: url), URLQueryItem(name: "path", value: path)])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func addRSSFolder(path: String) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/rss/addFolder", queryItems: [URLQueryItem(name: "path", value: path)])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func addRSSRemoveItem(path: String) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/rss/removeItem", queryItems: [URLQueryItem(name: "path", value: path)])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func addRSSRefreshItem(path: String) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/rss/refreshItem", queryItems: [URLQueryItem(name: "path", value: path)])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func moveRSSItem(itemPath: String, destPath: String) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/rss/moveItem", queryItems: [
            URLQueryItem(name: "itemPath", value: itemPath),
            URLQueryItem(name: "destPath", value: destPath)
        ])
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func removeTracker(hash: String, url: String) {
        let path = "/api/v2/torrents/removeTrackers"

        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hash", value: hash), URLQueryItem(name: "urls", value: url)])
        
        qBitRequest.requestUniversal(request: request)
    }

    static func editTrackerURL(hash: String, origUrl: String, newURL: String) {
        let path = "/api/v2/torrents/editTracker"

        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hash", value: hash), URLQueryItem(name: "origUrl", value: origUrl), URLQueryItem(name: "newUrl", value: newURL)])

        qBitRequest.requestUniversal(request: request)
    }
    
    static func addTrackerURL(hash: String, urls: String) {
        let path = "/api/v2/torrents/addTrackers"

        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hash", value: hash), URLQueryItem(name: "urls", value: urls)])

        qBitRequest.requestUniversal(request: request)
    }

    static func addMagnetTorrent(torrent: URLQueryItem, savePath: String = "", cookie: String = "", category: String = "", tags: String = "", skipChecking: Bool = false, paused: Bool = false, sequentialDownload: Bool = false, dlLimit: Int = -1, upLimit: Int = -1, ratioLimit: Float = -1.0, seedingTimeLimit: Int = -1) {
        let path = "/api/v2/torrents/add"
        
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(torrent)
        
        if savePath != "" {
            queryItems.append(URLQueryItem(name: "savepath", value: savePath))
        }
        
        if cookie != "" {
            queryItems.append(URLQueryItem(name: "cookie", value: cookie))
        }
        
        if category != "" {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        if tags != "" {
            queryItems.append(URLQueryItem(name: "tags", value: tags))
        }
        
        if skipChecking {
            queryItems.append(URLQueryItem(name: "skip_checking", value: "true"))
        }
        
        if paused {
            let version = qBittorrent.getVersion()
            if(version.major == 5) { queryItems.append(URLQueryItem(name: "stopped", value: "true")) }
            else { queryItems.append(URLQueryItem(name: "paused", value: "true")) }
        }
        
        if dlLimit > 0 {
            queryItems.append(URLQueryItem(name: "dlLimit", value: "\(dlLimit)"))
        }
        
        if upLimit > 0 {
            queryItems.append(URLQueryItem(name: "upLimit", value: "\(upLimit)"))
        }
        
        if ratioLimit > 0 {
            queryItems.append(URLQueryItem(name: "ratioLimit", value: "\(ratioLimit)"))
        }
        
        if seedingTimeLimit > 0 {
            queryItems.append(URLQueryItem(name: "seedingTimeLimit", value: "\(seedingTimeLimit)"))
        }
        
        if sequentialDownload {
            queryItems.append(URLQueryItem(name: "sequentialDownload", value: "true"))
        }
        
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: queryItems)
        
        qBitRequest.requestUniversal(request: request)
    }
    
    static func addFileTorrent(torrents: [String: Data], savePath: String = "", cookie: String = "", category: String = "", tags: String = "", skipChecking: Bool = false, paused: Bool = false, sequentialDownload: Bool = false, dlLimit: Int = -1, upLimit: Int = -1, ratioLimit: Float = -1.0, seedingTimeLimit: Int = -1) {
        
        // Function returning torrent data ready for upload
        func createFileEntry(file: Data, fileName: String = "unknown.torrent") -> Data {
            var data = Data()
            
            data.append("Content-Disposition: form-data; name=\"torrents\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: application/x-bittorrent\r\n\r\n".data(using: .utf8)!)

            for byte in [UInt8](file) {
                data.append(byte)
            }
            
            return data
        }
        
        func createSetting(name: String, value: Any) {
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)".data(using: .utf8)!)
        }
        
        let path = "/api/v2/torrents/add"
        let url = URL(string: "\(qBittorrent.getURL())\(path)")
        let cookie = qBittorrent.getCookie()
        
        // Setting the authentication cookie
        let jar = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": cookie]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url!)
        jar.setCookies(cookies, for: url!, mainDocumentURL: url!) // remove force unwrap
        
        var data = Data() // New data variable ready for appending of the data
        
        /**
         IMPORTANT!
         When specifying boundary in http header we do not write any dashes
         When writing boundries between elements (and at the start) we write two dashes at the beggining of the boundry
         The last boundry in the request must also contain two dashes in the end in addition to two dashes at the beginning ofc
         
         Cheers!
         */
        let boundary = "\(UUID().uuidString.replacing("-", with: ""))"

        let session = URLSession.shared

        var urlRequest = URLRequest(url: url!) // remove force unwrap
        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        
        // Torrents
        for torrent in torrents {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append(createFileEntry(file: torrent.value, fileName: torrent.key))
            data.append("\r\n".data(using: .utf8)!)
        }

        // Settings
        if savePath != "" {
            createSetting(name: "savepath", value: savePath)
        }
        
        if cookie != "" {
            createSetting(name: "cookie", value: cookie)
        }
        
        if category != "" {
            createSetting(name: "category", value: category)
        }
        
        if tags != "" {
            createSetting(name: "tags", value: tags)
        }
        
        if skipChecking {
            createSetting(name: "skip_checking", value: skipChecking)
        }
        
        if paused {
            if(self.version.major == 5) { createSetting(name: "stopped", value: paused) }
            else { createSetting(name: "paused", value: paused) }
        }
        
        if dlLimit > 0 {
            createSetting(name: "dlLimit", value: dlLimit)
        }
        
        if upLimit > 0 {
            createSetting(name: "upLimit", value: upLimit)
        }
        
        if ratioLimit > 0 {
            createSetting(name: "ratioLimit", value: ratioLimit)
        }
        
        if seedingTimeLimit > 0 {
            createSetting(name: "seedingTimeLimit", value: seedingTimeLimit)
        }
        
        if sequentialDownload {
            createSetting(name: "sequentialDownload", value: sequentialDownload)
        }
        
        // End
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        
        // Setting the headers
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")

        // Sending the request
        session.uploadTask(with: urlRequest, from: data, completionHandler: { data, response, error in
            if let error = error {
                print(error)
            }
        }).resume()
    }

    /**
     @Binding var urls: String
     
     @State private var savePath = ""
     @State private var defaultSavePath = ""
     
     @State private var cookie = ""
     @State private var category = ""
     @State private var tags = ""
     
     @State private var skipChecking = false
     @State private var paused = false
     
     @State private var showAdvanced = false
     
     @State private var showLimits = false
     @State private var DLlimit = ""
     @State private var UPlimit = ""
     @State private var ratioLimit = ""
     @State private var seedingTimeLimit = ""
     
     @State private var categories = []
     @State private var tagsArr: [String] = ["None"]
     */
    
    /*
     error
     missingFiles
     uploading
     pausedUP
     queuedUP
     stalledUP
     checkingUP
     forcedUP
     allocating
     downloading
     metaDL
     pausedDL
     queuedDL
     stalledDL
     checkingDL
     forcedDL
     checkingResumeData
     moving
     */
    /*func getTorrents() -> [[String:Any]] {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/info")
        var torrentsArray: [[String:Any]]
        
        qBitRequest.requestJSON(request: request, completionHandler: {array in torrentsArray = array})
        
        return torrentsArray
    }*/
}
