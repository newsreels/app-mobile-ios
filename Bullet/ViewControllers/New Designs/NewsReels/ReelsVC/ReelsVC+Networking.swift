//
//  ReelsVC+Networking.swift
//  Bullet
//
//  Created by Osman Ahmed on 05/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import DataCache
import Foundation
import Photos
import Reachability

extension ReelsVC {
    func getReelsCategories() {
        // This should be done in a View Model manner, but this will be refactored later on.
        // Quick fix only
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/home?type=reels", method: .get, parameters: nil, headers: token, withSuccess: { response in

            do {
                let FULLResponse = try
                    JSONDecoder().decode(subCategoriesDC.self, from: response)

                if let homeData = FULLResponse.data {
                    // write Cache Codable types object
                    do {
                        try DataCache.instance.write(codable: homeData, forKey: Constant.CACHE_HOME_TOPICS)
                    } catch {
                        print("Write error \(error.localizedDescription)")
                    }

                    SharedManager.shared.reelsCategories = homeData

                    if SharedManager.shared.curReelsCategoryId == "" {
                        SharedManager.shared.curReelsCategoryId = SharedManager.shared.reelsCategories.first?.id ?? ""
                    }
                }
            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/home?type=reels", error: jsonerror.localizedDescription, code: "")
            }

        }) { _ in

            print("Faeild to get reels categories")
        }
    }

    func performWSToGetReelsCaptions(id: String) {
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let url = "news/reels/\(id)/captions"

        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { [weak self] response in
            do {
                let FULLResponse = try
                    JSONDecoder().decode(subTitlesDC.self, from: response)

                guard let self = self else {
                    return
                }

                if let captions = FULLResponse.captions, captions.count > 0 {
                    if let selectedIndex = self.reelsArray.firstIndex(where: { $0.id ?? "" == id }) {
                        if (self.reelsArray[selectedIndex].captionAPILoaded ?? false) == false {
                            self.reelsArray[selectedIndex].captions = captions
                            self.reelsArray[selectedIndex].captionAPILoaded = true

                            if let cell = self.collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? ReelsCC {
                                cell.reelModel?.captionAPILoaded = true
                                cell.reelModel?.captions = captions
                            }
                            return
                        }
                    }
                } else {
                    // No captions
                    if let selectedIndex = self.reelsArray.firstIndex(where: { $0.id ?? "" == id }) {
                        self.reelsArray[selectedIndex].captionAPILoaded = true
                        if let cell = self.collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? ReelsCC {
                            cell.reelModel?.captionAPILoaded = true
                        }
                    }
                }

            } catch let jsonerror {
                print("error parsing json objects \(url) \n", jsonerror)
                guard let self = self else {
                    return
                }
                // No captions
                if let selectedIndex = self.reelsArray.firstIndex(where: { $0.id ?? "" == id }) {
                    self.reelsArray[selectedIndex].captionAPILoaded = true
                    if let cell = self.collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? ReelsCC {
                        cell.reelModel?.captionAPILoaded = true
                    }
                }
            }
        }) { error in

            print("error parsing json objects", error)
            // No captions
            if let selectedIndex = self.reelsArray.firstIndex(where: { $0.id ?? "" == id }) {
                self.reelsArray[selectedIndex].captionAPILoaded = true
                if let cell = self.collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? ReelsCC {
                    cell.reelModel?.captionAPILoaded = true
                }
            }
        }
    }
}

extension ReelsVC {
    func sendVideoViewedAnalyticsEvent() {
        if reelsArray.count > 0, reelsArray.count > currentlyPlayingIndexPath.item {
            let content = reelsArray[currentlyPlayingIndexPath.item]
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelViewed, eventDescription: "", article_id: content.id ?? "")
        }
    }

    func checkInternetConnection() {
        do {
            reachability = try Reachability()
        } catch {
            print("reachability init failed")
        }

        guard let reachabilitySwift = reachability else {
            return
        }

        reachabilitySwift.whenReachable = { _ in

            if self.isNoInternet {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.loadNewData()
                }
            }
        }

        reachabilitySwift.whenUnreachable = { _ in

            print("reachability Not reachable")
            self.isNoInternet = true
//            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
        }

        do {
            try reachabilitySwift.startNotifier()
        } catch {
            print("reachability Unable to start notifier")
        }
    }
}

