//
//  ReelsVC+Delegate.swift
//  Bullet
//
//  Created by Osman Ahmed on 05/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import DataCache
import Foundation
import Photos
import SideMenu
import FBSDKShareKit

// MARK: - ReelsVC + TutorialVCDelegate

extension ReelsVC: TutorialVCDelegate {
    func userDismissed(vc: TutorialVC) {
        let vc = AlertViewNew.instantiate(fromAppStoryboard: .Reels)
        vc.delegate = self
        vc.message = NSLocalizedString("Thanks! We have successfully saved your preferences. Start discovering curated content.", comment: "")
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - ReelsVC + AlertViewNewDelegate

extension ReelsVC: AlertViewNewDelegate {
    func alertClosedbyUser() {
        SharedManager.shared.isSavedPreferenceAlertRequired = false
        isViewControllerVisible = true
        playCurrentCellVideo()
    }
}

// MARK: - ReelsVC + ForYouPreferencesVCDelegate

extension ReelsVC: ForYouPreferencesVCDelegate {
    func userDismissed(vc _: ForYouPreferencesVC, selectedPreference _: Int, selectedCategory _: String) {}

    func userChangedCategory() {
        NotificationCenter.default.post(name: .didChangeReelsTopics, object: nil)
        reelsArray.removeAll()
        collectionView.reloadData()
        nextPageData = ""
        showSkeletonLoader = true
        performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.curReelsCategoryId)
    }
}

// MARK: - ReelsVC + FollowingPreferenceVCDelegate

extension ReelsVC: FollowingPreferenceVCDelegate {
    func userDismissed(vc _: FollowingPreferenceVC) {
        playCurrentCellVideo()
        isViewControllerVisible = true
    }
}

// MARK: - ReelsVC + AddUsernameVCDelegate

extension ReelsVC: AddUsernameVCDelegate {
    func userDismissed(vc _: AddUsernameVC) {
        playCurrentCellVideo()
        isViewControllerVisible = true
    }
}

// MARK: - ReelsVC + SelectTopicsVCDelegate

extension ReelsVC: SelectTopicsVCDelegate {
    func didTapClose() {
        playCurrentCellVideo()
        isViewControllerVisible = true
    }
}

// MARK: - ReelsVC + ReelsCategoryVCDelegate

extension ReelsVC: ReelsCategoryVCDelegate {
    func reelsCategoryVCDismissed() {}

    func loadNewData() {
        DataCache.instance.clean(byKey: Constant.CACHE_REELS)
        DataCache.instance.clean(byKey: Constant.CACHE_REELS_Follow)
        stopVideo()
        setUpSelectedCategory()
        currentlyPlayingIndexPath = IndexPath(item: 0, section: 0)
        collectionView.setContentOffset(.zero, animated: false)
        reelsArray.removeAll()
        nextPageData = ""

        print("CONTEXT = \(SharedManager.shared.curReelsCategoryId)")

        setRefresh(scrollView: collectionView, manual: true)
    }

