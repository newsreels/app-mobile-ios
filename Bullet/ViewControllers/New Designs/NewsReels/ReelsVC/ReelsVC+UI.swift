//
//  ReelsVC+UI.swift
//  Bullet
//
//  Created by Osman Ahmed on 05/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import AVFoundation
import SideMenu
import UIKit

extension ReelsVC {
    func setupView() {
        allCaughtUpView.isHidden = true
        ANLoader.hide()
        isViewControllerVisible = true
        registerCells()
        setupUI()

        btnContinue.backgroundColor = Constant.appColor.lightRed

        viewEmptyMessage.isHidden = true

        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.002)
        setupSideMenu()

        if isOpenfromNotificationList {
            collectionView.bounces = false
            collectionView.alwaysBounceVertical = false
            collectionView.bouncesZoom = false

            collectionView.isScrollEnabled = false
            collectionView.isPagingEnabled = false
        } else {
            collectionView.isScrollEnabled = true
            collectionView.isPagingEnabled = true
        }

        if isShowingProfileReels || isSugReels || contextID != "" {
            collectionView.bounces = false
            collectionView.bouncesZoom = false
        }
    }

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0 // Set the horizontal spacing between items
        layout.minimumLineSpacing = 0 // Set the vertical spacing between items
        collectionView.collectionViewLayout = layout // Assign the layout to your UICollectionView
    }

    func setupForCallMethod() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerInterruption), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
    }

    func setStatusBar() {
        var navVC = (navigationController?.navigationController as? AppNavigationController)
        if navVC == nil {
            navVC = (navigationController as? AppNavigationController)
        }

        if reelsArray.count == 0 {
            if navVC?.showDarkStatusBar == true {
                navVC?.showDarkStatusBar = false
                navVC?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    func setupUI() {
        collectionView.backgroundColor = .clear

        indicator.animationDuration = 1.0
        indicator.rotationDuration = 3
        indicator.numSegments = 15
        indicator.strokeColor = "#E01335".hexStringToUIColor()
        indicator.lineWidth = 3

        btnContinue.backgroundColor = Constant.appColor.lightRed

        if isBackButtonNeeded {
            viewBack.isHidden = false
            lblTitle.isHidden = false

            let titleTxt = titleText == "" ? "" : titleText
            addShadowText(label: lblTitle, text: titleTxt, font: UIFont(name: Constant.FONT_Mulli_BOLD, size: 25)!, spacing: 1)

            viewCategoryType.isHidden = true

            btnContinue.setTitle(NSLocalizedString("Follow", comment: ""), for: .normal)

            btnContinue.isHidden = true
        } else {
            viewBack.isHidden = true
            lblTitle.isHidden = true
            lblTitle.text = ""

            viewCategoryType.isHidden = false

            btnContinue.setTitle(NSLocalizedString("Follow", comment: ""), for: .normal)

            btnContinue.isHidden = false
        }

        setUpSelectedCategory()

        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true

        collectionView.layoutIfNeeded()

        imgArrow.layer.shadowColor = UIColor.black.cgColor
        imgArrow.layer.shadowOffset = CGSize(width: 0, height: 1)
        imgArrow.layer.shadowOpacity = 0.5

        imgLeftArrow.layer.shadowColor = UIColor.black.cgColor
        imgLeftArrow.layer.shadowOffset = CGSize(width: 0, height: 1)
        imgLeftArrow.layer.shadowOpacity = 0.5

        viewRefreshContainer.isHidden = true
    }

    func setupSideMenu() {
        if isSugReels || isShowingProfileReels || isFromChannelView {
            return
        }

        controller = SideMenuContainerVC.instantiate(fromAppStoryboard: .Reels)
        rightMenuNavigationController = SideMenuNavigationController(rootViewController: controller)
        rightMenuNavigationController!.navigationBar.isHidden = true
        rightMenuNavigationController!.sideMenuDelegate = self
        SideMenuManager.default.rightMenuNavigationController = rightMenuNavigationController

        rightMenuNavigationController!.settings = makeSettings()
    }

    private func makeSettings() -> SideMenuSettings {
        let presentationStyle = SideMenuPresentationStyle.menuSlideIn

        var settings = SideMenuSettings()
        settings.dismissOnPush = false
        settings.dismissOnPresent = false
        settings.presentationStyle = presentationStyle
        settings.menuWidth = view.frame.width
        settings.presentingViewControllerUseSnapshot = false
        settings.pushStyle = .subMenu
        settings.dismissOnRotation = false
        settings.presentingViewControllerUseSnapshot = false

        return settings
    }

    func setUpSelectedCategory() {
        if SharedManager.shared.getSelectedReelsCategory() == 0 {
            addShadowText(label: lblCategoryType, text: NSLocalizedString("For You", comment: "").capitalized, font: UIFont(name: Constant.FONT_Mulli_BOLD, size: 20)!, spacing: 1)
        } else if SharedManager.shared.getSelectedReelsCategory() == 1 {
            addShadowText(label: lblCategoryType, text: NSLocalizedString("Following", comment: "").capitalized, font: UIFont(name: Constant.FONT_Mulli_BOLD, size: 20)!, spacing: 1)
        } else {
            addShadowText(label: lblCategoryType, text: NSLocalizedString("Community", comment: "").capitalized, font: UIFont(name: Constant.FONT_Mulli_BOLD, size: 20)!, spacing: 1)
        }

        currentCategory = SharedManager.shared.getSelectedReelsCategory()
    }

    func addShadowText(label: UILabel, text: String, font: UIFont, spacing: CGFloat) {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 2

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .shadow: shadow,
            .kern: spacing,
        ]

        let s = text
        let attributedText = NSAttributedString(string: s, attributes: attrs)
        label.attributedText = attributedText

        label.layoutIfNeeded()
    }

    func registerCells() {
        collectionView.register(UINib(nibName: "ReelsCC", bundle: nil), forCellWithReuseIdentifier: "ReelsCC")
        collectionView.register(UINib(nibName: "ReelsPhotoAdCC", bundle: nil), forCellWithReuseIdentifier: "ReelsPhotoAdCC")
        collectionView.register(UINib(nibName: "ReelsSkeletonAnimation", bundle: nil), forCellWithReuseIdentifier: "ReelsSkeletonAnimation")
    }
}

extension ReelsVC {
    func scrollViewWillBeginDragging(_: UIScrollView) {
        isCurrentlyScrolling = true

        if isRefreshingReels == false {
            collectionViewTopConstraint.constant = 0
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isCurrentlyScrolling = true
        if isOpenfromNotificationList {
            // Disable scroll
            collectionView.setContentOffset(.zero, animated: false)
        }
        if isApiCallAlreadyRunning {
            return
        }

        if scrollView.panGestureRecognizer.state == .began || scrollView.panGestureRecognizer.state == .changed {
            if isRefreshingReels == false {
                if scrollView.contentOffset.y <= 0 {
                    viewRefreshContainer.isHidden = false
                    if collectionViewTopConstraint.constant < refreshMaximumSpace {
                        collectionViewTopConstraint.constant += 5
                        lblRefreshLabel.text = "" // "Pull to refresh"
                        loaderView.hideLoaderView()
                    } else {
                        lblRefreshLabel.text = "Release to refresh"
                        loaderView.hideLoaderView()
                        collectionViewTopConstraint.constant = refreshMaximumSpace
                    }
                } else {
                    collectionViewTopConstraint.constant -= 2.5
                    if collectionViewTopConstraint.constant <= 0 {
                        collectionViewTopConstraint.constant = 0
                    }
                }
            }
        }

        if scrollView.contentOffset.y >= (scrollView.contentSize.height + 50 - scrollView.frame.size.height) {
            allCaughtUpView.isHidden = false
        } else {
            allCaughtUpView.isHidden = true
        }

    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if lblRefreshLabel.text == "Release to refresh" {
            isPullToRefresh = true
            loadNewData()
        }

        if isRefreshingReels == false {
            collectionViewTopConstraint.constant = 0
            collectionView.layoutIfNeeded()
        }

        isCurrentlyScrolling = false
        if isWatchingRotatedVideos {
            return
        }

        if isOpenfromNotificationList == false {
            if scrollView.contentOffset.y < collectionView.frame.size.height / 2, currentlyPlayingIndexPath.item == 0 {
                scrollView.contentOffset.y = 0
                playCurrentCellVideo()
            } else {
                getCurrentVisibleIndexPlayVideo()
            }
        }

        delegate?.currentPlayingVideoChanged(newIndex: currentlyPlayingIndexPath)
    }

    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate _: Bool) {
        //slow scroll
        scrollTimer?.invalidate()
        view.isUserInteractionEnabled = false
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.view.isUserInteractionEnabled = true
        }
    }

    func setRefresh(scrollView _: UIScrollView, manual: Bool) {
        if isRefreshingReels {
            return
        }
        stopAllPlayers()
        if manual || collectionViewTopConstraint.constant >= refreshMaximumSpace {
            UIView.animate(withDuration: 0.25) {
                self.collectionViewTopConstraint.constant = self.refreshMaximumSpace
                self.lblRefreshLabel.text = "" // "Loading ..."
                self.loaderView.showLoader(color: Constant.appColor.lightRed)
            }
            viewRefreshContainer.isHidden = false
            isRefreshingReels = true

            collectionView.isUserInteractionEnabled = false
            refreshCollectionViewCells(isLoadingBackground: false)
        } else {
            collectionView.isUserInteractionEnabled = true
            viewRefreshContainer.isHidden = true
            isRefreshingReels = false
            UIView.animate(withDuration: 0.25) {
                self.collectionViewTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }

    func stopPullToRefresh() {
        lblRefreshLabel.text = "Refreshed"
        loaderView.hideLoaderView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if self.isRefreshingReels {
                self.collectionView.isUserInteractionEnabled = false
            }
            UIView.animate(withDuration: 0.05) {
                self.collectionViewTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.viewRefreshContainer.isHidden = true
                self.isRefreshingReels = false
                self.collectionView.isUserInteractionEnabled = true
            }
        }
    }

    func beginRefreshingWithAnimation(isLoadingBackground _: Bool) {
        if isApiCallAlreadyRunning {
            SharedManager.shared.hideLaoderFromWindow()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if self.isApiCallAlreadyRunning {
                SharedManager.shared.hideLaoderFromWindow()
                return
            }
        }
    }
}

// MARK: - Slide to show Details Page

extension ReelsVC {
    // MARK: - Swipe to dismiss methods

    func slideViewHorizontalTo(_: CGFloat, reset _: Bool) {}

    @objc func onPan(_ panGesture: UIPanGestureRecognizer, translationView _: UIView) {
        switch panGesture.state {
        case .began, .changed:
            let translation = panGesture.translation(in: view)
            let x = translation.x
             slideViewHorizontalTo(x, reset: false)

        default:

            break
        }
    }
}
