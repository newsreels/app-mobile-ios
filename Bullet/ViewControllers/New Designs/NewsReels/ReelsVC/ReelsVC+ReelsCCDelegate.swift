//
//  ReelsVC+ReelsCCDelegate.swift
//  Bullet
//
//  Created by Osman Ahmed on 05/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import UIKit
import DataCache
import CoreMedia
import AVFoundation

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension ReelsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if showSkeletonLoader {
            collectionView.isScrollEnabled = false
            return 1
        }
        collectionView.isScrollEnabled = true

        setStatusBar()
        delegate?.loaderShowing(status: false)
        return reelsArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if showSkeletonLoader {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReelsSkeletonAnimation", for: indexPath) as! ReelsSkeletonAnimation

            cell.showLoader()
            return cell
        }

        if indexPath.item < reelsArray.count {
            if reelsArray[indexPath.item].iosType == Constant.newsArticle.ARTICLE_TYPE_ADS {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReelsPhotoAdCC", for: indexPath) as! ReelsPhotoAdCC
                cell.fetchAds(viewController: self)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReelsCC", for: indexPath) as! ReelsCC

                if indexPath.item < reelsArray.count {
                    cell.setupCell(model: reelsArray[indexPath.item], fromMain: self.fromMain)
                }

                cell.delegate = self
                if let source = reelsArray[indexPath.item].source {
                    let fav = source.favorite ?? false
                    DispatchQueue.main.async {
                        cell.btnUserPlus.hideLoaderView()
                        if fav {
                            cell.btnUserPlus.setTitle("Following", for: .normal)
                            cell.btnUserPlusWidth.constant = 90
                            cell.btnUserPlus.layoutIfNeeded()
                            cell.followStack.layoutIfNeeded()
                        } else {
                            cell.btnUserPlus.setTitle("Follow", for: .normal)
                            cell.btnUserPlusWidth.constant = 70
                            cell.btnUserPlus.layoutIfNeeded()
                            cell.followStack.layoutIfNeeded()
                        }
                    }
                    
                } else {
                    let fav = reelsArray[indexPath.item].authors?.first?.favorite ?? false
                    DispatchQueue.main.async {
                        cell.btnUserPlus.hideLoaderView()
                        if fav {
                            cell.btnUserPlus.setTitle("Following", for: .normal)
                            cell.btnUserPlusWidth.constant = 90
                            cell.btnUserPlus.layoutIfNeeded()
                            cell.followStack.layoutIfNeeded()
                        } else {
                            cell.btnUserPlus.setTitle("Follow", for: .normal)
                            cell.btnUserPlusWidth.constant = 70
                            cell.btnUserPlus.layoutIfNeeded()
                            cell.followStack.layoutIfNeeded()
                        }
                    }
                    
                }
                if channelInfo != nil {
                    cell.viewEditArticle.isHidden = (channelInfo?.own ?? false) ? false : true
                } else {
                    cell.viewEditArticle.isHidden = (authorID == SharedManager.shared.userId && !SharedManager.shared.userId.isEmpty) ? false : true
                }
                cell.btnEditArticle.tag = indexPath.item
                cell.btnAuthor.tag = indexPath.item

                cell.contentView.frame = cell.bounds
                cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]


                
                
                return cell
            }
        }

        return UICollectionViewCell()
    }

    func collectionView(_: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt _: IndexPath) {
        if let skeletonCell = cell as? ReelsSkeletonAnimation {
            skeletonCell.hideLaoder()
        }

        if let cell = cell as? ReelsCC {
            cell.stopVideo()
            cell.pause()
        }
    }

    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ReelsCC {
            if indexPath.item == 0 {
                cell.play()
            }
            if SharedManager.shared.isAudioEnableReels == false {
                cell.playerLayer.player?.volume = 0.0
                cell.imgSound.image = UIImage(named: "newMuteIC")
            } else {
                cell.playerLayer.player?.volume = 1.0
                cell.imgSound.image = UIImage(named: "newUnmuteIC")
            }

            if SharedManager.shared.reelsAutoPlay {
                cell.viewPlayButton.isHidden = true
            } else {
                cell.viewPlayButton.isHidden = false
                cell.stopVideo()
            }
        }
        if reelsArray.count > 0 {
            if reelsArray[indexPath.row].reelDescription == "", reelsArray[indexPath.row].authors?.count == 0, reelsArray[indexPath.row].iosType == nil {
                reelsArray.remove(at: indexPath.row)
                let indexPathReload = IndexPath(item: indexPath.row, section: 0)
                collectionView.reloadItems(at: [indexPathReload])
            }
            
            // Preloading
            for section in 0..<collectionView.numberOfSections {
                for i in indexPath.item - 2 ..< indexPath.item + 2 {
                    let indexPath = IndexPath(item: i, section: section)
                    
                    if indexPath.item >= 0,
                       indexPath.item < reelsArray.count,
                        let urlString = reelsArray[indexPath.item].media,
                       let videoURL = URL(string: urlString) {
                        // Do something with the cell at the given index path
                        let asset = AVAsset(url: videoURL)
                        let playerItem = AVPlayerItem(asset: asset)
                        // Configure the player to preload the video
                        queuePlayer.insert(playerItem, after: queuePlayer.currentItem )
                    }
                }
            }
        }

        delegate?.currentPlayingVideoChanged(newIndex: indexPath)

        if isWatchingRotatedVideos {
            return
        }

        if let skeletonCell = cell as? ReelsSkeletonAnimation {
            skeletonCell.showLoader()
        }
        if reelsArray.count > 0, indexPath.item == setReelAPIHitLogic() { // numberofitem count
            callWebsericeToGetNextVideos()
        }

        (cell as? ReelsCC)?.setImage()
    }

    func setReelAPIHitLogic() -> Int {
        if reelsArray.count >= 10 {
            return reelsArray.count - 8
        } else {
            return reelsArray.count / 2
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        if showSkeletonLoader {
            return collectionView.frame.size
        }
        let lineSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height - lineSpacing)
    }

    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if isWatchingRotatedVideos == false {
            return proposedContentOffset
        }

        let attrs = collectionView.layoutAttributesForItem(at: currentlyPlayingIndexPath)

        let newOriginForOldIndex = attrs?.frame.origin

        return newOriginForOldIndex ?? proposedContentOffset
    }
}


