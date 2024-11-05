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


class ForYouVC: UIViewController, UIGestureRecognizerDelegate {

    //PROPERTIES
    @IBOutlet weak var tblExtendedView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //No Saved Articles View
    @IBOutlet weak var viewNoSavedBG: UIView!
    @IBOutlet var lblNoSavedArticles: [UILabel]!
    @IBOutlet weak var lblNoSavedTitle: UILabel!
    @IBOutlet weak var lblNoSavedDes1: UILabel!
    @IBOutlet weak var lblNoSavedDes2: UILabel!
    @IBOutlet weak var lblNoSavedDes3: UILabel!
    @IBOutlet weak var lblNoSavedDes4: UILabel!
    @IBOutlet weak var lblNoSavedDes5: UILabel!
    
    //No Data View
    @IBOutlet weak var viewNoData: UIView!
    @IBOutlet weak var imgNoData: UIImageView!
    @IBOutlet weak var lblNoDataTitle: UILabel!
    @IBOutlet weak var lblNoDataDescription: UILabel!
    @IBOutlet weak var lblHome: UILabel!
    
    //Forcing select topic or channels
    @IBOutlet weak var imgForcing: UIImageView!
    @IBOutlet weak var lblForcingTitle: UILabel!
    @IBOutlet weak var lblForcingSubTitle: UILabel!
    @IBOutlet weak var lblForcingGetStart: UILabel!
    @IBOutlet weak var viewForce: UIView!
    @IBOutlet weak var extendedViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var normalTableViewTopConstraint: CGFloat = 60
    var extendedTableViewTopConstraint: CGFloat = 0
    var normalCollectionViewTopConstraint: CGFloat = 40
    var extendedCollectionViewTopConstraint: CGFloat = 0
    
    weak var scrollDelegate: HomeVCScrollDelegate?
    
    //VARIABLES
    private var nextPaginate = ""
    private var isPullToRefresh = false
    private var articles: [articlesData] = []
    private var generator = UIImpactFeedbackGenerator()
    private var prefetchState: PrefetchState = .idle
    
    //sharing variables
    var urlOfImageToShare: URL?
    var shareTitle = ""
    var sourceBlock = false
    var sourceFollow = false
    var article_archived = false
    var stGreeting = ""

    //CELL INSTANCES
    var curVideoVisibleCell: VideoPlayerView?
    var curYoutubeVisibleCell: YoutubeCardCell?

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isFirstLoadView = true
    var refreshControlExtended = UIRefreshControl()
    
    let adUnitID  = UserDefaults.standard.string(forKey: Constant.UD_adsUnitKey) ?? ""
    
    /// The number of native ads to load (must be less than 5).
    let numAdsToLoad = 2
    
    /// The native ads.
    var nativeAds = [GADUnifiedNativeAd]()
    
    /// The ad loader that loads the native ads.
    var adLoader: GADAdLoader!
    var isViewPresenting: Bool = false
    var lastContentOffset: CGFloat = 0
    
    //PAGE VIEW CONTROLLER VARIABLE
    var isDataLoaded = false
    var pageIndex = 0
    var isDirectionFindingNeeded = false
    
    //deinit methods
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyMoveToCard, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SET LOCALIZABLE
        setLocalizableString()
        
        //Design View
        self.view.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        
        self.viewNoSavedBG.isHidden = true
        self.lblNoSavedArticles.forEach {
            $0.theme_textColor = GlobalPicker.textColor
        }
        self.activityIndicator.stopAnimating()
        self.viewNoData.isHidden = true
        self.imgNoData.theme_image = GlobalPicker.imgNoData
        self.lblNoDataTitle.theme_textColor = GlobalPicker.textColor
        self.lblNoDataDescription.theme_textColor = GlobalPicker.textColor
        self.lblNoDataDescription.setLineSpacing(lineSpacing: 5)
        self.lblNoDataDescription.textAlignment = .center
        self.lblHome.theme_textColor = GlobalPicker.textColor
        self.lblHome.layer.cornerRadius = lblHome.bounds.height / 2
        self.lblHome.layer.borderWidth = 2.5
        self.lblHome.layer.borderColor = Constant.appColor.purple.cgColor
        self.lblHome.addTextSpacing(spacing: 2.5)
        
        self.lblForcingTitle.theme_textColor = GlobalPicker.textColor
        self.lblForcingTitle.setLineSpacing(lineSpacing: 5)
        self.lblForcingSubTitle.theme_textColor = GlobalPicker.textColor
        self.lblForcingSubTitle.setLineSpacing(lineSpacing: 5)
        self.lblForcingGetStart.layer.cornerRadius = lblForcingGetStart.bounds.height / 2
        self.lblForcingGetStart.clipsToBounds = true
        self.lblForcingGetStart.theme_backgroundColor = GlobalPicker.btnSelectedTabbarTintColor
        self.lblForcingTitle.textAlignment = .center
        self.lblForcingSubTitle.textAlignment = .center
        
