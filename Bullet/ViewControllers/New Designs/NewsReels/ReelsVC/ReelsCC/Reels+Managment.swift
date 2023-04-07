//
//  Reels+Managment.swift
//  Bullet
//
//  Created by Osman Ahmed on 05/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import UIKit
import CoreMedia

extension ReelsCC {
    func pause() {
        player.pause(reason: .hidden)
    }

    func play() {
        setImage()
        if let url = URL(string: reelModel?.media ?? "") {
            player.play(for: url)
            if SharedManager.shared.isAudioEnableReels == false {
                player.volume = 0
                imgSound.image = UIImage(named: "newMuteIC")
            } else {
                player.volume = 1
                imgSound.image = UIImage(named: "newUnmuteIC")
            }
        }
    }

    func stopVideo() {
        print("Stop Video called")
        removeAllCaptions()

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
            player.volume = 0.0
            imgSound.image = UIImage(named: "newMuteIC")
        } else {
            player.volume = 1.0
            imgSound.image = UIImage(named: "newUnmuteIC")
        }

        if player.state != .playing {
            play()
        } else if (player.totalDuration) >= (player.currentDuration) {
            player.seek(to: .zero)
            play()
        }

        SharedManager.shared.performWSToUpdateArticleAnalytics(ArticleId: reelModel?.id ?? "", isFromReel: true)
    }

    func resumeVideoPlay(time: TimeInterval?) {
        viewPlayButton.isHidden = true
        isPlayWhenReady = true
        if SharedManager.shared.isAudioEnableReels == false {
            player.volume = 0.0
            imgSound.image = UIImage(named: "newMuteIC")
        } else {
            player.volume = 1.0
            imgSound.image = UIImage(named: "newUnmuteIC")
        }

        if let time = time {
            player.seek(to: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }

        play()

        removeAllCaptions()
    }
}

extension ReelsCC {
    func loadCaptions(time: Double) {
        if let captions = reelModel?.captions, captions.count > 0 {
            if currTime != time {
                currTime = time
                updateSubTitlesWithTime(currTime: time, captions: captions)
            }
        }
    }

    func removeAllCaptions() {
        if let captionsLabel = captionsArr {
            for label in captionsLabel {
                label.removeFromSuperview()
            }
        }
        if let captionsView = captionsViewArr {
            for view in captionsView {
                view.removeFromSuperview()
            }
        }
        viewSubTitle.subviews.forEach { $0.removeFromSuperview() }
        captionsArr?.removeAll()
        captionsViewArr?.removeAll()

        currTime = -1.0
    }
}
