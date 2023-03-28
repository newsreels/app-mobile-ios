//
//  BulletDetailsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 12/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FBAudienceNetwork
import ImageSlideshow
import Photos
import FBSDKShareKit
import SwiftUI

protocol BulletDetailsVCLikeDelegate: AnyObject {
    func likeUpdated(articleID: String, isLiked: Bool, count: Int)
    func commentUpdated(articleID: String, count: Int)
    func backButtonPressed(cell:HomeDetailCardCell?)
}

protocol BulletDetailsVCDelegate: AnyObject {
    func dismissBulletDetailsVC(selectedArticle: articlesData?)
}

class BulletDetailsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var constraintNavTop: NSLayoutConstraint!
    @IBOutlet weak var viewNav: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var gradientTopicView: UIView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var closeImage: UIImageView!
    @IBOutlet weak var closeImageShadowView: UIView!
    
    //Like and Comment
//    @IBOutlet weak var viewLikeCommentBG: UIView!
//    @IBOutlet weak var lblCommentsCount: UILabel!
//    @IBOutlet weak var lblLikeCount: UILabel!
//    @IBOutlet weak var imgLike: UIImageView!
//    @IBOutlet weak var imgComment: UIImageView!
    public var minimumVelocityToHide: CGFloat = 1500
    public var minimumScreenRatioToHide: CGFloat = 0.5
    public var animationDuration: TimeInterval = 0.2
    
    var selectedArticleData: articlesData?
    var isApiCallAlreadyRunning = false
    var articlesArray = [articlesData]()
    var similarArticlesArr: [articlesData]?
    var similarReelsArr: [Reel]?

    var nextPageData = ""
    var channelInfo: ChannelInfo?

    // HomeVC variables
    private var generator = UIImpactFeedbackGenerator()
    var focussedIndexPath = IndexPath(row: 0, section: 0)
    var forceSelectedIndexPath: IndexPath?
    var curVideoVisibleCell: VideoPlayerVieww?
    var curYoutubeVisibleCell: YoutubeCardCell?

    var sourceBlock = false
    var sourceFollow = false
    var article_archived = false
    var urlOfImageToShare: URL?
    var shareTitle = ""
    var isDirectionFindingNeeded = false
    var isLikeApiRunning = false
    var lastContentOffset: CGFloat = 0
    private var prefetchState: PrefetchState = .idle
    var isViewPresenting: Bool = false
    weak var delegate: BulletDetailsVCLikeDelegate?
    weak var delegateVC: BulletDetailsVCDelegate?
    
    var isNestedVC = false
    var cellHeights = [IndexPath: CGFloat]()
    var isRelatedArticletNeeded = true
    var isSimilarArticletNeeded = false
    var isFromPostArticle = false
    let pagingLoader = UIActivityIndicatorView()
    
    var adLoader: GADAdLoader? = nil
    var fbnNativeAd: FBNativeAd? = nil
    var googleNativeAd: GADUnifiedNativeAd?
    var isPlayingVideo = false
    var selectedCell: HomeDetailCardCell?
    
    var mediaWatermark = MediaWatermark()
    var DocController: UIDocumentInteractionController = UIDocumentInteractionController()
    @IBOutlet weak var indicator: InstagramActivityIndicator!
    @IBOutlet weak var viewIndicator: UIView!
    @IBOutlet weak var viewNavTransparent: UIView!
    @IBOutlet weak var imgMore: UIImageView!
    
    var panGestureRecognizer = UIPanGestureRecognizer()
    var isSwipeToDismissRequired = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let ptcTBC = self.tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(false, animated: true)
        }
        
        SharedManager.shared.isShowBulletDetails = true
        
        selectedArticleData?.bullets?.removeAll()
        // load data from api
        performWSViewArticle(selectedArticleData?.id ?? "")
        
        
        viewNav.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
//        view.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor //.white
//        tableView.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        
        view.backgroundColor = Constant.appColor.backgroundGray //.white
        tableView.backgroundColor = Constant.appColor.backgroundGray
        
        
        //GlobalPicker.backgroundColorHomeCell
        imgBack.theme_image = GlobalPicker.imgBackDetails
        imgMore.theme_image = GlobalPicker.imgMoreOptions
        
        titleLabel.text = selectedArticleData?.source?.name ?? ""
        titleLabel.theme_textColor = GlobalPicker.textBWColor
        
        
        if isSwipeToDismissRequired {
            addGestureRecognizer()
        }
        registerCells()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 250
        tableView.delegate = self
        tableView.dataSource = self
        
        addPagingLoader()
        
//        setLikeCommentView(self.selectedArticleData?.info)
        
        // Update Firebase Analytics
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleDetailsPageOpened, eventDescription: "", article_id: self.selectedArticleData?.id ?? "")
        
        indicator.animationDuration = 1.0
        indicator.rotationDuration = 3
        indicator.numSegments = 15
        indicator.strokeColor = "#E01335".hexStringToUIColor()
        indicator.lineWidth = 3
        
        /*
        let graLayer = SharedManager.shared.getGradient(viewGradient: gradientTopicView, colours: [
            UIColor(displayP3Red: 0.404, green: 0.408, blue: 0.671, alpha: 1),UIColor(displayP3Red: 0.969, green: 0.204, blue: 0.345, alpha: 1)], locations: [0,1])
        graLayer.cornerRadius = gradientTopicView.cornerRadius
        gradientTopicView.layer.insertSublayer(graLayer, at: 0)
        */
        viewNav.alpha = 0
        viewNavTransparent.alpha = 1
        
        closeImageShadowView.layer.cornerRadius = closeImageShadowView.frame.size.width/2
//        closeImageShadowView.addRoundedShadow(0.5)
        //addRoundedShadowWithColor(color: .black)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        SharedManager.shared.isShowTopic = false
//        SharedManager.shared.isShowSource = false
//        SharedManager.shared.isSavedArticle = false
        SharedManager.shared.isShowBulletDetails = true
        isViewPresenting = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChange), name: Notification.Name.notifyOrientationChange, object: nil)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versions
            return .default
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if selectedArticleData != nil {
            if selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_SIMPLE || selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_EXTENDED {
                UIView.performWithoutAnimation {
                    self.tableView.reloadSections([0], with: .none)
                }
            }
        }
        
        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
            fetchAds()
        }
        
        
        if selectedArticleData != nil {
            
            if self.focussedIndexPath == IndexPath(row: 0, section: 0) {
                
                if let cell = tableView.cellForRow(at: self.focussedIndexPath) as? HomeDetailCardCell {
                    playVideoOnFocus(cell: cell, isPause: false)
                }
                
            }
        }
        
        
        // Video Player callbacks
        MediaManager.sharedInstance.playerDidPlayToEndCallBack = { [self] in
            if let vc = MediaManager.sharedInstance.currentVC, vc != self  {
                return
            }
            
            if let cell =  getCurrentFocussedCell() as? HomeDetailCardCell, selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                
                if MediaManager.sharedInstance.isFullScreenButtonPressed == false {
                    MediaManager.sharedInstance.releasePlayer()
                }
                cell.playButton.isHidden = false
                cell.viewDuration.isHidden = false
                cell.imgPlayButton.isHidden = false
                
            }
            else if let cell =  getCurrentFocussedCell() as? VideoPlayerVieww {
                
                if MediaManager.sharedInstance.isFullScreenButtonPressed == false {
                    MediaManager.sharedInstance.releasePlayer()
                }
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
                
                if let cell =  getCurrentFocussedCell() as? HomeDetailCardCell, selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                    
                    MediaManager.sharedInstance.releasePlayer()
                    cell.playButton.isHidden = false
                    cell.viewDuration.isHidden = false
                    cell.imgPlayButton.isHidden = false
                    
                }
                else if let cell =  getCurrentFocussedCell() as? VideoPlayerVieww {
                    
                    MediaManager.sharedInstance.releasePlayer()
                    cell.playButton.isHidden = false
                    cell.viewDuration.isHidden = false
                    cell.imgPlayButton.isHidden = false
                    
                }
            }
            
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
        
        isViewPresenting = false
        SharedManager.shared.isAppLaunchedThroughNotification = false
//        SharedManager.shared.isViewArticleSourceNotification = false
        updateProgressbarStatus(isPause: true)
        
        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.viewIndicator.isHidden = true
        }
    }
