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
            if let url = URL(string: reelModel?.media ?? "") {
                //2. Create AVPlayer object
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                
                // set preferredMaximumResolution to stream only the 240p resolution
                // set preferred resolution for 240p
                playerItem.preferredMaximumResolution = CGSize(width: 426, height: 240)
                
                // set preferred bitrate for 240p resolution
                playerItem.preferredPeakBitRate = Double(200000)
                
                //3. Create AVPlayerLayer object
                if playerLayer.player != nil {
                    playerLayer.player?.replaceCurrentItem(with: playerItem)
                } else {
                    let player = AVPlayer(playerItem: playerItem)
                    playerLayer = AVPlayerLayer(player: player)
                }
                playerLayer.player?.automaticallyWaitsToMinimizeStalling = true
                playerLayer.videoGravity = .resizeAspectFill
                playerLayer.player?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
                playerLayer.player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
                playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
                playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
                playerItem.addObserver(self, forKeyPath: "playbackBufferFull", options: NSKeyValueObservingOptions.new, context: nil)
                playerContainer.frame = CGRectMake(0, 0, viewContent.frame.size.width, viewContent.frame.size.height)
                playerContainer.layer.addSublayer(playerLayer)
                playerLayer.frame = playerContainer.bounds
                playerContainer.backgroundColor = .clear
                //5. Play Video
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
    }

    func stopVideo() {
        if SharedManager.shared.reelsAutoPlay == false {
            viewPlayButton.isHidden = false
        }
        isPlayWhenReady = false
        pause()

        viewTransparentBG.isHidden = true
        isFullText = false
        setSeeMoreLabel()

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
        
        if object is AVPlayerItem {
            if let player = playerLayer.player, let currentItem = player.currentItem {
                let timeRange = currentItem.loadedTimeRanges.first?.timeRangeValue
                let bufferStart = timeRange?.start.seconds ?? 0
                let bufferDuration = timeRange?.duration.seconds ?? 0
                let bufferEnd = bufferStart + bufferDuration
                let bufferTime = bufferEnd - player.currentTime().seconds
                if bufferTime > 2 {
                    DispatchQueue.main.async {
                        self.imgThumbnailView.isHidden = false
                        if self.loader.isHidden == false {
                            self.loader.isHidden = true
                            self.loader.stopAnimating()
                        }
                        self.loader.stopAnimating()
                        self.hideLoader()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.imgThumbnailView.isHidden = false
                        self.loader.isHidden = false
                        self.loader.startAnimating()
                        self.hideLoader()
                    }
                }
                print("Buffer Time: \(bufferTime)")
            }
 

            
//                        switch keyPath {
//
//            case "playbackBufferEmpty":
//                // Show loader
//                DispatchQueue.main.async {
//                    self.imgThumbnailView.isHidden = false
//                        self.loader.isHidden = false
//                        self.loader.startAnimating()
//                }
//
//            case "playbackLikelyToKeepUp":
//                            // Show loader
//                            DispatchQueue.main.async {
//                                self.imgThumbnailView.isHidden = false
//                                    self.loader.isHidden = false
//                                    self.loader.startAnimating()
//                            }
//            case "playbackBufferFull":
//                // Hide loader
//                DispatchQueue.main.async {
//                    self.imgThumbnailView.isHidden = false
//                    if self.loader.isHidden == false {
//                        self.loader.isHidden = true
//                        self.loader.stopAnimating()
//                    }
//                    self.loader.stopAnimating()
//                    self.hideLoader()
//                }
//            default:
//                break
//            }
        }
    }
    
}
