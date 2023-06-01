//
//  NRPlayer.swift
//  Bullet
//
//  Created by Osman on 02/05/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import AVFoundation
import UIKit

class NRPlayer: AVPlayer {
    var stallingHandler: (() -> Void)?
    var bufferStuckHandler: (() -> Void)?
    var shouldBePlaying = false
    var timer: Timer?
    var reelId: String?
    var cellIndex: IndexPath?
    private var stallingSeconds = 0
    private var bufferWaitingSeconds = 0
    private var bufferFreezeSeconds = 0
    private var disapledBuffering = false
    private var didResetVideo = false
}

extension NRPlayer {
    override func play() {
        if SharedManager.shared.playingPlayers.count > 0 {
            super.play()
            startTimer()
            shouldBePlaying = true
        }
    }
    
    override func pause() {
        super.pause()
        shouldBePlaying = false
    }
    
    override func seek(to time: CMTime) {
        super.seek(to: time)
    }
    
    override func replaceCurrentItem(with item: AVPlayerItem?) {
        self.currentItem?.cancelPendingSeeks()
        self.seek(to: .zero)
        self.pause()
        super.replaceCurrentItem(with: item)
    }
    
    func dispose() {
        pause()
        self.currentItem?.cancelPendingSeeks()
        self.currentItem?.preferredForwardBufferDuration = 0
        self.currentItem?.seek(to: .zero)
        self.replaceCurrentItem(with: nil)
    }
}

extension NRPlayer {
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func endTimer() {
        timer?.invalidate()
    }
    
    @objc func updateTimer() {
        if isStuckWithStaling() || isFreezeWithBuffering() {
            stallingHandler?()
            didResetVideo = true
        }
        if isStuckWithBuffering() {
            bufferStuckHandler?()
        }
        if let cellIndex, let reelId {
            if SharedManager.shared.playingPlayers.contains(reelId),
               SharedManager.shared.currentlyPlayingIndexPath != cellIndex {
                SharedManager.shared.playingPlayers.remove(object: reelId)
                pause()
            }
        }
    }
 
    func isStuckWithStaling() -> Bool { 
        if let cellIndex,
           SharedManager.shared.currentlyPlayingIndexPath == cellIndex,
            self.shouldBePlaying == true,
            (self.currentItem == nil || self.timeControlStatus == .paused) {
            if stallingSeconds > 5 {
                stallingSeconds = 0
                bufferFreezeSeconds = 0
                bufferWaitingSeconds = 0
                return true
            } else {
                stallingSeconds += 1
                return false
            }
        }
        stallingSeconds = 0
        return false
    }
    
    func isFreezeWithBuffering() -> Bool {
        let maxWaiting = didResetVideo ? 5 : 10
        if let cellIndex,
           SharedManager.shared.currentlyPlayingIndexPath == cellIndex,
           self.shouldBePlaying == true
            && bufferFreezeSeconds >= maxWaiting
            && self.timeControlStatus == .waitingToPlayAtSpecifiedRate {
            bufferWaitingSeconds = 0
            stallingSeconds = 0
            bufferFreezeSeconds = 0
            return true
        } else if self.timeControlStatus == .waitingToPlayAtSpecifiedRate {
            bufferFreezeSeconds += 1
            return false
        } else {
            bufferFreezeSeconds = 0
            return false
        }
    }
    func isStuckWithBuffering() -> Bool {
            return false
    }
    
}