        //register cardcell for storyboard use
        self.tblExtendedView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: BOTTOM_INSET + self.tblExtendedView.bounds.height / 2, right: 0)
        self.tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_HOME_LISTVIEW, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW)
        self.tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_HOME_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_CARD)
        self.tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_ADS_LIST, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_ADS_LIST)
        self.tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_YOUTUBE_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_YOUTUBE_CARD)
        self.tblExtendedView.rowHeight = UITableView.automaticDimension
        self.tblExtendedView.estimatedRowHeight = 700
        self.tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_VIDEO_PLAYER, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER)
        
        //Pull to refresh for Extended View
        refreshControlExtended.theme_tintColor = GlobalPicker.textColor
        refreshControlExtended.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to refresh", comment: ""))
        refreshControlExtended.theme_titleAttributes = GlobalPicker.attributeTitleRefreshControl
        refreshControlExtended.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tblExtendedView.addSubview(refreshControlExtended) // not required when using UITableViewController
                
        
        self.isFirstLoadView = true
        SharedManager.shared.performWSToGetUserInfo()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            
            //SwiftRater.rateApp(host: self)
            SwiftRater.check(host: self)
            
            if SharedManager.shared.userAlert != nil {
                
                SharedManager.shared.isPauseAudio = true
                NotificationCenter.default.post(name: Notification.Name.notifyAudioAndProgressBarStatus, object: nil)
                let vc = WhatsNewVC.instantiate(fromAppStoryboard: .registration)
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        UserDefaults.standard.removeSuite(named: "group.app.newsinbullets")
        UserDefaults.standard.removeSuite(named: "accessToken")
        UserDefaults.standard.removePersistentDomain(forName: "group.app.newsinbullets")
        UserDefaults.standard.synchronize()
        
        let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
        if let userDefaults = UserDefaults(suiteName: "group.app.newsinbullets") {
            userDefaults.set(userToken as AnyObject, forKey: "accessToken")
            userDefaults.synchronize()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        isViewPresenting = true
        
        setTopBarInitialLoad()

        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyToRemoveVCObservers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapRemoveObserver(_:)), name: Notification.Name.notifyToRemoveVCObservers, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyPauseAudio, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapOpenEdition(_:)), name: Notification.Name.notifyPauseAudio, object: nil)
                        
        NotificationCenter.default.removeObserver(SharedManager.shared.observerArray)
        SharedManager.shared.observerArray = NotificationCenter.default.addObserver(forName: Notification.Name.notifyAppFromBackground, object: nil, queue: nil) { notification in
            
            self.notifyAppBackgroundEvent()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifyCallRecievedInApp), name: Notification.Name.notifyCallDuringAppUse, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapOnTabBarTwice(_:)), name: Notification.Name.notifyTabbarTapEvent, object: nil)
        
        SharedManager.shared.bulletPlayer?.stop()
        SharedManager.shared.bulletPlayer?.currentTime = 0
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyHomeVolumn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapVolume(notification:)), name: Notification.Name.notifyHomeVolumn, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyVideoVolumeStatus, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapUpdateVideoVolumeStatus(notification:)), name: Notification.Name.notifyVideoVolumeStatus, object: nil)
        
        if !self.isFirstLoadView {
            
            if !isDataLoaded {
                
                if SharedManager.shared.subSourcesList.count > 0 {
                    
                    //Data always load from first position
                    self.refreshListAndExtendedViewFromStartPosition(true)
                }
                else {
                    self.getRefreshArticlesData()
                }
            }
            else {
                
                if SharedManager.shared.isShowSource || !SharedManager.shared.isTabReload {
                    
                    self.refreshListAndExtendedViewFromStartPosition(false)
                }
                else {
                    self.refreshListAndExtendedViewFromStartPosition(true)
                }
            }
        }
        else {
                        
            //Data always load from first position
            if SharedManager.shared.isShowTopic {
                
                SharedManager.shared.focussedCardTopicIndex = 0
            }
            else if SharedManager.shared.isShowSource {
                SharedManager.shared.focussedCardSourceIndex = 0
            }
            else {
                SharedManager.shared.focussedCardIndex = 0
            }
            
            if SharedManager.shared.isViewArticleSourceNotification {
                self.articles = SharedManager.shared.viewArticleArray
            }
            else {
                self.getRefreshArticlesData()
            }
        }
        
        self.isFirstLoadView = false
    }
    
    
    func setTopBarInitialLoad() {
        
        if SharedManager.shared.isSavedArticle || SharedManager.shared.isAppLaunchedThroughNotification {
            
            self.tableViewTopConstraint.constant = self.extendedTableViewTopConstraint
        }
        else {
            
            if SharedManager.shared.isTopTabBarCurrentlHidden {
                self.tableViewTopConstraint.constant = self.extendedTableViewTopConstraint
            } else {
                self.tableViewTopConstraint.constant = self.normalTableViewTopConstraint
            }
        }
    }
    
    @objc func didTapRemoveObserver(_ notification: NSNotification) {
        
        SharedManager.shared.clearProgressBar()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyAppFromBackground, object: nil)
        NotificationCenter.default.removeObserver(SharedManager.shared.observerArray)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyVideoVolumeStatus, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        isViewPresenting = false
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyAppFromBackground, object: nil)
        NotificationCenter.default.removeObserver(SharedManager.shared.observerArray)
        
        self.resetCurrentFocussedArticles()
    }
    
    func resetCurrentFocussedArticles() {
        
        //HOME CARD VIEW CC
        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
            cell.resetVisibleCard()
        }
        
        //HOME LIST VIEW CC
        if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
            cell.resetVisibleListCell()
        }
        
        //HOME YOUTUBE VIEW CC
        if let yCell = self.curYoutubeVisibleCell {
            yCell.resetYoutubeCard()
        }
        
        //VIDEO VIEW CC
        if let vCell = self.curVideoVisibleCell {
            vCell.resetVisibleVideoPlayer()
        }
        else {
            print("not called....")
        }

    }

    //Set String for Language Translation and Put it in String Files
    func setLocalizableString() {
        
        //LOCALIZABLE STRING
        lblNoSavedTitle.text = NSLocalizedString("No saved stories yet", comment: "")
        lblNoSavedDes1.text = NSLocalizedString("Tap the", comment: "") + " ( "
        lblNoSavedDes2.text = " ) " + NSLocalizedString("icon on the article", comment: "")
        lblNoSavedDes3.text = " )" + NSLocalizedString("you want to read later then", comment: "")
        lblNoSavedDes4.text = NSLocalizedString("Select", comment: "") + " ( "
        lblNoSavedDes5.text = " ) " + NSLocalizedString("to save article.", comment: "")
        
        lblNoDataTitle.text = NSLocalizedString("There is nothing in here", comment: "")
        lblNoDataDescription.text = NSLocalizedString("Looks like there is nothing here but a cat.", comment: "") + "\n" + NSLocalizedString("Would you like to go back to home?", comment: "")
        lblHome.text = NSLocalizedString("GO HOME", comment: "")
        
        lblForcingTitle.text = NSLocalizedString("Personalize your reading experience", comment: "")
        lblForcingSubTitle.text = NSLocalizedString("Start following the news topics and channels you want to read.", comment: "")
        lblForcingGetStart.text = NSLocalizedString("LET'S GO", comment: "")
        
    }
    
    func refreshListAndExtendedViewFromStartPosition(_ isStartFromFirstPosition: Bool) {
        
        //Data always load from first position
        if isStartFromFirstPosition {
            
            self.getRefreshArticlesData()
        }
        else {
            
            self.tblExtendedView.reloadData()
        }
    }
    
    @objc func didTapUpdateVideoVolumeStatus( notification: NSNotification) {
        
        if let vCell = self.getCurrentFocussedCell() as? VideoPlayerView {
        
            guard let status = notification.userInfo?["isPause"] as? Bool else { return }
        
            vCell.playVideo(isPause: status)
        }
    }
    
    @objc func didTapVolume( notification: NSNotification) {
        
        // we checking the current articels of bullets
        if SharedManager.shared.isAudioEnable {
            
            if articles.count == 0 { return }
            
            if SharedManager.shared.isShowTopic {
                
                SharedManager.shared.articleOnVolume = articles[SharedManager.shared.focussedCardTopicIndex]
            }
            else if SharedManager.shared.isShowSource || SharedManager.shared.isViewArticleSourceNotification {
                
                SharedManager.shared.articleOnVolume = articles[SharedManager.shared.focussedCardSourceIndex]
            }
            else {
                
                SharedManager.shared.articleOnVolume = articles[SharedManager.shared.focussedCardIndex]
            }
        }
        
        let index = self.getIndexPathForSelectedArticleCardAndListView()
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeCardCell {
            cell.updateCardVloumeStatus()
        }
        else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeListViewCC {
            cell.updateListViewVolumeStatus()
        }

    }
    
    //Action for pull to refresh
    @objc func pullToRefresh() {
        
        isPullToRefresh = true
        //print("REFRESHING")
        if SharedManager.shared.isViewArticleSourceNotification {
            
            self.articles = SharedManager.shared.viewArticleArray
            
            if self.isPullToRefresh {
                //print("REFRESHED!!!")
                self.refreshControlExtended.endRefreshing()
                self.isPullToRefresh = false
            }
            self.tblExtendedView.reloadData()
        }
        else {
            getRefreshArticlesData()
        }
    }
    
    
    //MARK:- Notification Reciever
    
    @objc func didTapOnTabBarTwice(_ notification: NSNotification) {
        
        //Load from first position of list/extended view
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.7) {
                self.tblExtendedView.contentOffset = .zero
            } completion: { (Void) in
                self.getRefreshArticlesData()
            }
        }
    }
    
    @objc func didTapOpenEdition(_ notification: NSNotification) {
        
        self.updateProgressbarStatus(isPause: true)
    }
    
    @objc func notifyAppBackgroundEvent() {
        
        //do stuff using the userInfo property of the notification object
        if !SharedManager.shared.isSavedArticle {
            if SharedManager.shared.tabBarIndex != 0 {
                return
            }
        }
        
        if self.articles.count == 0 { return }
        
        SharedManager.shared.setAppsFlyerEventsReport(eventType: Constant.analyticsEvents.screenViewExpanded, eventDescription: "")
        var index = 0
        if SharedManager.shared.isShowTopic {
            index = SharedManager.shared.focussedCardTopicIndex
        }
        else if SharedManager.shared.isShowSource || SharedManager.shared.isViewArticleSourceNotification {
            index = SharedManager.shared.focussedCardSourceIndex
        }
        else {
            index = SharedManager.shared.focussedCardIndex
        }
        
        //reset current visible cell of Card List which is same index of list view
        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
            cell.clvBullets.isHidden = true
            cell.resetVisibleCard()
        }
        
        if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
            cell.clvBullets.isHidden = true
            cell.resetVisibleListCell()
        }
        
        self.tblExtendedView.isHidden = false
      //  self.tblExtendedView.reloadData()
        let indexPath = IndexPath(row: index, section: 0)
        if let visibleRows = tblExtendedView.indexPathsForVisibleRows, visibleRows.contains(indexPath) {
            self.tblExtendedView.reloadRows(at: [indexPath], with: .none)
        } else {
//            print("crash handled")
        }
        
    }
    
    @objc func notifyCallRecievedInApp() {
        
        if SharedManager.shared.bulletPlayer?.isPlaying ?? false {
            
            SharedManager.shared.bulletPlayer?.pause()
            SharedManager.shared.bulletPlayer?.stop()
            //print("Volume 8")
            
            SharedManager.shared.spbCardView?.isPaused = true
        }
    }
    
    //MARK:- BUTTON ACTION
    
    @IBAction func didTapGetStarted(_ sender: Any) {
        
        SharedManager.shared.tabBarIndex = TabbarType.Search.rawValue
        SharedManager.shared.subTabBarType = .none
        SharedManager.shared.isTabReload = true
                
        SharedManager.shared.isShowTopic = false
        SharedManager.shared.isShowSource = false
        SharedManager.shared.isSavedArticle = false
        
        SharedManager.shared.bulletPlayer?.stop()
        //print("Volume 34")
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.customTabBar.select(at: TabbarType.Search.rawValue)
        }
