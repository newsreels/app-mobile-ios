//
//  ReelsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 29/03/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation
import AppTrackingTransparency
import SideMenu
import Photos
import AVKit
import MobileCoreServices
import MediaWatermark
import MessageUI
import FBSDKShareKit
//import SCSDKCreativeKit
import DataCache
import PanModal
import GSPlayer
import Reachability

protocol ReelsVCDelegate: AnyObject {
    func backButtonPressed(_ isUpdateSavedArticle: Bool)
    func loaderShowing(status: Bool)
    func switchBackToForYou()
    
    func changeScreen(pageIndex: Int)
    
    func currentPlayingVideoChanged(newIndex: IndexPath)
}

class ReelsVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    //    @IBOutlet weak var containerView: UIView!
    //    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewCategoryType: UIView!
    @IBOutlet weak var lblCategoryType: UILabel!
    @IBOutlet weak var viewEmptyMessage: UIView!
    @IBOutlet weak var lblEmptyMessage: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var imgArrow: UIImageView!
//    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var indicator: InstagramActivityIndicator!
    @IBOutlet weak var viewIndicator: UIView!
    
    @IBOutlet weak var imgLeftArrow: UIImageView!
    
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblRefreshLabel: UILabel!
    
//    @IBOutlet weak var refreshIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var viewRefreshContainer: UIView!
    @IBOutlet weak var loaderView: UIView!
    
    @IBOutlet weak var refreshLoaderView: UIView!
    //    @IBOutlet weak var costraintCollectionViewBottom: NSLayoutConstraint!
    var  reelsArray = [Reel]()
    var currentlyPlayingIndexPath = IndexPath(item: 0, section: 0)
    var nextPageData = ""
    var isApiCallAlreadyRunning = false
    var isFirtTimeLoaded = false
    var isViewDidAppear = false
//    let refreshControl = UIRefreshControl()
    let offset:CGFloat = -50
    var isViewControllerVisible = false
    var isBackButtonNeeded = false
    var contextID = ""
    var isLikeApiRunning = false
    var titleText = ""
    var isShowingProfileReels = false
    var isFromChannelView = false
    var isFromDiscover = false
    var userSelectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    var authorID = ""
    weak var delegate: ReelsVCDelegate?
    var scrollToItemFirstTime = false
    var channelInfo: ChannelInfo?
    var isSugReels = false
    
    var currentPageIndex = 0
    var isOnFollowing = false
    
    var isShareSheetPresenting = false
    var isArchived = false
    
    var DocController: UIDocumentInteractionController = UIDocumentInteractionController()
    private let instagramURL = URL(string: "instagram://app")
    private let storiesURL = URL(string: "instagram-stories://share")
    
    //    @IBOutlet weak var leadingContraintContainerView: NSLayoutConstraint!
    
    var currentCategory =  0
    public var minimumVelocityToHide: CGFloat = 1500
    public var minimumScreenRatioToHide: CGFloat = 0.5
    public var animationDuration: TimeInterval = 0.2
    
    var controller: SideMenuContainerVC!
    
    @IBOutlet var allCaughtUpView: UIStackView!
    var rightMenuNavigationController: SideMenuNavigationController?
    var isRightMenuLoaded = false
    var isOpenFromTags = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var isFollowingVCOpened = false
    
    var isOpenfromNotificationList = false
    
    var mediaWatermark = MediaWatermark()
    
    var isWatchingRotatedVideos = false
    
    let reelsRefreshTimeNeeded: CGFloat = 2
    
    var showSkeletonLoader = false
    
    var isCurrentlyScrolling = false
    
    var refreshMaximumSpace: CGFloat = 100//125
    
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

        self.allCaughtUpView.isHidden = true
        ANLoader.hide()
        checkInternetConnection()
        // Do any additional setup after loading the view.
        _ = try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
    
        isViewControllerVisible = true
        registerCells()
        setupUI()
        collectionView.delegate = self
        collectionView.dataSource = self

//        performWSToUserConfig()
        
        btnContinue.backgroundColor = Constant.appColor.lightRed
        
        //theme_backgroundColor = GlobalPicker.themeCommonColor
