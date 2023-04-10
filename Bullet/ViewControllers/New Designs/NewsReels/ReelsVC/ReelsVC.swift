//
//  ReelsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 29/03/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import AppTrackingTransparency
import AVFAudio
import DataCache
import PanModal
import Reachability
import SideMenu
import UIKit

// MARK: - ReelsVCDelegate

protocol ReelsVCDelegate: AnyObject {
    func backButtonPressed(_ isUpdateSavedArticle: Bool)
    func loaderShowing(status: Bool)
    func switchBackToForYou()

    func changeScreen(pageIndex: Int)

    func currentPlayingVideoChanged(newIndex: IndexPath)
}

// MARK: - ReelsVC

class ReelsVC: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var viewBack: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var viewCategoryType: UIView!
    @IBOutlet var lblCategoryType: UILabel!
    @IBOutlet var viewEmptyMessage: UIView!
    @IBOutlet var lblEmptyMessage: UILabel!
    @IBOutlet var btnContinue: UIButton!
    @IBOutlet var imgArrow: UIImageView!
    @IBOutlet var indicator: InstagramActivityIndicator!
    @IBOutlet var viewIndicator: UIView!
    @IBOutlet var imgLeftArrow: UIImageView!
    @IBOutlet var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var lblRefreshLabel: UILabel!
    @IBOutlet var viewRefreshContainer: UIView!
    @IBOutlet var loaderView: UIView!
    @IBOutlet var refreshLoaderView: UIView!
    @IBOutlet var allCaughtUpView: UIStackView!

    weak var delegate: ReelsVCDelegate?
    public var minimumVelocityToHide: CGFloat = 1500
    public var minimumScreenRatioToHide: CGFloat = 0.5
    public var animationDuration: TimeInterval = 0.2
    var reelsArray = [Reel]()
    var currentlyPlayingIndexPath = IndexPath(item: 0, section: 0)
    var nextPageData = ""
    var isApiCallAlreadyRunning = false
    var isFirtTimeLoaded = false
    var isViewDidAppear = false
    let offset: CGFloat = -50
    var isViewControllerVisible = false
    var isBackButtonNeeded = false
    var contextID = ""
    var isLikeApiRunning = false
    var titleText = ""
    var isShowingProfileReels = false
    var isFromChannelView = false
    var isFromDiscover = false
    var userSelectedIndexPath = IndexPath(item: 0, section: 0)
    var authorID = ""
    var scrollToItemFirstTime = false
    var channelInfo: ChannelInfo?
    var isSugReels = false
    var currentPageIndex = 0
    var isOnFollowing = false
    var isShareSheetPresenting = false
    var isArchived = false
    var DocController = UIDocumentInteractionController()
    var currentCategory = 0
    var controller: SideMenuContainerVC!
    var rightMenuNavigationController: SideMenuNavigationController?
    var isRightMenuLoaded = false
    var isOpenFromTags = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isOpenfromNotificationList = false
    var mediaWatermark = MediaWatermark()
    var isWatchingRotatedVideos = false
    let reelsRefreshTimeNeeded: CGFloat = 2
    var showSkeletonLoader = false
    var isCurrentlyScrolling = false
    var refreshMaximumSpace: CGFloat = 100
    var isRefreshingReels = false
    var shareTitle = ""
    var articleArchived = false
    var sourceBlock = false
    var sourceFollow = false
    var isOpenedLightMode = false
    var isOpenedFollowingPrefernce = false
    var fromMain = false
    var currentCachePosition = 1
    var cacheLimit = 10
    var isPullToRefresh = false
    var reachability: Reachability?
    var isNoInternet = false
    var scrollTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionView()
        checkInternetConnection()
        // Do any additional setup after loading the view.
        _ = try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)

        if fromMain {
            loadNewData()
            getReelsCategories()
        }
        SharedManager.shared.isReelsLoadedFirstTime = true
    }

    override func viewWillAppear(_: Bool) {
        (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()

        if isWatchingRotatedVideos {
            return
        }
        setupNotification()
        _ = try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
        _ = try? AVAudioSession.sharedInstance().setActive(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ANLoader.hide()
        }

        if isBackButtonNeeded == false {
            if let ptcTBC = tabBarController as? PTCardTabBarController {
                ptcTBC.showTabBar(true, animated: false)
            }
        }

        if SharedManager.shared.reloadRequiredFromTopics {
            setRefresh(scrollView: collectionView, manual: true)
            SharedManager.shared.reloadRequiredFromTopics = false
        }

        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            if SharedManager.shared.reelsAutoPlay {
                cell.viewPlayButton.isHidden = true
            } else {
                cell.viewPlayButton.isHidden = false
                stopVideo()
            }
        }

        if isFirtTimeLoaded {
            if reelsArray.count > 0 {
                sendVideoViewedAnalyticsEvent()

                if SharedManager.shared.reelsAutoPlay {
                    if isWatchingRotatedVideos {
                        // Resume videos
                    } else {
                        playCurrentCellVideo()
                    }
                } else {
                    // Reset Current cell
                    stopVideo()
                }
            }

            if isBackButtonNeeded == false {
                if reelsArray.count == 0 {
                    loadNewData()
                } else if SharedManager.shared.getSelectedReelsCategory() != currentCategory {
                    loadNewData()
                } else if currentCategory == 1, SharedManager.shared.isReelsFollowingNeedRefresh {
                    loadNewData()
                } else {
                    if SharedManager.shared.minutesBetweenDates(SharedManager.shared.lastBackgroundTimeReels ?? Date(), Date()) >= reelsRefreshTimeNeeded, reelsArray.count > 0 {
                        if SharedManager.shared.tabBarIndex == 0, isShowingProfileReels == false, isFromChannelView == false {
                            collectionView.setContentOffset(.zero, animated: false)
                            beginRefreshingWithAnimation(isLoadingBackground: false)
                        }

                    } else if reelsArray.count > 0 {
                        sendVideoViewedAnalyticsEvent()

                        if SharedManager.shared.reelsAutoPlay {
                            if isWatchingRotatedVideos {
                                // Resume videos
                            } else {
                                playCurrentCellVideo()
                            }
                        }
                    }
                }
            }
        }

        isFirtTimeLoaded = true
        isViewDidAppear = false
        isViewControllerVisible = true

        SharedManager.shared.isReelsFollowingNeedRefresh = false
        if isOnFollowing {
            SharedManager.shared.isFollowingTabReelsReload = false
        } else {
            SharedManager.shared.isForYouTabReelsReload = false
        }

        setupForCallMethod()

        SharedManager.shared.lastBackgroundTimeReels = Date()

        if appDelegate.shouldResetReels {
            reloadDataFromBG()
            appDelegate.shouldResetReels = false
        }
    }

    override func viewDidAppear(_: Bool) {
        setStatusBar()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.getArticleDataPayLoad()
        }
        SharedManager.shared.isFirstimeSplashScreenLoaded = true

        (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()

        if scrollToItemFirstTime {
            currentlyPlayingIndexPath = userSelectedIndexPath
        }

        isViewDidAppear = true
        scrollToItemFirstTime = false

        isWatchingRotatedVideos = false

        MediaManager.sharedInstance.isLandscapeReelPresenting = false

        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in

                switch status {
                case .authorized:
                    // Authorized
                    break
                case .denied,
                     .notDetermined,
                     .restricted:
                    break
                @unknown default:
                    break
                }
            }
        }
    }

    override func viewWillDisappear(_: Bool) {
        ANLoader.hide()

        SharedManager.shared.lastBackgroundTimeReels = Date()
    }

    override func viewDidDisappear(_: Bool) {
        ANLoader.hide()
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.removeObserver(self)
        DispatchQueue.main.async {
            if let cell = self.collectionView.cellForItem(at: self.currentlyPlayingIndexPath) as? ReelsCC {
                cell.player.destroy()
            }
        }
        
        isViewDidAppear = false
        isViewControllerVisible = false

        if indicator.isAnimating {
            indicator.stopAnimating()
            indicator.isHidden = true
            viewIndicator.isHidden = true
        }

        if reelsArray.count == 0 && isShowingProfileReels == false && isFromChannelView == false {
            SharedManager.shared.isForYouTabReelsReload = true
            SharedManager.shared.isFollowingTabReelsReload = true
        }
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let presentableController = viewControllerToPresent as? PanModalPresentable, let controller = presentableController as? UIViewController, UIDevice.current.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .custom
            controller.modalPresentationCapturesStatusBarAppearance = true
            controller.transitioningDelegate = PanModalPresentationDelegate.default
            super.present(controller, animated: flag, completion: completion)
            return
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if isWatchingRotatedVideos {
            return
        }

        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.invalidateLayout()

        if scrollToItemFirstTime {
            if userSelectedIndexPath.item < reelsArray.count {
                collectionView.layoutIfNeeded()

                collectionView.scrollToItem(at: userSelectedIndexPath, at: .centeredVertically, animated: false)
            }
        }
    }

    @IBAction func didTapCategory(_: Any) {
        currentCategory = SharedManager.shared.getSelectedReelsCategory()

        let vc = ReelsCategoryVC.instantiate(fromAppStoryboard: .Reels)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }

    @IBAction func didTapBack(_: Any) {
        SharedManager.shared.isOnDiscover = true
        if isShowingProfileReels || isFromChannelView {
            ReelsCacheManager.shared.reelViewedOnChannelPage = true
            navigationController?.popViewController(animated: true)
        } else if isFromDiscover {
            navigationController?.popViewController(animated: true)
            ReelsCacheManager.shared.clearDiskCache()
            SharedManager.shared.reloadRequiredFromTopics = true
            return
        } else if isSugReels {
            dismiss(animated: true, completion: nil)
        } else {
            ReelsCacheManager.shared.clearDiskCache()
            SharedManager.shared.reloadRequiredFromTopics = true
            dismiss(animated: true, completion: nil)
            return
        }

        reelsArray.removeAll()
        collectionView.reloadData()
        nextPageData = ""
        performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.curReelsCategoryId)

        delegate?.backButtonPressed(isArchived)
    }

    @IBAction func didTapStartFollowing(_: Any) {
        didTapFilter(isTabNeeded: false)
    }
}

