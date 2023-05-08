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
        endTimer()
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
    }
    
    func isStuckWithStaling() -> Bool { 
        if self.shouldBePlaying == true
            && (self.currentItem == nil || self.timeControlStatus == .paused) {
            if stallingSeconds > 3 {
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
        if self.shouldBePlaying == true
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
//        guard disapledBuffering == false else { return false }
//        if self.shouldBePlaying == true
//            && bufferWaitingSeconds >= 3 && self.timeControlStatus == .waitingToPlayAtSpecifiedRate {
//            bufferWaitingSeconds = 0
//            stallingSeconds = 0
//            bufferFreezeSeconds = 0
//            disapledBuffering = true
//            return true
//        } else if self.timeControlStatus == .waitingToPlayAtSpecifiedRate {
//            bufferWaitingSeconds += 1
//            return false
//        } else {
//            bufferWaitingSeconds = 0
            return false
//        }
    }
    
}