//        NotificationCenter.default.post(name: Notification.Name.notifyManageLocation, object: nil)
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.customTabBar.select(at: TabbarType.Search.rawValue)
        }
    }
    
    @IBAction func didTapGoHomeAction(_ sender: Any) {
        
        SharedManager.shared.isShowTopic = false
        SharedManager.shared.isShowSource = false
        SharedManager.shared.isSavedArticle = false
                
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyTapSubcategories, object: nil)
        NotificationCenter.default.removeObserver(Notification.Name.notifyTapSubcategories)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.appDelegate.setHomeVC(false)
        })
    }
}

//MARK:- Webservices -  Private func
extension ForYouVC {
    
    func getRefreshArticlesData() {
        
        self.tblExtendedView.setContentOffset(.zero, animated: false)
        
        if SharedManager.shared.isShowTopic {
            
            SharedManager.shared.focussedCardTopicIndex = 0
        }
        else if SharedManager.shared.isShowSource {
            SharedManager.shared.focussedCardSourceIndex = 0
        }
        else {
            SharedManager.shared.focussedCardIndex = 0
        }

        nextPaginate = ""
        if SharedManager.shared.isShowTopic || SharedManager.shared.isShowSource || SharedManager.shared.isViewArticleSourceNotification  {
            
            self .viewForce.isHidden = true
            self .performWSToGetNews()
        }
        else {
            
            if let isForYouSelected = UserDefaults.standard.string(forKey: Constant.isForYouSelected), isForYouSelected == "isForYouSelected" {
                
                if SharedManager.shared.force {
                    
                    self .viewForce.isHidden = false
                }
                else {
                    
                    self .viewForce.isHidden = true
                    self .performWSToGetNews()
                }
            }
            else {
                
                self .viewForce.isHidden = true
                self .performWSToGetNews()
            }
        }
    }
    