extension ReelsVC {
    @objc func reloadDataFromBG() {
        reelsArray.removeAll()
        collectionView.reloadData()
        nextPageData = ""
        performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.curReelsCategoryId)
    }

    @objc func playerInterruption(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        if type == .began {
            stopVideo()

        } else {
            if SharedManager.shared.reelsAutoPlay {
                playCurrentCellVideo()
            }
        }
    }

    @objc func autohideloader() {
        SharedManager.shared.hideLaoderFromWindow()
    }

    @objc func appMovedToBackground() {
        stopVideo()

        SharedManager.shared.lastBackgroundTimeReels = Date()
    }

    @objc func appWillLoadForeground() {
        SharedManager.shared.isFromPNBackground = true
        if isViewControllerVisible == false {
            return
        }

        if isBackgroundRefreshRequired() {
            stopVideo()
            SharedManager.shared.showLoaderInWindow()
        } else {
            SharedManager.shared.hideLaoderFromWindow()
        }
    }

    @objc func appMovedToForeground() {
        if isViewControllerVisible == false {
            return
        }
        if isBackgroundRefreshRequired() {
            stopVideo()
            collectionView.setContentOffset(.zero, animated: false)

            SharedManager.shared.showLoaderInWindow()

            loadNewData()

            perform(#selector(autohideloader), with: nil, afterDelay: 5)

        } else {
            SharedManager.shared.hideLaoderFromWindow()
            if reelsArray.count > 0 {
                if isRightMenuLoaded == false, isShareSheetPresenting == false {
                    if SharedManager.shared.reelsAutoPlay {
                        playCurrentCellVideo()
                    }
                }
            }
        }
    }

    @objc func getArticleDataPayLoad() {
        if SharedManager.shared.reelsContextNotification != "" {
            if SharedManager.shared.isFromPNBackground {
                reelsArray.removeAll()
                collectionView.reloadData()
                nextPageData = ""
                SharedManager.shared.isAppLaunchedThroughNotification = false
                performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.reelsContextNotification)
                SharedManager.shared.isFromPNBackground = false
            }
            SharedManager.shared.reelsContextNotification = ""
        }
    }

    @objc func changeReelsDataLanguage() {
        LanguageHelper.shared.performWSToUpdateUserContentLanguages(isPrimary: true) {
            SharedManager.shared.performWSToUpdateLanguage(id: LanguageHelper.shared.getSavedLanguage()?.id ?? "", isRefreshedToken: true, completionHandler: { status in
                if status {
                    DispatchQueue.main.async {
                        self.loadNewData()
                    }
                } else {}
            })
        }
    }

    @objc func stopVideo() {
        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            cell.stopVideo()
//            cell.pause()
        }
    }

    @objc func reelsOrientationChange() {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            if reelsArray.count == 0 {
                return
            }
            if isRightMenuLoaded {
                return
            }
            if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
                didTapRotateVideo(cell: cell)
            }
        }
    }

    @objc func tabBarTapped(notification _: Notification) {
        if isViewDidAppear == false {
            return
        }
        if isShowingProfileReels || isSugReels || contextID != "" {
            return
        }
        let indexPath = IndexPath(item: 0, section: 0)
        UIView.animate(withDuration: 0.5) {} completion: { _ in
            self.reelsArray.removeAll()
            self.collectionView.reloadData()
            self.setRefresh(scrollView: self.collectionView, manual: true)
            if let cell = self.collectionView.cellForItem(at: indexPath) as? ReelsCC {
                self.currentlyPlayingIndexPath = indexPath
                if SharedManager.shared.reelsAutoPlay {
                    cell.viewPlayButton.isHidden = true
                    self.playCurrentCellVideo()
                } else {
                    cell.viewPlayButton.isHidden = false
                    cell.stopVideo()
                }
            }
        }
    }

    @objc func refreshCollectionViewCells(isLoadingBackground: Bool) {
        // Alredy at top
        // refresh collectionview
        if isApiCallAlreadyRunning == false {
            nextPageData = ""

            if isLoadingBackground {
                stopVideo()
                SharedManager.shared.showLoaderInWindow()
            }

            if isLoadingBackground == false {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }

            if SharedManager.shared.reelsContextNotification != "" {
                performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.reelsContextNotification)
            } else {
                performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.curReelsCategoryId)
            }

        } else {
            stopPullToRefresh()
            SharedManager.shared.hideLaoderFromWindow()
        }
    }
}
