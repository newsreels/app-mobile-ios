//
//  ReelsCropperViewController.swift
//  Bullet
//
//  Created by Faris Muhammed on 23/05/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Photos
import PryntTrimmerView
import AVFoundation

/// A view controller to demonstrate the cropping of a video. Make sure the scene is selected as the initial
// view controller in the storyboard

class ReelsCropperViewController: UIViewController {

    @IBOutlet weak var videoCropView: VideoCropView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var viewScaleContainer: UIView!
    @IBOutlet weak var imgExpand: UIImageView!
    @IBOutlet weak var lblExpand: UILabel!
    @IBOutlet weak var constraintScaleViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var imgPlay: UIImageView!
    
    @IBOutlet weak var viewControls: UIView!
    @IBOutlet weak var viewNavCrop: UIView!
    @IBOutlet weak var viewNavBackButton: UIView!
    
    
    var inputVideo: YPMediaVideo!
    var inputAsset: AVAsset { return AVAsset(url: inputVideo.url!) }
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var didSave: ((YPMediaItem) -> Void)?
    var didCancel: (() -> Void)?
    
    enum cropType: String {
        case type16
        case type9
    }
    
    enum scaleType {
        case normal
        case expanded
    }
    
    struct YPTrimError: Error {
        let description: String
        let underlyingError: Error?
        
        init(_ description: String, underlyingError: Error? = nil) {
            self.description = "TrimVideo: " + description
            self.underlyingError = underlyingError
        }
    }
    let scaleViewNormalWidth: CGFloat = 38
    let scaleViewMaxWidth: CGFloat = 85
    var selectedScaleType: scaleType = .normal
    
    
    // Open as Preview
    var isOpenForPreview = false
    var selectedUploadItem: UploadTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblDuration.isHidden = true
        loadAsset()
        setScaleView(isAnimationRequired: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
        
        setLocalization()
        
        // Add gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPlay))
        tapGesture.delegate = self
        self.videoCropView.addGestureRecognizer(tapGesture)
        
        
        setupPlayer(isPlay: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
        
        setupPlayer(isPlay: true)
        videoCropView.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        imgPlay.isHidden = false
        videoCropView.player?.pause()
        navigationController?.navigationBar.isHidden = false
        
        setSelectedDuration()
        
        stopPlaybackTimeChecker()
    }
    
    
    func setupPlayer(isPlay: Bool) {
        
        if isOpenForPreview {
           
            setUpScaleAspectRatio()
            
//            self.videoCropView.videoScrollView.scrollView.zoomScale = self.selectedUploadItem?.zoomScale ?? 1
            
//            self.videoCropView.videoScrollView.scrollView.contentOffset = self.selectedUploadItem?.contentOffset ?? .zero
//            self.videoCropView.videoScrollView.scrollView.contentInset = UIEdgeInsets(top: self.selectedUploadItem?.contentInsetTop ?? 0, left: self.selectedUploadItem?.contentInsetLeft ?? 0, bottom: self.selectedUploadItem?.contentInsetBottom ?? 0, right: self.selectedUploadItem?.contentInsetRight ?? 0)
//
                
            viewControls.isHidden = true
            viewNavCrop.isHidden = true
            viewNavBackButton.isHidden = false
            
            
            
            
            
            
            viewScaleContainer.isHidden = true
            
            trimmerView.asset = inputAsset
            trimmerView.seek(to: self.selectedUploadItem?.startTime ?? .zero)
            trimmerView.moveLeftHandle(to: self.selectedUploadItem?.startTime ?? .zero)
            trimmerView.moveRightHandle(to: self.selectedUploadItem?.endTime ?? .zero)
            
            if isPlay {
                
                self.trimmerView.seek(to: self.selectedUploadItem?.startTime ?? .zero)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.videoCropView.player?.play()
                    self.imgPlay.isHidden = true
                    
                    self.startPlaybackTimeChecker()
                }
                
            }
            
            videoCropView.isHidden = true
            videoCropView.hideCropBoxBackground()
            self.videoCropView.videoScrollView.scrollView.isUserInteractionEnabled = false
            
            
        } else {
            
            viewControls.isHidden = false
            viewNavCrop.isHidden = false
            viewNavBackButton.isHidden = true
            
            setUpScaleAspectRatio()
            trimmerView.asset = inputAsset
            
            self.videoCropView.videoScrollView.scrollView.isUserInteractionEnabled = false
        }
        
    }
    @objc func didTapPlay() {
        
        
        if videoCropView.player?.isPlaying ?? false {
            
            videoCropView.player?.pause()
            imgPlay.isHidden = false
            
        } else {
            
            videoCropView.player?.play()
            imgPlay.isHidden = true
        }
    }
    