    func performWSToGetNews(isReloadView: Bool = false) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: NSLocalizedString("Check your internet Connection and try again.", comment: ""))
            return
        }
                
        //Reload View when user comes from App Background
        if isReloadView {
            
            SharedManager.shared.focussedCardTopicIndex = 0
            SharedManager.shared.focussedCardSourceIndex = 0
            SharedManager.shared.focussedCardIndex = 0
                    
            nextPaginate = ""
            prefetchState = .fetching
        }
        
        //encode pagination value
        nextPaginate = nextPaginate.encode()
        var querySt = ""
        var id = ""
        
        if SharedManager.shared.isSavedArticle {
            
            ANLoader.hide()
            querySt = "news/articles/archive?page=\(nextPaginate)"
        }
        else {
                        
            if SharedManager.shared.isShowTopic {
                
                if self.pageIndex < SharedManager.shared.subTopicsList.count {
                    id = SharedManager.shared.subTopicsList[self.pageIndex].context ?? ""
                }
                
                //print("topic id: ", id, SharedManager.shared.subTopicsList[self.pageIndex].name ?? "")
            }
            
            else if SharedManager.shared.isShowSource {
                
                id = SharedManager.shared.subSourcesList.first?.context ?? ""
                if self.pageIndex != 0 {
                    
                    if self.pageIndex < SharedManager.shared.subSourcesList.count {
                        id = SharedManager.shared.subSourcesList[self.pageIndex].context ?? ""
                    }
                }
                //print("source id: ", id, SharedManager.shared.subSourcesList[self.pageIndex].name ?? "")
                
            }
            else {
                
                if self.pageIndex < SharedManager.shared.headlinesList.count {
                    id = SharedManager.shared.headlinesList[self.pageIndex].id ?? ""
                    self.stGreeting = SharedManager.shared.headlinesList[self.pageIndex].greeting ?? ""
                }
                //print("home id: ", id, SharedManager.shared.headlinesList[self.pageIndex].title ?? "")
            }
            
            
            //print("Context id",id)
            querySt = "news/articles?context=\(id)&page=\(nextPaginate)&reader_mode=\(SharedManager.shared.readerMode)"
        }
        
        if !isPullToRefresh && self.nextPaginate.isEmpty {
            
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(querySt, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            if !self.isDataLoaded && self.isViewPresenting {
                
                if SharedManager.shared.curCategoryIndex == self.pageIndex {
                    self.isDataLoaded = true
                }
            }
            
            do {
                
                let FULLResponse = try
                    JSONDecoder().decode(articlesDC.self, from: response)
                
                DispatchQueue.main.async {

                    if self.isViewPresenting == false {
                        return
                    }
                                        
                    self.prefetchState = .idle
                    if self.nextPaginate == "" {
                        
                        //RESET PROGRESS BAR FOR CHANGING LIST/EXTEDED VIEW ACTION
                        self.resetCurrentProgressBarStatus()
                        self.articles.removeAll()
                    }
                    
                    //Reload View when user comes from App Background
                    if isReloadView {
                        
                        self.viewNoData.isHidden = true
                        self.viewNoSavedBG.isHidden = true
                        
                        if var arr = FULLResponse.articles, arr.count > 0 {
                            
                            let adsAvailable = UserDefaults.standard.bool(forKey: Constant.UD_adsAvailable)
                            if adsAvailable == true {
                                
                                //LOAD ADS
                                self.refreshAds()
                                
                                arr = arr.adding(articlesData(id: "", title: "", image: "", link: "", color: "", publish_time: "", source: nil, bullets: nil, topics: nil, status: "", type: ARTICLE_TYPE_ADS), afterEvery: SharedManager.shared.adsInterval)
                            }
                            
                            self.articles += arr
                            
                            self.tblExtendedView.setContentOffset(.zero, animated: false)
                            self.tblExtendedView.isHidden = false
                            self.tblExtendedView.reloadData()

                            if let meta = FULLResponse.meta {
                                self.nextPaginate = meta.next ?? ""
                            }
                            
                        }
                        else {
                            
                            self.viewNoData.isHidden = false
                            self.viewNoSavedBG.isHidden = true
                            self.tblExtendedView.isHidden = true
                        }
                        
                        self.activityIndicator.stopAnimating()

                    }
                    else {
                        
                        if var arr = FULLResponse.articles, arr.count > 0 {
                            
                            if SharedManager.shared.isSavedArticle == false {
                                
                                let adsAvailable = UserDefaults.standard.bool(forKey: Constant.UD_adsAvailable)
                                if adsAvailable == true {
                                    
                                    //LOAD ADS
                                    self.refreshAds()
                                    
                                    arr = arr.adding(articlesData(id: "", title: "", image: "", link: "", color: "", publish_time: "", source: nil, bullets: nil, topics: nil, status: "", type: ARTICLE_TYPE_ADS), afterEvery: SharedManager.shared.adsInterval)
                                }
                            }
                            
                            //insert into array
//                            self.articles += arr.filter { dict in
//                              return dict.type == ARTICLE_TYPE_SIMPLE || dict.type == ARTICLE_TYPE_EXTENDED || dict.type == ARTICLE_TYPE_VIDEO
//                            }
                            self.articles += arr
                            
                            if self.isPullToRefresh {
                                //print("REFRESHED!!!")
                                self.isPullToRefresh = false
                                self.refreshControlExtended.endRefreshing()
                            }
                            
                            //This is for Extended View

                            //Reload data
                            self.tblExtendedView.isHidden = false
                            self.tblExtendedView.reloadData()
                            self.isDirectionFindingNeeded = false
                            
                            if self.nextPaginate == "" && !self.isPullToRefresh {
                                
                            }
                            
                            //aassign string for pagination
                            if let meta = FULLResponse.meta {
                                self.nextPaginate = meta.next ?? ""
                            }
                        }
                        

                        if SharedManager.shared.isSavedArticle {
                            
                            if let arr = FULLResponse.articles, arr.count > 0 {
                                
                                SharedManager.shared.haveAritcles = true
                                self.viewNoSavedBG.isHidden = true
                            }
                            else {
                                
                                SharedManager.shared.haveAritcles = false
                                NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
                                self.articles.removeAll()
                                self.viewNoSavedBG.isHidden = false
                                self.tblExtendedView.reloadData()
                            }
                        }
                        else {
                            
                            self.viewNoData.isHidden = (self.articles.count > 0) ? true : false
                        }
                                                
                        //Get notification which is launched app
                        if SharedManager.shared.isAppLaunchedThroughNotification {
                            
                            SharedManager.shared.isAppLaunchedThroughNotification = false
                            NotificationCenter.default.post(name: Notification.Name.notifyGetPushNotificationArticleData, object: nil, userInfo: nil)
                        }
                                                
                        self.activityIndicator.stopAnimating()
                    }

                }
                
            } catch let jsonerror {
                
                self.prefetchState = .idle
                SharedManager.shared.showAPIFailureAlert()
                self.activityIndicator.stopAnimating()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            self.prefetchState = .idle
            //SharedManager.shared.showAPIFailureAlert()
            self.activityIndicator.stopAnimating()
            print("error parsing json objects",error)
        }
    }
    
    func performWSuggestMoreOrLess(_ id: String, isMoreOrLess: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: "Check your internet Connection and try again.")
            return
        }
        
        let query = isMoreOrLess ? "news/articles/\(id)/suggest/more" : "news/articles/\(id)/suggest/less"
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(query, method: .post, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    self.updateProgressbarStatus(isPause: false)
                    if status == Constant.STATUS_SUCCESS {
                        
                        if isMoreOrLess {
                            
                            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                            if var topController = keyWindow?.rootViewController {
                                while let presentedViewController = topController.presentedViewController {
                                    topController = presentedViewController
                                }
                                topController.view.makeToast("You'll see more stories like this", duration: 2.0, position: .bottom)
                            }
                        }
                        else {
                            
                            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                            if var topController = keyWindow?.rootViewController {
                                while let presentedViewController = topController.presentedViewController {
                                    topController = presentedViewController
                                }
                                
                                topController.view.makeToast("You'll see less stories like this", duration: 2.0, position: .bottom)
                            }
                        }
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: status)
                    }
                }
                
            } catch let jsonerror {
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            print("error parsing json objects",error)
        }
    }
    
    func performBlockSource(_ id: String, sourceName: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: "Check your internet Connection and try again.")
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        WebService.URLResponse("news/sources/block", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(BlockTopicDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    self.updateProgressbarStatus(isPause: false)
                    if status == Constant.STATUS_SUCCESS {
                        
                        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                        if var topController = keyWindow?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                            }
                            topController.view.makeToast("Blocked \(sourceName)", duration: 3.0, position: .bottom)
                        }
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: status)
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToFollowSource(_ id: String, name:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: "Check your internet Connection and try again.")
            return
        }
        
        ANLoader.showLoading(disableUI: false)
        
        let params = ["sources": id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse("news/sources/follow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(AddSourceDC.self, from: response)
                
                SharedManager.shared.isFav = true
                NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
                self.updateProgressbarStatus(isPause: false)
                if let _ = FULLResponse.sources {
                    
                    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                    if var topController = keyWindow?.rootViewController {
                        while let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                        }
                        
                        topController.view.makeToast("Followed \(name)", duration: 2.0, position: .bottom)
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performUnFollowUserSource(_ id: String, name:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: "Check your internet Connection and try again.")
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        
        ANLoader.showLoading(disableUI: true)
        WebService.URLResponse("news/sources/unfollow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    self.updateProgressbarStatus(isPause: false)
                    if status == Constant.STATUS_SUCCESS {
                        
                        SharedManager.shared.isFav = false
                        NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
                        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                        if var topController = keyWindow?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                            }
                            
                            topController.view.makeToast("Unfollowed \(name)", duration: 2.0, position: .bottom)
                        }
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: status)
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUnblockSource(_ id: String, name:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: "Check your internet Connection and try again.")
            return
        }
        ANLoader.showLoading(disableUI: true)
        
        let param = ["sources":id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/unblock", method: .post, parameters:param , headers: token, withSuccess: { (response) in
            
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                self.updateProgressbarStatus(isPause: false)
                if FULLResponse.message == "Success" {
                    
                    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                    if var topController = keyWindow?.rootViewController {
                        while let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                        }
                        
                        topController.view.makeToast("Unblocked \(name)", duration: 2.0, position: .bottom)
                    }
                }
                else {
                    
                    SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: FULLResponse.message ?? "")
                }
                ANLoader.hide()
            } catch let jsonerror {
                
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    
    func performGoToSource(_ article: articlesData) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: "Check your internet Connection and try again.")
            return
        }
        
        let id = article.source?.id ?? ""
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/info/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(sourceInfoDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let Info = FULLResponse.info {
                        
                        if SharedManager.shared.isShowTopic {
                            SharedManager.shared.isFromTopic = true
                        }
                        else {
                            SharedManager.shared.isFromTopic = false
                        }
                        
                        SharedManager.shared.isShowTopic = false
                        SharedManager.shared.isShowSource = true
                        
                        if let sources = Info.categories {
                            
                            SharedManager.shared.subSourcesList = sources
                        }
                        
                        let detailsVC = MainTopicSourceVC.instantiate(fromAppStoryboard: .Main)
                        detailsVC.subSourcesInfo = Info
                        detailsVC.delegateVC = self
                        if let source = article.source {
                            
                            detailsVC.selectedID = source.id ?? ""
                            detailsVC.isFav = Info.favorite ?? false
                            SharedManager.shared.subSourcesTitle = Info.name ?? ""
                            detailsVC.modalPresentationStyle = .fullScreen
                            self.navigationController?.pushViewController(detailsVC, animated: true)
                        }
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: "Related Sources not available")
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performArticleArchive(_ id: String, isArchived: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: "Check your internet Connection and try again.")
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
                        
                        if SharedManager.shared.isSavedArticle {
                            
                            SharedManager.shared.clearProgressBar()
                            self.getRefreshArticlesData()
                        }
                        
                        self.updateProgressbarStatus(isPause: false)
                        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                        if var topController = keyWindow?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                            }
                            topController.view.makeToast(isArchived ? "Saved Article" : "Removed Article", duration: 2.0, position: .bottom)
                        }
                        
                        
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: status)
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToShare(article: articlesData) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertView(source: self, title: "News in Bullets", message: "Check your internet Connection and try again.")
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/articles/\(article.id ?? "")/share/info", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ShareSheetDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    self.sourceBlock = FULLResponse.source_blocked ?? false
                    self.sourceFollow = FULLResponse.source_followed ?? false
                    self.shareTitle = FULLResponse.share_message ?? ""
                    self.article_archived = FULLResponse.article_archived ?? false
                    
                    self.urlOfImageToShare = URL(string: article.link ?? "")
                    self.shareTitle = FULLResponse.share_message ?? ""
                    
                    self.updateProgressbarStatus(isPause: true)
                    
                    let vc = BottomSheetVC.instantiate(fromAppStoryboard: .registration)
                    vc.delegateBottomSheet = self
                    vc.article = article
                    vc.sourceBlock = self.sourceBlock
                    vc.sourceFollow = self.sourceFollow
                    vc.article_archived = self.article_archived
                    vc.share_message = FULLResponse.share_message ?? ""
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
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
        if let vCell = self.getCurrentFocussedCell() as? VideoPlayerView {
            vCell.resetVisibleVideoPlayer()
        }

    }
    
    func updateProgressbarStatus(isPause: Bool) {
        
        SharedManager.shared.bulletPlayer?.pause()
        
        if isPause {
            
            if SharedManager.shared.isShowTopic {
                
                if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: SharedManager.shared.focussedCardTopicIndex, section: 0)) as? HomeCardCell {
                    
                    cell.pauseAudioAndProgress(isPause:true)
                    
                }
                else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: SharedManager.shared.focussedCardTopicIndex, section: 0)) as? HomeListViewCC {
                    
                    cell.pauseAudioAndProgress(isPause:true)
                    
                }
                else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: SharedManager.shared.focussedCardTopicIndex, section: 0)) as? VideoPlayerView {
                    
                    cell.playVideo(isPause: true)
                    
                }
            }
            else if SharedManager.shared.isShowSource {
                
                if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: SharedManager.shared.focussedCardSourceIndex, section: 0)) as? HomeCardCell {
                    
                    cell.pauseAudioAndProgress(isPause:true)
                }
                else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: SharedManager.shared.focussedCardSourceIndex, section: 0)) as? HomeListViewCC {
                    
                    cell.pauseAudioAndProgress(isPause:true)
                }
                else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: SharedManager.shared.focussedCardSourceIndex, section: 0)) as? VideoPlayerView {
                    
                    cell.playVideo(isPause: true)
                    
                }
            }
            else {
                
                if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: SharedManager.shared.focussedCardIndex, section: 0)) as? HomeCardCell {
                    
                    cell.pauseAudioAndProgress(isPause:true)
                    
                }
                else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: SharedManager.shared.focussedCardIndex, section: 0)) as? HomeListViewCC {
                    
                    cell.pauseAudioAndProgress(isPause:true)
                    
                }
                else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: SharedManager.shared.focussedCardIndex, section: 0)) as? VideoPlayerView {
                    
                    cell.playVideo(isPause: true)
                    
                }
            }
        }
        else {
            
            if SharedManager.shared.isShowTopic {
                
                if let cell = self.tblExtendedView.cellForRow(at: IndexPath(item: SharedManager.shared.focussedCardTopicIndex, section: 0)) as? HomeCardCell {
                    
                    cell.pauseAudioAndProgress(isPause:false)
                }
                else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(item: SharedManager.shared.focussedCardTopicIndex, section: 0)) as? HomeListViewCC {
                    
                    cell.pauseAudioAndProgress(isPause:false)
                }
                
                else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: SharedManager.shared.focussedCardTopicIndex, section: 0)) as? VideoPlayerView {
                    
                    cell.playVideo(isPause: false)
                }
            }
            
            else if SharedManager.shared.isShowSource {
                
                if let cell = self.tblExtendedView.cellForRow(at: IndexPath(item: SharedManager.shared.focussedCardSourceIndex, section: 0)) as? HomeCardCell {
                    
                    cell.pauseAudioAndProgress(isPause:false)
                }
                else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(item: SharedManager.shared.focussedCardSourceIndex, section: 0)) as? HomeListViewCC {
                    
                    cell.pauseAudioAndProgress(isPause:false)
                }
                else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: SharedManager.shared.focussedCardSourceIndex, section: 0)) as? VideoPlayerView {
                    
                    cell.playVideo(isPause: false)
                    
                }
            }
            
            else {
                
                if let cell = self.tblExtendedView.cellForRow(at: IndexPath(item: SharedManager.shared.focussedCardIndex, section: 0)) as? HomeCardCell {
                    
                    cell.pauseAudioAndProgress(isPause:false)
                }
                else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(item: SharedManager.shared.focussedCardIndex, section: 0)) as? HomeListViewCC {
                    
                    cell.pauseAudioAndProgress(isPause:false)
                }
                else if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: SharedManager.shared.focussedCardIndex, section: 0)) as? VideoPlayerView {
                    
                    cell.playVideo(isPause: false)
                    
                }
            }
        }
    }
    
    func setupIndexPathForSelectedArticleCardAndListView(_ index: Int) {
        
        if SharedManager.shared.isShowTopic {
            SharedManager.shared.focussedCardTopicIndex = index
        }
        else if SharedManager.shared.isShowSource || SharedManager.shared.isViewArticleSourceNotification {
            SharedManager.shared.focussedCardSourceIndex = index
        }
        else {
            SharedManager.shared.focussedCardIndex = index
        }
    }
    
    func getIndexPathForSelectedArticleCardAndListView() -> Int {
        
        var index = 0
        if SharedManager.shared.isShowTopic {
            index = SharedManager.shared.focussedCardTopicIndex
        }
        else if SharedManager.shared.isShowSource || SharedManager.shared.isViewArticleSourceNotification {
            index = SharedManager.shared.focussedCardSourceIndex
        }
        else {
            index = SharedManager.shared.focussedCardIndex
        }

        return index
    }
    
    func getCurrentFocussedCell() -> UITableViewCell {
        
        let index = self.getIndexPathForSelectedArticleCardAndListView()
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) {
            return cell
        }

        return UITableViewCell()
    }
}

