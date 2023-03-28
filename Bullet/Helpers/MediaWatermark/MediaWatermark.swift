//
//  MediaWatermark.swift
//  Bullet
//
//  Created by Khadim Hussain on 30/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation
import Photos
import SpriteKit
import AVKit

enum PDWatermarkPosition {
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
    case Default
}

class MediaWatermark: NSObject {
    
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    func downloadVideo(video videoUrl:String, saveToLibrary flag : Bool, completionHandler: @escaping CompletionHandler) {
    
        self.dwonloadVideoToLocal(videoLink: videoUrl, saveToLibrary: flag) { status in
            
            if status {
                
                completionHandler(true)
            }
            else {
                completionHandler(false)
                
            }
        }
    }
    
    func watermark(video videoAsset:AVAsset, watermarkText text : String, saveToLibrary flag : Bool, watermarkPosition position : PDWatermarkPosition, completion : ((_ status : AVAssetExportSession.Status?, _ session: AVAssetExportSession?, _ outputURL : URL?) -> ())?) {
        self.watermark(video: videoAsset, watermarkText: text, imageName: nil, saveToLibrary: flag, watermarkPosition: position) { (status, session, outputURL) -> () in
            completion!(status, session, outputURL)
        }
    }
    
    func watermark(video videoAsset:AVAsset, imageName name : String, watermarkText text : String , saveToLibrary flag : Bool, watermarkPosition position : PDWatermarkPosition, completion : ((_ status : AVAssetExportSession.Status?, _ session: AVAssetExportSession?, _ outputURL : URL?) -> ())?) {
        self.watermark(video: videoAsset, watermarkText: text, imageName: name, saveToLibrary: flag, watermarkPosition: position) { (status, session, outputURL) -> () in
            completion!(status, session, outputURL)
        }
    }
    
    private func watermark(video videoAsset:AVAsset, watermarkText text : String!, imageName name : String!, saveToLibrary flag : Bool, watermarkPosition position : PDWatermarkPosition, completion : ((_ status : AVAssetExportSession.Status?, _ session: AVAssetExportSession?, _ outputURL : URL?) -> ())?) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            
            let mixComposition = AVMutableComposition()
            
            let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            
            
            if videoAsset.tracks(withMediaType: AVMediaType.video).count == 0
            
            {
                completion!(nil, nil, nil)
                return
            }
            
            let clipVideoTrack =  videoAsset.tracks(withMediaType: AVMediaType.video)[0]
            
