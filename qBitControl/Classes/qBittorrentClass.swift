//
//  qBittorrentClass.swift
//  qBitControl
//

import Foundation
import SwiftUI


class qBittorrent {
    static private var cookie = "n/a"
    static private var url = "http://0.0.0.0"
    
    static func setURL(url: String) {
        self.url = url
    }
    
    static func getURL() -> String {
        return url
    }
    
    static func setCookie(cookie: String) -> Void {
        self.cookie = cookie
    }
    
    static func getCookie() -> String {
        return cookie
    }
    
    static func getState(state: String) -> String {
        switch state {
        case "error":
            return "Error"
        case "missingFiles":
            return "Missing Files"
        case "uploading":
            return "Seeding"
        case "pausedUP":
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
        case "pausedDL":
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
        
        switch state {
        case "error":
            return errorIcon
        case "missingFiles":
            return errorIcon
        case "uploading":
            return uploadIcon
        case "pausedUP":
            return pauseIcon
        case "queuedUP":
            return uploadIcon
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
        case "pausedDL":
            return pauseIcon
        case "queuedDL":
            return downloadIcon
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
        case "pausedUP":
            return pausedColor
        case "queuedUP":
            return seedingColor
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
        case "pausedDL":
            return pausedColor
        case "queuedDL":
            return downloadingColor
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
    
    static func getFormatedDate(date: Int) -> String {
        let fullDate = Date(timeIntervalSince1970: TimeInterval(date))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: fullDate)
    }
    
    static func getPreferences(completionHandler: @escaping (qBitPreferences) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/app/preferences")
        
        qBitRequest.requestPreferencesJSON(request: request, completionHandler: completionHandler)
    }
    
    static func getCategories(completionHandler: @escaping ([String: [String: String]]) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/categories")
        
        qBitRequest.requestCategoriesJSON(request: request, completionHandler: completionHandler)
    }
    
    static func getTags(completionHandler: @escaping ([String]) -> Void) {
        let request = qBitRequest.prepareURLRequest(path: "/api/v2/torrents/tags")
        
        qBitRequest.requestTagsJSON(request: request, completionHandler: completionHandler)
    }
    
    static func pauseTorrent(hash: String) {
        let path = "/api/v2/torrents/pause"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hash)])
        
        qBitRequest.requestTorrentManagement(request: request)
    }
    
    static func pauseTorrents(hashes: [String]) {
        let path = "/api/v2/torrents/pause"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))])
        
        qBitRequest.requestTorrentManagement(request: request)
    }
    
    static func pauseAllTorrents() {
        pauseTorrent(hash: "all")
    }
    
    static func resumeTorrent(hash: String) {
        let path = "/api/v2/torrents/resume"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hash)])
        
        qBitRequest.requestTorrentManagement(request: request)
    }
    
    static func resumeTorrents(hashes: [String]) {
        let path = "/api/v2/torrents/resume"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|"))])
        
        qBitRequest.requestTorrentManagement(request: request)
    }
    
    static func resumeAllTorrents() {
        resumeTorrent(hash: "all")
    }
    
    static func recheckTorrent(hash: String) {
        let path = "/api/v2/torrents/recheck"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hash)])
        
        qBitRequest.requestTorrentManagement(request: request)
    }
    
    static func reannounceTorrent(hash: String) {
        let path = "/api/v2/torrents/reannounce"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hash)])
        
        qBitRequest.requestTorrentManagement(request: request)
    }
    
    static func deleteTorrent(hash: String, deleteFiles: Bool) {
        let path = "/api/v2/torrents/delete"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hash), URLQueryItem(name: "deleteFiles", value: "\(deleteFiles)")])
        
        qBitRequest.requestTorrentManagement(request: request)
    }
    
    static func deleteTorrents(hashes: [String], deleteFiles: Bool) {
        let path = "/api/v2/torrents/delete"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|")), URLQueryItem(name: "deleteFiles", value: "\(deleteFiles)")])
        
        qBitRequest.requestTorrentManagement(request: request)
    }
    
    static func deleteTorrent(hash: String) {
        let path = "/api/v2/torrents/delete"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hash), URLQueryItem(name: "deleteFiles", value: "false")])
        
        qBitRequest.requestTorrentManagement(request: request)
    }
    
    static func deleteTorrents(hashes: [String]) {
        let path = "/api/v2/torrents/delete"
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: [URLQueryItem(name: "hashes", value: hashes.joined(separator: "|")), URLQueryItem(name: "deleteFiles", value: "false")])
        
        qBitRequest.requestTorrentManagement(request: request)
    }
    
    static func addMagnetTorrent(torrent: URLQueryItem, savePath: String = "", cookie: String = "", category: String = "", tags: String = "", skipChecking: Bool = false, paused: Bool = false, dlLimit: Int = -1, upLimit: Int = -1, ratioLimit: Float = -1.0, seedingTimeLimit: Int = -1) {
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
            queryItems.append(URLQueryItem(name: "paused", value: "true"))
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
        
        
        let request = qBitRequest.prepareURLRequest(path: path, queryItems: queryItems)
        
        qBitRequest.requestTorrentManagement(request: request)
    }
    
    static func addFileTorrent(torrents: [String: Data], savePath: String = "", cookie: String = "", category: String = "", tags: String = "", skipChecking: Bool = false, paused: Bool = false, dlLimit: Int = -1, upLimit: Int = -1, ratioLimit: Float = -1.0, seedingTimeLimit: Int = -1) {
        
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
            createSetting(name: "paused", value: paused)
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
        
        // End
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        
        // Setting the headers
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")

        // Sending the request
        session.uploadTask(with: urlRequest, from: data, completionHandler: { data, response, error in
            if let response = response {
                print("\(response)")
            }
            
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
     
     @State private var categoriesArr = ["None"]
     @State private var categoriesPaths = ["None": ""]
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