//MARK:- BottomSheetVC Delegate methods
extension ForYouVC: BottomSheetVCDelegate {
    
    func didTapUpdateAudioAndProgressStatus() {
        
        self.updateProgressbarStatus(isPause: false)
    }
    
    func didTapDissmisReportContent() {
        
        self.updateProgressbarStatus(isPause: false)
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.view.makeToast("Report concern sent successfully.", duration: 3.0, position: .bottom)
        }
    }
    
    func didTapBottomShareSheetAction(sender: UIButton, article: articlesData) {
        
        if sender.tag == 1 {
            
            //Save article
            performArticleArchive(article.id ?? "", isArchived: !self.article_archived)
        }
        else if sender.tag == 2 {
            
            //Share
            let shareContent: [Any] = [self.shareTitle]
            
            let activityVc = UIActivityViewController(activityItems: shareContent, applicationActivities: [])
            activityVc.excludedActivityTypes = [.assignToContact, .print, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .openInIBooks, .markupAsPDF]
            
            activityVc.completionWithItemsHandler = { activity, success, items, error in
                
                if activity == nil || success == true {
                    // User canceled
                    self.updateProgressbarStatus(isPause: false)
                    return
                }
                // User completed activity
            }
            
            DispatchQueue.main.async {
                
                self.updateProgressbarStatus(isPause: true)
                self.present(activityVc, animated: true)
            }
        }
        else if sender.tag == 3 {
            
            //Go to Source
            self.performGoToSource(article)
            
        }
        else if sender.tag == 4 {
            
            //Follow Source
            if self.sourceFollow {
                
                self.performUnFollowUserSource(article.source?.id ?? "", name: article.source?.name ?? "")
            }
            else {
                
                self.performWSToFollowSource(article.source?.id ?? "", name: article.source?.name ?? "")
                
            }
        }
        else if sender.tag == 5 {
            
            //Block articles from Source
            
            if self.sourceBlock {
                
                self.performWSToUnblockSource(article.source?.id ?? "", name: article.source?.name ?? "")
            }
            else {
                
                self.performBlockSource(article.source?.id ?? "", sourceName: article.source?.name ?? "")
            }
            
        }
        else if sender.tag == 6 {
            
            //Report content
            
        }
        else if sender.tag == 7 {
            
            //More like this
            SharedManager.shared.setAppsFlyerEventsReport(eventType: Constant.analyticsEvents.moreLikeThisClick, eventDescription: "")
            self.performWSuggestMoreOrLess(article.id ?? "", isMoreOrLess: true)
            
        }
        else if sender.tag == 8 {
            
            //I don't like this
            SharedManager.shared.setAppsFlyerEventsReport(eventType: Constant.analyticsEvents.lessLikeThisClick, eventDescription: "")
            self.performWSuggestMoreOrLess(article.id ?? "", isMoreOrLess: false)
        }
    }
}

//MARK:- HomeCardCell Delegate methods
extension ForYouVC: HomeCardCellDelegate, YoutubeCardCellDelegate, HomeCardAdsCCDelegate, videoPlayerViewDelegates {
    
    func resetSelectedArticle() {
        
        //RESET EXTENDED VIEW CELL WHEN EXTENDED VIEW VISIBLE
        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
            cell.btnVolume.isHidden = true
        }
        
