//
//  UploadManager.swift
//  Bullet
//
//  Created by Faris Muhammed on 01/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation
import AVFoundation
import Alamofire
import UIKit
import DataCache

class UploadManager {
    
    // Can't init is singleton
    private init() { }
    
    static let shared = UploadManager()
    
    var arrayUploads = [UploadTask]()
    var updateProgress: (([UploadTask]) -> Void)?
    
    var editingPostTaskID = ""
    var editingArticle: articlesData?
    
    
    func checkCroppingItemsAndUpload() {
        
        
        checkUploadItemsAndUpload()
        if arrayUploads.first(where: {$0.task_status == .cropping }) != nil {
            // Already cropping is running
            return
        }
        
        if let index = arrayUploads.firstIndex(where: {$0.task_status == .waitingForCropping }) {
            
            self.arrayUploads[index].task_status = .cropping
            updateProgress?(arrayUploads)
            
            // url alsways chnage if app restart so we will reconstruct
            let newURL = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(arrayUploads[index].assetURL?.lastPathComponent ?? "")")
            arrayUploads[index].assetURL = newURL
            writeCache(arrCacheDownloads: arrayUploads)
            
            startCroppingInBackground(uploadTask: arrayUploads[index]) { uploadTask, status, url in
                
                if (status ?? false) {
                    
                    if let latestIndex = self.arrayUploads.firstIndex(where: ({$0.taskId == uploadTask.taskId})) {
                        self.arrayUploads[latestIndex].localURL = url
                        self.arrayUploads[latestIndex].task_status = .croppingCompleted
                    }
                    self.writeCache(arrCacheDownloads: self.arrayUploads)
                    
                } else {
                    
                    self.deleteTask(deleteTask: uploadTask)
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Video cropping failed. Please upload then video again.", comment: ""))
                    
                }
                 
                self.updateProgress?(self.arrayUploads)
                self.checkCroppingItemsAndUpload()
            }
        } else {
            print("no item ready for cropping")
        }
        
        
    }
    
    func checkUploadItemsAndUpload() {
        
        if arrayUploads.first(where: {$0.task_status == .uploading }) != nil {
            // Already cropping is running
            return
        }
        
        if let index = arrayUploads.firstIndex(where: {$0.task_status == .croppingCompleted && $0.userUploadStatus != .cancelled && $0.userUploadStatus != .creating_post }) {
           
            // url alsways change if app restart so we will reconstruct
            let newURL = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(arrayUploads[index].localURL?.lastPathComponent ?? "")")
            arrayUploads[index].localURL = newURL
            writeCache(arrCacheDownloads: arrayUploads)
            
            uploadVideo(uploadTask: arrayUploads[index])
            
        } else if let index = arrayUploads.firstIndex(where: {$0.task_status == .uploadingFailed}) {
           
            // url alsways change if app restart so we will reconstruct
            let newURL = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(arrayUploads[index].localURL?.lastPathComponent ?? "")")
            arrayUploads[index].localURL = newURL
            writeCache(arrCacheDownloads: arrayUploads)
            
            uploadVideo(uploadTask: arrayUploads[index])
            
        } else {
            print("no item ready for upload")
        }
        
    }
    
    func uploadVideo(uploadTask: UploadTask) {
        
        if let index = arrayUploads.firstIndex(where: {$0.taskId == uploadTask.taskId}) {
           
            
            arrayUploads[index].task_status = .uploading
            
            self.updateProgress?(self.arrayUploads)
            
            performWSToUploadVideo(uploadItem: arrayUploads[index]) { uploadTask, status, error in
                
                if (status ?? false) {
                    
                    if self.arrayUploads.contains(where: {$0.taskId == uploadTask.taskId}) {
                        self.performWSToArticlePublished(uploadItem: uploadTask)
                    }
                    
                    self.deleteTask(deleteTask: uploadTask)
                    DispatchQueue.main.async {
                        SharedManager.shared.showAlertLoader(message: NSLocalizedString("Video uploaded successfully.", comment: ""))
                    }
                    // upload next item
                    self.checkUploadItemsAndUpload()
                    
                    
                } else if (error ?? false) {
                    
                    self.deleteTask(deleteTask: uploadTask)
                    DispatchQueue.main.async {
                        SharedManager.shared.showAlertLoader(message: NSLocalizedString("Video upload failed. Please upload again.", comment: ""))
                    }
                    // upload next item
                    self.checkUploadItemsAndUpload()
                    
                    
                } else {
                    
                    if let latestIndex = self.arrayUploads.firstIndex(where: ({$0.taskId == uploadTask.taskId})) {
                        self.arrayUploads[latestIndex].task_status = .uploadingFailed
                    }
                    self.writeCache(arrCacheDownloads: self.arrayUploads)
                    DispatchQueue.main.async {
                        SharedManager.shared.showAlertLoader(message: NSLocalizedString("Video upload failed. Please upload again.", comment: ""))
                    }
                }
                
                self.updateProgress?(self.arrayUploads)
            }
            
        }
        
    }
    