// MARK: - API

extension ReelsVC {
    func performWSToUserConfig() {
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config", method: .get, parameters: nil, headers: token, withSuccess: { response in

            do {
                let FULLResponse = try
                    JSONDecoder().decode(userConfigDC.self, from: response)

                if let onboarded = FULLResponse.onboarded {
                    SharedManager.shared.isOnboardingPreferenceLoaded = onboarded
                }

                if let ads = FULLResponse.ads {
                    UserDefaults.standard.set(ads.enabled, forKey: Constant.UD_adsAvailable)
                    UserDefaults.standard.set(ads.ad_unit_key, forKey: Constant.UD_adsUnitKey)
                    UserDefaults.standard.set(ads.type, forKey: Constant.UD_adsType)
                    SharedManager.shared.adsInterval = ads.interval ?? 10

                    if ads.type?.uppercased() == "FACEBOOK" {
                        UserDefaults.standard.set(ads.facebook?.feed, forKey: Constant.UD_adsUnitFeedKey)
                        UserDefaults.standard.set(ads.facebook?.reel, forKey: Constant.UD_adsUnitReelKey)
                    } else {
                        UserDefaults.standard.set(ads.admob?.feed, forKey: Constant.UD_adsUnitFeedKey)
                        UserDefaults.standard.set(ads.admob?.reel, forKey: Constant.UD_adsUnitReelKey)
                    }
                }

                if let walletLink = FULLResponse.wallet {
                    UserDefaults.standard.set(walletLink, forKey: Constant.UD_WalletLink)
                }

                // For Community Guildelines
                if let terms = FULLResponse.terms {
                    SharedManager.shared.community = terms.community ?? true
                }

                if let preference = FULLResponse.home_preference {
                    SharedManager.shared.isTutorialDone = preference.tutorial_done ?? false
                    SharedManager.shared.bulletsAutoPlay = preference.bullets_autoplay ?? false
                    SharedManager.shared.reelsAutoPlay = preference.reels_autoplay ?? false
                    SharedManager.shared.videoAutoPlay = preference.videos_autoplay ?? false
                    SharedManager.shared.readerMode = preference.reader_mode ?? false
                    SharedManager.shared.speedRate = preference.narration?.speed_rate ?? ["1.0x": 1]

                    if let narrMode = preference.narration?.mode {
                        SharedManager.shared.showHeadingsOnly = narrMode
                    }

                    if let speed = preference.narration?.speed {
                        let allKeys = [String](SharedManager.shared.speedRate.keys)
                        for key in allKeys {
                            if key == speed {
                                let value = SharedManager.shared.speedRate[key]
                                SharedManager.shared.localReadingSpeed = value ?? 1.0
                                SharedManager.shared.readingSpeed = key
                            }
                        }
                    }
                }

                if let user = FULLResponse.user {
                    SharedManager.shared.userId = user.id ?? ""

                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(user) {
                        SharedManager.shared.userDetails = encoded
                    }

                    SharedManager.shared.isLinkedUser = user.guestValid ?? false
                }

                if let rating = FULLResponse.rating {
                    let interval = rating.interval ?? 100
                    let nextInt = rating.next_interval ?? 100

                    if interval > SharedManager.shared.appUsageCount ?? 0 {
                        UserDefaults.standard.setValue(interval, forKey: Constant.ratingTimeIntervel)
                    } else {
                        UserDefaults.standard.setValue(nextInt, forKey: Constant.ratingTimeIntervel)
                    }
                }

                if let alert = FULLResponse.alert {
                    SharedManager.shared.userAlert = alert
                }

            } catch let jsonerror {
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects", jsonerror)
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
            }

        }) { error in

            print("error parsing json objects", error)
        }
    }

    func performWSToGetReelsData(page: String, isRefreshRequired: Bool = false, contextID: String) {
        if reelsArray.count == 0 {
            delegate?.loaderShowing(status: true)
            viewEmptyMessage.isHidden = true
            showSkeletonLoader = true
            collectionView.reloadData()
        }

        if !(SharedManager.shared.isConnectedToNetwork()) {
            stopPullToRefresh()
            delegate?.loaderShowing(status: false)
            SharedManager.shared.hideLaoderFromWindow()
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)

        isApiCallAlreadyRunning = true

        var url = ""

        if isFromChannelView {
            // For Channels view
            if channelInfo?.own ?? false {
                url = "studio/reels?source=\(channelInfo?.id ?? "")"
            } else {
                url = "news/reels?context=\(channelInfo?.context ?? "")"
            }
        } else if isShowingProfileReels {
            // Showing user profile
            url = "studio/reels?source"
            if authorID != SharedManager.shared.userId {
                url = "news/authors/\(authorID)/reels"
            }
        } else if SharedManager.shared.isAppOpenFromDeepLink == true {
            // Play specific reels shared from link
            url = "news/reels?context=\(contextID)"
            SharedManager.shared.isAppOpenFromDeepLink = false
        } else {
            if SharedManager.shared.curReelsCategoryId == "" {
                // Reels
                url = "news/reels"
            } else {
                // Discover specific reels
                url = "news/reels?context=\(contextID.replace(string: "+", replacement: "%2B").replace(string: "=", replacement: "%3D"))"
            }
        }

        var type = ""
        if !isBackButtonNeeded {
            if isOnFollowing {
                type = "FOLLOWING"
            } else {
                type = "FOR_YOU"
            }
        }

        let params = [
            "page": page,
            "type": type,
            "tag": isOpenFromTags ? titleText.replace(string: "#", replacement: "") : "",
        ] as [String: Any]

        viewEmptyMessage.isUserInteractionEnabled = false

        WebService.URLResponse(url, method: .get, parameters: params, headers: token, withSuccess: { [weak self] response in

            self?.delegate?.loaderShowing(status: false)

            self?.stopPullToRefresh()
            SharedManager.shared.hideLaoderFromWindow()

            ANLoader.hide()
            guard let self = self else {
                return
            }
            self.isApiCallAlreadyRunning = false

            do {
                let FULLResponse = try
                    JSONDecoder().decode(ReelsModel.self, from: response)

                ANLoader.hide()
                self.collectionView.isHidden = false
                if isRefreshRequired {
                    self.reelsArray.removeAll()
                    self.currentlyPlayingIndexPath = IndexPath(item: 0, section: 0)
                    self.collectionView.setContentOffset(.zero, animated: false)
                    self.collectionView.reloadData()
                }

                if let reelsData = FULLResponse.reels, reelsData.count > 0 {
                    self.isOpenedFollowingPrefernce = false
                    self.viewEmptyMessage.isHidden = true

                    // write Cache Codable types object reels
                    if !self.isBackButtonNeeded, self.nextPageData.isEmpty {
                        self.writeToCache(response: FULLResponse)
                    }

                    if self.reelsArray.count == 0 {
                        ReelsCacheManager.shared.clearDiskCache()
                        ReelsCacheManager.shared.delegate = self

                        self.reelsArray = reelsData
                        if self.reelsArray.count < 10 {
                            self.callWebsericeToGetNextVideos()
                        }
                        self.currentCachePosition = 1
                        self.cacheLimit = 10
                        self.startReelsCaching()

                        if SharedManager.shared.adsAvailable, SharedManager.shared.adUnitReelID != "", self.isSugReels == false, self.isShowingProfileReels == false, self.isFromChannelView == false {
                            // LOAD ADS
                            self.reelsArray.removeAll { $0.iosType == Constant.newsArticle.ARTICLE_TYPE_ADS }
                            self.reelsArray = self.reelsArray.adding(Reel(id: "", context: "", reelDescription: "", media: "", media_landscape: "", mediaMeta: nil, publishTime: "", source: nil, info: nil, authors: nil, captions: nil, image: "", status: "", iosType: Constant.newsArticle.ARTICLE_TYPE_ADS, nativeTitle: true), afterEvery: SharedManager.shared.adsInterval)
                        }

                        if self.showSkeletonLoader {
                            self.showSkeletonLoader = false
                            if let skeletonCell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ReelsSkeletonAnimation {
                                skeletonCell.hideLaoder()
                            }

                        } else {
                            if isRefreshRequired {
                                self.collectionView.isUserInteractionEnabled = false
                                self.collectionView.setContentOffset(.zero, animated: false)
                                self.collectionView.layoutIfNeeded()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    self.stopVideo()
                                    self.collectionView.setContentOffset(.zero, animated: false)
                                    self.collectionView.isUserInteractionEnabled = true
                                    self.collectionView.reloadData()
                                    self.collectionView.layoutIfNeeded()
                                }
                            }
                        }

                        if !self.fromMain || self.isPullToRefresh {
                            self.collectionView.reloadData()
                        }

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

                        for obj in self.reelsArray {
                            SharedManager.shared.saveAllVideosThumbnailsToCache(imageURL: obj.image ?? "")
                        }

                    } else {
                        let newIndexArray = [IndexPath]()
                        reelsData.forEach { reel in
                            if !self.reelsArray.contains(where: { $0.id == reel.id }) {
                                self.reelsArray.append(reel)
                            }
                        }

                        if self.cacheLimit < self.reelsArray.count {
                            self.cacheLimit = self.reelsArray.count
                        }
                        self.startReelsCaching()
                        if SharedManager.shared.adsAvailable, SharedManager.shared.adUnitReelID != "", self.isSugReels == false, self.isShowingProfileReels == false, self.isFromChannelView == false, self.fromMain {
                            // LOAD ADS
                            self.reelsArray.removeAll { $0.iosType == Constant.newsArticle.ARTICLE_TYPE_ADS }
                            self.reelsArray = self.reelsArray.adding(Reel(id: "", context: "", reelDescription: "", media: "", media_landscape: "", mediaMeta: nil, publishTime: "", source: nil, info: nil, authors: nil, captions: nil, image: "", status: "", iosType: Constant.newsArticle.ARTICLE_TYPE_ADS, nativeTitle: false), afterEvery: SharedManager.shared.adsInterval)
                        }

                        self.collectionView.performBatchUpdates {
                            self.collectionView.layoutIfNeeded()
                            self.collectionView.insertItems(at: newIndexArray)
                        } completion: { _ in
                            self.collectionView.layoutIfNeeded()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                if self.isViewControllerVisible == false {
                                    return
                                }
                                if self.isRightMenuLoaded {
                                    return
                                }
                                if self.isWatchingRotatedVideos {
                                    return
                                }
                                self.getCurrentVisibleIndexPlayVideo()
                            }
                        }
                    }

                } else {
                    if self.reelsArray.count == 0 {
                        if self.isOpenedFollowingPrefernce {
                            self.delegate?.switchBackToForYou()
                            self.isOpenedFollowingPrefernce = false
                        } else {
                            self.showSkeletonLoader = false
                            self.viewEmptyMessage.isUserInteractionEnabled = true
                            self.viewEmptyMessage.isHidden = false
                        }
                    }

                    self.collectionView.reloadData()
                }

                // Meta data
                if let next = FULLResponse.meta?.next, next.isEmpty == false {
                    self.nextPageData = next
                } else {
                    self.nextPageData = ""
                }

            } catch let jsonerror {
                self.delegate?.loaderShowing(status: false)
                self.stopPullToRefresh()
                SharedManager.shared.hideLaoderFromWindow()

                ANLoader.hide()
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                self.isApiCallAlreadyRunning = false
                print("error parsing json objects", jsonerror)
            }
        }) { error in
            self.delegate?.loaderShowing(status: false)
            self.stopPullToRefresh()
            SharedManager.shared.hideLaoderFromWindow()

            self.isApiCallAlreadyRunning = false
            ANLoader.hide()
            print("error parsing json objects", error)
        }
    }
}

