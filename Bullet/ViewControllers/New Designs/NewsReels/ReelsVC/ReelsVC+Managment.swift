//
//  ReelsVC+Managment.swift
//  Bullet
//
//  Created by Osman Ahmed on 05/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import DataCache
import GSPlayer
import UIKit
import AVFoundation

extension ReelsVC {
    func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillLoadForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tabBarTapped(notification:)), name: Notification.Name.notifyReelsTabBarTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reelsOrientationChange), name: NSNotification.Name.notifyOrientationChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeReelsDataLanguage), name: .SwiftUIDidChangeLanguage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataFromBG), name: NSNotification.Name(rawValue: "OpenedFromBackground"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.notifyGetPushNotificationArticleData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getArticleDataPayLoad), name: NSNotification.Name.notifyGetPushNotificationArticleData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getArticleDataPayLoad), name: NSNotification.Name.notifyGetPushNotificationToReelsView, object: nil)
    }
}

extension ReelsVC {
    func pauseCellVideo(indexPath: IndexPath?) {
        if let indexPath = indexPath, let cell = collectionView.cellForItem(at: indexPath) as? ReelsCC {
            cell.pause()
        }
    }
    
    func pauseVideo() {
        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            cell.pause()
        }
    }
    
    func disposeVideo() {
        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            cell.disposeVideo()
        }
    }

    func resumeVideo(time: TimeInterval?) {
        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            cell.resumeVideoPlay(time: time)
        }
    }

    func playNextCellVideo(indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        } completion: { _ in
            if let _ = self.collectionView.cellForItem(at: indexPath) as? ReelsCC {
                self.currentlyPlayingIndexPath = indexPath
                if SharedManager.shared.reelsAutoPlay {
                    self.playCurrentCellVideo()
                }
                self.sendVideoViewedAnalyticsEvent()
            } else if let cell = self.collectionView.cellForItem(at: indexPath) as? ReelsPhotoAdCC {
                self.currentlyPlayingIndexPath = indexPath
                cell.fetchAds(viewController: self)
            }
        }
    }

    func playCurrentCellVideo(isFromBackground: Bool = false) {
        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC,
           let id = cell.reelModel?.id,
           !SharedManager.shared.playingPlayers.contains(id) {
 
            if let player = SharedManager.shared.players.first(where: {$0.id == reelsArray[currentlyPlayingIndexPath.item].id ?? ""})?.player, player.currentItem != nil {
                cell.playerLayer = AVPlayerLayer(player: player)
            }
//            if !isFromBackground {
//                cell.playerLayer.player?.seek(to: .zero)
//            }
            cell.play()
        } else if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsPhotoAdCC {
            cell.fetchAds(viewController: self)
        }

        delegate?.currentPlayingVideoChanged(newIndex: currentlyPlayingIndexPath)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.adjustCellScrollPostion()
        }
        if currentlyPlayingIndexPath.row < reelsArray.count {
            if !reelsArray.isEmpty, let reelID = reelsArray[currentlyPlayingIndexPath.row].id {
                SharedManager.shared.performWSToUpdateArticleAnalytics(ArticleId: reelID, isFromReel: true)
            }
        }
    }
}

extension ReelsVC {
    func isBackgroundRefreshRequired() -> Bool {
        if SharedManager.shared.minutesBetweenDates(SharedManager.shared.lastBackgroundTimeReels ?? Date(), Date()) >= reelsRefreshTimeNeeded, reelsArray.count > 0 {
            if SharedManager.shared.tabBarIndex == 0, isShowingProfileReels == false, isFromChannelView == false {
                return true
            }
        }

        return false
    }

    func didTapNotifications() {
        stopVideo()
        isViewControllerVisible = false

        let vc = NotificationsListVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        vc.delegate = self
        present(nav, animated: true, completion: nil)
    }

    func didTapFilter(isTabNeeded: Bool) {
        stopVideo()
        isViewControllerVisible = false

        let vc = ForYouPreferencesVC.instantiate(fromAppStoryboard: .Reels)
        vc.preferenceType = .reels
        vc.delegate = self
        vc.currentSelection = isOnFollowing ? 1 : 0
        vc.isOpenReels = true
        vc.isReelsTabNeeded = isTabNeeded
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }

    func openFollowingPrefernce() {
        stopVideo()
        isViewControllerVisible = false

        let vc = FollowingPreferenceVC.instantiate(fromAppStoryboard: .Reels)
        vc.delegate = self
        vc.hasReels = true
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen

        isOpenedFollowingPrefernce = true
        present(nav, animated: true, completion: nil)
    }

    func adjustCellScrollPostion() {
        if isCurrentlyScrolling == false, currentlyPlayingIndexPath.item < reelsArray.count {
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: currentlyPlayingIndexPath, at: .centeredVertically, animated: false)
        }
    }
}

extension ReelsVC {
    func callWebsericeToGetNextVideos() {
        if isApiCallAlreadyRunning == false {
            if !nextPageData.isEmpty {
                performWSToGetReelsData(page: nextPageData, contextID: SharedManager.shared.curReelsCategoryId)
            }
        }
    }


    func getCurrentVisibleIndexPlayVideo() {
        // Stop Old cell

        isFirstVideo = false
        var newIndexDetected = false
        // Play latest cell
        for cell in collectionView.visibleCells {
            let cellRect = cell.contentView.convert(cell.contentView.bounds, to: UIScreen.main.coordinateSpace)
            if cellRect.origin.x == 0, cellRect.origin.y == 0, let indexPath = collectionView.indexPath(for: cell) {
                // Visible cell
                if currentlyPlayingIndexPath != indexPath {
                    currentlyPlayingIndexPath = indexPath
                    if SharedManager.shared.reelsAutoPlay {
                        playCurrentCellVideo()
                    }
                    sendVideoViewedAnalyticsEvent()
                    newIndexDetected = true
                }
            } else {
                let indexPath = collectionView.indexPath(for: cell)
                pauseCellVideo(indexPath: indexPath)
            }
        }

        if newIndexDetected == false {
            if let cell = collectionView.visibleCells.first, let indexPath = collectionView.indexPath(for: cell) {
                if currentlyPlayingIndexPath != indexPath {
                    currentlyPlayingIndexPath = indexPath
                    if SharedManager.shared.reelsAutoPlay {
                        playCurrentCellVideo()
                    }
                    sendVideoViewedAnalyticsEvent()
                    
                }
            }
        }

    }
}

extension ReelsVC {
   @objc func stopAllPlayers() {
       DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
           for section in 0..<self.collectionView.numberOfSections {
               for item in 0..<self.collectionView.numberOfItems(inSection: section) {
                   let indexPath = IndexPath(item: item, section: section)
                   if let cell = self.collectionView.cellForItem(at: indexPath) as? ReelsCC {
                       cell.stopVideo()
                   }
               }
           }
        }
    }
    
    func pauseAllPlayers() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for section in 0..<self.collectionView.numberOfSections {
                for item in 0..<self.collectionView.numberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? ReelsCC {
                        cell.pause()
                    }
                }
            }
         }
     }
    
    @objc func handlePlaybackInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo, let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt, let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        switch type {
        case .began:
            stopAllPlayers()
        case .ended:
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    (
                        collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC
                    )?.resetPlayer()
                    playCurrentCellVideo(isFromBackground: true)
                }
            }
        }
    }
}
