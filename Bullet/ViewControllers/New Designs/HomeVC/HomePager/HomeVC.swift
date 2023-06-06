//
//  HomeVC.swift
//  Bullet
//
//  Created by Mahesh on 16/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SDWebImage
import LinkPresentation
import SwiftRater
import CoreHaptics
import GoogleMobileAds
import AVFoundation
import LoadingShimmer
import GoogleMobileAds
//import SkeletonView
import FBAudienceNetwork
import DataCache
import NicoProgress
import FBSDKShareKit
import Photos
import SwiftUI
import Alamofire



enum PrefetchState {
    case fetching
    case idle
}

protocol HomeVCScrollDelegate: AnyObject {
    func homeScrollViewDidScroll(delta: CGFloat)
}

protocol HomeVCDelegate: AnyObject {
    func backButtonPressed()
    func loaderShowing(status: Bool)
    func switchBackToForYou()
    func homeScrollViewDidScroll(delta: CGFloat, animated: Bool)
    
    func changeScreen(pageIndex: Int)
}


class HomeVC: UIViewController, UIGestureRecognizerDelegate {

    //PROPERTIES
    @IBOutlet weak var tblExtendedView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //    //No Saved Articles View
//    @IBOutlet weak var viewNoSavedBG: UIView!
//    @IBOutlet var lblNoSavedArticles: [UILabel]!
//    @IBOutlet weak var lblNoSavedTitle: UILabel!
//    @IBOutlet weak var lblNoSavedDes1: UILabel!
//    @IBOutlet weak var lblNoSavedDes2: UILabel!
//    @IBOutlet weak var lblNoSavedDes3: UILabel!
//    @IBOutlet weak var lblNoSavedDes4: UILabel!
//    @IBOutlet weak var lblNoSavedDes5: UILabel!
    
    //No Data View
    @IBOutlet weak var viewNoData: UIView!
    @IBOutlet weak var imgNoData: UIImageView!
    @IBOutlet weak var lblNoDataTitle: UILabel!
    @IBOutlet weak var lblNoDataDescription: UILabel!
    @IBOutlet weak var lblHome: UILabel!
    
    //Forcing select topic or channels
    @IBOutlet weak var imgEmptyFollow: UIImageView!
    @IBOutlet weak var viewEmptyMessage: UIView!
    @IBOutlet weak var lblEmptyMessage: UILabel!
    @IBOutlet weak var lblEmptyTitle: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
//    @IBOutlet weak var extendedViewBottomConstraint: NSLayoutConstraint!
    
    //view new posts
    @IBOutlet weak var viewNewPosts: UIView!
    @IBOutlet weak var lblNewPosts: UILabel!
    @IBOutlet weak var ctViewNewPostTop: NSLayoutConstraint!

    //View
    @IBOutlet weak var viewHeaderContainer: UIView!
    @IBOutlet weak var viewProgress: UIView!
    
    
    @IBOutlet weak var ctViewHeaderProgressHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    
    var currentIndexSub = 0
    var isShowCreatePost = false
    var tempCategoryId = ""
    //var tempForYouArr: [sectionsData]?
    var tempArticlesArr: [sectionsData]?
    
    var normalTableViewTopConstraint: CGFloat = 70
    var extendedTableViewTopConstraint: CGFloat = 0
    
    let headerProgressHeight: CGFloat = 60
    var selectedItems = [YPMediaItem]()
//    fileprivate var collectionViewContentOffsetX: CGFloat = 0.0
//    fileprivate var currentBarViewWidth: CGFloat = 0.0
//    fileprivate var currentBarViewLeftConstraint: NSLayoutConstraint?
    fileprivate var subFeedArr: [subFeedCategory]?
    fileprivate var cachedCellSizes: [IndexPath: CGSize] = [:]
//    fileprivate var cellForSize: SubTabCategoryCell?
//    fileprivate var option: TabPageOption = TabPageOption()
//    fileprivate var pageTabItemsWidth: CGFloat = 0.0
//    var layouted: Bool = false

    
    weak var scrollDelegate: HomeVCScrollDelegate?
    weak var delegateBulletDetails: BulletDetailsVCLikeDelegate?
    
    //VARIABLES
    var nextPaginate = ""
    var isPullToRefresh = false
    var articles: [articlesData] = []
    var generator = UIImpactFeedbackGenerator()
    var prefetchState: PrefetchState = .idle
    var cellHeights = [IndexPath: CGFloat]()

    //sharing variables
    var urlOfImageToShare: URL?
    var shareTitle = ""
    var authorBlock = false
    var sourceBlock = false
    var sourceFollow = false
    var article_archived = false
//    var stGreeting = ""
//    var isForYouPage = false

    //CELL INSTANCES
    var curVideoVisibleCell: VideoPlayerVieww?
    var curYoutubeVisibleCell: YoutubeCardCell?

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isFirstLoadView = true
    var isViewDidLoad = false

    var isViewPresenting: Bool = false
    var lastContentOffset: CGFloat = 0
    let refreshTimeNeeded: CGFloat = 2

    //PAGE VIEW CONTROLLER VARIABLE
    var isDataLoaded = false
    var pageIndex = 0
    var isDirectionFindingNeeded = false
    var isLikeApiRunning = false
    var focussedIndexPath = 0
    var forceSelectedIndexPath: IndexPath?
    var showArticleType: ArticleType = .home
    let pagingLoader = UIActivityIndicatorView()
    
    var adLoader: GADAdLoader? = nil
    var fbnNativeAd: FBNativeAd? = nil
    var googleNativeAd: GADUnifiedNativeAd?
    var imageWaterMark = ""
    
    var mediaWatermark = MediaWatermark()
    var DocController: UIDocumentInteractionController = UIDocumentInteractionController()
    @IBOutlet weak var indicator: InstagramActivityIndicator!
    @IBOutlet weak var viewIndicator: UIView!

    typealias CompletionHandler = (_ success: Bool) -> Void

    var showSkeletonLoader = false
    //deinit methods
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyMoveToCard, object: nil)
//        NotificationCenter.default.removeObserver(self)
//    }
    
    // View Model
    var homeViewModel : HomeViewModel!
    
    var currentPageIndex = 0
    var isOnFollowing = false
    weak var delegate: HomeVCDelegate?
    var placeContextId = ""
    var topicContextId = ""
    var subTopicTitle = ""
    var selectedID = ""
    var isOpenFromCustomBulletDetails = false
    var isFav = true
    var isFollowBtnNeeded = false
    
    var isOpenedFollowingPrefernce = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Force light mode
        MyThemes.switchTo(theme: .light)
        
        self.getAPIResponseCallbacks()
        
        ANLoader.hide()
        
        //SET LOCALIZABLE
        setLocalizableString()
        
        //Design View
        setDesignView()
        
        //Cell Register
        setRegisterCell()
        
        tblExtendedView.alwaysBounceVertical = true
        //Pull to refresh for View
        tblExtendedView.es.addPullToRefresh { [weak self] in
            self?.pullToRefreshAction()
        }
        self.tblExtendedView.tableHeaderView?.frame = .zero
        self.tblExtendedView.tableHeaderView?.isHidden = true

        self.isFirstLoadView = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            
            SwiftRater.check(host: self)
//            if SwiftRater.isRateDone == false {
//                SwiftRater.rateApp(host: self)
//            }
//            else {
//                SwiftRater.check(host: self)
//            }
            
            if SharedManager.shared.userAlert != nil {
                
                SharedManager.shared.isPauseAudio = true
                NotificationCenter.default.post(name: Notification.Name.notifyAudioAndProgressBarStatus, object: nil)
                let vc = WhatsNewVC.instantiate(fromAppStoryboard: .registration)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        UserDefaults.standard.removeSuite(named: "group.app.newsreels")
        UserDefaults.standard.removeSuite(named: "accessToken")
        UserDefaults.standard.removePersistentDomain(forName: "group.app.newsreels")
        UserDefaults.standard.synchronize()
        
        let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
        if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
            userDefaults.set(userToken as AnyObject, forKey: "accessToken")
            userDefaults.synchronize()
        }
                
        if let arrCache = self.readCache(key: getCategoryId()), arrCache.count > 0 {
//            SharedManager.shared.hideLaoderFromWindow()
            self.getRefreshArticlesData(startFromFirstPosition: true)
        }
        else {
//            if SharedManager.shared.isFirstimeSplashScreenLoaded == false {
//                SharedManager.shared.isFirstimeSplashScreenLoaded = true
//                if self.showArticleType != .topic && self.showArticleType != .places {
//                    SharedManager.shared.showLoaderInWindow()
//                }
//                perform(#selector(autohideloader), with: nil, afterDelay: 5)
//            }
            loadNewData()
        }
          
        NotificationCenter.default.addObserver(self, selector: #selector(refetchArticles), name: .didChangeReelsTopics, object: nil)
    }
    
    
//    override func viewDidLayoutSubviews()
    
    override func viewWillAppear(_ animated: Bool) {
        
        _ = try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
        _ = try? AVAudioSession.sharedInstance().setActive(true)
        
        
        isViewPresenting = true
        
//        addNSNotifications()
        setTopBarInitialLoad()
        showBottomTabWhenTopVisible()
        self.setupForCallMethod()
//        showLoader()
        
        setStatusBar()
    }
    
    @objc func refetchArticles() {
        self.getRefreshArticlesData(startFromFirstPosition: true)
    }
    
    func setupForCallMethod() {
        
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(playerInterruption),name: AVAudioSession.interruptionNotification,object: AVAudioSession.sharedInstance())
    }
    
    
    
    func loadNewData() {
        
        DataCache.instance.clean(byKey: getCategoryId())
        updateProgressbarStatus(isPause: true)
        self.focussedIndexPath = 0
        self.tblExtendedView.setContentOffset(.zero, animated: false)
        articles.removeAll()
        nextPaginate = ""
       
        self.showLoader()
        
        self.getRefreshArticlesData(startFromFirstPosition: true)
        
        
        SharedManager.shared.isTabReload = false
    }
    
    
    func setStatusBar() {
        var navVC = (self.navigationController?.navigationController as? AppNavigationController)
        if navVC == nil {
            navVC = (self.navigationController as? AppNavigationController)
        }
        if navVC?.showDarkStatusBar == false {
            navVC?.showDarkStatusBar = true
            navVC?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    
    @objc func orientationChange() {
     
        
        if MediaManager.sharedInstance.isFullScreenButtonPressed {
            return
        }
        
        if isViewPresenting == false {
            return
        }
        
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight  {
            print("orientation landscape")
        } else if UIDevice.current.orientation == .portrait {
            print("orientation portrait")
        } else {
            print("orientation other")
        }
        
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            
            if articles.count == 0 || focussedIndexPath == -1 || focussedIndexPath >= articles.count {
                return
            }
            
            let currentFocusedIndex = IndexPath(row: focussedIndexPath, section: 0)
            let content = self.articles[currentFocusedIndex.row]
            if (tblExtendedView.cellForRow(at: currentFocusedIndex) as? VideoPlayerVieww) != nil {
                
                guard let url = URL(string: content.link ?? "") else { return }
                
                if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == currentFocusedIndex, player.contentURL == url {
                    if player.isPlaying && player.displayMode == .embedded {
                        
                        (UIApplication.shared.delegate as! AppDelegate).orientationLock = [.landscapeLeft, .landscapeRight,.portrait]
                        
                        MediaManager.sharedInstance.isFullScreenButtonPressed = true
                        
                        MediaManager.sharedInstance.player?.fullScreenMode = .landscape
                        MediaManager.sharedInstance.player?.toFull()
                        
                    }
                   return
                }
            }
            
            if (tblExtendedView.cellForRow(at: currentFocusedIndex) as? HomeHeroCC) != nil {
                if content.subType == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                    
                    guard let url = URL(string: content.link ?? "") else { return }
                    
                    if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == currentFocusedIndex, player.contentURL == url {
                        if player.isPlaying && player.displayMode == .embedded {
                            
                            (UIApplication.shared.delegate as! AppDelegate).orientationLock = [.landscapeLeft, .landscapeRight,.portrait]
                            
                            MediaManager.sharedInstance.isFullScreenButtonPressed = true
                            
                            MediaManager.sharedInstance.player?.fullScreenMode = .landscape
                            MediaManager.sharedInstance.player?.toFull()
                            
                        }
                       return
                    }
                    
                    
                }
            }
            
        }
    }
    
    
    
    @objc func playerInterruption(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        if type == .began {
            
            print("Call-- began")
            self.updateProgressbarStatus(isPause: true)
            
        } else {
            
            print("Call-- end")
            self.updateProgressbarStatus(isPause: true)
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        
        setStatusBar()
        //addNSNotifications()
        if MediaManager.sharedInstance.isFullScreenButtonPressed {
            return
        }
        SharedManager.shared.isFirstimeSplashScreenLoaded = true

        if isFirstLoadView {
            
            //load sub category
//            option.tabHeight = 40
//            option.tabMargin = 8

            if self.showArticleType != .places {
                
                if self.showArticleType == .topic {
                    /*
                    if SharedManager.shared.subTopicsList.count > 0 {
                        setCollectionSubCategory()
                    }
                    else {
                        ctContentClvViewHeight.constant = 0
                        contentClvView.isHidden = true
                    }*/
                }
                else {
                    /*
                    if self.pageIndex < SharedManager.shared.headlinesList.count {
                        
                        if let sub = SharedManager.shared.headlinesList[self.pageIndex].sub, sub.count > 0 {
                            
                            subFeedArr = sub
                            setCollectionSubCategory()
                        }
                        else {
                            
                            ctContentClvViewHeight.constant = 0
                            contentClvView.isHidden = true
                        }
                    }*/
                }
            }
            
            //Data always load from first position
            if let arrCache = self.readCache(key: getCategoryId()), arrCache.count > 0 {
                //self.focussedIndexPath = -1
                //self.scrollToTopVisibleExtended()
            }
            else {
//                self.getRefreshArticlesData(startFromFirstPosition: true)
                loadNewData()
            }
        }
        
        if !isFirstLoadView {
            
//            btnPlus.isHidden = true
//            imgPlus.isHidden = true
//            viewHeaderContainer.isHidden = true
//            tblExtendedView.tableHeaderView?.frame = .zero

            if !isDataLoaded {
                
                if SharedManager.shared.subSourcesList.count > 0 {

                    //Data always load from first position
                    self.refreshListAndExtendedViewFromStartPosition(true)
                }
                else {
                    self.getRefreshArticlesData(startFromFirstPosition: true)
                }
            }
            else {
            
                if SharedManager.shared.isTabReload {
                    loadNewData()
                }
                else {
//                    self.refreshListAndExtendedViewFromStartPosition(true)
                    updateProgressbarStatus(isPause: false)
                }
                
                updateProgressbarStatus(isPause: false)
            }
        }
        
        self.isFirstLoadView = false

        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
            fetchAds()
        }
                     
        // Video Player callbacks
        MediaManager.sharedInstance.playerDidPlayToEndCallBack = { [self] in
            
            if let vc = MediaManager.sharedInstance.currentVC, vc != self  {
                return
            }
            
            if let cell =  getCurrentFocussedCell() as? VideoPlayerVieww {
                
                if MediaManager.sharedInstance.isFullScreenButtonPressed == false {
                    MediaManager.sharedInstance.releasePlayer()
                }
                cell.playButton.isHidden = false
                cell.viewDuration.isHidden = false
                cell.imgPlayButton.isHidden = false
                
            }
            else if let cell =  getCurrentFocussedCell() as? HomeHeroCC {
                
                if MediaManager.sharedInstance.isFullScreenButtonPressed == false {
                    MediaManager.sharedInstance.releasePlayer()
                }
                //cell.animationSourceShowHide(isShow: false)
                cell.playButton.isHidden = false
                cell.viewDuration.isHidden = false
                cell.imgPlayButton.isHidden = false
            }
            
        }
        
        MediaManager.sharedInstance.playerDidChangeDisplayModeCallBack = { [self] in
            
            if let vc = MediaManager.sharedInstance.currentVC, vc != self  {
                return
            }
            
            if MediaManager.sharedInstance.player?.displayMode == .embedded && (MediaManager.sharedInstance.player?.currentTime ?? .zero >= MediaManager.sharedInstance.player?.duration ?? .zero) {
                if let cell =  getCurrentFocussedCell() as? VideoPlayerVieww {
                    
                    MediaManager.sharedInstance.releasePlayer()
                    cell.playButton.isHidden = false
                    cell.viewDuration.isHidden = false
                    cell.imgPlayButton.isHidden = false
                    
                }
                else if let cell =  getCurrentFocussedCell() as? HomeHeroCC {
                    
                    MediaManager.sharedInstance.releasePlayer()
                    //cell.animationSourceShowHide(isShow: false)
                    cell.playButton.isHidden = false
                    cell.viewDuration.isHidden = false
                    cell.imgPlayButton.isHidden = false
                }
            }
            
        }
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        forceRemoveLoader()
        
        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.viewIndicator.isHidden = true
        }
        
        print("page disappeared")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        isViewPresenting = false
//        NotificationCenter.default.removeObserver(self)
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyAppFromBackground, object: nil)
//        NotificationCenter.default.removeObserver(SharedManager.shared.observerArray)
        
        self.resetCurrentFocussedCell()
    }
    
    func setRegisterCell() {
        
        tblExtendedView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)

        //register cardcell for storyboard use
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_HOME_LISTVIEW, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_HOME_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_CARD)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_ADS_LIST, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_ADS_LIST)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_YOUTUBE_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_YOUTUBE_CARD)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_VIDEO_PLAYER, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_HOME_HERO, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_HERO)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_HOME_HEADLINE_CLV, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_HEADLINE_CLV)
        tblExtendedView.register(UINib(nibName: "sugClvReelsCC", bundle: nil), forCellReuseIdentifier: "sugClvReelsCC")
        tblExtendedView.register(UINib(nibName: "HomeReelCarouselCC", bundle: nil), forCellReuseIdentifier: "HomeReelCarouselCC")
        tblExtendedView.register(UINib(nibName: "HomeVideoCarouselCC", bundle: nil), forCellReuseIdentifier: "HomeVideoCarouselCC")

//        tblExtendedView.register(UINib(nibName: "sugClvAuthorsCC", bundle: nil), forCellReuseIdentifier: "sugClvAuthorsCC")
        tblExtendedView.register(UINib(nibName: "sugClvChannelsCC", bundle: nil), forCellReuseIdentifier: "sugClvChannelsCC")
        tblExtendedView.register(UINib(nibName: "sugClvTopicsCC", bundle: nil), forCellReuseIdentifier: "sugClvTopicsCC")
        tblExtendedView.register(UINib(nibName: "SuggestedCC", bundle: nil), forCellReuseIdentifier: "SuggestedCC")
        
//        self.tblExtendedView.rowHeight = UITableView.automaticDimension
//        self.tblExtendedView.estimatedRowHeight = 700
        
        //HEADER---FOOTER
        tblExtendedView.register(UINib(nibName: HEADER_HOME_CC, bundle: nil), forCellReuseIdentifier: HEADER_HOME_CC)
        tblExtendedView.register(UINib(nibName: FOOTER_HOME_CC, bundle: nil), forCellReuseIdentifier: FOOTER_HOME_CC)
        
        tblExtendedView.register(UINib(nibName: "HomeSkeltonCardCell", bundle: nil), forCellReuseIdentifier: "HomeSkeltonCardCell")
        tblExtendedView.register(UINib(nibName: "HomeSkeltonListCell", bundle: nil), forCellReuseIdentifier: "HomeSkeltonListCell")
    }

    func didTapNotifications() {
        
        let vc = NotificationsListVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
        
    }
    
    func didTapFilter() {
        
//        self.updateProgressbarStatus(isPause: true)
//        isViewPresenting = false
//        
//        let vc = ForYouPreferencesVC.instantiate(fromAppStoryboard: .Reels)
//        vc.delegate = self
//        vc.currentSelection = "isOnFollowing ? 1 : 0"
//        let nav = AppNavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        self.present(nav, animated: true, completion: nil)
//        
        
    }
    
    func openFollowingPrefernce() {
        
//        self.updateProgressbarStatus(isPause: true)
//        isViewPresenting = false
//
//        let vc = FollowingPreferenceVC.instantiate(fromAppStoryboard: .Reels)
//        vc.delegate = self
//        vc.hasReels = false
//        let nav = AppNavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//
//        isOpenedFollowingPrefernce = true
//        self.present(nav, animated: true, completion: nil)
//
    }
    
    
    func isProgressNeeded()-> Bool {
        
        // Check any upload running
        /*
        if UploadManager.shared.arrayUploads.filter({ $0.task_status == .uploading }).count > 0 {
            
            return true
        }
        if UploadManager.shared.arrayUploads.filter({ $0.task_status == .cropping}).count > 0 {
            
            return true
        }
        
        return false
        */
        
        return true
    }
    
    func loadDataForShowSkeleton() {
        
        if showSkeletonLoader {
            self.getRefreshArticlesData(startFromFirstPosition: true)
        }
    }
    
    func fetchAds() {
        
        if SharedManager.shared.adType.uppercased() == "FACEBOOK" {
            if fbnNativeAd == nil {
                fbnNativeAd = FBNativeAd(placementID: SharedManager.shared.adUnitFeedID)
                fbnNativeAd?.delegate = self
                #if DEBUG
                FBAdSettings.testAdType = .img_16_9_App_Install
                #else
                #endif
                
                fbnNativeAd?.loadAd()
                print("ad requested")
            }
        } else {
            
            if adLoader == nil {
                adLoader = GADAdLoader(adUnitID: SharedManager.shared.adUnitFeedID, rootViewController: self,
                                       adTypes: [ .unifiedNative ], options: nil)
                adLoader?.delegate = self
                adLoader?.load(GADRequest())
            }
        }
        
         //Move to a background thread to do some long running work
//        DispatchQueue.global(qos: .userInitiated).async {
//
//            let request = GADRequest()
//            // Bounce back to the main thread to update the UI
//            DispatchQueue.main.async {
//                self.adLoader.load(request)
//            }
//        }
    }
    
    
    func addNSNotifications() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyToRemoveVCObservers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapRemoveObserver(_:)), name: Notification.Name.notifyToRemoveVCObservers, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyPauseAudio, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapOpenEdition(_:)), name: Notification.Name.notifyPauseAudio, object: nil)
                        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyAppFromBackground, object: nil)
