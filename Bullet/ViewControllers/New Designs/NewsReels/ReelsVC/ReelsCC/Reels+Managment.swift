//
//  Reels+Managment.swift
//  Bullet
//
//  Created by Osman Ahmed on 05/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import UIKit
import CoreMedia
import AVFoundation

extension ReelsCC {
    func pause() {
        if isPlaying {
            isPlaying = false
            playerLayer.player?.pause()
        }
    }
    
    func play() {
        if !isPlaying {
            isPlaying = true
            setImage()
            if let url = URL(string: reelModel?.media ?? ""),
               playerLayer.player == nil {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                playerLayer.player?.automaticallyWaitsToMinimizeStalling = true
                playerItem.preferredMaximumResolution = CGSize(width: 426, height: 240)
                playerItem.preferredPeakBitRate = Double(200000)
                let player = AVPlayer(playerItem: playerItem)
                playerLayer = AVPlayerLayer(player: player)
            }
            
            playerLayer.player?.addObserver(self, forKeyPath: "timeControlStatus", options: NSKeyValueObservingOptions.new, context: nil)
            playerContainer.frame = CGRectMake(0, 0, viewContent.frame.size.width, viewContent.frame.size.height)
            playerContainer.layer.addSublayer(playerLayer)
            playerLayer.frame = playerContainer.bounds
            playerContainer.backgroundColor = .clear
            playerLayer.player?.play()
            if SharedManager.shared.isAudioEnableReels == false {
                playerLayer.player?.volume = 0
                imgSound.image = UIImage(named: "newMuteIC")
            } else {
                playerLayer.player?.volume = 1
                imgSound.image = UIImage(named: "newUnmuteIC")
            }
            
        }
    }
    
    func stopVideo() {
        if SharedManager.shared.reelsAutoPlay == false {
            viewPlayButton.isHidden = false
        }
        isPlayWhenReady = false
        pause()
        viewTransparentBG.isHidden = true
        isFullText = false
        currTime = -1
    }
    
    func PauseVideo() {
        isPlayWhenReady = false
    }
    
    func playVideo() {
        setFollowButton(hidden: reelModel?.source?.favorite ?? false)
        viewPlayButton.isHidden = true
        isPlayWhenReady = true
        if SharedManager.shared.isAudioEnableReels == false {
            playerLayer.player?.volume = 0.0
            imgSound.image = UIImage(named: "newMuteIC")
        } else {
            playerLayer.player?.volume = 1.0
            imgSound.image = UIImage(named: "newUnmuteIC")
        }
        
        if !(playerLayer.player?.isPlaying ?? false) {
            play()
        } else if (playerLayer.player?.totalDuration ?? 0) >= (playerLayer.player?.currentDuration ?? 0) {
            playerLayer.player?.seek(to: .zero)
            play()
        }
        
        SharedManager.shared.performWSToUpdateArticleAnalytics(ArticleId: reelModel?.id ?? "", isFromReel: true)
    }
    
    func resumeVideoPlay(time: TimeInterval?) {
        viewPlayButton.isHidden = true
        isPlayWhenReady = true
        if SharedManager.shared.isAudioEnableReels == false {
            playerLayer.player?.volume = 0.0
            imgSound.image = UIImage(named: "newMuteIC")
        } else {
            playerLayer.player?.volume = 1.0
            imgSound.image = UIImage(named: "newUnmuteIC")
        }
        
        if let time = time {
            playerLayer.player?.seek(to: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }
        
        play()
    }
}

extension ReelsCC {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let player = object as? AVPlayer {
            switch player.timeControlStatus {
            case .playing:
                print("playing \(reelModel?.id ?? "")")
                if SharedManager.shared.playingVideos.count > 1 {
                    delegate?.stopPrevious(cell: self)
                    guard let id = reelModel?.id else { return }
                    SharedManager.shared.playingVideos.append(id)
                }
                if let id = reelModel?.id, !SharedManager.shared.playingVideos.contains(id) {
                    SharedManager.shared.playingVideos.append(id)
                }
                
                
                DispatchQueue.main.async {
                    self.imgThumbnailView.isHidden = false
                    if self.loader.isHidden == false {
                        self.loader.isHidden = true
                        self.loader.stopAnimating()
                    }
                    self.loader.stopAnimating()
                        self.hideLoader()
                    ANLoader.hide()
                }
            case .paused:
                print("paused \(reelModel?.id ?? "")")
                if let id = reelModel?.id, SharedManager.shared.playingVideos.contains(id) {
                    SharedManager.shared.playingVideos.remove(object: id)
                }
            case .waitingToPlayAtSpecifiedRate:
                if let currentItem = playerLayer.player?.currentItem {
                    let timeRange = currentItem.loadedTimeRanges.first?.timeRangeValue
                    if let timeRange = timeRange {
                        let bufferDuration = timeRange.duration.seconds
                        print("waitingToPlayAtSpecifiedRate, buffer: \(bufferDuration), currently: \((playerLayer.player?.currentItem?.currentDuration ?? 0))")
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if self.playerLayer.player?.timeControlStatus == .waitingToPlayAtSpecifiedRate  {
                        self.imgThumbnailView.isHidden = false
                        self.loader.isHidden = false
                        self.loader.startAnimating()
//                        self.hideLoader()
                    }
                }
            }
        }
    }
    
}