    func addItemForCropping(uploadTask: UploadTask) {
        
        arrayUploads.append(uploadTask)
        
        checkCroppingItemsAndUpload()
        
        
        writeCache(arrCacheDownloads: arrayUploads)
        
    }
    
    private func writeCache(arrCacheDownloads: [UploadTask]) {
        
        //write articles data in cache
        do {
            try DataCache.instance.write(codable: arrCacheDownloads, forKey: Constant.CACHE_UploadTask)
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    
    func readCacheOfDownloads() {
        
        //read articles data from cache
        do {
            if let object: [UploadTask] = try DataCache.instance.readCodable(forKey: Constant.CACHE_UploadTask) {
                // Load data from cache
                arrayUploads = object
            }
        } catch {
            print("Read error \(error.localizedDescription)")
        }
        
    }
    
    func clearUncompletedItems() {
        
        arrayUploads = arrayUploads.filter({ $0.userUploadStatus != .creating_post && $0.userUploadStatus != .cancelled })
        writeCache(arrCacheDownloads: arrayUploads)
        
    }
    
    func resetUncompletedItems() {
        
        for (index,task) in arrayUploads.enumerated() {
            if task.task_status == .cropping {
                arrayUploads[index].task_status = .waitingForCropping
                writeCache(arrCacheDownloads: arrayUploads)
                return
            }
            
            if task.task_status == .uploading {
                arrayUploads[index].task_status = .croppingCompleted
                writeCache(arrCacheDownloads: arrayUploads)
                return
            }
        }
        
        
    }
    
    
    func generateRandomTaskID(len: Int = 10)-> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 1...len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString as String
        
    }
    
    
    func deleteTask(deleteTask: UploadTask) {
        
        for (index,task) in arrayUploads.enumerated() {
            if task.taskId == deleteTask.taskId {
                arrayUploads.remove(at: index)
                writeCache(arrCacheDownloads: arrayUploads)
                return
            }
        }
        
    }
    
    
    func updateProgressPercentage(uploadTask: UploadTask, progress: Double) {
        
        for (index,task) in arrayUploads.enumerated() {
            if task.taskId == uploadTask.taskId {
                arrayUploads[index].uploadProgress = progress
                
                updateProgress?(arrayUploads)
                return
            }
        }
    }
    
    
    func updatePostIDForTask(taskID: String, postID: String, sourceID: String) {
        
        for (index,task) in arrayUploads.enumerated() {
            if task.taskId == taskID {
                arrayUploads[index].articleID = postID
                arrayUploads[index].sourceID = sourceID
                
                writeCache(arrCacheDownloads: arrayUploads)
                
                return
            }
        }
        
    }
    
//    func updateTask(uploadTask: UploadTask) {
//
//        for (index,task) in arrayUploads.enumerated() {
//            if task.taskId == uploadTask.taskId {
//                arrayUploads[index] = uploadTask
//                writeCache(arrCacheDownloads: arrayUploads)
//                return
//            }
//        }
//    }
    
    func updatePostUploadStatus(taskID: String, updateUserStatus: UserUploadStatus) {
        
        for (index,task) in arrayUploads.enumerated() {
            if task.taskId == taskID {
                arrayUploads[index].userUploadStatus = updateUserStatus
                writeCache(arrCacheDownloads: arrayUploads)
                return
            }
        }
        
    }
    
    func updatePostUploadStatus(articleID: String, updateUserStatus: UserUploadStatus) {
        
        for (index,task) in arrayUploads.enumerated() {
            if task.articleID == articleID {
                arrayUploads[index].userUploadStatus = updateUserStatus
                
                writeCache(arrCacheDownloads: arrayUploads)
                return
            }
        }
        
    }
    
    func updatePostServerURL(taskID: String, serverURL: String) {
        
        for (index,task) in arrayUploads.enumerated() {
            if task.taskId == taskID {
                arrayUploads[index].serverURL = serverURL
                
                writeCache(arrCacheDownloads: arrayUploads)
                return
            }
        }
        
    }
    
    
    func startCroppingInBackground(uploadTask: UploadTask, completionHandlerCropping: @escaping (_ uploadItem: UploadTask,_ status: Bool?, _ url: URL?) -> ()) {
        
        do {
            guard let assetURL = uploadTask.assetURL else {
                completionHandlerCropping(uploadTask, false, nil)
                return
            }
            let asset = try assetByTrimming(startTime: uploadTask.startTime ?? .zero, endTime: uploadTask.endTime ?? .zero, asset: getAsset(url: assetURL))
            guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
                completionHandlerCropping(uploadTask, false, nil)
                return
            }
            
            let assetComposition = AVMutableComposition()
            let frame1Time = CMTime(seconds: asset.duration.seconds, preferredTimescale: asset.duration.timescale)
            let trackTimeRange = CMTimeRangeMake(start: .zero, duration: frame1Time)
            
            guard let videoCompositionTrack = assetComposition.addMutableTrack(withMediaType: .video,
                                                                               preferredTrackID: kCMPersistentTrackID_Invalid) else {
                completionHandlerCropping(uploadTask, false, nil)
                return
            }
            
            try videoCompositionTrack.insertTimeRange(trackTimeRange, of: videoTrack, at: CMTime.zero)
            
            if let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first {
                let audioCompositionTrack = assetComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                             preferredTrackID: kCMPersistentTrackID_Invalid)
                try audioCompositionTrack?.insertTimeRange(trackTimeRange, of: audioTrack, at: CMTime.zero)
            }
            
            //1. Create the instructions
            let mainInstructions = AVMutableVideoCompositionInstruction()
            mainInstructions.timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
            
            //2 add the layer instructions
            let layerInstructions = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
            
            let renderSize = CGSize(width: 16 * (uploadTask.aspectRatioWidth ?? 1) * 18,
                                    height: 16 * (uploadTask.aspectRatioHeight ?? 1) * 18)
            let transform = getTransform(for: videoTrack, aspectRatioWidth: (uploadTask.aspectRatioWidth ?? 1), aspectRatioHeight: (uploadTask.aspectRatioHeight ?? 1), imageCropFrame: uploadTask.imageCropFrame ?? .zero)
            
            layerInstructions.setTransform(transform, at: CMTime.zero)
            layerInstructions.setOpacity(1.0, at: CMTime.zero)
            mainInstructions.layerInstructions = [layerInstructions]
            
            //3 Create the main composition and add the instructions
            
            let videoComposition = AVMutableVideoComposition()
            videoComposition.renderSize = renderSize
            videoComposition.instructions = [mainInstructions]
            videoComposition.frameDuration = CMTimeMake(value: 1, timescale:     30)
            
            let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(uploadTask.taskId ?? "").mp4")
            try? FileManager.default.removeItem(at: url)
            
            let exportSession = AVAssetExportSession(asset: assetComposition, presetName: AVAssetExportPresetHighestQuality)
            exportSession?.outputFileType = AVFileType.mp4
            exportSession?.shouldOptimizeForNetworkUse = true
            exportSession?.videoComposition = videoComposition
            exportSession?.outputURL = url
            exportSession?.exportAsynchronously(completionHandler: {
                
                DispatchQueue.main.async {
                    
                    if let url = exportSession?.outputURL, exportSession?.status == .completed {
                        //                    UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
                        
//                        guard let didSave = self.didSave else { return print("Don't have saveCallback") }
//                        let resultVideo = YPMediaVideo(thumbnail: nil,
//                                                       videoURL: url,
//                                                       asset: self.inputVideo.asset)
//                        didSave(YPMediaItem.video(v: resultVideo))
                        
                        completionHandlerCropping(uploadTask, true, url)
                    } else {
                        completionHandlerCropping(uploadTask, false, nil)
                    }
                }
            })
        } catch let error {
            
            print(error.localizedDescription)
        }
        
    }
    
    func getAsset(url: URL) -> AVAsset {
        return AVAsset(url: url)
    }
    
    
    func assetByTrimming(startTime: CMTime, endTime: CMTime, asset: AVAsset) throws -> AVAsset {
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        let composition = AVMutableComposition()
        do {
            for track in asset.tracks {
                let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType,
                                                                   preferredTrackID: track.trackID)
                try compositionTrack?.insertTimeRange(timeRange, of: track, at: CMTime.zero)
            }
        } catch let error {
            throw YPTrimError("Error during composition", underlyingError: error)
        }
        
        // Reaply correct transform to keep original orientation.
        if let videoTrack = asset.tracks(withMediaType: .video).last,
            let compositionTrack = composition.tracks(withMediaType: .video).last {
            compositionTrack.preferredTransform = videoTrack.preferredTransform
        }

        return composition
    }
    
    
    func getTransform(for videoTrack: AVAssetTrack, aspectRatioWidth: CGFloat, aspectRatioHeight: CGFloat, imageCropFrame: CGRect) -> CGAffineTransform {

        let renderSize = CGSize(width: 16 * aspectRatioWidth * 18,
                                height: 16 * aspectRatioHeight * 18)
        let cropFrame = imageCropFrame
        let renderScale = renderSize.width / cropFrame.width
        let offset = CGPoint(x: -cropFrame.origin.x, y: -cropFrame.origin.y)
        let rotation = atan2(videoTrack.preferredTransform.b, videoTrack.preferredTransform.a)

        var rotationOffset = CGPoint(x: 0, y: 0)

        if videoTrack.preferredTransform.b == -1.0 {
            rotationOffset.y = videoTrack.naturalSize.width
        } else if videoTrack.preferredTransform.c == -1.0 {
            rotationOffset.x = videoTrack.naturalSize.height
        } else if videoTrack.preferredTransform.a == -1.0 {
            rotationOffset.x = videoTrack.naturalSize.width
            rotationOffset.y = videoTrack.naturalSize.height
        }

        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: renderScale, y: renderScale)
        transform = transform.translatedBy(x: offset.x + rotationOffset.x, y: offset.y + rotationOffset.y)
        transform = transform.rotated(by: rotation)

        print("track size \(videoTrack.naturalSize)")
        print("preferred Transform = \(videoTrack.preferredTransform)")
        print("rotation angle \(rotation)")
        print("rotation offset \(rotationOffset)")
        print("actual Transform = \(transform)")
        return transform
    }
    
    
    
}