    func setLocalization() {
        
        lblExpand.text = NSLocalizedString("Scale", comment: "")
        btnCancel.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        btnAdd.setTitle(NSLocalizedString("Add", comment: ""), for: .normal)
    }
    
    func loadAsset() {
        
        trimmerView.mainColor = UIColor.white
        trimmerView.handleColor = UIColor.black
        trimmerView.positionBarColor = UIColor.white
        trimmerView.maskColor = .black
        trimmerView.maxDuration = 120//YPConfig.video.trimmerMaxDuration
        trimmerView.minDuration = 1//YPConfig.video.trimmerMinDuration
        
        
        videoCropView.asset = inputAsset
        trimmerView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        setSelectedDuration()
    }
    
    func setSelectedDuration() {
        
        let duration = (trimmerView.endTime?.seconds ?? 1) - (trimmerView.startTime?.seconds ?? 0)
        lblDuration.text = duration.formatFromSeconds()
    }
    
    func setUpScaleAspectRatio() {
        
        guard let track = AVURLAsset(url: inputVideo.url!).tracks(withMediaType: AVMediaType.video).first else { return }
           let size = track.naturalSize.applying(track.preferredTransform)
           let videoSize = CGSize(width: abs(size.width), height: abs(size.height))
        
        videoCropView.hideCropBoxBackground()
        if videoSize.width > videoSize.height {
            
            if isOpenForPreview && (selectedUploadItem?.isVideoScaling ?? false) {
                selectedScaleType = .expanded
                let aspectWidth = (videoCropView.frame.width / videoCropView.frame.height) * 3
                videoCropView.setAspectRatio(CGSize(width: aspectWidth, height: 3), margin: 0, animated: false)
                
                viewScaleContainer.isHidden = true
            } else {
                
                // Landscape
                let aspectWidth = (videoSize.width / videoSize.height) * 3
                videoCropView.setAspectRatio(CGSize(width: aspectWidth, height: 3), margin: 0, animated: false)
                
                viewScaleContainer.isHidden = false
            }
            
        } else {
            // Portait
            let aspectWidth = (videoCropView.frame.width / videoCropView.frame.height) * 3
            videoCropView.setAspectRatio(CGSize(width: aspectWidth, height: 3), margin: 0, animated: false)
            viewScaleContainer.isHidden = true
            
            
        }
        
    }
    