//        NotificationCenter.default.removeObserver(SharedManager.shared.observerArray)
//        SharedManager.shared.observerArray = NotificationCenter.default.addObserver(forName: Notification.Name.notifyAppFromBackground, object: nil, queue: nil) { notification in
//
//            self.notifyAppBackgroundEvent()
//        }
        NotificationCenter.default.addObserver(forName: Notification.Name.notifyAppFromBackground, object: nil, queue: nil) { [weak self] notification in
            
            self?.notifyAppBackgroundEvent()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifyCallRecievedInApp), name: Notification.Name.notifyCallDuringAppUse, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapOnTabBarTwice(_:)), name: Notification.Name.notifyTabbarTapEvent, object: nil)
        
        SharedManager.shared.bulletPlayer?.stop()
        SharedManager.shared.bulletPlayer?.currentTime = 0
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyHomeVolumn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapVolume), name: Notification.Name.notifyHomeVolumn, object: nil)
        
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyVideoVolumeStatus, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapUpdateVideoVolumeStatus(notification:)), name: Notification.Name.notifyVideoVolumeStatus, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(self.didTapUpdateVideoVolumeStatus(notification:)), name: Notification.Name.notifyVideoVolumeStatus, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(orientationChange), name: Notification.Name.notifyOrientationChange, object: nil)
//
//        NotificationCenter.default.addObserver(forName: .EZPlayerStatusDidChange, object: nil, queue: nil) { [weak self] notification in
//            self?.videoPlayerStatus(notification)
//        }
            
    }
    
    func pageViewControllerViewWillAppear() {
        
        if SharedManager.shared.textSizeChanged {
            DispatchQueue.main.async {
                self.tblExtendedView.reloadData()
            }
            SharedManager.shared.textSizeChanged = false
        }
        
        isViewPresenting = true
        SharedManager.shared.isShowBulletDetails = false

//        if self.tableViewTopConstraint.constant == self.normalTableViewTopConstraint {
//            if let ptcTBC = tabBarController as? PTCardTabBarController {
//                ptcTBC.showTabBar(true, animated: true)
//            }
//        }
        
//        showTopAndBottomBar()
        /*
        if MediaManager.sharedInstance.isFullScreenButtonPressed == false {
            self.refreshListAndExtendedViewFromStartPosition(false)
        }
        */
        
        showTopAndBottomBar(animated: true)
        
        setStatusBar()
        
    }
    
    func pageViewControllerViewWillDisappear() {
        
        isViewPresenting = false
//        if let ptcTBC = tabBarController as? PTCardTabBarController {
//            ptcTBC.showTabBar(false, animated: true)
//        }
        updateProgressbarStatus(isPause: true)
        
        NotificationCenter.default.removeObserver(self)
    }
        
    func setTopBarInitialLoad() {
        
        if self.showArticleType == .places || self.showArticleType == .topic || SharedManager.shared.isAppLaunchedThroughNotification {
            
//            self.tableViewTopConstraint.constant = self.extendedTableViewTopConstraint
//            self.hideTopAndBottomBar()
        }
        else {
            
//            if SharedManager.shared.isTopTabBarCurrentlHidden {
//                hideTopAndBottomBar()
//            } else {
//                showTopAndBottomBar()
//            }
        
            showTopAndBottomBar(animated: false)
        }
    }
    
    @objc func didTapRemoveObserver(_ notification: NSNotification) {
        
        if self.readCache(key: getCategoryId()) == nil {
            SharedManager.shared.clearProgressBar()
        }
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyAppFromBackground, object: nil)
//        NotificationCenter.default.removeObserver(SharedManager.shared.observerArray)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyVideoVolumeStatus, object: nil)
    }

    //Set String for Language Translation and Put it in String Files
    func setLocalizableString() {
        
        //LOCALIZABLE STRING
//        lblNoSavedTitle.text = NSLocalizedString("No saved stories yet", comment: "")
//        lblNoSavedDes1.text = NSLocalizedString("Tap the", comment: "") + " ( "
//        lblNoSavedDes2.text = " ) " + NSLocalizedString("icon on the article", comment: "")
//        lblNoSavedDes3.text = NSLocalizedString("you want to read later then", comment: "")
//        lblNoSavedDes4.text = NSLocalizedString("Select", comment: "") + " ( "
//        lblNoSavedDes5.text = " ) " + NSLocalizedString("to save article.", comment: "")
        
        lblEmptyMessage.text = NSLocalizedString("You are not following anything yet", comment: "")
        lblEmptyTitle.text = NSLocalizedString("START FOLLOWING", comment: "")

        lblNoDataTitle.text = NSLocalizedString("There is nothing in here", comment: "")
        lblNoDataDescription.text = NSLocalizedString("Looks like there is nothing here but a cat.", comment: "") + "\n" + NSLocalizedString("Would you like to go back to home?", comment: "")
        lblHome.text = NSLocalizedString("GO HOME", comment: "")
        
//        lblForcingTitle.text = NSLocalizedString("Personalize your reading experience", comment: "")
//        lblForcingSubTitle.text = NSLocalizedString("Start following the news topics and channels you want to read.", comment: "")
//        lblForcingGetStart.text = NSLocalizedString("LET'S GO", comment: "")
        lblNewPosts.text = NSLocalizedString("New Posts", comment: "")
    }
    
    func setDesignView() {
        
        viewNewPosts.isHidden = true
        //        view.theme_backgroundColor = GlobalPicker.customTabbarBGColor
//        view.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        view.backgroundColor = Constant.appColor.backgroundGray
        tblExtendedView.backgroundColor = Constant.appColor.backgroundGray
        
//        view.backgroundColor = "#F2F2F2".hexStringToUIColor()
//        self.viewNoSavedBG.isHidden = true
//        self.lblNoSavedArticles.forEach {
//            $0.theme_textColor = GlobalPicker.textColor
//        }
        self.activityIndicator.stopAnimating()
        viewProgress.backgroundColor = .clear
//        viewHeaderContainer.theme_backgroundColor = GlobalPicker.backgroundShadow
//        viewHeaderContainer.addBottomShadowForDiscoverPage()

        viewEmptyMessage.isHidden = true
        imgEmptyFollow.theme_image = GlobalPicker.imgErrorFollow
        btnContinue.theme_backgroundColor = GlobalPicker.themeCommonColor
        lblEmptyTitle.addTextSpacing(spacing: 2.0)

        viewNoData.isHidden = true
        imgNoData.theme_image = GlobalPicker.imgNoData
        lblNoDataTitle.theme_textColor = GlobalPicker.textColor
        lblNoDataDescription.theme_textColor = GlobalPicker.textColor
        lblNoDataDescription.setLineSpacing(lineSpacing: 5)
        lblNoDataDescription.textAlignment = .center
        lblHome.theme_textColor = GlobalPicker.textColor
        lblHome.layer.cornerRadius = lblHome.bounds.height / 2
        lblHome.layer.borderWidth = 2.5
        lblHome.layer.borderColor = Constant.appColor.purple.cgColor
        lblHome.addTextSpacing(spacing: 2.5)
        lblHome.isHidden = true
        
//        self.lblForcingTitle.theme_textColor = GlobalPicker.textColor
//        self.lblForcingTitle.setLineSpacing(lineSpacing: 5)
//        self.lblForcingSubTitle.theme_textColor = GlobalPicker.textColor
//        self.lblForcingSubTitle.setLineSpacing(lineSpacing: 5)
//        self.lblForcingGetStart.layer.cornerRadius = lblForcingGetStart.bounds.height / 2
//        self.lblForcingGetStart.clipsToBounds = true
//        self.lblForcingGetStart.theme_backgroundColor = GlobalPicker.btnSelectedTabbarTintColor
//        self.lblForcingTitle.textAlignment = .center
//        self.lblForcingSubTitle.textAlignment = .center
        
        
        indicator.animationDuration = 1.0
        indicator.rotationDuration = 3
        indicator.numSegments = 15
        indicator.strokeColor = "#E01335".hexStringToUIColor()
        indicator.lineWidth = 3

    }
    
    func showLoader() {
        
        
        DispatchQueue.main.async { [self] in
            
            
//            let animation = GradientDirection.leftRight.slidingAnimation()
//                //        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftToRight)
//            self.tblExtendedView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient.init(baseColor: MyThemes.current == .light ? GlobalPicker.skeletonColorLightMode : GlobalPicker.skeletonColorDarkMode), animation: animation, transition: .crossDissolve(0.25))
//            self.tblExtendedView.showSkeleton()
            
            
            self.delegate?.loaderShowing(status: true)
            self.showSkeletonLoader = true
            self.tblExtendedView.reloadData()
        }
//        DispatchQueue.main.async {
//
//            if self.viewLoader == nil {
//                self.viewLoader = HomeSkeletonView(frame: self.view.bounds)
//                self.viewLoader?.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
//                self.viewLoader?.isHidden = false
//                self.viewLoader?.alpha = 1
//                self.viewLoader?.showSkeletonLoader()
//
//
//                self.view.addSubview(self.viewLoader!)
//
//                self.view?.bringSubviewToFront(self.viewLoader!)
//            }
//        }
    }
    
    
    func forceRemoveLoader() {
        
//        view.layer.removeAllAnimations()
//        viewLoader?.layer.removeAllAnimations()
//        if self.viewLoader != nil {
//            self.viewLoader?.alpha = 0
//            self.viewLoader?.hideSkeletonLoader()
//            self.viewLoader?.isHidden = true
//
//            self.viewLoader?.removeFromSuperview()
//            self.viewLoader = nil
//        }
    }
    
    
    func refreshListAndExtendedViewFromStartPosition(_ isStartFromFirstPosition: Bool) {
        
        //Data always load from first position
        if isStartFromFirstPosition {
            
            self.getRefreshArticlesData(startFromFirstPosition: true)
        }
        else {
            
            print("tblExtendedView.reloadData 1")
            if tblExtendedView.numberOfRows(inSection: 0) == self.articles.count, self.articles.count > 0 {
                UIView.setAnimationsEnabled(false)
                tblExtendedView.beginUpdates()
                tblExtendedView.reloadData()
                tblExtendedView.endUpdates()
                UIView.setAnimationsEnabled(true)
                
                //tell us if first article youtube then will force to call scrollToTopVisibleExtended for play article
                if focussedIndexPath >= 0 {
                    if let type = self.articles[focussedIndexPath].type, (type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE || type == Constant.newsArticle.ARTICLE_TYPE_VIDEO || type == Constant.newsArticle.FEED_ARTICLE_HERO || type == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL || type == Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS) {
                        self.scrollToTopVisibleExtended()
                    }
                }
            }
            self.isDirectionFindingNeeded = false
        }
    }
    
    @objc func didTapUpdateVideoVolumeStatus( notification: Notification) {
        
        guard let status = notification.userInfo?["isPause"] as? Bool else { return }
        updateProgressbarStatus(isPause: status)
    }
    
    @objc func didTapVolume() {
        
        // we checking the current articels of bullets
        if SharedManager.shared.isAudioEnable {
            
            if articles.count == 0 { return }
            
            if focussedIndexPath > 0 {
                SharedManager.shared.articleOnVolume = articles[focussedIndexPath]
            }
        }
        
        if isViewPresenting == false {
            return
        }
        let index = self.getIndexPathForSelectedArticleCardAndListView()
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeCardCell {
            cell.updateCardVloumeStatus()
        }
        else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeListViewCC {
            cell.updateListViewVolumeStatus()
        }

    }
    
    func reloadDataFromBG() {
        isPullToRefresh = true
        viewNewPosts.isHidden = true
        SharedManager.shared.showLoaderInWindow()
        perform(#selector(autohideloader), with: nil, afterDelay: 5)
        self.getRefreshArticlesData(startFromFirstPosition: true)
    }

    //Action for pull to refresh
    func pullToRefreshAction(isBackground: Bool = false) {
        
        if isBackground {
            SharedManager.shared.showLoaderInWindow()
            perform(#selector(autohideloader), with: nil, afterDelay: 5)
        }
        
        // stop all api requests
        AF.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
        
        isPullToRefresh = true
        viewNewPosts.isHidden = true
        //updateTableViewUserInteractionEnabled(false)
        self.getRefreshArticlesData(startFromFirstPosition: true)
    }
    
//    func updateTableViewUserInteractionEnabled(_ userInteractionEnabled: Bool) {
//        tblExtendedView.isUserInteractionEnabled = userInteractionEnabled
//    }
    
    func onTabSelected(isTheSame: Bool) {
        
        if isTheSame {
            
            self.updateProgressbarStatus(isPause: true)
            if tblExtendedView.contentOffset != .zero {
                
                focussedIndexPath = 1
                tblExtendedView.scrollToRow(at: IndexPath(row: focussedIndexPath, section: 0), at: .top, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.tblExtendedView.setContentOffset(.zero, animated: true)
                }
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.tblExtendedView.es.autoPullToRefresh()
                }
            }
            
            /*
            if SharedManager.shared.curCategoryId != SharedManager.shared.headlinesList.first?.id ?? "" {
            //if !SharedManager.shared.curCategoryId.isEmpty {
                SharedManager.shared.curCategoryId = SharedManager.shared.headlinesList.first?.id ?? ""
                NotificationCenter.default.post(name: Notification.Name.notifyTapSubcategories, object: nil)
            }
            else {
                
                if tblExtendedView.contentOffset != .zero {
                    
                    focussedIndexPath = 1
                    tblExtendedView.scrollToRow(at: IndexPath(row: focussedIndexPath, section: 0), at: .top, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.tblExtendedView.setContentOffset(.zero, animated: true)
                    }
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.tblExtendedView.es.autoPullToRefresh()
                    }
                }
            }*/
        }
    }
    
    @objc func didTapOpenEdition(_ notification: NSNotification) {
        
        self.updateProgressbarStatus(isPause: true)
    }
    
    @objc func notifyAppBackgroundEvent() {
        
        //do stuff using the userInfo property of the notification object
        if SharedManager.shared.tabBarIndex != 1 {
            return
        }
        
        if articles.count == 0 { return }
                
        //SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.screenViewExpanded, eventDescription: "")
        var index = 0
        index = focussedIndexPath

        //reset current visible cell of Card List which is same index of list view
        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
            cell.clvBullets.isHidden = true
            cell.resetVisibleCard()
        }
        
        if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
            cell.clvBullets.isHidden = true
            cell.resetVisibleListCell()
        }
        
        //Reset Video Player
        MediaManager.sharedInstance.releasePlayer()
        if let _ = self.getCurrentFocussedCell() as? VideoPlayerVieww {
            self.resetOldPlayer(oldFocus: IndexPath(row: focussedIndexPath, section: 0))
        }
        
        if let _ = self.getCurrentFocussedCell() as? HomeHeroCC {
            
            let subType = self.articles[focussedIndexPath].subType ?? ""
            if subType.uppercased() == Constant.newsArticle.ARTICLE_TYPE_VIDEO {

                self.resetOldPlayer(oldFocus: IndexPath(row: focussedIndexPath, section: 0))
            }
        }
                
        tblExtendedView.isHidden = false
        print("tblExtendedView.reloadData 3")

        DispatchQueue.main.async {

            let indexPath = IndexPath(row: index, section: 0)
            if let visibleRows = self.tblExtendedView.indexPathsForVisibleRows, visibleRows.contains(indexPath) {
                
                UIView.setAnimationsEnabled(false)
                self.tblExtendedView.beginUpdates()
                self.tblExtendedView.reloadRows(at: [indexPath], with: .none)
                self.tblExtendedView.endUpdates()
                UIView.setAnimationsEnabled(true)
            } else {
    //            print("crash handled")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                
                if SharedManager.shared.tabBarIndex == 1 && self.isViewPresenting {
                    // Play currently focused video if any
                    if SharedManager.shared.videoAutoPlay {
                        if let cell = self.getCurrentFocussedCell() as? VideoPlayerVieww {
                            self.didTapVideoPlayButton(cell: cell, isTappedFromCell: false)
                        }
                        else if let cell = self.getCurrentFocussedCell() as? HomeHeroCC {
                            self.didTapHeroVideoPlayButton(cell: cell)
                        }
                    }
                }
            }

        }
        
       
        
        
    }
    
    @objc func notifyCallRecievedInApp() {
        
        if SharedManager.shared.bulletPlayer?.isPlaying ?? false {
            
            print("print 2...")
            SharedManager.shared.bulletPlayer?.pause()
            SharedManager.shared.bulletPlayer?.stop()
            //print("Volume 8")
            
        }
    }
    
    //MARK:- BUTTON ACTION
    
    @IBAction private func didTapNewPostsAction(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            
            self.viewNewPosts.isHidden = true

        }, completion: {_ in
            
            self.updateProgressbarStatus(isPause: true)
            //self.tblExtendedView.contentOffset = .zero
            
            self.isDirectionFindingNeeded = true
            self.tblExtendedView.setContentOffset(.zero, animated: false)
            self.tblExtendedView.reloadData()
            self.tblExtendedView.layoutIfNeeded()
            self.tblExtendedView.setContentOffset(.zero, animated: false)

//            if self.isForYouPage {
//
//                //self.srollToTop(isForYou: true)
//                self.focussedIndexPath = 1
//
//                if let arr = self.tempForYouArr, arr.count > 0 {
//
//                    self.articles.removeAll()
//                    self.loadDataInForYouList(arr, id: self.tempCategoryId)
//                    self.tempCategoryId = ""
//                    self.tempForYouArr = nil
//                }
//            }
//            else {
                
                self.focussedIndexPath = 0
                
                if let arr = self.tempArticlesArr, arr.count > 0 {
                    
                    self.articles.removeAll()
                    self.loadDataInFeedList(arr, id: self.tempCategoryId, isNewPost: true)

                    self.tempCategoryId = ""
                    self.tempArticlesArr = nil
                }
                
                DispatchQueue.main.async {
                    self.showTopAndBottomBar(animated: true)
                }
//            }
        })
    }
    
    private func srollToTop(isForYou: Bool) {
        
        self.isDirectionFindingNeeded = true
        self.tblExtendedView.setContentOffset(.zero, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            
            if self.tblExtendedView.contentOffset.y != 0 {
                self.srollToTop(isForYou: isForYou)
            } else {
                self.tblExtendedView.setContentOffset(.zero, animated: true)
                
                self.showTopAndBottomBar(animated: true)
                
                if let _ =  self.tblExtendedView.indexPathsForVisibleRows {
                    self.focussedIndexPath = isForYou ? 1 : 0
                    self.tblExtendedView.reloadRows(at: [IndexPath(row: self.focussedIndexPath, section: 0)], with: .none)
                }
            }
        }
    }
    
    @IBAction func didTapGetStarted(_ sender: Any) {
        
        SharedManager.shared.tabBarIndex = TabbarType.Search.rawValue
        SharedManager.shared.subTabBarType = .none
        SharedManager.shared.isTabReload = true
        SharedManager.shared.isDiscoverTabReload = true
        
        SharedManager.shared.bulletPlayer?.stop()
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.customTabBar.select(at: TabbarType.Search.rawValue)
        }
//        NotificationCenter.default.post(name: Notification.Name.notifyManageLocation, object: nil)
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.customTabBar.select(at: TabbarType.Search.rawValue)
        }
    }
    
    @IBAction func didTapStartFollowing(_ sender: UIButton) {
        
        //FollowingVC
        let vc = FollowingVC.instantiate(fromAppStoryboard: .Channel)
        //vc.delegate = self
        vc.isOpenFromFeed = true
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func didTapGoHomeAction(_ sender: UIButton) {
                
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyTapSubcategories, object: nil)
        NotificationCenter.default.removeObserver(Notification.Name.notifyTapSubcategories)
        
//        SharedManager.shared.curCategoryId = SharedManager.shared.headlinesList.first?.id ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.appDelegate.setHomeVC(false)
        })
    }

}

//MARK:- Webservices -  Private func
extension HomeVC {
    
    private func getRefreshArticlesData(startFromFirstPosition: Bool = false) {
        
        if startFromFirstPosition {
            if !isPullToRefresh {
                tblExtendedView.setContentOffset(.zero, animated: false)
            }
            focussedIndexPath = 0
            nextPaginate = ""
        }
        
        if pagingLoader.isAnimating {
            
            self.pagingLoader.stopAnimating()
            self.pagingLoader.hidesWhenStopped = true
        }
        pagingLoader.theme_color = GlobalPicker.activityViewColor
        pagingLoader.startAnimating()
        pagingLoader.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tblExtendedView.bounds.width, height: CGFloat(62))
        
        self.tblExtendedView.tableFooterView = pagingLoader
        self.tblExtendedView.tableFooterView?.isHidden = false
        