// MARK: - Webservices
extension UploadManager {
    
    func performWSToUploadVideo(uploadItem: UploadTask, completionHandler: @escaping (_ uploadTask: UploadTask, _ status: Bool?, _ error: Bool?) -> Void) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {

            SharedManager.shared.showAlertLoader(message: NSLocalizedString(ApplicationAlertMessages.kMsgInternetNotAvailable, comment: ""))
            completionHandler(uploadItem ,false, false)
            
        }
        DispatchQueue.main.async {
//            self.lblProgressStatus.text = "0%"
//            self.viewProgressContainer.isHidden = false
        }
        
        //        do {
        //            let resources = try videoURL.resourceValues(forKeys: [.fileSizeKey])
        //            let fileSize = resources.fileSize!
        //            print ("fileSize: \(fileSize)")
        //        } catch {
        //            print("Error: \(error)")
        //        }
        
        let params = ["video": uploadItem.localURL?.absoluteString ?? ""] as [String : Any]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let completeUrl : String = WebserviceManager.shared.API_BASE + "media/videos"
        
        var headersToken = HTTPHeaders()
        headersToken = [
            "Authorization": "Bearer \(token)"
        ]
        headersToken["x-app-platform"] = "ios"
        headersToken["x-app-version"] = Bundle.main.releaseVersionNumberPretty
        headersToken["api-version"] = WebserviceManager.shared.API_VERSION
        headersToken["X-User-Timezone"] = TimeZone.current.identifier
        