    func setScaleView(isAnimationRequired: Bool) {
        
        viewScaleContainer.layer.cornerRadius = viewScaleContainer.frame.size.height/2
        viewScaleContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        var duration: TimeInterval = .zero
        if isAnimationRequired {
            duration = 0.5
        }
        
        if selectedScaleType == .normal {
            self.imgExpand.image = UIImage(named: "ReelsCropExpand")
            lblExpand.isHidden = true
            UIView.animate(withDuration: duration) {
                self.constraintScaleViewWidth.constant = self.scaleViewNormalWidth
            }
        } else {
            lblExpand.isHidden = false
            self.imgExpand.image = UIImage(named: "ReelsCropExpand")
            UIView.animate(withDuration: duration) {
                self.constraintScaleViewWidth.constant = self.scaleViewMaxWidth
                self.view.layoutIfNeeded()
            } completion: { status in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if self.selectedScaleType == .expanded {
                        UIView.animate(withDuration: duration) {
                            self.constraintScaleViewWidth.constant = self.scaleViewNormalWidth
                            self.view.layoutIfNeeded()
                        } completion: { status in
                            self.imgExpand.image = UIImage(named: "ReelsCropFilled")
                        }
                    }
                }
                                
            }

        }
        
    }
    
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func didTapCancel(_ sender: Any) {
        didCancel?()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func didTapAddVideo(_ sender: Any) {
        
        imgPlay.isHidden = false
        videoCropView.player?.pause()
        //        try? prepareAssetComposition()
        // Save video values for preview
        var videoRatio = videoCropView.aspectRatio
        let view = videoCropView.videoScrollView
        let contentOffset = view.scrollView.contentOffset
        let contentInset = view.scrollView.contentInset
        let zoomScale = view.scrollView.zoomScale
        
        
        if let index = UploadManager.shared.arrayUploads.firstIndex(where: {$0.articleID == UploadManager.shared.editingArticle?.id || $0.taskId == UploadManager.shared.editingPostTaskID}) {
            UploadManager.shared.arrayUploads.remove(at: index)
        }
        
        var uploadStatus = UserUploadStatus.creating_post
        if UploadManager.shared.editingArticle != nil {
            if UploadManager.shared.editingArticle?.status == Constant.newsArticle.ARTICLE_STATUS_DRAFT  {
                uploadStatus = UserUploadStatus.drafted
            }
            else if UploadManager.shared.editingArticle?.status == Constant.newsArticle.ARTICLE_STATUS_PUBLISHED || UploadManager.shared.editingArticle?.status == Constant.newsArticle.ARTICLE_STATUS_SCHEDULED {
                uploadStatus = UserUploadStatus.posted
            }
        }
        
        var isCroppingNeeded = true
        guard let track = AVURLAsset(url: inputVideo.url!).tracks(withMediaType: AVMediaType.video).first else { return }
        let size = track.naturalSize.applying(track.preferredTransform)
        let videoSize = CGSize(width: abs(size.width), height: abs(size.height))
        if videoSize.width < videoSize.height {
            // Portait
            // Cropping not needed for portait reels
            isCroppingNeeded = false
            let aspectWidth = (videoSize.width / videoSize.height) * 3
            videoRatio = CGSize(width: aspectWidth, height: 3)
        }
        
        let uploadTask = UploadTask(startTime: trimmerView.startTime ?? .zero, endTime: trimmerView.endTime ?? (videoCropView.asset?.duration ?? .zero), assetURL: inputVideo.url, aspectRatioWidth: videoCropView.aspectRatio.width, aspectRatioHeight: videoCropView.aspectRatio.height, imageCropFrame: videoCropView.getImageCropFrame(), taskId: UploadManager.shared.generateRandomTaskID(), localURL: isCroppingNeeded ? nil : inputVideo.url, isEditing: nil, task_status: isCroppingNeeded ? .waitingForCropping : .croppingCompleted, userUploadStatus: uploadStatus, uploadType: .reel, articleID: "", sourceID: "", videoRatio: videoRatio, contentOffset: contentOffset, zoomScale: zoomScale, contentInsetLeft: contentInset.left, contentInsetRight: contentInset.right, contentInsetTop: contentInset.top, contentInsetBottom: contentInset.bottom, isVideoScaling: selectedScaleType == .expanded ? true : false)
        
        
        UploadManager.shared.addItemForCropping(uploadTask: uploadTask)
        
        guard let didSave = self.didSave else { return print("Don't have saveCallback") }
        let resultVideo = YPMediaVideo(thumbnail: self.inputVideo.thumbnail,
                                       videoURL: nil,
                                       asset: self.inputVideo.asset, taskID: uploadTask.taskId)
        didSave(YPMediaItem.video(v: resultVideo))
        
        
    }
    
    @IBAction func crop(_ sender: Any) {

//        if let selectedTime = selectThumbView.selectedTime, let asset = videoCropView.asset {
//            let generator = AVAssetImageGenerator(asset: asset)
//            generator.requestedTimeToleranceBefore = CMTime.zero
//            generator.requestedTimeToleranceAfter = CMTime.zero
//            generator.appliesPreferredTrackTransform = true
//            var actualTime = CMTime.zero
//            let image = try? generator.copyCGImage(at: selectedTime, actualTime: &actualTime)
//            if let image = image {
//
//                let selectedImage = UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up)
//                let croppedImage = selectedImage.crop(in: videoCropView.getImageCropFrame())!
//                UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
//            }

//            try? prepareAssetComposition()
//        }

//        try? prepareAssetComposition()
        
    }

    
    @IBAction func didTapScale(_ sender: Any) {
        
        if selectedScaleType == .normal {
            
            selectedScaleType = .expanded
            let aspectWidth = (videoCropView.frame.width / videoCropView.frame.height) * 3
            videoCropView.setAspectRatio(CGSize(width: aspectWidth, height: 3), margin: 0, animated: false)
        } else {
            
            selectedScaleType = .normal
            
            guard let track = AVURLAsset(url: inputVideo.url!).tracks(withMediaType: AVMediaType.video).first else { return }
               let size = track.naturalSize.applying(track.preferredTransform)
               let videoSize = CGSize(width: abs(size.width), height: abs(size.height))
            
            let aspectWidth = (videoSize.width / videoSize.height) * 3
            videoCropView.setAspectRatio(CGSize(width: aspectWidth, height: 3), margin: 0, animated: false)
        }
        
        setScaleView(isAnimationRequired: true)
    }
    
    // MARK: - Top buttons

//    @objc public func save() {
//        guard let didSave = didSave else { return print("Don't have saveCallback") }
//        navigationItem.rightBarButtonItem = YPLoaders.defaultLoader
//
//        do {
//            let asset = AVURLAsset(url: inputVideo.url)
//            let trimmedAsset = try asset
//                .assetByTrimming(startTime: trimmerView.startTime ?? CMTime.zero,
//                                 endTime: trimmerView.endTime ?? inputAsset.duration)
//
//            // Looks like file:///private/var/mobile/Containers/Data/Application
//            // /FAD486B4-784D-4397-B00C-AD0EFFB45F52/tmp/8A2B410A-BD34-4E3F-8CB5-A548A946C1F1.mov
//            let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory())
//                .appendingUniquePathComponent(pathExtension: YPConfig.video.fileType.fileExtension)
//
//            _ = trimmedAsset.export(to: destinationURL) { [weak self] session in
//                switch session.status {
//                case .completed:
//                    DispatchQueue.main.async {
//                        let resultVideo = YPMediaVideo(thumbnail: nil,
//                                                       videoURL: destinationURL,
//                                                       asset: self?.inputVideo.asset)
//                        didSave(YPMediaItem.video(v: resultVideo))
//                    }
//                case .failed:
//                    print("YPVideoFiltersVC Export of the video failed. Reason: \(String(describing: session.error))")
//                default:
//                    print("YPVideoFiltersVC Export session completed with \(session.status) status. Not handled")
//                }
//            }
//        } catch let error {
//            print("💩 \(error)")
//        }
//    }
    
    @objc func cancel() {
        didCancel?()
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
    
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            videoCropView.player?.seek(to: startTime)
            if (videoCropView.player?.isPlaying != true) {
                videoCropView.player?.play()
            }
        }
    }
    
    func startPlaybackTimeChecker() {

        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                        selector:
            #selector(onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }

    func stopPlaybackTimeChecker() {

        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }

    @objc func onPlaybackTimeChecker() {

        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = videoCropView.player else {
            return
        }

        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)

        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            trimmerView.seek(to: startTime)
        }
    }
    
    
    func prepareAssetComposition() throws {

//        guard let asset = videoCropView.asset, let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
//            return
//        }
        ANLoader.showLoading(disableUI: true)
        let asset = try assetByTrimming(startTime: trimmerView.startTime ?? .zero, endTime: trimmerView.endTime ?? (videoCropView.asset?.duration ?? .zero), asset: videoCropView.asset!)
        guard let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
            ANLoader.hide()
            return
        }
        
        let assetComposition = AVMutableComposition()
        let frame1Time = CMTime(seconds: asset.duration.seconds, preferredTimescale: asset.duration.timescale)
        let trackTimeRange = CMTimeRangeMake(start: .zero, duration: frame1Time)

        guard let videoCompositionTrack = assetComposition.addMutableTrack(withMediaType: .video,
                                                                           preferredTrackID: kCMPersistentTrackID_Invalid) else {
            ANLoader.hide()
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

        let renderSize = CGSize(width: 16 * videoCropView.aspectRatio.width * 18,
                                height: 16 * videoCropView.aspectRatio.height * 18)
        let transform = getTransform(for: videoTrack)

        layerInstructions.setTransform(transform, at: CMTime.zero)
        layerInstructions.setOpacity(1.0, at: CMTime.zero)
        mainInstructions.layerInstructions = [layerInstructions]

        //3 Create the main composition and add the instructions

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = renderSize
        videoComposition.instructions = [mainInstructions]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale:     30)

        let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())TrimmedMovie.mp4")
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
                    
                    guard let didSave = self.didSave else { return print("Don't have saveCallback") }
                    let resultVideo = YPMediaVideo(thumbnail: self.inputVideo.thumbnail,
                                                   videoURL: url,
                                                   asset: self.inputVideo.asset, taskID: "")
                    didSave(YPMediaItem.video(v: resultVideo))
                    ANLoader.hide()
                } else {
                    ANLoader.hide()
                    let error = exportSession?.error
                    print("error exporting video \(String(describing: error))")
                }
            }
        })
    }

    private func getTransform(for videoTrack: AVAssetTrack) -> CGAffineTransform {

        let renderSize = CGSize(width: 16 * videoCropView.aspectRatio.width * 18,
                                height: 16 * videoCropView.aspectRatio.height * 18)
        let cropFrame = videoCropView.getImageCropFrame()
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

extension ReelsCropperViewController: ThumbSelectorViewDelegate {

    func didChangeThumbPosition(_ imageTime: CMTime) {
        videoCropView.player?.seek(to: imageTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
}


extension ReelsCropperViewController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        
        videoCropView.player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
//        videoCropView.player?.play()
        startPlaybackTimeChecker()
        
        setSelectedDuration()
        
        lblDuration.isHidden = true
        
    }

    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        imgPlay.isHidden = false
        videoCropView.player?.pause()
        videoCropView.player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        print(duration)
        
        
        setSelectedDuration()
        
        lblDuration.isHidden = false
    }
}


extension ReelsCropperViewController: UIGestureRecognizerDelegate {
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}