    func writeToCache(response: ReelsModel?) {
        if isOnFollowing {
            do {
                try DataCache.instance.write(codable: response, forKey: Constant.CACHE_REELS_Follow)
            } catch {
                print("Write error \(error.localizedDescription)")
            }
        } else {
            do {
                try DataCache.instance.write(codable: response, forKey: Constant.CACHE_REELS)
            } catch {
                print("Write error \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - ReelsVC + ReelsVCDelegate

extension ReelsVC: ReelsVCDelegate {
    func changeScreen(pageIndex _: Int) {}

    func switchBackToForYou() {}

    func loaderShowing(status _: Bool) {}

    func backButtonPressed(_: Bool) {}

    func currentPlayingVideoChanged(newIndex _: IndexPath) {}
}

// MARK: - ReelsVC + BottomSheetVCDelegate

extension ReelsVC: BottomSheetVCDelegate {
    func didTapUpdateAudioAndProgressStatus() {
        if SharedManager.shared.reelsAutoPlay {
            playCurrentCellVideo()
        }
    }

    func didTapDissmisReportContent() {
        if SharedManager.shared.reelsAutoPlay {
            playCurrentCellVideo()
        }
        SharedManager.shared.showAlertLoader(message: "Report concern sent successfully.")
    }

    func didTapBottomShareSheetAction(sender: UIButton, article: articlesData) {
        if sender.tag != 2 {
            playCurrentCellVideo()
        }

        if sender.tag == 1 {
            // Save article
            performArticleArchive(article.id ?? "", isArchived: !articleArchived)
        } else if sender.tag == 2 {
            openDefaultShareSheet(shareTitle: shareTitle)
        } else if sender.tag == 3 {
            // Go to Source
            if let _ = article.source {
                performGoToSource(id: article.source?.id ?? "")
            } else {
                if (article.authors?.first?.id ?? "") == SharedManager.shared.userId {
                    let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: true, completion: nil)
                } else {
                    let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                    vc.authors = article.authors
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen

                    present(navVC, animated: true, completion: nil)
                }
            }
        } else if sender.tag == 4 {
            // Follow Source
            if sourceFollow {
                SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [article.source?.id ?? ""], isFav: false, type: .sources) { success in
                    print("status ", success)
                    if success {
                        SharedManager.shared.showAlertLoader(message: "Unfollowed \(article.source?.name ?? "")", type: .alert)
                    }
                }
            } else {
                SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [article.source?.id ?? ""], isFav: true, type: .sources) { success in
                    print("status ", success)
                    if success {
                        SharedManager.shared.showAlertLoader(message: "followed \(article.source?.name ?? "")", type: .alert)
                    }
                }
            }
        } else if sender.tag == 5 {
            // Block articles
            if let _ = article.source {
                /* If article source */
                if sourceBlock {
                    performWSToUnblockSource(article.source?.id ?? "", name: article.source?.name ?? "")
                } else {
                    performBlockSource(article.source?.id ?? "", sourceName: article.source?.name ?? "")
                }
            } else {
                // If article author data
                performWSToBlockUnblockAuthor(article.authors?.first?.id ?? "", name: article.authors?.first?.name ?? "")
            }
        } else if sender.tag == 6 {
            // Report content
        } else if sender.tag == 7 {
            // More like this
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.moreLikeThisClick, eventDescription: "")
            performWSuggestMoreOrLess(article.id ?? "", isMoreOrLess: true)
        } else if sender.tag == 8 {
            // I don't like this
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.lessLikeThisClick, eventDescription: "", article_id: article.id ?? "")
            performWSuggestMoreOrLess(article.id ?? "", isMoreOrLess: false)
        } else if sender.tag == 9 {
            SharedManager.shared.isCaptionsEnableReels = !SharedManager.shared.isCaptionsEnableReels

            if SharedManager.shared.isCaptionsEnableReels {
                getCaptionsFromAPI()
            }

            if SharedManager.shared.isCaptionsEnableReels {
                SharedManager.shared.showAlertLoader(message: "Turned on captions", type: .alert)
            } else {
                SharedManager.shared.showAlertLoader(message: "Turned off captions", type: .alert)
            }
        } else if sender.tag == 10 {
            // Copy
            // write to clipboard
            UIPasteboard.general.string = shareTitle
            SharedManager.shared.showAlertLoader(message: "Copied to clipboard successfully", type: .alert)
        }
    }
}

// MARK: - ReelsVC + CommentsVCDelegate

extension ReelsVC: CommentsVCDelegate {
    func commentsVCDismissed(articleID: String) {
        isViewControllerVisible = true
        appDelegate.setOrientationPortraitInly()

        if SharedManager.shared.reelsAutoPlay {
            playCurrentCellVideo()
        }
        SharedManager.shared.performWSToGetCommentsCount(id: articleID) { info in
            if info != nil {
                if let selectedIndex = self.reelsArray.firstIndex(where: { $0.id == articleID }) {
                    self.reelsArray[selectedIndex].info?.commentCount = info?.commentCount ?? 0

                    if let cell = self.collectionView.cellForItem(at: IndexPath(row: selectedIndex, section: 0)) {
                        (cell as? ReelsCC)?.setLikeComment(model: self.reelsArray[selectedIndex].info, showAnimation: false)
                    }
                }
            }
        }
    }