        AF.upload(multipartFormData: { (multipartFormData) in
            
            for item in params {
                
                if let url = URL(string:item.value as! String) {
                    
                    do {
                        let videoData = try Data(contentsOf: url)
                        multipartFormData.append(videoData, withName: item.key, fileName: "video.mp4", mimeType: "video/mp4")
                    } catch {
                           debugPrint("Error Couldn't get Data from URL: \(url): \(error)")
                    }
                }
            }
            
        }, to: URL(string: completeUrl)!, usingThreshold: UInt64.init(), method: .post, headers: headersToken, fileManager: FileManager.default)
        
        .uploadProgress { progress in // main queue by default
            print("Upload Progress: \(progress.fractionCompleted)")
            //print("Upload Estimated Time Remaining: \(String(describing: progress.estimatedTimeRemaining))")
            //print("Upload Total Unit count: \(progress.totalUnitCount)")
            //print("Upload Completed Unit Count: \(progress.completedUnitCount)")
            
//            let percent = Int(progress.fractionCompleted * 100)
//            print("percentage", percent)
            
            self.updateProgressPercentage(uploadTask: uploadItem, progress: progress.fractionCompleted)
            
//                self.viewCircularProgress.setProgressWithAnimation(duration: 0.1, fromValue: prevProgress, toValue: Float(progress.fractionCompleted))
//            prevProgress = Float(progress.fractionCompleted)
            
//                self.lblProgressStatus.text = "\(percent)%"
            
            
        }
        
