//
//  ReelsCacheManager.swift
//  Bullet
//
//  Created by Abdullah Tariq on 14/11/2022.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation
import GCDWebServer
import AVFoundation

protocol ReelsCacheManagerDelegate: NSObject {
    func cachingCompleted(reel: Reel, position: Int)
}

enum Resolution: String {
    case High = "1080p"
    case Medium = "720p"
    case Low = "480p"
    case VeryLow = "240p"
}

class CacheObserver: NSObject {
    
    var compilition: (() -> Void)
    init(compilition: @escaping () -> Void) {
        self.compilition = compilition
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges), let playerItem = object as? AVPlayerItem {
            let timeRange = playerItem.loadedTimeRanges.first?.timeRangeValue ?? CMTimeRange.zero
            let bufferDuration = CMTimeGetSeconds(timeRange.duration)
            if bufferDuration >= 3 {
                compilition()
                playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
            }
        }
    }
}


class ReelsCacheManager {
    
    static let shared = ReelsCacheManager()
    static let webServer = GCDWebServer()
    let queue = DispatchQueue(label: "serial")

    weak var delegate: ReelsCacheManagerDelegate?
    var reelsArray: [Reel]!
    var chunkList = [String]()
    var reel: Reel!
    var resType = Resolution.Medium
    var webServerHost: String!
    var webServerHostHLS: String!
    var reelViewedOnChannelPage = false
    func begin(reelModel: Reel, position: Int){
        
        if NetworkManager.isReachable {
            resType = NetworkManager.isReachableViaWiFi ? Resolution.Medium : Resolution.Low
        }
        
        queue.async { [weak self] in
            self?.cacheAVPlayerItem(reelModel, position)
        }
        //        queue.waitUntilAllOperationsAreFinished()
    }
    
    func cacheAVPlayerItem(_ reel: Reel,_ position: Int) {
        guard let media = reel.media,
        let url = URL(string: media) else { return }
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredMaximumResolution = CGSize(width: 426, height: 240)
        playerItem.preferredPeakBitRate = Double(200000)
        playerItem.preferredForwardBufferDuration = 3
        let player = NRPlayer(playerItem: playerItem)
        player.automaticallyWaitsToMinimizeStalling = false
        SharedManager.shared.players.append(player) 
    }