        //Normal API call
        if self.showArticleType != .topic && self.showArticleType != .places {
            
            if nextPaginate.isEmpty && !isPullToRefresh {
                
                let id = self.getCategoryId()
                if let arrCache = self.readCache(key: id), arrCache.count > 0 {
                    
                    self.isDataLoaded = true
                    self.articles = arrCache
                                
                    //Reload data
                    self.tblExtendedView.isHidden = false
                    self.tblExtendedView.reloadData {
                        self.tblExtendedView.setContentOffset(.zero, animated: true)
                        if let type = self.articles.first?.type, (type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE || type == Constant.newsArticle.ARTICLE_TYPE_VIDEO || type == Constant.newsArticle.FEED_ARTICLE_HERO || type == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL || type == Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS) {
                            
                            self.scrollToTopVisibleExtended()
                        }
                    }
                    self.isDirectionFindingNeeded = true

                    // do something in background
                    let killTime = SharedManager.shared.refreshFeedOnKillApp ?? Date()
                    let interval = Date().timeIntervalSince(killTime)
                    let minutes = (interval / 60).truncatingRemainder(dividingBy: 60)
                    if minutes >= Double(refreshTimeNeeded) {
                                   
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            self.viewNewPosts.isHidden = true
                            self.tblExtendedView.es.startPullToRefresh()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                self.tblExtendedView.es.stopPullToRefresh()
                            }
                        }
                        
                    }
                    else {
                        
                        if !(SharedManager.shared.isConnectedToNetwork()) {
                            
                    SharedManager.shared.isTabReload = true
                            return
                        }
                        
                        let cacheId = self.getCategoryId()
                        var lastModified = ""
                        if isOnFollowing {
                            lastModified = SharedManager.shared.lastModifiedTimeArticlesFollowing
                        }
                        else {
                            lastModified = SharedManager.shared.lastModifiedTimeArticlesForYou
                        }
                        /*
                        if let sub = SharedManager.shared.headlinesList[self.pageIndex].sub, sub.count > 0 {
                            cacheId = SharedManager.shared.headlinesList[self.pageIndex].sub?[self.currentIndexSub].id ?? ""
                            
                            lastModified = SharedManager.shared.headlinesList[self.pageIndex].lastModified ?? ""
                        }
                        else {
                            cacheId = SharedManager.shared.headlinesList[self.pageIndex].id ?? ""
                            lastModified = SharedManager.shared.headlinesList[self.pageIndex].lastModified ?? ""
                        }*/
//                        cacheId = SharedManager.shared.headlinesList[self.pageIndex].id ?? ""
//                        lastModified = SharedManager.shared.headlinesList[self.pageIndex].lastModified ?? ""
                        self.homeViewModel.performWSToGetFeedBackgroundTask(arrCache, lastModified: lastModified, cacheId: cacheId)

//                        DispatchQueue.background(background: {
//
//                        }, completion: {
//                            // when background job finished, do something in main thread
//                            self.pagingLoader.stopAnimating()
//                            self.pagingLoader.hidesWhenStopped = true
//                        })
                    }

                }
                else {
                    
                    self.callToGetNewsFeed()
                }
            }
            else {
                self.callToGetNewsFeed()
            }
        }
        else {
            self.callToGetNewsFeed()
        }
    }
    
    
    @objc func autohideloader() {
        
        SharedManager.shared.hideLaoderFromWindow()
    }
    
    private func writeCache(key: String, arrCacheArticles: [articlesData]) {
        
        //write articles data in cache
        do {
            try DataCache.instance.write(codable: arrCacheArticles, forKey: key)
        } catch {
            print("Write error \(error.localizedDescription)")
        }
    }
    
    private func readCache(key: String) -> [articlesData]? {
        
        //read articles data from cache
        do {
            let object: [articlesData]? = try DataCache.instance.readCodable(forKey: key)
            return object
        } catch {
            print("Read error \(error.localizedDescription)")
            return nil
        }
    }
    
    func getCategoryId(isReloadView: Bool = false) -> String {
        
        var id = ""
        if self.showArticleType == .topic {
            
            id = topicContextId
            
        }
        
        else if self.showArticleType == .places {
            
            id = placeContextId
            
            
        }
        else {
            
            if self.pageIndex < SharedManager.shared.reelsCategories.count {
                                
                if let sub = SharedManager.shared.reelsCategories[self.pageIndex].sub, sub.count > 0 {
                    
                    id = SharedManager.shared.reelsCategories[self.pageIndex].sub?[self.currentIndexSub].id ?? ""
                    if !isReloadView && !isPullToRefresh {
                        //self.nextPaginate = SharedManager.shared.headlinesList[self.pageIndex].sub?[self.currentIndexSub].pagination ?? ""
                    }
                }
                else {
                    
                    id = SharedManager.shared.reelsCategories[self.pageIndex].id ?? ""
                    if !isReloadView && !isPullToRefresh {
                        //self.nextPaginate = SharedManager.shared.headlinesList[self.pageIndex].pagination ?? ""
                    }
                }
            }
            
            //encode pagination value
            //nextPaginate = nextPaginate.encode()
            print("home id: ", nextPaginate, SharedManager.shared.reelsCategories[self.pageIndex].title ?? "")
        }

        return id
    }
    

    
    
    func loadDataInFeedList(_ arrFeed: [sectionsData], id: String, isNewPost: Bool = false) {
        
        //arrData = arrData.unique { $0.id ?? ""}
        var arrArticles = [articlesData]()
        
        //New Feed parsing
//        if let arrFeed = SharedManager.shared.loadJsonFeeds(filename: "feed") {
            
            for (idx, dictData) in arrFeed.enumerated() {
                
                let feedType = dictData.type?.uppercased() ?? ""
                let feedData = dictData.data
                
                // For testing
                /*
                if idx == 0 {
                    //Header
                    let bannerHeader = "Recent article"
                    if bannerHeader != "" {
                        arrArticles.append(articlesData(id: feedData?.context, title: bannerHeader, subheader: feedData?.subheader ?? "", type: Constant.newsArticle.ARTICLE_TYPE_HEADER, footer: feedData?.footer))
                    }
                    
                    arrArticles.append(articlesData(id: feedData?.context, title: "Trending Topics", subheader: "", type: Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_TOPICS, footer: nil))

                }*/
                
                if feedType == Constant.newsArticle.FEED_ARTICLE_HERO && feedType != "" {
                    
                    if feedData != nil, let article = feedData?.article {
                        arrArticles.append(articlesData(id: article.id, title: article.title, media: article.media, image: article.image, link: article.link, original_link: article.original_link, color: article.color, publish_time: article.publish_time, source: article.source, bullets: article.bullets, topics: article.topics, status: article.status, mute: article.mute, type: feedType, meta: article.meta, info: article.info, authors: article.authors, media_meta: article.media_meta, language: article.language, icon: article.icon, subType: article.type))
                    }
                }
                else if feedType == Constant.newsArticle.FEED_ARTICLE_HORIZONTAL && feedType != "" {
                    
                    let bannerHeader = feedData?.header ?? ""

                    if var articles = feedData?.articles {
                        
                        //Header
                        if bannerHeader != "" {
                            arrArticles.append(articlesData(id: feedData?.context, title: bannerHeader, subheader: feedData?.subheader ?? "", type: Constant.newsArticle.ARTICLE_TYPE_HEADER, footer: feedData?.footer))
                        }

                        if let topicHorinotal = feedData?.topic {
                            
                            let isFollow = topicHorinotal.followed ?? false
                            if isFollow {
                                
                                articles.append(articlesData(id: topicHorinotal.id, title: topicHorinotal.followed_text, image: topicHorinotal.image, type: "FOLLOWED_CARD", followed: isFollow, footer: feedData?.footer))
                            }
                            else {
                                articles.append(articlesData(id: topicHorinotal.id, title: topicHorinotal.unfollowed_text, image: topicHorinotal.image, type: "FOLLOWED_CARD", followed: isFollow, footer: feedData?.footer))
                            }
                        }
                        
                        //Data
                        arrArticles.append(articlesData(type: Constant.newsArticle.FEED_ARTICLE_HORIZONTAL, suggestedFeeds: articles, footer: feedData?.footer))
                        
//                        //Footer
//                        if let footer = feedData?.footer {
//                            arrArticles.append(articlesData(id: feedData?.context, type: Constant.newsArticle.ARTICLE_TYPE_FOOTER, footer: footer))
//                        }
                    }
                }
                else if feedType == Constant.newsArticle.FEED_ARTICLE_LIST && feedType != "" {
                    
                    let bannerHeader = feedData?.header ?? ""

                    if let articles = feedData?.articles {
                        
                        //Header
                        if bannerHeader != "" {
                            arrArticles.append(articlesData(id: feedData?.context, title: bannerHeader, subheader: feedData?.subheader ?? "", type: Constant.newsArticle.ARTICLE_TYPE_HEADER, footer: feedData?.footer))
                        }

                        //Data
                        for news in articles {
                            
                            if arrArticles.contains(where: {$0.id == news.id }) == false {
                                arrArticles.append(news)
                            }
                        }
                        
                        //Footer
                        if let footer = feedData?.footer {
                            arrArticles.append(articlesData(id: feedData?.context, type: Constant.newsArticle.ARTICLE_TYPE_FOOTER, footer: footer))
                        }
                    }
                }
                
                else if (feedType.contains(Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL) || feedType.contains(Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS)) && feedType != "" {
                    
                    let header = feedData?.header ?? ""

                    //large reels
                    if let reels = feedData?.reels {

                        arrArticles.append(articlesData(title: header, type: feedType, suggestedReels: reels))
                        
                        //Footer
                        if let footer = feedData?.footer {
                            arrArticles.append(articlesData(id: feedData?.context, type: Constant.newsArticle.ARTICLE_TYPE_FOOTER, suggestedReels: reels, subType: feedType, footer: footer))
                        }
                    }
                    
                    //Video Carousel
                    else if let arr = feedData?.articles {

                        arrArticles.append(articlesData(title: header, type: feedType, suggestedFeeds: arr))
                        
                        //Footer
                        if let footer = feedData?.footer {
                            arrArticles.append(articlesData(id: feedData?.context, type: Constant.newsArticle.ARTICLE_TYPE_FOOTER, suggestedFeeds: arr, subType: feedType, footer: footer))
                        }
                    }
                    
                }
                
                else if (feedType == Constant.newsArticle.FEED_REELS || feedType == Constant.newsArticle.FEED_TOPICS || feedType == Constant.newsArticle.FEED_CHANNELS) && feedType != "" {
                    
                    let header = feedData?.header ?? ""
                    
                    if let reels = feedData?.reels {
                        
                        //Header
//                        if header != "" {
//                            arrArticles.append(articlesData(title: header, type: Constant.newsArticle.ARTICLE_TYPE_HEADER))
//                        }

                        //reels
                        arrArticles.append(articlesData(title: header, type: Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_REELS, suggestedReels: reels))
                        
                        //Footer
                        if let footer = feedData?.footer {
                            arrArticles.append(articlesData(id: feedData?.context, type: Constant.newsArticle.ARTICLE_TYPE_FOOTER, footer: footer))
                        }
                    }
                    
                    else if let topics = feedData?.topics {

                        //topics
                        arrArticles.append(articlesData(title: header, type: Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_TOPICS, suggestedTopics: topics))

                        //Footer
                        if let footer = feedData?.footer {
                            arrArticles.append(articlesData(id: feedData?.context, type: Constant.newsArticle.ARTICLE_TYPE_FOOTER, footer: footer))
                        }
                    }
                    
                    else if let channels = feedData?.channels {
                        
                        //channels
                        arrArticles.append(articlesData(title: header, type: Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_CHANNELS, suggestedChannels: channels))
                        
                        //Footer
                        if let footer = feedData?.footer {
                            arrArticles.append(articlesData(id: feedData?.context, type: Constant.newsArticle.ARTICLE_TYPE_FOOTER, footer: footer))
                        }
                    }
                }
                
                else if feedType == Constant.newsArticle.FEED_ADS {
                    
                    arrArticles.append(articlesData(type: Constant.newsArticle.ARTICLE_TYPE_ADS))
                }
            }
//        }

        //append array
        let articlesPrevCount = self.articles.count
        self.articles += arrArticles
        
        
        if self.isPullToRefresh {
            //print("REFRESHED!!!")
//            self.isPullToRefresh = false
            self.tblExtendedView.contentOffset = .zero
        }
        
        if self.showArticleType == .topic {
            
        }
        else if self.showArticleType == .places {
            
        }
        else {
            
//            if (self.nextPaginate == "" && !self.isPullToRefresh) || isNewPost {
            if (self.nextPaginate == "") || isNewPost {
                if isNewPost {
                    self.viewNewPosts.isHidden = true
                }
                
                
                self.writeCache(key: id, arrCacheArticles: self.articles)
                
                //<--- read and write cache data
//                if SharedManager.shared.headlinesList[self.pageIndex].sub == nil {
//                    self.writeCache(key: id, arrCacheArticles: self.articles)
//                }
                //--->
            }
        }
        
        //Reload data
        self.tblExtendedView.isHidden = false
//        print("tblExtendedView.reloadData 5")
        //                            self.tblExtendedView.reloadData()
        
        DispatchQueue.main.async {
            
            if self.showSkeletonLoader {
                
                self.delegate?.loaderShowing(status: false)
                self.showSkeletonLoader = false
                self.tblExtendedView.reloadData {
//                    if self.nextPaginate == "" && !self.isPullToRefresh {
                        self.tblExtendedView.setContentOffset(.zero, animated: true)
                        if let type = self.articles.first?.type, (type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE || type == Constant.newsArticle.ARTICLE_TYPE_VIDEO || type == Constant.newsArticle.FEED_ARTICLE_HERO || type == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL || type == Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS), self.isViewPresenting {
                            self.scrollToTopVisibleExtended()
                        }
                        
//                    }
                }
                
            } else {
                // Pagination reload
                let articlesNewCount = self.articles.count - articlesPrevCount
                let rowsCount = self.tblExtendedView.numberOfRows(inSection: 0)
                if !self.isPullToRefresh && rowsCount > 0 && articlesPrevCount > 0 && articlesNewCount > 0 && rowsCount == articlesPrevCount {
//                    print("isNewPost \(isNewPost) , articlesPrevCount \(articlesPrevCount), articlesNewCount \(articlesNewCount)")
                    
                    var letestIndexArray = [IndexPath]()
                    
                    let newRowsCount = rowsCount + articlesNewCount
                    for i in rowsCount...newRowsCount - 1 {
                        print("inserted row \(i), rowsCount \(rowsCount), articlesPrevCount \(articlesPrevCount), articlesNewCount \(articlesNewCount) ")
                        let newIndexPath = IndexPath(row: i, section: 0)
                        letestIndexArray.append(newIndexPath)
                    }
                    
                    print("first item \(self.articles.first?.type ?? "")")
                    self.tblExtendedView.beginUpdates()
                    self.tblExtendedView.insertRows(at: letestIndexArray, with: .none)
                    self.tblExtendedView.endUpdates()
                } else {

                    self.tblExtendedView.reloadData {
                        if self.tblExtendedView.contentOffset == .zero {
                            if let type = self.articles.first?.type, (type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE || type == Constant.newsArticle.ARTICLE_TYPE_VIDEO || type == Constant.newsArticle.FEED_ARTICLE_HERO || type == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL || type == Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS), self.isViewPresenting {
                                self.scrollToTopVisibleExtended()
                            }
                        }
                    }
                }
                
                
            }
            
            if self.isPullToRefresh {
                //print("REFRESHED!!!")
                self.isPullToRefresh = false
            }
            
        }
        self.isDirectionFindingNeeded = true
        
        self.pagingLoader.stopAnimating()
        self.pagingLoader.hidesWhenStopped = true

    }
    

    
    
    
    
    public func presentationControllerDidDismiss( _ presentationController: UIPresentationController) {
        
        //print("dismiss")
    }
    
    func resetCurrentProgressBarStatus() {
        
        self.tblExtendedView.contentOffset = .zero

        //RESET EXTENDED VIEW CELL WHEN EXTENDED VIEW VISIBLE
        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
            cell.resetVisibleCard()
        }
        
        //RESET CURRENT PLAYING YOUTUBE CELL
        if let yCell = self.getCurrentFocussedCell() as? YoutubeCardCell {
            yCell.resetYoutubeCard()
        }
        
        //RESET VIDEO VIEW CC
        if let vCell = self.getCurrentFocussedCell() as? VideoPlayerVieww {
//            vCell.resetVisibleVideoPlayer()
            resetPlayerAtIndex(cell: vCell)
        }
        
        //RESET HERO VIEW CC
        if let hCell = self.getCurrentFocussedCell() as? HomeHeroCC {
            
            if let indexPath = tblExtendedView.indexPath(for: hCell) {
                let subtype = articles[indexPath.row].subType ?? ""
                if subtype.uppercased() == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                    resetHeroPlayerAtIndex(cell: hCell)
                }
                else if subtype.uppercased() == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                    hCell.resetYoutubeCard()
                }
            }

        }
        
        if let cell = self.getCurrentFocussedCell() as? HomeReelCarouselCC {
           
            cell.pauseAllCurrentlyFocusedMedia()
        }
        
        if let cell = self.getCurrentFocussedCell() as? HomeVideoCarouselCC {

            cell.pauseAllCurrentlyFocusedMedia()
        }


    }
    
    func updateProgressbarStatus(isPause: Bool) {
        
        if SharedManager.shared.isOnPrefrence {
            if isPause == false {
                return
            }
        }
        print("updateProgressbarStatus pause \(isPause) called")
        SharedManager.shared.bulletPlayer?.pause()
        
        if isPause {
            
            if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? HomeCardCell {
                
                cell.pauseAudioAndProgress(isPause:true)
            }
            else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? HomeListViewCC {
                
                cell.pauseAudioAndProgress(isPause:true)
            }
            else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? VideoPlayerVieww {
                
//                cell.playVideo(isPause: true)
                playVideoOnFocus(cell: cell, isPause: true)
            }
            else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? YoutubeCardCell {
                
                cell.resetYoutubeCard()
            }
            else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? HomeHeroCC {
                
                //let subType = self.articles[self.focussedIndexPath].subType ?? ""
                //if subType == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                    playHeroVideoOnFocus(cell: cell, isPause: true)
                //}
                //else if subType == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                    cell.resetYoutubeCard()
                //}
            }
            
            if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? HomeReelCarouselCC {
               
                cell.pauseAllCurrentlyFocusedMedia()
            }
            
            if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? HomeVideoCarouselCC {

                cell.pauseAllCurrentlyFocusedMedia()
            }

        }
        else {
            
            if let cell = self.tblExtendedView.cellForRow(at: IndexPath(item: self.focussedIndexPath, section: 0)) as? HomeCardCell {
                
                if let visibleIndex = self.getVisibleIndexPath() {
                    
                    if visibleIndex.row == self.focussedIndexPath {
                        if SharedManager.shared.viewSubCategoryIshidden {
                            print("audio playing 1")
                            cell.pauseAudioAndProgress(isPause:false)
                        } else {
                            cell.pauseAudioAndProgress(isPause:true)
                        }
                    }
                }
            }
            else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(item: self.focussedIndexPath, section: 0)) as? HomeListViewCC {
                                
                if let visibleIndex = self.getVisibleIndexPath() {
                    
                    if visibleIndex.row == self.focussedIndexPath {
                        if SharedManager.shared.viewSubCategoryIshidden {
                            print("audio playing 2")
                            cell.pauseAudioAndProgress(isPause:false)
                        } else {
                            cell.pauseAudioAndProgress(isPause:true)
                        }
                    }
                }
            }
            else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? VideoPlayerVieww {
                
                if SharedManager.shared.viewSubCategoryIshidden {
                    print("audio playing 3") 
//                    cell.playVideo(isPause: false)
                    playVideoOnFocus(cell: cell, isPause: false)
                } else {
//                    cell.playVideo(isPause: true)
                    playVideoOnFocus(cell: cell, isPause: true)
                }
                
            }
            else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? YoutubeCardCell {
                
                if SharedManager.shared.viewSubCategoryIshidden {
                    cell.setFocussedYoutubeView()
                } else {
                    cell.resetYoutubeCard()
                }
            }
            
            else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? HomeHeroCC {
                
                let subType = self.articles[self.focussedIndexPath].subType ?? ""
                if subType == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                    
                    playHeroVideoOnFocus(cell: cell, isPause: !SharedManager.shared.viewSubCategoryIshidden)
                }
                else if subType == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                    
                    if SharedManager.shared.viewSubCategoryIshidden {
                        cell.setFocussedYoutubeView()
                    } else {
                        cell.resetYoutubeCard()
                    }
                }
            }
            else if let reelCell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? HomeReelCarouselCC {
               
                if SharedManager.shared.viewSubCategoryIshidden {
                    reelCell.playCurrentlyFocusedMedia()
                } else {
                    reelCell.pauseAllCurrentlyFocusedMedia()
                }
            }
            
            else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? HomeVideoCarouselCC {

                if SharedManager.shared.viewSubCategoryIshidden {
                    cell.playCurrentlyFocusedMedia()
                }
                else {
                    cell.pauseAllCurrentlyFocusedMedia()
                }
            }
        }
    }
    
    func setupIndexPathForSelectedArticleCardAndListView(_ index: Int) {
        
        self.focussedIndexPath = index
    }
    
    func getIndexPathForSelectedArticleCardAndListView() -> Int {
        
        var index = 0
        index = self.focussedIndexPath
        return index
    }
    
    func getCurrentFocussedCell() -> UITableViewCell {
        
        let index = self.getIndexPathForSelectedArticleCardAndListView()
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) {
            return cell
        }

        return UITableViewCell()
    }
    
    func getVisibleIndexPath() -> IndexPath? {
        
        var isVisible = false
        var indexPathVisible: IndexPath?
        for indexPath in tblExtendedView.indexPathsForVisibleRows ?? [] {
            let cellRect = tblExtendedView.rectForRow(at: indexPath)
            isVisible = tblExtendedView.bounds.contains(cellRect)
            if isVisible {
                //print("indexPath is Visible")
                indexPathVisible = indexPath
                break
            }
        }
        if isVisible == false {
            //print("indexPath not Visible")
            let center = self.view.convert(tblExtendedView.center, to: tblExtendedView)
            indexPathVisible = tblExtendedView.indexPathForRow(at: center)
        }
        
        return indexPathVisible
    }
}

//MARK:- BottomSheetVC Delegate methods
extension HomeVC: BottomSheetVCDelegate {
    
    func didTapUpdateAudioAndProgressStatus() {
        
        self.updateProgressbarStatus(isPause: false)
    }
    
    func didTapDissmisReportContent() {
        
        self.updateProgressbarStatus(isPause: false)
        SharedManager.shared.showAlertLoader(message: "Report concern sent successfully.")
    }

}

//MARK:- HomeCardCell Delegate methods
extension HomeVC: HomeCardCellDelegate, YoutubeCardCellDelegate, VideoPlayerViewwDelegates, FullScreenVideoVCDelegate {
    