    func performWSToShare(indexPath: IndexPath, id: String, isOpenViewMoreOptions: Bool) {
        if !(SharedManager.shared.isConnectedToNetwork()) {
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        showLoaderInVC()
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/articles/\(id)/share/info", method: .get, parameters: nil, headers: token, withSuccess: { [weak self] response in

            self?.hideLoaderVC()
            do {
                let FULLResponse = try
                    JSONDecoder().decode(ShareSheetDC.self, from: response)

                SharedManager.shared.instaMediaUrl = ""
                self?.shareTitle = FULLResponse.share_message ?? ""
                self?.articleArchived = FULLResponse.article_archived ?? false
                self?.sourceBlock = FULLResponse.source_blocked ?? false
                self?.sourceFollow = FULLResponse.source_followed ?? false

                if let media = FULLResponse.download_link {
                    SharedManager.shared.instaMediaUrl = media
                }
                if isOpenViewMoreOptions == false {
                    self?.pauseCellVideo(indexPath: indexPath)

                    self?.openDefaultShareSheet(shareTitle: self?.shareTitle ?? "")
                } else {
                    self?.openViewMoreOptions()
                }

            } catch let jsonerror {
                self?.hideLoaderVC()
                print("error parsing json objects", jsonerror)
            }

        }) { error in
            self.hideLoaderVC()
            print("error parsing json objects", error)
        }
    }

    func createAssetURL(url: URL, completion: @escaping (String) -> Void) {
        let photoLibrary = PHPhotoLibrary.shared()
        var videoAssetPlaceholder: PHObjectPlaceholder!
        photoLibrary.performChanges({
                                        let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                                        videoAssetPlaceholder = request!.placeholderForCreatedAsset
                                    },
                                    completionHandler: { success, _ in
                                        if success {
                                            let localID = NSString(string: videoAssetPlaceholder.localIdentifier)
                                            let assetID = localID.replacingOccurrences(of: "/.*", with: "", options: NSString.CompareOptions.regularExpression, range: NSRange())
                                            let ext = "mp4"
                                            let assetURLStr =
                                                "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"

                                            completion(assetURLStr)
                                        }
                                    })
    }

    func performWSToUnblockSource(_ id: String, name: String) {
        if !(SharedManager.shared.isConnectedToNetwork()) {
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        ANLoader.showLoading(disableUI: true)

        let param = ["sources": id]
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/unblock", method: .post, parameters: param, headers: token, withSuccess: { response in

            do {
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)

                if FULLResponse.message == "Success" {
                    SharedManager.shared.showAlertLoader(message: "Unblocked \(name)", type: .alert)
                } else {
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                ANLoader.hide()
            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/sources/unblock", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects", jsonerror)
            }

        }) { error in

            ANLoader.hide()
            print("error parsing json objects", error)
        }
    }

    func performWSuggestMoreOrLess(_ id: String, isMoreOrLess: Bool) {
        if !(SharedManager.shared.isConnectedToNetwork()) {
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let query = isMoreOrLess ? "news/articles/\(id)/suggest/more" : "news/articles/\(id)/suggest/less"

        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(query, method: .post, parameters: nil, headers: token, withSuccess: { response in

            do {
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)

                if let status = FULLResponse.message?.uppercased() {
                    if status == Constant.STATUS_SUCCESS {
                        if isMoreOrLess {
                            SharedManager.shared.showAlertLoader(message: "You'll see more stories like this", type: .alert)
                        } else {
                            SharedManager.shared.showAlertLoader(message: "You'll see less stories like this", type: .alert)
                        }
                    } else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }

            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects", jsonerror)
            }
        }) { error in
            print("error parsing json objects", error)
        }
    }

    func performBlockSource(_ id: String, sourceName: String) {
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockSource, eventDescription: "", source_id: id)

        if !(SharedManager.shared.isConnectedToNetwork()) {
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        WebService.URLResponse("news/sources/block", method: .post, parameters: params, headers: token, withSuccess: { response in

            do {
                let FULLResponse = try
                    JSONDecoder().decode(BlockTopicDC.self, from: response)

                if let status = FULLResponse.message?.uppercased() {
                    if status == Constant.STATUS_SUCCESS {
                        SharedManager.shared.showAlertLoader(message: "Blocked \(sourceName)", type: .alert)
                    } else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }

            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/sources/block", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects", jsonerror)
            }

        }) { error in

            print("error parsing json objects", error)
        }
    }

    func performWSToBlockUnblockAuthor(_ id: String, name: String) {
        if sourceBlock == false {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockauthor, eventDescription: "", author_id: id)
        }

        if !(SharedManager.shared.isConnectedToNetwork()) {
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        ANLoader.showLoading(disableUI: true)

        let param = ["authors": id]
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)

        let query = sourceBlock ? "news/authors/unblock" : "news/authors/block"

        WebService.URLResponse(query, method: .post, parameters: param, headers: token, withSuccess: { response in

            do {
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)

                if FULLResponse.message == "Success" {
                    if self.sourceBlock {
                        SharedManager.shared.showAlertLoader(message: "Unblocked \(name)", type: .alert)
                    } else {
                        SharedManager.shared.showAlertLoader(message: "Blocked \(name)", type: .alert)
                    }
                } else {
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                ANLoader.hide()
            } catch let jsonerror {
                ANLoader.hide()
                print("error parsing json objects", jsonerror)
                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
            }

        }) { error in

            ANLoader.hide()
            print("error parsing json objects", error)
        }
    }

    func openViewMoreOptions() {
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reportClick, eventDescription: "")

        let reel = reelsArray[currentlyPlayingIndexPath.item]

        let bullet = [Bullets(data: reel.reelDescription, audio: nil, duration: nil, image: nil)]
        let content = articlesData(id: reel.id, title: reel.reelDescription, media: reel.media, image: reel.image, link: reel.media, color: nil, publish_time: reel.publishTime, source: reel.source, bullets: bullet, topics: nil, status: nil, mute: nil, type: Constant.newsArticle.ARTICLE_TYPE_VIDEO, meta: nil, info: nil, media_meta: reel.mediaMeta)

        let vc = BottomSheetVC.instantiate(fromAppStoryboard: .registration)
        vc.delegateBottomSheet = self
        vc.article = content
        vc.isFromReels = true
        vc.isCaptionOptionNeeded = true
        vc.openReportList = false
        if reel.authors?.first?.id == SharedManager.shared.userId {
            vc.isSameAuthor = true
        }
        vc.sourceBlock = sourceBlock
        vc.sourceFollow = sourceFollow
        vc.article_archived = articleArchived
        vc.share_message = shareTitle
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }

    func openDefaultShareSheet(shareTitle: String) {
        DispatchQueue.main.async {
            // Share
            let shareContent: [Any] = [shareTitle]

            let activityVc = UIActivityViewController(activityItems: shareContent, applicationActivities: [])
            activityVc.excludedActivityTypes = [.assignToContact, .print, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .openInIBooks, .markupAsPDF]

            activityVc.completionWithItemsHandler = { activity, success, _, _ in

                if activity == nil || success == true {
                    // User canceled
                    self.isViewControllerVisible = false
                    self.playCurrentCellVideo()
                    return
                }

                // User completed activity
            }
            self.stopVideo()
            self.isViewControllerVisible = false
            self.present(activityVc, animated: true)
        }
    }

    func stopIndicatorLoading() {
        if indicator.isAnimating {
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                self.viewIndicator.isHidden = true
            }
        }
    }
}