extension ReelsVC {
    func performWSToLikePost(article_id: String, isLike: Bool) {
        if !(SharedManager.shared.isConnectedToNetwork()) {
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let params = ["like": isLike]
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)

        //        isLikeApiRunning = true
        WebService.URLResponseJSONRequest("social/likes/article/\(article_id)", method: .post, parameters: params, headers: token, withSuccess: { response in
            self.isLikeApiRunning = false
            do {
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)

            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "social/likes/article/\(article_id)", error: jsonerror.localizedDescription, code: "")
                self.isLikeApiRunning = false
                print("error parsing json objects", jsonerror)
            }
        }) { error in
            self.isLikeApiRunning = false
            print("error parsing json objects", error)
        }
    }
}

extension ReelsVC {
    func performWSToOpenTopics(id: String, title: String, favorite: Bool) {
        ANLoader.showLoading(disableUI: false)
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""

        let url = "news/topics/related/\(id)"
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { response in

            ANLoader.hide()
            do {
                let FULLResponse = try
                    JSONDecoder().decode(SubTopicDC.self, from: response)

                DispatchQueue.main.async {
                    if let topics = FULLResponse.topics {
                        SharedManager.shared.subTopicsList = topics

                        let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
                        vc.showArticleType = .topic
                        vc.selectedID = id
                        vc.isFav = favorite
                        vc.subTopicTitle = title

                        let nav = AppNavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                    }
                }

            } catch let jsonerror {
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects", jsonerror)
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
            }

        }) { error in

            ANLoader.hide()
            print("error parsing json objects", error)
        }
    }

    func performGoToSource(id: String) {
        if !(SharedManager.shared.isConnectedToNetwork()) {
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/data/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { response in

            do {
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)

                DispatchQueue.main.async {
                    if let Info = FULLResponse.channel {
                        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
                        detailsVC.isOpenFromReel = true
                        detailsVC.channelInfo = Info
                        detailsVC.delegate = self
                        detailsVC.modalPresentationStyle = .fullScreen

                        let nav = AppNavigationController(rootViewController: detailsVC)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                    } else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: "Related Sources not available")
                    }
                }

            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects", jsonerror)
            }

        }) { error in

            print("error parsing json objects", error)
        }
    }
}

extension ReelsVC {
    func performArticleArchive(_ id: String, isArchived: Bool) {
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.archiveClick, eventDescription: "", article_id: id)

        if !(SharedManager.shared.isConnectedToNetwork()) {
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["archive": isArchived]
        WebService.URLResponse("news/articles/\(id)/archive", method: .post, parameters: params, headers: token, withSuccess: { response in

            do {
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)

                if let status = FULLResponse.message?.uppercased() {
                    if status == Constant.STATUS_SUCCESS {
                        SharedManager.shared.showAlertLoader(message: isArchived ? ApplicationAlertMessages.kMsgAddToFavorite : ApplicationAlertMessages.kMsRemoveFromFavorite, type: .alert)
                        self.isArchived = true
                    } else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }

            } catch let jsonerror {
                print("error parsing json objects", jsonerror)
                SharedManager.shared.logAPIError(url: "news/articles/\(id)/archive", error: jsonerror.localizedDescription, code: "")
            }

        }) { error in

            print("error parsing json objects", error)
        }
    }
}

extension ReelsVC {
    func downloadVideoInLocal() {
        let urlString = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"

        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: urlString),
               let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let filePath = "\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { _, _ in
                    }
                }
            }
        }
    }
}