    func didTapCardCellFollow(cell: HomeCardCell) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        
        let article = self.articles[indexPath.row]
        if article.source != nil {
            
            let fav = self.articles[indexPath.row].source?.favorite ?? false
            self.articles[indexPath.row].source?.isShowingLoader = true
            cell.setFollowingUI(model: self.articles[indexPath.row])
            
            SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [article.source?.id ?? ""], isFav: !fav, type: .sources) {  success in
                
                self.articles[indexPath.row].source?.isShowingLoader = false
                
                if success {
                    self.articles[indexPath.row].source?.favorite = !fav
                }
                
                cell.setFollowingUI(model: self.articles[indexPath.row])
            }
        }
        else if (self.articles[indexPath.row].authors?.count ?? 0) > 0 {
            
            let fav = self.articles[indexPath.row].authors?[0].favorite ?? false
            self.articles[indexPath.row].authors?[0].isShowingLoader = true
            cell.setFollowingUI(model: self.articles[indexPath.row])
            
            
            SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [self.articles[indexPath.row].authors?[0].id ?? ""], isFav: !fav, type: .authors) {  success in
                
                self.articles[indexPath.row].authors?[0].isShowingLoader = false
                
                if success {
                    self.articles[indexPath.row].authors?[0].favorite = !fav
                }
                
                cell.setFollowingUI(model: self.articles[indexPath.row])
                
            }
        }
        
        
    }
    
    func backButtonPressed(cell: HomeDetailCardCell?) {
        updateProgressbarStatus(isPause: true)
    }
    func backButtonPressed(cell: GenericVideoCell?) {}
    func backButtonPressed(cell: VideoPlayerVieww?) {
        
//        cell?.playVideo(isPause: false)
        guard let cell = cell else { return }
        playVideoOnFocus(cell: cell, isPause: false)
    }
    
    
    func playVideoOnFocus(cell: VideoPlayerVieww, isPause: Bool) {
        
//        if SharedManager.shared.isAudioEnable == false {
//
//            player.volume = 0
//            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
//        }
//        else {
//
//            player.volume = 1
//            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
//        }
        
        if MediaManager.sharedInstance.isFullScreenButtonPressed {
            return
        }
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        
        print("playVideoOnFocus indexPath", indexPath)
        if isPause {
            
            guard let player = MediaManager.sharedInstance.player else {
                return
            }
               
//            guard let index = player.indexPath , index == indexPath else {
//                return
//            }
//            if player.indexPath == indexPath {
//                MediaManager.sharedInstance.releasePlayer()
//            }
//            cell.playButton.isHidden = false
//            cell.viewDuration.isHidden = false
//            cell.imgPlayButton.isHidden = false
            player.pause()
//            player.stop()
            print("player.pause at indexPath", indexPath)
//            if self.isCommunityCell {
//                self.btnReport.isHidden = false
//            }
            
//            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoDurationEvent, eventDescription: "", article_id: self.articles[self.focussedIndexPath].id ?? "", duration: MediaManager.sharedInstance.player?.currentTime?.formatToMilliSeconds() ?? "")
            
        }
        else {
            
            if SharedManager.shared.videoAutoPlay {
                let status = articles[indexPath.row].status
                if status != Constant.newsArticle.ARTICLE_STATUS_SCHEDULED && status != Constant.newsArticle.ARTICLE_STATUS_PROCESSING {
                    didTapVideoPlayButton(cell: cell, isTappedFromCell: false)
                }
            }
            
        }
    }
    
    func resetPlayerAtIndex(cell: VideoPlayerVieww) {
        
        if MediaManager.sharedInstance.isFullScreenButtonPressed {
            return
        }
        cell.playButton.isHidden = false
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        
        if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == indexPath {
            MediaManager.sharedInstance.player?.stop()
            MediaManager.sharedInstance.releasePlayer()
            cell.viewDuration.isHidden = false
            cell.imgPlayButton.isHidden = false
        }
        
    }
    
    func didTapVideoPlayButton(cell: VideoPlayerVieww, isTappedFromCell: Bool) {
        
        if isTappedFromCell {
            updateProgressbarStatus(isPause: true)
        }
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        
        let oldFocus = IndexPath(row: self.focussedIndexPath, section: 0)
        if oldFocus == indexPath {
            
            let art = self.articles[oldFocus.row]
            guard let url = URL(string: art.link ?? "") else { return }
            // Same focus
            if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == oldFocus, player.contentURL == url {
                if player.isPlaying == false {
                    
                    cell.playButton.isHidden = true
                    cell.viewDuration.isHidden = true
                    cell.imgPlayButton.isHidden = true
                    player.play()
                    return
                }
            }
        }
        
        // reset old player
        resetOldPlayer(oldFocus: oldFocus)
        
        
        let art = self.articles[indexPath.row]
        guard let url = URL(string: art.link ?? "") else { return }
        self.focussedIndexPath = indexPath.row
        
        if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == indexPath, player.contentURL == url {
            player.play()
            cell.playButton.isHidden = true
            cell.viewDuration.isHidden = true
            cell.imgPlayButton.isHidden = true
           return
        }
        
        cell.playButton.isHidden = true
        cell.viewDuration.isHidden = true
        cell.imgPlayButton.isHidden = true
        let videoInfo = [
            "autoPlay":true,
            "floatMode": EZPlayerFloatMode.none,
            "fullScreenMode": EZPlayerFullScreenMode.landscape
        ] as [String : Any]
        
        MediaManager.sharedInstance.releasePlayer()
        MediaManager.sharedInstance.playEmbeddedVideo(url: url, embeddedContentView: cell.imgPlaceHolder, userinfo: videoInfo, viewController: self, articleID: art.id ?? "")
        MediaManager.sharedInstance.player?.indexPath = indexPath
        MediaManager.sharedInstance.player?.scrollView = tblExtendedView
        
    }
    
    func resetOldPlayer(oldFocus: IndexPath) {
        
        
        if let cell = tblExtendedView.cellForRow(at: oldFocus) as? VideoPlayerVieww {
            
            MediaManager.sharedInstance.releasePlayer()
            cell.playButton.isHidden = false
            cell.viewDuration.isHidden = false
            cell.imgPlayButton.isHidden = false
        }
        
        else if let cell =  getCurrentFocussedCell() as? HomeHeroCC {
            
            MediaManager.sharedInstance.releasePlayer()
            cell.animationSourceShowHide(isShow: true)
            cell.playButton.isHidden = false
            cell.viewDuration.isHidden = false
            cell.imgPlayButton.isHidden = false
        }
        
    }
    
    func didSelectCell(cell: VideoPlayerVieww) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        
        // When focus index of card and the user taps index not same then return it
        let row = indexPath.row
        print("UITapGestureRecognizer: ", row)
        let content = self.articles[row]
        updateProgressbarStatus(isPause: true)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//            self.showTopAndBottomBar()
//        }
        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.selectedArticleData = content
        vc.delegate = self
        vc.delegateVC = self
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalTransitionStyle = .crossDissolve
//        self.present(navVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func seteMaxHeightForIndexPathHomeList(cell: UITableViewCell, maxHeight: CGFloat) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
//        SharedManager.shared.maxHeightForIndexPath[indexPath] = maxHeight
    }
    
    func resetSelectedArticle() {
        
        //RESET EXTENDED VIEW CELL WHEN EXTENDED VIEW VISIBLE
        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
            cell.btnVolume.isHidden = true
        }
        
        //RESET VIDEO VIEW CC
        if let vCell = self.getCurrentFocussedCell() as? HomeListViewCC {
            vCell.btnVolume.isHidden = true
        }
        
        if let vCell = self.getCurrentFocussedCell() as? VideoPlayerVieww {
            
//            vCell.btnVolume.isHidden = true
//            vCell.resetVisibleVideoPlayer()
            resetPlayerAtIndex(cell: vCell)
        }
        
        //RESET HERO VIEW CC
        if let hCell = self.getCurrentFocussedCell() as? HomeHeroCC {
            
            if let indexPath = tblExtendedView.indexPath(for: hCell) {
                let subtype = articles[indexPath.row].subType ?? ""
                if subtype.uppercased() == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                    resetHeroPlayerAtIndex(cell: hCell)
                }
                else if subtype.uppercased() == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                    hCell.resetYoutubeCard()
                }
            }

        }
        
        if let reelCell = self.getCurrentFocussedCell() as? HomeReelCarouselCC {
           
            reelCell.pauseAllCurrentlyFocusedMedia()
        }
        
        if let cell = self.getCurrentFocussedCell() as? HomeVideoCarouselCC {

            cell.pauseAllCurrentlyFocusedMedia()
        }

    }
    
    //ARTICLES SWIPE
    func layoutUpdate() {
        
        if prefetchState != .fetching && articles.count == tblExtendedView.numberOfRows(inSection: 0) {
            DispatchQueue.main.async {
                self.tblExtendedView.beginUpdates()
                self.tblExtendedView.endUpdates()
            }
        }
    }
    
    @objc func didTapOpenSourceURL(sender: UITapGestureRecognizer) {

        // When focus index of card and the user taps index not same then return it
        let row = sender.view?.tag ?? 0
        print("UITapGestureRecognizer: ", row)
        let content = self.articles[row]
        updateProgressbarStatus(isPause: true)
                
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//            self.showTopAndBottomBar()
//        }
        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.selectedArticleData = content
        vc.delegate = self
        vc.delegateVC = self
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalTransitionStyle = .crossDissolve
//        self.present(navVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
//        self.presentDetail(navVC)
        
    }

        
    @objc func didTapPlayYoutube(_ button: UIButton) {
        
        //EXTENDED/LIST VIEW TAP TO PLAY YOUTUBE
        updateProgressbarStatus(isPause: true)
        
        let index = button.tag
        self.focussedIndexPath = index
        
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? YoutubeCardCell {
            
            //self.curVisibleYoutubeCardCell = cell
            cell.pauseYoutube(isPause: false)
        }
        else if let hCell = tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeHeroCC {
            
            let subType = articles[index].subType ?? ""
            if subType.uppercased() == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                
                hCell.pauseYoutube(isPause: false)
            }
        }
    }
    
    
    @objc func didTapReport(button: UIButton) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.shareClick, eventDescription: "")

        self.updateProgressbarStatus(isPause: true)
        let index = button.tag
        let content = self.articles[index]
        self.homeViewModel.performWSToShare(article: content, isOpenForNativeShare: false)
    }
    
    @objc func didTapShare(button: UIButton) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.shareClick, eventDescription: "")

        self.updateProgressbarStatus(isPause: true)
        let index = button.tag
        let content = self.articles[index]
        self.homeViewModel.performWSToShare(article: content, isOpenForNativeShare: true)
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
                    //                    self.playCurrentCellVideo()
                    self.updateProgressbarStatus(isPause: false)
                    return
                }
                // User completed activity
            }
            self.updateProgressbarStatus(isPause: true)
            self.present(activityVc, animated: true)
        }
        
    }
    
    
    @objc func didTapSource(button: UIButton) {
        
        //EXTENDED VIEW TAP TO OPEN SOURCE
        let index = button.tag
        let content = self.articles[index]
        
        if let _ = content.source {
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
            
            self.updateProgressbarStatus(isPause: true)
            button.isUserInteractionEnabled = false
            
            self.homeViewModel.performGoToSource(content.source?.id ?? "")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                button.isUserInteractionEnabled = true
            }
        }
        else {
            self.updateProgressbarStatus(isPause: true)
            
            let authors = content.authors
            if (authors?.first?.id ?? "") == SharedManager.shared.userId {
                
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
    
    @objc func didTapForYouHeaderAction(button: UIButton) {
        
        self.showTopAndBottomBar(animated: true)
        
        let row = button.tag
        let content = self.articles[row]
        
        SharedManager.shared.curReelsCategoryId = content.id ?? ""
        NotificationCenter.default.post(name: Notification.Name.notifyTapSubcategories, object: nil)
    }
    
    @objc func didTapReadMoreForYouFooter(button: UIButton) {
        
        self.showTopAndBottomBar(animated: true)
        let row = button.tag
        let content = self.articles[row]
        let id = content.id ?? ""
        let subType = content.subType ?? ""
        
        if subType == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL {
            
            updateProgressbarStatus(isPause: true)
            let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
            vc.isBackButtonNeeded = true
            vc.modalPresentationStyle = .overFullScreen
            if let reels = content.suggestedReels {
                vc.reelsArray = reels
            }
            
            //vc.isSugReels = true
            //vc.delegate = self
            //vc.userSelectedIndexPath = IndexPath(item: reelRow, section: 0)
            //vc.authorID = reelsArray[reelRow].authors?.first?.id ?? ""
            vc.scrollToItemFirstTime = true

            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .overFullScreen
            self.present(navVC, animated: true, completion: nil)
        }
        else if subType == Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS {
            
            updateProgressbarStatus(isPause: true)

            let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
            vc.showArticleType = .places
            vc.isFollowBtnNeeded = false
            vc.selectedID = id
            placeContextId = content.id ?? ""
            vc.isFav = false
            vc.subTopicTitle = content.footer?.title ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            
            if showArticleType != .topic && showArticleType != .places {
                /*
                let result = SharedManager.shared.headlinesList.filter { $0.id ?? "" ==  id}
                if result.isEmpty {
                    
                    if let ptcTBC = tabBarController as? PTCardTabBarController {
                        ptcTBC.showTabBar(false, animated: true)
                    }
                    
                    let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
                    vc.showArticleType = .places
                    vc.selectedID = id
                    vc.isFav = content.followed ?? false
                    vc.subTopicTitle = content.footer?.title ?? ""
                    placeContextId = content.id ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                } else {
                    // exists
                    SharedManager.shared.curCategoryId = content.id ?? ""
                    NotificationCenter.default.post(name: Notification.Name.notifyTapSubcategories, object: nil)
                }*/
            }
            else {
                
                // exists
                SharedManager.shared.curReelsCategoryId = content.id ?? ""
                NotificationCenter.default.post(name: Notification.Name.notifyTapSubcategories, object: nil)

            }
        }

    }
    
    //<---
    // Public delegate methods for all cells are here
    func handleLongPressHold(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        var index: Int = 0
        index = self.focussedIndexPath

        if let cell = tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeCardCell {
            
            if gestureRecognizer.state == .began {
                
                cell.pauseAudioAndProgress(isPause: true)
            }
            if gestureRecognizer.state == .ended {
                
                cell.pauseAudioAndProgress(isPause: false)
            }
        }
        else if let cell = tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeListViewCC {
            
            if gestureRecognizer.state == .began {
                
                cell.pauseAudioAndProgress(isPause: true)
            }
            if gestureRecognizer.state == .ended {
                
                cell.pauseAudioAndProgress(isPause: false)
            }
        }
    }
    
    func autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: Bool) {
        
        isDirectionFindingNeeded = true
        //Check for auto scroll is running when the user changed View Type(Extended to List)
//        SharedManager.shared.bulletsMaxCount = 0
        
        //Data always load from first position
        var index = 0
        index = self.focussedIndexPath

        //Reset previous view cell audio -- CARD VIEW
        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
            cell.resetVisibleCard()
        }
        else {
            
            if let cell = tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeCardCell {
                cell.resetVisibleCard()
            }
        }
        
        //Reset previous view cell audio -- LIST VIEW
        if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
            cell.resetVisibleListCell()
        }
        else {
            
            if let cell = tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeListViewCC {
                cell.resetVisibleListCell()
            }
        }
        
        //Reset previous view cell audio -- LIST VIEW
        if let cell = self.getCurrentFocussedCell() as? YoutubeCardCell {
            cell.resetYoutubeCard()
        }
        else {
            
            if let cell = tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? YoutubeCardCell {
                cell.resetYoutubeCard()
            }
        }


        if index < self.articles.count && self.articles.count > 1 {
            
            var newIndex = 0
            newIndex = isMoveNext ? index + 1 : index - 1
            newIndex = newIndex >= self.articles.count ? 0 : newIndex
            var newIndexPath: IndexPath = IndexPath(item: newIndex, section: 0)
            
            //For Skip header and footer cell
            if newIndex < self.articles.count && newIndex != self.articles.count - 1 {
                
                let content = self.articles[newIndex]
                if content.type == Constant.newsArticle.ARTICLE_TYPE_HEADER || content.type == Constant.newsArticle.ARTICLE_TYPE_FOOTER || content.type == Constant.newsArticle.ARTICLE_TYPE_ADS {
                    newIndex += 1
                    
                    if newIndex < self.articles.count {
                        let content = self.articles[newIndex]
                        if content.type == Constant.newsArticle.ARTICLE_TYPE_HEADER || content.type == Constant.newsArticle.ARTICLE_TYPE_FOOTER || content.type == Constant.newsArticle.ARTICLE_TYPE_ADS {
                            newIndex += 1
                        }
                    }
                    
                    if newIndex < self.articles.count {
                        let content = self.articles[newIndex]
                        if content.type == Constant.newsArticle.ARTICLE_TYPE_HEADER || content.type == Constant.newsArticle.ARTICLE_TYPE_FOOTER || content.type == Constant.newsArticle.ARTICLE_TYPE_ADS {
                            newIndex += 1
                        }
                    }
                    newIndexPath = IndexPath(row: newIndex, section: newIndexPath.section)
                }
            }
            else if newIndex == self.articles.count - 1 {
                let content = self.articles[newIndex]
                if content.type == Constant.newsArticle.ARTICLE_TYPE_HEADER || content.type == Constant.newsArticle.ARTICLE_TYPE_FOOTER || content.type == Constant.newsArticle.ARTICLE_TYPE_ADS {
                    return
                }
            }
                   
            let currentContent = self.articles[index]
            UIView.animate(withDuration: 0.3) {
                if currentContent.type == Constant.newsArticle.ARTICLE_TYPE_EXTENDED {
                    self.tblExtendedView.selectRow(at: newIndexPath, animated: false, scrollPosition: .top)
                } else {
                    self.tblExtendedView.selectRow(at: newIndexPath, animated: true, scrollPosition: .top)
                }
                
                //self.tblExtendedView.scrollToRow(at: newIndexPath, at: .top, animated: false)
                //self.tblExtendedView.layoutIfNeeded()
                
            } completion: { (finished) in
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let cell = self.tblExtendedView.cellForRow(at: newIndexPath) as? HomeCardCell {

                    let content = self.articles[newIndexPath.row]
                    cell.setupSlideScrollView(article: content, isAudioPlay: true, row: newIndexPath.row, isMute: content.mute ?? true)

                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex)
                }
                else if let cell = self.tblExtendedView.cellForRow(at: newIndexPath) as? HomeListViewCC {

                    let content = self.articles[newIndexPath.row]
                    cell.setupCellBulletsView(article: content, isAudioPlay: true, row: newIndexPath.row, isMute: content.mute ?? true)

                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex)
                }
                else if let vCell = self.tblExtendedView.cellForRow(at: newIndexPath) as? VideoPlayerVieww {
                    
                    vCell.videoControllerStatus(isHidden: true)
//                    vCell.playVideo(isPause: false)
                    self.playVideoOnFocus(cell: vCell, isPause: false)
                    
                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex)
                }
                
                else if let yCell = self.tblExtendedView.cellForRow(at: newIndexPath) as? YoutubeCardCell {
                    
                    self.curYoutubeVisibleCell = yCell
                    yCell.setFocussedYoutubeView()
                    
                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex)
                }
            }
        }
        else if self.articles.count == 1 {
            
            //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
            self.setupIndexPathForSelectedArticleCardAndListView(0)
            self.tblExtendedView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    //--->
}


//MARK:- UIActivityItemSource --- For ShareSheet
extension HomeVC: UIActivityItemSource {
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage() // an empty UIImage is sufficient to ensure share sheet shows right actions
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return self.shareTitle
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        
        if #available(iOS 13.0, *) {
            let metadata = LPLinkMetadata()
            
            metadata.title = self.shareTitle // Preview Title
            metadata.originalURL = urlOfImageToShare // determines the Preview Subtitle
            metadata.url = urlOfImageToShare
            metadata.imageProvider = NSItemProvider.init(contentsOf: urlOfImageToShare)
            metadata.iconProvider = NSItemProvider.init(contentsOf: urlOfImageToShare)
            
            return metadata
            
        } else {
            // Fallback on earlier versions
            return nil
        }
    }
}