    func fetchResFileList(_ reel: Reel,_ position: Int){
        let url = URL(string: reel.media ?? "")!
        
        let task = URLSession.shared.dataTask(with: url) { [ weak self] (data, response, error) in
            guard let data = data else { return }
            let list = (String(data: data, encoding: .utf8)!).split(whereSeparator: \.isNewline)
            
            if self?.resType == .Low{
                if let chunkUrl = list.first(where: { $0.contains(Resolution.Low.rawValue)}){
                    self?.fetchFileChunks(String(chunkUrl), reel, position)
                }else  if let chunkUrl = list.first(where: { $0.contains(Resolution.VeryLow.rawValue)}){
                    self?.fetchFileChunks(String(chunkUrl), reel, position)
                }
            }else{
                if let chunkUrl = list.first(where: { $0.contains(self?.resType.rawValue ?? "720p")}){
                    self?.fetchFileChunks(String(chunkUrl), reel, position)
                }else if let chunkUrl = list.first(where: { $0.contains("720p")}){
                    self?.fetchFileChunks(String(chunkUrl), reel, position)
                }
            }
        }
        task.resume()
    }
    
    
    func fetchFileChunks(_ url: String, _ reel: Reel, _ position: Int){
        let url = URL(string: url)!
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data else { return }
            let content = (String(data: data, encoding: .utf8))
            if let content, content.count > 0{
                self?.downloadChunkAndStore(content, reel, position)
            }else{
                return
            }
        }
        task.resume()
    }
    
    func downloadChunkAndStore(_ chunkContent: String, _ reel: Reel,_ position: Int){
        
        let list = chunkContent.split(separator: "\n").map(String.init)
        self.chunkList = list.filter{
            $0.contains("https")
        }
        let urlChunck = chunkList[0]
        if urlChunck != " ", urlChunck.count > 0 {
            let url = URL(string: urlChunck)!
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                
                let pathHLS = FileManager.default.urls(for: .documentDirectory,
                                                       in: .userDomainMask)[0].appendingPathComponent("HLSFiles")
                let pathM3U8 = FileManager.default.urls(for: .documentDirectory,
                                                        in: .userDomainMask)[0].appendingPathComponent("M3U8Files")
                
                if !self.directoryExistsAtPath(pathHLS.absoluteString){
                    self.createDirIfNeeded(dirName: "HLSFiles")
                    
                }
                if !self.directoryExistsAtPath(pathM3U8.absoluteString){
                    self.createDirIfNeeded(dirName: "M3U8Files")
                }
                
                let finalHLSFileName = "\(position)_" + (reel.id ?? "") + "_" + String(urlChunck.components(separatedBy: "/").last ?? "")
                var finalM3U8FileName = String(urlChunck.components(separatedBy: "/").last ?? "")
                finalM3U8FileName = (finalM3U8FileName as NSString).deletingPathExtension
                finalM3U8FileName += ".m3u8"
                let fileUrlHLS = pathHLS.appendingPathComponent(finalHLSFileName)
                if let webserver = self.webServerHost{
                    let newM3U8File = chunkContent.replace(string: urlChunck, replacement: webserver + "HLSFiles/\(finalHLSFileName)")
                    
                    let fileUrlM3U8 = pathM3U8.appendingPathComponent("\(position)_" + (reel.id ?? "") + "_" + finalM3U8FileName)
                    do {
                        try data.write(to: fileUrlHLS)
                        try newM3U8File.write(to: fileUrlM3U8, atomically: true, encoding: .utf8)
                        self.completion(reel: reel, position: position, finalM3U8FileName: finalM3U8FileName)
                    } catch {
                        return
                    }
                }
            }
            task.resume()
        }
    }
    
    private func completion(reel: Reel, position: Int, finalM3U8FileName: String) {
        if let webserver = self.webServerHost{
            self.reel = reel
            self.reel.media = webserver + "M3U8Files/" + "\(position)_" + (reel.id ?? "") + "_" + finalM3U8FileName
            self.delegate?.cachingCompleted(reel: self.reel, position: position)
        }
    }
    
    static func getGCDHostURL(){
        DispatchQueue.main.async {
            let pathM3U8 = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask)[0].path
            webServer.addGETHandler(forBasePath: "/", directoryPath: pathM3U8, indexFilename: nil, cacheAge: 0, allowRangeRequests: true)
            do {
                GCDWebServer.setLogLevel(4)

                try webServer.start(options: [
                    "Port": 9090,
                    "BindToLocalhost": true
                    ])
                ReelsCacheManager.shared.webServerHost = webServer.serverURL?.absoluteString
            } catch {
                // handle error
            }
             
//            if webServer.serverURL?.absoluteString == nil {
//                ReelsCacheManager.shared.webServerHost = "http://localhost:9090/"
//            }else{
//                ReelsCacheManager.shared.webServerHost = webServer.serverURL?.absoluteString
//            }
            
                        
        }
        
    }
    
    func createDirIfNeeded(dirName: String) {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(dirName + "/")
        do {
            try FileManager.default.createDirectory(atPath: dir.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    func clearDiskCache() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        guard let filePaths = try? fileManager.contentsOfDirectory(at: myDocuments, includingPropertiesForKeys: nil, options: []) else { return }
        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
    }
    
    func deleteCachedReels(currentPosition: Int, reelsArray: [Reel], completion: (_ index: Int)->(Void)) {
        
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsHLSFilesPath = documentsUrl.appendingPathComponent("HLSFiles")?.path
        let documentsM3U8FilesPath = documentsUrl.appendingPathComponent("M3U8Files")?.path
        
        let reel = reelsArray[0]
        do {
            if let documentsHLSFilesPath = documentsHLSFilesPath
            {
                
                var fileToDelete = reel.media ?? ""
                fileToDelete = fileToDelete.components(separatedBy: "/").last ?? ""
                fileToDelete = fileToDelete.replace(string: ".m3u8", replacement: ".ts")
                let filePathName = "\(documentsHLSFilesPath)/\(fileToDelete)"
                try fileManager.removeItem(atPath: filePathName)
                let files = try fileManager.contentsOfDirectory(atPath: "\(documentsHLSFilesPath)")
             }
            if let documentsM3U8FilesPath = documentsM3U8FilesPath
            {
                
                var fileToDelete = reel.media ?? ""
                fileToDelete = fileToDelete.components(separatedBy: "/").last ?? ""
                let filePathName = "\(documentsM3U8FilesPath)/\(fileToDelete)"
                try fileManager.removeItem(atPath: filePathName)
                
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentsM3U8FilesPath)")
             }
            
            completion(0)
        } catch {
         }
    }
}
