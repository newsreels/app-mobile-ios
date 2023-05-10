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
    func pause(shouldContinue: Bool = false) {
        if isPlaying && SharedManager.shared.playingPlayers.count > 0 {
            if let id = reelModel?.id,
               SharedManager.shared.playingPlayers.contains(id) {
                SharedManager.shared.playingPlayers.remove(object: id)
            }
            isPlaying = false
            playerLayer.player?.pause()
            totalDuration = playerLayer.player?.currentDuration
            if !shouldContinue {
                playerLayer.player?.seek(to: .zero)
                playerLayer.player = nil
            }
        }
    }
    
    func play() {
        if !isPlaying && SharedManager.shared.playingPlayers.count < 1  {
            print("will play \(reelModel?.id ?? "")")
            isPlaying = true
            if let id = reelModel?.id,
               !SharedManager.shared.playingPlayers.contains(id) {
                SharedManager.shared.playingPlayers.append(id)
            }
            setImage()
            if self.playerLayer.player == nil,
               let id = reelModel?.id,
               let player = SharedManager.shared.players.first(where: {$0.id == id})?.player,
               player.currentItem != nil, player.currentItem?.bufferDuration != nil{
                playerLayer = AVPlayerLayer(player: player)
            } else if let url = URL(string: reelModel?.media ?? ""),
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
            playerLayer.player?.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: NSKeyValueObservingOptions.new, context: nil)

            playerContainer.layer.addSublayer(playerLayer)
            playerLayer.frame = playerContainer.bounds
            playerContainer.backgroundColor = .clear
            playerLayer.videoGravity = .resize
            playerContainer.layer.masksToBounds = true
            playerLayer.masksToBounds = true
            playerLayer.player?.play()
            imgThumbnailView.layoutIfNeeded()
            if SharedManager.shared.isAudioEnableReels == false {
                playerLayer.player?.volume = 0
                imgSound.image = UIImage(named: "newMuteIC")
            } else {
                playerLayer.player?.volume = 1
                imgSound.image = UIImage(named: "newUnmuteIC")
            }
            
        }
    }
    
    func stopVideo(shouldContinue: Bool = false) {
        if SharedManager.shared.reelsAutoPlay == false {
            viewPlayButton.isHidden = false
        }
        isPlayWhenReady = false
        pause(shouldContinue: shouldContinue)
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
    
    func setPlayer(didFail: Bool = false) {
        if didFail || playerLayer.player == nil {
            ReelsCacheManager.shared.clearCache()
            pause()
            playerLayer.removeFromSuperlayer()
            play()
        }
    }
    
    func stallingHandler() {
        setPlayer(didFail: true)
    }

    func bufferStuckHandler() {
        setPlayer(didFail: true)
    }
}

extension ReelsCC {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let player = object as? AVPlayer {
            self.imgThumbnailView.isHidden = false
            imgThumbnailView?.layoutIfNeeded()
            switch player.timeControlStatus {
            case .playing:
                print("playing \(reelModel?.id ?? "")")
                loadingStartingTime = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.imgThumbnailView.isHidden = true
                }
                DispatchQueue.main.async {
                    if self.loader.isHidden == false {
                        self.loader.isHidden = true
                        self.loader.stopAnimating()
                    }
                    self.loader.stopAnimating()
                        self.hideLoader()
                    ANLoader.hide()
                }
            case .paused:
                if SharedManager.shared.playingPlayers.count > 0 {
                    if let id = reelModel?.id,
                       SharedManager.shared.playingPlayers.contains(id) {
                        SharedManager.shared.playingPlayers.remove(object: id)
                    }
                }
                    isPlaying = false
                
                print("paused \(reelModel?.id ?? "")")
            case .waitingToPlayAtSpecifiedRate:
                if let loadingStartingTime {
                    let endDate = Date()
                    if endDate.timeIntervalSince(loadingStartingTime) > 2 {
                        SharedManager.shared.players.forEach({ item in
                            // Cancel the loading of the player's current asset
                            item.player.currentItem?.cancelPendingSeeks()
                            item.player.currentItem?.asset.cancelLoading()
                        })
                    }
                } else {
                    loadingStartingTime = Date()
                }
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
                    }
                }
            }
        } else if keyPath == #keyPath(AVPlayerItem.status), let playerItem = object as? AVPlayerItem {
            print(playerItem.status)
            switch playerItem.status {
               case .failed:
                   setPlayer(didFail: true)
                   if let error = playerItem.error {
                       print("Player item failed with error: \(error.localizedDescription)")
                   }
               default:
                   break
               }
           }
    }
    
}