// MARK: - ReelsVC + BottomSheetArticlesVCDelegate

extension ReelsVC: BottomSheetArticlesVCDelegate {
    func dismissBottomSheetArticlesVCDelegateAction(type: Int, idx: Int) {
        if type == -1 {
            // When user tap outside only dismiss bottom sheet
            if SharedManager.shared.reelsAutoPlay {
                playCurrentCellVideo()
            }
            return
        }

        if type == 0 {
            // edit

            let reel = reelsArray[idx]

            let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
            vc.postArticleType = .reel
            vc.isEditable = true
            vc.isScheduleRequired = false

            let bullet = [Bullets(data: reel.reelDescription, audio: nil, duration: nil, image: nil)]

            vc.yArticle = articlesData(id: reel.id, title: reel.reelDescription, media: reel.media, image: reel.image, link: reel.media, color: nil, publish_time: reel.publishTime, source: reel.source, bullets: bullet, topics: nil, status: nil, mute: nil, type: Constant.newsArticle.ARTICLE_TYPE_VIDEO, meta: nil, info: nil, media_meta: reel.mediaMeta)
            vc.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(vc, animated: true)
        } else if type == 1 {
            // delete

            let reel = reelsArray[idx]
            performWSToArticleUnpublished(reel.id ?? "")
        }
    }