//MARK:- CARD VIEW TABLE DELEGATE
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    //gradient for ForYou page
    func setGradientBackground(viewBG:UIView,colours: [UIColor]) {
        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = colours
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.frame = viewBG.bounds
//        viewBG.layer.insertSublayer(gradientLayer, at:0)
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = viewBG.bounds
        gradient.colors = colours.map { $0.withAlphaComponent(1.0).cgColor }
        gradient.locations = [0.0, 1.0]
        viewBG.layer.addSublayer(gradient)
    }
    
    
    //func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if showSkeletonLoader {
            tableView.isScrollEnabled = false
            return 10
        }
        tableView.isScrollEnabled = true
        if articles.count > 0 {
            self.delegate?.loaderShowing(status: false)
        }
        
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      
        
        if let cell = (cell as? sugClvTopicsCC) {
            cell.layoutSubviews()
        }
        
        if let skeletonCell = cell as? HomeSkeltonCardCell {
            skeletonCell.slide(to: .right)
        }
        
        if let skeletonCell = cell as? HomeSkeltonListCell {
            skeletonCell.slide(to: .right)
        }
        
        
        if let cell = cell as? HomeListViewCC {
            
            cell.clvBullets.reloadData()
        }
    
        print("Pre loading... index", indexPath.item)
        print("Pre loading... arrayCount", self.articles.count)
        
        if self.articles.count > 0 && indexPath.item >= self.articles.count / 2 {
            
            if self.prefetchState == .idle {
                
                print("Pre loading... Called")
                guard self.prefetchState == .idle && !isPullToRefresh && !(self.nextPaginate.isEmpty) else { return }
                self.prefetchState = .fetching
                self.getRefreshArticlesData()
            }
        }
        

        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if showSkeletonLoader {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeSkeltonCardCell") as! HomeSkeltonCardCell
                cell.gradientLayers.forEach { gradientLayer in
                  let baseColor = cell.viewTitle1.backgroundColor!
                  gradientLayer.colors = [baseColor.cgColor,
                                          baseColor.brightened(by: 0.93).cgColor,
                                          baseColor.cgColor]
                }
                
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeSkeltonListCell") as! HomeSkeltonListCell
            cell.gradientLayers.forEach { gradientLayer in
              let baseColor = cell.viewTitle1.backgroundColor!
              gradientLayer.colors = [baseColor.cgColor,
                                      baseColor.brightened(by: 0.93).cgColor,
                                      baseColor.cgColor]
            }
            return cell
            
        }
    
        // Fixed crash
        if indexPath.row >=  self.articles.count {
            return UITableViewCell()
        }
        
        let content = self.articles[indexPath.row]
        
        
        let type = content.type?.uppercased() ?? ""
        if type == Constant.newsArticle.FEED_ARTICLE_HERO {
            
            let imgCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_HERO, for: indexPath) as! HomeHeroCC
            imgCell.delegate = self
            imgCell.selectionStyle = .none
            imgCell.setupCell(content: content, isAutoPlay: false, isFromDetailScreen: false)
            return imgCell
        }
        else if type == Constant.newsArticle.FEED_ARTICLE_HORIZONTAL {

            let headCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_HEADLINE_CLV, for: indexPath) as! HomeClvHeadlineCC
         
            headCell.contentView.theme_backgroundColor = GlobalPicker.backgroundCardColor
            headCell.backView.theme_backgroundColor = GlobalPicker.backgroundColorWhiteBlack
            
            headCell.delegateSugFeeds = self
            headCell.selectionStyle = .none
            headCell.setupCell(content: content, row: indexPath.row)
            return headCell
        }
        else if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_TOPICS {

            guard let sugcell = tableView.dequeueReusableCell(withIdentifier: "sugClvTopicsCC", for: indexPath) as? sugClvTopicsCC else { return UITableViewCell() }
            sugcell.delegateSugTopics = self
            sugcell.selectionStyle = .none
            sugcell.setupCell(content: content, row: indexPath.row)
            sugcell.layoutIfNeeded()
            return sugcell
        }
        else if type == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_CHANNELS {

//            guard let sugcell = tableView.dequeueReusableCell(withIdentifier: "sugClvChannelsCC", for: indexPath) as? sugClvChannelsCC else { return UITableViewCell() }
//            sugcell.selectionStyle = .none
//            sugcell.delegateSugChannels = self
//            sugcell.setupCell(content: content, row: indexPath.row)
//            sugcell.layoutIfNeeded()
//            return sugcell
            guard let channels = content.suggestedChannels else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedCC", for: indexPath) as! SuggestedCC
            cell.setupCell(model: channels)
            cell.delegate = self
            return cell
            
        }
        else if type == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_REELS {

            guard let sugcell = tableView.dequeueReusableCell(withIdentifier: "sugClvReelsCC", for: indexPath) as? sugClvReelsCC else { return UITableViewCell() }
            sugcell.selectionStyle = .none
            sugcell.delegateSugReels = self
            sugcell.setupCell(content: content, row: indexPath.row, isHomeFeed: true)
            sugcell.layoutIfNeeded()
            return sugcell
        }
        else if type == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL {

            guard let reelCC = tableView.dequeueReusableCell(withIdentifier: "HomeReelCarouselCC", for: indexPath) as? HomeReelCarouselCC else { return UITableViewCell() }
            reelCC.setUpCell(content: content)
            reelCC.delegate = self
            reelCC.layoutIfNeeded()
            return reelCC
        }
        else if type == Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS {

            guard let vCell = tableView.dequeueReusableCell(withIdentifier: "HomeVideoCarouselCC", for: indexPath) as? HomeVideoCarouselCC else { return UITableViewCell() }
            vCell.setUpCell(model: content)
            vCell.delegate = self
            vCell.layoutIfNeeded()
            return vCell
        }
        else if type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {

            //LOCAL VIDEO TYPE
            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            let videoPlayer = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER, for: indexPath) as! VideoPlayerVieww
         //   videoPlayer.delegateVideoView = self

            videoPlayer.viewDividerLine.isHidden = !SharedManager.shared.readerMode
            videoPlayer.constraintContainerViewBottom.constant = 10
            
            videoPlayer.delegate = self
            videoPlayer.delegateLikeComment = self

//            videoPlayer.lblViewCount.text = "0"
            if let info = content.meta {
                
//                videoPlayer.lblViewCount.text = info.view_count
            }
            
            videoPlayer.selectionStyle = .none
            videoPlayer.videoThumbnail = content.image ?? ""
            
            videoPlayer.btnReport.tag = indexPath.row
            // videoPlayer.btnShare.tag = indexPath.row
            videoPlayer.btnSource.tag = indexPath.row
            videoPlayer.playButton.tag = indexPath.row
            
            // videoPlayer.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
            videoPlayer.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            videoPlayer.btnReport.addTarget(self, action: #selector(didTapReport(button:)), for: .touchUpInside)
//            videoPlayer.playButton.addTarget(self, action: #selector(didTapPlayVideo(_:)), for: .touchUpInside)

            //LEFT - RIGHT ACTION
            videoPlayer.lblSource.addTextSpacing(spacing: 2.0)
            
            if let pubDate = content.publish_time {
                videoPlayer.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
            }
            videoPlayer.lblTime.addTextSpacing(spacing: 0.5)
            
            if self.focussedIndexPath == indexPath.row {
                self.curVideoVisibleCell = videoPlayer
            }
            
            if let bullets = content.bullets {
                
                if SharedManager.shared.viewSubCategoryIshidden {
                    print("audio playing 4")
                    videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: self.focussedIndexPath == indexPath.row ? true : false)

                } else {
                    
                    print("audio not playing")
                    videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: false)

                }
            }
    
            videoPlayer.setNeedsUpdateConstraints()
            videoPlayer.updateConstraintsIfNeeded()
            videoPlayer.setNeedsLayout()
            videoPlayer.layoutIfNeeded()

            return videoPlayer
        }
        
        //GOOGLE ADS CELL
        else if type == Constant.newsArticle.ARTICLE_TYPE_ADS {
            
            SharedManager.shared.isVolumnOffCard = true
            
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            //print("Volume 36")
            
            let adCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_ADS_LIST, for: indexPath) as! HomeListAdsCC
            
//            if isForYouPage  {
//
//                adCell.viewDividerLine.isHidden = false
//                adCell.constraintContainerViewBottom.constant = 0
//            }
//            else {
                  
                adCell.viewDividerLine.isHidden = !SharedManager.shared.readerMode
                adCell.constraintContainerViewBottom.constant = 10
//            }
            
            adCell.selectionStyle = .none
            if SharedManager.shared.adType.uppercased() == "FACEBOOK" {
                
                adCell.loadFacebookAd(nativeAd: self.fbnNativeAd, viewController: self)
            } else {
                
                adCell.loadGoogleAd(nativeAd: self.googleNativeAd)
            }
            
            adCell.contentView.backgroundColor = .clear
            adCell.viewUnifiedNativeAd.backgroundColor = .clear
            adCell.viewBackground.theme_backgroundColor =  GlobalPicker.bgBlackWhiteColor
            return adCell
            
        }
        
        //YOUTUBE CARD CELL
        else if type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            
            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            //print("Volume 37")
            
            let youtubeCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_YOUTUBE_CARD, for: indexPath) as! YoutubeCardCell
             
            
            youtubeCell.viewDividerLine.isHidden = !SharedManager.shared.readerMode
            youtubeCell.constraintContainerViewBottom.constant = 10
            
            
            //BUTTON ACTIONs
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
            tapGesture.view?.tag = indexPath.row
            youtubeCell.tag = indexPath.row
            print("cardCell.viewGestures: ", indexPath.row)
            youtubeCell.addGestureRecognizer(tapGesture)
            
            // Set like comment
            youtubeCell.setLikeComment(model: content.info)
            
            youtubeCell.langCode = content.language ?? ""
            youtubeCell.delegateYoutubeCardCell = self
            youtubeCell.delegateLikeComment = self
            youtubeCell.selectionStyle = .none
            
            youtubeCell.url = content.link ?? ""
            youtubeCell.urlThumbnail = content.image ?? ""
            youtubeCell.articleID = content.id ?? ""
            
            if let source = content.source {
                
                let sourceURL = source.icon ?? ""
                youtubeCell.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
                youtubeCell.lblSource.text = source.name ?? ""
            }
            else {
                
                let url = content.authors?.first?.image ?? ""
                youtubeCell.imgWifi?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
                youtubeCell.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            }
            youtubeCell.lblSource.addTextSpacing(spacing: 2.0)

//            youtubeCell.lblAuthor.text = content.authors?.first?.name?.capitalized
            let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            let source = content.source?.name ?? ""
           