            self.addAudioTrack(composition: mixComposition, videoAsset: videoAsset as! AVURLAsset)
            
            
            do {
                try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: clipVideoTrack, at: CMTime.zero)
            }
            catch {
                print(error.localizedDescription)
            }
            
            
            let videoSize = clipVideoTrack.naturalSize //CGSize(width: 375, height: 300)
            
            
            
            print("videoSize--\(videoSize)")
            let parentLayer = CALayer()
            
            let videoLayer = CALayer()
            
            parentLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
            videoLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
            //videoLayer.backgroundColor = UIColor.red.cgColor
            parentLayer.addSublayer(videoLayer)
            
            if name != nil {
                let watermarkImage = UIImage(named: "mediaMarkLight")
                let imageLayer = CALayer()
                //imageLayer.backgroundColor = UIColor.purple.cgColor
                imageLayer.contents = watermarkImage?.cgImage
                
                var xPosition : CGFloat = 0.0
                var yPosition : CGFloat = 0.0
                
                var imageSize : CGFloat = 350
                var imageHeight : CGFloat = 113
                if SharedManager.shared.isReelsVideo {
                    
                    imageSize = 200
                    imageHeight = 65
                }
                switch (position) {
                case .TopLeft:
                    xPosition = 30
                    yPosition = videoSize.height - (200 + 30)
                    break
                case .TopRight:
                    xPosition = videoSize.width - 200 - 30
                    yPosition = 30
                    break
                case .BottomLeft:
                    xPosition = 30
                    yPosition = 30 // videoSize.height - imageSize
                    break
                case .BottomRight, .Default:
                    xPosition = videoSize.width - imageSize
                    yPosition = videoSize.height - imageSize
                    break
                }
                
                
                imageLayer.frame = CGRect(x: xPosition, y: yPosition, width: imageSize, height: imageHeight)
                imageLayer.opacity = 1.0
                
                parentLayer.addSublayer(imageLayer)
                
                
                
                if text != nil {
                    let titleLayer = CATextLayer()
                    titleLayer.backgroundColor = UIColor.clear.cgColor
                    titleLayer.string = ""
                    titleLayer.font = Constant.FONT_Mulli_EXTRABOLD as CFTypeRef
                    titleLayer.fontSize = 16
                    titleLayer.alignmentMode = CATextLayerAlignmentMode.left
                    titleLayer.frame = CGRect(x: xPosition - 20, y: yPosition - 55 , width: videoSize.width - imageSize/2 - 4, height: 57)
                    titleLayer.foregroundColor = UIColor.black.cgColor
                    parentLayer.addSublayer(titleLayer)
                } 
            }
            
            let videoComp = AVMutableVideoComposition()
            videoComp.renderSize = videoSize
            videoComp.frameDuration = CMTimeMake(value: 1, timescale: 30)
            videoComp.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
            
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: mixComposition.duration)
            instruction.backgroundColor = UIColor.gray.cgColor
            _ = mixComposition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack
            
            let layerInstruction = self.videoCompositionInstructionForTrack(track: compositionVideoTrack!, asset: videoAsset)
            
            instruction.layerInstructions = [layerInstruction]
            videoComp.instructions = [instruction]
            
            
            
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let timestamp = Date().timeIntervalSince1970
            
            let url = URL(fileURLWithPath: documentDirectory).appendingPathComponent("watermarkVideo-\(timestamp).mp4")
            SharedManager.shared.videoUrlTesting = URL(fileURLWithPath: documentDirectory).appendingPathComponent("watermarkVideo-\(timestamp).mp4")
            SharedManager.shared.instaVideoLocalPath = "watermarkVideo-\(timestamp)"
            
            let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
            exporter?.outputURL = url
            exporter?.outputFileType = AVFileType.mp4
            exporter?.shouldOptimizeForNetworkUse = false
            exporter?.videoComposition = videoComp
            
            exporter?.exportAsynchronously() {
                DispatchQueue.main.async {
                    
                    if exporter?.status == AVAssetExportSession.Status.completed {
                        let outputURL = exporter?.outputURL
                        if flag {
                            
                            let videoAsset1 = AVAsset(url: outputURL!)
                            
                            guard let path = Bundle.main.path(forResource: SharedManager.shared.isReelsVideo ? "appLogo" : "appLogoPortrait", ofType:"mp4") else {
                                //   debugPrint("video not found")
                                
                                SharedManager.shared.isReelsVideo = false
                                return
                            }
                            let videoAsset2 = AVAsset(url: URL(fileURLWithPath: path))
                            self.merge(arrayVideos: [videoAsset1, videoAsset2]) { output, _ in
                                
                                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(output!.path) {
                                    PHPhotoLibrary.shared().performChanges({
                                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: output!)
                                    }) { saved, error in
                                        if saved {
                                            completion!(AVAssetExportSession.Status.completed, exporter, output)
                                        }
                                    }
                                }
                            }
                            SharedManager.shared.isReelsVideo = false
                        }
                        else {
                            
                            let videoAsset1 = AVAsset(url: outputURL!)
                            
                            guard let path = Bundle.main.path(forResource: SharedManager.shared.isReelsVideo ? "appLogo" : "appLogoPortrait", ofType:"mp4") else {
                                
                                SharedManager.shared.isReelsVideo = false
                                return
                            }
                            let videoAsset2 = AVAsset(url: URL(fileURLWithPath: path))
                            self.merge(arrayVideos: [videoAsset1, videoAsset2]) { output, _ in
                                
                                completion!(AVAssetExportSession.Status.completed, exporter, output)
                            }
                            
                            // completion!(AVAssetExportSession.Status.completed, exporter, outputURL)
                            SharedManager.shared.isReelsVideo = false
                        }
                        
                    } else {
                        // Error
                        completion!(exporter?.status, exporter, nil)
                        SharedManager.shared.isReelsVideo = false
                    }
                }
            }
        }
    }
    
    private func addAudioTrack(composition: AVMutableComposition, videoAsset: AVURLAsset) {
        let compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
        let audioTracks = videoAsset.tracks(withMediaType: AVMediaType.audio)
        for audioTrack in audioTracks {
            try! compositionAudioTrack.insertTimeRange(audioTrack.timeRange, of: audioTrack, at: CMTime.zero)
        }
    }
    
    
    private func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        
        return (assetOrientation, isPortrait)
    }
    
    private func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform: transform)
        
        var scaleToFitRatio = UIScreen.main.bounds.width / UIScreen.main.bounds.width
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),
                                     at: CMTime.zero)
        } else {
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: 0))
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                let windowBounds = UIScreen.main.bounds
                let yFix = 375 + windowBounds.height
                let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: CGFloat(yFix))
                concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
            }
            instruction.setTransform(concat, at: CMTime.zero)
            
        }
        
        return instruction
    }
    
    func merge(arrayVideos:[AVAsset], completion:@escaping (URL?, Error?) -> ()) {
        
        let mainComposition = AVMutableComposition()
        let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        //  compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)
        
        let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var insertTime = CMTime.zero
        
        for videoAsset in arrayVideos {
            try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
            try! soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: insertTime)
            
            insertTime = CMTimeAdd(insertTime, videoAsset.duration)
        }
        
        let outputFileURL = URL(fileURLWithPath: NSTemporaryDirectory() + "merge.mp4")
        SharedManager.shared.videoUrlTesting = URL(fileURLWithPath: NSTemporaryDirectory() + "merge.mp4")
        
        let fileManager = FileManager()
        try? fileManager.removeItem(at: outputFileURL)
        
        let exporter = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetMediumQuality)
        
        exporter?.outputURL = outputFileURL
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = true
        
        exporter?.exportAsynchronously {
            if let url = exporter?.outputURL{
                completion(url, nil)
            }
            if let error = exporter?.error {
                completion(nil, error)
            }
        }
    }
    
    private func dwonloadVideoToLocal(videoLink: String, saveToLibrary: Bool, completionHandler: @escaping CompletionHandler) {
  
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: videoLink),
               let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/watermarkVideo.mp4"
                SharedManager.shared.instaVideoLocalPath = filePath
                SharedManager.shared.videoUrlTesting = URL(fileURLWithPath: filePath)
                
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            
                            completionHandler(true)
                            print("Video is saved!")
                        }
                        else {
                            
                            completionHandler(false)
                        }
                    }
                }
            }
        }
    }
}