//        btnContinue.addTextSpacing(spacing: 2.0)
        
        viewEmptyMessage.isHidden = true
                
        if fromMain {
            loadNewData()
            getReelsCategories()
        }
        
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
                }
                else {
                    FullResponse = try? DataCache.instance.readCodable(forKey: Constant.CACHE_REELS)
                }
                
                
                if let reels = FullResponse?.reels, reels.count > 0 && minutes < Double(reelsRefreshTimeNeeded) {
                    self.reelsArray = reels
                    self.nextPageData = FullResponse?.meta?.next ?? ""
                    
                    if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitReelID != "" {
                        //LOAD ADS
                        self.reelsArray.removeAll { $0.iosType == Constant.newsArticle.ARTICLE_TYPE_ADS }
                        self.reelsArray = self.reelsArray.adding(Reel(id: "", context: "", reelDescription: "", media: "", media_landscape: "", mediaMeta: nil, publishTime: "", source: nil, info: nil, authors: nil, captions: nil, image: "", status: "", iosType: Constant.newsArticle.ARTICLE_TYPE_ADS, nativeTitle: true), afterEvery: SharedManager.shared.adsInterval)
                    }
                    self.collectionView.reloadData()

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
                }
                else {
                    
                    if SharedManager.shared.isFirstimeSplashScreenLoaded == false {
                        SharedManager.shared.isFirstimeSplashScreenLoaded = true
                        SharedManager.shared.showLoaderInWindow()
                    }
                    perform(#selector(autohideloader), with: nil, afterDelay: 5)
                    if SharedManager.shared.reelsContextNotification != "" {
                        performWSToGetReelsData(page: "", contextID: SharedManager.shared.reelsContextNotification)
                    }else{
                        performWSToGetReelsData(page: "", contextID: self.contextID)
                    }
                    
                }
            }
            else {
                ReelsCacheManager.shared.clearDiskCache()
                currentCachePosition = 1
                cacheLimit = 10
                startReelsCaching()
                if SharedManager.shared.reelsContextNotification != "" {
                    performWSToGetReelsData(page: "", contextID: SharedManager.shared.reelsContextNotification)
                }else{
                    performWSToGetReelsData(page: "", contextID: self.contextID)
                }
            }
        } else {
            ReelsCacheManager.shared.clearDiskCache()
            currentCachePosition = 1
            cacheLimit = 10
            startReelsCaching()
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
        
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.002)
        
        SharedManager.shared.isReelsLoadedFirstTime = true
        
        //        if isBackButtonNeeded == false {
        setupSideMenu()
        //        }
        
        if isOpenfromNotificationList {
            self.collectionView.bounces = false
            self.collectionView.alwaysBounceVertical = false
            self.collectionView.bouncesZoom = false
            
            self.collectionView.isScrollEnabled = false
            self.collectionView.isPagingEnabled = false
        } else {
            self.collectionView.isScrollEnabled = true
            self.collectionView.isPagingEnabled = true
        }
        
        
        if isShowingProfileReels || isSugReels || contextID != "" {
            collectionView.bounces = false
            collectionView.bouncesZoom = false
        }

    }
    
    @objc private func reloadDataFromBG() {
        self.reelsArray.removeAll()
        self.collectionView.reloadData()
        nextPageData = ""
        self.performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.curReelsCategoryId)
    }
    
    private func getReelsCategories() {
        
        // This should be done in a View Model manner, but this will be refactored later on.
        // Quick fix only
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/home?type=reels", method: .get, parameters: nil, headers: token, withSuccess: { (response) in

            
//            if let response = response {
//
//            }
//
//            if response != nil {
//
//                self.performWSToGetCategoriesResponseRecieved(response: response!, url: "")
//
//            }
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(subCategoriesDC.self, from: response)
                                
                if let homeData = FULLResponse.data {
                    
                    
                    //write Cache Codable types object
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
                
                
            }
            catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/home?type=reels", error: jsonerror.localizedDescription, code: "")
            }
            
            
            
        }) { (error) in
            
            print("Faeild to get reels categories")
            
        }
    }
    
    func openReelsTutorial() {
        DispatchQueue.main.async {
            let vc = TutorialVC.instantiate(fromAppStoryboard: .Reels)
            vc.delegate = self
            self.isViewControllerVisible = false
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func setupForCallMethod() {
        NotificationCenter.default.addObserver(self,selector: #selector(playerInterruption),name: AVAudioSession.interruptionNotification,object: AVAudioSession.sharedInstance())
    }
    
    @objc func playerInterruption(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        if type == .began {
            
            print("Call-- began")
            self.stopVideo()
            
        } else {
            
            print("Call-- end")
            
            print("REELS AUTO PLAY EWA 3= \(SharedManager.shared.reelsAutoPlay)")

            if SharedManager.shared.reelsAutoPlay {
                self.playCurrentCellVideo()
            }
        }
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
            if userSelectedIndexPath.item < self.reelsArray.count{
                collectionView.layoutIfNeeded()
                print("USERSELECTEDINDEXPATH = \(userSelectedIndexPath)")
                collectionView.scrollToItem(at: userSelectedIndexPath, at: .centeredVertically, animated: false)
            }
        }
        
//        if isWatchingRotatedVideos {
//
//            collectionView.layoutIfNeeded()
//            collectionView.scrollToItem(at: currentlyPlayingIndexPath, at: .centeredVertically, animated: false)
//        }
    }
    
    @objc func autohideloader() {
        
        SharedManager.shared.hideLaoderFromWindow()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ANLoader.hide()
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.removeObserver(self)
        DispatchQueue.main.async {
            self.stopVideo()
        }
        self.stopVideo()
        isViewDidAppear = false
        isViewControllerVisible = false
        
        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.viewIndicator.isHidden = true
        }
        
        if reelsArray.count == 0 && self.isShowingProfileReels == false && self.isFromChannelView == false {
            SharedManager.shared.isForYouTabReelsReload = true
            SharedManager.shared.isFollowingTabReelsReload = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()
        
        if isWatchingRotatedVideos {
            return
        }
        
        _ = try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
        _ = try? AVAudioSession.sharedInstance().setActive(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillLoadForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tabBarTapped(notification:)), name: Notification.Name.notifyReelsTabBarTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reelsOrientationChange), name: NSNotification.Name.notifyOrientationChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeReelsDataLanguage), name: .SwiftUIDidChangeLanguage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataFromBG), name: NSNotification.Name(rawValue: "OpenedFromBackground"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.notifyGetPushNotificationArticleData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getArticleDataPayLoad), name: NSNotification.Name.notifyGetPushNotificationArticleData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getArticleDataPayLoad), name: NSNotification.Name.notifyGetPushNotificationToReelsView, object: nil)
        
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
        
        if let cell = self.collectionView.cellForItem(at: self.currentlyPlayingIndexPath) as? ReelsCC {
            print("video played at index", self.currentlyPlayingIndexPath)
            if SharedManager.shared.reelsAutoPlay {
                cell.viewPlayButton.isHidden = true
            } else {
                cell.viewPlayButton.isHidden = false
                self.stopVideo()
            }
        }
       
        
        if isFirtTimeLoaded {
            if reelsArray.count > 0 {
                
                self.sendVideoViewedAnalyticsEvent()
                print("REELS AUTO PLAY EWA 4= \(SharedManager.shared.reelsAutoPlay)")

                if SharedManager.shared.reelsAutoPlay {
                    if isWatchingRotatedVideos {
                        // Resume videos
                    } else {
                        self.playCurrentCellVideo()
                    }
                } else {
                    
                    // Reset Current cell
                    self.stopVideo()
                }
            }
            
            if isBackButtonNeeded == false {
                
                if reelsArray.count == 0 {
                    loadNewData()
                }
//                else if isOnFollowing && SharedManager.shared.isFollowingTabReelsReload {
//                    loadNewData()
//                }
//                else if isOnFollowing == false && SharedManager.shared.isForYouTabReelsReload {
//                    loadNewData()
//                }
                else if SharedManager.shared.getSelectedReelsCategory() != currentCategory {
                    loadNewData()
                } else if currentCategory == 1 && SharedManager.shared.isReelsFollowingNeedRefresh {
                    loadNewData()
                } else {
                    
                    if SharedManager.shared.minutesBetweenDates(SharedManager.shared.lastBackgroundTimeReels ?? Date(), Date()) >= reelsRefreshTimeNeeded && reelsArray.count > 0 {
                        
                        if SharedManager.shared.tabBarIndex == 0 && self.isShowingProfileReels == false && self.isFromChannelView == false {
                            self.collectionView.setContentOffset(.zero, animated: false)
                            beginRefreshingWithAnimation(isLoadingBackground: false)
                        }
                        
                    } else if reelsArray.count > 0 {
                        
                        self.sendVideoViewedAnalyticsEvent()
                        
                        print("REELS AUTO PLAY EWA 5= \(SharedManager.shared.reelsAutoPlay)")

                        if SharedManager.shared.reelsAutoPlay {
                            if isWatchingRotatedVideos {
                                // Resume videos
                            } else {
                                self.playCurrentCellVideo()
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
        }
        else {
            SharedManager.shared.isForYouTabReelsReload = false
        }
        
        setupForCallMethod()
        
        SharedManager.shared.lastBackgroundTimeReels = Date()
        
        print("APPDELEGATE SHOULD RESET REELS = \(appDelegate.shouldResetReels)")
        
        if appDelegate.shouldResetReels {
            self.reloadDataFromBG()
            appDelegate.shouldResetReels = false
        }
    }
    
    @objc func getArticleDataPayLoad(){
        if SharedManager.shared.reelsContextNotification != "" {
            if SharedManager.shared.isFromPNBackground{
                self.reelsArray.removeAll()
                self.collectionView.reloadData()
                nextPageData = ""
                SharedManager.shared.isAppLaunchedThroughNotification = false
                self.performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.reelsContextNotification)
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
                } else {
                    print("language updated failed")
                }
            })
        }

    }
    
    func setStatusBar() {
        var navVC = (self.navigationController?.navigationController as? AppNavigationController)
        if navVC == nil {
            navVC = (self.navigationController as? AppNavigationController)
        }
        
        if reelsArray.count == 0 {
            if navVC?.showDarkStatusBar == true {
                navVC?.showDarkStatusBar = false
                navVC?.setNeedsStatusBarAppearanceUpdate()
            }
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ANLoader.hide()
        DispatchQueue.main.async {
            self.stopVideo()
        }
        self.stopVideo()
        SharedManager.shared.lastBackgroundTimeReels = Date()
    }
    
    override func viewDidAppear(_ animated: Bool) {

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
        scrollToItemFirstTime  = false
        
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
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let presentableController = viewControllerToPresent as? PanModalPresentable, let controller = presentableController as? UIViewController,UIDevice.current.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .custom
            controller.modalPresentationCapturesStatusBarAppearance = true
            controller.transitioningDelegate = PanModalPresentationDelegate.default
            super.present(controller, animated: flag, completion: completion)
            return
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
//    override func viewDidLayoutSubviews() {
//        collectionView.layoutSkeletonIfNeeded()
//    }
    
    
    func setupUI() {
        
        collectionView.backgroundColor = .clear
        
        indicator.animationDuration = 1.0
        indicator.rotationDuration = 3
        indicator.numSegments = 15
        indicator.strokeColor = "#E01335".hexStringToUIColor()
        indicator.lineWidth = 3
        
        btnContinue.backgroundColor = Constant.appColor.lightRed
        
        if  isBackButtonNeeded {
            viewBack.isHidden = false
            lblTitle.isHidden = false
            
            let titleTxt = titleText == "" ? "": titleText
            self.addShadowText(label: lblTitle, text: titleTxt, font: UIFont(name: Constant.FONT_Mulli_BOLD, size: 25)!, spacing: 1)
            
            
            viewCategoryType.isHidden = true
            
//            lblEmptyMessage.text = NSLocalizedString("No Newsreels yet", comment: "")
            btnContinue.setTitle(NSLocalizedString("Follow", comment: ""), for: .normal)
            
            btnContinue.isHidden = true
        } else {
            viewBack.isHidden = true
            lblTitle.isHidden = true
            lblTitle.text = ""
            
            viewCategoryType.isHidden = false
            
//            lblEmptyMessage.text = NSLocalizedString("You are not following anything yet", comment: "")
            btnContinue.setTitle(NSLocalizedString("Follow", comment: ""), for: .normal)
            
            btnContinue.isHidden = false
        }
        
        setUpSelectedCategory()
        
        
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true        
        
//        refreshControl.tintColor = UIColor.white
//        refreshControl.addTarget(self, action: #selector(refreshCollectionViewCells), for: .valueChanged)
//        //        refreshControl.layer.zPosition = -1
//        refreshControl.bounds = CGRect(x: refreshControl.bounds.origin.x, y: offset,
//                                       width: refreshControl.bounds.size.width,
//                                       height: refreshControl.bounds.size.height)
//        collectionView.addSubview(refreshControl)
//        refreshControl.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        
        
        //        imgArrow.layer.cornerRadius = 20.0
        imgArrow.layer.shadowColor = UIColor.black.cgColor
        imgArrow.layer.shadowOffset = CGSize(width: 0, height: 1)
        imgArrow.layer.shadowOpacity = 0.5
        //        imgArrow.backgroundColor = UIColor.white
        //addSubview(refreshControl)
        //refreshControl = refreshControl
        //(refreshControl)
        
        imgLeftArrow.layer.shadowColor = UIColor.black.cgColor
        imgLeftArrow.layer.shadowOffset = CGSize(width: 0, height: 1)
        imgLeftArrow.layer.shadowOpacity = 0.5
        
        
        
//        collectionView.bounces = false
//        collectionView.alwaysBounceVertical = false
//        collectionView.es.addPullToRefresh {
//
//            self.collectionView.bounces = false
//            self.collectionView.alwaysBounceVertical = false
//            self.refreshCollectionViewCells(isLoadingBackground: false)
//        }
//        refreshIndicator.startAnimating()
        
        viewRefreshContainer.isHidden = true
    }
    
    @objc func reelsOrientationChange() {
        
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            
            if reelsArray.count == 0{
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
    
    
    func setupSideMenu() {
        
//        if  self.navigationController == nil {
//            return
//        }
        if isSugReels || isShowingProfileReels || isFromChannelView {
            return
        }
        
        controller = SideMenuContainerVC.instantiate(fromAppStoryboard: .Reels)
        rightMenuNavigationController = SideMenuNavigationController(rootViewController: controller)
        rightMenuNavigationController!.navigationBar.isHidden = true
        rightMenuNavigationController!.sideMenuDelegate = self
        SideMenuManager.default.rightMenuNavigationController = rightMenuNavigationController
        
        // Setup gestures: the left and/or right menus must be set up (above) for these to work.
        // Note that these continue to work on the Navigation Controller independent of the view controller it displays!
//        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
//        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        //        SideMenuManager.default.menuPushStyle = .subMenu
        // (Optional) Prevent status bar area from turning black when menu appears:
        //        leftMenuNavigationController.statusBarEndAlpha = 0
        // Copy all settings to the other menu
        rightMenuNavigationController!.settings = makeSettings()
        
        
    }
    
    private func makeSettings() -> SideMenuSettings {
        
        //        let modes: [SideMenuPresentationStyle] = [.menuSlideIn, .viewSlideOut, .viewSlideOutMenuIn, .menuDissolveIn]
        
        let presentationStyle = SideMenuPresentationStyle.menuSlideIn
        //        presentationStyle.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        //        presentationStyle.menuStartAlpha = CGFloat(menuAlphaSlider.value)
        //        presentationStyle.menuScaleFactor = CGFloat(menuScaleFactorSlider.value)
        //        presentationStyle.onTopShadowOpacity = shadowOpacitySlider.value
        //        presentationStyle.presentingEndAlpha = CGFloat(presentingAlphaSlider.value)
        //        presentationStyle.presentingScaleFactor = CGFloat(presentingScaleFactorSlider.value)
        
        //        let styles:[UIBlurEffect.Style?] = [nil, .dark, .light, .extraLight]
        //        settings.blurEffectStyle = styles[blurSegmentControl.selectedSegmentIndex]
        //        settings.statusBarEndAlpha = blackOutStatusBar.isOn ? 1 : 0
        
        var settings = SideMenuSettings()
        settings.dismissOnPush = false
        settings.dismissOnPresent = false
        settings.presentationStyle = presentationStyle
        settings.menuWidth = view.frame.width//min(view.frame.width, view.frame.height) * CGFloat(screenWidthSlider.value)
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
        
        //        lblCategoryType.addTextSpacing(spacing: 1)
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
            .kern: spacing
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
    
     func checkInternetConnection() {
        
        do {
            reachability = try Reachability()
        } catch {
            print("reachability init failed")
        }
        
        guard let reachabilitySwift = reachability  else {
            return
        }
        
        reachabilitySwift.whenReachable = { reachability in
            
            if reachability.connection == .wifi {
                print("reachability Reachable via WiFi")
            } else {
                print("reachability Reachable via Cellular")
            }
            if self.isNoInternet{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
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
    
    @objc func stopVideo() {
        
        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            
            cell.stopVideo()
//            cell.pause()
        }
    }
    
    func pauseVideo() {
        
        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            
            cell.PauseVideo()
        }
        
    }
    
    
    func resumeVideo(time: TimeInterval?) {
        
        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            
            cell.resumeVideoPlay(time: time)
        }
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
            self.stopVideo()
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
            
            self.stopVideo()
            self.collectionView.setContentOffset(.zero, animated: false)
            
            SharedManager.shared.showLoaderInWindow()
//            beginRefreshingWithAnimation(isLoadingBackground: true)
            
            loadNewData()
            
            
            perform(#selector(autohideloader), with: nil, afterDelay: 5)
            
        } else {
            SharedManager.shared.hideLaoderFromWindow()
            if reelsArray.count > 0 {
                if isRightMenuLoaded == false && isShareSheetPresenting == false {
                    
                    if SharedManager.shared.reelsAutoPlay {
                        self.playCurrentCellVideo()
                    }
                }
            }
            
        }
        
        
        
    }
    
    func isBackgroundRefreshRequired() -> Bool {
        
        if SharedManager.shared.minutesBetweenDates(SharedManager.shared.lastBackgroundTimeReels ?? Date(), Date()) >= reelsRefreshTimeNeeded && reelsArray.count > 0 {
            
            if SharedManager.shared.tabBarIndex == 0 && self.isShowingProfileReels == false && self.isFromChannelView == false {
                
                return true
            }
        }
        
        return false
        
    }
    
    func didTapNotifications() {
        
        self.stopVideo()
        isViewControllerVisible = false
        
        let vc = NotificationsListVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        vc.delegate = self
        self.present(nav, animated: true, completion: nil)
        
    }
    
    func didTapFilter(isTabNeeded: Bool) {
        
        self.stopVideo()
        isViewControllerVisible = false
        
        let vc = ForYouPreferencesVC.instantiate(fromAppStoryboard: .Reels)
        vc.preferenceType = .reels
        vc.delegate = self
        vc.currentSelection = isOnFollowing ? 1 : 0
        vc.isOpenReels = true
        vc.isReelsTabNeeded = isTabNeeded
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
        
        
    }
    
    func openFollowingPrefernce() {
        
        self.stopVideo()
        isViewControllerVisible = false
        
        let vc = FollowingPreferenceVC.instantiate(fromAppStoryboard: .Reels)
        vc.delegate = self
        vc.hasReels = true
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        
        isOpenedFollowingPrefernce = true
        self.present(nav, animated: true, completion: nil)
        
    }
    
    
    @IBAction func didTapCategory(_ sender: Any) {
        
        currentCategory = SharedManager.shared.getSelectedReelsCategory()
        
        
        let vc = ReelsCategoryVC.instantiate(fromAppStoryboard: .Reels)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
        
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        SharedManager.shared.isOnDiscover = true
        if isShowingProfileReels || isFromChannelView {
            ReelsCacheManager.shared.reelViewedOnChannelPage = true
            self.navigationController?.popViewController(animated: true)
        }else if isFromDiscover{
            self.navigationController?.popViewController(animated: true)
            ReelsCacheManager.shared.clearDiskCache()
            SharedManager.shared.reloadRequiredFromTopics = true
            return
        }
        else if isSugReels {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            ReelsCacheManager.shared.clearDiskCache()
            SharedManager.shared.reloadRequiredFromTopics = true
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.reelsArray.removeAll()
        self.collectionView.reloadData()
        nextPageData = ""
        self.performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.curReelsCategoryId)
        
        self.delegate?.backButtonPressed(self.isArchived)
    }
    
    @objc func tabBarTapped(notification: Notification) {
        
        print("tababr tapped event")
        if isViewDidAppear == false {
            return
        }
//        let index = getCurrentVisibleTopCell()
//        if index.item == 0  {
//            if isShowingProfileReels || isSugReels || contextID != "" {
//                return
//            }
//            setRefresh(scrollView: collectionView, manual: true)
//        }
        if isShowingProfileReels || isSugReels || contextID != "" {
            return
        }
        let indexPath = IndexPath(item: 0, section: 0)
        UIView.animate(withDuration: 0.5) {
//            self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        } completion: { (status) in
            self.reelsArray.removeAll()
            self.collectionView.reloadData()
            self.setRefresh(scrollView: self.collectionView, manual: true)
            if let cell = self.collectionView.cellForItem(at: indexPath) as? ReelsCC {

                self.currentlyPlayingIndexPath = indexPath
//                    cell.playVideo()
//                    self.getCaptionsFromAPI()
                if SharedManager.shared.reelsAutoPlay {
                    cell.viewPlayButton.isHidden = true
                    self.playCurrentCellVideo()
                } else {
                    cell.viewPlayButton.isHidden = false
                    cell.stopVideo()
                }
            }
        }
       
//        else {
//            let indexPath = IndexPath(item: 0, section: 0)
//            UIView.animate(withDuration: 0.5) {
//                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
//            } completion: { (status) in
//                if let cell = self.collectionView.cellForItem(at: indexPath) as? ReelsCC {
//
//                    self.currentlyPlayingIndexPath = indexPath
////                    cell.playVideo()
////                    self.getCaptionsFromAPI()
//                    if SharedManager.shared.reelsAutoPlay {
//                        cell.viewPlayButton.isHidden = true
//                        self.playCurrentCellVideo()
//                    } else {
//                        cell.viewPlayButton.isHidden = false
//                        cell.stopVideo()
//                    }
//                }
//            }
//        }
    }
    
    
    @objc func refreshCollectionViewCells(isLoadingBackground: Bool) {
        
        // Alredy at top
        // refresh collectionview
        if isApiCallAlreadyRunning == false {
            nextPageData = ""
            
            if isLoadingBackground {
                self.stopVideo()
                SharedManager.shared.showLoaderInWindow()
            }
            
            if isLoadingBackground == false {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            
            if SharedManager.shared.reelsContextNotification != "" {
                performWSToGetReelsData(page: "", isRefreshRequired: true, contextID:  SharedManager.shared.reelsContextNotification)
            }else{
                performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.curReelsCategoryId)
            }
            
        } else {
            self.stopPullToRefresh()
            SharedManager.shared.hideLaoderFromWindow()
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
            } completion: { status in
                self.viewRefreshContainer.isHidden = true
                self.isRefreshingReels = false
                self.collectionView.isUserInteractionEnabled = true
            }
            
        }
        
    }
    
    
    @IBAction func didTapStartFollowing(_ sender: Any) {
        
        //FollowingVC
//        let vc = FollowingVC.instantiate(fromAppStoryboard: .Channel)
//        vc.delegate = self
//        vc.isOpenFromReels = true
//        let nav = AppNavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        self.present(nav, animated: true, completion: nil)
        
        didTapFilter(isTabNeeded: false)
    }
    
    func beginRefreshingWithAnimation(isLoadingBackground: Bool) {
        
        if  isApiCallAlreadyRunning {
            SharedManager.shared.hideLaoderFromWindow()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if  self.isApiCallAlreadyRunning {
                SharedManager.shared.hideLaoderFromWindow()
                return
            }
            
            
//            self.collectionView.es.startPullToRefresh()
//            self.collectionView.setContentOffset(CGPoint(x: 0, y: self.collectionView.contentOffset.y - (self.refreshControl.frame.size.height)), animated: false)
//            self.collectionView.layoutIfNeeded()
//            self.refreshControl.layoutIfNeeded()
//            defer {
//                self.refreshControl.beginRefreshing()
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                self.refreshCollectionViewCells(isLoadingBackground: isLoadingBackground)
//            }
        }
    }
    
}

extension ReelsVC: TutorialVCDelegate {
    
    func userDismissed(vc: TutorialVC) {
        
        let vc = AlertViewNew.instantiate(fromAppStoryboard: .Reels)
        vc.delegate = self
        vc.message = NSLocalizedString("Thanks! We have successfully saved your preferences. Start discovering curated content.", comment: "")
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
}

extension ReelsVC: AlertViewNewDelegate {
    
    func alertClosedbyUser() {
        SharedManager.shared.isSavedPreferenceAlertRequired = false
        self.isViewControllerVisible = true
        playCurrentCellVideo()
        
    }
}




extension ReelsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let navVC = (self.navigationController?.navigationController as? AppNavigationController)
        if showSkeletonLoader {
            collectionView.isScrollEnabled = false
            return 1
        }
        collectionView.isScrollEnabled = true
        
        setStatusBar()
        self.delegate?.loaderShowing(status: false)
        return reelsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if showSkeletonLoader {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReelsSkeletonAnimation", for: indexPath) as! ReelsSkeletonAnimation
            
//            cell.gradientLayers.forEach { gradientLayer in
//              let baseColor = cell.viewTitle1.backgroundColor!
//              gradientLayer.colors = [baseColor.cgColor,
//                                      baseColor.brightened(by: 0.5).cgColor,
//                                      baseColor.cgColor]
//            }
            cell.showLoader()
            return cell
        }
        
        if indexPath.item < reelsArray.count {
            
            
//            if currentCachePosition == cacheLimit {
//                cacheLimit += 10
//            }
//            if currentCachePosition < cacheLimit {
//                self.startReelsCaching()
//            }
            
            if reelsArray[indexPath.item].iosType == Constant.newsArticle.ARTICLE_TYPE_ADS {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReelsPhotoAdCC", for: indexPath) as! ReelsPhotoAdCC
                cell.fetchAds(viewController: self)
                return cell
            } else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReelsCC", for: indexPath) as! ReelsCC
                
                if indexPath.item < reelsArray.count {
                    cell.setupCell(model: reelsArray[indexPath.item])
                }
                
                cell.delegate = self
                
                if channelInfo != nil {
                    cell.viewEditArticle.isHidden = (channelInfo?.own ?? false) ? false : true
                }
                else {
                    cell.viewEditArticle.isHidden = (authorID == SharedManager.shared.userId && !SharedManager.shared.userId.isEmpty) ? false : true
                }
                cell.btnEditArticle.tag = indexPath.item
                cell.btnAuthor.tag = indexPath.item
                
                cell.contentView.frame = cell.bounds
                cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//                cell.layoutIfNeeded()
//                check()
                return cell
            }
        } 
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        if let skeletonCell = cell as? ReelsSkeletonAnimation {
            skeletonCell.hideLaoder()
//            skeletonCell.stopSliding()
        }
        
        if let cell = cell as? ReelsCC {
            cell.stopVideo()
            cell.pause()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? ReelsCC {
            if indexPath.item == 0 {
                cell.play()
            }
            if SharedManager.shared.isAudioEnableReels == false {
                cell.player.volume = 0.0
                cell.imgSound.image = UIImage(named: "newMuteIC")
            }
            else {
                cell.player.volume = 1.0
                cell.imgSound.image = UIImage(named: "newUnmuteIC")
            }
            
            if SharedManager.shared.reelsAutoPlay {
                cell.viewPlayButton.isHidden = true
            } else {
                cell.viewPlayButton.isHidden = false
                cell.stopVideo()
            }
        }
        if self.reelsArray.count > 0 {
            if self.reelsArray[indexPath.row].reelDescription == "" && self.reelsArray[indexPath.row].authors?.count == 0 && self.reelsArray[indexPath.row].iosType == nil {
                self.reelsArray.remove(at: indexPath.row)
                let indexPathReload = IndexPath(item: indexPath.row, section: 0)
                self.collectionView.reloadItems(at: [indexPathReload])
            }
        }
        
        self.delegate?.currentPlayingVideoChanged(newIndex: indexPath)
        
        if isWatchingRotatedVideos {
            return
        }
        
        if let skeletonCell = cell as? ReelsSkeletonAnimation {
            skeletonCell.showLoader()
        }
        if reelsArray.count > 0 && indexPath.item == setReelAPIHitLogic() {  //numberofitem count
            callWebsericeToGetNextVideos()
        }
        
//        if indexPath.item > 5 {
//            ReelsCacheManager.shared.deleteCachedReels(currentPosition: indexPath.item, reelsArray: self.reelsArray, completion: { [weak self] pos in
//                DispatchQueue.main.async {
//                    self?.reelsArray.remove(at: pos)
//                    let indexPathRow = IndexPath(item: pos, section: 0)
//                    self?.collectionView.reloadItems(at: [indexPathRow])
//                }
//            })
//
//        }
        
        (cell as? ReelsCC)?.setImage()
        
        (cell as? ReelsCC)?.cellLayoutUpdate()
        if SharedManager.shared.bulletsAutoPlay {
//            (cell as? ReelsCC)?.play()
        }


    }
    
    func setReelAPIHitLogic() -> Int{
        
        if reelsArray.count >= 10 {
            return reelsArray.count - 8
        }else {
            return reelsArray.count / 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if showSkeletonLoader {
            return collectionView.frame.size
        }
        let lineSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height - lineSpacing)
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        if collectionView != nil {
//            collectionView.collectionViewLayout.invalidateLayout()
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {

        if isWatchingRotatedVideos == false {
            return proposedContentOffset
        }
        
        let attrs =  collectionView.layoutAttributesForItem(at: self.currentlyPlayingIndexPath)

        let newOriginForOldIndex = attrs?.frame.origin

        return newOriginForOldIndex ?? proposedContentOffset
    }
    
    
}

extension ReelsVC: ForYouPreferencesVCDelegate {
    
    func userDismissed(vc: ForYouPreferencesVC, selectedPreference: Int, selectedCategory: String) {
       
//        if selectedPreference == 0 {
//            // For you
//            if isOnFollowing {
//                // Change page index
//                self.delegate?.changeScreen(pageIndex: selectedPreference)
//            }
//            else {
//                self.playCurrentCellVideo()
//                isViewControllerVisible = true
//            }
//        }
//        else {
//
//            if isOnFollowing == false {
//                // Change page index
//                self.delegate?.changeScreen(pageIndex: selectedPreference)
//            }
//            else {
//                self.playCurrentCellVideo()
//                isViewControllerVisible = true
//            }
//
//        }
//
//        self.performWSToGetReelsData(page: "1", contextID: selectedCategory)
//        self.reelsArray.removeAll()
//        self.collectionView.reloadData()
//        self.performWSToGetReelsData(page: "", contextID: SharedManager.shared.curReelsCategoryId)

        
    }
    
    func userChangedCategory() {
        NotificationCenter.default.post(name: .didChangeReelsTopics, object: nil)
        self.reelsArray.removeAll()
        self.collectionView.reloadData()
        nextPageData = ""
        self.showSkeletonLoader = true
        self.performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.curReelsCategoryId)
    }
    
}

extension NSNotification.Name {
    static let didChangeReelsTopics = Notification.Name("didChangeReelsTopics")
}

extension ReelsVC: FollowingPreferenceVCDelegate {
    
    func userDismissed(vc: FollowingPreferenceVC) {
        
        self.playCurrentCellVideo()
        isViewControllerVisible = true
    }
    
}

extension ReelsVC: AddUsernameVCDelegate {
    
    func userDismissed(vc: AddUsernameVC) {
        self.playCurrentCellVideo()
        isViewControllerVisible = true
    }
    
}

extension ReelsVC: SelectTopicsVCDelegate {
    
    func didTapClose() {
        
        self.playCurrentCellVideo()
        isViewControllerVisible = true
    }
}
extension ReelsVC {
    
    func callWebsericeToGetNextVideos() {
        
        if isApiCallAlreadyRunning == false {
            
            if !nextPageData.isEmpty {
//                self.allCaughtUpView.isHidden = true
                performWSToGetReelsData(page: nextPageData, contextID: SharedManager.shared.curReelsCategoryId)
            } else {
                if isSugReels || isShowingProfileReels || isFromChannelView {
                    // Not needed
                } else {
                    // no need to repeat data for now
//                    performWSToGetReelsData(page: "", contextID: self.contextID)
                }
                // YOU'RE ALL CAUGHT UP
//                self.allCaughtUpView.isHidden = false
            }
            
        }
        
    }
    
    func playNextCellVideo(indexPath: IndexPath) {
        
        getCaptionsFromAPI()
        
        UIView.animate(withDuration: 0.5) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        } completion: { (status) in
            if let cell = self.collectionView.cellForItem(at: indexPath) as? ReelsCC {
                
                self.currentlyPlayingIndexPath = indexPath
                if SharedManager.shared.reelsAutoPlay {
                    cell.playVideo()
                }
                self.sendVideoViewedAnalyticsEvent()
            }
            else if let cell = self.collectionView.cellForItem(at: indexPath) as? ReelsPhotoAdCC {
                
                self.currentlyPlayingIndexPath = indexPath
                cell.fetchAds(viewController: self)
            }
        }
        
    }
    
    func playCurrentCellVideo() {
        
        getCaptionsFromAPI()
        
        if SharedManager.shared.isGuestUser == false, SharedManager.shared.isUserSetup == false, isViewControllerVisible {
    /*
            let vc = AddUsernameVC.instantiate(fromAppStoryboard: .RegistrationSB)
            vc.isPresented = true
            vc.delegate = self
            let navVC = UINavigationController(rootViewController: vc)
            self.isViewControllerVisible = false
            self.stopVideo()
            self.present(navVC, animated: true, completion: nil)
            return
            */
        }
//        else if SharedManager.shared.isOnboardingPreferenceLoaded == false, isViewControllerVisible {
//            let vc = SelectTopicsVC.instantiate(fromAppStoryboard: .RegistrationSB)
//            vc.delegate = self
//            let navVC = UINavigationController(rootViewController: vc)
//            self.isViewControllerVisible = false
//            self.stopVideo()
//            self.present(navVC, animated: true, completion: nil)
//            return
//        }
        
        
//        print("video play fired", self.currentlyPlayingIndexPath)
        if let cell = self.collectionView.cellForItem(at: self.currentlyPlayingIndexPath) as? ReelsCC {
            print("video played at index", self.currentlyPlayingIndexPath)
            if cell.player.state != .playing{
                DispatchQueue.main.async {
                    cell.loader.isHidden = false
                    cell.loader.startAnimating()
                }
                cell.play()
            }else{
                DispatchQueue.main.async {
                    cell.loader.isHidden = true
                    cell.loader.stopAnimating()
                }
            }
            
//            let tempIndex = currentlyPlayingIndexPath
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//
//                if tempIndex == self.currentlyPlayingIndexPath {
//                    self.collectionView.layoutIfNeeded()
//                    self.collectionView.scrollToItem(at: tempIndex, at: .centeredVertically, animated: true)
//                }
//
//            }
            
            
        } else if let cell = self.collectionView.cellForItem(at: self.currentlyPlayingIndexPath) as? ReelsPhotoAdCC {
            print("video played at index", self.currentlyPlayingIndexPath)
            cell.fetchAds(viewController: self)
        }
        
        self.delegate?.currentPlayingVideoChanged(newIndex: currentlyPlayingIndexPath)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            
            self.adjustCellScrollPostion()
        }
        if currentlyPlayingIndexPath.row < reelsArray.count {
            if !reelsArray.isEmpty, let reelID = reelsArray[currentlyPlayingIndexPath.row].id {
                SharedManager.shared.performWSToUpdateArticleAnalytics(ArticleId: reelID, isFromReel: true)
            }
        }
    }
    
    
    func getCaptionsFromAPI() {
        
        if self.reelsArray.count < self.currentlyPlayingIndexPath.item || self.reelsArray.count == 0 {
            
            return
        }
        if (reelsArray[self.currentlyPlayingIndexPath.item].captions?.count ?? 0) == 0  {
            self.performWSToGetReelsCaptions(id: self.reelsArray[self.currentlyPlayingIndexPath.item].id ?? "")
            
            // Force check api response loaded after 1 sec, if not recieved call api again
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.reelsArray.count > self.currentlyPlayingIndexPath.item {
                    if self.reelsArray[self.currentlyPlayingIndexPath.item].captionAPILoaded == false {
                        self.performWSToGetReelsCaptions(id: self.reelsArray[self.currentlyPlayingIndexPath.item].id ?? "")
                    }
                }
            }
            
        }
        

        let nextIndex = self.currentlyPlayingIndexPath.item + 1
        if reelsArray.count > nextIndex {
            if (reelsArray[nextIndex].captions?.count ?? 0) == 0  {
                self.performWSToGetReelsCaptions(id: self.reelsArray[nextIndex].id ?? "")
            }
        }
        let thirdIndex = self.currentlyPlayingIndexPath.item + 2
        if reelsArray.count > thirdIndex {
            if (reelsArray[thirdIndex].captions?.count ?? 0) == 0  {
                self.performWSToGetReelsCaptions(id: self.reelsArray[thirdIndex].id ?? "")
            }
        }
        
    }
    
    func adjustCellScrollPostion() {
        
        if isCurrentlyScrolling == false {
            self.collectionView.layoutIfNeeded()
            self.collectionView.scrollToItem(at: self.currentlyPlayingIndexPath, at: .centeredVertically, animated: false)
        }
        
    }
    
    
    func pauseCellVideo(indexPath: IndexPath?) {
        print("video paused index before", indexPath?.item)
        if let indexPath = indexPath, let cell = collectionView.cellForItem(at: indexPath) as? ReelsCC {
            print("video paused index after", indexPath.item)
            
           // cell.removeCaptions()
            cell.stopVideo()
        }
    }
    
    
    func sendVideoViewedAnalyticsEvent() {
        
        if reelsArray.count > 0 && reelsArray.count > self.currentlyPlayingIndexPath.item {
            let content = reelsArray[self.currentlyPlayingIndexPath.item]
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelViewed, eventDescription: "", article_id: content.id ?? "")
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
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
            if self.isRefreshingReels == false {
                
                if scrollView.contentOffset.y <= 0  {
                    
                    viewRefreshContainer.isHidden = false
                    if collectionViewTopConstraint.constant < refreshMaximumSpace  {
                        collectionViewTopConstraint.constant += 5
                        lblRefreshLabel.text = ""//"Pull to refresh"
                        loaderView.hideLoaderView()
                    }
                    else {
                        lblRefreshLabel.text = "Release to refresh"
                        loaderView.hideLoaderView()
                        collectionViewTopConstraint.constant = refreshMaximumSpace
                    }
                }
                else {
                    collectionViewTopConstraint.constant -= 2.5
                    if collectionViewTopConstraint.constant <= 0 {
                        collectionViewTopConstraint.constant = 0
                    }
                }
                
            }
        }
        
        

        
//        else if scrollView.contentOffset.y < -50 {
//            collectionViewTopConstraint.constant += 5
//            lblRefreshLabel.text = "Release to refresh"
//
//            if collectionViewTopConstraint.constant >= refreshMaximumSpace {
//                collectionViewTopConstraint.constant = refreshMaximumSpace
//            }
//        }
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height + 50 - scrollView.frame.size.height)) {
            self.allCaughtUpView.isHidden = false
        } else {
            self.allCaughtUpView.isHidden = true
            
        }
        