    func performWSToArticleUnpublished(_ id: String) {
        if !(SharedManager.shared.isConnectedToNetwork()) {
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        ANLoader.showLoading()
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)

        let params = ["status": "UNPUBLISHED"]

        WebService.URLResponse("studio/articles/\(id)/status", method: .patch, parameters: params, headers: token, withSuccess: { response in

            ANLoader.hide()
            do {
                _ = try
                    JSONDecoder().decode(messageDC.self, from: response)

                SharedManager.shared.showAlertLoader(message: NSLocalizedString("Article removed successfully", comment: ""))
                if let index = self.reelsArray.firstIndex(where: { $0.id == id }) {
                    self.reelsArray.remove(at: index)

                    if self.reelsArray.count == 0 {
                        self.didTapBack(UIButton())
                        return
                    }

                    self.collectionView.reloadData()

                    self.collectionView.reloadData()
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

            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "studio/articles/\(id)/status", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects", jsonerror)
            }

        }) { error in

            ANLoader.hide()
            print("error parsing json objects", error)
        }
    }
}

// MARK: - ReelsVC + ReelsCacheManagerDelegate

extension ReelsVC: ReelsCacheManagerDelegate {
    func cachingCompleted(reel: Reel, position: Int) {
        if position < reelsArray.count {
            reelsArray[position] = reel
        }

        DispatchQueue.main.async {
            if position == 10 {
                ANLoader.hide()
                self.stopIndicatorLoading()
                let indexPaths = Array(1 ... 9).map { IndexPath(item: $0, section: 0) }
                self.collectionView.reloadItems(at: indexPaths)
            }
        }

        let indexPath = IndexPath(item: position, section: 0)
        DispatchQueue.main.async {
            if position > 10 {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        currentCachePosition += 1
//        startReelsCaching()
    }

//    func startReelsCaching() {
//        ReelsCacheManager.shared.delegate = self
//        if currentCachePosition < cacheLimit, currentCachePosition < reelsArray.count {
//            if reelsArray[currentCachePosition].iosType == nil {
//                ReelsCacheManager.shared.begin(reelModel: reelsArray[currentCachePosition], position: currentCachePosition)
//            } else {
//                currentCachePosition += 1
//                if currentCachePosition < reelsArray.count {
//                    ReelsCacheManager.shared.begin(reelModel: reelsArray[currentCachePosition], position: currentCachePosition)
//                }
//            }
//        }
//    }
}

// MARK: - ReelsVC + ReelsFullScreenVCDelegate

extension ReelsVC: ReelsFullScreenVCDelegate {
    func rotatedVideoWatchingFinished(time: TimeInterval?) {
        collectionView.alpha = 0
        viewCategoryType.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            UIView.animate(withDuration: 0.25) {
                self.collectionView.alpha = 1
                if self.isBackButtonNeeded == false {
                    self.viewCategoryType.alpha = 1
                }
            } completion: { _ in
                self.collectionView.alpha = 1
                if self.isBackButtonNeeded == false {
                    self.viewCategoryType.alpha = 1
                }
            }
        }

        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.invalidateLayout()

        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: currentlyPlayingIndexPath, at: .centeredVertically, animated: false)

        view.isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.view.isUserInteractionEnabled = true
            self.isWatchingRotatedVideos = false

            if let cell = self.collectionView.cellForItem(at: self.currentlyPlayingIndexPath) as? ReelsCC {
                if time == .zero || time == nil {
                    self.forceScrollandPlayVideo(time: time)
                } else if (time ?? .zero) >= (cell.player.currentDuration) {
                    let nextIndexPath = IndexPath(item: self.currentlyPlayingIndexPath.item + 1, section: 0)
                    if nextIndexPath.item < self.reelsArray.count {
                        if self.isViewControllerVisible == false {
                            return
                        }
                        if self.isRightMenuLoaded {
                            return
                        }

                        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelsDurationEvent, eventDescription: "", article_id: self.reelsArray[self.currentlyPlayingIndexPath.item].id ?? "", duration: cell.player.totalDuration.formatToMilliSeconds())

                        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelsFinishedPlaying, eventDescription: "", article_id: self.reelsArray[self.currentlyPlayingIndexPath.item].id ?? "")

                        self.playNextCellVideo(indexPath: nextIndexPath)
                    }
                } else {
                    self.forceScrollandPlayVideo(time: time)
                }
            }
        }
    }

    func forceScrollandPlayVideo(time: TimeInterval?) {
        resumeVideo(time: time)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.adjustCellScrollPostion()
        }
    }
}

// MARK: - ReelsVC + ChannelDetailsVCDelegate

extension ReelsVC: ChannelDetailsVCDelegate {
    func backButtonPressedChannelDetailsVC() {}