        //RESET VIDEO VIEW CC
        if let vCell = self.getCurrentFocussedCell() as? HomeListViewCC {
            vCell.btnVolume.isHidden = true
        }
    }
    //ARTICLES SWIPE
    func layoutUpdate() {
        
        self.tblExtendedView.beginUpdates()
        self.tblExtendedView.endUpdates()
    }
    
    @objc func didTapOpenSourceURL(sender: UITapGestureRecognizer) {

        // When focus index of card and the user taps index not same then return it
        let row = sender.view?.tag ?? 0
        print("UITapGestureRecognizer: ", row)
        let content = self.articles[row]
        updateProgressbarStatus(isPause: true)
        
        let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
        vc.delegateVC = self
        vc.webURL = content.link ?? ""
        vc.titleWeb = content.source?.name ?? ""
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
        
    @objc func didTapPlayYoutube(_ button: UIButton) {
        
        //EXTENDED/LIST VIEW TAP TO PLAY YOUTUBE
        updateProgressbarStatus(isPause: true)
        
        let index = button.tag
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? YoutubeCardCell {
            
//            self.curVisibleYoutubeCardCell = cell
            if cell.videoPlayer.ready {
                
                cell.videoPlayer.play()
                cell.imgPlay.isHidden = true
                cell.activityLoader.startAnimating()
            }
        }
    }
    
    
    @objc func didTapShare(button: UIButton) {
        
        SharedManager.shared.setAppsFlyerEventsReport(eventType: Constant.analyticsEvents.shareClick, eventDescription: "")

        self.updateProgressbarStatus(isPause: true)
        let index = button.tag
        let content = self.articles[index]
        performWSToShare(article: content)
    }
    
    @objc func didTapSource(button: UIButton) {
        
        //EXTENDED VIEW TAP TO OPEN SOURCE
        if SharedManager.shared.isShowSource || SharedManager.shared.isViewArticleSourceNotification || SharedManager.shared.isSavedArticle { return }
        //NotificationCenter.default.post(name: Notification.Name.notifyToRemoveVCObservers, object: nil)
        SharedManager.shared.setAppsFlyerEventsReport(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
        
        self.updateProgressbarStatus(isPause: true)
        button.isUserInteractionEnabled = false
        let index = button.tag

        let content = self.articles[index]
        self.performGoToSource(content)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            button.isUserInteractionEnabled = true
        }
    }
    
    //<---
    // Public delegate methods for all cells are here
    func handleLongPressHold(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        var index: Int = 0
        if SharedManager.shared.isShowTopic {
            index = SharedManager.shared.focussedCardTopicIndex
        }
        else if SharedManager.shared.isShowSource {
            index = SharedManager.shared.focussedCardSourceIndex
        }
        else {
            index = SharedManager.shared.focussedCardIndex
        }
                
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
        SharedManager.shared.bulletsMaxCount = 0
        
        //Data always load from first position
        var index = 0
        if SharedManager.shared.isShowTopic {
            index = SharedManager.shared.focussedCardTopicIndex
        }
        else if SharedManager.shared.isShowSource || SharedManager.shared.isViewArticleSourceNotification {
            index = SharedManager.shared.focussedCardSourceIndex
        }
        else {
            index = SharedManager.shared.focussedCardIndex
        }
        
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

        
        if index < self.articles.count && self.articles.count > 1 {
            
            var newIndex = 0
            newIndex = isMoveNext ? index + 1 : index - 1
            newIndex = newIndex >= self.articles.count ? 0 : newIndex
            let newIndexPath: IndexPath = IndexPath(item: newIndex, section: 0)
            
            UIView.animate(withDuration: 0.3) {
                
                self.tblExtendedView.selectRow(at: newIndexPath, animated: false, scrollPosition: .top)
                //self.tblExtendedView.scrollToRow(at: newIndexPath, at: .top, animated: false)
                self.tblExtendedView.layoutIfNeeded()
                
            } completion: { (finished) in
                
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
                else if let vCell = self.tblExtendedView.cellForRow(at: newIndexPath) as? VideoPlayerView {
                    
                    vCell.videoControllerStatus(isHidden: true)
                    vCell.playVideo(isPause: false)
                    
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
extension ForYouVC: UIActivityItemSource {
    
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

//MARK:- RETRIVED ADS DELEGATE
extension ForYouVC: GADUnifiedNativeAdLoaderDelegate {
    
    func refreshAds() {
        
        //Ads Data Load
        let options = GADMultipleAdsAdLoaderOptions()
        options.numberOfAds = numAdsToLoad
        
        // Prepare the ad loader and start loading ads.
        adLoader = GADAdLoader(adUnitID: adUnitID,
                               rootViewController: self,
                               adTypes: [.unifiedNative],
                               options: [options])
        adLoader.delegate = self
        adLoader.load(GADRequest())
        
    }
    
    /// Add native ads to the tableViewItems list.
    func addNativeAds() {
        
        if nativeAds.count <= 0 {
            return
        }
    }
    
    // MARK: - GADAdLoaderDelegate
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        //print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        ////print("Received native ad: \(nativeAd)")
        
        // Add the native ad to the list of native ads.
        nativeAds.append(nativeAd)
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        
        addNativeAds()
    }
}

//MARK:- CARD VIEW TABLE DELEGATE
extension ForYouVC: UITableViewDelegate, UITableViewDataSource {
    
    //func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let content = self.articles[indexPath.row]
        //LOCAL VIDEO TYPE
        if content.type ?? "" == ARTICLE_TYPE_VIDEO {

            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            let videoPlayer = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER, for: indexPath) as! VideoPlayerView
         //   videoPlayer.delegateVideoView = self
            videoPlayer.delegate = self
            videoPlayer.delegateLikeComment = self

//            videoPlayer.lblViewCount.text = "0"
            if let info = content.meta {
                
//                videoPlayer.lblViewCount.text = info.view_count
            }
            
            videoPlayer.selectionStyle = .none
            let sourceURL = content.source?.icon ?? ""
            videoPlayer.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: nil)
            
            videoPlayer.btnShare.tag = indexPath.row
            videoPlayer.btnSource.tag = indexPath.row
            
            videoPlayer.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
            videoPlayer.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            
            //LEFT - RIGHT ACTION
            videoPlayer.lblSource.text = content.source?.name?.uppercased()
            videoPlayer.lblSource.addTextSpacing(spacing: 2.5)
            
            if let pubDate = content.publish_time {
                videoPlayer.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate)
            }
            videoPlayer.lblTime.addTextSpacing(spacing: 1.25)
            
            if (SharedManager.shared.focussedCardTopicIndex == indexPath.row || SharedManager.shared.focussedCardSourceIndex == indexPath.row || SharedManager.shared.focussedCardIndex == indexPath.row) {
                self.curVideoVisibleCell = videoPlayer
            }
            
            if let bullets = content.bullets {
                
                videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: false)
                
                if SharedManager.shared.isShowTopic {
                    
                    videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: SharedManager.shared.focussedCardTopicIndex == indexPath.row ? true : false)
                    
                }
                else if SharedManager.shared.isShowSource || SharedManager.shared.isViewArticleSourceNotification {
                    
                    videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: SharedManager.shared.focussedCardSourceIndex == indexPath.row ? true : false)
                }
                else {
                    
                    videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: SharedManager.shared.focussedCardIndex == indexPath.row ? true : false)
                }
            }
            
            return videoPlayer
        }
        
        //GOOGLE ADS CELL
        else if content.type ?? "" == ARTICLE_TYPE_ADS {
            
            SharedManager.shared.isVolumnOffCard = true
            
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            //print("Volume 36")
            
            let adCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_ADS_LIST, for: indexPath) as! HomeListAdsCC //was
            adCell.selectionStyle = .none
            //adCell.delegateAdsCardCell = self
            adCell.setupCell()
            
            //load ads from local array of ads
            let nativeAd: GADUnifiedNativeAd?
            
            let nativeAdsIndex = max(0, Int((indexPath.row / 5) - 1))
            if nativeAdsIndex < nativeAds.count {
                nativeAd = nativeAds[nativeAdsIndex]
            }
            else {
                nativeAd = nativeAds.first
            }
            
            if let nativeAd = nativeAd {
                
                /// Set the native ad's rootViewController to the current view controller.
                nativeAd.rootViewController = self
                
                // Get the ad view from the Cell. The view hierarchy for this cell is defined in
                // UnifiedNativeAdCell.xib.
                let adView : GADUnifiedNativeAdView = adCell.contentView.subviews
                    .first as! GADUnifiedNativeAdView
                
                // Associate the ad view with the ad object.
                // This is required to make the ad clickable.
                adView.nativeAd = nativeAd
                adView.mediaView?.contentMode = .scaleAspectFill
                
                (adView.headlineView as? UILabel)?.theme_textColor = GlobalPicker.textBWColor
                (adView.headlineView as? UILabel)?.text = nativeAd.headline
                adView.headlineView?.isHidden = nativeAd.headline == nil
                
                (adView.bodyView as? UILabel)?.theme_textColor = GlobalPicker.textBWColor
                (adView.bodyView as? UILabel)?.text = nativeAd.body
                adView.bodyView?.isHidden = nativeAd.body == nil
                
                //                        (adView.callToActionView as? UIButton)?.theme_backgroundColor = GlobalPicker.adsButtonBGColor
                (adView.callToActionView as? UIButton)?.setTitleColor(.white, for: .normal)
                //  (adView.callToActionView as? UIButton)?.theme_setTitleColor(UIColor.white, forState: .normal)
                (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
                adView.callToActionView?.isHidden = nativeAd.callToAction == nil
                
                //                        (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
                //                        adView.iconView?.isHidden = nativeAd.icon == nil
                
                //   (adView.starRatingView as? UIImageView)?.image = imageOfStars(fromStarRating:nativeAd.starRating)
                adView.starRatingView?.isHidden = nativeAd.starRating == nil
                
                //                        (adView.storeView as? UILabel)?.theme_textColor = GlobalPicker.textColor
                //                        (adView.storeView as? UILabel)?.text = nativeAd.store
                //                        adView.storeView?.isHidden = nativeAd.store == nil
                
                //                        (adView.priceView as? UILabel)?.theme_textColor = GlobalPicker.textColor
                //                        (adView.priceView as? UILabel)?.text = nativeAd.price
                //                        adView.priceView?.isHidden = nativeAd.price == nil
                
                (adView.advertiserView as? UILabel)?.theme_textColor = GlobalPicker.textBWColor
                (adView.advertiserView as? UILabel)?.text = nativeAd.advertiser
                adView.advertiserView?.isHidden = nativeAd.advertiser == nil
                
                // In order for the SDK to process touch events properly, user interaction should be disabled.
                adView.callToActionView?.isUserInteractionEnabled = false
            }
            return adCell
        }
        
        //YOUTUBE CARD CELL
        else if content.type?.uppercased() == ARTICLE_TYPE_YOUTUBE {
            
            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            //print("Volume 37")
            
            let youtubeCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_YOUTUBE_CARD, for: indexPath) as! YoutubeCardCell
            youtubeCell.langCode = content.source?.language ?? ""
            youtubeCell.delegateYoutubeCardCell = self
            youtubeCell.delegateLikeComment = self
            youtubeCell.selectionStyle = .none
            
            youtubeCell.url = content.link ?? ""
            youtubeCell.urlThumbnail = content.bullets?.first?.image ?? ""
            
            let sourceURL = content.source?.icon ?? ""
            youtubeCell.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: nil)
            
            youtubeCell.btnShare.tag = indexPath.row
            youtubeCell.btnSource.tag = indexPath.row
            youtubeCell.btnPlayYoutube.tag = indexPath.row

            youtubeCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
            youtubeCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            youtubeCell.btnPlayYoutube.addTarget(self, action: #selector(didTapPlayYoutube(_:)), for: .touchUpInside)

            //LEFT - RIGHT ACTION
            youtubeCell.lblSource.text = content.source?.name?.uppercased()
            youtubeCell.lblSource.addTextSpacing(spacing: 2.5)
            
            if let pubDate = content.publish_time {
                youtubeCell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate)
            }
            youtubeCell.lblTime.addTextSpacing(spacing: 1.25)
            
