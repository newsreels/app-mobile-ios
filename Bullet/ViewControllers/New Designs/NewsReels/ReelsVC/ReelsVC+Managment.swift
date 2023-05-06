//
//  ReelsVC+Managment.swift
//  Bullet
//
//  Created by Osman Ahmed on 05/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import GSPlayer
import UIKit
import DataCache

extension ReelsVC {
    func setReels() {
        if !isSugReels && isShowingProfileReels == false && isFromChannelView == false {
            // do something in background
            let killTime = SharedManager.shared.refreshReelsOnKillApp ?? Date()
            let interval = Date().timeIntervalSince(killTime)
            let minutes = (interval / 60).truncatingRemainder(dividingBy: 60)

            if !isBackButtonNeeded {
                SharedManager.shared.hideLaoderFromWindow()
                var FullResponse: ReelsModel?
                if isOnFollowing {
                    FullResponse = try? DataCache.instance.readCodable(forKey: Constant.CACHE_REELS_Follow)
                } else {
                    FullResponse = try? DataCache.instance.readCodable(forKey: Constant.CACHE_REELS)
                }

                if let reels = FullResponse?.reels, reels.count > 0, minutes < Double(reelsRefreshTimeNeeded) {
                    reelsArray = reels
                    nextPageData = FullResponse?.meta?.next ?? ""

                    if SharedManager.shared.adsAvailable, SharedManager.shared.adUnitReelID != "" {
                        // LOAD ADS
                        reelsArray.removeAll { $0.iosType == Constant.newsArticle.ARTICLE_TYPE_ADS }
                        reelsArray = reelsArray.adding(Reel(id: "", context: "", reelDescription: "", media: "", media_landscape: "", mediaMeta: nil, publishTime: "", source: nil, info: nil, authors: nil, captions: nil, image: "", status: "", iosType: Constant.newsArticle.ARTICLE_TYPE_ADS, nativeTitle: true), afterEvery: SharedManager.shared.adsInterval)
                    }
                    collectionView.reloadData()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if self.isViewControllerVisible == false {
                            return
                        }
                        if self.isRightMenuLoaded {
                            return
                        }
                        self.sendVideoViewedAnalyticsEvent()
                        if SharedManager.shared.reelsAutoPlay {
                            self.playCurrentCellVideo()
                            // Force play
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if self.isViewControllerVisible == false {
                                    return
                                }
                                if self.isRightMenuLoaded {
                                    return
                                }
                                if self.currentlyPlayingIndexPath.item == 0 {
                                    self.playCurrentCellVideo()
                                }
                            }
                        }

                        if SharedManager.shared.isAppLaunchedThroughNotification {
                            self.stopVideo()
                            SharedManager.shared.isAppLaunchedThroughNotification = false
                            NotificationCenter.default.post(name: Notification.Name.notifyGetPushNotificationArticleData, object: nil, userInfo: nil)
                        }
                    }

                    for obj in reelsArray {
                        SharedManager.shared.saveAllVideosThumbnailsToCache(imageURL: obj.image ?? "")
                    }
                } else {
                    if SharedManager.shared.isFirstimeSplashScreenLoaded == false {
                        SharedManager.shared.isFirstimeSplashScreenLoaded = true
                        SharedManager.shared.showLoaderInWindow()
                    }
                    perform(#selector(autohideloader), with: nil, afterDelay: 5)
                    if SharedManager.shared.reelsContextNotification != "" {
                        performWSToGetReelsData(page: "", contextID: SharedManager.shared.reelsContextNotification)
                    } else {
                        performWSToGetReelsData(page: "", contextID: contextID)
                    }
                }
            } else {
                ReelsCacheManager.shared.clearDiskCache()
                currentCachePosition = 1
                cacheLimit = 10
                if SharedManager.shared.reelsContextNotification != "" {
                    performWSToGetReelsData(page: "", contextID: SharedManager.shared.reelsContextNotification)
                } else {
                    performWSToGetReelsData(page: "", contextID: contextID)
                }
            }
        } else {
            ReelsCacheManager.shared.clearDiskCache()
            currentCachePosition = 1
            cacheLimit = 10 
            viewWillLayoutSubviews()
            collectionView.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.collectionView.isUserInteractionEnabled = true
                if self.isViewControllerVisible == false {
                    return
                }
                if self.isRightMenuLoaded {
                    return
                }
                self.currentlyPlayingIndexPath = self.userSelectedIndexPath
                self.sendVideoViewedAnalyticsEvent()

                print("REELS AUTO PLAY EWA 2= \(SharedManager.shared.reelsAutoPlay)")

                if SharedManager.shared.reelsAutoPlay {
                    self.playCurrentCellVideo()
                }
            }
        }
    }
    
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
            print("video paused index after", indexPath.item)

            cell.stopVideo()
        }
    }

    func pauseVideo() {
        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            cell.pause()
        }
    }

    func resumeVideo(time: TimeInterval?) {
        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            cell.resumeVideoPlay(time: time)
        }
    }

    func playNextCellVideo(indexPath: IndexPath) {
        getCaptionsFromAPI()

        UIView.animate(withDuration: 0.5) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        } completion: { _ in
            if let cell = self.collectionView.cellForItem(at: indexPath) as? ReelsCC {
                self.currentlyPlayingIndexPath = indexPath
                if SharedManager.shared.reelsAutoPlay {
                    cell.playVideo()
                }
                self.sendVideoViewedAnalyticsEvent()
            } else if let cell = self.collectionView.cellForItem(at: indexPath) as? ReelsPhotoAdCC {
                self.currentlyPlayingIndexPath = indexPath
                cell.fetchAds(viewController: self)
            }
        }
    }

    func playCurrentCellVideo() {
        getCaptionsFromAPI()

        if SharedManager.shared.isGuestUser == false, SharedManager.shared.isUserSetup == false, isViewControllerVisible {}

        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            print("video played at index", currentlyPlayingIndexPath)
            if cell.player.timeControlStatus != .playing {
                cell.play()
            } else {
                DispatchQueue.main.async {
                    cell.loader.isHidden = true
                    cell.loader.stopAnimating()
                }
            }

        } else if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsPhotoAdCC {
            print("video played at index", currentlyPlayingIndexPath)
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
    func check() {
        checkPreload()
        checkPlay()
    }

    func checkPreload() {
        let urls = reelsArray.filter { $0.media != nil && !($0.media?.isEmpty ?? true) }
            .suffix(2)

        VideoPreloadManager.shared.set(waiting: urls.map { URL(string: $0.media!)! })
    }

    func checkPlay() {
        let visibleCells = collectionView.visibleCells.compactMap { $0 as? ReelsCC }

        guard visibleCells.count > 0 else { return }

        let visibleFrame = CGRect(x: 0, y: collectionView.contentOffset.y, width: collectionView.bounds.width, height: collectionView.bounds.height)

        let visibleCell = visibleCells
            .filter { visibleFrame.intersection($0.frame).height >= $0.frame.height / 2 }
            .first

        if SharedManager.shared.bulletsAutoPlay {
            visibleCell?.play()
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
        if isCurrentlyScrolling == false {
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
    
    func getCaptionsFromAPI() {
        if reelsArray.count < currentlyPlayingIndexPath.item || reelsArray.count == 0 {
            return
        }
        if (reelsArray[currentlyPlayingIndexPath.item].captions?.count ?? 0) == 0 {
            performWSToGetReelsCaptions(id: reelsArray[currentlyPlayingIndexPath.item].id ?? "")

            // Force check api response loaded after 1 sec, if not recieved call api again
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.reelsArray.count > self.currentlyPlayingIndexPath.item {
                    if self.reelsArray[self.currentlyPlayingIndexPath.item].captionAPILoaded == false {
                        self.performWSToGetReelsCaptions(id: self.reelsArray[self.currentlyPlayingIndexPath.item].id ?? "")
                    }
                }
            }
        }

        let nextIndex = currentlyPlayingIndexPath.item + 1
        if reelsArray.count > nextIndex {
            if (reelsArray[nextIndex].captions?.count ?? 0) == 0 {
                performWSToGetReelsCaptions(id: reelsArray[nextIndex].id ?? "")
            }
        }
        let thirdIndex = currentlyPlayingIndexPath.item + 2
        if reelsArray.count > thirdIndex {
            if (reelsArray[thirdIndex].captions?.count ?? 0) == 0 {
                performWSToGetReelsCaptions(id: reelsArray[thirdIndex].id ?? "")
            }
        }
    }

    func getCurrentVisibleIndexPlayVideo() {
        let prevsIndex = currentlyPlayingIndexPath
        var newIndexDetected = false
        isFirstVideo = false
        // Play latest cell
        for cell in collectionView.visibleCells {
            let cellRect = cell.contentView.convert(cell.contentView.bounds, to: UIScreen.main.coordinateSpace)
            if cellRect.origin.x == 0, cellRect.origin.y == 0, let indexPath = collectionView.indexPath(for: cell) {
                // Visible cell

                currentlyPlayingIndexPath = indexPath
                if SharedManager.shared.reelsAutoPlay {
                    playCurrentCellVideo()
                }
                sendVideoViewedAnalyticsEvent()
                newIndexDetected = true
            } else {
                let indexPath = collectionView.indexPath(for: cell)
                pauseCellVideo(indexPath: indexPath)
            }
        }

        if newIndexDetected == false {
            print("index not detected, last index is,", currentlyPlayingIndexPath)
            if let cell = collectionView.visibleCells.first, let indexPath = collectionView.indexPath(for: cell) {
                currentlyPlayingIndexPath = indexPath
                if SharedManager.shared.reelsAutoPlay {
                    playCurrentCellVideo()
                }
                sendVideoViewedAnalyticsEvent()
            }
        }
        // Stop Old cell
        if prevsIndex != currentlyPlayingIndexPath {
            if reelsArray.count == 0 {
                return
            }
            if let prevCell = collectionView.cellForItem(at: prevsIndex) as? ReelsCC {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelsDurationEvent, eventDescription: "", article_id: reelsArray[prevsIndex.item].id ?? "", duration: prevCell.player.totalDuration.formatToMilliSeconds())
            }

            pauseCellVideo(indexPath: prevsIndex)
        }
    }
}