//            youtubeCell.viewDot.clipsToBounds = false
            if author == source || author == "" {
                youtubeCell.lblAuthor.isHidden = true
//                youtubeCell.viewDot.isHidden = true
//                youtubeCell.viewDot.clipsToBounds = true
                youtubeCell.lblSource.text = source
            }
            else {
                
                youtubeCell.lblSource.text = source
                youtubeCell.lblAuthor.text = author
                
                if source == "" {
                    youtubeCell.lblAuthor.isHidden = true
//                    youtubeCell.viewDot.isHidden = true
//                    youtubeCell.viewDot.clipsToBounds = true
                    youtubeCell.lblSource.text = author
                }
                else if author != "" {
                    youtubeCell.lblAuthor.isHidden = false
//                    youtubeCell.viewDot.isHidden = false
                }
            }

            youtubeCell.btnShare.tag = indexPath.row
            youtubeCell.btnSource.tag = indexPath.row
            youtubeCell.btnPlayYoutube.tag = indexPath.row

            youtubeCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
            youtubeCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            youtubeCell.btnPlayYoutube.addTarget(self, action: #selector(didTapPlayYoutube(_:)), for: .touchUpInside)

            //LEFT - RIGHT ACTION
            
            if let pubDate = content.publish_time {
                youtubeCell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
            }
            youtubeCell.lblTime.addTextSpacing(spacing: 0.5)
            
            //Selected cell
            if self.focussedIndexPath == indexPath.row {
                self.curYoutubeVisibleCell = youtubeCell
            }
            
            //setup cell
            if let bullets = content.bullets {
                
                youtubeCell.setupSlideScrollView(bullets: bullets, row: indexPath.row)
            }
            
            return youtubeCell
        }
        
        //HOME ARTICLES CELL
        else {
            
            SharedManager.shared.isVolumnOffCard = false
            
            if type == Constant.newsArticle.ARTICLE_TYPE_SIMPLE {
                
                //LIST VIEW DESIGN CELL- SMALL CELL
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW, for: indexPath) as? HomeListViewCC else { return UITableViewCell() }
                    
//                cell.viewDividerLine.isHidden = !SharedManager.shared.readerMode
//                cell.constraintContainerViewBottom.constant = 10
                
                cell.backgroundColor = UIColor.clear
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                cell.selectionStyle = .none
                cell.delegateHomeListCC = self
                cell.delegateLikeComment = self
                
                cell.btnShare.tag = indexPath.row
                cell.btnSource.tag = indexPath.row
                cell.btnShare.addTarget(self, action: #selector(didTapReport(button:)), for: .touchUpInside)
                cell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
                
                cell.btnLeft.accessibilityIdentifier = String(indexPath.row)
                cell.btnRight.accessibilityIdentifier = String(indexPath.row)
                cell.btnLeft.addTarget(self, action: #selector(didTapScrollBulletsList(_:)), for: .touchUpInside)
                cell.btnRight.addTarget(self, action: #selector(didTapScrollBulletsList(_:)), for: .touchUpInside)
                
                //GESTURE
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
                tapGesture.view?.tag = indexPath.row
                cell.tag = indexPath.row
                cell.viewContainer.addGestureRecognizer(tapGesture)
                
                let panLeft = PanDirectionGestureRecognizer(direction: .horizontal(.left), target: self, action: #selector(handlePanGesture(_:)))
                panLeft.view?.tag = indexPath.row
                panLeft.cancelsTouchesInView = false
                cell.viewContainer.addGestureRecognizer(panLeft)
                
                let panRight = PanDirectionGestureRecognizer(direction: .horizontal(.right), target: self, action: #selector(handlePanGesture(_:)))
                panRight.view?.tag = indexPath.row
                panRight.cancelsTouchesInView = false
                cell.viewContainer.addGestureRecognizer(panRight)
                
                //add UISwipeGestureRecognizer when selected cell is active
                let direction: [UISwipeGestureRecognizer.Direction] = [ .left, .right]
                for dir in direction {
                    let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeViewList(_:)))
                    cell.viewContainer.addGestureRecognizer(swipeGesture)
                    swipeGesture.direction = dir
                    swipeGesture.view?.tag = indexPath.row
                    cell.viewContainer.isUserInteractionEnabled = true
                    cell.viewContainer.isMultipleTouchEnabled = false
                    
                    panLeft.require(toFail: swipeGesture)
                    panRight.require(toFail: swipeGesture)
                }
                
                //Set Child Collectionview DataSource and Layout
                if SharedManager.shared.viewSubCategoryIshidden {
                    print("audio playing 5")
                    cell.setupCellBulletsView(article: content, isAudioPlay: self.focussedIndexPath == indexPath.row ? true : false, row: indexPath.row, isMute: content.mute ?? false)
                } else {
                    print("audio not playing")
                    cell.setupCellBulletsView(article: content, isAudioPlay: false, row: indexPath.row, isMute: content.mute ?? false)
                }
                
                //cell.viewLikeCommentBG.theme_backgroundColor = GlobalPicker.textWBColor
                
                return cell
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_EXTENDED {

                //CARD VIEW DESIGN CELL- LARGE CELL
                guard let cardCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_CARD, for: indexPath) as? HomeCardCell else { return UITableViewCell() }
    

//                else {
                    
                    cardCell.viewDividerLine.isHidden = !SharedManager.shared.readerMode
                    cardCell.constraintContainerViewBottom.constant = 10
//                }
                
                
                cardCell.backgroundColor = UIColor.clear
                cardCell.setNeedsLayout()
                cardCell.layoutIfNeeded()
                cardCell.selectionStyle = .none
                cardCell.delegateHomeCard = self
                cardCell.delegateLikeComment = self
                cardCell.langCode = content.language ?? ""

                //LEFT - RIGHT ACTION
                cardCell.btnLeft.theme_tintColor = GlobalPicker.btnCellTintColor
                cardCell.btnRight.theme_tintColor = GlobalPicker.btnCellTintColor
                cardCell.constraintArcHeight.constant = cardCell.viewGestures.frame.size.height - 20
                
                cardCell.btnLeft.accessibilityIdentifier = String(indexPath.row)
                cardCell.btnRight.accessibilityIdentifier = String(indexPath.row)
                cardCell.btnLeft.addTarget(self, action: #selector(didTapScrollLeftRightCard(_:)), for: .touchUpInside)
                cardCell.btnRight.addTarget(self, action: #selector(didTapScrollLeftRightCard(_:)), for: .touchUpInside)

                // image Preloading logic
//                if articles.count > indexPath.row + 1 {
//
//                    let preContent = articles[indexPath.row + 1]
//                    cardCell.imgPreLoaded?.sd_setImage(with: URL(string: preContent.image ?? ""))
//                }
//                if articles.count > indexPath.row + 2 {
//
//                    let preContent = articles[indexPath.row + 2]
//                    cardCell.imgPreLoaded?.sd_setImage(with: URL(string: preContent.image ?? ""))
//                }
                
                let url = content.image ?? ""
                cardCell.imgBlurBG?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
                
                cardCell.imgBG.contentMode = .scaleAspectFill
                cardCell.imgBG.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"), completed: { (image, error, cacheType, imageURL) in
                    
                    if image == nil {
                        
                        cardCell.imgBG.accessibilityIdentifier = "image_placeholder"
                    }
                    else {
                        
                        cardCell.imgBG.accessibilityIdentifier = ""
                        cardCell.imgBG.contentMode = .scaleAspectFill
                        cardCell.imgBG.image = image
                    }
                })
                
                //BUTTON ACTIONs
//                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
//                tapGesture.view?.tag = indexPath.row
//                print("cardCell.viewGestures: ", indexPath.row)
//                cardCell.addGestureRecognizer(tapGesture)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
                tapGesture.view?.tag = indexPath.row
                cardCell.tag = indexPath.row

                cardCell.viewGestures.addGestureRecognizer(tapGesture)

//                cardCell.btnShare.tag = indexPath.row
                cardCell.btnSource.tag = indexPath.row
                cardCell.btnReport.tag = indexPath.row
                
//                cardCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
                cardCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)

                cardCell.btnReport.addTarget(self, action: #selector(didTapReport(button:)), for: .touchUpInside)
                
                
                //<---Pan Gestures
                let panLeft = PanDirectionGestureRecognizer(direction: .horizontal(.left), target: self, action: #selector(handlePanGesture(_:)))
                panLeft.view?.tag = indexPath.row
                panLeft.cancelsTouchesInView = false
                cardCell.viewGestures.addGestureRecognizer(panLeft)
                
                let panRight = PanDirectionGestureRecognizer(direction: .horizontal(.right), target: self, action: #selector(handlePanGesture(_:)))
                panRight.view?.tag = indexPath.row
                panRight.cancelsTouchesInView = false
                cardCell.viewGestures.addGestureRecognizer(panRight)
                
                //add UISwipeGestureRecognizer when selected cell is active
                let direction: [UISwipeGestureRecognizer.Direction] = [ .left, .right]
                for dir in direction {
                    let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeViewCard(_:)))
                    cardCell.viewGestures.addGestureRecognizer(swipeGesture)
                    swipeGesture.direction = dir
                    swipeGesture.view?.tag = indexPath.row
                    cardCell.viewGestures.isUserInteractionEnabled = true
                    cardCell.viewGestures.isMultipleTouchEnabled = false
                    
                    panLeft.require(toFail: swipeGesture)
                    panRight.require(toFail: swipeGesture)
                }

                //--->
                //cardCell.setupSlideScrollView(article: content, isAudioPlay: false, row: indexPath.row, isMute: true)
                if SharedManager.shared.viewSubCategoryIshidden {
                    print("audio playing")
                    cardCell.setupSlideScrollView(article: content, isAudioPlay: self.focussedIndexPath == indexPath.row ? true : false, row: indexPath.row, isMute: content.mute ?? false)
                } else {
                    print("audio not playing")
                    cardCell.setupSlideScrollView(article: content, isAudioPlay: false, row: indexPath.row, isMute: content.mute ?? false)
                }
                return cardCell
            }
            
            else if type == Constant.newsArticle.ARTICLE_TYPE_HEADER {

                //HEADER CELL
                guard let headerCell = tableView.dequeueReusableCell(withIdentifier: HEADER_HOME_CC, for: indexPath) as? HomeHeaderCC else { return UITableViewCell() }
                
//                headerCell.contentView.theme_backgroundColor = GlobalPicker.backgroundCardColor
//                headerCell.backgrView.theme_backgroundColor = GlobalPicker.backgroundColorWhiteBlack
                headerCell.selectionStyle = .none
                headerCell.lblTitle.text = content.title
                
                headerCell.lblSubheader.isHidden = content.subheader == "" || content.subheader == nil ? true : false
                headerCell.lblSubheader.text = content.subheader
                
                if let footer = content.footer {
                    
                    headerCell.imgArrow.isHidden = false
                    headerCell.btnReadMore.tag = indexPath.row
                    headerCell.btnReadMore.addTarget(self, action: #selector(didTapReadMoreForYouFooter(button:)), for: .touchUpInside)
                }
                else {
                    
                    headerCell.imgArrow.isHidden = true
                }
                headerCell.layoutIfNeeded()
                return headerCell
            }
            else {

                //FOOTER CELL
                guard let footerCell = tableView.dequeueReusableCell(withIdentifier: FOOTER_HOME_CC, for: indexPath) as? HomeFooterCC else { return UITableViewCell() }
                footerCell.selectionStyle = .none
             //   footerCell.viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor//GlobalPicker.backgroundColorEditions
                footerCell.setCell(content)
                footerCell.lblFooterName.text = content.footer?.title ?? ""
                footerCell.lblFooterName.addTextSpacing(spacing: 0.6)

                footerCell.lblPrefix.text = content.footer?.prefix ?? ""
                footerCell.lblPrefix.addTextSpacing(spacing: 0.6)

                let pType = articles[max(0, indexPath.row - 1)].type ?? ""
                if pType == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL || pType == Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS {
                    footerCell.viewPadding.theme_backgroundColor = GlobalPicker.textWBColor
                }

                //footerCell.lblFooter.text = content.title?.uppercased()
                //footerCell.lblFooter.addTextSpacing(spacing: 1.5)
                //footerCell.lblMore.addTextSpacing(spacing: 1.5)

                footerCell.btnReadMore.tag = indexPath.row
                footerCell.btnReadMore.addTarget(self, action: #selector(didTapReadMoreForYouFooter(button:)), for: .touchUpInside)
                return footerCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.articles.count > 0 && indexPath.row < self.articles.count {
            let content = self.articles[indexPath.row]
            let type = content.type ?? ""
            
            if type == Constant.newsArticle.ARTICLE_TYPE_HEADER {
                return 60
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_FOOTER {
                
                let pType = articles[max(0, indexPath.row - 1)].type ?? ""
                if pType == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL || pType == Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS {
                    return 80
                }
                return 60
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_ADS {
                return 200
            }
            else if type == Constant.newsArticle.FEED_ARTICLE_HORIZONTAL {
                if SharedManager.shared.readerMode {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        return 230
                    }
                    return 170
                }
                else {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        return 340
                    }
                    return 270
                }
            }
//            else if type == Constant.newsArticle.ARTICLE_TYPE_SIMPLE {
//                return HEIGHT_HOME_LISTVIEW
//            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL {
                return UIScreen.main.bounds.height * 0.75
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS {
                
                SharedManager.shared.homeVideoCarouselCCSize = CGSize(width: tableView.frame.size.width, height: 400)
                return SharedManager.shared.homeVideoCarouselCCSize.height
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_REELS {
                return COLLECTION_HEIGHT_REELS
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_CHANNELS {
                return UITableView.automaticDimension//COLLECTION_HEIGHT_REELS
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_TOPICS {
                return UITableView.automaticDimension//COLLECTION_HEIGHT_TOPICS
            }
            else {
                return UITableView.automaticDimension
            }
        } else {
            return UITableView.automaticDimension
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        if self.articles.count > 0 && indexPath.row < self.articles.count {
            let content = self.articles[indexPath.row]
            
            let type = content.type ?? ""
            if type == Constant.newsArticle.ARTICLE_TYPE_HEADER {
                return 60
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_FOOTER {
                return 60
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_ADS {
                return 200
            }
            else if type == Constant.newsArticle.FEED_ARTICLE_HORIZONTAL {
                
                if SharedManager.shared.readerMode {
                    return 170
                }
                else {
                    return 270
                }
            }
//            else if type == Constant.newsArticle.ARTICLE_TYPE_SIMPLE {
//                return HEIGHT_HOME_LISTVIEW
//            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL {
                return UIScreen.main.bounds.height * 0.75
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS {
                
                SharedManager.shared.homeVideoCarouselCCSize = CGSize(width: tableView.frame.size.width, height: 400)
                return SharedManager.shared.homeVideoCarouselCCSize.height
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_REELS {
                return COLLECTION_HEIGHT_REELS
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_CHANNELS {
                return UITableView.automaticDimension//COLLECTION_HEIGHT_REELS
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_TOPICS {
                return UITableView.automaticDimension//COLLECTION_HEIGHT_TOPICS
            }
            else if type == Constant.newsArticle.ARTICLE_TYPE_SIMPLE {
                return cellHeights[indexPath] ?? UITableView.automaticDimension
            }
            else {
                return cellHeights[indexPath] ?? UITableView.automaticDimension
                //return 500
            }
        } else {
            return UITableView.automaticDimension
        }
    }
            
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //print("indexPath:...", indexPath.row)
        if let cell = cell as? VideoPlayerVieww {
//            cell.resetVisibleVideoPlayer()
            resetPlayerAtIndex(cell: cell)
        }

        else if let cell = cell as? YoutubeCardCell {
            cell.resetYoutubeCard()
        }
        
        //RESET HERO VIEW CC
        if let hCell = cell as? HomeHeroCC {
            
            resetHeroPlayerAtIndex(cell: hCell)
            hCell.resetYoutubeCard()

        }
        
        if let reelCell = cell as? HomeReelCarouselCC {
           
            reelCell.pauseAllCurrentlyFocusedMedia()
        }
        
        if let cell = cell as? HomeVideoCarouselCC {

            cell.pauseAllCurrentlyFocusedMedia()
        }
    }
    
    func focusedIndex(index: Int) {
        
        //EXTENDED/LIST VIEW TAP TO PLAY YOUTUBE
        updateProgressbarStatus(isPause: true)
        
        self.setupIndexPathForSelectedArticleCardAndListView(index)

        if let vCell = self.tblExtendedView.cellForRow(at: IndexPath(row: self.focussedIndexPath, section: 0)) as? VideoPlayerVieww {
//            vCell.playVideo(isPause: true)
            playVideoOnFocus(cell: vCell, isPause: true)
        }
    }
    
    @objc func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        
        if let gesture = pan as? PanDirectionGestureRecognizer {
            
            switch gesture.state {
            case .began:
                break
            case .changed:
                break
            case .ended,
                 .cancelled:
                break
            default:
                break
            }
        }
    }
    
    @objc func swipeViewCard(_ sender: UISwipeGestureRecognizer) {
        
        if UserDefaults.standard.bool(forKey: Constant.UD_isHapticOn) {
            
            if #available(iOS 13.0, *) {
                generator = UIImpactFeedbackGenerator(style: .soft)
            } else {
                
                generator = UIImpactFeedbackGenerator(style: .heavy)
            }
            generator.impactOccurred()
        }
        
        let pausePlayAudioCard = { (cell: HomeCardCell) in
            
            SharedManager.shared.isUserinteractWithHeadlinesOnly = true
            cell.isAutoScrolling = false
            SharedManager.shared.bulletPlayer?.pause()
            SharedManager.shared.bulletPlayer?.stop()
        }
        
        let setProgressBarSelectedCardCell = { (cell: HomeCardCell, bullets: [Bullets]) in
            
            pausePlayAudioCard(cell)
            
            if SharedManager.shared.isSelectedLanguageRTL() {
                // Arabic
                if sender.direction == .right {
                    cell.swipeLeftFocusedCell(bullets: bullets)
                }
                else if sender.direction == .left {
                    cell.swipeRightFocusedCell(bullets: bullets, tag: self.focussedIndexPath)
                }
            } else {
                if sender.direction == .right {
                    cell.swipeRightFocusedCell(bullets: bullets, tag: self.focussedIndexPath)
                }
                else if sender.direction == .left {
                    cell.swipeLeftFocusedCell(bullets: bullets)
                }
            }
        }
        
        let row = sender.view?.tag ?? 0
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: row, section: 0)) as? HomeCardCell {
            
            let content = self.articles[row]
            if let bullets = content.bullets {
                
                if row == focussedIndexPath {
                    setProgressBarSelectedCardCell(cell, bullets)
                    return
                }
                
                // For unselected cell
                self.resetCurrentFocussedCell()
                forceSelectedIndexPath = IndexPath(row: row, section: 0)
                focussedIndexPath = row

                pausePlayAudioCard(cell)
                
                if SharedManager.shared.isSelectedLanguageRTL() {
                    // Arabic
                    if sender.direction == .right {
                        cell.swipeLeftNormalCell(bullets: bullets)
                    }
                    else if sender.direction == .left {
                        cell.swipeRightNormalCell(bullets: bullets)
                    }
                } else {
                    if sender.direction == .right {
                        
                        cell.swipeRightNormalCell(bullets: bullets)
                    }
                    else if sender.direction == .left {
                        
                        cell.swipeLeftNormalCell(bullets: bullets)
                    }
                }

            }
        }
    }
    
    //MARK:- UISwipeGesture Recognizer for left/right
    @objc func swipeViewList(_ sender:UISwipeGestureRecognizer) {
        
        if UserDefaults.standard.bool(forKey: Constant.UD_isHapticOn) {
            
            if #available(iOS 13.0, *) {
                generator = UIImpactFeedbackGenerator(style: .soft)
            } else {
                
                generator = UIImpactFeedbackGenerator(style: .heavy)
            }
            generator.impactOccurred()
        }
        
        let pausePlayAudio = { (cell: HomeListViewCC) in
            
            SharedManager.shared.isUserinteractWithHeadlinesOnly = true
            cell.isAutoScrolling = false
            print("print 4...")
            SharedManager.shared.bulletPlayer?.pause()
            SharedManager.shared.bulletPlayer?.stop()
        }
        
        let setProgressBarSelectedCell = { (cell: HomeListViewCC) in

            pausePlayAudio(cell)

            if SharedManager.shared.isSelectedLanguageRTL() {
                if sender.direction == .right {
                    
                    cell.swipeLeftCurrentlyFocusedCell()
                }
                else if sender.direction == .left {
                    
                    cell.swipeRightCurrentlyFocusedCell(self.focussedIndexPath)
                }
            } else {
                if sender.direction == .right {
                    
                    cell.swipeRightCurrentlyFocusedCell(self.focussedIndexPath)
                }
                else if sender.direction == .left {
                    
                    cell.swipeLeftCurrentlyFocusedCell()
                }
            }
        }
        
        let row = sender.view?.tag ?? 0
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: row, section: 0)) as? HomeListViewCC {
            
            // For selected item , currently playing cell
            if row == focussedIndexPath {

                setProgressBarSelectedCell(cell)
                return
            }
            
            // For unselected cell
            self.resetCurrentFocussedCell()
            forceSelectedIndexPath = IndexPath(row: row, section: 0)
            focussedIndexPath = row
            
            pausePlayAudio(cell)
            
            if SharedManager.shared.isSelectedLanguageRTL() {
                
                if sender.direction == .right {
                    
                    cell.swipeLeftUserSelectedCell()
                }
                else if sender.direction == .left {
                    
                    cell.swipeRightUserSelectedCell()
                }
            } else {
                
                if sender.direction == .right {
                    
                    cell.swipeRightUserSelectedCell()
                }
                else if sender.direction == .left {
                    
                    cell.swipeLeftUserSelectedCell()
                }
            }
        }
    }
    
    @objc func didTapScrollLeftRightCard(_ sender: UIButton) {
        
        if UserDefaults.standard.bool(forKey: Constant.UD_isHapticOn) {
            
            if #available(iOS 13.0, *) {
                generator = UIImpactFeedbackGenerator(style: .soft)
            } else {
                
                generator = UIImpactFeedbackGenerator(style: .heavy)
            }
            generator.impactOccurred()
        }
        
        let pausePlayAudio = { (cell: HomeCardCell) in
            
            SharedManager.shared.isUserinteractWithHeadlinesOnly = true
            cell.isAutoScrolling = false
            print("print 4...")
            SharedManager.shared.bulletPlayer?.pause()
            SharedManager.shared.bulletPlayer?.stop()
        }
        
        
        let index = Int(sender.accessibilityIdentifier ?? "0") ?? 0

        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeCardCell {
            
            cell.constraintArcHeight.constant = cell.viewGestures.frame.size.height - 20

            //let content = self.articles[index]
            if cell.bullets?.count ?? 0 <= 0 { return }
            
            SharedManager.shared.isManualScrolling = true
                        
            if index == focussedIndexPath {
                
                //focus cell
                pausePlayAudio(cell)
                
                if sender.tag == 0 {
                    
                    //LEFT
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articles[focussedIndexPath].id ?? "")
                    cell.btnLeft.pulsate()
                    cell.btnLeft.setImage(UIImage(named: "leftArc"), for: .normal)
                    cell.imgPrevious.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                        cell.btnLeft.setImage(UIImage(named: ""), for: .normal)
                        cell.imgPrevious.isHidden = true
                    }
                    
                    if cell.currPage > 0 {
                        
                        if cell.currPage < cell.bullets?.count ?? 0 {
                            
                            cell.currPage -= 1
                            SharedManager.shared.segementIndex = cell.currPage
                            cell.scrollToItemBullet(at: cell.currPage, animated: true)
                            cell.playAudio()
                            //SharedManager.shared.spbCardView?.rewind()
                        }
                        else {
                            
                            cell.restartProgressbar()
                        }
                    }
                    else {
                        
//                        if focussedIndexPath > 0 {
//
//                            SharedManager.shared.bulletsMaxCount = 0
//                            cell.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: false)
//                        }
//                        else {
//                            cell.restartProgressbar()
//                        }
                    }
                }
                else {
                    
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articles[focussedIndexPath].id ?? "")
                    cell.btnRight.setImage(UIImage(named: "rightArc"), for: .normal)
                    cell.btnRight.pulsate()
                    cell.imgNext.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                        cell.btnRight.setImage(UIImage(named: ""), for: .normal)
                        cell.imgNext.isHidden = true
                    }
                    
                    if cell.currPage < (cell.bullets?.count ?? 0) - 1 {
                        
                        cell.currPage += 1
                        SharedManager.shared.segementIndex = cell.currPage
                        cell.scrollToItemBullet(at: cell.currPage, animated: true)
                        cell.playAudio()
                        //SharedManager.shared.spbCardView?.skip()
                    }
                    else {
                        
                        //self.restartProgressbar()
                        
                        //SharedManager.shared.bulletsMaxCount = 0
                        //cell.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
                    }
                }
            }
            else {
                
                //unfocussed cell selected
                self.resetCurrentFocussedCell()
                forceSelectedIndexPath = IndexPath(row: index, section: 0)
                focussedIndexPath = index

                pausePlayAudio(cell)

                if let bullets = cell.bullets {
                    
                    if sender.tag == 0 {
                        
                        //LEFT
                        cell.btnLeft.pulsate()
                        cell.btnLeft.setImage(UIImage(named: "leftArc"), for: .normal)
                        cell.imgPrevious.isHidden = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            
                            cell.btnLeft.setImage(UIImage(named: ""), for: .normal)
                            cell.imgPrevious.isHidden = true
                        }
                        
                        if cell.currMutedPage < bullets.count {
                            
//                            cell.currMutedPage -= 1
//                            cell.scrollToItemBullet(at: cell.currMutedPage, animated: true)
                            cell.swipeRightNormalCell(bullets: bullets)

//                            self.setSelectedCellAndPlay(index: index, indexPath: forceSelectedIndexPath!)

                        }
                        //  self.animateImageView(isFromRight: false)
                    }
                    else {
                        
                        cell.btnRight.setImage(UIImage(named: "rightArc"), for: .normal)
                        cell.btnRight.pulsate()
                        cell.imgNext.isHidden = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            
                            cell.btnRight.setImage(UIImage(named: ""), for: .normal)
                            cell.imgNext.isHidden = true
                        }
                        if cell.currMutedPage < bullets.count - 1 {
                            
//                            cell.currMutedPage += 1
//                            cell.scrollToItemBullet(at: cell.currMutedPage, animated: true)
                            cell.swipeLeftNormalCell(bullets: bullets)
                        }
                        //   self.animateImageView(isFromRight: true)
                    }
                }
            }
        }
    }
    
    @objc func didTapScrollBulletsList(_ sender: UIButton) {
        
        if UserDefaults.standard.bool(forKey: Constant.UD_isHapticOn) {
            
            if #available(iOS 13.0, *) {
                generator = UIImpactFeedbackGenerator(style: .soft)
            } else {
                
                generator = UIImpactFeedbackGenerator(style: .heavy)
            }
            generator.impactOccurred()
        }
        
        let pausePlayAudio = { (cell: HomeListViewCC) in
            
            SharedManager.shared.isUserinteractWithHeadlinesOnly = true
            cell.isAutoScrolling = false
            print("print 7...")
            SharedManager.shared.bulletPlayer?.pause()
            SharedManager.shared.bulletPlayer?.stop()
        }
        
        let index = Int(sender.accessibilityIdentifier ?? "0") ?? 0
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeListViewCC {
         
            if cell.bullets.count <= 0 { return }
            
            if index == focussedIndexPath {
                
                //focus cell
                pausePlayAudio(cell)
                
                if sender.tag == 0 {
                    
                    //LEFT
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articles[focussedIndexPath].id ?? "")
                    cell.btnLeft.pulsate()
                    cell.btnLeft.setImage(UIImage(named: "leftArc"), for: .normal)
                    cell.imgPrevious.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                        cell.btnLeft.setImage(UIImage(named: ""), for: .normal)
                        cell.imgPrevious.isHidden = true
                    }
                    
                    if cell.currPage > 0 {
                        
                        if cell.currPage < cell.bullets.count {
                            
                            cell.currPage -= 1
                            SharedManager.shared.segementIndex = cell.currPage
                            cell.scrollToItemBullet(at: cell.currPage, animated: true)
                            cell.playAudio()
                            //SharedManager.shared.spbCardView?.rewind()
                        }
                        else {
                            
                            cell.restartProgressbar()
                        }
                    }
                    else {
//                        if focussedIndexPath > 0 {
//                            cell.delegateHomeListCC?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: false)
//                        }
//                        else {
//                            cell.restartProgressbar()
//                        }
                    }
                    //cell.animateImageView(isFromRight: false)
                }
                else {
                    
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articles[focussedIndexPath].id ?? "")
                    cell.btnRight.setImage(UIImage(named: "rightArc"), for: .normal)
                    cell.btnRight.pulsate()
                    cell.imgNext.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                        cell.btnRight.setImage(UIImage(named: ""), for: .normal)
                        cell.imgNext.isHidden = true
                    }
                    
                    if cell.currPage < cell.bullets.count - 1 {
                        
                        cell.currPage += 1
                        SharedManager.shared.segementIndex = cell.currPage
                        cell.scrollToItemBullet(at: cell.currPage, animated: true)
                        cell.playAudio()
                        //SharedManager.shared.spbCardView?.skip()
                    }
                    else {
                        
                        //self.restartProgressbar()
//                        cell.delegateHomeListCC?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
                    }
                    //cell.animateImageView(isFromRight: true)
                }
            }
            else {
                
                //unfocussed cell selected
                pausePlayAudio(cell)
                
                self.resetCurrentFocussedCell()
                forceSelectedIndexPath = IndexPath(row: index, section: 0)
                focussedIndexPath = index

                if sender.tag == 0 {
                    
                    //LEFT
                    cell.btnLeft.pulsate()
                    cell.btnLeft.setImage(UIImage(named: "leftArc"), for: .normal)
                    cell.imgPrevious.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                        cell.btnLeft.setImage(UIImage(named: ""), for: .normal)
                        cell.imgPrevious.isHidden = true
                    }
                    if cell.currMutedPage < cell.bullets.count {
                        
//                        cell.currMutedPage -= 1
//                        cell.scrollToItemBullet(at: cell.currMutedPage, animated: true)
                        cell.swipeRightUserSelectedCell()
                    }
                    //cell.animateImageView(isFromRight: false)
                }
                else {
                    
                    cell.btnRight.setImage(UIImage(named: "rightArc"), for: .normal)
                    cell.btnRight.pulsate()
                    cell.imgNext.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                        cell.btnRight.setImage(UIImage(named: ""), for: .normal)
                        cell.imgNext.isHidden = true
                    }
                    
                    if cell.currMutedPage < cell.bullets.count - 1 {
                        
//                        cell.currMutedPage += 1
//                        cell.scrollToItemBullet(at: cell.currMutedPage, animated: true)
                        cell.swipeLeftUserSelectedCell()
                    }
                    //cell.animateImageView(isFromRight: true)
                }
            }
        }
    }
}


//MARK:- SCROLL VIEW DELEGATE
extension HomeVC: UIScrollViewDelegate, UICollectionViewDelegate {
        
    
    func isTopAndBottomAnimationRequired() -> Bool {
        
        //tblExtendedView.layoutIfNeeded()
        if tblExtendedView.contentSize.height > (tblExtendedView.frame.size.height + 200)  {
            return true
        } else {
            return false
        }
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Disable tableview bounce ath bottom
        if scrollView.contentOffset.y < 50 {
            scrollView.bounces = true
            scrollView.bouncesZoom = true
        }
        else {
            scrollView.bounces = false
            scrollView.bouncesZoom = false
        }
        
        // Added due to crash
        DispatchQueue.main.async {
            
            if self.isTopAndBottomAnimationRequired() {
                let delta = scrollView.contentOffset.y - self.lastContentOffset

//                let scrollViewHeight = scrollView.frame.size.height
//                let scrollContentSizeHeight = scrollView.contentSize.height
//                if (scrollView.contentOffset.y + 1 + scrollViewHeight >= scrollContentSizeHeight) {
//                    //print("scroll view reached bottom")
//                    self.isDirectionFindingNeeded = true
//                }
                
                
                if !self.isDirectionFindingNeeded {
                        
                    if self.lastContentOffset > 50 &&  abs(self.lastContentOffset - scrollView.contentOffset.y) > 20 {
                        if delta < 0 {

                            self.showTopAndBottomBar(animated: true)
                        } else {

                            self.hideTopAndBottomBar(animated: true)
                        }
                        
                        self.lastContentOffset = scrollView.contentOffset.y
                    } else if scrollView.contentOffset.y < 100 {
                        self.showTopAndBottomBar(animated: true)
                        
                        self.lastContentOffset = scrollView.contentOffset.y
                    }
                    
                }
                
                

            } else {
                if self.tableViewTopConstraint.constant != self.normalTableViewTopConstraint {
                    self.showTopAndBottomBar(animated: true)
                }
            }
                    

        }
    }
    
    func showBottomTabWhenTopVisible() {
        
        if self.tableViewTopConstraint.constant != self.normalTableViewTopConstraint {
            if let ptcTBC = tabBarController as? PTCardTabBarController {
                if ptcTBC.additionalSafeAreaInsets == .zero {
                    ptcTBC.showTabBar(false, animated: false)
                }
            }
        }
        else {
            if let ptcTBC = tabBarController as? PTCardTabBarController {
                if ptcTBC.additionalSafeAreaInsets != .zero {
                    ptcTBC.showTabBar(true, animated: false)
                }
            }
        }
    }
    
    func showTopAndBottomBar(animated: Bool) {
        
        if self.showArticleType == .places || self.showArticleType == .topic { return }
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            if ptcTBC.additionalSafeAreaInsets == .zero {
                ptcTBC.showTabBar(true, animated: animated)
            }
        }
        