        .responseJSON { (response) in
            
            //print("Parameters: \(self.parameters.description)")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")                         // response serialization result
            if let responseData = response.data, let utf8Text = String(data: responseData, encoding: .utf8) {
                print("String Data: \(utf8Text)")
                
                do{
                    
                    let FULLResponse = try
                        JSONDecoder().decode(UploadSuccessDC.self, from: responseData)
                    
//                        self.viewProgressContainer.isHidden = true
                    if FULLResponse.success == true {
                        
                        if let latestIndex = self.arrayUploads.firstIndex(where: ({$0.taskId == uploadItem.taskId})) {
                            
                            self.arrayUploads[latestIndex].serverURL = FULLResponse.key ?? ""
                            self.writeCache(arrCacheDownloads: self.arrayUploads)
                            
                            completionHandler(self.arrayUploads[latestIndex], true, false)
                            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Video uploaded successfully.", comment: ""))
                        } else {
                            
                            completionHandler(uploadItem ,false, true)
                        }
                        

                        
                    }
                    else {
                        
                        completionHandler(uploadItem ,false, true)
                    }
                    
                } catch let jsonerror {
                    
                    completionHandler(uploadItem ,false, true)
                    
                    
                    print("error parsing json objects", jsonerror)
                }
            }
            else {
                
                completionHandler(uploadItem ,false, false)
                
                
            }
        }
        
    }
    
    
    func performWSToArticlePublished(uploadItem: UploadTask) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            

        }
        
//        ANLoader.showLoading()
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let id = uploadItem.articleID ?? ""
        
        var params = ["media": uploadItem.serverURL ?? "",
                      "source": uploadItem.sourceID ?? "",
                      "id": id,
                      "status": uploadItem.userUploadStatus == .posted ? "PUBLISHED" : "DRAFT"] as [String : Any]
        
        var query = ""
        if uploadItem.uploadType == .reel {
            
            query = "studio/reels"
        } else {
            
            //video
            params = ["video": uploadItem.serverURL ?? "",
                      "source": uploadItem.sourceID ?? "",
                      "id": id,
                      "status": uploadItem.userUploadStatus == .posted ? "PUBLISHED" : "DRAFT"] as [String : Any]
            
            query = "studio/articles/video"
        }
        
        WebService.URLResponse(query, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
//            ANLoader.hide()
            do{
                
                let FULLResponse = try JSONDecoder().decode(messageDC.self, from: response)
                print("publish response", FULLResponse.status ?? "")
                
                
//                SharedManager.shared.showAlertLoader(message: NSLocalizedString(self.scheduleDate.isEmpty ? "Article published successfully" : "Article scheduled successfully", comment: ""), type: .alert)
//                self.navigationController?.popToRootViewController(animated: true)
                                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "studio/articles/id/status", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    
}
