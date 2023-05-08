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
        if SharedManager.shared.playingPlayers.count > 0 {
            if let id = reelModel?.id,
               SharedManager.shared.playingPlayers.contains(id) {
                SharedManager.shared.playingPlayers.remove(object: id)
            }
            playerLayer.player?.pause()
        } 
    }
    
    func play() {
        if SharedManager.shared.playingPlayers.count < 1  {
            print("will play \(reelModel?.id ?? "")")
            if let id = reelModel?.id,
               !SharedManager.shared.playingPlayers.contains(id) {
                SharedManager.shared.playingPlayers.append(id)
            }
            setImage()
            if let id = self.reelModel?.id, let player = SharedManager.shared.players.first(where: {$0.id == id})?.player {
                self.player = player
                playerLayer = AVPlayerLayer(player: player)
            } else if let url = URL(string: reelModel?.media ?? "") {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                playerLayer.player?.automaticallyWaitsToMinimizeStalling = true
                playerItem.preferredMaximumResolution = CGSize(width: 426, height: 240)
                playerItem.preferredPeakBitRate = Double(200000)
                player = NRPlayer(playerItem: playerItem)
                playerLayer = AVPlayerLayer(player: player)
            }
            playerLayer.player?.addObserver(self, forKeyPath: "timeControlStatus", options: NSKeyValueObservingOptions.new, context: nil)
            playerLayer.player?.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: NSKeyValueObservingOptions.new, context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerLayer.player?.currentItem)
            playerLayer.frame = playerContainer.bounds
            playerContainer.backgroundColor = .clear
            playerLayer.videoGravity = .resize
            playerContainer.layer.masksToBounds = true
            playerLayer.masksToBounds = true
            playerContainer.layer.addSublayer(playerLayer)
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
    
    func resetPlayer() {
            ReelsCacheManager.shared.clearDiskCache()
            SharedManager.shared.players.forEach({$0.player.dispose()})
            pause()
            play()
    }
    
    
    func bufferStuckHandler() {
        resetPlayer()
    }
    
    func stallingHandler() {
        resetPlayer()
    }
}

extension ReelsCC {
    func checkPlayerStatus(_ player: NRPlayer) {
        self.imgThumbnailView.isHidden = false
        imgThumbnailView?.layoutIfNeeded()
        switch player.timeControlStatus {
        case .playing:
            print("playing \(reelModel?.id ?? "")")
            loadingStartingTime = nil
            DispatchQueue.main.async {
                self.imgThumbnailView.isHidden = true
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
            playerLayer.player?.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
            playerLayer.player?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerLayer.player?.currentItem)
            
        case .waitingToPlayAtSpecifiedRate:
            if let currentItem = playerLayer.player?.currentItem {
                let timeRange = currentItem.loadedTimeRanges.first?.timeRangeValue
                if let timeRange = timeRange {
                    let bufferDuration = timeRange.duration.seconds
                    print("waitingToPlayAtSpecifiedRate, buffer: \(bufferDuration), currently: \((playerLayer.player?.currentItem?.currentDuration ?? 0))")
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if self.playerLayer.player?.timeControlStatus == .waitingToPlayAtSpecifiedRate  {
                    self.imgThumbnailView.isHidden = false
                    self.loader.isHidden = false
                    self.loader.startAnimating()
                }
            }
        @unknown default:
            self.imgThumbnailView.isHidden = false
            imgThumbnailView?.layoutIfNeeded()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            if keyPath == "timeControlStatus", let player = object as? NRPlayer {
                self.checkPlayerStatus(player)
            } else if keyPath == #keyPath(AVPlayerItem.status), let playerItem = object as? AVPlayerItem {
                switch playerItem.status {
                case .failed:
                    self.resetPlayer()
                    if let error = playerItem.error {
                        print("Player item failed with error: \(error.localizedDescription)")
                    }
                default:
                    break
                }
            }
        }
    }
    
}