//            youtubeCell.lblViewCount.text = "0"
            if let info = content.meta {
                
//                youtubeCell.lblViewCount.text = info.view_count
            }
            
            //Selected cell
            if (SharedManager.shared.focussedCardTopicIndex == indexPath.row || SharedManager.shared.focussedCardSourceIndex == indexPath.row || SharedManager.shared.focussedCardIndex == indexPath.row) {
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
            
            if content.type ?? "" == ARTICLE_TYPE_SIMPLE {
                
                //LIST VIEW DESIGN CELL- SMALL CELL
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW, for: indexPath) as? HomeListViewCC else { return UITableViewCell() }
                cell.backgroundColor = UIColor.clear
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                cell.selectionStyle = .none
                cell.delegateHomeListCC = self
                cell.delegateLikeComment = self
                
                let url = content.image ?? ""
                cell.imageURL = url
                
                cell.lblSource.text = content.source?.name?.uppercased()
                cell.lblSource.theme_textColor = GlobalPicker.textSourceColor
                cell.lblSource.addTextSpacing(spacing: 1.25)
                cell.langCode = content.source?.language ?? ""
                if let pubDate = content.publish_time {
                    cell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate)
                }
                
                cell.lblTime.addTextSpacing(spacing: 1.25)
                
                cell.btnShare.tag = indexPath.row
                cell.btnSource.tag = indexPath.row
                cell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
                cell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
                tapGesture.view?.tag = indexPath.row
                cell.viewContainer.addGestureRecognizer(tapGesture)

                
                if let _ = content.bullets {
                    
//                    cell.lblViewCount.text = "0"
                    if let info = content.meta {
                        
//                        cell.lblViewCount.text = info.view_count
                    }
                    
                    //Set Child Collectionview DataSource and Layout
                    cell.setupCellBulletsView(article: content, isAudioPlay: false, row: indexPath.row, isMute: true)

                    if SharedManager.shared.isShowTopic {
                        
                        cell.setupCellBulletsView(article: content, isAudioPlay: SharedManager.shared.focussedCardTopicIndex == indexPath.row ? true : false, row: indexPath.row, isMute: content.mute ?? false)
                    }
                    else if SharedManager.shared.isShowSource || SharedManager.shared.isViewArticleSourceNotification {
                        
                        cell.setupCellBulletsView(article: content, isAudioPlay: SharedManager.shared.focussedCardSourceIndex == indexPath.row ? true : false, row: indexPath.row, isMute: content.mute ?? false)
                    }
                    else {
                        
                        cell.setupCellBulletsView(article: content, isAudioPlay: SharedManager.shared.focussedCardIndex == indexPath.row ? true : false, row: indexPath.row, isMute: content.mute ?? false)
                    }
                }
                
                return cell
            }
            else {
                
                //CARD VIEW DESIGN CELL- LARGE CELL
                guard let cardCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_CARD, for: indexPath) as? HomeCardCell else { return UITableViewCell() }
                cardCell.backgroundColor = UIColor.clear
                cardCell.setNeedsLayout()
                cardCell.layoutIfNeeded()
                cardCell.selectionStyle = .none
                cardCell.delegateHomeCard = self
                cardCell.delegateLikeComment = self
                cardCell.langCode = content.source?.language ?? ""

                //LEFT - RIGHT ACTION
                cardCell.btnLeft.theme_tintColor = GlobalPicker.btnCellTintColor
                cardCell.btnRight.theme_tintColor = GlobalPicker.btnCellTintColor
                cardCell.constraintArcHeight.constant = cardCell.viewGestures.frame.size.height - 20
                cardCell.btnLeft.accessibilityIdentifier = String(indexPath.row)
                cardCell.btnRight.accessibilityIdentifier = String(indexPath.row)
                
                // image Preloading logic
                if articles.count > indexPath.row + 1 {
                    
                    let preContent = articles[indexPath.row + 1]
                    cardCell.imgPreLoaded?.sd_setImage(with: URL(string: preContent.image ?? ""))
                }
                if articles.count > indexPath.row + 2 {
                    
                    let preContent = articles[indexPath.row + 2]
                    cardCell.imgPreLoaded?.sd_setImage(with: URL(string: preContent.image ?? ""))
                }
                
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
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
                tapGesture.view?.tag = indexPath.row
                print("cardCell.viewGestures: ", indexPath.row)
                cardCell.addGestureRecognizer(tapGesture)

                cardCell.btnShare.tag = indexPath.row
                cardCell.btnSource.tag = indexPath.row
                cardCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
                cardCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)

                cardCell.lblSource.text = content.source?.name?.uppercased()
                cardCell.lblSource.addTextSpacing(spacing: 2.5)
                
                let sourceURL = content.source?.icon ?? ""
                cardCell.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
                
                if let pubDate = content.publish_time {
                    cardCell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate)
                }
                
//                cardCell.lblViewCount.text = "0"
                if let info = content.meta {
                    
//                    cardCell.lblViewCount.text = info.view_count
                }
                
                cardCell.lblTime.addTextSpacing(spacing: 1.25)
                cardCell.setupSlideScrollView(article: content, isAudioPlay: false, row: indexPath.row, isMute: true)
                                
                if SharedManager.shared.isShowTopic {
                    
                    cardCell.setupSlideScrollView(article: content, isAudioPlay: SharedManager.shared.focussedCardTopicIndex == indexPath.row ? true : false, row: indexPath.row, isMute: content.mute ?? false)
                }
                else if SharedManager.shared.isShowSource || SharedManager.shared.isViewArticleSourceNotification {
                    
                    cardCell.setupSlideScrollView(article: content, isAudioPlay: SharedManager.shared.focussedCardSourceIndex == indexPath.row ? true : false, row: indexPath.row, isMute: content.mute ?? false)
                }
                else {
                    
                    cardCell.setupSlideScrollView(article: content, isAudioPlay: SharedManager.shared.focussedCardIndex == indexPath.row ? true : false, row: indexPath.row, isMute: content.mute ?? false)
                }
                
                return cardCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let content = self.articles[indexPath.row]
        
        if content.type ?? "" == ARTICLE_TYPE_SIMPLE {
            return HEIGHT_HOME_LISTVIEW
        }
        else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if !(self.stGreeting.isEmpty) {
            
            let headerView = UIView(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            
            let label = UILabel()
            label.frame = CGRect(x: 4, y: 0, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            
            label.text = self.stGreeting
            label.font = UIFont.init(name: Constant.FONT_NEU_BOLD, size: 22)
            label.theme_textColor = GlobalPicker.textColor
            
            headerView.addSubview(label)
            return headerView
        }
        
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return self.stGreeting.isEmpty ? CGFloat.leastNormalMagnitude : 50
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //print("indexPath:...", indexPath.row)
        if let cell = cell as? VideoPlayerView {
            cell.resetVisibleVideoPlayer()
        }
//        else if let cell = cell as? HomeCardCell {
//            cell.resetVisibleCard()
//        }
//        else if let cell = cell as? HomeListViewCC {
//            cell.resetVisibleListCell()
//        }
        else if let cell = cell as? YoutubeCardCell {
            cell.resetYoutubeCard()
        }
    }
}


