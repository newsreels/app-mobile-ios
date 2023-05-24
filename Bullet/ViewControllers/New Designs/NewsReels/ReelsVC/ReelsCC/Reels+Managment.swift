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
                (playerLayer.player as? NRPlayer)?.endTimer()
                imgThumbnailView.isHidden = false
                playerLayer.player = nil
            }
        }
    }
    
    func play() {
        if !isPlaying && SharedManager.shared.playingPlayers.count < 1  {
            NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerLayer.player?.currentItem)
            isPlayerEnded = false
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
               player.currentItem != nil, player.currentItem?.bufferDuration != nil {
                playerLayer = AVPlayerLayer(player: player)
            } else if let url = URL(string: reelModel?.media ?? ""),
               playerLayer.player == nil {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                playerLayer.player?.automaticallyWaitsToMinimizeStalling = true
                playerItem.preferredMaximumResolution = CGSize(width: 426, height: 240)
                playerItem.preferredPeakBitRate = Double(200000)
                let player = NRPlayer(playerItem: playerItem)
                playerLayer = AVPlayerLayer(player: player)
            }
            
            playerLayer.player?.addObserver(self, forKeyPath: "timeControlStatus", options: NSKeyValueObservingOptions.new, context: nil)
            playerLayer.player?.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: NSKeyValueObservingOptions.new, context: nil)

            playerContainer.layer.addSublayer(playerLayer)
            playerLayer.frame = playerContainer.bounds
            playerContainer.backgroundColor = .clear
            playerLayer.videoGravity = .resizeAspectFill
            playerContainer.layer.masksToBounds = true
            playerLayer.masksToBounds = true
            playerLayer.player?.play()
            self.seekBarTotalDurationLabelValue = (self.playerLayer.player?.totalDuration ?? 0)
            playerLayer.player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 5), queue: DispatchQueue.main) { [weak self] time in
                guard let self = self else { return }
                let currentTime = CMTimeGetSeconds(time)
                self.seekBar.setValue(Float(currentTime / (self.playerLayer.player?.totalDuration ?? 0)), animated: true)
                self.seekBarTotalDurationLabelValue = (self.playerLayer.player?.totalDuration ?? 0)
                self.seekBarCurrentDurationLabelValue = currentTime
            }
            seekBar.addTarget(self, action: #selector(seekBarTouchDown), for: .touchDown)
            seekBar.addTarget(self, action: #selector(seekBarTouchUpInside), for: .touchUpInside)
            imgThumbnailView.layoutIfNeeded()
            if let collectionView = superview as? UICollectionView,
               let index = collectionView.indexPath(for: self) {
                (playerLayer.player as? NRPlayer)?.cellIndex = index
            }
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
    @objc func seekBarTouchDown() {
        self.isSeeking = true
        self.seekBar.updateState()
    }

    @objc func seekBarTouchUpInside() {
        self.seekBar.updateState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isSeeking = false
        }
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.imgThumbnailView.isHidden = true
                }
                DispatchQueue.main.async {
                    if self.loader.isHidden == false {
                        self.loader.isHidden = true
                        self.loader.stopAnimating()
                    }
                    self.loader.stopAnimating()
                    if !self.isSeeking {
                        self.hideLoader()
                    }
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
                if isSeeking {
                        self.imgThumbnailView.isHidden = false
                        self.loader.isHidden = false
                        self.loader.startAnimating()
                }
                print("paused \(reelModel?.id ?? "")")
            case .waitingToPlayAtSpecifiedRate:
                if let currentItem = playerLayer.player?.currentItem {
                    let timeRange = currentItem.loadedTimeRanges.first?.timeRangeValue
                    if let timeRange = timeRange {
                        let bufferDuration = timeRange.duration.seconds
                        print("waitingToPlayAtSpecifiedRate, buffer: \(bufferDuration), currently: \((playerLayer.player?.currentItem?.currentDuration ?? 0))")
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.playerLayer.player?.timeControlStatus == .waitingToPlayAtSpecifiedRate &&
                        self.playerLayer.player?.currentDuration ?? 0 < 5  {
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