// MARK: - ReelsVC + ReelsCCDelegate

extension ReelsVC: ReelsCCDelegate {
    func didTapOpenSource(cell _: ReelsCC) {}

    func didSwipeRight(cell: ReelsCC) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        pauseCellVideo(indexPath: indexPath)

        if isRightMenuLoaded == false {
            setupSideMenu()
            if let rightMenuNavigationController = rightMenuNavigationController {
                present(rightMenuNavigationController, animated: true, completion: nil)
            }
        }
    }

    func didTapViewMore(cell: ReelsCC) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        pauseCellVideo(indexPath: indexPath)

        let reel = reelsArray[currentlyPlayingIndexPath.item]

        let bullet = [Bullets(data: reel.reelDescription, audio: nil, duration: nil, image: nil)]
        let content = articlesData(id: reel.id, title: reel.reelDescription, media: reel.media, image: reel.image, link: reel.media, original_link: reel.link, color: nil, publish_time: reel.publishTime, source: reel.source, bullets: bullet, topics: nil, status: nil, mute: nil, type: Constant.newsArticle.ARTICLE_TYPE_REEL, meta: nil, info: nil, media_meta: reel.mediaMeta)

        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.selectedArticleData = content
        vc.delegate = self
        vc.isSwipeToDismissRequired = true
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .overFullScreen

        if MyThemes.current == .dark {
            isOpenedLightMode = true
            MyThemes.switchTo(theme: .light)
        }
        isViewControllerVisible = false
        present(navVC, animated: true, completion: nil)
    }

    func didTapComment(cell: ReelsCC) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        stopVideo()
        isViewControllerVisible = false
        appDelegate.setOrientationPortraitInly()

        let content = reelsArray[indexPath.item]
        let vc = CommentsVC.instantiate(fromAppStoryboard: .Home)
        vc.articleID = content.id ?? ""
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        navVC.modalPresentationStyle = .overFullScreen
        present(navVC, animated: true, completion: nil)
    }

    func didTapLike(cell: ReelsCC) {
        if isLikeApiRunning {
            return
        }

        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        var likeCount = reelsArray[indexPath.item].info?.likeCount

        if reelsArray[indexPath.item].info?.isLiked ?? false {
            likeCount = (likeCount ?? 0) - 1
        } else {
            likeCount = (likeCount ?? 0) + 1
        }

        let info = Info(viewCount: reelsArray[indexPath.item].info?.viewCount, likeCount: likeCount, commentCount: reelsArray[indexPath.item].info?.commentCount, isLiked: !(reelsArray[indexPath.item].info?.isLiked ?? false))
        reelsArray[indexPath.item].info = info
        cell.setLikeComment(model: reelsArray[indexPath.item].info, showAnimation: true)

        performWSToLikePost(article_id: reelsArray[indexPath.item].id ?? "", isLike: reelsArray[indexPath.item].info?.isLiked ?? false)
    }

    func didTapViewMoreOptions(cell: ReelsCC) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let content = reelsArray[indexPath.item]
        // Open action sheet for share
        pauseCellVideo(indexPath: indexPath)
        performWSToShare(indexPath: indexPath, id: content.id ?? "", isOpenViewMoreOptions: true)
    }

    func didTapShare(cell: ReelsCC) {
        downloadVideoInLocal()

        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let content = reelsArray[indexPath.item]

        pauseCellVideo(indexPath: indexPath)
        performWSToShare(indexPath: indexPath, id: content.id ?? "", isOpenViewMoreOptions: false)
    }

    func didTapEditArticle(cell: ReelsCC) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        pauseCellVideo(indexPath: indexPath)

        let vc = BottomSheetArticlesVC.instantiate(fromAppStoryboard: .Main)
        vc.index = cell.btnEditArticle.tag
        vc.isFromReels = true
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }

    func didTapOpenCaptionType(cell: ReelsCC, action: String) {
        let actionArr = action.components(separatedBy: "/")
        if actionArr.count == 2 {
            let aId = actionArr.last ?? ""

            if action.contains("topic") {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.topicOpen, eventDescription: "")
                cell.isUserInteractionEnabled = false

                performWSToOpenTopics(id: aId, title: "", favorite: false)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    cell.isUserInteractionEnabled = true
                }
            } else if action.contains("source") {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
                cell.isUserInteractionEnabled = false

                performGoToSource(id: aId)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    cell.isUserInteractionEnabled = true
                }
            } else if action.contains("author") {
                if aId == SharedManager.shared.userId {
                    let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen

                    present(navVC, animated: true, completion: nil)
                } else {
                    let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                    vc.authors = [Authors(id: aId, context: nil, name: nil, username: nil, image: nil, favorite: nil)]
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen

                    present(navVC, animated: true, completion: nil)
                }
            }
        }
    }

    func didTapAuthor(cell: ReelsCC) {
        let index = cell.btnAuthor.tag

        if reelsArray[index].source != nil {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
            cell.isUserInteractionEnabled = false

            performGoToSource(id: reelsArray[index].source?.id ?? "")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                cell.isUserInteractionEnabled = true
            }

        } else if let authors = reelsArray[index].authors, authors.count > 0 {
            let aId = authors.first?.id ?? ""
            if aId == SharedManager.shared.userId {
                let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
                let navVC = AppNavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen

                present(navVC, animated: true, completion: nil)
            } else {
                let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                vc.authors = authors
                let navVC = AppNavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen

                present(navVC, animated: true, completion: nil)
            }
        }
    }

    func didTapFollow(cell: ReelsCC, tagNo: Int) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        if tagNo == 0 {
            var FullResponse: ReelsModel?
            // Follow
            if reelsArray[indexPath.item].source?.favorite ?? false {
                cell.btnUserPlus.setTitle("Following", for: .normal)
                cell.btnUserPlusWidth.constant = 90
                cell.btnUserPlus.layoutIfNeeded()
                cell.followStack.layoutIfNeeded()
            } else {
                cell.btnUserPlus.setTitle("Follow", for: .normal)
                cell.btnUserPlusWidth.constant = 70
                cell.btnUserPlus.layoutIfNeeded()
                cell.followStack.layoutIfNeeded()
            }
            cell.btnUserPlus.isUserInteractionEnabled = false

            if let source = reelsArray[indexPath.item].source {
                let fav = source.favorite ?? false
                cell.btnUserPlus.showLoader()
                SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [source.id ?? ""], isFav: !fav, type: .sources) { status in
                    
                    cell.btnUserPlus.isUserInteractionEnabled = true
                    if status {
                        self.reelsArray[indexPath.item].source?.favorite = !fav
                        cell.reelModel = self.reelsArray[indexPath.item]
                        // update all cells
                        for (indexP, rl) in self.reelsArray.enumerated() {
                            if rl.source?.id == self.reelsArray[indexPath.item].source?.id {
                                self.reelsArray[indexP].source?.favorite = !fav
                            }
                        }
                        DispatchQueue.main.async {
                            cell.btnUserPlus.hideLoaderView()
                            if !fav {
                                cell.btnUserPlus.setTitle("Following", for: .normal)
                                cell.btnUserPlusWidth.constant = 90
                                cell.btnUserPlus.layoutIfNeeded()
                                cell.followStack.layoutIfNeeded()
                            } else {
                                cell.btnUserPlus.setTitle("Follow", for: .normal)
                                cell.btnUserPlusWidth.constant = 70
                                cell.btnUserPlus.layoutIfNeeded()
                                cell.followStack.layoutIfNeeded()
                            }
                        }
                        FullResponse?.reels = self.reelsArray
                        self.writeToCache(response: FullResponse)
                     } else {
                        print("failed")
                    }
                }
            } else {
                let id = reelsArray[indexPath.item].authors?.first?.id ?? ""
                let fav = reelsArray[indexPath.item].authors?.first?.favorite ?? false
                if (reelsArray[indexPath.item].authors?.count ?? 0) > 0 {
                    reelsArray[indexPath.item].authors?[0].favorite = !fav
                }
                cell.reelModel = reelsArray[indexPath.item]
                // update all cells
                                for (indexP, rl) in reelsArray.enumerated() {
                                    if rl.source?.id == reelsArray[indexPath.item].source?.id {
                                        reelsArray[indexP].source?.favorite = !fav
                                    }
                                }

                

                cell.btnUserPlus.showLoader()
                SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [id], isFav: !fav, type: .authors) { status in
                    
                    cell.btnUserPlus.isUserInteractionEnabled = true
                    if status {
                        self.reelsArray[indexPath.item].source?.favorite = !fav
                        cell.reelModel = self.reelsArray[indexPath.item]
                        // update all cells
                        for (indexP, rl) in self.reelsArray.enumerated() {
                            if rl.source?.id == self.reelsArray[indexPath.item].source?.id {
                                self.reelsArray[indexP].source?.favorite = !fav
                                if let cellP = self.collectionView.cellForItem(at: IndexPath(item: indexP, section: 0)) as? ReelsCC {
                                    cellP.reelModel?.source?.favorite = !fav
                                    cellP.setFollowButton(hidden: cellP.reelModel?.source?.favorite ?? false)
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            cell.btnUserPlus.hideLoaderView()
                            if !fav {
                                cell.btnUserPlus.setTitle("Following", for: .normal)
                                cell.btnUserPlusWidth.constant = 90
                                cell.btnUserPlus.layoutIfNeeded()
                                cell.followStack.layoutIfNeeded()
                            } else {
                                cell.btnUserPlus.setTitle("Follow", for: .normal)
                                cell.btnUserPlusWidth.constant = 70
                                cell.btnUserPlus.layoutIfNeeded()
                                cell.followStack.layoutIfNeeded()
                            }
                        }
                        FullResponse?.reels = self.reelsArray
                        self.writeToCache(response: FullResponse)
                     } else {
                        print("failed")

                    }
                }
            }
        } else {
            // view
            didTapAuthor(cell: cell)
        }
    }

    func didTapHashTag(cell _: ReelsCC, text: String) {
//        let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
//
//        vc.titleText = "#\(text)"
//        vc.isBackButtonNeeded = true
//        vc.modalPresentationStyle = .fullScreen
//        vc.delegate = self
//        vc.isOpenFromTags = true
//        let nav = AppNavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        present(nav, animated: true, completion: nil)
    }

    func didSingleTapDetected(cell: ReelsCC) {
        didTapViewMore(cell: cell)
    }

    func videoVolumeStatusChanged(cell _: ReelsCC) {}

    func videoPlayingStarted(cell _: ReelsCC) {}

    func videoPlayingFinished(cell: ReelsCC) {
        if isOpenfromNotificationList {
            sendVideoViewedAnalyticsEvent()
            if SharedManager.shared.reelsAutoPlay {
                playCurrentCellVideo()
            }
            return
        }

        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelsFinishedPlaying, eventDescription: "", article_id: reelsArray[indexPath.item].id ?? "")

        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelsDurationEvent, eventDescription: "", article_id: reelsArray[indexPath.item].id ?? "", duration: cell.playerLayer.player?.totalDuration.formatToMilliSeconds() ?? "")

        if isFromChannelView, indexPath.item == reelsArray.count - 1 {
            let nextIndexPath = IndexPath(item: 0, section: 0)
            playNextCellVideo(indexPath: nextIndexPath)
        } else if isShowingProfileReels, indexPath.item == reelsArray.count - 1 {
            let nextIndexPath = IndexPath(item: 0, section: 0)
            playNextCellVideo(indexPath: nextIndexPath)
        } else if isSugReels, indexPath.item == reelsArray.count - 1 {
            let nextIndexPath = IndexPath(item: 0, section: 0)
            playNextCellVideo(indexPath: nextIndexPath)
        }
        // If Last item, scroll to first item
        else if indexPath.item == reelsArray.count - 5, reelsArray.count > 1 {
            callWebsericeToGetNextVideos()
        } else if reelsArray.count > 0 {
            let nextIndexPath = IndexPath(item: indexPath.item + 1, section: 0)
            if nextIndexPath.item < reelsArray.count {
                playNextCellVideo(indexPath: nextIndexPath)
            }
        }
    }

    func didPangestureDetected(cell _: ReelsCC, panGesture: UIPanGestureRecognizer, view: UIView) {
        onPan(panGesture, translationView: view)
    }

    func didTapRotateVideo(cell: ReelsCC) {
        if MediaManager.sharedInstance.isLandscapeReelPresenting {
            return
        }

        if reelsArray.count == 0 {
            return
        }

        if isViewControllerVisible == false {
            return
        }

        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        if let url = URL(string: reelsArray[indexPath.item].media_landscape ?? "") {
            stopVideo()
            isWatchingRotatedVideos = true
            collectionView.alpha = 0
            viewCategoryType.alpha = 0
            let vc = ReelsFullScreenVC.instantiate(fromAppStoryboard: .Reels)
            vc.imgPlaceHolder = cell.imgThumbnailView
            vc.url = url
            vc.modalPresentationStyle = .fullScreen
            vc.customDuration = CMTime(seconds: cell.playerLayer.player?.currentDuration ?? 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

            // captions
            vc.captions = reelsArray[indexPath.item].captions
            vc.delegate = self
            MediaManager.sharedInstance.isLandscapeReelPresenting = true

            vc.modalPresentationStyle = .overFullScreen
            (UIApplication.shared.delegate as! AppDelegate).setOrientationBothLandscape()
            present(vc, animated: true, completion: nil)
        }
    }

    func didTapPlayVideo(cell: ReelsCC) {
        cell.viewPlayButton.isHidden = true
        playCurrentCellVideo()
    }

    func didTapCaptions(cell _: ReelsCC) {
     }
}