        if self.tableViewTopConstraint.constant != self.normalTableViewTopConstraint {
            if animated {
                UIView.animate(withDuration: 0.25) {
                    self.tableViewTopConstraint.constant = self.normalTableViewTopConstraint
                }
            }
            else {
                self.tableViewTopConstraint.constant = self.normalTableViewTopConstraint
            }
            self.delegate?.homeScrollViewDidScroll(delta: -1, animated: animated)
            self.scrollDelegate?.homeScrollViewDidScroll(delta: -1)
        }
        
        
        
        
    }
    
    func hideTopAndBottomBar(animated: Bool) {

        if let ptcTBC = tabBarController as? PTCardTabBarController {
            if ptcTBC.additionalSafeAreaInsets != .zero {
                ptcTBC.showTabBar(false, animated: animated)
            }
        }
        
        if self.tableViewTopConstraint.constant != self.extendedTableViewTopConstraint {
           
            if animated {
                UIView.animate(withDuration: 0.25) {
                    self.tableViewTopConstraint.constant = self.extendedTableViewTopConstraint
                }
            }
            else {
                self.tableViewTopConstraint.constant = self.extendedTableViewTopConstraint
            }
            self.delegate?.homeScrollViewDidScroll(delta: 1, animated: animated)
            self.scrollDelegate?.homeScrollViewDidScroll(delta: 1)
        }
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        lastContentOffset = scrollView.contentOffset.y
//        //print("lastContentOffset", lastContentOffset)
        isDirectionFindingNeeded = false

        ////print("scrollViewWillBeginDragging")
        if !isPullToRefresh {
            updateProgressbarStatus(isPause: true)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {

        ////print("scrollViewWillBeginDecelerating")
        if !isPullToRefresh {
            updateProgressbarStatus(isPause: true)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
//        if scrollView.contentOffset.y <= -160 {
//            scrollView.setContentOffset(CGPoint(x: 0, y: -160), animated: false)
//        }
        print("scrollViewDidEndDragging called")
        //ScrollView for ListView Mode
        if decelerate { return }
        if !isPullToRefresh {
            //updateProgressbarStatus(isPause: isViewPresenting ? true : false)
            if !isViewPresenting {
                updateProgressbarStatus(isPause: true)
            }
            else {
                updateProgressbarStatus(isPause: false)
            }
            scrollToTopVisibleExtended()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //ScrollView for ListView Mode
        print("scrollViewDidEndDecelerating called")
        if !isPullToRefresh {

            if !isViewPresenting {
                updateProgressbarStatus(isPause: true)
            }
            else {
                updateProgressbarStatus(isPause: false)
            }
            //updateProgressbarStatus(isPause: isViewPresenting ? true : false)
            scrollToTopVisibleExtended()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.994000); //0.998000
    }

    func scrollToTopVisibleExtended(viewWillAppear: Bool = false) {
        
        // set hight light to a new first or center cell
        //SharedManager.shared.clearProgressBar()
        var isVisible = false
        var indexPathVisible:  IndexPath?
        for indexPath in tblExtendedView.indexPathsForVisibleRows ?? [] {
            let cellRect = tblExtendedView.rectForRow(at: indexPath)
            isVisible = tblExtendedView.bounds.contains(cellRect)
            if isVisible {
                //print("indexPath is Visible")
                indexPathVisible = indexPath
                break
            }
        }
        
        if isVisible == false {
            //print("indexPath not Visible")
            let center = self.view.convert(tblExtendedView.center, to: tblExtendedView)
            indexPathVisible = tblExtendedView.indexPathForRow(at: center)
        }
        
//        if let visibleRows = tblExtendedView.indexPathsForVisibleRows, let focusIdx = forceSelectedIndexPath {
//
//            if visibleRows.contains(focusIdx) {
//                print("not same focussed cell...")
//                updateProgressbarStatus(isPause: false)
//                return
//            }
//        }
        
        
        if viewWillAppear {
            
            //Set Selected index into focus variables
            if let indexPath = indexPathVisible {
                
                self.setupIndexPathForSelectedArticleCardAndListView(indexPath.row)
            }
        }
        
        if var indexPath = indexPathVisible, indexPath.row != getIndexPathForSelectedArticleCardAndListView() {
            
            var index = indexPath.row
            
            //Reset cell
            self.resetCurrentFocussedCell()
            
            //For Skip header and footer cell
            if index < self.articles.count && index != self.articles.count - 1 {
                
                let content = self.articles[index]
                if content.type == Constant.newsArticle.ARTICLE_TYPE_HEADER || content.type == Constant.newsArticle.ARTICLE_TYPE_FOOTER || content.type == Constant.newsArticle.ARTICLE_TYPE_ADS {
                    index += 1
                    
                    if index < self.articles.count {
                        let content = self.articles[index]
                        if content.type == Constant.newsArticle.ARTICLE_TYPE_HEADER || content.type == Constant.newsArticle.ARTICLE_TYPE_FOOTER || content.type == Constant.newsArticle.ARTICLE_TYPE_ADS {
                            index += 1
                        }
                    }
                    
                    if index < self.articles.count {
                        let content = self.articles[index]
                        if content.type == Constant.newsArticle.ARTICLE_TYPE_HEADER || content.type == Constant.newsArticle.ARTICLE_TYPE_FOOTER || content.type == Constant.newsArticle.ARTICLE_TYPE_ADS {
                            index += 1
                        }
                    }
                    indexPath = IndexPath(row: index, section: indexPath.section)
                }
            }
            
            //Set Selected index into focus variables
            focussedIndexPath = index

            //set selected cell
            self.setSelectedCellAndPlay(index: index, indexPath: indexPath)
        }
        else {
            
            if isVisible {
                
                if let videoCell = self.getCurrentFocussedCell() as? VideoPlayerVieww {
                    
                    playVideoOnFocus(cell: videoCell, isPause: false)
                }
                else if let homeHero = self.getCurrentFocussedCell() as? HomeHeroCC {
                    
                    if homeHero.viewVideo.isHidden == false {
                     
                        playHeroVideoOnFocus(cell: homeHero, isPause: false)
                    }
                    else if homeHero.viewYoutubeBG.isHidden == false {
                     
                        homeHero.setFocussedYoutubeView()
                    }
                }
                else if let yCell = self.getCurrentFocussedCell() as? YoutubeCardCell {
         
                    yCell.setFocussedYoutubeView()
                }
                else if let reelCell = self.getCurrentFocussedCell() as? HomeReelCarouselCC {
                    
                    reelCell.playCurrentlyFocusedMedia()
                }
                else if let cell = self.getCurrentFocussedCell() as? HomeVideoCarouselCC {

                    cell.playCurrentlyFocusedMedia()
                }
                else {
                    if let yCell = self.curYoutubeVisibleCell {

                        
                        yCell.resetYoutubeCard()
                    }
                }
            }
            else {
                
                if let yCell = self.curYoutubeVisibleCell {
                    
                    yCell.resetYoutubeCard()
                }
                
                else if let homeHero = self.getCurrentFocussedCell() as? HomeHeroCC {
                    
                    if homeHero.viewVideo.isHidden == false {
                     
                        playHeroVideoOnFocus(cell: homeHero, isPause: true)
                    }
                    else if homeHero.viewYoutubeBG.isHidden == false {
                     
                        homeHero.resetYoutubeCard()
                    }
                }
            }

        }
    }
    
    func fullyVisibleCells(_ inCollectionView: UICollectionView) -> [IndexPath] {

        var returnCells = [IndexPath]()

        var vCells = inCollectionView.visibleCells
        vCells = vCells.filter({ cell -> Bool in
            let cellRect = inCollectionView.convert(cell.frame, to: inCollectionView.superview)
            return inCollectionView.frame.contains(cellRect)
        })

        vCells.forEach({
            if let pth = inCollectionView.indexPath(for: $0) {
                returnCells.append(pth)
            }
        })

        return returnCells.sorted()
    }
    
    func resetCurrentFocussedCell() {
        
        //this func tells to set index for visible article focus
        //RESET CURRENT PLAYING CARD CELL WHEN SHOW YOUTUBE
        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
            
            cell.pauseAudioAndProgress(isPause: true)
            cell.resetVisibleCard()
        }
        
        //RESET CURRENT PLAYING LIST SMALL CELL WHEN SHOW YOUTUBE
        //Reset Home List View
        if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
            cell.pauseAudioAndProgress(isPause: true)
            cell.resetVisibleListCell()
        }
        
        //RESET CURRENT PLAYING YOUTUBE CELL
        //Reset Home Youtube View
        if let yCell = self.getCurrentFocussedCell() as? YoutubeCardCell {
            yCell.resetYoutubeCard()
        }
        
        //Reset Home Card View
        if let vCell = self.getCurrentFocussedCell() as? VideoPlayerVieww {
//            vCell.resetVisibleVideoPlayer()
            resetPlayerAtIndex(cell: vCell)
        }
        
        if let hCell = self.getCurrentFocussedCell() as? HomeHeroCC {
            
            if let indexPath = tblExtendedView.indexPath(for: hCell) {
                let subtype = articles[indexPath.row].subType ?? ""
                if subtype.uppercased() == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                    resetHeroPlayerAtIndex(cell: hCell)
                }
                else if subtype.uppercased() == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                    hCell.resetYoutubeCard()
                }
            }

        }
        
        if let cell = self.getCurrentFocussedCell() as? HomeReelCarouselCC {
           
            cell.pauseAllCurrentlyFocusedMedia()
        }
        
        if let cell = self.getCurrentFocussedCell() as? HomeVideoCarouselCC {

            cell.pauseAllCurrentlyFocusedMedia()
        }
    }
    
    func setSelectedCellAndPlay(index: Int, indexPath: IndexPath) {
        
        //Set Selected index into focus variables
        self.setupIndexPathForSelectedArticleCardAndListView(index)
        
        //ASSIGN CELL FOR CARD VIEW
        if let cell = tblExtendedView.cellForRow(at: indexPath) as? HomeCardCell {
            
            if self.prefetchState == .idle && articles.count > 0 {
                
                if !self.isPullToRefresh {
                    
                    // Play audio only when vc is visible
                    if isViewPresenting {

                        
                        let content = self.articles[index]
                        cell.setupSlideScrollView(article: content, isAudioPlay: true, row: index, isMute: content.mute ?? true)
                        //print("audio playing")
                    } else {
                        //print("audio playing skipped")
                    }
                    
                }
            }
        }
        else if let cell = tblExtendedView.cellForRow(at: indexPath) as? HomeListViewCC {
            
            //ASSIGN CELL FOR LSIT VIEW
            if self.prefetchState == .idle && articles.count > 0 {
                
                if !self.isPullToRefresh {
                    
                    // Play audio only when vc is visible
                    if isViewPresenting {

                        let content = self.articles[index]
                        cell.setupCellBulletsView(article: content, isAudioPlay: true, row: index, isMute: content.mute ?? true)
                        print("audio playing 6")
                    } else {
                        print("audio playing skipped")
                    }
                }
            }
        }
        else if let hCell = tblExtendedView.cellForRow(at: indexPath) as? HomeHeroCC {
            
            let content = self.articles[index]
            let subType = content.subType ?? ""
            
            if subType == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                
                hCell.url = content.link ?? ""
                hCell.setFocussedYoutubeView()

            }
            else if subType == Constant.newsArticle.ARTICLE_TYPE_VIDEO {

                playHeroVideoOnFocus(cell: hCell, isPause: false)
            }
        }
        else if let yCell = tblExtendedView.cellForRow(at: indexPath) as? YoutubeCardCell {
            
            let content = self.articles[index]
            if let bullets = content.bullets {
                
                self.curYoutubeVisibleCell = yCell
                yCell.url = content.link ?? ""
                yCell.setFocussedYoutubeView()
            }
        }
        else if let vCell = tblExtendedView.cellForRow(at: indexPath) as? VideoPlayerVieww {
            
            let content = self.articles[index]
            if let bullets = content.bullets {
                
                self.curVideoVisibleCell = vCell
                
                //   vCell.playVideo(isPause: false)
//                vCell.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: self.focussedIndexPath == indexPath.row ? true : false)
                
                playVideoOnFocus(cell: vCell, isPause: false)
            }
        }
        else if let reelCell = tblExtendedView.cellForRow(at: indexPath) as? HomeReelCarouselCC {
            
            reelCell.playCurrentlyFocusedMedia()
        }
        else if let cell = self.tblExtendedView.cellForRow(at: indexPath) as? HomeVideoCarouselCC {

            cell.playCurrentlyFocusedMedia()
        }
    }
}

// MARK: - Comment Loike Delegates
extension HomeVC: LikeCommentDelegate {
    
    func didTapCommentsButtonCollectionView(cell: UITableViewCell) {
    }
    
    func didTapLikeButtonCollectionView(cell: UITableViewCell) {
    }
    
    func didTapCommentsButton(cell: UITableViewCell) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {return}
        let content = self.articles[indexPath.row]
        
        updateProgressbarStatus(isPause: true)
        
        let vc = CommentsVC.instantiate(fromAppStoryboard: .Home)
        vc.delegate = self
        vc.articleID = content.id ?? ""
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        navVC.modalPresentationStyle = .overFullScreen
        self.present(navVC, animated: true, completion: nil)
        
        self.delegateBulletDetails?.commentUpdated(articleID: content.id ?? "", count: content.info?.commentCount ?? 0)
        
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.feedComment, article_id: content.id ?? "")

        
    }
    
    func didTapLikeButton(cell: UITableViewCell) {
        
        if isLikeApiRunning {
            return
        }
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {return}
        
        var likeCount = self.articles[indexPath.row].info?.likeCount
        if (self.articles[indexPath.row].info?.isLiked ?? false) {
            likeCount = (likeCount ?? 0) - 1
        } else {
            likeCount = (likeCount ?? 0) + 1
        }
        let info = Info(viewCount: self.articles[indexPath.row].info?.viewCount, likeCount: likeCount, commentCount: self.articles[indexPath.row].info?.commentCount, isLiked: !(self.articles[indexPath.row].info?.isLiked ?? false), socialLike: self.articles[indexPath.row].info?.socialLike)
        self.articles[indexPath.row].info = info
        (cell as? HomeListViewCC)?.setLikeComment(model: self.articles[indexPath.row].info)
        (cell as? HomeCardCell)?.setLikeComment(model: self.articles[indexPath.row].info)
        (cell as? YoutubeCardCell)?.setLikeComment(model: self.articles[indexPath.row].info)
        (cell as? VideoPlayerVieww)?.setLikeComment(model: self.articles[indexPath.row].info)

        isLikeApiRunning = true
        self.homeViewModel.performWSToLikePost(article_id: self.articles[indexPath.row].id ?? "", isLike: self.articles[indexPath.row].info?.isLiked ?? false)
        
        
        self.delegateBulletDetails?.likeUpdated(articleID: self.articles[indexPath.row].id ?? "", isLiked: self.articles[indexPath.row].info?.isLiked ?? false, count: likeCount ?? 0)
        
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.feed_like, article_id: self.articles[indexPath.row].id ?? "")
        
    }
    
}



extension HomeVC: BulletDetailsVCLikeDelegate {
    
    func likeUpdated(articleID: String, isLiked: Bool, count: Int) {
        
        if let index = self.articles.firstIndex(where: { $0.id == articleID }) {
            self.articles[index].info?.isLiked = isLiked
            self.articles[index].info?.likeCount = count
            let cell = tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0))
            
            (cell as? HomeListViewCC)?.setLikeComment(model: self.articles[index].info)
            (cell as? HomeCardCell)?.setLikeComment(model: self.articles[index].info)
            (cell as? YoutubeCardCell)?.setLikeComment(model: self.articles[index].info)
            (cell as? VideoPlayerVieww)?.setLikeComment(model: self.articles[index].info)
        }
        
    }
    
    func commentUpdated(articleID: String, count: Int) {
    }
    func backButtonPressed(isVideoPlaying: Bool) {  }
}


extension HomeVC: CommentsVCDelegate {
    func guestUser() {
        let vc = RegistrationNewVC.instantiate(fromAppStoryboard: .RegistrationSB)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navVC, animated: true, completion: nil)
    }
    func commentsVCDismissed(articleID: String) {
        self.updateProgressbarStatus(isPause: false)
        
        
        SharedManager.shared.performWSToGetCommentsCount(id: articleID) { info in
            if info != nil {
                
                if let selectedIndex = self.articles.firstIndex(where: { $0.id == articleID }) {
//                    self.articles[selectedIndex].info = info
                    self.articles[selectedIndex].info?.commentCount = info?.commentCount ?? 0
                    
                    if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) {
                        (cell as? HomeListViewCC)?.setLikeComment(model: self.articles[selectedIndex].info)
                        (cell as? HomeCardCell)?.setLikeComment(model: self.articles[selectedIndex].info)
                        (cell as? YoutubeCardCell)?.setLikeComment(model: self.articles[selectedIndex].info)
                        (cell as? VideoPlayerVieww)?.setLikeComment(model: self.articles[selectedIndex].info)
                    }
                    
                }
            }
        }
        
        
    }
}


// MARK: - Ads
// Google Ads
extension HomeVC: GADUnifiedNativeAdLoaderDelegate {
    
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
        self.googleNativeAd = nil
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        
        //print("Ad loader came with results")
        print("Received native ad: \(nativeAd)")
        self.googleNativeAd = nativeAd
        
        DispatchQueue.main.async {
            let visibleCells = self.tblExtendedView.visibleCells
            
            for cell in visibleCells {
                
                if let cell = cell as? HomeListAdsCC {
                    cell.loadGoogleAd(nativeAd: self.googleNativeAd!)
                }
            }
        }
    }
}

// Facebook Ads
extension HomeVC: FBNativeAdDelegate {
    
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        
        // 1. If there is an existing valid native ad, unregister the view
        if let previousNativeAd = self.fbnNativeAd, previousNativeAd.isAdValid {
            previousNativeAd.unregisterView()
        }
        
        // 2. Retain a reference to the native ad object
        self.fbnNativeAd = nativeAd
        
        DispatchQueue.main.async {
            let visibleCells = self.tblExtendedView.visibleCells
            
            for cell in visibleCells {
                
                if let cell = cell as? HomeListAdsCC {
                    cell.loadFacebookAd(nativeAd: nativeAd, viewController: self)
                }
            }
        }
        
        
    }
    
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        
        self.fbnNativeAd = nil
        print("error", error.localizedDescription)
    }
    
    
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        print("nativeAdDidClick")
    }
    
}

//MARK:- Cell Suggested article Delegate
extension HomeVC: sugClvReelsCCDelegate, HomeClvHeadlineCCDelegate, HomeHeroCCDelegate, sugClvTopicsCCDelegate {
    
    //<--- Home Hero Cell Delegates
    func didTapOpenSource(cell: HomeHeroCC) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell)  else {
            return
        }
        let btn = UIButton()
        btn.tag = indexPath.row
        btn.accessibilityIdentifier = "\(indexPath.section)"
        cell.isUserInteractionEnabled = false
        self.didTapSource(button: btn)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            cell.isUserInteractionEnabled = true
        }
    }
    
    func didTapYoutubePlayButton(cell: HomeHeroCC) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell)  else {
            return
        }
        let btn = UIButton()
        btn.tag = indexPath.row
        btn.accessibilityIdentifier = "\(indexPath.section)"
        self.didTapPlayYoutube(btn)
        
    }
    
    func didHeroSelectCell(cell: HomeHeroCC) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        
        // When focus index of card and the user taps index not same then return it
        let row = indexPath.row
        print("UITapGestureRecognizer: ", row)
        let content = self.articles[row]
        updateProgressbarStatus(isPause: true)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//            self.showTopAndBottomBar()