//        check()
    }
    
    func check() {
        checkPreload()
        checkPlay()
    }
    
    func checkPreload() {
        
        guard let lastRow = collectionView.indexPathsForVisibleItems.last else { return }
        
        let urls = reelsArray.filter({$0.media != nil && !($0.media?.isEmpty ?? true)})
            .suffix(2)
        
        VideoPreloadManager.shared.set(waiting: urls.map({URL(string: $0.media!)!}))
      
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

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        
//        setRefresh(scrollView: scrollView, manual: false)
        
        if lblRefreshLabel.text == "Release to refresh" {
            isPullToRefresh = true
            self.currentCachePosition = 1
            self.cacheLimit = 10
            loadNewData()
        }
        
        if isRefreshingReels == false {
            collectionViewTopConstraint.constant = 0
            self.collectionView.layoutIfNeeded()
        }
        
        isCurrentlyScrolling = false
        if isWatchingRotatedVideos {
            return
        }
        
//        print("collectionViewTopConstraint", collectionViewTopConstraint.constant)
//        print("collectionViewTopConstraint scrollView.contentOffset", scrollView.contentOffset.y)
//        print("collectionViewTopConstraint collectionView.contentOffset", collectionView.contentOffset.y)
        
        if isOpenfromNotificationList == false {
            if scrollView.contentOffset.y < collectionView.frame.size.height/2 && currentlyPlayingIndexPath.item == 0 {
                scrollView.contentOffset.y = 0
                playCurrentCellVideo()
            }
            else {
                self.getCurrentVisibleIndexPlayVideo()
            }
            
        }
        
        
        self.delegate?.currentPlayingVideoChanged(newIndex: currentlyPlayingIndexPath)
        //        self.view.isUserInteractionEnabled = false
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) {
        //            self.view.isUserInteractionEnabled = true
        //        }
        
//        check()

        
    }
    
    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate _: Bool) {
        // Invalidate any existing timer
        scrollTimer?.invalidate()
        // Disable scrolling until the timer fires
        self.view.isUserInteractionEnabled = false
        // Start a new timer with a delay of 0.5 second
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
            // The timer has fired, do something here (e.g. enable scrolling)
            self?.view.isUserInteractionEnabled = true
        }
    }
    
    func setRefresh(scrollView: UIScrollView, manual: Bool) {
        
        if self.isRefreshingReels {
            return
        }
        if manual || collectionViewTopConstraint.constant >= self.refreshMaximumSpace {
            
            UIView.animate(withDuration: 0.25) {
                self.collectionViewTopConstraint.constant = self.refreshMaximumSpace
                self.lblRefreshLabel.text = ""//"Loading ..."
                self.loaderView.showLoader(color: Constant.appColor.lightRed)
//                self.view.layoutIfNeeded()
            }
            self.viewRefreshContainer.isHidden = false
            self.isRefreshingReels = true
            
            self.collectionView.isUserInteractionEnabled = false
            refreshCollectionViewCells(isLoadingBackground: false)
            
            
        }
        else {
            
            self.collectionView.isUserInteractionEnabled = true
            self.viewRefreshContainer.isHidden = true
            self.isRefreshingReels = false
            UIView.animate(withDuration: 0.25) {
                self.collectionViewTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
            
        }
        
    }
    
    func getCurrentVisibleIndexPlayVideo() {
        
        let prevsIndex = currentlyPlayingIndexPath
        var newIndexDetected = false
        // Play latest cell
        for cell in collectionView.visibleCells {
            let cellRect = cell.contentView.convert(cell.contentView.bounds, to: UIScreen.main.coordinateSpace)
            if cellRect.origin.x == 0 && cellRect.origin.y == 0, let indexPath = collectionView.indexPath(for: cell) {
                // Visible cell
//                print("cell is visible")
                currentlyPlayingIndexPath = indexPath
                if SharedManager.shared.reelsAutoPlay {
                    playCurrentCellVideo()
                }
                self.sendVideoViewedAnalyticsEvent()
                newIndexDetected = true
            } else {
                let indexPath = collectionView.indexPath(for: cell)
                pauseCellVideo(indexPath: indexPath)
            }
            //            if UIScreen.main.bounds.intersects(cellRect) {
            //                print("cell is visible")
            //                let cell = cell as? ReelsCC
            //                cell?.player?.play()
            //            }
        }
        
        if newIndexDetected == false {
            print("index not detected, last index is,", currentlyPlayingIndexPath)
            if let cell = collectionView.visibleCells.first, let indexPath = collectionView.indexPath(for: cell) {
                
                currentlyPlayingIndexPath = indexPath
                if SharedManager.shared.reelsAutoPlay {
                    playCurrentCellVideo()
                }
                self.sendVideoViewedAnalyticsEvent()
            }
        }
        // Stop Old cell
        if prevsIndex != currentlyPlayingIndexPath {
            
            if reelsArray.count == 0 {
                return
            }
            if let prevCell = collectionView.cellForItem(at: prevsIndex) as? ReelsCC {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelsDurationEvent, eventDescription: "", article_id: reelsArray[prevsIndex.item].id ?? "", duration: prevCell.player.totalDuration.formatToMilliSeconds() ?? "")
            }
            
            pauseCellVideo(indexPath: prevsIndex)
        }
        
    }
    
    func getCurrentVisibleTopCell() -> IndexPath {
        var  visibleIndexPath = IndexPath(item: 0, section: 0)
        for cell in collectionView.visibleCells {
            let cellRect = cell.contentView.convert(cell.contentView.bounds, to: UIScreen.main.coordinateSpace)
            if cellRect.origin.x == 0 && cellRect.origin.y == 0, let indexPath = collectionView.indexPath(for: cell) {
                print("cell is visible", indexPath)
                visibleIndexPath = indexPath
            }
        }
        return visibleIndexPath
    }
}