    func backButtonPressedWhenFromReels(_ channel: ChannelInfo?) {
        if ReelsCacheManager.shared.reelViewedOnChannelPage {
            reelsArray.removeAll()
            collectionView.reloadData()
            nextPageData = ""
            performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.curReelsCategoryId)
        }
        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            // Check source if its not available then use author
            if let _ = cell.reelModel?.source {
                cell.reelModel?.source = channel
                cell.btnUserPlus.isHidden = channel?.favorite ?? false

                reelsArray[currentlyPlayingIndexPath.item].source = channel

                for (indexPa, reelObj) in reelsArray.enumerated() {
                    if reelObj.source?.id == channel?.id {
                        reelsArray[indexPa].source = channel
                    }
                }

                let cellsArray = collectionView.visibleCells

                if cellsArray.count > 0 {
                    for cellObj in cellsArray {
                        if let reelscell = cellObj as? ReelsCC {
                            if reelscell.reelModel?.source?.id == channel?.id {
                                reelscell.reelModel?.source = channel
                                reelscell.btnUserPlus.isHidden = channel?.favorite ?? false
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ReelsVC + BulletDetailsVCLikeDelegate

extension ReelsVC: BulletDetailsVCLikeDelegate {
    func likeUpdated(articleID _: String, isLiked _: Bool, count _: Int) {}

    func commentUpdated(articleID _: String, count _: Int) {}

    func backButtonPressed(cell: HomeDetailCardCell?) {
        if SharedManager.shared.reloadRequiredFromTopics {
            setRefresh(scrollView: collectionView, manual: true)
            SharedManager.shared.reloadRequiredFromTopics = false
        }
        isViewControllerVisible = true
        if isOpenedLightMode {
            isOpenedLightMode = false
            MyThemes.switchTo(theme: .dark)
        }

        if SharedManager.shared.bulletsAutoPlay {
            playCurrentCellVideo()
        }

        if let cellReel = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            // Check source if its not available then use author
            if let _ = cellReel.reelModel?.source, let channel = cell?.articleModel?.source {
                cellReel.reelModel?.source = channel
                cellReel.btnUserPlus.isHidden = channel.favorite ?? false

                reelsArray[currentlyPlayingIndexPath.item].source = channel

                for (indexPa, reelObj) in reelsArray.enumerated() {
                    if reelObj.source?.id == channel.id {
                        reelsArray[indexPa].source = channel
                    }
                }

                let cellsArray = collectionView.visibleCells

                if cellsArray.count > 0 {
                    for cellObj in cellsArray {
                        if let reelscell = cellObj as? ReelsCC {
                            if reelscell.reelModel?.source?.id == channel.id {
                                reelscell.reelModel?.source = channel
                                reelscell.btnUserPlus.isHidden = channel.favorite ?? false
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ReelsVC + NotificationsListVCDelegate

extension ReelsVC: NotificationsListVCDelegate {
    func backButtonPressed() {
        isViewControllerVisible = true
        playCurrentCellVideo()
    }
}

// MARK: - ReelsVC + SideMenuNavigationControllerDelegate

extension ReelsVC: SideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu _: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")

        if currentlyPlayingIndexPath.item > reelsArray.count - 1 {
            return
        }
        // Authors CollectionView
        if let source = reelsArray[currentlyPlayingIndexPath.item].source {
            stopVideo()

            if source.id == controller.currentlyOpenedChannedID {
                return
            }
            controller.showChannelDetails(source: source)
        } else if let author = reelsArray[currentlyPlayingIndexPath.item].authors {
            stopVideo()

            if author.first?.id == controller.currentlyOpenedAuthorID {
                return
            }
            controller.showAuthorProfile(author: author)
        }
    }

    func sideMenuDidAppear(menu _: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")

        isRightMenuLoaded = true
        stopVideo()
    }

    func sideMenuWillDisappear(menu _: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }

    func sideMenuDidDisappear(menu _: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")

        isRightMenuLoaded = false
        if SharedManager.shared.reelsAutoPlay {
            playCurrentCellVideo()
        }
    }
}

// MARK: - ReelsVC + FollowingVCDelegate

extension ReelsVC: FollowingVCDelegate {
    func didTapBack() {}
}

// MARK: - ReelsVC + SharingDelegate, UIDocumentInteractionControllerDelegate

extension ReelsVC: SharingDelegate, UIDocumentInteractionControllerDelegate {
    func sharer(_: Sharing, didCompleteWithResults _: [String: Any]) {
        print("shared")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {}
    }

    func sharer(_: Sharing, didFailWithError _: Error) {
        print("didFailWithError")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {}
    }

    func sharerDidCancel(_: Sharing) {}
}