//        }
        
        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.selectedArticleData = articlesData(id: content.id, title: content.title, media: content.media, image: content.image, link: content.link, original_link: content.original_link, color: content.color, publish_time: content.publish_time, source: content.source, bullets: content.bullets, topics: content.topics, status: content.status, mute: content.mute, type: content.subType, meta: content.meta, info: content.info, authors: content.authors, media_meta: content.media_meta, language: content.language, icon: content.icon, suggestedAuthors: content.suggestedAuthors, suggestedReels: content.suggestedReels, suggestedChannels: content.suggestedChannels, suggestedFeeds: content.suggestedFeeds, suggestedTopics: content.suggestedTopics, subType: "", followed: content.followed)
        
        vc.delegate = self
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalTransitionStyle = .crossDissolve
//        self.present(navVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func resetHeroPlayerAtIndex(cell: HomeHeroCC) {
        
        if MediaManager.sharedInstance.isFullScreenButtonPressed {
            return
        }
        cell.playButton.isHidden = false
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        
        cell.animationSourceShowHide(isShow: true)
        if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == indexPath {
            //cell.animationSourceShowHide(isShow: true)
            MediaManager.sharedInstance.player?.stop()
            cell.viewDuration.isHidden = false
            cell.imgPlayButton.isHidden = false
        }
        
    }
    
    func playHeroVideoOnFocus(cell: HomeHeroCC, isPause: Bool) {
                
        if MediaManager.sharedInstance.isFullScreenButtonPressed {
            return
        }
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        
        print("playVideoOnFocus indexPath", indexPath)
        if isPause {
            
            guard let player = MediaManager.sharedInstance.player else {
                return
            }
            //cell.animationSourceShowHide(isShow: true)
            player.pause()
            print("player.pause at indexPath", indexPath)
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoDurationEvent, eventDescription: "", article_id: self.articles[self.focussedIndexPath].id ?? "", duration: MediaManager.sharedInstance.player?.currentTime?.formatToMilliSeconds() ?? "")
            

        }
        else {
            
            if SharedManager.shared.videoAutoPlay {
                didTapHeroVideoPlayButton(cell: cell)
            }
        }
    }
    
    
    func didTapHeroVideoPlayButton(cell: HomeHeroCC) {
        
        updateProgressbarStatus(isPause: true)
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        
        let oldFocus = IndexPath(row: self.focussedIndexPath, section: 0)
        if oldFocus == indexPath {
            
            let art = self.articles[oldFocus.row]
            guard let url = URL(string: art.link ?? "") else { return }
            // Same focus
            if let player = MediaManager.sharedInstance.player, let index = player.indexPath, index == oldFocus, player.contentURL == url {
                if player.isPlaying == false {
                    
                    //cell.animationSourceShowHide(isShow: false)
                    cell.playButton.isHidden = true
                    cell.viewDuration.isHidden = true
                    cell.imgPlayButton.isHidden = true
                    player.play()
                    return
                }
            }
        }
        
        // reset old player
        resetOldPlayer(oldFocus: oldFocus)
        
        
        let art = articles[indexPath.row]
        guard let url = URL(string: art.link ?? "") else { return }
        self.focussedIndexPath = indexPath.row
        
        if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == indexPath, player.contentURL == url {
            player.play()
            cell.animationSourceShowHide(isShow: false)
            cell.playButton.isHidden = true
            cell.viewDuration.isHidden = true
            cell.imgPlayButton.isHidden = true
           return
        }
        
        cell.animationSourceShowHide(isShow: false)
        cell.playButton.isHidden = true
        cell.viewDuration.isHidden = true
        cell.imgPlayButton.isHidden = true
        let videoInfo = [
            "autoPlay":true,
            "floatMode": EZPlayerFloatMode.none,
            "fullScreenMode": EZPlayerFullScreenMode.landscape
        ] as [String : Any]
        
        MediaManager.sharedInstance.playEmbeddedVideo(url: url, embeddedContentView: cell.imgPlaceHolder, userinfo: videoInfo, viewController: self, articleID: art.id ?? "")
        MediaManager.sharedInstance.player?.indexPath = indexPath
        MediaManager.sharedInstance.player?.scrollView = tblExtendedView
    }
    
    @objc func videoPlayerStatus(_ notification: Notification) {
        
        if let hCell = self.getCurrentFocussedCell() as? HomeHeroCC {
            
            let content = self.articles[self.focussedIndexPath]
            guard let _ = URL(string: content.link ?? "") else { return }
            
            let subType = content.subType ?? ""
            if subType.uppercased() == Constant.newsArticle.ARTICLE_TYPE_VIDEO {

                if let player = MediaManager.sharedInstance.player {
                    if player.state == EZPlayerState.pause {
                        hCell.animationSourceShowHide(isShow: true)
                    }
                    else if player.state == EZPlayerState.playing {
                        hCell.animationSourceShowHide(isShow: false)
                    }
                }
            }

        }
    }
    //--->

    //horizontal suggested article
    func didTapOnHeadlineFeedsCell(cell: UITableViewCell, row: Int) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else { return }
        
        updateProgressbarStatus(isPause: true)
        
        let content = articles[indexPath.row].suggestedFeeds?[row]

        if content?.type ?? "" == "FOLLOWED_CARD" {

            self.homeViewModel.performWSToOpenTopics(id: content?.id ?? "", title: content?.footer?.title ?? "", favorite: content?.followed ?? false)
        }
        else {
            
            let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
            vc.selectedArticleData = content
            vc.delegate = self
            vc.delegateVC = self
            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            navVC.modalTransitionStyle = .crossDissolve
    //        self.present(navVC, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }

        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//            self.showTopAndBottomBar()
//        }
    }
    
    func didTapOnHeadlineFeedsSource(cell: UITableViewCell, row: Int) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else { return }

        self.updateProgressbarStatus(isPause: true)
        
        if let content = articles[indexPath.row].suggestedFeeds?[row] {
            
            // TAP TO OPEN SOURCE
            if content.source != nil {
                
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
                
                self.homeViewModel.performGoToSource(content.source?.id ?? "")
            }
            else {
                            
                let authors = content.authors
                if (authors?.first?.id ?? "") == SharedManager.shared.userId {
                    
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
    }
    
    //topics
    func didTapOnTopicCell(cell: UITableViewCell, row: Int, isTapOnButton: Bool) {
            
        guard let indexPath = tblExtendedView.indexPath(for: cell) else { return }
        
        let id = articles[indexPath.row].suggestedTopics?[row].id ?? ""
        let name = articles[indexPath.row].suggestedTopics?[row].name ?? ""
        let fav = articles[indexPath.row].suggestedTopics?[row].favorite ??
            true
        
        guard let topicCell = cell as? sugClvTopicsCC else {
            return
        }
        
        if let topicArray = self.articles[indexPath.row].suggestedTopics {
            if let index = topicCell.topicArray1.firstIndex(where: { $0.id == id }) {
                topicCell.clv1.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
            if let index = topicCell.topicArray2.firstIndex(where: { $0.id == id }) {
                topicCell.clv2.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
            if let index = topicCell.topicArray3.firstIndex(where: { $0.id == id }) {
                topicCell.clv3.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
        
        
        if isTapOnButton {
            
            articles[indexPath.row].suggestedTopics?[row].isShowingLoader = true
            self.tblExtendedView.reloadRows(at: [indexPath], with: .none)
            
            SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [id], isFav: !fav, type: .topics) { status in
                self.articles[indexPath.row].suggestedTopics?[row].isShowingLoader = false
                if status {
                    self.articles[indexPath.row].suggestedTopics?[row].favorite = !fav
                    print("topics status", status)
                } else {
                    print("topics status", status)
                }
                
                if let topicArray = self.articles[indexPath.row].suggestedTopics {
                    if let index = topicCell.topicArray1.firstIndex(where: { $0.id == id }) {
                        topicCell.clv1.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                    if let index = topicCell.topicArray2.firstIndex(where: { $0.id == id }) {
                        topicCell.clv2.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                    if let index = topicCell.topicArray3.firstIndex(where: { $0.id == id }) {
                        topicCell.clv3.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                }
                
            }
        }
        else {
            
            let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
            detailsVC.isOpenFromReel = false
            detailsVC.delegate = self
            detailsVC.isOpenForTopics = true
            detailsVC.context = articles[indexPath.row].suggestedTopics?[row].context ?? ""
            detailsVC.topicTitle = "#\(articles[indexPath.row].suggestedTopics?[row].name ?? "")"
            detailsVC.modalPresentationStyle = .fullScreen
            
            let nav = AppNavigationController(rootViewController: detailsVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
//            self.homeViewModel.performWSToOpenTopics(id: id, title: name, favorite: fav)
        }

    }
    
    //Reels
    func didTapOnReelsCell(cell: UITableViewCell, reelRow: Int) {
        
        updateProgressbarStatus(isPause: true)
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else { return }

        let content = self.articles[indexPath.row]
        if let reelsArray = content.suggestedReels {
            
            let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
            vc.isBackButtonNeeded = true
            vc.modalPresentationStyle = .overFullScreen
            vc.reelsArray = reelsArray
            
            //vc.isSugReels = true
            //vc.delegate = self
            vc.userSelectedIndexPath = IndexPath(item: reelRow, section: 0)
            vc.authorID = reelsArray[reelRow].authors?.first?.id ?? ""
            vc.scrollToItemFirstTime = true

            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .overFullScreen
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
    
    
    func openViewController(article: articlesData) {
        
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



//MARK:- AuthorProfileVC Delegate
extension HomeVC: AuthorProfileVCDelegate {
    
    func updateAuthorWhenDismiss(article: articlesData) {
        
        if let row = self.articles.firstIndex(where: { $0.id == article.id }) {
            self.articles[row] = article
        }
    }
}

//MARK:- Popup Delegate
extension HomeVC: PopupVCDelegate {
    
    func popupVCDismissed() {

        let vc = EditProfileVC.instantiate(fromAppStoryboard: .Main)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK:- CommunityGuide Delegate
extension HomeVC: CommunityGuideVCDelegate {
        
    func dimissCommunityGuideApprovedDelegate() {
    }
}

//MARK:- YoutubeArticle Delegate
extension HomeVC: YoutubeArticleVCDelegate {
    
    func submitYoutubeArticlePost(_ article: articlesData) {
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(false, animated: true)
        }
        
        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
        vc.yArticle = article
        vc.postArticleType = .youtube
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- YPImagePicker Delegate
extension HomeVC: YPImagePickerDelegate {
    
    func noPhotos() {}
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true// indexPath.row != 2
    }
    
    func openMediaPicker(isForReels: Bool) {
        
        var config = YPImagePickerConfiguration()
        
        config.library.onlySquare = false
        
        
        config.library.mediaType = .photoAndVideo
        config.library.itemOverlayType = .grid
        
        config.libraryPhotoOnly.mediaType = .photo
        config.libraryPhotoOnly.itemOverlayType = .grid
        
        config.libraryVideoOnly.mediaType = .video
        config.libraryVideoOnly.itemOverlayType = .grid
        
        
        config.showsPhotoFilters = false
        
        
        config.shouldSaveNewPicturesToAlbum = false
        
        /* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
        config.video.compression = AVAssetExportPresetPassthrough
        
        
        config.albumName = ApplicationAlertMessages.kAppName
        
        
        config.startOnScreen = .library
        
        
        if isForReels {
            config.screens = [.libraryVideoOnly]
        } else {
            config.screens = [.library, .libraryPhotoOnly, .libraryVideoOnly]
        }
        
        
        config.video.libraryTimeLimit = 14400
        
        config.video.libraryTimeLimit = 14400
        
        config.video.minimumTimeLimit = 1
        
        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .none//.rectangle(ratio: (16/9))
        
        
        config.hidesStatusBar = false
        
        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false
        
        config.maxCameraZoomFactor = 2.0
        
        config.library.maxNumberOfItems = 1
        config.libraryPhotoOnly.maxNumberOfItems = 1
        config.libraryVideoOnly.maxNumberOfItems = 1
        config.gallery.hidesRemoveButton = false
        
        
        
        config.isForReels = isForReels
        
        
        let picker = YPImagePicker(configuration: config)
        
        picker.imagePickerDelegate = self
        
        /* Change configuration directly */
        // YPImagePickerConfiguration.shared.wordings.libraryTitle = "Gallery2"
        
        /* Multiple media implementation */
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }
            
            self.selectedItems = items
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    //                    self.selectedImageV.image = photo.image
                    picker.dismiss(animated: true, completion: { [weak self] in
                        //                        self?.present(playerVC, animated: true, completion: nil)
                        //                        print("resolutionForLocalVideo 😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
                        
                        if let ptcTBC = self?.tabBarController as? PTCardTabBarController {
                            ptcTBC.showTabBar(false, animated: true)
                        }
                        
                        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
                        vc.imgPhoto = photo.originalImage
                        vc.postArticleType = .media
                        vc.selectedMediaType = .photo
                        vc.modalPresentationStyle = .fullScreen
                        self?.navigationController?.pushViewController(vc, animated: true)
                        
                    })
                case .video(let video):
                    //                    self.selectedImageV.image = video.thumbnail
                    
                    let assetURL = video.url
                    
                    //                    let playerVC = AVPlayerViewController()
                    //                    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
                    //                    playerVC.player = player
                    
                    picker.dismiss(animated: true, completion: { [weak self] in
                        //                        self?.present(playerVC, animated: true, completion: nil)
                        //                        print("resolutionForLocalVideo 😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
                        
                        if let ptcTBC = self?.tabBarController as? PTCardTabBarController {
                            ptcTBC.showTabBar(false, animated: true)
                        }
                        
                        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
                        vc.videoURL = assetURL
                        vc.imgPhoto = video.thumbnail
                        vc.uploadingFileTaskID = video.taskID ?? ""
                        
                        if isForReels {
                            vc.postArticleType = .reel
                        }
                        else {
                            vc.postArticleType = .media
                            vc.selectedMediaType = .video
                        }
                        vc.modalPresentationStyle = .fullScreen
                        self?.navigationController?.pushViewController(vc, animated: true)
                        
                    })
                }
            }
        }
        
        present(picker, animated: true, completion: nil)
    }
}

extension HomeVC: SharingDelegate, UIDocumentInteractionControllerDelegate {
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("shared")
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("didFailWithError")

    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        print("sharerDidCancel")
    }
}


extension UILabel {
    func textWidth() -> CGFloat {
        return UILabel.textWidth(label: self)
    }
    
    class func textWidth(label: UILabel) -> CGFloat {
        return textWidth(label: label, text: label.text!)
    }
    
    class func textWidth(label: UILabel, text: String) -> CGFloat {
        return textWidth(font: label.font, text: text)
    }
    
    class func textWidth(font: UIFont, text: String) -> CGFloat {
        let myText = text as NSString
        
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(labelSize.width)
    }
}


extension HomeVC {
    
    func didTapBottomShareSheetAction(sender: UIButton, article: articlesData) {
        
        if sender.tag == 1 {
            
            //Save article
            self.homeViewModel.performArticleArchive(article.id ?? "", isArchived: !self.article_archived)
        }
        else if sender.tag == 2 {
            self.updateProgressbarStatus(isPause: true)
            self.openDefaultShareSheet(shareTitle: shareTitle)
        }
        else if sender.tag == 3 {
            
            //Go to Source
            if let source = article.source {
                self.homeViewModel.performGoToSource(source.id ?? "")
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
                
                self.homeViewModel.performUnFollowUserSource(article.source?.id ?? "", name: article.source?.name ?? "")
            }
            else {
                
                self.homeViewModel.performWSToFollowSource(article.source?.id ?? "", name: article.source?.name ?? "")
            }
        }
        else if sender.tag == 5 {
            
            //Block articles
            if let _ = article.source {
                /* If article source */
                if self.sourceBlock {
                    self.homeViewModel.performWSToUnblockSource(article.source?.id ?? "", name: article.source?.name ?? "")
                }
                else {
                    self.homeViewModel.performBlockSource(article.source?.id ?? "", sourceName: article.source?.name ?? "")
                }
            }
            else {
                //If article author data
                self.homeViewModel.performWSToBlockUnblockAuthor(article.authors?.first?.id ?? "", name: article.authors?.first?.name ?? "", authorBlock: authorBlock)
            }
        }
        else if sender.tag == 6 {
            
            //Report content
            
        }
        else if sender.tag == 7 {
            
            //More like this
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.moreLikeThisClick, eventDescription: "")
            self.homeViewModel.performWSuggestMoreOrLess(article.id ?? "", isMoreOrLess: true)
            
        }
        else if sender.tag == 8 {
            
            //I don't like this
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.lessLikeThisClick, eventDescription: "", article_id: article.id ?? "")
            self.homeViewModel.performWSuggestMoreOrLess(article.id ?? "", isMoreOrLess: false)
        }
        else if sender.tag == 10 {
           
            // Copy
            // write to clipboard
            UIPasteboard.general.string = shareTitle
            SharedManager.shared.showAlertLoader(message: "Copied to clipboard successfully", type: .alert)
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
    
    func stopIndicatorLoading() {
        
        if self.indicator.isAnimating {
            
            DispatchQueue.main.async {
                
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                self.viewIndicator.isHidden = true
            }
        }
    }
    
    func writeToPhotoAlbum(image: UIImage){
     
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if (error != nil) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgUnableToLoadImage)

        }
        else {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            if let lastAsset = fetchResult.firstObject {
                let localIdentifier = lastAsset.localIdentifier
                let u = "instagram://library?LocalIdentifier=" + localIdentifier
                let url = NSURL(string: u)!
                
                DispatchQueue.main.async {
                
                    if UIApplication.shared.canOpenURL(url as URL) {
                        UIApplication.shared.open(URL(string: u)!, options: [:], completionHandler: nil)
                    } else {
                        
                        let urlStr = "https://itunes.apple.com/in/app/instagram/id389801252?mt=8"
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                            
                        } else {
                            UIApplication.shared.openURL(URL(string: urlStr)!)
                        }
                    }
                }
            }
        }
    }
}
 
//MARK:- HomeReelCarouselCC Delegate
extension HomeVC: HomeReelCarouselCCDelegate, HomeVideoCarouselCCDelegate, ReelsVCDelegate, BulletDetailsVCDelegate {
    
    func currentPlayingVideoChanged(newIndex: IndexPath) {
    }
    
    func changeScreen(pageIndex: Int) {
    }
    
    
    func switchBackToForYou() {
        
    }
    
    func loaderShowing(status: Bool) {
    }
    
    
    func dismissBulletDetailsVC(selectedArticle: articlesData?) {
        
        if let index = self.articles.firstIndex(where: { $0.id == selectedArticle?.id ?? "" }) {
            self.articles[index].source = selectedArticle?.source
            let cell = tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0))
            
//            (cell as? HomeListViewCC)?.setLikeComment(model: self.articles[index].info)
            (cell as? HomeCardCell)?.setFollowingUI(model: self.articles[index])
//            (cell as? YoutubeCardCell)?.setLikeComment(model: self.articles[index].info)
//            (cell as? VideoPlayerVieww)?.setLikeComment(model: self.articles[index].info)
        }
        
        
    }
    
    func backButtonPressed(_ isUpdateSavedArticle: Bool) {
        
        updateProgressbarStatus(isPause: true)
    }
    
    
    func openSelectedItem(indexPath: IndexPath, secondaryIndexPath: IndexPath?) {
        
        if articles[indexPath.row].type == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL {
            
            guard let secondaryIndex = secondaryIndexPath  else { return }
            
            let reel = articles[indexPath.row].suggestedReels?[secondaryIndex.row]
            //openReels(title: "", context: reel?.context, isOpenForTags: false)
            
            updateProgressbarStatus(isPause: true)
                        
            let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
            vc.isBackButtonNeeded = true
            vc.modalPresentationStyle = .overFullScreen
            if let reels = articles[indexPath.row].suggestedReels {
                vc.reelsArray = reels
            }

            //vc.isSugReels = true
            //vc.delegate = self
            vc.userSelectedIndexPath = IndexPath(item: secondaryIndex.row, section: 0)
            vc.authorID = reel?.authors?.first?.id ?? ""
            vc.scrollToItemFirstTime = true

            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .overFullScreen
            self.present(navVC, animated: true, completion: nil)

        }
        
        if articles[indexPath.row].type == Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS {
            
            guard let secondaryIndex = secondaryIndexPath  else { return }
            
            let article = articles[indexPath.row].suggestedFeeds?[secondaryIndex.row]
            openBulletDetails(indexPath: indexPath, article: article)
        }
    }
    
    func openBulletDetails(indexPath: IndexPath, article: articlesData?) {
        
        updateProgressbarStatus(isPause: true)
        
        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.selectedArticleData = article
        
        vc.delegate = self
        vc.delegateVC = self
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.isHidden = true
        navVC.modalPresentationStyle = .overFullScreen
        navVC.modalTransitionStyle = .crossDissolve
        
        SharedManager.shared.isOnDiscover = false
        self.present(navVC, animated: true, completion: nil)
        
    }
    
    func openChannelDetails(channel: ChannelInfo) {
        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
        detailsVC.isOpenFromReel = false
        detailsVC.delegate = self
        detailsVC.isOpenForTopics = false
        detailsVC.channelInfo = channel
//        detailsVC.context = channel.context ?? ""
//                    detailsVC.topicTitle = "#\(articles[indexPath.row].suggestedTopics?[row].name ?? "")"
        detailsVC.modalPresentationStyle = .fullScreen
        
        let nav = AppNavigationController(rootViewController: detailsVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    //<--- Reels
    func didSelectItem(cell: HomeReelCarouselCC, secondaryIndex: IndexPath) {
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)

    }
    
    func didTapOnChannel(cell: HomeReelCarouselCC, secondaryIndex: IndexPath) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        
        if self.articles[indexPath.row].type == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL {
              
            updateProgressbarStatus(isPause: true)
            
            let reel = self.articles[indexPath.row].suggestedReels?[secondaryIndex.item]
            
            if let source = reel?.source {
                                
                self.homeViewModel.performGoToSource(source.id ?? "")
            }
            else {
                                
                let authors = reel?.authors
                if (authors?.first?.id ?? "") == SharedManager.shared.userId {
    
                    let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .overFullScreen
                    //vc.delegate = self
                    self.present(navVC, animated: true, completion: nil)
                }
                else {
    
                    let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                    vc.authors = authors
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .overFullScreen
    //                vc.delegateVC = self
                    self.present(navVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func setCurrentFocusedSelected(cell: HomeReelCarouselCC) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        if focussedIndexPath != indexPath.row {
            updateProgressbarStatus(isPause: true)
            focussedIndexPath = indexPath.row
        }
    }
    //--->
    
    
    //<--- Video
    func didSelectItem(cell: HomeVideoCarouselCC, secondaryIndex: IndexPath) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)
    }
    
    func setCurrentFocusedSelected(cell: HomeVideoCarouselCC) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        
        if focussedIndexPath != indexPath.row {
            updateProgressbarStatus(isPause: true)
            focussedIndexPath = indexPath.row
        }
    }
    //--->
}


extension HomeVC: ChannelDetailsVCDelegate {
    
    func backButtonPressedChannelDetailsVC(_ channel: ChannelInfo?) {
    }
    
    func backButtonPressedWhenFromReels(_ channel: ChannelInfo?) {
    }
    
    
}



extension HomeVC: ForYouPreferencesVCDelegate {
    
    func userDismissed(vc: ForYouPreferencesVC, selectedPreference: Int, selectedCategory: String) {
       
        if selectedPreference == 0 {
            // For you
            if isOnFollowing {
                // Change page index
                self.delegate?.changeScreen(pageIndex: selectedPreference)
            }
            else {
                self.updateProgressbarStatus(isPause: false)
                isViewPresenting = true
            }
        }
        else {
            
            if isOnFollowing == false {
                // Change page index
                self.delegate?.changeScreen(pageIndex: selectedPreference)
            }
            else {
                self.updateProgressbarStatus(isPause: false)
                isViewPresenting = true
            }
            
        }
        
        
    }
    
    func userChangedCategory() {
        
        
    }
    
}

extension HomeVC: FollowingPreferenceVCDelegate {
    
    func userDismissed(vc: FollowingPreferenceVC) {
        
        self.updateProgressbarStatus(isPause: false)
        isViewPresenting = true
    }
    
}



extension HomeVC: SuggestedAuthorsCCDelegate {
    
    func didTapChannel(cell: SuggestedCC, channel: ChannelInfo) {
        openChannelDetails(channel: channel)
    }
    
    func didTapSeeAll(cell: SuggestedCC) {
        
        let vc = FollowingChannelsVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
        
    }
    
    func didTapFollow(cell: SuggestedCC, index: Int) {
        // not working properly
        guard let rowIndexPath = tblExtendedView.indexPath(for: cell) else { return }
        let fav = (self.articles[rowIndexPath.row].suggestedChannels?[index].favorite ?? false)
        let id = (self.articles[rowIndexPath.row].suggestedChannels?[index].id ?? "")
        
        self.articles[rowIndexPath.row].suggestedChannels?[index].isShowingLoader = true
        
        
        if let channelArray = self.articles[rowIndexPath.row].suggestedChannels {
            cell.channelArray = channelArray
            cell.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
        
        
        SharedManager.shared.performWSToUpdateUserFollow(id: [id], isFav: !(fav), type: .sources) { status in
            
            self.articles[rowIndexPath.row].suggestedChannels?[index].isShowingLoader = false
            if status {
                self.articles[rowIndexPath.row].suggestedChannels?[index].favorite = !(fav)
            }
            
            if let channelArray = self.articles[rowIndexPath.row].suggestedChannels {
                cell.channelArray = channelArray
                cell.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
            
        }
    }
    
}