//MARK:- API
extension ReelsVC {
    
    func performWSToUserConfig() {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
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
                
                //For Community Guildelines
                if let terms = FULLResponse.terms {
                    SharedManager.shared.community = terms.community ?? true
                }
                
                if let preference = FULLResponse.home_preference {
                    
                    SharedManager.shared.isTutorialDone = preference.tutorial_done ?? false
                    SharedManager.shared.bulletsAutoPlay = preference.bullets_autoplay ?? false
                    SharedManager.shared.reelsAutoPlay = preference.reels_autoplay ?? false
                    SharedManager.shared.videoAutoPlay = preference.videos_autoplay ?? false
                    SharedManager.shared.readerMode = preference.reader_mode ?? false
                    SharedManager.shared.speedRate = preference.narration?.speed_rate ?? ["1.0x":1]
                    
                    //                    if let mode = preference.view_mode {
                    //
                    //                        SharedManager.shared.menuViewModeType = mode
                    //                    }
                    
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
                                //print("you current reading speed", value)
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
                    }
                    else {
                        UserDefaults.standard.setValue(nextInt, forKey: Constant.ratingTimeIntervel)
                    }
                }
                
                if let alert = FULLResponse.alert {
                    
                    SharedManager.shared.userAlert = alert
                }
                
                //                if let homeImage = FULLResponse.static?.home_image {
                //
                //                    SharedManager.shared.leftHomeImage = homeImage.left ?? ""
                //                    SharedManager.shared.opacityHomeImage = homeImage.opacity ?? 1.0
                //                    SharedManager.shared.rightHomeImage = homeImage.right ?? ""
                //                }
                
            } catch let jsonerror {
                
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetReelsData(page: String, isRefreshRequired: Bool = false, contextID: String) {
        

        print("API Called performWSToGetReelsData")
        if reelsArray.count == 0 {
//            collectionView.showAnimatedSkeleton(usingColor: .lightGray, transition: .crossDissolve(0.25))
            self.delegate?.loaderShowing(status: true)
            viewEmptyMessage.isHidden = true
            showSkeletonLoader = true
            collectionView.reloadData()
        }
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            self.stopPullToRefresh()
            self.delegate?.loaderShowing(status: false)
            SharedManager.shared.hideLaoderFromWindow()
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        isApiCallAlreadyRunning = true
        
        var url = ""
        
        if isFromChannelView {
            
            //For Channels view
            if self.channelInfo?.own ?? false {
                url = "studio/reels?source=\(self.channelInfo?.id ?? "")"
            }
            else {
                url = "news/reels?context=\(self.channelInfo?.context ?? "")"
            }
        }
        else if isShowingProfileReels {
            // Showing user profile
            url = "studio/reels?source"
            if authorID != SharedManager.shared.userId {
                url = "news/authors/\(authorID)/reels"
            }
        }
        //else if contextID != "" {
        else if SharedManager.shared.isAppOpenFromDeepLink == true {
            //Play specific reels shared from link
            url = "news/reels?context=\(contextID)"
            SharedManager.shared.isAppOpenFromDeepLink = false
        }
        else {
            if SharedManager.shared.curReelsCategoryId == "" {
                // Reels
                url = "news/reels"
            }
            else {
                // Discover specific reels
                url = "news/reels?context=\(contextID.replace(string: "+", replacement: "%2B").replace(string: "=", replacement: "%3D"))"
            }
        }
        
        print("URL = \(url)")
        
        var type = ""
        if !isBackButtonNeeded {
            /*
            if SharedManager.shared.getSelectedReelsCategory() == 0 {
                type = "FOR_YOU"
            } else if SharedManager.shared.getSelectedReelsCategory() == 1 {
                type = "FOLLOWING"
            } else {
                type = "COMMUNITY"
            }*/
            
            if isOnFollowing {
                type = "FOLLOWING"
            }
            else {
                type = "FOR_YOU"
            }
        }
        
        print("performWSToGetReelsData URL = \(url)")
        
        let params = [
            "page": page,
            "type": type,
            "tag": isOpenFromTags ? titleText.replace(string: "#", replacement: "") : ""
        ] as [String : Any]
        
        self.viewEmptyMessage.isUserInteractionEnabled = false
        
        WebService.URLResponse(url, method: .get, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            
            self?.delegate?.loaderShowing(status: false)
            
            self?.stopPullToRefresh()
            SharedManager.shared.hideLaoderFromWindow()
            
            ANLoader.hide()
            guard let self = self else {
                return
            }
            self.isApiCallAlreadyRunning = false
            
            do{
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
                    
                    //write Cache Codable types object reels
                    if !self.isBackButtonNeeded && self.nextPageData.isEmpty {
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
                        
                        
                        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitReelID != "" && self.isSugReels == false && self.isShowingProfileReels == false && self.isFromChannelView == false {
                            //LOAD ADS
                            self.reelsArray.removeAll { $0.iosType == Constant.newsArticle.ARTICLE_TYPE_ADS }
                            self.reelsArray = self.reelsArray.adding(Reel(id: "", context: "", reelDescription: "", media: "", media_landscape: "", mediaMeta: nil, publishTime: "", source: nil, info: nil, authors: nil, captions: nil, image: "", status: "", iosType: Constant.newsArticle.ARTICLE_TYPE_ADS, nativeTitle: true), afterEvery: SharedManager.shared.adsInterval)
                        }
                                                
                        if self.showSkeletonLoader {
                            self.showSkeletonLoader = false
                            if let skeletonCell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ReelsSkeletonAnimation {
                                skeletonCell.hideLaoder()
//                                skeletonCell.stopSliding()
                            }
                            
//                            self.collectionView.reloadData()
                        } else {
                            if isRefreshRequired {
                                
                                self.stopVideo()
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
                        
                        if (!self.fromMain || self.isPullToRefresh){
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
                        //                        let newIndex = self.reelsArray.count
                        let newindex = self.reelsArray.count
                        var newIndexArray = [IndexPath]()
                        reelsData.map { reel in
                            if !self.reelsArray.contains(where: {$0.id == reel.id}) {
                                self.reelsArray.append(reel)
                            }
                        }
                        print("reelsArray.count = \(self.reelsArray.count)")

                        print("reelsArray.count DATA= \(reelsData.count)")
                        
                        if self.cacheLimit < self.reelsArray.count{
                            self.cacheLimit = self.reelsArray.count
                        }
                        self.startReelsCaching()
                        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitReelID != "" && self.isSugReels == false && self.isShowingProfileReels == false && self.isFromChannelView == false && self.fromMain{
                            //LOAD ADS
                            self.reelsArray.removeAll{ $0.iosType == Constant.newsArticle.ARTICLE_TYPE_ADS }
                            self.reelsArray = self.reelsArray.adding(Reel(id: "", context: "", reelDescription: "", media: "", media_landscape: "", mediaMeta: nil, publishTime: "", source: nil, info: nil, authors: nil, captions: nil, image: "", status: "", iosType: Constant.newsArticle.ARTICLE_TYPE_ADS, nativeTitle: false), afterEvery: SharedManager.shared.adsInterval)
                            
                        }
                        
                        
//                        for i in newindex...self.reelsArray.count - 1
//                        {
//                            SharedManager.shared.saveAllVideosThumbnailsToCache(imageURL: self.reelsArray[i].image ?? "")
//                            newIndexArray.append(IndexPath(item: i, section: 0))
//                        }
                        
                        
                        self.collectionView.performBatchUpdates {
                            self.collectionView.layoutIfNeeded()
                            self.collectionView.insertItems(at: newIndexArray)
                        } completion: { status in
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
                        
                        
                        //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        //                            self.playNextCellVideo(indexPath: IndexPath(item: newIndex, section: 0))
                        //                        }
                        
                        
                        print("Reels array count = \(self.reelsArray.count)")
                        self.reelsArray.map { value in
                            print("VALUEEEE REELS = \(value)")
                        }
                    }
                    
                    
                } else {
                    
                    print("Empty Result")
                    if self.reelsArray.count == 0 {
                        
                        if self.isOpenedFollowingPrefernce {
                            self.delegate?.switchBackToForYou()
                            self.isOpenedFollowingPrefernce = false
                        }
                        else {
                            //                            self.openFollowingPrefernce()
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
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            self.delegate?.loaderShowing(status: false)
            self.stopPullToRefresh()
            SharedManager.shared.hideLaoderFromWindow()
            
            self.isApiCallAlreadyRunning = false
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

//MARK:- ReelsCC Delegate
extension ReelsVC: ReelsCCDelegate {
    
    func didSwipeRight(cell: ReelsCC) {
        
        //        if isBackButtonNeeded == false {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        pauseCellVideo(indexPath: indexPath)
        
        if isRightMenuLoaded == false {
            setupSideMenu()
            if let rightMenuNavigationController = rightMenuNavigationController {
//                rightMenuNavigationController.modalPresentationStyle = .fullScreen
                self.present(rightMenuNavigationController, animated: true, completion: nil)
            }
        }
        //        }
    }
    
    func didTapViewMore(cell: ReelsCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        pauseCellVideo(indexPath: indexPath)
        
//        if let ptcTBC = tabBarController as? PTCardTabBarController {
//            ptcTBC.showTabBar(false, animated: false)
//        }
        
        
        /*
        let vc = ViewMoreReelsVC.instantiate(fromAppStoryboard: .Reels)
        vc.reelContent = reelsArray[indexPath.item]
        let navVC = PanNavigationViewController(rootViewController: vc)

//        if let vc = navVC.viewControllers.first as? ViewMoreReelsVC {
//            vc.reelContent = reelsArray[indexPath.item]
//        }
        navVC.modalPresentationStyle = .fullScreen
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            present(navVC, animated: true)
        }
        else {
            presentPanModal(navVC)
        }
        */
        
        let reel = self.reelsArray[currentlyPlayingIndexPath.item]
        
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
        self.isViewControllerVisible = false
        self.present(navVC, animated: true, completion: nil)
        
    }
    
    func didTapComment(cell: ReelsCC) {
        
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        self.stopVideo()
        isViewControllerVisible = false
        self.appDelegate.setOrientationPortraitInly()
        
        let content = reelsArray[indexPath.item]
        let vc = CommentsVC.instantiate(fromAppStoryboard: .Home)
        vc.articleID = content.id ?? ""
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        navVC.modalPresentationStyle = .overFullScreen
        self.present(navVC, animated: true, completion: nil)
        
        
    }
    
    func didTapLike(cell: ReelsCC) {
        
        if isLikeApiRunning {
            return
        }
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        var likeCount = self.reelsArray[indexPath.item].info?.likeCount
        
        if (self.reelsArray[indexPath.item].info?.isLiked ?? false) {
            
            likeCount = (likeCount ?? 0) - 1
        } else {
            
            likeCount = (likeCount ?? 0) + 1
        }
        
        let info = Info(viewCount: self.reelsArray[indexPath.item].info?.viewCount, likeCount: likeCount, commentCount: self.reelsArray[indexPath.item].info?.commentCount, isLiked: !(self.reelsArray[indexPath.item].info?.isLiked ?? false))
        self.reelsArray[indexPath.item].info = info
        cell.setLikeComment(model: self.reelsArray[indexPath.item].info, showAnimation: true)
        
        performWSToLikePost(article_id: self.reelsArray[indexPath.item].id ?? "", isLike: self.reelsArray[indexPath.item].info?.isLiked ?? false)
    }
    
    func didTapViewMoreOptions(cell: ReelsCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let content = reelsArray[indexPath.item]
        // Open action sheet for share
        self.pauseCellVideo(indexPath: indexPath)
        self.performWSToShare(indexPath: indexPath, id: content.id ?? "", isOpenViewMoreOptions: true)
    }
    
    
    func didTapShare(cell: ReelsCC) {
        
        self .downloadVideoInLocal()
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let content = reelsArray[indexPath.item]
        
        self.pauseCellVideo(indexPath: indexPath)
        self.performWSToShare(indexPath: indexPath, id: content.id ?? "", isOpenViewMoreOptions: false)
    }
    
    func didTapOpenSource(cell: ReelsCC) {
        
        //        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        //        let content = reelsArray[indexPath.item]
        //
        ////        let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
        //////        vc.delegateVC = self
        ////        vc.webURL = content.source?.link ?? ""
        ////        vc.titleWeb = content.source?.name ?? ""
        ////        vc.modalPresentationStyle = .fullScreen
        ////        self.present(vc, animated: true, completion: nil)
        //
        //        SharedManager.shared.openWebPageViewController(parentVC: self, pageUrlString: content.source?.link ?? "", isPresenting: true)
    }
    
    func didTapEditArticle(cell: ReelsCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        self.pauseCellVideo(indexPath: indexPath)
        
        
        let vc = BottomSheetArticlesVC.instantiate(fromAppStoryboard: .Main)
        vc.index = cell.btnEditArticle.tag
        vc.isFromReels = true
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)

        
        
    }
    
    func didTapOpenCaptionType(cell: ReelsCC, action: String) {
        
        let actionArr = action.components(separatedBy: "/")
        if actionArr.count == 2 {
            
            let aName = actionArr.first ?? ""
            let aId = actionArr.last ?? ""
            
            if action.contains("topic") {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.topicOpen, eventDescription: "")
                cell.isUserInteractionEnabled = false
                
                self.performWSToOpenTopics(id: aId, title: "", favorite: false)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    cell.isUserInteractionEnabled = true
                }
            }
            else if action.contains("source") {
                
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
                cell.isUserInteractionEnabled = false
                
                self.performGoToSource(id: aId)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    cell.isUserInteractionEnabled = true
                }
            }
            else if action.contains("author") {
                
                if aId == SharedManager.shared.userId {
                    
                    let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen
                    //vc.delegate = self
                    self.present(navVC, animated: true, completion: nil)
                }
                else {
                    
                    let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                    vc.authors = [Authors(id: aId, context: nil, name: nil, username: nil, image: nil, favorite: nil)]
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen
                    //vc.delegate = self
                    self.present(navVC, animated: true, completion: nil)
                }
            }
        }
       
    }
    
    func didTapAuthor(cell: ReelsCC) {
        
        let index = cell.btnAuthor.tag
        
        if self.reelsArray[index].source != nil {
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
            cell.isUserInteractionEnabled = false
            
            self.performGoToSource(id: self.reelsArray[index].source?.id ?? "")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                cell.isUserInteractionEnabled = true
            }
            
        } else if let authors = self.reelsArray[index].authors, authors.count > 0 {
            let aId = authors.first?.id ?? ""
            if aId == SharedManager.shared.userId {
                
                let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
                let navVC = AppNavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen
                //vc.delegate = self
                self.present(navVC, animated: true, completion: nil)
            }
            else {
                
                let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                vc.authors = authors
                let navVC = AppNavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen
                //vc.delegate = self
                self.present(navVC, animated: true, completion: nil)
            }
        }
        
    }
    
    func didTapFollow(cell: ReelsCC, tagNo: Int) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        if tagNo == 0 {
            
            //Follow
            if cell.imgUserPlus.isHidden { return }
            cell.imgUserPlus.isHidden = true
            cell.btnUserPlus.isUserInteractionEnabled = false
            
            var FullResponse: ReelsModel?
            if isOnFollowing {
                FullResponse = try? DataCache.instance.readCodable(forKey: Constant.CACHE_REELS_Follow)
            }
            else {
                FullResponse = try? DataCache.instance.readCodable(forKey: Constant.CACHE_REELS)
            }
            
            //Check source if its not available then use author
            if let source = self.reelsArray[indexPath.item].source {
                
                let fav = source.favorite ?? false
                self.reelsArray[indexPath.item].source?.favorite = !fav
                cell.reelModel = self.reelsArray[indexPath.item]
                // update all cells
                for (indexP, rl) in reelsArray.enumerated() {
                    if rl.source?.id == self.reelsArray[indexPath.item].source?.id {
                        self.reelsArray[indexP].source?.favorite = !fav
                        if let cellP = collectionView.cellForItem(at: IndexPath(item: indexP, section: 0)) as? ReelsCC {
                            cellP.reelModel?.source?.favorite = !fav
                            cellP.setFollowButton(hidden: cellP.reelModel?.source?.favorite ?? false)
                        }
                    }
                }
                
                
                FullResponse?.reels = self.reelsArray
                self.writeToCache(response: FullResponse)
                
                cell.btnUserPlus.showLoader()
                SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [source.id ?? ""], isFav: !fav, type: .sources) { status in
                    cell.btnUserPlus.hideLoaderView()
                    cell.btnUserPlus.isUserInteractionEnabled = true
                    if status {
                        print("success")
                    }
                    else{
                        print("failed")
                        DispatchQueue.main.async {
                            cell.imgUserPlus.isHidden = false
                        }
                    }
                }
            }
            else {
                
                let id = self.reelsArray[indexPath.item].authors?.first?.id ?? ""
                let fav = self.reelsArray[indexPath.item].authors?.first?.favorite ?? false
                
                if (self.reelsArray[indexPath.item].authors?.count ?? 0) > 0 {
                    self.reelsArray[indexPath.item].authors?[0].favorite = !fav
                }
                cell.reelModel = self.reelsArray[indexPath.item]
                // update all cells
                for (indexP, rl) in reelsArray.enumerated() {
                    if rl.source?.id == self.reelsArray[indexPath.item].source?.id {
                        self.reelsArray[indexP].source?.favorite = !fav
                        if let cellP = collectionView.cellForItem(at: IndexPath(item: indexP, section: 0)) as? ReelsCC {
                            cellP.reelModel?.source?.favorite = !fav
                            cellP.setFollowButton(hidden: cellP.reelModel?.source?.favorite ?? false)
                        }
                    }
                }
                
                
                self.writeToCache(response: FullResponse)

                cell.btnUserPlus.showLoader()
                SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [id], isFav: !fav, type: .authors) { status in
                    cell.btnUserPlus.hideLoaderView()
                    cell.btnUserPlus.isUserInteractionEnabled = true
                    if status {
                        print("success")
                    }
                    else{
                        print("failed")
                        DispatchQueue.main.async {
                            cell.imgUserPlus.isHidden = false
                        }
                    }
                }
            }
        }
        else {
            
            //view
            self.didTapAuthor(cell: cell)
        }
    }
    
    func didTapHashTag(cell: ReelsCC, text: String) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let article = self.reelsArray[indexPath.item]
        let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
        //        vc.contextID = article.data?.context ?? ""
        vc.titleText = "#\(text)"
        vc.isBackButtonNeeded = true
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        vc.isOpenFromTags = true
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func didSingleTapDetected(cell: ReelsCC) {
        
        //        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        //        let article = self.reelsArray[indexPath.item]
        //        SharedManager.shared. (parentVC: self, pageUrlString: "www.google.com", isPresenting: true)
        didTapViewMore(cell: cell)
    }
    
    func videoVolumeStatusChanged(cell: ReelsCC) {
    }
    
    func videoPlayingStarted(cell: ReelsCC) {
    }
    
    func videoPlayingFinished(cell: ReelsCC) {
        
        if isOpenfromNotificationList {
            self.sendVideoViewedAnalyticsEvent()
            if SharedManager.shared.reelsAutoPlay {
                self.playCurrentCellVideo()
            }
            return
        }
        
        guard let indexPath = collectionView.indexPath(for: cell)  else { return }
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelsFinishedPlaying, eventDescription: "", article_id: reelsArray[indexPath.item].id ?? "")
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelsDurationEvent, eventDescription: "", article_id: reelsArray[indexPath.item].id ?? "", duration: cell.player.totalDuration.formatToMilliSeconds() ?? "")
        
        
        if isFromChannelView && (indexPath.item == reelsArray.count - 1) {
            let nextIndexPath = IndexPath(item: 0, section: 0)
            playNextCellVideo(indexPath: nextIndexPath)
        }
        else if isShowingProfileReels && (indexPath.item == reelsArray.count - 1) {
            let nextIndexPath = IndexPath(item: 0, section: 0)
            playNextCellVideo(indexPath: nextIndexPath)
        }
        else if isSugReels && (indexPath.item == reelsArray.count - 1) {
            let nextIndexPath = IndexPath(item: 0, section: 0)
            playNextCellVideo(indexPath: nextIndexPath)
        }
        // If Last item, scroll to first item
        else if indexPath.item == reelsArray.count - 5 && reelsArray.count > 1 {
            //            let firstIndexPath = IndexPath(item: 0, section: 0)
            //            playNextCellVideo(indexPath: firstIndexPath)
            callWebsericeToGetNextVideos()
        } else if reelsArray.count > 0 {
            let nextIndexPath = IndexPath(item: indexPath.item + 1, section: 0)
            if nextIndexPath.item < reelsArray.count {
                playNextCellVideo(indexPath: nextIndexPath)
            }
        }
        
    }
    
    func didPangestureDetected(cell: ReelsCC, panGesture: UIPanGestureRecognizer, view: UIView) {
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
        
        guard let indexPath = collectionView.indexPath(for: cell)  else { return }
        
//        print("media_landscape currentlyPlayingIndexPath, \(currentlyPlayingIndexPath.item)")
//        print("media_landscape indexPath, \(indexPath.item)")
//        print("media_landscape lblSeeMore, \(cell.lblSeeMore.text ?? "")")
//        print("media_landscape reelDescription, \(reelsArray[indexPath.item].reelDescription ?? "")")
//        print("media_landscape, \(reelsArray[indexPath.item].media_landscape ?? "")")
        if let url = URL(string: reelsArray[indexPath.item].media_landscape ?? "") {
            
            stopVideo()
            isWatchingRotatedVideos = true
            collectionView.alpha = 0
            viewCategoryType.alpha = 0
//            MediaManager.sharedInstance.playEmbeddedVideo(url:url, embeddedContentView: nil, userinfo: ["fullScreenMode" :EZPlayerFullScreenMode.landscape], isOpenForReels: true)
            
            let vc = ReelsFullScreenVC.instantiate(fromAppStoryboard: .Reels)
            vc.imgPlaceHolder = cell.imgThumbnailView
            vc.url = url
            vc.modalPresentationStyle = .fullScreen
            vc.customDuration = CMTime(seconds: cell.player.currentDuration, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            
            // captions
            vc.captions = reelsArray[indexPath.item].captions
            vc.delegate = self
            MediaManager.sharedInstance.isLandscapeReelPresenting = true
            
            vc.modalPresentationStyle = .overFullScreen
            (UIApplication.shared.delegate as! AppDelegate).setOrientationBothLandscape()
            self.present(vc, animated: true, completion: nil)
            
        }
        
    }
    
    func didTapPlayVideo(cell: ReelsCC) {
        
        cell.viewPlayButton.isHidden = true
        playCurrentCellVideo()
    }
    
    
    func didTapCaptions(cell: ReelsCC) {
    }
    
    
}


extension ReelsVC {
    
    func performWSToLikePost(article_id: String, isLike: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let params = ["like": isLike]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        //        isLikeApiRunning = true
        WebService.URLResponseJSONRequest("social/likes/article/\(article_id)", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            self.isLikeApiRunning = false
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    print("like status", status)
                    //                    if status == Constant.STATUS_SUCCESS_LIKE {
                    //                        print("Successfull")
                    //                    }
                    //                    else {
                    ////                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    //                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "social/likes/article/\(article_id)", error: jsonerror.localizedDescription, code: "")
                self.isLikeApiRunning = false
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            self.isLikeApiRunning = false
            print("error parsing json objects",error)
        }
        
    }
    
}


//MARK- EDIT ARTICLE BOTTOM SHEET
extension ReelsVC: BottomSheetArticlesVCDelegate {
    
    func dismissBottomSheetArticlesVCDelegateAction(type: Int, idx: Int) {
        
        if type == -1 {
            //When user tap outside only dismiss bottom sheet
            if SharedManager.shared.reelsAutoPlay {
                self.playCurrentCellVideo()
            }
            return
        }
        
        if type == 0 {
            //edit
            
            let reel = self.reelsArray[idx]
            
            let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
            vc.postArticleType = .reel
            vc.isEditable = true
            vc.isScheduleRequired = false
            
            let bullet = [Bullets(data: reel.reelDescription, audio: nil, duration: nil, image: nil)]
            
            vc.yArticle = articlesData(id: reel.id, title: reel.reelDescription, media: reel.media, image: reel.image, link: reel.media, color: nil, publish_time: reel.publishTime, source: reel.source, bullets: bullet, topics: nil, status: nil, mute: nil, type: Constant.newsArticle.ARTICLE_TYPE_VIDEO, meta: nil, info: nil, media_meta: reel.mediaMeta)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        else if type == 1 {
            //delete
            
            let reel = self.reelsArray[idx]
            self.performWSToArticleUnpublished(reel.id ?? "")
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
        
        WebService.URLResponse("studio/articles/\(id)/status", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
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
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
}

extension ReelsVC {
    
    func performWSToOpenTopics(id: String, title: String, favorite: Bool) {
                            
        ANLoader.showLoading(disableUI: false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        let url = "news/topics/related/\(id)"
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
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
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            //SharedManager.shared.showAPIFailureAlert()
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }

    
    func performGoToSource(id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/data/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
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
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: "Related Sources not available")
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
}


extension ReelsVC: CommentsVCDelegate {
    
    func commentsVCDismissed(articleID: String) {
        
        isViewControllerVisible = true
        self.appDelegate.setOrientationPortraitInly()
        
        if SharedManager.shared.reelsAutoPlay {
            self.playCurrentCellVideo()
        }
        SharedManager.shared.performWSToGetCommentsCount(id: articleID) { info in
            if info != nil {
                
                if let selectedIndex = self.reelsArray.firstIndex(where: { $0.id == articleID }) {
                    //                    self.articles[selectedIndex].info = info
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
        
        self.showLoaderInVC()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/articles/\(id)/share/info", method: .get, parameters: nil, headers: token, withSuccess: { [weak self] (response)  in
            
            self?.hideLoaderVC()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ShareSheetDC.self, from: response)
                
                //"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
                
                SharedManager.shared.instaMediaUrl = ""
                self?.shareTitle = FULLResponse.share_message ?? ""
                self?.articleArchived = FULLResponse.article_archived ?? false
                self?.sourceBlock = FULLResponse.source_blocked ?? false
                self?.sourceFollow = FULLResponse.source_followed ?? false
                
                
                if let media = FULLResponse.download_link {
                    
                    SharedManager.shared.instaMediaUrl = media
                }
                if isOpenViewMoreOptions == false  {
                    
                    self?.pauseCellVideo(indexPath: indexPath)
                    //                self?.openCustomShareSheet(shareTitle: shareTitle, articleArchived: articleArchived)
                    
                    self?.openDefaultShareSheet(shareTitle: self?.shareTitle ?? "")
                    //                self?.saveVideoAndShare(shareTitle: shareTitle)
                }
                else {
                    self?.openViewMoreOptions()
                }

                
            } catch let jsonerror {
                self?.hideLoaderVC()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
    func saveVideoAndShare(shareTitle: String) {
        
        if !(SharedManager.shared.instaMediaUrl.isEmpty) || SharedManager.shared.instaMediaUrl != "" {
            
            self.viewIndicator.isHidden = false
            self.indicator.isHidden = false
            self.indicator.startAnimating()
            SharedManager.shared.isReelsVideo = true
            self.mediaWatermark.downloadVideo(video: SharedManager.shared.instaMediaUrl, saveToLibrary: true) { status in
                
                self.stopIndicatorLoading()
                if status {
                    
                }
                else {
                    
                }
            }
        }
    }
    
    func openCustomShareSheet(shareTitle: String, articleArchived: Bool) {
        
        DispatchQueue.main.async {
            
            let vc = CustomShareVC.instantiate(fromAppStoryboard: .Reels)
            vc.modalPresentationStyle = .overFullScreen
            
            vc.shareText = shareTitle
            vc.articleArchived = articleArchived
            
            vc.dismissShareSheet = { [weak self] (resume) in
                self?.isShareSheetPresenting = false
                if resume {
                    if SharedManager.shared.reelsAutoPlay {
                        self?.playCurrentCellVideo()
                    }
                }
            }
            vc.didTapFlag = { [weak self] in
                
                self?.playCurrentCellVideo()
                self?.openReportNews()
            }
            
            vc.didTapNotInterested = { [weak self] in
                
                if SharedManager.shared.reelsAutoPlay {
                    self?.playCurrentCellVideo()
                }
                guard let self = self else { return }
                
                let reel = self.reelsArray[self.currentlyPlayingIndexPath.item]
                self.performWSuggestLess(reel.id ?? "")
            }
            vc.didTapAddToFavoriteVideo = { [weak self] in
                
                if SharedManager.shared.reelsAutoPlay {
                    self?.playCurrentCellVideo()
                }
                
                guard let self = self else { return }
                
                //Save article
                let reel = self.reelsArray[self.currentlyPlayingIndexPath.item]
                self.performArticleArchive(reel.id ?? "", isArchived: !articleArchived)
            }
            vc.didTapSaveToDeviceVideo = { [weak self] in
                
                if SharedManager.shared.reelsAutoPlay {
                    self?.playCurrentCellVideo()
                }
                
                guard let self = self else { return }
                
                if !(SharedManager.shared.instaMediaUrl.isEmpty) || SharedManager.shared.instaMediaUrl != "" {
                    
                    self.viewIndicator.isHidden = false
                    self.indicator.isHidden = false
                    self.indicator.startAnimating()
                    
                    SharedManager.shared.isReelsVideo = true
                    self.mediaWatermark.downloadVideo(video: SharedManager.shared.instaMediaUrl, saveToLibrary: true) { status in
                        
                        self.stopIndicatorLoading()
                    }
                }
                else {
                    
                    SharedManager.shared.showAlertLoader(message: "You can't download this video")
                }
            }
            
            vc.openFacebookForVideo = { [weak self] in
                
                if !(SharedManager.shared.instaMediaUrl.isEmpty) || SharedManager.shared.instaMediaUrl != "" {
                    
                    self?.viewIndicator.isHidden = false
                    self?.indicator.isHidden = false
                    self?.indicator.startAnimating()
              
                    SharedManager.shared.isReelsVideo = true
                    
                    self?.mediaWatermark.downloadVideo(video: SharedManager.shared.instaMediaUrl, saveToLibrary: true) { status in
                        
                        if status {
                            
                            guard let schemaUrl = URL(string: "fb://") else {
                        
                                self?.stopIndicatorLoading()
                                return //be safe
                            }
                            DispatchQueue.main.async {
                                
                                if UIApplication.shared.canOpenURL(schemaUrl) {
                                    
                                    let content: ShareVideoContent = ShareVideoContent()
                                    self?.createAssetURL(url: SharedManager.shared.videoUrlTesting!) { url in
                                        let video = ShareVideo()
                                        video.videoURL = URL(string: url)
                                        content.video = video
                                        
                                        let shareDialog = ShareDialog()
                                        shareDialog.shareContent = content
                                        shareDialog.mode = .native
                                        shareDialog.delegate = self
                                        shareDialog.show()
                                    }
                                    self?.stopIndicatorLoading()
                                }else {
                                    
                                    self?.stopIndicatorLoading()
                                    print("app not installed")
                                }
                                
                            }
                            
                        }
                        else {
                            
                            self?.stopIndicatorLoading()
                        }
                    }
                    
//                    let asset = AVURLAsset(url: URL(string: SharedManager.shared.instaMediaUrl)!, options: options)
//                    self?.mediaWatermark.watermark(video: asset , imageName: "mediaMarkLight", watermarkText: "", saveToLibrary: true, watermarkPosition: .BottomLeft, completion: { success,_,videoURL in
//
//                        if (success != nil) {
//
//                            guard let schemaUrl = URL(string: "fb://") else {
//
//                             //   self?.playCurrentCellVideo()
//                                self?.stopIndicatorLoading()
//                                return //be safe
//                            }
//
//                            DispatchQueue.main.async {
//
//                                if UIApplication.shared.canOpenURL(schemaUrl) {
//
//                                    let content: ShareVideoContent = ShareVideoContent()
//                                    self?.createAssetURL(url: SharedManager.shared.videoUrlTesting!) { url in
//                                        let video = ShareVideo()
//                                        video.videoURL = URL(string: url)
//                                        content.video = video
//
//                                        let shareDialog = ShareDialog()
//                                        shareDialog.shareContent = content
//                                        shareDialog.mode = .native
//                                        shareDialog.delegate = self
//                                        shareDialog.show()
//                                    }
//                                    self?.stopIndicatorLoading()
//                                }else {
//
//                               //     self?.playCurrentCellVideo()
//                                    self?.stopIndicatorLoading()
//                                    print("app not installed")
//                                }
//                            }
//                        }
//                        else {
//
//                         //   self?.playCurrentCellVideo()
//                            self?.stopIndicatorLoading()
//                        }
//                    })
                }
            }
            
            vc.didTapSendVideoOnWhatsapp = { [weak self] (type, sourceName, media) in
                
                if !(SharedManager.shared.instaMediaUrl.isEmpty) || SharedManager.shared.instaMediaUrl != "" {
                    
                    self?.viewIndicator.isHidden = false
                    self?.indicator.isHidden = false
                    self?.indicator.startAnimating()
                    SharedManager.shared.isReelsVideo = true
                    self?.mediaWatermark.downloadVideo(video: SharedManager.shared.instaMediaUrl, saveToLibrary: true) { status in
                        
                        if status {
                            
                            let urlWhats = "whatsapp://app"
                            if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                                
                                self?.stopIndicatorLoading()
                                DispatchQueue.main.async {
                                    
                                    if let whatsappURL = URL(string: urlString) {
                                        if UIApplication.shared.canOpenURL(whatsappURL) {
                                            
                                            self?.DocController = UIDocumentInteractionController(url: SharedManager.shared.videoUrlTesting!)
                                            self?.DocController.uti = "net.whatsapp.movie"
                                            self?.DocController.delegate = self
                                            self?.DocController.presentOpenInMenu(from: CGRect.zero, in: (self?.view)!, animated: true)
                                            
                                            
                                        } else {
                                            
                                            //     self?.playCurrentCellVideo()
                                            self?.stopIndicatorLoading()
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            
                            self?.stopIndicatorLoading()
                        }
                    }
                    //                    var options = [String : Bool]()
                    //                    if #available(iOS 13.0, *) {
                    //                        options = [AVURLAssetAllowsCellularAccessKey: true, AVURLAssetAllowsExpensiveNetworkAccessKey : true]
                    //                    } else {
                    //                        // Fallback on earlier versions
                    //                        options = [AVURLAssetAllowsCellularAccessKey: true]
                    //                    }
                    //                    SharedManager.shared.isReelsVideo = true
                    //                    let asset = AVURLAsset(url: URL(string: SharedManager.shared.instaMediaUrl)!, options: options)
                    //                    self?.mediaWatermark.watermark(video: asset , imageName: "mediaMarkLight", watermarkText: "", saveToLibrary: false, watermarkPosition: .BottomLeft, completion: { success,_,outPutURL in
                    //
                    //                        if (success != nil) {
                    //
                    //                            let urlWhats = "whatsapp://app"
                    //                            if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                    //
                    //                                self?.stopIndicatorLoading()
                    //                                DispatchQueue.main.async {
                    //
                    //                                    if let whatsappURL = URL(string: urlString) {
                    //                                        if UIApplication.shared.canOpenURL(whatsappURL) {
                    //
                    //                                            self?.DocController = UIDocumentInteractionController(url: SharedManager.shared.videoUrlTesting!)
                    //                                            self?.DocController.uti = "net.whatsapp.movie"
                    //                                            self?.DocController.delegate = self
                    //                                            self?.DocController.presentOpenInMenu(from: CGRect.zero, in: (self?.view)!, animated: true)
                    //
                    //
                    //                                        } else {
                    //
                    //                                            //     self?.playCurrentCellVideo()
                    //                                            self?.stopIndicatorLoading()
                    //                                        }
                    //                                    }
                    //                                }
                    //                            }
                    //                        }
                    //                        else {
                    //
                    //                          //  self?.playCurrentCellVideo()
                    //                            self?.stopIndicatorLoading()
                    //                        }
                    //                    })
                }
            }
            
            vc.didTapShareInInstaStories = { [weak self] in
                
                if !(SharedManager.shared.instaMediaUrl.isEmpty) || SharedManager.shared.instaMediaUrl != "" {
                    
                    self?.viewIndicator.isHidden = false
                    self?.indicator.isHidden = false
                    self?.indicator.startAnimating()
                    SharedManager.shared.isReelsVideo = true
                    self?.mediaWatermark.downloadVideo(video: SharedManager.shared.instaMediaUrl, saveToLibrary: true) { status in
                        
                        if status {
                            
                            guard let instagramUrl = URL(string: "instagram-stories://share") else {
                                return
                            }
                            DispatchQueue.main.async {
                                
                                var videoData : Data?
                                do {
                                    videoData = try Data(contentsOf: SharedManager.shared.videoUrlTesting!)
                                } catch let error {
                                    print(error)
                                }
                                
                                if UIApplication.shared.canOpenURL(instagramUrl) {
                                    
                                    let pasterboardItems = [["com.instagram.sharedSticker.backgroundVideo": videoData as Any]]
                                    UIPasteboard.general.setItems(pasterboardItems)
                                    UIApplication.shared.open(instagramUrl)
                                } else {
                                }
                            }
                            self?.stopIndicatorLoading()
                        }
                        else {
                            
                            self?.stopIndicatorLoading()
                        }
                    }
                    
//                    var options = [String : Bool]()
//                    if #available(iOS 13.0, *) {
//                        options = [AVURLAssetAllowsCellularAccessKey: true, AVURLAssetAllowsExpensiveNetworkAccessKey : true]
//                    } else {
//                        // Fallback on earlier versions
//                        options = [AVURLAssetAllowsCellularAccessKey: true]
//                    }
//                    SharedManager.shared.isReelsVideo = true
//
//                    SharedManager.shared.isReelsVideo = true
//                    let asset = AVURLAsset(url: URL(string: SharedManager.shared.instaMediaUrl)!, options: options)
//                    self?.mediaWatermark.watermark(video: asset , imageName: "mediaMarkLight", watermarkText: "", saveToLibrary: true, watermarkPosition: .BottomLeft, completion: { success,_,_ in
//
//                        if (success != nil) {
//
//
//                            guard let instagramUrl = URL(string: "instagram-stories://share") else {
//                                return
//                            }
//                            DispatchQueue.main.async {
//
//                                var videoData : Data?
//                                do {
//                                    videoData = try Data(contentsOf: SharedManager.shared.videoUrlTesting!)
//                                } catch let error {
//                                    print(error)
//                                }
//
//                                if UIApplication.shared.canOpenURL(instagramUrl) {
//
//                                    let pasterboardItems = [["com.instagram.sharedSticker.backgroundVideo": videoData as Any]]
//                                    UIPasteboard.general.setItems(pasterboardItems)
//                                    UIApplication.shared.open(instagramUrl)
//                                } else {
//                                }
//                            }
//                            self?.stopIndicatorLoading()
//                        }
//                        else {
//
//                            self?.stopIndicatorLoading()
//                        }
//                    })
                }
            }
            
            vc.didTapShareOnInstaFeeds = { [weak self] in
                
                if !(SharedManager.shared.instaMediaUrl.isEmpty) || SharedManager.shared.instaMediaUrl != "" {
                    
                    self?.viewIndicator.isHidden = false
                    self?.indicator.isHidden = false
                    self?.indicator.startAnimating()
                    SharedManager.shared.isReelsVideo = true
                    
                    self?.mediaWatermark.downloadVideo(video: SharedManager.shared.instaMediaUrl, saveToLibrary: true) { status in
                        
                        if status {
                            
                            DispatchQueue.main.async {
                                
                                let url = URL(string: ("instagram://library?LocalIdentifier=" + SharedManager.shared.instaVideoLocalPath))
                                
                                if UIApplication.shared.canOpenURL(url!) {
                                    UIApplication.shared.open(url!, options: [:], completionHandler:nil)
                                }
                                self?.stopIndicatorLoading()
                            }
                        }
                        else {
                            
                            self?.stopIndicatorLoading()
                        }
                    }
                }
            }
            
            self.isShareSheetPresenting = true
            self.present(vc, animated: true, completion: nil)
            
        }
    }
    
    func createAssetURL(url: URL, completion: @escaping (String) -> Void) {
        let photoLibrary = PHPhotoLibrary.shared()
        var videoAssetPlaceholder:PHObjectPlaceholder!
        photoLibrary.performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            videoAssetPlaceholder = request!.placeholderForCreatedAsset
        },
        completionHandler: { success, error in
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
    
    func performWSToUnblockSource(_ id: String, name:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        ANLoader.showLoading(disableUI: true)
        
        let param = ["sources":id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/unblock", method: .post, parameters:param , headers: token, withSuccess: { (response) in
            
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    
                    SharedManager.shared.showAlertLoader(message: "Unblocked \(name)", type: .alert)
                }
                else {
                    
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                ANLoader.hide()
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/unblock", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSuggestMoreOrLess(_ id: String, isMoreOrLess: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let query = isMoreOrLess ? "news/articles/\(id)/suggest/more" : "news/articles/\(id)/suggest/less"
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(query, method: .post, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    if status == Constant.STATUS_SUCCESS {
                        
                        if isMoreOrLess {
                            
                            SharedManager.shared.showAlertLoader(message: "You'll see more stories like this", type: .alert)
                        }
                        else {
                            
                            SharedManager.shared.showAlertLoader(message: "You'll see less stories like this", type: .alert)
                        }
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            print("error parsing json objects",error)
        }
    }
    
    func performBlockSource(_ id: String, sourceName: String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockSource, eventDescription: "", source_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        WebService.URLResponse("news/sources/block", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(BlockTopicDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    if status == Constant.STATUS_SUCCESS {
                        
                        SharedManager.shared.showAlertLoader(message: "Blocked \(sourceName)", type: .alert)
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/sources/block", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToBlockUnblockAuthor(_ id: String, name: String) {
        
        
        if self.sourceBlock == false {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockauthor, eventDescription: "", author_id: id)
        }
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        ANLoader.showLoading(disableUI: true)
        
        let param = ["authors": id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let query = sourceBlock ? "news/authors/unblock" : "news/authors/block"
        
        WebService.URLResponse(query, method: .post, parameters: param, headers: token, withSuccess: { (response) in
            
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    
                    if self.sourceBlock {
                        SharedManager.shared.showAlertLoader(message: "Unblocked \(name)", type: .alert)
                    }
                    else {
                        SharedManager.shared.showAlertLoader(message: "Blocked \(name)", type: .alert)
                    }

                }
                else {
                    
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                ANLoader.hide()
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func openReportNews() {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reportClick, eventDescription: "")
        
        let reel = self.reelsArray[currentlyPlayingIndexPath.item]
        
        let bullet = [Bullets(data: reel.reelDescription, audio: nil, duration: nil, image: nil)]
        let content = articlesData(id: reel.id, title: reel.reelDescription, media: reel.media, image: reel.image, link: reel.media, color: nil, publish_time: reel.publishTime, source: reel.source, bullets: bullet, topics: nil, status: nil, mute: nil, type: Constant.newsArticle.ARTICLE_TYPE_VIDEO, meta: nil, info: nil, media_meta: reel.mediaMeta)
        
        let vc = BottomSheetVC.instantiate(fromAppStoryboard: .registration)
        vc.delegateBottomSheet = self
        vc.article = content
        vc.isFromReels = true
        vc.openReportList = true
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func openViewMoreOptions() {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reportClick, eventDescription: "")
        
        let reel = self.reelsArray[currentlyPlayingIndexPath.item]
        
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
        vc.sourceBlock = self.sourceBlock
        vc.sourceFollow = self.sourceFollow
        vc.article_archived = self.articleArchived
        vc.share_message = self.shareTitle
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func openDefaultShareSheet(shareTitle: String) {
        
        DispatchQueue.main.async {
            
            //Share
            let shareContent: [Any] = [shareTitle]
            
            let activityVc = UIActivityViewController(activityItems: shareContent, applicationActivities: [])
            activityVc.excludedActivityTypes = [.assignToContact, .print, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .openInIBooks, .markupAsPDF]
            
            activityVc.completionWithItemsHandler = { activity, success, items, error in
                
                
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
        
        if self.indicator.isAnimating {
            
            DispatchQueue.main.async {
                
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                self.viewIndicator.isHidden = true
            }
        }
    }
}


//MARK:- BottomSheetVC Delegate methods
extension ReelsVC: BottomSheetVCDelegate {
    
    func didTapUpdateAudioAndProgressStatus() {
        
        if SharedManager.shared.reelsAutoPlay {
            self.playCurrentCellVideo()
        }
    }
    
    func didTapDissmisReportContent() {
        
        if SharedManager.shared.reelsAutoPlay {
            self.playCurrentCellVideo()
        }
        SharedManager.shared.showAlertLoader(message: "Report concern sent successfully.")
    }
    
    func didTapBottomShareSheetAction(sender: UIButton, article: articlesData) {
        
        if sender.tag != 2 {
            self.playCurrentCellVideo()
        }
        
        
        if sender.tag == 1 {
            
            //Save article
            performArticleArchive(article.id ?? "", isArchived: !self.articleArchived)
        }
        else if sender.tag == 2 {
            
            self.openDefaultShareSheet(shareTitle: shareTitle)
        }
        else if sender.tag == 3 {
            
            //Go to Source
            if let _ = article.source {
                self.performGoToSource(id: article.source?.id ?? "")
            }
            else {
                
                if (article.authors?.first?.id ?? "") == SharedManager.shared.userId {
                    
                    let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen
                    //vc.delegate = self
                    self.present(navVC, animated: true, completion: nil)
                }
                else {
                    
                    let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                    vc.authors = article.authors
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen
                    //vc.delegate = self
                    self.present(navVC, animated: true, completion: nil)
                }
            }
        }
        else if sender.tag == 4 {
            
            //Follow Source
            if self.sourceFollow {
                
                SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [article.source?.id ?? ""], isFav: false, type: .sources) { success in
                    print("status ", success)
                    if success {
                        SharedManager.shared.showAlertLoader(message: "Unfollowed \(article.source?.name ?? "")", type: .alert)
                    }
                }
            }
            else {
                
                SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [article.source?.id ?? ""], isFav: true, type: .sources) { success in
                    print("status ", success)
                    if success {
                        SharedManager.shared.showAlertLoader(message: "followed \(article.source?.name ?? "")", type: .alert)
                    }
                }
                
            }
        }
        else if sender.tag == 5 {
            
            //Block articles
            if let _ = article.source {
                /* If article source */
                if self.sourceBlock {
                    self.performWSToUnblockSource(article.source?.id ?? "", name: article.source?.name ?? "")
                }
                else {
                    self.performBlockSource(article.source?.id ?? "", sourceName: article.source?.name ?? "")
                }
            }
            else {
                //If article author data
                self.performWSToBlockUnblockAuthor(article.authors?.first?.id ?? "", name: article.authors?.first?.name ?? "")
            }
        }
        else if sender.tag == 6 {
            
            //Report content
            
        }
        else if sender.tag == 7 {
            
            //More like this
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.moreLikeThisClick, eventDescription: "")
            self.performWSuggestMoreOrLess(article.id ?? "", isMoreOrLess: true)
            
        }
        else if sender.tag == 8 {
            
            //I don't like this
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.lessLikeThisClick, eventDescription: "", article_id: article.id ?? "")
            self.performWSuggestMoreOrLess(article.id ?? "", isMoreOrLess: false)
        }
        else if sender.tag == 9 {
            SharedManager.shared.isCaptionsEnableReels = !SharedManager.shared.isCaptionsEnableReels
            
            if SharedManager.shared.isCaptionsEnableReels {
                getCaptionsFromAPI()
            }
            
            if SharedManager.shared.isCaptionsEnableReels {
                SharedManager.shared.showAlertLoader(message: "Turned on captions", type: .alert)
            }
            else {
                SharedManager.shared.showAlertLoader(message: "Turned off captions", type: .alert)
            }
        }
        else if sender.tag == 10 {
           
            // Copy
            // write to clipboard
            UIPasteboard.general.string = shareTitle
            SharedManager.shared.showAlertLoader(message: "Copied to clipboard successfully", type: .alert)
        }
        
        
    }
}


extension ReelsVC {
    
    func performArticleArchive(_ id: String, isArchived: Bool) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.archiveClick, eventDescription: "", article_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["archive": isArchived]
        WebService.URLResponse("news/articles/\(id)/archive", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    if status == Constant.STATUS_SUCCESS {
                  
                        SharedManager.shared.showAlertLoader(message: isArchived ? ApplicationAlertMessages.kMsgAddToFavorite : ApplicationAlertMessages.kMsRemoveFromFavorite, type: .alert)
                        self.isArchived = true
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/articles/\(id)/archive", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSuggestLess(_ id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/articles/\(id)/suggest/less", method: .post, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    if status == Constant.STATUS_SUCCESS {
                        
                        SharedManager.shared.showAlertLoader(message: "You'll see less stories like this")
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            print("error parsing json objects",error)
        }
    }
    
}


extension ReelsVC: ReelsCategoryVCDelegate {
    
    func reelsCategoryVCDismissed() {
        
        //        if SharedManager.shared.getSelectedReelsCategory() != currentCategory {
        //            if currentCategory != 1 {
        //                loadNewData()
        //            }
        //        }
        
    }
    
    func loadNewData() {
        
        DataCache.instance.clean(byKey: Constant.CACHE_REELS)
        DataCache.instance.clean(byKey: Constant.CACHE_REELS_Follow)
        stopVideo()
        setUpSelectedCategory()
        currentlyPlayingIndexPath = IndexPath(item: 0, section: 0)
        self.collectionView.setContentOffset(.zero, animated: false)
        reelsArray.removeAll()
        nextPageData = ""
        
//        self.collectionView.reloadData()

        print("CONTEXT = \(SharedManager.shared.curReelsCategoryId)")
//        performWSToGetReelsData(page: "", contextID: SharedManager.shared.curReelsCategoryId)
        setRefresh(scrollView: collectionView, manual: true)
        
    }
    
    func writeToCache(response: ReelsModel?) {
        if isOnFollowing {
            do {
                try DataCache.instance.write(codable: response, forKey: Constant.CACHE_REELS_Follow)
            } catch {
                print("Write error \(error.localizedDescription)")
            }
        }
        else {
            do {
                try DataCache.instance.write(codable: response, forKey: Constant.CACHE_REELS)
            } catch {
                print("Write error \(error.localizedDescription)")
            }
        }
    }
}


extension ReelsVC: ReelsVCDelegate {
    
    func changeScreen(pageIndex: Int) {
    }
    
    func switchBackToForYou() {
    }
    
    
    func loaderShowing(status: Bool) {
    }
    
    func backButtonPressed(_ isUpdateSavedArticle: Bool) {
        
    }
    func currentPlayingVideoChanged(newIndex: IndexPath) {
    }
}


// MARK: - Slide to show Details Page

extension ReelsVC {
    
    // MARK: - Swipe to dismiss methods
    func slideViewHorizontalTo(_ x: CGFloat, reset: Bool) {
        //        self.view.frame.origin = CGPoint(x: x, y: 0)
        
        //        if leadingContraintContainerView.constant > 0 {
        //            leadingContraintContainerView.constant = self.view.frame.width + x
        //        } else {
        //            leadingContraintContainerView.constant = 0
        //        }
        
        //        self.view.updateConstraintsIfNeeded()
        //        self.view.layoutIfNeeded()
        //
        //        stopVideo()
        
    }
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer, translationView: UIView) {
        
        //        if tableView.contentOffset.y > 0 {
        //            return
        //        }
        
        switch panGesture.state {
        
        case .began, .changed:
            // If pan started or is ongoing then
            // slide the view to follow the finger
            let translation = panGesture.translation(in: self.view)
            let x = translation.x //max(translation.x, 0)
            
            print("UIPanGestureRecognizer translation x", -x)
            slideViewHorizontalTo(x, reset: false)
            
        case .ended:
            
            // If pan ended, decide it we should close or reset the view
            // based on the final position and the speed of the gesture
            let translation = panGesture.translation(in: self.view)
            let velocity = panGesture.velocity(in: self.view)
            
        //            UIView.animate(withDuration: animationDuration) {
        //                if self.leadingContraintContainerView.constant > self.view.frame.size.width/2  || (velocity.x > self.minimumVelocityToHide) {
        //                    self.leadingContraintContainerView.constant = 0
        //                } else {
        //                    self.leadingContraintContainerView.constant = self.view.frame.width
        //                }
        //            }
        
        
        //            print("UIPanGestureRecognizer leadingContraintContainerView.constant * minimumScreenRatioToHide", leadingContraintContainerView.constant * minimumScreenRatioToHide)
        //            print("UIPanGestureRecognizer translation.x", leadingContraintContainerView.constant * minimumScreenRatioToHide)
        //            print("UIPanGestureRecognizer minimumVelocityToHide", minimumVelocityToHide)
        
        //            let closing = (-(translation.x) > leadingContraintContainerView.constant * minimumScreenRatioToHide) ||
        //                (velocity.x > minimumVelocityToHide)
        //
        //            if closing {
        //                UIView.animate(withDuration: animationDuration, animations: {
        //                    // If closing, animate to the bottom of the view
        //                    self.slideViewHorizontalTo(0, reset: true)
        //                }, completion: { (isCompleted) in
        //                    if isCompleted {
        //                        // Dismiss the view when it dissapeared
        //                    }
        //                })
        //            } else {
        //                // If not closing, reset the view to the top
        //                UIView.animate(withDuration: animationDuration, animations: {
        //                    self.slideViewHorizontalTo(0, reset: true)
        //                })
        //            }
        
        default:
            // If gesture state is undefined, reset the view to the top
            
            //            UIView.animate(withDuration: animationDuration) {
            //                if self.leadingContraintContainerView.constant < self.view.frame.size.width/2 {
            //                    self.leadingContraintContainerView.constant = 0
            //                } else {
            //                    self.leadingContraintContainerView.constant = self.view.frame.width
            //                }
            //            }
            break
            
        }
    }
    
}


extension ReelsVC: SideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
        
        if currentlyPlayingIndexPath.item > reelsArray.count - 1  {
            return
        }
        //Authors CollectionView
        if let source = reelsArray[currentlyPlayingIndexPath.item].source {
            
            stopVideo()
            
            if source.id == controller.currentlyOpenedChannedID {
                return
            }
            controller.showChannelDetails(source: source)
        }
        else if let author = reelsArray[currentlyPlayingIndexPath.item].authors {
            
            stopVideo()
            
            if author.first?.id == controller.currentlyOpenedAuthorID {
                return
            }
            controller.showAuthorProfile(author: author)
            
        }
        
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
        
        isRightMenuLoaded = true
        stopVideo()
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
        
        isRightMenuLoaded = false
        if SharedManager.shared.reelsAutoPlay {
            self.playCurrentCellVideo()
        }
    }
}


extension ReelsVC: FollowingVCDelegate {
    
    func didTapBack() {
        
        //        currentCategory = SharedManager.shared.getSelectedReelsCategory()
        ////        loadNewData()
        //        if currentCategory == 1 {
        //
        //            performWSToCheckFollowing()
        //        }
        //
        
    }
}

extension ReelsVC {
    
    
    
    //    func processVideo(urlString: URL) {
    //        resultImageView.image = nil
    //
    //        let urlString = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
    //
    //         let item = MediaItem(url: URL(string: urlString))
    //
    //            let logoImage = UIImage(named: "logo")
    //
    //            let firstElement = MediaElement(image: logoImage!)
    //            firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
    //
    //            let testStr = "Attributed Text"
    //         let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35) ]
    //            let attrStr = NSAttributedString(string: testStr, attributes: attributes)
    //
    //            let secondElement = MediaElement(text: attrStr)
    //            secondElement.frame = CGRect(x: 300, y: 300, width: logoImage!.size.width, height: logoImage!.size.height)
    //
    //            item.add(elements: [firstElement, secondElement])
    //
    //            let mediaProcessor = MediaProcessor()
    //            mediaProcessor.processElements(item: item) { [weak self] (result, error) in
    //                self?.videoPlayer.url = result.processedUrl
    //                self?.videoPlayer.playFromBeginning()
    //            }
    //
    //        let item = MediaItem(url: URL(string: urlString))
    //            let logoImage = UIImage(named: "rglogo")
    //
    //            let firstElement = MediaElement(image: logoImage!)
    //            firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
    //
    //            let secondElement = MediaElement(image: logoImage!)
    //            secondElement.frame = CGRect(x: 150, y: 150, width: logoImage!.size.width, height: logoImage!.size.height)
    //
    //            item.add(elements: [firstElement, secondElement])
    //
    //            let mediaProcessor = MediaProcessor()
    //            mediaProcessor.processElements(item: item) { [weak self] (result, error) in
    //                DispatchQueue.main.async {
    //                    self?.downloadVideoInLocal(url: result.processedUrl!, view: (self?.resultImageView)!)
    //                }
    //            }
    //     //   }
    //    }
    
    func downloadVideoInLocal() {
        
        
        
        let urlString = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
        
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: urlString),
               let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            print("Video is saved!")
                        }
                    }
                }
            }
        }
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
}

extension ReelsVC: SharingDelegate, UIDocumentInteractionControllerDelegate {
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("shared")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            //   self.didTapCancel(self)
        }
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("didFailWithError")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            //    self.didTapCancel(self)
        }
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        print("sharerDidCancel")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            //  self.didTapCancel(self)
        }
    }
}

 

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
            } completion: { status in
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
        
        self.view.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            self.view.isUserInteractionEnabled = true
            self.isWatchingRotatedVideos = false
            
            if let cell = self.collectionView.cellForItem(at: self.currentlyPlayingIndexPath) as? ReelsCC {
                
                if time == .zero || time == nil {
                    self.forceScrollandPlayVideo(time: time)
                }
                else if (time ?? .zero) >= (cell.player.currentDuration ?? .zero) {
                    let nextIndexPath = IndexPath(item: self.currentlyPlayingIndexPath.item + 1, section: 0)
                    if nextIndexPath.item < self.reelsArray.count {
                        
                        if self.isViewControllerVisible == false {
                            return
                        }
                        if self.isRightMenuLoaded {
                            return
                        }
                        
                        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelsDurationEvent, eventDescription: "", article_id: self.reelsArray[self.currentlyPlayingIndexPath.item].id ?? "", duration: cell.player.totalDuration.formatToMilliSeconds() ?? "")
                        
                        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelsFinishedPlaying, eventDescription: "", article_id: self.reelsArray[self.currentlyPlayingIndexPath.item].id ?? "")
                        
                        self.playNextCellVideo(indexPath: nextIndexPath)
                        
                    }
                }
                else {
                    self.forceScrollandPlayVideo(time: time)
                }
                
            }
            
        }
        
        
        
    }
    
    
    func forceScrollandPlayVideo(time: TimeInterval?) {
        
        self.resumeVideo(time: time)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            
            self.adjustCellScrollPostion()
        }
    }
    
}


extension ReelsVC: ChannelDetailsVCDelegate {
    
    func backButtonPressedChannelDetailsVC() { }
    
    func backButtonPressedWhenFromReels(_ channel: ChannelInfo?) {
        
        //print("backButtonPressedWhenFromReels", channel)
        if ReelsCacheManager.shared.reelViewedOnChannelPage {
            self.reelsArray.removeAll()
            self.collectionView.reloadData()
            nextPageData = ""
            self.performWSToGetReelsData(page: "", isRefreshRequired: true, contextID: SharedManager.shared.curReelsCategoryId)
        }
        if let cell = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            
            //Check source if its not available then use author
            if let _ = cell.reelModel?.source {
                
                cell.reelModel?.source = channel
                cell.imgUserPlus.isHidden = channel?.favorite ?? false
                
                
                self.reelsArray[currentlyPlayingIndexPath.item].source = channel
                
                for (indexPa,reelObj) in self.reelsArray.enumerated() {
                    
                    if reelObj.source?.id == channel?.id {
                        
                        self.reelsArray[indexPa].source = channel
                    }
                    
                }
                
//                DispatchQueue.main.sync {
                    
                    let cellsArray =  collectionView.visibleCells
                    
                    if cellsArray.count > 0 {
                        
                        for cellObj in cellsArray {
                            
                            if let reelscell = cellObj as? ReelsCC {
                                
                                if reelscell.reelModel?.source?.id == channel?.id {
                                    reelscell.reelModel?.source = channel
                                    reelscell.imgUserPlus.isHidden = channel?.favorite ?? false
                                }
                                
                            }
                            
                        }
                    }
                    
//                }
                
                
                
                
                
            }
            else {
                
                //author
                //imgUserPlus.isHidden = (reelModel?.authors?.first?.favorite ?? false)
            }

        }
    }
    
    func performWSToGetReelsCaptions(id: String) {
  
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let url = "news/reels/\(id)/captions"
       // let params = ["id":ID]
        
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { [weak self] (response) in
            do{
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
                                cell.setCaptionImage()
                                
                                cell.cellLayoutUpdate()
                            }
                            return
                        }
                        
                    }
                }
                else {
                    
                    // No captions
                    if let selectedIndex = self.reelsArray.firstIndex(where: { $0.id ?? "" == id }) {
                        self.reelsArray[selectedIndex].captionAPILoaded = true
                        if let cell = self.collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? ReelsCC {
                            cell.reelModel?.captionAPILoaded = true
                            cell.cellLayoutUpdate()
                        }
                    }
                    
                }
                
            } catch let jsonerror {
            
                print("error parsing json objects \(url) \n",jsonerror)
                guard let self = self else {
                    return
                }
                // No captions
                if let selectedIndex = self.reelsArray.firstIndex(where: { $0.id ?? "" == id }) {
                    self.reelsArray[selectedIndex].captionAPILoaded = true
                    if let cell = self.collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? ReelsCC {
                        cell.reelModel?.captionAPILoaded = true
                        cell.cellLayoutUpdate()
                    }
                }
                
            }
        }) { (error) in
            
            print("error parsing json objects",error)
            // No captions
            if let selectedIndex = self.reelsArray.firstIndex(where: { $0.id ?? "" == id }) {
                self.reelsArray[selectedIndex].captionAPILoaded = true
                if let cell = self.collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? ReelsCC {
                    cell.reelModel?.captionAPILoaded = true
                    cell.cellLayoutUpdate()
                }
            }
            
        }
    }
}
//
//extension ReelsVC: AlertViewNewDelegate {
//
//    func alertClosedbyUser() {
//        SharedManager.shared.isSavedPreferenceAlertRequired = false
//    }
//}