//MARK:- SCROLL VIEW DELEGATE
extension ForYouVC: UIScrollViewDelegate {
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //        if isDirectionFindingNeeded {
        //            //print("lastContentOffset current", scrollView.contentOffset.y)
        let delta = scrollView.contentOffset.y - lastContentOffset
        
        //            //print("lastContentOffset delta", delta)
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        if (scrollView.contentOffset.y + 1 + scrollViewHeight >= scrollContentSizeHeight) {
            //print("scroll view reached bottom")
            isDirectionFindingNeeded = true
        }
        if isDirectionFindingNeeded == false {
            if lastContentOffset > 0 {
                if delta < 0 {
                    
                    if self.tableViewTopConstraint.constant != self.normalTableViewTopConstraint {
                        
                        if let ptcTBC = tabBarController as? PTCardTabBarController {
                            ptcTBC.showTabBar(true, animated: true)
                        }
                        
                        UIView.animate(withDuration: 0.25) {
                            self.tableViewTopConstraint.constant = self.normalTableViewTopConstraint
                            
//                            self.collectionViewTopConstraint.constant = self.normalCollectionViewTopConstraint
                            //                        self.tblExtendedView.layoutIfNeeded()
                            //                        self.collectioViewList.layoutIfNeeded()
                        }
                    }
                    self.scrollDelegate?.homeScrollViewDidScroll(delta: -1)
                } else {
                    
                    if self.tableViewTopConstraint.constant != self.extendedTableViewTopConstraint {
                        
                        if let ptcTBC = tabBarController as? PTCardTabBarController {
                            ptcTBC.showTabBar(false, animated: true)
                        }
                        
                        UIView.animate(withDuration: 0.25) {
                            self.tableViewTopConstraint.constant = self.extendedTableViewTopConstraint
//                            self.collectionViewTopConstraint.constant = self.extendedCollectionViewTopConstraint
    //                        self.tblExtendedView.layoutIfNeeded()
    //                        self.collectioViewList.layoutIfNeeded()
                        }
                    }
                    self.scrollDelegate?.homeScrollViewDidScroll(delta: 1)
                }
            } else {
                
                if self.tableViewTopConstraint.constant != self.normalTableViewTopConstraint {
                    
                    if let ptcTBC = tabBarController as? PTCardTabBarController {
                        ptcTBC.showTabBar(true, animated: true)
                    }
                    
                    UIView.animate(withDuration: 0.25) {
                        self.tableViewTopConstraint.constant = self.normalTableViewTopConstraint
//                        self.collectionViewTopConstraint.constant = self.normalCollectionViewTopConstraint
                        //                        self.tblExtendedView.layoutIfNeeded()
                        //                        self.collectioViewList.layoutIfNeeded()
                    }
                }
                self.scrollDelegate?.homeScrollViewDidScroll(delta: -1)
            }
        }
        //        }
        lastContentOffset = scrollView.contentOffset.y
        //        //print("lastContentOffset after", lastContentOffset)
        
        //scrollView.bounces = true
        let prefetchThreshold: CGFloat = BOTTOM_INSET + 30 // prefetching will start prefetchThreshold (ex.100pts) above the bottom of the scroll view
        if scrollView.contentOffset.y > scrollView.contentSize.height - tblExtendedView.frame.height - prefetchThreshold {
            if prefetchState == .idle {
                //print("mahesh nextPaginate", nextPaginate)
                guard prefetchState == .idle && !(self.nextPaginate.isEmpty) else { return }
                prefetchState = .fetching
                performWSToGetNews()
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        lastContentOffset = scrollView.contentOffset.y
//        //print("lastContentOffset", lastContentOffset)
        isDirectionFindingNeeded = false

        ////print("scrollViewWillBeginDragging")
        if !isPullToRefresh && !SharedManager.shared.isViewArticleSourceNotification {
            updateProgressbarStatus(isPause: true)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        ////print("scrollViewWillBeginDecelerating")
        if !isPullToRefresh && !SharedManager.shared.isViewArticleSourceNotification {
            updateProgressbarStatus(isPause: true)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //ScrollView for ListView Mode
        if decelerate { return }
        if !isPullToRefresh && !SharedManager.shared.isViewArticleSourceNotification {
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
        if !isPullToRefresh && !SharedManager.shared.isViewArticleSourceNotification {
            
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
    
    func scrollToTopVisibleExtended() {
        
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
        
        if let indexPath = indexPathVisible, indexPath.row != getIndexPathForSelectedArticleCardAndListView() {
            
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
            if let vCell = self.getCurrentFocussedCell() as? VideoPlayerView {
                vCell.resetVisibleVideoPlayer()
            }
            
            //
            self.setupIndexPathForSelectedArticleCardAndListView(indexPath.row)

            //ASSIGN CELL FOR CARD VIEW
            if let cell = tblExtendedView.cellForRow(at: indexPath) as? HomeCardCell {
                
                if self.prefetchState == .idle && articles.count > 0 {
                    
                    if !self.isPullToRefresh {
                        
                        // Play audio only when vc is visible
                        if isViewPresenting {

                            
                            SharedManager.shared.isVideoCellSelected = false
                            let content = self.articles[indexPath.row]
                            cell.setupSlideScrollView(article: content, isAudioPlay: true, row: indexPath.row, isMute: content.mute ?? true)
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

                            SharedManager.shared.isVideoCellSelected = false
                            let content = self.articles[indexPath.row]
                            cell.setupCellBulletsView(article: content, isAudioPlay: true, row: indexPath.row, isMute: content.mute ?? true)
                            print("audio playing")
                        } else {
                            print("audio playing skipped")
                        }
                        
                    }
                }
            }
            else if let yCell = tblExtendedView.cellForRow(at: indexPath) as? YoutubeCardCell {
                
                self.curYoutubeVisibleCell = yCell
                yCell.setFocussedYoutubeView()
            }
            else if let vCell = tblExtendedView.cellForRow(at: indexPath) as? VideoPlayerView {
                
                self.curVideoVisibleCell = vCell
                SharedManager.shared.isVideoCellSelected = true
                vCell.playVideo(isPause: false)
            }
        }
        else {
            
            if let yCell = self.getCurrentFocussedCell() as? YoutubeCardCell {
     
                SharedManager.shared.isVideoCellSelected = false
                yCell.resetYoutubeCard()
            }
            else {
                if let yCell = self.curYoutubeVisibleCell {
                    
                    SharedManager.shared.isVideoCellSelected = false
                    yCell.resetYoutubeCard()
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
}

//MARK:- WEBVIEW DISMISS
extension ForYouVC: webViewVCDelegate, MainTopicSourceVCDelegate {
    
    func dismissMainTopicSourceVC() {
        
        print("isHome called....")
        
        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
            cell.restartProgressbar()
        }
        else if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
            cell.restartProgressbar()
        }
        else if let cell = self.getCurrentFocussedCell() as? VideoPlayerView {
            cell.playVideo(isPause: false)
        }
    }
    
    func dismissWebViewVC() {
        
        print("dismissWebViewVC called....")

        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
            cell.restartProgressbar()
        }
        else if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
            cell.restartProgressbar()
        }
        else if let cell = self.getCurrentFocussedCell() as? VideoPlayerView {
            cell.playVideo(isPause: false)
        }
        
    }
}



// MARK: - Comment Loike Delegates
extension ForYouVC: LikeCommentDelegate {
    
    func didTapCommentsButton(cell: UITableViewCell) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {return}
        let content = self.articles[indexPath.row]
        
        updateProgressbarStatus(isPause: true)
        
        let vc = CommentsVC.instantiate(fromAppStoryboard: .Home)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        navVC.modalPresentationStyle = .overFullScreen
        self.present(navVC, animated: true, completion: nil)
        
    }
    
    func didTapLikeButton(cell: UITableViewCell) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {return}
        
        let content = self.articles[indexPath.row]
    }
    
}