//    override func viewWillLayoutSubviews() {
//        if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: selectedArticleData?.source?.language ?? "") {
//            DispatchQueue.main.async {
//                self.tableView.semanticContentAttribute = .forceRightToLeft
//            }
//
//        } else {
//            DispatchQueue.main.async {
//                self.tableView.semanticContentAttribute = .forceLeftToRight
//            }
//        }
//    }
    
    
    func addGestureRecognizer() {
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    
    
    @objc func orientationChange() {
     
        
        if MediaManager.sharedInstance.isFullScreenButtonPressed {
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
            
            if self.focussedIndexPath.section == 0 {
                
                if (tableView.cellForRow(at: self.focussedIndexPath) as? HomeDetailCardCell) != nil && selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                    
                    guard let url = URL(string: selectedArticleData?.link ?? "") else { return }
                    
                    if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == self.focussedIndexPath, player.contentURL == url {
                        if player.isPlaying && player.displayMode == .embedded {
                            
                            (UIApplication.shared.delegate as! AppDelegate).orientationLock = [.landscapeLeft, .landscapeRight,.portrait]
                            
                            MediaManager.sharedInstance.isFullScreenButtonPressed = true
                            
                            MediaManager.sharedInstance.player?.fullScreenMode = .landscape
                            MediaManager.sharedInstance.player?.toFull()
                            
                        }
                       return
                    }
                }
                
                
            } else {
                
                if articlesArray.count == 0 || focussedIndexPath.row == -1 || focussedIndexPath.row >= articlesArray.count {
                    return
                }
                
                let content = self.articlesArray[self.focussedIndexPath.row]
                if (tableView.cellForRow(at: self.focussedIndexPath) as? VideoPlayerVieww) != nil {
                    
                    guard let url = URL(string: content.link ?? "") else { return }
                    
                    if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == self.focussedIndexPath, player.contentURL == url {
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
    
    
    func registerCells() {
        
        tableView.register(UINib(nibName: "HomeDetailCardCell", bundle: nil), forCellReuseIdentifier: "HomeDetailCardCell")
        tableView.register(UINib(nibName: "CustomBulletsCC", bundle: nil), forCellReuseIdentifier: "CustomBulletsCC")
        tableView.register(UINib(nibName: "HeaderRelatedArticles", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderRelatedArticles")
        tableView.register(UINib(nibName: "AdHeaderFooter", bundle: nil), forHeaderFooterViewReuseIdentifier: "AdHeaderFooter")
        
        tableView.register(UINib(nibName: CELL_IDENTIFIER_HOME_LISTVIEW, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW)
        tableView.register(UINib(nibName: CELL_IDENTIFIER_HOME_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_CARD)
        tableView.register(UINib(nibName: CELL_IDENTIFIER_YOUTUBE_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_YOUTUBE_CARD)
        tableView.register(UINib(nibName: CELL_IDENTIFIER_VIDEO_PLAYER, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER)
        tableView.register(UINib(nibName: CELL_IDENTIFIER_ADS_LIST, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_ADS_LIST)
    }
    
    /*
    func setLikeCommentView(_ model: Info?) {
        
        if model?.isLiked ?? false {
            //viewLike.theme_backgroundColor = GlobalPicker.themeCommonColor
            imgLike.theme_image = GlobalPicker.likedImage
            lblLikeCount.theme_textColor = GlobalPicker.likeCountColor
        } else {
            //self.viewLike.theme_backgroundColor = GlobalPicker.viewCountColor
            imgLike.theme_image = GlobalPicker.likeDefaultImage
            lblLikeCount.textColor = .gray
        }
        //self.viewComment.theme_backgroundColor = GlobalPicker.viewCountColor
        lblCommentsCount.textColor = .gray
        imgComment.theme_image = GlobalPicker.commentDefaultImage
        lblLikeCount.minimumScaleFactor = 0.5
        lblCommentsCount.minimumScaleFactor = 0.5
        lblLikeCount.text = SharedManager.shared.formatPoints(num: Double((model?.likeCount ?? 0)))
        lblCommentsCount.text = SharedManager.shared.formatPoints(num: Double((model?.commentCount ?? 0)))

        if SharedManager.shared.isSelectedLanguageRTL() {
            lblLikeCount.textAlignment = .right
            lblCommentsCount.textAlignment = .right
        } else {
            lblLikeCount.textAlignment = .left
            lblCommentsCount.textAlignment = .left
        }
    }*/
    
    //MARK:- BUTTON ACTION
    @IBAction func didPressTapLike(_ sender: Any) {
        
        var content = self.selectedArticleData
        var likeCount = content?.info?.likeCount
        if (content?.info?.isLiked ?? false) {
            likeCount = (likeCount ?? 0) - 1
        } else {
            likeCount = (likeCount ?? 0) + 1
        }
        let info = Info(viewCount: content?.info?.viewCount, likeCount: likeCount, commentCount: content?.info?.commentCount, isLiked: !(content?.info?.isLiked ?? false))
        content?.info = info
        selectedArticleData?.info = info
//        setLikeCommentView(content?.info)
        
        performWSToLikePost(article_id: content?.id ?? "", isLike: content?.info?.isLiked ?? false)
    }
    
    @IBAction func didPressComment(_ sender: Any) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HomeDetailCardCell {
            self.didTapCommentsButton(cell: cell)
        }
    }
    
    @IBAction func didPressShare(_ sender: Any) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HomeDetailCardCell {
            
            self.didTapShare(button: cell.btnShare)
        }
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        
        
        DispatchQueue.main.async {
            
//            MediaManager.sharedInstance.releasePlayer()
            self.updateProgressbarStatus(isPause: true)
            
            SharedManager.shared.isOnDiscover = true
            SharedManager.shared.isAppLaunchedThroughNotification = false
    //        SharedManager.shared.isViewArticleSourceNotification = false
    //        if isNestedVC {
                self.navigationController?.popViewController(animated: true)
    //        } else {
                self.dismiss(animated: true, completion: nil)
    //        }
            

            self.delegate?.backButtonPressed(cell: self.selectedCell)
            self.delegateVC?.dismissBulletDetailsVC(selectedArticle: self.selectedArticleData)
    //        self.dismissDetail()
    //        self.navigationController?.popToRootViewController(animated: true)
    //        self.dismiss(animated: true) {
    //            self.delegateVC?.dismissBulletDetailsVC()
    //        }
            
           
        }
       
    }
    
    @IBAction func didTapViewMoreOptions(_ sender: Any) {
        
        share(index: 0, section: 0, isOpenForNativeShare: false)
        
    }
    
    func fetchAds() {
        
        if SharedManager.shared.adType.uppercased() == "FACEBOOK" {
            
//            #if DEBUG
//                FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
//            #else
//                FBAdSettings.clearTestDevices()
//            #endif
            
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
    
    
    // MARK: - Swipe to dismiss methods
    func slideViewVerticallyTo(_ y: CGFloat) {
        self.view.frame.origin = CGPoint(x: 0, y: y)
    }
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        
        if tableView.contentOffset.y > 0 {
            return
        }
        
        switch panGesture.state {
        
        case .began, .changed:
            // If pan started or is ongoing then
            // slide the view to follow the finger
            let translation = panGesture.translation(in: view)
            let y = max(0, translation.y)
            slideViewVerticallyTo(y)
            
        case .ended:
            // If pan ended, decide it we should close or reset the view
            // based on the final position and the speed of the gesture
            let translation = panGesture.translation(in: view)
            let velocity = panGesture.velocity(in: view)
            let closing = (translation.y > self.view.frame.size.height * minimumScreenRatioToHide) ||
                (velocity.y > minimumVelocityToHide)
            
            if closing {
                UIView.animate(withDuration: animationDuration, animations: {
                    // If closing, animate to the bottom of the view
                    self.slideViewVerticallyTo(self.view.frame.size.height)
                }, completion: { (isCompleted) in
                    if isCompleted {
                        // Dismiss the view when it dissapeared
//                        self.didTapBackButton(UIButton())
                        self.dismiss(animated: false, completion: {
                            self.updateProgressbarStatus(isPause: true)
                            SharedManager.shared.isOnDiscover = true
                            SharedManager.shared.isAppLaunchedThroughNotification = false
                            self.delegate?.backButtonPressed(cell: self.selectedCell)
                            self.delegateVC?.dismissBulletDetailsVC(selectedArticle: self.selectedArticleData)
                        })
                    }
                })
            } else {
                // If not closing, reset the view to the top
                UIView.animate(withDuration: animationDuration, animations: {
                    self.slideViewVerticallyTo(0)
                })
            }
            
        default:
            // If gesture state is undefined, reset the view to the top
            UIView.animate(withDuration: animationDuration, animations: {
                self.slideViewVerticallyTo(0)
            })
            
        }
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen;
        modalTransitionStyle = .coverVertical;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .overFullScreen;
        modalTransitionStyle = .coverVertical;
    }
    
}

extension BulletDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            var bulletsCount = (selectedArticleData?.bullets?.count ?? 0)
            if selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_REEL {
                bulletsCount = 1
            }
            return  bulletsCount + 1
            
//            if selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE || selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
//                return 1
//            } else {
//                // Title + bullets
//                return (selectedArticleData?.bullets?.count ?? 0) + 1
//            }
        }
        // Related Articles
        if self.articlesArray.count > 0 {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.tableView.bounds.height - (HEIGHT_HOME_LISTVIEW + 30), right: 0)
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return self.articlesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            // Top card data bullet details
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeDetailCardCell") as! HomeDetailCardCell
            
                cell.setupCell(content: selectedArticleData, isAutoPlay: self.focussedIndexPath == indexPath ? true : false, isFromDetailScreen: true)
                self.selectedCell = cell
                cell.delegate = self
                cell.delegateLikeComment = self
                
                cell.layoutIfNeeded()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CustomBulletsCC") as! CustomBulletsCC
                cell.delegate = self
                
                var isShowFullArticle = false // Last index show view fullarticle
                var isViewFullArticleNeeded = true
                var isNewsTextNeeded = true // hide show bullet dot
                
                if selectedArticleData?.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_REEL {
                    isShowFullArticle = true
                    isNewsTextNeeded = false
                    cell.setupCell(bullet: nil, isShowFullArticle: isShowFullArticle, isViewFullArticleNeeded: isViewFullArticleNeeded, isNewsTextNeeded: isNewsTextNeeded, articleData: self.selectedArticleData, index: indexPath.row, isTitleSameBullet: false)
                    
                }
                else {
                    if (selectedArticleData?.bullets?.count ?? 0) == indexPath.row {
                        isShowFullArticle = true
                    }
                    
                    let selectedBullet = selectedArticleData?.bullets?[indexPath.row - 1]
                    cell.langCode = selectedArticleData?.language ?? ""
                    
                    if (selectedArticleData?.original_link ?? "" == "") {
                        isViewFullArticleNeeded = false
                    } else {
                        isViewFullArticleNeeded = true
                    }
                    
                    let selecteddata = selectedArticleData?.bullets?[indexPath.row - 1]
                    if selecteddata?.data ?? "" == selectedArticleData?.title {
                        isNewsTextNeeded = false
                    }
                    
                    var isTitleSameBullet = false
                    if selectedArticleData?.bullets?.first?.data ?? "" == selectedArticleData?.title ?? "" {
                        isTitleSameBullet = true
                    }
                    cell.setupCell(bullet: selectedBullet, isShowFullArticle: isShowFullArticle, isViewFullArticleNeeded: isViewFullArticleNeeded, isNewsTextNeeded: isNewsTextNeeded, articleData: self.selectedArticleData, index: indexPath.row, isTitleSameBullet: isTitleSameBullet)
                }
                
                
                
                
                
                cell.layoutIfNeeded()
                return cell
            }
            
        } else {
            
            let content = self.articlesArray[indexPath.row]
            //LOCAL VIDEO TYPE
            if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_VIDEO {

                SharedManager.shared.isVolumnOffCard = true
                SharedManager.shared.bulletPlayer?.stop()
                SharedManager.shared.bulletPlayer?.currentTime = 0
                
                let videoPlayer = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER, for: indexPath) as! VideoPlayerVieww
             //   videoPlayer.delegateVideoView = self
                
                videoPlayer.viewDividerLine.isHidden = true
                videoPlayer.constraintContainerViewBottom.constant = 10
                
                videoPlayer.delegate = self
                videoPlayer.delegateLikeComment = self

    //            videoPlayer.lblViewCount.text = "0"
                if let info = content.meta {
                    
    //                videoPlayer.lblViewCount.text = info.view_count
                }
                
                videoPlayer.selectionStyle = .none
                videoPlayer.videoThumbnail = content.image ?? ""
                
                if let source = content.source {
                    
                    let sourceURL = source.icon ?? ""
//                    videoPlayer.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
                    videoPlayer.lblSource.text = source.name ?? ""
                }
                else {
                    
                    let url = content.authors?.first?.image ?? ""
//                    videoPlayer.imgWifi?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
                    videoPlayer.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
                }
                videoPlayer.lblSource.addTextSpacing(spacing: 2.5)

                videoPlayer.btnReport.tag = indexPath.row
                videoPlayer.btnReport.accessibilityIdentifier = "\(indexPath.section)"
                // videoPlayer.btnShare.tag = indexPath.row
                // videoPlayer.btnShare.accessibilityIdentifier = "\(indexPath.section)"
                videoPlayer.btnSource.tag = indexPath.row
                videoPlayer.btnSource.accessibilityIdentifier = "\(indexPath.section)"
                // videoPlayer.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
                videoPlayer.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
                videoPlayer.btnReport.addTarget(self, action: #selector(didTapReport(button:)), for: .touchUpInside)
                
                //LEFT - RIGHT ACTION
                if let pubDate = content.publish_time {
                    videoPlayer.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                }
                //videoPlayer.lblTime.addTextSpacing(spacing: 1.25)
                
                if self.focussedIndexPath == indexPath {
                    self.curVideoVisibleCell = videoPlayer
                }
                
                if let bullets = content.bullets {
                    
//                    videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: false)
                    videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: self.focussedIndexPath == indexPath ? true : false)
                }
                
                return videoPlayer
            }
            
            else if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_ADS {
                
                SharedManager.shared.isVolumnOffCard = true
                
                SharedManager.shared.bulletPlayer?.stop()
                SharedManager.shared.bulletPlayer?.currentTime = 0
                //print("Volume 36")
                
                let adCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_ADS_LIST, for: indexPath) as! HomeListAdsCC
                
                adCell.viewDividerLine.isHidden = true
                adCell.constraintContainerViewBottom.constant = 10
                
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
            else if content.type?.uppercased() == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                
                SharedManager.shared.isVolumnOffCard = true
                SharedManager.shared.bulletPlayer?.stop()
                SharedManager.shared.bulletPlayer?.currentTime = 0
                //print("Volume 37")
                
                let youtubeCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_YOUTUBE_CARD, for: indexPath) as! YoutubeCardCell
                
                youtubeCell.viewDividerLine.isHidden = true
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
                youtubeCell.lblSource.addTextSpacing(spacing: 2.5)

                
                youtubeCell.btnShare.tag = indexPath.row
                youtubeCell.btnShare.accessibilityIdentifier = "\(indexPath.section)"
                youtubeCell.btnSource.tag = indexPath.row
                youtubeCell.btnSource.accessibilityIdentifier = "\(indexPath.section)"
                youtubeCell.btnPlayYoutube.tag = indexPath.row
                youtubeCell.btnPlayYoutube.accessibilityIdentifier = "\(indexPath.section)"
                
                youtubeCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
                youtubeCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
                youtubeCell.btnPlayYoutube.addTarget(self, action: #selector(didTapPlayYoutube(_:)), for: .touchUpInside)

                //LEFT - RIGHT ACTION
                if let pubDate = content.publish_time {
                    youtubeCell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                }
//                youtubeCell.lblTime.addTextSpacing(spacing: 1.25)
                
    //            youtubeCell.lblViewCount.text = "0"
                if let info = content.meta {
                    
    //                youtubeCell.lblViewCount.text = info.view_count
                }
                
                //Selected cell
                if self.focussedIndexPath == indexPath {
                    self.curYoutubeVisibleCell = youtubeCell
                }
                
                //setup cell
                if let bullets = content.bullets {
                    
                    youtubeCell.setupSlideScrollView(bullets: bullets, row: indexPath.row)
                }
                
                youtubeCell.layoutIfNeeded()
                return youtubeCell
            }
            
            //HOME ARTICLES CELL
            else {
                
                SharedManager.shared.isVolumnOffCard = false
                
                if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_SIMPLE {
                    
                    //LIST VIEW DESIGN CELL- SMALL CELL
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW, for: indexPath) as? HomeListViewCC else { return UITableViewCell() }
                    
                    cell.backgroundColor = UIColor.clear
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                    cell.selectionStyle = .none
                    cell.delegateHomeListCC = self
                    cell.delegateLikeComment = self
                    
                    cell.btnShare.tag = indexPath.row
                    cell.btnShare.accessibilityIdentifier = "\(indexPath.section)"
                    cell.btnSource.tag = indexPath.row
                    cell.btnSource.accessibilityIdentifier = "\(indexPath.section)"
                    cell.btnShare.addTarget(self, action: #selector(didTapReport(button:)), for: .touchUpInside)
                    cell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
                    
                    cell.btnLeft.accessibilityIdentifier = String(indexPath.row)
                    cell.btnRight.accessibilityIdentifier = String(indexPath.row)
                    cell.btnLeft.addTarget(self, action: #selector(didTapScrollBulletsList(_:)), for: .touchUpInside)
                    cell.btnRight.addTarget(self, action: #selector(didTapScrollBulletsList(_:)), for: .touchUpInside)

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
                    //cell.setupCellBulletsView(article: content, isAudioPlay: false, row: indexPath.row, isMute: true)
                    cell.setupCellBulletsView(article: content, isAudioPlay: self.focussedIndexPath == indexPath ? true : false, row: indexPath.row, isMute: content.mute ?? false)
                    
                    //cell.viewLikeCommentBG.theme_backgroundColor = GlobalPicker.textWBColor
                    return cell
                }
                else {
                    
                    //CARD VIEW DESIGN CELL- LARGE CELL
                    guard let cardCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_CARD, for: indexPath) as? HomeCardCell else { return UITableViewCell() }
                    
                    cardCell.viewDividerLine.isHidden = true
                    cardCell.constraintContainerViewBottom.constant = 10
                    
                    
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
                    if articlesArray.count > indexPath.row + 1 {
                        
                        let preContent = articlesArray[indexPath.row + 1]
                        cardCell.imgPreLoaded?.sd_setImage(with: URL(string: preContent.image ?? ""))
                    }
                    if articlesArray.count > indexPath.row + 2 {
                        
                        let preContent = articlesArray[indexPath.row + 2]
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
                    cardCell.tag = indexPath.row
                    print("cardCell.viewGestures: ", indexPath.row)
                    cardCell.addGestureRecognizer(tapGesture)

                    cardCell.btnReport.tag = indexPath.row
                    cardCell.btnReport.accessibilityIdentifier = "\(indexPath.section)"
//                    cardCell.btnShare.tag = indexPath.row
//                    cardCell.btnShare.accessibilityIdentifier = "\(indexPath.section)"
                    cardCell.btnSource.tag = indexPath.row
                    cardCell.btnSource.accessibilityIdentifier = "\(indexPath.section)"
                    
                    cardCell.btnReport.addTarget(self, action: #selector(didTapReport(button:)), for: .touchUpInside)
//                    cardCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
                    cardCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)

                    if let source = content.source {
                        
                        let sourceURL = source.icon ?? ""
//                        cardCell.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
                        cardCell.lblSource.text = source.name ?? ""
    //                    cardCell.lblSource.addTextSpacing(spacing: 2.5)
                    }
                    else {
                        
                        let url = content.authors?.first?.image ?? ""
//                        cardCell.imgWifi?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
                        cardCell.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
    //                    cardCell.lblSource.addTextSpacing(spacing: 2.5)
                    }
                    
                    let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
                    let source = content.source?.name ?? ""
                    
//                    cardCell.viewSingleDot.clipsToBounds = false
                    if author == source || author == "" {
//                        cardCell.lblAuthor.isHidden = true
//                        cardCell.viewSingleDot.isHidden = true
//                        cardCell.viewSingleDot.clipsToBounds = true
                        cardCell.lblSource.text = source
                    }
                    else {
                        
                        cardCell.lblSource.text = source
//                        cardCell.lblAuthor.text = author
                        
                        if source == "" {
//                            cardCell.lblAuthor.isHidden = true
//                            cardCell.viewSingleDot.isHidden = true
//                            cardCell.viewSingleDot.clipsToBounds = true
                            cardCell.lblSource.text = author
                        }
                        else if author != "" {
//                            cardCell.lblAuthor.isHidden = false
//                            cardCell.viewSingleDot.isHidden = false
                        }
                    }

                    if let pubDate = content.publish_time {
                        cardCell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                    }
    //                cardCell.lblTime.addTextSpacing(spacing: 1.25)

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
                    
//                    cardCell.setupSlideScrollView(article: content, isAudioPlay: false, row: indexPath.row, isMute: true)
                    cardCell.setupSlideScrollView(article: content, isAudioPlay: self.focussedIndexPath == indexPath ? true : false, row: indexPath.row, isMute: content.mute ?? false)
                    
                    return cardCell
                }
            }
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 1 {
//            if (selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE || selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO) {
//                return CGFloat.leastNormalMagnitude
//            }
            if ((selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE || selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO)) && indexPath.row == (selectedArticleData?.bullets?.count ?? 0 - 1) {
                return UITableView.automaticDimension
            }
            
            if selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_REEL {
                
                return UITableView.automaticDimension
            } else {
                if selectedArticleData?.bullets?.count ?? 0 > 0 {
                    let selectedBullet = selectedArticleData?.bullets?[indexPath.row - 1]
                    if selectedBullet?.data ?? "" == selectedArticleData?.title {
                        return CGFloat.leastNormalMagnitude
                    }
                }
            }
            
        } else if indexPath.section == 1 && self.articlesArray.count > 0 && indexPath.row < self.articlesArray.count {
            
            let content = self.articlesArray[indexPath.row]
            if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_ADS {
                return 200
            }
            else {
                return UITableView.automaticDimension
            }
            
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderRelatedArticles") as! HeaderRelatedArticles
        header.delegateHeader = self
        header.isRequiredRelatedData = isRelatedArticletNeeded
        header.isRequiredSimilarData = isSimilarArticletNeeded
        header.setHeaderSimilarArticlesData(self.similarArticlesArr, reels: self.similarReelsArr)
        return header
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else {
            if isRelatedArticletNeeded || isSimilarArticletNeeded {
                var height: CGFloat = 0
                if isRelatedArticletNeeded {
                    height += articlesArray.count > 0 ? 100 : 0
                }
                if isSimilarArticletNeeded {
                    
                    if (self.similarReelsArr?.count ?? 0 > 0) {
                        height += (self.similarReelsArr?.count ?? 0) > 0 ? 200 : 0
                    }
                    else {
                        height += (self.similarArticlesArr?.count ?? 0) > 0 ? 200 : 0
                    }
                    
                }
                return height
            }
            else {
                return CGFloat.leastNormalMagnitude
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else {
            
            if isRelatedArticletNeeded || isSimilarArticletNeeded {
                var height: CGFloat = 0
                if isRelatedArticletNeeded {
                    height += articlesArray.count > 0 ? 100 : 0
                }
                if isSimilarArticletNeeded {
                    
                    if (self.similarReelsArr?.count ?? 0 > 0) {
                        height += (self.similarReelsArr?.count ?? 0) > 0 ? 250 : 0
                    }
                    else {
                        height += (self.similarArticlesArr?.count ?? 0) > 0 ? 250 : 0
                    }
                    
                }
                return height
            }
            else {
                return CGFloat.leastNormalMagnitude
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 0 && SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
            
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AdHeaderFooter") as! AdHeaderFooter
            if SharedManager.shared.adType.uppercased() == "FACEBOOK" {
                
                footer.loadFacebookAd(nativeAd: self.fbnNativeAd, viewController: self)
            } else {
                
                footer.loadGoogleAd(nativeAd: self.googleNativeAd)
            }
            return footer
        } else {
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 && SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
            
            return 200
        } else {
            return CGFloat.leastNormalMagnitude
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 && SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
            
            return 200
        } else {
            return CGFloat.leastNormalMagnitude
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == articlesArray.count - 1 {  //numberofitem count
                if nextPageData.isEmpty == false {
                    
                    pagingLoader.startAnimating()
                    self.pagingLoader.hidesWhenStopped = true
                    performWSToGetRelatedArticles(page: nextPageData)
                }
            }
        }
        
        if let cell = cell as? HomeListViewCC {
            cell.clvBullets.reloadData()
        }
        
        
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    
    func addPagingLoader() {
        
        if pagingLoader.isAnimating {
            
            self.pagingLoader.stopAnimating()
            self.pagingLoader.hidesWhenStopped = true
        }
        
        if self.tableView.tableFooterView != pagingLoader {
            if #available(iOS 13.0, *) {
                pagingLoader.style = .medium
            }
            pagingLoader.theme_color = GlobalPicker.activityViewColor
            
            pagingLoader.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(62))
            
            self.tableView.tableFooterView = pagingLoader
            self.tableView.tableFooterView?.isHidden = false
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
                    cell.swipeRightFocusedCell(bullets: bullets, tag: self.focussedIndexPath.row)
                }
            } else {
                if sender.direction == .right {
                    cell.swipeRightFocusedCell(bullets: bullets, tag: self.focussedIndexPath.row)
                }
                else if sender.direction == .left {
                    cell.swipeLeftFocusedCell(bullets: bullets)
                }
            }
        }
        
        let row = sender.view?.tag ?? 0
        if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 1)) as? HomeCardCell {
            
            let content = self.articlesArray[row]
            if let bullets = content.bullets {
                
                if row == focussedIndexPath.row {
                    setProgressBarSelectedCardCell(cell, bullets)
                    return
                }
                
                // For unselected cell
                self.resetCurrentFocussedCell()
                forceSelectedIndexPath = IndexPath(row: row, section: 1)
                focussedIndexPath = IndexPath(row: row, section: 1)

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
    
    //MARK:- UISwipeGesture Recognizer for left/rightss
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
                    
                    cell.swipeRightCurrentlyFocusedCell(self.focussedIndexPath.row)
                }
            } else {
                if sender.direction == .right {
                    
                    cell.swipeRightCurrentlyFocusedCell(self.focussedIndexPath.row)
                }
                else if sender.direction == .left {
                    
                    cell.swipeLeftCurrentlyFocusedCell()
                }
            }
        }
        
        let row = sender.view?.tag ?? 0
        if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 1)) as? HomeListViewCC {
            
            // For selected item , currently playing cell
            if row == focussedIndexPath.row {

                setProgressBarSelectedCell(cell)
                return
            }
            
            // For unselected cell
            self.resetCurrentFocussedCell()
            forceSelectedIndexPath = IndexPath(row: row, section: 1)
            focussedIndexPath = IndexPath(row: row, section: 1)
            
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

        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 1)) as? HomeCardCell {
            
            cell.constraintArcHeight.constant = cell.viewGestures.frame.size.height - 20

            //let content = self.articles[index]
            if cell.bullets?.count ?? 0 <= 0 { return }
            
            SharedManager.shared.isManualScrolling = true
                        
            if index == focussedIndexPath.row {
                
                //focus cell
                pausePlayAudio(cell)
                
                if sender.tag == 0 {
                    
                    //LEFT
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articlesArray[focussedIndexPath.row].id ?? "")
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
//                            //SharedManager.shared.spbCardView?.rewind()
                        }
                        else {
                            
                            cell.restartProgressbar()
                        }
                    }
                    else {
                        
//                        if focussedIndexPath.row > 0 {
//
//                            
//                            cell.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: false)
//                        }
//                        else {
//                            cell.restartProgressbar()
//                        }
                    }
                }
                else {
                    
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articlesArray[focussedIndexPath.row].id ?? "")
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
//                        
//                        cell.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
                    }
                }
            }
            else {
                
                //unfocussed cell selected
                self.resetCurrentFocussedCell()
                forceSelectedIndexPath = IndexPath(row: index, section: 1)
                focussedIndexPath = IndexPath(row: index, section: 1)

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
                        
                        if cell.currPage < bullets.count {
                            
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
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 1)) as? HomeListViewCC {
         
            if cell.bullets.count <= 0 { return }
            
            if index == focussedIndexPath.row {
                
                //focus cell
                pausePlayAudio(cell)
                
                if sender.tag == 0 {
                    
                    //LEFT
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articlesArray[focussedIndexPath.row].id ?? "")
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
//                            //SharedManager.shared.spbCardView?.rewind()
                        }
                        else {
                            
                            cell.restartProgressbar()
                        }
                    }
                    else {
//                        if focussedIndexPath.row > 0 {
//                            cell.delegateHomeListCC?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: false)
//                        }
//                        else {
//                            cell.restartProgressbar()
//                        }
                    }
                    //cell.animateImageView(isFromRight: false)
                }
                else {
                    
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articlesArray[focussedIndexPath.row].id ?? "")
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
                self.resetCurrentFocussedCell()
                forceSelectedIndexPath = IndexPath(row: index, section: 1)
                focussedIndexPath = IndexPath(row: index, section: 1)

                pausePlayAudio(cell)
                
                if sender.tag == 0 {
                    
                    //LEFT
                    //SharedManager.shared.sendAnalyticsEvent(eventType: Constant.articleSwipeEvent, eventDescription: "", article_id: self.articlesArray[focussedIndexPath.row].id ?? "")
                    cell.btnLeft.pulsate()
                    cell.btnLeft.setImage(UIImage(named: "leftArc"), for: .normal)
                    cell.imgPrevious.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                        cell.btnLeft.setImage(UIImage(named: ""), for: .normal)
                        cell.imgPrevious.isHidden = true
                    }
                    if cell.currPage < cell.bullets.count {
                        
//                        cell.currMutedPage -= 1
//                        cell.scrollToItemBullet(at: cell.currMutedPage, animated: true)
                        cell.swipeRightUserSelectedCell()
                    }
                    //cell.animateImageView(isFromRight: false)
                }
                else {
                    
                    //SharedManager.shared.sendAnalyticsEvent(eventType: Constant.articleSwipeEvent, eventDescription: "", article_id: self.articlesArray[focussedIndexPath.row].id ?? "")
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

extension BulletDetailsVC: ReelsVCDelegate {
    
    func changeScreen(pageIndex: Int) {
    }
    
    func switchBackToForYou() {
        
    }
    
    func backButtonPressed(_ isUpdateSavedArticle: Bool) {
        
        updateProgressbarStatus(isPause: false)
    }
    
    func loaderShowing(status: Bool) {
        
    }
    func currentPlayingVideoChanged(newIndex: IndexPath) {
    }
    
}

// MARK: - Webservices
extension BulletDetailsVC {
    
    func performWSViewArticle(_ id: String) {
  
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.showLoaderInVC()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/articles/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.hideLoaderVC()
            do {
                let FULLResponse = try
                    JSONDecoder().decode(viewArticleDC.self, from: response)
                
                if self.isRelatedArticletNeeded {
                    self.pagingLoader.startAnimating()
                    self.performWSToGetRelatedArticles(page: "")
                }
                else {
                    self.pagingLoader.stopAnimating()
                    self.isRelatedArticletNeeded = false
                }
                
                
                if let article = FULLResponse.article {
                    
                    self.selectedArticleData = article
                }
                else {
                    
                    SharedManager.shared.showAlertLoader(message: FULLResponse.message ?? NSLocalizedString("Not Found.", comment: ""))
                }
                
                self.tableView.reloadData()
                
            } catch let jsonerror {
                self.hideLoaderVC()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/articles/\(id)", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetRelatedArticles(page: String) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
//        if self.articlesArray.count == 0 {
//            ANLoader.showLoading(disableUI: false)
//        }
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        isApiCallAlreadyRunning = true
        
        if page == "" {
            prefetchState = .fetching
        }
        
        let param = [
            "page": page,
            "reader_mode": SharedManager.shared.readerMode
        ] as [String : Any]
        
        WebService.URLResponse("news/articles/\(self.selectedArticleData?.id ?? "")/related", method: .get, parameters: param, headers: token, withSuccess: { [weak self] (response) in
            ANLoader.hide()
            self?.pagingLoader.stopAnimating()
            self?.pagingLoader.hidesWhenStopped = true
            self?.prefetchState = .idle
            guard let self = self else {
                return
            }
            self.isApiCallAlreadyRunning = false
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(articlesDC.self, from: response)
                
                if let articlesDataObj = FULLResponse.articles, articlesDataObj.count > 0 {
                    if self.articlesArray.count == 0 {
                        self.articlesArray = articlesDataObj
                        
                        
                        
                        
                        if let reelsArray = FULLResponse.reels {
                            
                            self.similarReelsArr = reelsArray
                            self.isSimilarArticletNeeded = (reelsArray.count ) > 0 ? true : false
                        }
                        else {
                            
                            self.similarArticlesArr = FULLResponse.group_articles
                            self.isSimilarArticletNeeded = (self.similarArticlesArr?.count ?? 0) > 0 ? true : false
                        }
                        

                        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
                            //LOAD ADS
                            self.articlesArray.removeAll{ $0.type == Constant.newsArticle.ARTICLE_TYPE_ADS }
                            self.articlesArray = self.articlesArray.adding(articlesData(id: "", title: "", image: "", link: "", color: "", publish_time: "", source: nil, bullets: nil, topics: nil, status: "", type: Constant.newsArticle.ARTICLE_TYPE_ADS), afterEvery: SharedManager.shared.adsInterval)
                        }
                        UIView.performWithoutAnimation {
                            self.tableView.reloadSections([1], with: .none)
                        }
                        
                    } else {
                        self.articlesArray = self.articlesArray + articlesDataObj
                        
                        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
                            //LOAD ADS
                            self.articlesArray.removeAll{ $0.type == Constant.newsArticle.ARTICLE_TYPE_ADS }
                            self.articlesArray = self.articlesArray.adding(articlesData(id: "", title: "", image: "", link: "", color: "", publish_time: "", source: nil, bullets: nil, topics: nil, status: "", type: Constant.newsArticle.ARTICLE_TYPE_ADS), afterEvery: SharedManager.shared.adsInterval)
                        }
                        
                        UIView.performWithoutAnimation {
         
                            self.tableView.reloadSections([1], with: .none)
                        }
                    }
                    
                } else {
                    
                    print("Empty Result")
                    self.isRelatedArticletNeeded = false
                    UIView.performWithoutAnimation {
                        self.tableView.reloadSections([1], with: .none)
                    }
                }
                // Meta data
                if let next = FULLResponse.meta?.next, next.isEmpty == false {
                    self.nextPageData = next
                } else {
                    self.nextPageData = ""
                }
                
            } catch let jsonerror {
                self.isApiCallAlreadyRunning = false
                self.prefetchState = .idle
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/articles/\(self.selectedArticleData?.id ?? "")/related", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            self.prefetchState = .idle
            self.isApiCallAlreadyRunning = false
            ANLoader.hide()
            self.pagingLoader.stopAnimating()
            self.pagingLoader.hidesWhenStopped = true
            print("error parsing json objects",error)
        }
    }
    
    func performWSToShare(article: articlesData, idx: Int, isOpenForNativeShare: Bool = false) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.showLoaderInVC()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/articles/\(article.id ?? "")/share/info", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.hideLoaderVC()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ShareSheetDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    SharedManager.shared.instaMediaUrl = ""
                    self.sourceBlock = FULLResponse.source_blocked ?? false
                    self.sourceFollow = FULLResponse.source_followed ?? false
                    self.article_archived = FULLResponse.article_archived ?? false
                    
                    self.urlOfImageToShare = URL(string: article.link ?? "")
                    self.shareTitle = FULLResponse.share_message ?? ""
                    
                    self.updateProgressbarStatus(isPause: true)
                    if let media = FULLResponse.download_link {
                        
                        SharedManager.shared.instaMediaUrl = media
                    }
                    
                    if self.isFromPostArticle {
                        
                        if article.authors?.first?.id == SharedManager.shared.userId {
                            
                            let vc = BottomSheetArticlesVC.instantiate(fromAppStoryboard: .Main)
                            vc.article_archived = self.article_archived
                            vc.article = article
                            vc.index = idx
                            vc.share_message = FULLResponse.share_message ?? ""
                            vc.delegate = self
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(vc, animated: true)
                        }
                        else {
                            
                            if isOpenForNativeShare {
                                self.openDefaultShareSheet(shareTitle: self.shareTitle)
                            }
                            else {
                                let vc = BottomSheetVC.instantiate(fromAppStoryboard: .registration)
                                vc.delegateBottomSheet = self
                                vc.article = article
                                vc.isOtherAuthorArticleMenu = true
                                vc.isSameAuthor = true
                                vc.sourceBlock = self.sourceBlock
                                vc.sourceFollow = self.sourceFollow
                                vc.article_archived = self.article_archived
                                vc.share_message = FULLResponse.share_message ?? ""
                                vc.modalPresentationStyle = .overFullScreen
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                    else {
                        
                        if isOpenForNativeShare {
                            self.openDefaultShareSheet(shareTitle: self.shareTitle)
                        }
                        else {
                            let vc = BottomSheetVC.instantiate(fromAppStoryboard: .registration)
                            if let _ = article.source {
                                /* If article source */
                                vc.isMainScreen = true
                            }
                            else {
                                //If article author data
                                vc.isMainScreen = false
                                vc.isOtherAuthorArticleMenu = true
                                if article.authors?.first?.id == SharedManager.shared.userId {
                                    vc.isSameAuthor = true
                                }
                            }
                            vc.delegateBottomSheet = self
                            vc.article = article
                            vc.sourceBlock = self.sourceBlock
                            vc.sourceFollow = self.sourceFollow
                            vc.article_archived = self.article_archived
                            vc.share_message = FULLResponse.share_message ?? ""
                            vc.modalPresentationStyle = .overFullScreen
                            vc.modalTransitionStyle = .crossDissolve
                            self.present(vc, animated: true, completion: nil)
                        }

                    }
                    
                }
                
            } catch let jsonerror {
                
                self.hideLoaderVC()
                SharedManager.shared.logAPIError(url: "news/articles/\(article.id ?? "")/share/info", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
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
                        
//                        if SharedManager.shared.isSavedArticle {
//
//                            SharedManager.shared.clearProgressBar()
//                            self.getRefreshArticlesData()
//                        }
                        
                        self.updateProgressbarStatus(isPause: false)
                        
                        SharedManager.shared.showAlertLoader(message: isArchived ? ApplicationAlertMessages.kMsgAddToFavorite : ApplicationAlertMessages.kMsRemoveFromFavorite)
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/articles/\(id)/archive", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performGoToSource(_ id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        //let id = article.source?.id ?? ""
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/data/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let Info = FULLResponse.channel {
                        
                        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
                        detailsVC.channelInfo = Info
                        //detailsVC.delegateVC = self
                        //detailsVC.isOpenFromDiscoverCustomListVC = true
                        detailsVC.modalPresentationStyle = .fullScreen
//                        self.navigationController?.pushViewController(detailsVC, animated: true)
                        let nav = AppNavigationController(rootViewController: detailsVC)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)

                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: NSLocalizedString("Related Sources not available", comment: ""))
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
    
    
    func performWSToLikePost(article_id: String, isLike: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let params = ["like": isLike]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        isLikeApiRunning = true
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
                self.isLikeApiRunning = false
                print("error parsing json objects",jsonerror)
                
                SharedManager.shared.logAPIError(url: "social/likes/article/\(article_id)", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            self.isLikeApiRunning = false
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
                    
                    self.updateProgressbarStatus(isPause: false)
                    if status == Constant.STATUS_SUCCESS {
                        
                        
                        SharedManager.shared.showAlertLoader(message: "Blocked \(sourceName)")
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
                
                self.updateProgressbarStatus(isPause: false)
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
                
                self.updateProgressbarStatus(isPause: false)
                if FULLResponse.message == "Success" {
                    
                    SharedManager.shared.showAlertLoader(message: "Unblocked \(name)")
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
                    
                    self.updateProgressbarStatus(isPause: false)
                    if status == Constant.STATUS_SUCCESS {
                        
                        if isMoreOrLess {
                            
                            SharedManager.shared.showAlertLoader(message: "You'll see more stories like this")
                        }
                        else {
                            
                            SharedManager.shared.showAlertLoader(message: "You'll see less stories like this")
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
    
    
}

// Home VC Methods
extension BulletDetailsVC {
    
    func setupIndexPathForSelectedArticleCardAndListView(_ index: Int, section: Int) {
        
        self.focussedIndexPath = IndexPath(row: index, section: section)
    }
    
    func getIndexPathForSelectedArticleCardAndListView() -> IndexPath {
        
        var index = self.focussedIndexPath

        return index
    }
    
    func getCurrentFocussedCell() -> UITableViewCell {
        
        let index = self.getIndexPathForSelectedArticleCardAndListView()
        if let cell = self.tableView.cellForRow(at: index) {
            return cell
        }

        return UITableViewCell()
    }
    
    func updateProgressbarStatus(isPause: Bool) {
        
        
        SharedManager.shared.bulletPlayer?.pause()
        
        
        if isPause {
            
            if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? HomeDetailCardCell {
                if cell.viewYoutubeArticle.isHidden == false {
                    cell.videoPlayer.pause()
                }
                else if cell.viewVideoArticle.isHidden == false {
//                    cell.player.pause()
                    playVideoOnFocus(cell: cell, isPause: true)
                }
            }
            else if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? HomeCardCell {
                
                cell.pauseAudioAndProgress(isPause:true)
                
            }
            else if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? HomeListViewCC {
                
                cell.pauseAudioAndProgress(isPause:true)
                
            }
            else if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? VideoPlayerVieww {
                
//                cell.playVideo(isPause: true)
                playVideoOnFocus(cell: cell, isPause: true)
                
            }
        }
        else {
            
            if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? HomeDetailCardCell {
                if SharedManager.shared.videoAutoPlay {
                    if cell.viewYoutubeArticle.isHidden == false {
                        cell.videoPlayer.play()
                    }
                    else if cell.viewVideoArticle.isHidden == false {
//                        cell.player.play()
                        playVideoOnFocus(cell: cell, isPause: false)
                    }
                }
            } else if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? HomeCardCell {
                
                cell.pauseAudioAndProgress(isPause:false)
            }
            else if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? HomeListViewCC {
                
                cell.pauseAudioAndProgress(isPause:false)
            }
            else if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? VideoPlayerVieww {
                
//                cell.playVideo(isPause: false)
                playVideoOnFocus(cell: cell, isPause: false)
                
            }
            
        }
    }
    
}

//MARK:- HomeCardCell Delegate methods
extension BulletDetailsVC: HomeCardCellDelegate, YoutubeCardCellDelegate, VideoPlayerViewwDelegates {
    
    
    func didTapCardCellFollow(cell: HomeCardCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let article = self.articlesArray[indexPath.row]
        if article.source != nil {
            
            let fav = self.articlesArray[indexPath.row].source?.favorite ?? false
            self.articlesArray[indexPath.row].source?.isShowingLoader = true
            cell.setFollowingUI(model: self.articlesArray[indexPath.row])
            
            SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [article.source?.id ?? ""], isFav: !fav, type: .sources) {  success in
                
                self.articlesArray[indexPath.row].source?.isShowingLoader = false
                
                if success {
                    self.articlesArray[indexPath.row].source?.favorite = !fav
                }
                
                cell.setFollowingUI(model: self.articlesArray[indexPath.row])
            }
        }
        else if (self.articlesArray[indexPath.row].authors?.count ?? 0) > 0 {
            
            let fav = self.articlesArray[indexPath.row].authors?[0].favorite ?? false
            self.articlesArray[indexPath.row].authors?[0].isShowingLoader = true
            cell.setFollowingUI(model: self.articlesArray[indexPath.row])
            
            
            SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [self.articlesArray[indexPath.row].authors?[0].id ?? ""], isFav: !fav, type: .authors) {  success in
                
                self.articlesArray[indexPath.row].authors?[0].isShowingLoader = false
                
                if success {
                    self.articlesArray[indexPath.row].authors?[0].favorite = !fav
                }
                
                cell.setFollowingUI(model: self.articlesArray[indexPath.row])
                
            }
        }
        
        
    }
    
    
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
        
        guard let indexPath = tableView.indexPath(for: cell) else {
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
            
            player.pause()
            print("player.pause at indexPath", indexPath)
//            if self.isCommunityCell {
//                self.btnReport.isHidden = false
//            }
//            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoDurationEvent, eventDescription: "", article_id: self.articlesArray[self.focussedIndexPath.row].id ?? "", duration: MediaManager.sharedInstance.player?.currentTime?.formatToMilliSeconds() ?? "")
        }
        else {
            
            if SharedManager.shared.videoAutoPlay {
                let status = articlesArray[indexPath.row].status
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
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == indexPath {
            MediaManager.sharedInstance.player?.stop()
            cell.viewDuration.isHidden = false
            cell.imgPlayButton.isHidden = false
        }
        
    }
    
    func didTapVideoPlayButton(cell: VideoPlayerVieww, isTappedFromCell: Bool) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let art = self.articlesArray[indexPath.row]
        guard let url = URL(string: art.link ?? "") else { return }
        self.focussedIndexPath = indexPath
        
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
        
        MediaManager.sharedInstance.playEmbeddedVideo(url: url, embeddedContentView: cell.imgPlaceHolder, userinfo: videoInfo, viewController: self, articleID: art.id ?? "")
        MediaManager.sharedInstance.player?.indexPath = indexPath
        MediaManager.sharedInstance.player?.scrollView = tableView
        
    }
    
    func didSelectCell(cell: VideoPlayerVieww) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        // When focus index of card and the user taps index not same then return it
        let row = indexPath.row
        let content = self.articlesArray[row]
        updateProgressbarStatus(isPause: true)
        
//        let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
//        vc.delegateVC = self
//        vc.webURL = content.link ?? ""
//        vc.titleWeb = content.source?.name ?? ""
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true, completion: nil)
        
        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.isNestedVC = true
        vc.selectedArticleData = content
        vc.delegate = self
        vc.delegateVC = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func seteMaxHeightForIndexPathHomeList(cell: UITableViewCell, maxHeight: CGFloat) {
    }
    
    func focusedIndex(index: Int) {
       
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
    }
    //ARTICLES SWIPE
    func layoutUpdate() {
        
        if articlesArray.count > 0 {
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
    
    @objc func didTapOpenSourceURL(sender: UITapGestureRecognizer) {

        // When focus index of card and the user taps index not same then return it
        let row = sender.view?.tag ?? 0
        print("UITapGestureRecognizer: ", row)
        let content = self.articlesArray[row]
        updateProgressbarStatus(isPause: true)
        
//        let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
//        vc.delegateVC = self
//        vc.webURL = content.link ?? ""
//        vc.titleWeb = content.source?.name ?? ""
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true, completion: nil)
        
        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.isNestedVC = true
        vc.selectedArticleData = content
        vc.delegate = self
        vc.delegateVC = self
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
        
    @objc func didTapPlayYoutube(_ button: UIButton) {
        
        //EXTENDED/LIST VIEW TAP TO PLAY YOUTUBE
        updateProgressbarStatus(isPause: true)
        
        let index = button.tag
        let section = Int(button.accessibilityIdentifier ?? "0") ?? 0
        if section == 0 {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeDetailCardCell {
                if cell.videoPlayer.ready {
                    
                    cell.videoPlayer.play()
                    cell.imgPlay.isHidden = true
                    cell.activityLoader.startAnimating()
                }
            }
        } else {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 1)) as? YoutubeCardCell {
                
    //            self.curVisibleYoutubeCardCell = cell
                if cell.videoPlayer.ready {
                    
                    cell.videoPlayer.play()
                    //cell.imgPlay.isHidden = true
                    cell.activityLoader.startAnimating()
                }
            }
        }
        
    }
    
    
    @objc func didTapReport(button: UIButton) {
        
        let index = button.tag
        let section = Int(button.accessibilityIdentifier ?? "0") ?? 0
        if section == 0 {
            share(index: index, section: section, isOpenForNativeShare: true)
        }
        else {
            share(index: index, section: section, isOpenForNativeShare: false)
        }
    }
    
    @objc func didTapShare(button: UIButton) {
        
        let index = button.tag
        let section = Int(button.accessibilityIdentifier ?? "0") ?? 0
        if section == 0 {
            share(index: index, section: section, isOpenForNativeShare: true)
        }
        else {
            let indexPath = IndexPath(row: index, section: section)
            if let cell = tableView.cellForRow(at: indexPath) as? HomeCardCell {
                share(index: index, section: section, isOpenForNativeShare: true)
            }
            else {
                share(index: index, section: section, isOpenForNativeShare: false)
            }
        }
        
        
    }
    
    func share(index: Int, section: Int, isOpenForNativeShare: Bool) {
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.shareClick, eventDescription: "")

        self.updateProgressbarStatus(isPause: true)
        
        
        if section == 0 {
            let content = self.selectedArticleData
            performWSToShare(article: content!, idx: index, isOpenForNativeShare: isOpenForNativeShare)
        } else {
            let content = self.articlesArray[index]
            performWSToShare(article: content, idx: index, isOpenForNativeShare: isOpenForNativeShare)
        }
    }
    
    @objc func didTapSource(button: UIButton) {
        
        //EXTENDED VIEW TAP TO OPEN SOURCE
        let index = button.tag
        let section = Int(button.accessibilityIdentifier ?? "0")
        
        let content = section == 0 ? self.selectedArticleData : self.articlesArray[index]

        if let source = content?.source {
            
            //EXTENDED VIEW TAP TO OPEN SOURCE
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
            
            self.updateProgressbarStatus(isPause: true)
            button.isUserInteractionEnabled = false
            self.performGoToSource(source.id ?? "")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                button.isUserInteractionEnabled = true
            }
        }
        else {
            self.updateProgressbarStatus(isPause: true)

            let authors = content?.authors
//            let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
//            vc.authors = authors
//            let navVC = AppNavigationController(rootViewController: vc)
//            navVC.modalPresentationStyle = .fullScreen
//            //vc.delegate = self
//            self.present(navVC, animated: true, completion: nil)
            
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
    
    //<---
    // Public delegate methods for all cells are here
    func handleLongPressHold(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        var index: IndexPath = self.focussedIndexPath
                
        if let cell = tableView.cellForRow(at: index) as? HomeCardCell {
            
            if gestureRecognizer.state == .began {
                
                cell.pauseAudioAndProgress(isPause: true)
            }
            if gestureRecognizer.state == .ended {
                
                cell.pauseAudioAndProgress(isPause: false)
            }
        }
        else if let cell = tableView.cellForRow(at: index) as? HomeListViewCC {
            
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
//        
        
        //Data always load from first position
        var index = self.focussedIndexPath
        
        //Reset previous view cell audio -- CARD VIEW
        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
            cell.resetVisibleCard()
        }
        else {
            
            if let cell = tableView.cellForRow(at: index) as? HomeCardCell {
                cell.resetVisibleCard()
            }
        }
        
        //Reset previous view cell audio -- LIST VIEW
        if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
            cell.resetVisibleListCell()
        }
        else {
            
            if let cell = tableView.cellForRow(at: index) as? HomeListViewCC {
                cell.resetVisibleListCell()
            }
        }

        
        if index.section == 1 && index.row < self.articlesArray.count && self.articlesArray.count > 1 {
            
            var newIndex = 0
            newIndex = isMoveNext ? index.row + 1 : index.row - 1
            newIndex = newIndex >= self.articlesArray.count ? 0 : newIndex
            let newIndexPath: IndexPath = IndexPath(item: newIndex, section: 1)
            
            UIView.animate(withDuration: 0.3) {
                
                self.tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .top)
                //self.tableView.scrollToRow(at: newIndexPath, at: .top, animated: false)
                self.tableView.layoutIfNeeded()
                
            } completion: { (finished) in
                
                if let cell = self.tableView.cellForRow(at: newIndexPath) as? HomeCardCell {

                    let content = self.articlesArray[newIndexPath.row]
                    cell.setupSlideScrollView(article: content, isAudioPlay: true, row: newIndexPath.row, isMute: content.mute ?? true)

                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: 1)
                }
                else if let cell = self.tableView.cellForRow(at: newIndexPath) as? HomeListViewCC {

                    let content = self.articlesArray[newIndexPath.row]
                    cell.setupCellBulletsView(article: content, isAudioPlay: true, row: newIndexPath.row, isMute: content.mute ?? true)

                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: 1)
                }
                else if let vCell = self.tableView.cellForRow(at: newIndexPath) as? VideoPlayerVieww {
                    
                    vCell.videoControllerStatus(isHidden: true)
//                    vCell.playVideo(isPause: false)
                    self.playVideoOnFocus(cell: vCell, isPause: false)
                    
                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: 1)
                }
            }
        }
        else if self.articlesArray.count == 1 {
            
            //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
            self.setupIndexPathForSelectedArticleCardAndListView(0, section: 1)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
        }
    }
    //--->
}


// MARK: - Comment Loike Delegates
extension BulletDetailsVC: LikeCommentDelegate {
    
    func didTapCommentsButtonCollectionView(cell: UITableViewCell) {
    }
    
    func didTapLikeButtonCollectionView(cell: UITableViewCell) {
    }
    
    func didTapCommentsButton(cell: UITableViewCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        var content = self.selectedArticleData
        if indexPath.section == 1 {
            content = self.articlesArray[indexPath.row]
        }
        
        updateProgressbarStatus(isPause: true)
        
        let vc = CommentsVC.instantiate(fromAppStoryboard: .Home)
        vc.articleID = content?.id ?? ""
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        navVC.modalPresentationStyle = .overFullScreen
        self.present(navVC, animated: true, completion: nil)
        
    }
    
    func didTapLikeButton(cell: UITableViewCell) {
        
        if isLikeApiRunning {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        var content = self.selectedArticleData
        if indexPath.section == 1 {
            // Related Articles
            content = self.articlesArray[indexPath.row]
        }
        var likeCount = content?.info?.likeCount
        if (content?.info?.isLiked ?? false) {
            likeCount = (likeCount ?? 0) - 1
        } else {
            likeCount = (likeCount ?? 0) + 1
        }
        let info = Info(viewCount: content?.info?.viewCount, likeCount: likeCount, commentCount: content?.info?.commentCount, isLiked: !(content?.info?.isLiked ?? false))
        content?.info = info
        if indexPath.section == 1 {
            self.articlesArray[indexPath.row].info = info
        } else {
            selectedArticleData?.info = info
        }
        
        (cell as? HomeListViewCC)?.setLikeComment(model: content?.info)
//        (cell as? HomeCardCell)?.setLikeComment(model: content?.info)
        (cell as? YoutubeCardCell)?.setLikeComment(model: content?.info)
        (cell as? VideoPlayerVieww)?.setLikeComment(model: content?.info)
        (cell as? HomeDetailCardCell)?.setLikeComment(model: content?.info)
        performWSToLikePost(article_id: content?.id ?? "", isLike: content?.info?.isLiked ?? false)
        
        self.delegate?.likeUpdated(articleID: content?.id ?? "", isLiked: content?.info?.isLiked ?? false, count: likeCount ?? 0)
        
        
    }
    
}


//extension BulletDetailsVC: MainTopicSourceVCDelegate {
//    func dismissMainTopicSourceVC() {
//
//        print("isHome called....")
//
//        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
//            cell.restartProgressbar()
//        }
//        else if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
//            cell.restartProgressbar()
//        }
//        else if let cell = self.getCurrentFocussedCell() as? VideoPlayerVieww {
//            cell.playVideo(isPause: false)
//        }
//    }
//}


//MARK:- SCROLL VIEW DELEGATE
extension BulletDetailsVC: UIScrollViewDelegate {
        
//    func isTopAndBottomAnimationRequired() -> Bool {
//
//        tableView.layoutIfNeeded()
//        if tableView.contentSize.height > (tableView.frame.size.height + 400)  {
//            return true
//        } else {
//            return false
//        }
//
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         
        if self.tableView.contentOffset.y > 100 {
            
            if viewNav.alpha == 0 {
                UIView.animate(withDuration: 0.5) {
                    self.viewNav.alpha = 1
                    self.viewNavTransparent.alpha = 0
                }
                
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HomeDetailCardCell {
                    cell.moreOptionsView.isHidden = true
                }
                
            }
        }
        else {
            if viewNav.alpha == 1 {
                UIView.animate(withDuration: 0.5) {
                    self.viewNav.alpha = 0
                    self.viewNavTransparent.alpha = 1
                }
            }
            
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? HomeDetailCardCell {
                cell.moreOptionsView.isHidden = false
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        lastContentOffset = scrollView.contentOffset.y
//        //print("lastContentOffset", lastContentOffset)
        isDirectionFindingNeeded = false
        updateProgressbarStatus(isPause: true)
        
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        updateProgressbarStatus(isPause: true)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //ScrollView for ListView Mode
        if decelerate { return }
        if !isViewPresenting {
            updateProgressbarStatus(isPause: true)
        }
        else {
            updateProgressbarStatus(isPause: false)
        }
        scrollToTopVisibleExtended()
        
//        if isTopAndBottomAnimationRequired() == false || scrollView.contentOffset.y < 50 {
//            if self.constraintNavTop.constant != 0 {
//                UIView.animate(withDuration: 0.25) {
//                    self.constraintNavTop.constant = 0
//                    self.viewNav.alpha = 1
//                    self.view.layoutIfNeeded()
//                }
//            }
//        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //ScrollView for ListView Mode
        if !isViewPresenting {
            updateProgressbarStatus(isPause: true)
        }
        else {
            updateProgressbarStatus(isPause: false)
        }
        //updateProgressbarStatus(isPause: isViewPresenting ? true : false)
        scrollToTopVisibleExtended()
        
//        if isTopAndBottomAnimationRequired() == false || scrollView.contentOffset.y < 50 {
//            if self.constraintNavTop.constant != 0 {
//                UIView.animate(withDuration: 0.25) {
//                    self.constraintNavTop.constant = 0
//                    self.viewNav.alpha = 1
//                    self.view.layoutIfNeeded()
//                }
//            }
//        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.994000); //0.998000
    }
    
    func scrollToTopVisibleExtended() {
        
        // set hight light to a new first or center cell
        //SharedManager.shared.clearProgressBar()
        var isVisible = false
        var indexPathVisible:  IndexPath?
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            let cellRect = tableView.rectForRow(at: indexPath)
            isVisible = tableView.bounds.contains(cellRect)
            if isVisible {
                //print("indexPath is Visible")
                indexPathVisible = indexPath
                break
            }
        }
        if isVisible == false {
            //print("indexPath not Visible")
            let center = self.view.convert(tableView.center, to: tableView)
            indexPathVisible = tableView.indexPathForRow(at: center)
        }
        
//        if indexPathVisible == 0 {
//            // Skip
//            return
//        }
        if let indexPath = indexPathVisible, indexPath != getIndexPathForSelectedArticleCardAndListView() {
            
            resetCurrentFocussedCell()
            //
            self.setupIndexPathForSelectedArticleCardAndListView(indexPath.row, section: indexPath.section)

            //ASSIGN CELL FOR CARD VIEW
            setSelectedCellAndPlay(index: indexPath.row, indexPath: indexPath)
        }
        else {
            
            if let videoCell = self.getCurrentFocussedCell() as? HomeDetailCardCell {
                
                if videoCell.viewYoutubeArticle.isHidden == false {
                    videoCell.setFocussedYoutubeView()
                }
                else if videoCell.viewVideoArticle.isHidden == false {
                    playVideoOnFocus(cell: videoCell, isPause: false)
                }
            }
            else if let vCell = self.getCurrentFocussedCell() as? VideoPlayerVieww {

                
                playVideoOnFocus(cell: vCell, isPause: false)
            }
            else if let yCell = self.getCurrentFocussedCell() as? YoutubeCardCell {

                
                yCell.setFocussedYoutubeView()
            }
            else {
                if let yCell = self.curYoutubeVisibleCell {

                    
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
    
    func resetCurrentFocussedCell() {
        
        //Reset Cells
        if let cell = self.getCurrentFocussedCell() as? HomeDetailCardCell {
            if cell.viewYoutubeArticle.isHidden == false {
                cell.videoPlayer.pause()
                cell.resetYoutubeCard()
            }
            else if cell.viewVideoArticle.isHidden == false {
                resetPlayerAtIndex(cell: cell)
            }
        }
        
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
        
    }
    
    func setSelectedCellAndPlay(index: Int, indexPath: IndexPath) {
        
        //Set Selected index into focus variables
        self.setupIndexPathForSelectedArticleCardAndListView(index, section: indexPath.section)
        
        //ASSIGN CELL FOR CARD VIEW
        if let cell = tableView.cellForRow(at: indexPath) as? HomeDetailCardCell {
            if cell.viewYoutubeArticle.isHidden == false {
                cell.setFocussedYoutubeView()
            }
            else if cell.viewVideoArticle.isHidden == false {
//                cell.playVideo(isPause: false)
                playVideoOnFocus(cell: cell, isPause: false)
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? HomeCardCell {
            
            // Play audio only when vc is visible
            if isApiCallAlreadyRunning == false && isViewPresenting && articlesArray.count > 0 {
                
                let content = self.articlesArray[indexPath.row]
                cell.setupSlideScrollView(article: content, isAudioPlay: true, row: indexPath.row, isMute: content.mute ?? true)
                //print("audio playing")
            } else {
                //print("audio playing skipped")
            }
        }
        else if let cell = tableView.cellForRow(at: indexPath) as? HomeListViewCC {
            
            //ASSIGN CELL FOR LSIT VIEW
            // Play audio only when vc is visible
            if isApiCallAlreadyRunning == false && isViewPresenting && articlesArray.count > 0 {

                
                let content = self.articlesArray[indexPath.row]
                cell.setupCellBulletsView(article: content, isAudioPlay: true, row: indexPath.row, isMute: content.mute ?? true)
                print("audio playing")
            } else {
                print("audio playing skipped")
            }
            
        }
        else if let yCell = tableView.cellForRow(at: indexPath) as? YoutubeCardCell {
            
            self.curYoutubeVisibleCell = yCell
            yCell.setFocussedYoutubeView()
        }
        else if let vCell = tableView.cellForRow(at: indexPath) as? VideoPlayerVieww {
            
            self.curVideoVisibleCell = vCell
            
//            vCell.playVideo(isPause: false)
            playVideoOnFocus(cell: vCell, isPause: false)
        }
    }
}


extension BulletDetailsVC: CustomBulletsCCDelegate {

    func didTapViewFullArticle(cell: CustomBulletsCC) {
//        let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
//        //vc.delegateVC = self
//        vc.webURL = self.selectedArticleData?.link ?? ""
//        vc.titleWeb = self.selectedArticleData?.source?.name ?? ""
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true, completion: nil)
        
        
        
//        var url = self.selectedArticleData?.link ?? ""
        
//        if selectedArticleData?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
//            url = "https://www.youtube.com/watch?v=\(self.selectedArticleData?.link ?? "")"
//        }
        
        guard let instagram = URL(string: self.selectedArticleData?.original_link ?? "") else { return }
        openInstagram(url: instagram)
    }
    
    func openInstagram(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }else{
            SharedManager.shared.openWebPageViewController(parentVC: self, pageUrlString: self.selectedArticleData?.original_link ?? "", isPresenting: true)
        }
    }
}

//extension BulletDetailsVC: webViewVCDelegate {
//
//    func dismissWebViewVC() {
//        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
//            cell.restartProgressbar()
//        }
//        else if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
//            cell.restartProgressbar()
//        }
//        else if let cell = self.getCurrentFocussedCell() as? VideoPlayerVieww {
//            cell.playVideo(isPause: false)
//        }
//    }
//
//}


extension BulletDetailsVC: HomeDetailCardCellDelegate, FullScreenVideoVCDelegate {
    
    
    func didTapFollow(cell: HomeDetailCardCell) {
        
        if let source =  selectedArticleData?.source {
            
            selectedArticleData?.source?.isShowingLoader = true
            cell.articleModel?.source?.isShowingLoader = true
            cell.setFollowingUI()
            SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [source.id ?? ""], isFav: !(source.favorite ?? false), type: .sources) { success in
                
                self.selectedArticleData?.source?.isShowingLoader = false
                cell.articleModel?.source?.isShowingLoader = false
                
                self.selectedArticleData?.source?.favorite = !(source.favorite ?? false)
                cell.articleModel?.source?.favorite = !(source.favorite ?? false)
                
                cell.setFollowingUI()
            }
            
        }
        else {
            //Author
            if selectedArticleData?.authors?.count ?? 0 > 0 {
                selectedArticleData?.authors?[0].isShowingLoader = true
                cell.articleModel?.authors?[0].isShowingLoader = true
                cell.setFollowingUI()
                SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [cell.articleModel?.authors?.first?.id ?? ""], isFav: !(cell.articleModel?.authors?.first?.favorite ?? false), type: .authors) { success in
                    DispatchQueue.main.async {
                        self.selectedArticleData?.authors?[0].isShowingLoader = false
                        cell.articleModel?.authors?[0].isShowingLoader = false
                        
                        self.selectedArticleData?.source?.favorite = !(cell.articleModel?.authors?.first?.favorite ?? false)
                        cell.articleModel?.authors?[0].favorite = !(cell.articleModel?.authors?.first?.favorite ?? false)
                        
                        cell.setFollowingUI()
                    }
                    
                }
            }
        }
    }
    
   
    func didTapViewMoreOptions(cell: HomeDetailCardCell) {
        
        didTapViewMoreOptions(UIButton())
    }
    
    func backButtonPressed(cell: GenericVideoCell?) {}
    

    func backButtonPressed(cell: HomeDetailCardCell?) {
        
//        cell?.playVideo(isPause: false)
        guard let cell = cell else { return }
        playVideoOnFocus(cell: cell, isPause: false)
    }
    
    
    
    func playVideoOnFocus(cell: HomeDetailCardCell, isPause: Bool) {
        
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
        
        guard let indexPath = tableView.indexPath(for: cell) else {
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
            
            player.pause()
            print("player.pause at indexPath", indexPath)
//            if self.isCommunityCell {
//                self.btnReport.isHidden = false
//            }
        }
        else {
            
            if SharedManager.shared.videoAutoPlay {
                let status = self.selectedArticleData?.status
                if status != Constant.newsArticle.ARTICLE_STATUS_SCHEDULED && status != Constant.newsArticle.ARTICLE_STATUS_PROCESSING && indexPath.row == 0 {
                    didTapVideoPlayButton(cell: cell)
                }
            }
            
        }
    }
    
    func resetPlayerAtIndex(cell: HomeDetailCardCell) {
        
        if MediaManager.sharedInstance.isFullScreenButtonPressed {
            return
        }
        cell.playButton.isHidden = false
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == indexPath {
            MediaManager.sharedInstance.player?.stop()
            cell.viewDuration.isHidden = false
            cell.imgPlayButton.isHidden = false
        }
        
    }
    
    func didTapVideoPlayButton(cell: HomeDetailCardCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let art = self.selectedArticleData
        guard let url = URL(string: art?.link ?? "") else { return }
        self.focussedIndexPath = indexPath
        
        if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == indexPath, player.contentURL == url, MediaManager.sharedInstance.currentVC == self {
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
            "fullScreenMode": EZPlayerFullScreenMode.landscape,
            "videoGravity": EZPlayerVideoGravity.aspect
        ] as [String : Any]
        
        MediaManager.sharedInstance.releasePlayer()
        MediaManager.sharedInstance.playEmbeddedVideo(url: url, embeddedContentView: cell.imgPlaceHolder, userinfo: videoInfo, viewController: self, articleID: art?.id ?? "")
        MediaManager.sharedInstance.player?.indexPath = indexPath
        MediaManager.sharedInstance.player?.scrollView = tableView
        
    }

    
    func didTapOpenSource(cell: HomeDetailCardCell) {
        guard let indexPath = tableView.indexPath(for: cell)  else {
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
    
    func didTapShare(cell: HomeDetailCardCell) {
        guard let indexPath = tableView.indexPath(for: cell)  else {
            return
        }
        let btn = UIButton()
        btn.tag = indexPath.row
        btn.accessibilityIdentifier = "\(indexPath.section)"
        self.didTapShare(button: btn)
    }
    
    func didTapYoutubePlayButton(cell: HomeDetailCardCell) {
        
        guard let indexPath = tableView.indexPath(for: cell)  else {
            return
        }
        let btn = UIButton()
        btn.tag = indexPath.row
        btn.accessibilityIdentifier = "\(indexPath.section)"
        self.didTapPlayYoutube(btn)
        
    }
    
    func didTapPlayLocalVideo(cell: HomeDetailCardCell) {
        
        guard let _ = tableView.indexPath(for: cell)  else {
            return
        }
        
//        cell.player.play()
        playVideoOnFocus(cell: cell, isPause: false)
    }
    
    func didTapZoomImages(cell: HomeDetailCardCell) {
        
        guard let _ = tableView.indexPath(for: cell)  else {
            return
        }
        
        let fullScreenController = cell.slideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        //fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
}

extension BulletDetailsVC: BulletDetailsVCLikeDelegate {

    func likeUpdated(articleID: String, isLiked: Bool, count: Int) {
        
        if self.selectedArticleData?.id == articleID {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
            self.selectedArticleData?.info?.isLiked = isLiked
            self.selectedArticleData?.info?.likeCount = count
            (cell as? HomeDetailCardCell)?.setLikeComment(model: self.selectedArticleData?.info)
        }
        else if let index = self.articlesArray.firstIndex(where: { $0.id == articleID }) {
            self.articlesArray[index].info?.isLiked = isLiked
            self.articlesArray[index].info?.likeCount = count
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 1))
            
            (cell as? HomeListViewCC)?.setLikeComment(model: self.articlesArray[index].info)
//            (cell as? HomeCardCell)?.setLikeComment(model: self.articlesArray[index].info)
            (cell as? YoutubeCardCell)?.setLikeComment(model: self.articlesArray[index].info)
            (cell as? VideoPlayerVieww)?.setLikeComment(model: self.articlesArray[index].info)
        }
        
        self.delegate?.likeUpdated(articleID: articleID, isLiked: isLiked, count: count)
    }
    
    func commentUpdated(articleID: String, count: Int) {
        
        self.delegate?.commentUpdated(articleID: articleID, count: count)
    }
    func backButtonPressed(isVideoPlaying: Bool) {    }
}

//MARK:- POST ARTICLE BOTTOM SHEET
extension BulletDetailsVC: BottomSheetArticlesVCDelegate {

    func dismissBottomSheetArticlesVCDelegateAction(type: Int, idx: Int) {
        
        if type == -1 {
            //When user only dismiss bottom sheet
            updateProgressbarStatus(isPause: false)
            return
        }
        
        var content: articlesData?
        if idx == 0 {
            content = self.selectedArticleData
        } else {
            content = self.articlesArray[idx]
        }
        
        if type == 0 {
            
            //edit
            let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
            if content?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                vc.postArticleType = .media
                vc.selectedMediaType = .video
            }
            else if content?.type == Constant.newsArticle.ARTICLE_TYPE_IMAGE {
                vc.postArticleType = .media
                vc.selectedMediaType = .photo
            }
            else if content?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                vc.postArticleType = .youtube
            }
            
            vc.isScheduleRequired = false
            vc.isEditable = true
            vc.yArticle = content
            vc.selectedChannel = self.channelInfo
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        else if type == 1 {
            
            //delete
            self.performWSToArticleUnpublished(content?.id ?? "")
        }
        
        else if type == 2 {
            
            //Save article
            performArticleArchive(content?.id ?? "", isArchived: !self.article_archived)
        }
        else if type == 3 {
            
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
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                SharedManager.shared.showAlertLoader(message: NSLocalizedString("Article removed successfully", comment: ""))
                self.navigationController?.popToRootViewController(animated: true)
                
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



extension BulletDetailsVC: CommentsVCDelegate {
    
    func commentsVCDismissed(articleID: String) {
        self.updateProgressbarStatus(isPause: false)
        
        
        SharedManager.shared.performWSToGetCommentsCount(id: articleID) { info in
            if info != nil {
                
                
                if self.selectedArticleData?.id == articleID {
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                        self.selectedArticleData?.info?.commentCount = info?.commentCount
                        (cell as? HomeDetailCardCell)?.setLikeComment(model: self.selectedArticleData?.info)
                    }
                    self.delegate?.commentUpdated(articleID: articleID, count: info?.commentCount ?? 0)
                } else {
                    if let selectedIndex = self.articlesArray.firstIndex(where: { $0.id == articleID }) {
    //                    self.articles[selectedIndex].info = info
                        self.articlesArray[selectedIndex].info?.commentCount = info?.commentCount ?? 0
                        
                        self.delegate?.commentUpdated(articleID: articleID, count: info?.commentCount ?? 0)
                        
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 1)) {
                            (cell as? HomeListViewCC)?.setLikeComment(model: self.articlesArray[selectedIndex].info)
//                            (cell as? HomeCardCell)?.setLikeComment(model: self.articlesArray[selectedIndex].info)
                            (cell as? YoutubeCardCell)?.setLikeComment(model: self.articlesArray[selectedIndex].info)
                            (cell as? VideoPlayerVieww)?.setLikeComment(model: self.articlesArray[selectedIndex].info)
                        }
                        
                    }
                }
                
            }
        }
        
    }
}

extension BulletDetailsVC: HeaderRelatedArticlesDelegate {
        
    
    //horizontal suggested article
    func didTapOnHeadlineFeedsCell(header: UITableViewHeaderFooterView, row: Int) {

        //guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        updateProgressbarStatus(isPause: true)
        
        if similarArticlesArr?.count ?? 0 > 0 {
            if let content = similarArticlesArr?[row] {
                
                let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
                vc.selectedArticleData = content
                vc.delegate = self
                //        let navVC = AppNavigationController(rootViewController: vc)
                //        navVC.modalPresentationStyle = .fullScreen
                //        navVC.modalTransitionStyle = .crossDissolve
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if similarReelsArr?.count ?? 0 > 0 {
            if let content = similarReelsArr?[row] {
                let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
//                vc.contextID = content.id ?? ""
                if let similarReels = similarReelsArr{
                    vc.reelsArray = similarReels
                    vc.userSelectedIndexPath = IndexPath(item: row, section: 0)
                }
                vc.titleText = ""
                vc.isBackButtonNeeded = true
                vc.isOpenFromTags = false
                vc.scrollToItemFirstTime = true
                vc.modalPresentationStyle = .overFullScreen
                vc.delegate = self
                let nav = AppNavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .overFullScreen
                updateProgressbarStatus(isPause: true)
                self.present(nav, animated: true, completion: nil)
            }
        }
        
    }
    
    func didTapOnHeadlineFeedsSource(header: UITableViewHeaderFooterView, row: Int) {

        //guard let indexPath = header.indexPath(for: cell) else { return }

        self.updateProgressbarStatus(isPause: true)
        
        if let content = similarArticlesArr?[row] {
            
            // TAP TO OPEN SOURCE
            if content.source != nil {
                
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
                
                self.performGoToSource(content.source?.id ?? "")
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
}


// MARK: - Ads
// Google Ads
extension BulletDetailsVC: GADUnifiedNativeAdLoaderDelegate {
    
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
        self.googleNativeAd = nil
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        
        //print("Ad loader came with results")
        print("Received native ad: \(nativeAd)")
        self.googleNativeAd = nativeAd
        
        
        DispatchQueue.main.async {
            
            let visibleCells = self.tableView.visibleCells
            
            for cell in visibleCells {
                
                if let cell = cell as? HomeListAdsCC {
                    cell.loadGoogleAd(nativeAd: self.googleNativeAd!)
                }
            }
            
            
            let view = self.tableView.footerView(forSection: 0) as? AdHeaderFooter
            view?.loadGoogleAd(nativeAd: self.googleNativeAd!)
            
        }
    }
    
}

// Facebook Ads
extension BulletDetailsVC: FBNativeAdDelegate {
    
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        
        // 1. If there is an existing valid native ad, unregister the view
        if let previousNativeAd = self.fbnNativeAd, previousNativeAd.isAdValid {
            previousNativeAd.unregisterView()
        }
        
        // 2. Retain a reference to the native ad object
        self.fbnNativeAd = nativeAd
        

        DispatchQueue.main.async {
            let visibleCells = self.tableView.visibleCells
            
            for cell in visibleCells {

                if let cell = cell as? HomeListAdsCC {
                    cell.loadFacebookAd(nativeAd: nativeAd, viewController: self)
                    if let indexPath = self.tableView.indexPath(for: cell) {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
            
            let view = self.tableView.footerView(forSection: 0) as? AdHeaderFooter
            view?.loadFacebookAd(nativeAd: nativeAd, viewController: self)
            
//            UIView.performWithoutAnimation {
//                self.tableView.reloadData()
//            }
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

extension BulletDetailsVC: BulletDetailsVCDelegate {
    
    
    func dismissBulletDetailsVC(selectedArticle: articlesData?) {
        
    }
    
}

//MARK:- BottomSheetVC Delegate methods
extension BulletDetailsVC: BottomSheetVCDelegate, UIDocumentInteractionControllerDelegate, SharingDelegate{
    
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
            
            self.present(activityVc, animated: true)
        }
        
    }
    
    func didTapUpdateAudioAndProgressStatus() {
        
        self.updateProgressbarStatus(isPause: false)
    }
    
    func didTapDissmisReportContent() {
        
        self.updateProgressbarStatus(isPause: false)
        SharedManager.shared.showAlertLoader(message: "Report concern sent successfully.")
    }
    
    func didTapBottomShareSheetAction(sender: UIButton, article: articlesData) {
        
        if sender.tag == 1 {
            
            //Save article
            performArticleArchive(article.id ?? "", isArchived: !self.article_archived)
        }
        else if sender.tag == 2 {
            self.updateProgressbarStatus(isPause: true)
            self.openDefaultShareSheet(shareTitle: shareTitle)
        }
        else if sender.tag == 3 {
            
            //Go to Source
            if let _ = article.source {
                self.performGoToSource(article.source?.id ?? "")
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
                
//                self.performUnFollowUserSource(article.source?.id ?? "", name: article.source?.name ?? "")
                SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [article.source?.id ?? ""], isFav: false, type: .sources) { status in
                    
                    self.updateProgressbarStatus(isPause: false)
                    SharedManager.shared.isFav = false
                    NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
                    
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Unfollowed \(article.source?.name ?? "")", comment: ""))
                }
                
            }
            else {
                
                SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [article.source?.id ?? ""], isFav: true, type: .sources) { status in
                    
                    self.updateProgressbarStatus(isPause: false)
                    SharedManager.shared.isFav = true
                    NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
                    
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Followed \(article.source?.name ?? "")", comment: ""))
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
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("shared")
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("didFailWithError")

    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        print("sharerDidCancel")
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

extension BulletDetailsVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }
    
}