extension ReelsVC: BulletDetailsVCLikeDelegate {
    
    
    func likeUpdated(articleID: String, isLiked: Bool, count: Int) {
        
    }
    
    func commentUpdated(articleID: String, count: Int) {
        
    }
    
    func backButtonPressed(cell: HomeDetailCardCell?) {
        if SharedManager.shared.reloadRequiredFromTopics {
            setRefresh(scrollView: collectionView, manual: true)
            SharedManager.shared.reloadRequiredFromTopics = false
        }
        self.isViewControllerVisible = true
        if isOpenedLightMode {
            isOpenedLightMode = false
            MyThemes.switchTo(theme: .dark)
        }
//        if SharedManager.shared.isForYouTabReelsReload {
//            loadNewData()
//        }
//        else {
//            if SharedManager.shared.bulletsAutoPlay {
//                playCurrentCellVideo()
//            }
//        }
        if SharedManager.shared.bulletsAutoPlay {
            playCurrentCellVideo()
        }
        
        if let cellReel = collectionView.cellForItem(at: currentlyPlayingIndexPath) as? ReelsCC {
            
            //Check source if its not available then use author
            if let _ = cellReel.reelModel?.source, let channel = cell?.articleModel?.source {
                
                cellReel.reelModel?.source = channel
                cellReel.imgUserPlus.isHidden = channel.favorite ?? false
                
                
                self.reelsArray[currentlyPlayingIndexPath.item].source = channel
                
                for (indexPa,reelObj) in self.reelsArray.enumerated() {
                    
                    if reelObj.source?.id == channel.id {
                        
                        self.reelsArray[indexPa].source = channel
                    }
                    
                }
                
                
                let cellsArray =  collectionView.visibleCells
                
                if cellsArray.count > 0 {
                    
                    for cellObj in cellsArray {
                        
                        if let reelscell = cellObj as? ReelsCC {
                            
                            if reelscell.reelModel?.source?.id == channel.id {
                                reelscell.reelModel?.source = channel
                                reelscell.imgUserPlus.isHidden = channel.favorite ?? false
                            }
                            
                        }
                        
                    }
                }
            }
        }
        
    }
    
}


extension ReelsVC: NotificationsListVCDelegate {
    
    func backButtonPressed() {
        
        self.isViewControllerVisible = true
        self.playCurrentCellVideo()
        
    }
}

extension ReelsVC: ReelsCacheManagerDelegate {
    
    func cachingCompleted(reel: Reel, position: Int) {


        if position < self.reelsArray.count{
            self.reelsArray[position] = reel
        }

        DispatchQueue.main.async {
            if position == 10 {
                ANLoader.hide()
                self.stopIndicatorLoading()
                let indexPaths = Array(1...9).map { IndexPath(item: $0, section: 0) }
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
        startReelsCaching()
    }
    
    func startReelsCaching(){
        ReelsCacheManager.shared.delegate = self
        if currentCachePosition < cacheLimit && currentCachePosition < self.reelsArray.count {
            if self.reelsArray[currentCachePosition].iosType == nil {
                ReelsCacheManager.shared.begin(reelModel: reelsArray[currentCachePosition], position: currentCachePosition)
            }else{
                currentCachePosition += 1
                if currentCachePosition < self.reelsArray.count {
                    ReelsCacheManager.shared.begin(reelModel: reelsArray[currentCachePosition], position: currentCachePosition)
                }
            }
        }
    }
}
