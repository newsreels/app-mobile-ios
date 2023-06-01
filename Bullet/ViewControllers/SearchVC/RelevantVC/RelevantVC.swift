//
//  RelevantVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 18/05/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FBAudienceNetwork
import Photos
import FBSDKShareKit
protocol RelevantVCDelegate: AnyObject {
    func userDidSelectViewAll(type: RelevantVC.searchType)
}
class RelevantVC: UIViewController {

    @IBOutlet weak var tableViewRelevant: UITableView!
    @IBOutlet weak var appLoaderView: UIView!
    @IBOutlet weak var loaderView: GMView!
    @IBOutlet weak var loaderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var seachNoDataView: UIView!
    
    var arrRelevant = [Relevant]()
    var dismissKeyboard : (()-> Void)?
    
    
    var adLoader: GADAdLoader? = nil
    var fbnNativeAd: FBNativeAd? = nil
    var googleNativeAd: GADUnifiedNativeAd?
    
    var searchText = ""
    var txtNameCount = ""
    
    enum searchType: String {
        case topics
        case sources
        case articles
        case locations
        case authors
        case reels
    }
    
    
    var isApiCallAlreadyRunning = false
    var nextPageData = ""
    var nextPageContext = ""
    var focussedIndexPath = IndexPath(row: 0, section: 0)
    var isFirstTimeCalled = false
    var curVideoVisibleCell: VideoPlayerVieww?
    var curYoutubeVisibleCell: YoutubeCardCell?
    private var generator = UIImpactFeedbackGenerator()
    var isLikeApiRunning = false
    var isViewPresenting: Bool = false
    var article_archived = false
    var shareTitle = ""
    var sourceBlock = false
    var sourceFollow = false
    var urlOfImageToShare: URL?
    var articleSection = 0
    weak var delegate: RelevantVCDelegate?
    typealias CompletionHandler = (_ success:Bool) -> Void
    let pagingLoader = UIActivityIndicatorView()
    var pagingLoaderAdded = false
    var authorBlock = false
    var forceSelectedIndexPath: IndexPath?
    var isOpenedBulletDetails = false

    var mediaWatermark = MediaWatermark()
    var DocController: UIDocumentInteractionController = UIDocumentInteractionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        self.view.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        self.view.backgroundColor = .white
        self.tableViewRelevant.theme_backgroundColor =  GlobalPicker.bgBlackWhiteColor
        
        tableViewRelevant.register(UINib(nibName: "NewTopicsCC", bundle: nil), forCellReuseIdentifier: "NewTopicsCC")
        tableViewRelevant.register(UINib(nibName: "RelatedSourcesCC", bundle: nil), forCellReuseIdentifier: "RelatedSourcesCC")
        self.tableViewRelevant.register(UINib(nibName: "RelevantCell", bundle: nil), forCellReuseIdentifier: "RelevantCell")
        self.tableViewRelevant.register(UINib(nibName: "RelevantTopCC", bundle: nil), forCellReuseIdentifier: "RelevantTopCC")
        
        // Header
        tableViewRelevant.register(UINib(nibName: "HeaderRelevantDiscover", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderRelevantDiscover")
        
        
        tableViewRelevant.register(UINib(nibName: CELL_IDENTIFIER_HOME_LISTVIEW, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW)
        tableViewRelevant.register(UINib(nibName: CELL_IDENTIFIER_HOME_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_CARD)
        tableViewRelevant.register(UINib(nibName: CELL_IDENTIFIER_ADS_LIST, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_ADS_LIST)
        tableViewRelevant.register(UINib(nibName: CELL_IDENTIFIER_YOUTUBE_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_YOUTUBE_CARD)
        tableViewRelevant.register(UINib(nibName: CELL_IDENTIFIER_VIDEO_PLAYER, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER)
        
        
        
//        indicator.animationDuration = 1.0
//        indicator.rotationDuration = 3
//        indicator.numSegments = 15
//        indicator.strokeColor = "#E01335".hexStringToUIColor()
//        indicator.lineWidth = 3
        
        seachNoDataView.isHidden = true
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let ptcTBC = self.tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(true, animated: true)
        }

        SharedManager.shared.isShowRelevant = true
        isViewPresenting = true
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if self.searchText.count > 0 && !isOpenedBulletDetails {
            self.performWSToRelevantList(searchText: self.searchText, page: "")
        }
        isOpenedBulletDetails = false
        
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
            }
            
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
            fetchAds()
        }
        
//        if self.indicator.isAnimating {
//
//            self.indicator.stopAnimating()
//            self.indicator.isHidden = true
//            self.viewIndicator.isHidden = true
//        }
        
        updateProgressbarStatus(isPause: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        SharedManager.shared.isShowRelevant = false
        isViewPresenting = false
        
        updateProgressbarStatus(isPause: true)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableViewRelevant.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.tableViewRelevant.bounds.height - (HEIGHT_HOME_LISTVIEW + 30), right: 0)
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
        
    }
    
    
    
    func showNoResultView() {
//        viewNoResultBG.isHidden = false
//        self.lblSearch.text = NSLocalizedString("No results", comment: "")
    }
    
    func showSearchView() {
//        viewNoResultBG.isHidden = false
//        self.lblSearch.text = NSLocalizedString("Search", comment: "")
    }
    
    func hideSearchView() {
        
//        viewNoResultBG.isHidden = true
    }
    
    
    //Keyboard events
    @objc func keyboardWillShow(_ notification: Notification) {

            self.keyboardEvent(true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification?) {
        
            self.keyboardEvent(false)
    }
    
    func keyboardEvent(_ isKeyboardShow: Bool) {
        
//        if isKeyboardShow {
//            constraintViewNoResultBottomHeight.constant = self.view.bounds.height * 0.5
//        }
//        else {
//            constraintViewNoResultBottomHeight.constant = self.view.bounds.height * 0.2
//        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}


// Home VC Methods
extension RelevantVC {
    
    func setupIndexPathForSelectedArticleCardAndListView(_ index: Int, section: Int) {
        
        self.focussedIndexPath = IndexPath(row: index, section: section)
    }
    
    func getIndexPathForSelectedArticleCardAndListView() -> IndexPath {
        
        let index = self.focussedIndexPath
        return index
    }
    
    func getCurrentFocussedCell() -> UITableViewCell {
        
        let index = self.getIndexPathForSelectedArticleCardAndListView()
        if let cell = self.tableViewRelevant.cellForRow(at: index) {
            return cell
        }

        return UITableViewCell()
    }
    
    func updateProgressbarStatus(isPause: Bool) {
        
        
        SharedManager.shared.bulletPlayer?.pause()
        
        
        if isPause {
            
            if let cell = self.tableViewRelevant.cellForRow(at: self.focussedIndexPath) as? HomeCardCell {
                
                cell.pauseAudioAndProgress(isPause:true)
                
            }
            else if let cell = self.tableViewRelevant.cellForRow(at: self.focussedIndexPath) as? HomeListViewCC {
                
                cell.pauseAudioAndProgress(isPause:true)
                
            }
            else if let cell = self.tableViewRelevant.cellForRow(at: self.focussedIndexPath) as? VideoPlayerVieww {
                
//                cell.playVideo(isPause: true)
                playVideoOnFocus(cell: cell, isPause: true)
                
            }
        }
        else {
            
            if let cell = self.tableViewRelevant.cellForRow(at: self.focussedIndexPath) as? HomeCardCell {
                
                cell.pauseAudioAndProgress(isPause:false)
            }
            else if let cell = self.tableViewRelevant.cellForRow(at: self.focussedIndexPath) as? HomeListViewCC {
                
                cell.pauseAudioAndProgress(isPause:false)
            }
            else if let cell = self.tableViewRelevant.cellForRow(at: self.focussedIndexPath) as? VideoPlayerVieww {
                
//                cell.playVideo(isPause: false)
                playVideoOnFocus(cell: cell, isPause: false)
                
            }
        }
    }
    
}

//MARK:- TABLEVIEW DELEGATE AND DATASOURCES
extension RelevantVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if arrRelevant.count == 0 && searchText == "" {
            showSearchView()
            tableView.isHidden = true
        }
        else if arrRelevant.count == 0 {
            showNoResultView()
            tableView.isHidden = true
        } else {
            hideSearchView()
            tableView.isHidden = false
        }
//        viewNoResultBG.isHidden = true
//        tableView.isHidden = false
        return arrRelevant.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if arrRelevant[section].type == .articles {
            
            articleSection = section
            return arrRelevant[section].articles?.count ?? 0
        }
        else if arrRelevant[section].type == .sources {
            
            return arrRelevant[section].sources?.count ?? 0 > 0 ? 1 : 0
        }
        else if arrRelevant[section].type == .topics {
            
            return arrRelevant[section].topics?.count ?? 0 > 0 ? 1 : 0
        }
        else if arrRelevant[section].type == .locations {
            
            return arrRelevant[section].locations?.count ?? 0 > 0 ? 1 : 0
        }
        else if arrRelevant[section].type == .authors {
            
            return arrRelevant[section].authors?.count ?? 0 > 0 ? 1 : 0
        }
        else if arrRelevant[section].type == .reels {
            
            return arrRelevant[section].reels?.count ?? 0 > 0 ? 1 : 0
        }
//        else if arrRelevant[section].type ==  {
//
//            return arrRelevant[section].sources?.count ?? 0 > 0 ? 1 : 0
//        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        if arrRelevant[indexPath.section].type == .sources {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedSourcesCC", for: indexPath) as! RelatedSourcesCC
            cell.setupCell(model: arrRelevant[indexPath.section].sources, title: "Channels")
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
        }
        else if arrRelevant[indexPath.section].type == .topics || arrRelevant[indexPath.section].type == .locations {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewTopicsCC", for: indexPath) as! NewTopicsCC
            if let topics = arrRelevant[indexPath.section].topics {
                cell.setupTopicsCell(topics: topics)
            }
            else if let locations = arrRelevant[indexPath.section].locations {
                cell.setupLocationsCell(locations: locations)
            }
            cell.delegate = self
            return cell
        }
        else if arrRelevant[indexPath.section].type == .authors || arrRelevant[indexPath.section].type == .reels {
            
            let relevantCell = tableView.dequeueReusableCell(withIdentifier: "RelevantCell", for: indexPath) as! RelevantCell
            relevantCell.backgroundColor = .white
            relevantCell.delegate = self
            relevantCell.setupCell(model: arrRelevant[indexPath.section])
            relevantCell.layoutIfNeeded()
            return relevantCell
            
        }
        
        else if arrRelevant[indexPath.section].type == .articles {
            
            guard let content = arrRelevant[indexPath.section].articles?[indexPath.row] else {
                return UITableViewCell()
            }
            //LOCAL VIDEO TYPE
            if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_VIDEO {

                SharedManager.shared.isVolumnOffCard = true
                SharedManager.shared.bulletPlayer?.stop()
                SharedManager.shared.bulletPlayer?.currentTime = 0
                
                let videoPlayer = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER, for: indexPath) as! VideoPlayerVieww
             //   videoPlayer.delegateVideoView = self
                
                videoPlayer.delegate = self
                videoPlayer.delegateLikeComment = self

    //            videoPlayer.lblViewCount.text = "0"
                if let info = content.meta {
                    
    //                videoPlayer.lblViewCount.text = info.view_count
                }
                
                videoPlayer.selectionStyle = .none
                videoPlayer.videoThumbnail = content.image ?? ""
                
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
                
                if let source = content.source {
                    videoPlayer.lblSource.text = content.source?.name ?? ""
                    videoPlayer.lblSource.addTextSpacing(spacing: 2.5)
//                    videoPlayer.imgWifi?.sd_setImage(with: URL(string: content.source?.icon ?? ""), placeholderImage: nil)
                } else {
                    videoPlayer.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
//                    videoPlayer.imgWifi?.sd_setImage(with: URL(string: content.authors?.first?.image ?? ""), placeholderImage: nil)
                }
                
                
                if let pubDate = content.publish_time {
                    videoPlayer.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate)
                }
                videoPlayer.lblTime.addTextSpacing(spacing: 1.25)
                
                if self.focussedIndexPath == indexPath {
                    self.curVideoVisibleCell = videoPlayer
                }
                
                if let bullets = content.bullets {
                    
    //                    videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: false)
                    videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: self.focussedIndexPath == indexPath ? true : false)
                }
                videoPlayer.viewDividerLine.isHidden = true
                videoPlayer.constraintContainerViewBottom.constant = 0
                return videoPlayer
            }
            
            //GOOGLE ADS CELL
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
                adCell.viewDividerLine.isHidden = true
                adCell.constraintContainerViewBottom.constant = 0
                return adCell
                
            }
            
            //YOUTUBE CARD CELL
            else if content.type?.uppercased() == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                
                SharedManager.shared.isVolumnOffCard = true
                SharedManager.shared.bulletPlayer?.stop()
                SharedManager.shared.bulletPlayer?.currentTime = 0
                //print("Volume 37")
                
                let youtubeCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_YOUTUBE_CARD, for: indexPath) as! YoutubeCardCell
                
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
                if let source = content.source {
                    youtubeCell.lblSource.text = content.source?.name ?? ""
                    youtubeCell.lblSource.addTextSpacing(spacing: 2.5)
                    youtubeCell.imgWifi?.sd_setImage(with: URL(string: content.source?.icon ?? ""), placeholderImage: nil)
                } else {
                    youtubeCell.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
                    youtubeCell.imgWifi?.sd_setImage(with: URL(string: content.authors?.first?.image ?? ""), placeholderImage: nil)
                }
                
                
                if let pubDate = content.publish_time {
                    youtubeCell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate)
                }
                youtubeCell.lblTime.addTextSpacing(spacing: 1.25)
                
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
                youtubeCell.viewDividerLine.isHidden = true
                youtubeCell.constraintContainerViewBottom.constant = 0
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
                    cell.btnSource.tag = indexPath.row
                    cell.btnShare.addTarget(self, action: #selector(didTapReport(button:)), for: .touchUpInside)
                    cell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
                    
                    cell.btnLeft.accessibilityIdentifier = String(indexPath.row)
                    cell.btnLeft.accessibilityLabel = String(indexPath.section)
                    cell.btnRight.accessibilityIdentifier = String(indexPath.row)
                    cell.btnRight.accessibilityLabel = String(indexPath.section)

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
                        swipeGesture.view?.accessibilityLabel = String(indexPath.section)
                        swipeGesture.view?.tag = indexPath.row
                        cell.viewContainer.isUserInteractionEnabled = true
                        cell.viewContainer.isMultipleTouchEnabled = false
                        
                        panLeft.require(toFail: swipeGesture)
                        panRight.require(toFail: swipeGesture)
                    }
                    
                    //Set Child Collectionview DataSource and Layout
                    if SharedManager.shared.viewSubCategoryIshidden {
                        print("audio playing")
                        
                        cell.setupCellBulletsView(article: content, isAudioPlay: self.focussedIndexPath == indexPath ? true : false, row: indexPath.row, isMute: content.mute ?? false)
                        
                   //     cell.setupCellBulletsView(article: content, isAudioPlay: self.focussedIndexPath == indexPath.row ? true : false, row: indexPath.row, isMute: content.mute ?? false)
                    } else {
                        print("audio not playing")
                        cell.setupCellBulletsView(article: content, isAudioPlay: false, row: indexPath.row, isMute: content.mute ?? false)
                    }
                    
                    return cell
                }
                
//                {
//
//                    //LIST VIEW DESIGN CELL- SMALL CELL
//                    guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW, for: indexPath) as? HomeListViewCC else { return UITableViewCell() }
//
//                    // Set like comment
//                    cell.setLikeComment(model: content.info)
//
//                    cell.backgroundColor = UIColor.clear
//                    cell.setNeedsLayout()
//                    cell.layoutIfNeeded()
//                    cell.selectionStyle = .none
//                    cell.delegateHomeListCC = self
//                    cell.delegateLikeComment = self
//
//                    let url = content.image ?? ""
//                    cell.imageURL = url
//
//                    if let source = content.source {
//                        cell.lblSource.text = content.source?.name?.capitalized
//                        cell.lblSource.addTextSpacing(spacing: 1.25)
//                    } else {
//                        cell.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
//                    }
//
//                    cell.lblSource.theme_textColor = GlobalPicker.textSourceColor
//
//                    cell.langCode = content.language ?? ""
//                    if let pubDate = content.publish_time {
//                        cell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate)
//                    }
//
//                    cell.lblTime.addTextSpacing(spacing: 1.25)
//
//                    cell.btnShare.tag = indexPath.row
//                    cell.btnShare.accessibilityIdentifier = "\(indexPath.section)"
//                    cell.btnSource.tag = indexPath.row
//                    cell.btnSource.accessibilityIdentifier = "\(indexPath.section)"
//                    cell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
//                    cell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
//
//                    cell.btnLeft.accessibilityIdentifier = String(indexPath.row)
//                    cell.btnRight.accessibilityIdentifier = String(indexPath.row)
//                    cell.btnLeft.addTarget(self, action: #selector(didTapScrollBulletsList(_:)), for: .touchUpInside)
//                    cell.btnRight.addTarget(self, action: #selector(didTapScrollBulletsList(_:)), for: .touchUpInside)
//
//
//                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
//                    tapGesture.view?.tag = indexPath.row
//                    cell.tag = indexPath.row
//                    cell.viewContainer.addGestureRecognizer(tapGesture)
//
//                    let panLeft = PanDirectionGestureRecognizer(direction: .horizontal(.left), target: self, action: #selector(handlePanGesture(_:)))
//                    panLeft.view?.tag = indexPath.row
//                    panLeft.cancelsTouchesInView = false
//                    cell.viewContainer.addGestureRecognizer(panLeft)
//
//                    let panRight = PanDirectionGestureRecognizer(direction: .horizontal(.right), target: self, action: #selector(handlePanGesture(_:)))
//                    panRight.view?.tag = indexPath.row
//                    panRight.cancelsTouchesInView = false
//                    cell.viewContainer.addGestureRecognizer(panRight)
//
//                    //add UISwipeGestureRecognizer when selected cell is active
//                    let direction: [UISwipeGestureRecognizer.Direction] = [ .left, .right]
//                    for dir in direction {
//                        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeViewList(_:)))
//                        cell.viewContainer.addGestureRecognizer(swipeGesture)
//                        swipeGesture.direction = dir
//                        swipeGesture.view?.tag = indexPath.row
//                        cell.viewContainer.isUserInteractionEnabled = true
//                        cell.viewContainer.isMultipleTouchEnabled = false
//
//                        panLeft.require(toFail: swipeGesture)
//                        panRight.require(toFail: swipeGesture)
//                    }
//
//                    //Set Child Collectionview DataSource and Layout
//                    //cell.setupCellBulletsView(article: content, isAudioPlay: false, row: indexPath.row, isMute: true)
//                    cell.setupCellBulletsView(article: content, isAudioPlay: self.focussedIndexPath == indexPath ? true : false, row: indexPath.row, isMute: content.mute ?? false)
//                    cell.viewDividerLine.isHidden = true
//                    cell.constraintContainerViewBottom.constant = 0
//
//                    return cell
//                }
                
                else {

                    //CARD VIEW DESIGN CELL- LARGE CELL
                    guard let cardCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_CARD, for: indexPath) as? HomeCardCell else { return UITableViewCell() }


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
                    cardCell.btnLeft.accessibilityLabel = String(indexPath.section)
                    cardCell.btnRight.accessibilityLabel = String(indexPath.section)

                    cardCell.btnLeft.addTarget(self, action: #selector(didTapScrollLeftRightCard(_:)), for: .touchUpInside)
                    cardCell.btnRight.addTarget(self, action: #selector(didTapScrollLeftRightCard(_:)), for: .touchUpInside)


                    // image Preloading logic
                    if arrRelevant[articleSection].articles?.count ?? 0 > indexPath.row + 1 {

                        if let precontent = arrRelevant[articleSection].articles?[indexPath.row + 1] {
                            cardCell.imgPreLoaded?.sd_setImage(with: URL(string: precontent.image ?? ""))
                        }

                    }
                    if arrRelevant[articleSection].articles?.count ?? 0 > indexPath.row + 2 {

                        if let precontent = arrRelevant[articleSection].articles?[indexPath.row + 2] {
                            cardCell.imgPreLoaded?.sd_setImage(with: URL(string: precontent.image ?? ""))
                        }
                    }

//                    cardCell.lblAuthor.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""

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
                        cardCell.lblSource.text = content.source?.name ?? ""
                        cardCell.lblSource.addTextSpacing(spacing: 2.5)
//                        cardCell.imgWifi?.sd_setImage(with: URL(string: content.source?.icon ?? ""), placeholderImage: nil)
                    } else {
                        cardCell.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
//                        cardCell.imgWifi?.sd_setImage(with: URL(string: content.authors?.first?.image ?? ""), placeholderImage: nil)
                    }


                    if let pubDate = content.publish_time {
                        cardCell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate)
                    }

                    cardCell.lblTime.addTextSpacing(spacing: 1.25)

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

                    cardCell.viewDividerLine.isHidden = true
                    cardCell.constraintContainerViewBottom.constant = 0
                    return cardCell
                }
            }
        }
        else {
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        
        if arrRelevant[section].type == .topics ||  arrRelevant[section].type == .sources ||  arrRelevant[section].type == .locations ||  arrRelevant[section].type == .authors
        {
            let emptyHeader = UIView()
            emptyHeader.backgroundColor = .clear
            emptyHeader.frame = .zero
            return emptyHeader
        }
        
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderRelevantDiscover") as! HeaderRelevantDiscover
        header.viewContainer.backgroundColor = .white
        header.lblTitle.textColor = .black
        if arrRelevant[section].type == .articles {
            
            header.lblTitle.text = NSLocalizedString("Articles", comment: "").capitalized
            header.viewContainer.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
            header.lblTitle.theme_textColor = GlobalPicker.textColor
        }
        else if arrRelevant[section].type == .reels {
            header.lblTitle.text = NSLocalizedString("Reels", comment: "").capitalized
        }
        else {
            header.lblTitle.text = ""
        }
        return header
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if arrRelevant[indexPath.section].isTopOne ?? false {
            return 100
        }
        else if arrRelevant[indexPath.section].type == .topics || arrRelevant[indexPath.section].type == .locations {
            return 123 + 76
        }
        else if arrRelevant[indexPath.section].type == .sources {
            if arrRelevant[indexPath.section].sources?.count == 1 {
                return (130)
            }
            else if arrRelevant[indexPath.section].sources?.count == 2 {
                return (130 * 2)
            }
            else {
                return (100 * 3)
            }
        }
        else if arrRelevant[indexPath.section].type == .authors {
            
            return 0//230
        }
        else if arrRelevant[indexPath.section].type == .reels {
            
            return 230//230
        }
        else  if self.arrRelevant.count > 0 && arrRelevant.count - 1 > articleSection {
            
            let content = self.arrRelevant[articleSection].articles?[indexPath.row]
            if content?.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_ADS {
                
                return 200
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if arrRelevant[indexPath.section].isTopOne ?? false {
            return 100
        }
        else if arrRelevant[indexPath.section].type == .topics {
            if arrRelevant[indexPath.section].topics?.count == 1 {
                return (60) + 62
            }
            else if arrRelevant[indexPath.section].topics?.count == 2 {
                return (60 * 2) + 62
            }
            else {
                return (60 * 3) + 62
            }
        }
        else if arrRelevant[indexPath.section].type == .sources {
            if arrRelevant[indexPath.section].sources?.count == 1 {
                return (130)
            }
            else if arrRelevant[indexPath.section].sources?.count == 2 {
                return (130 * 2)
            }
            else {
                return (100 * 3)
            }
        }
        else if arrRelevant[indexPath.section].type == .authors {
            
            return 0//230
        }
        else if arrRelevant[indexPath.section].type == .reels {
            
            return 230//230
        }
        else  if self.arrRelevant.count > 0 && arrRelevant.count - 1 > articleSection {
            
            let content = self.arrRelevant[articleSection].articles?[indexPath.row]
            if content?.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_ADS {
                
                return 200
            }
        }
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if arrRelevant[section].type == .topics || arrRelevant[section].type == .sources || arrRelevant[section].type == .locations || arrRelevant[section].type == .authors {
            return CGFloat.leastNormalMagnitude
        }
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if arrRelevant.last?.type == .articles && indexPath.row == (arrRelevant.last?.articles?.count ?? 0) - 1 {  //numberofitem count
            if nextPageData.isEmpty == false {
                
                if pagingLoaderAdded == false {
                    addPagingLoader()
                }
                
                pagingLoader.startAnimating()
                self.pagingLoader.hidesWhenStopped = true
                performWSToGetPaginatedArticles(context: nextPageContext, page: nextPageData)
            }
        }
        
        
        if let cell = cell as? HomeListViewCC {
            cell.clvBullets.reloadData()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //print("indexPath:...", indexPath.row)
        if let cell = cell as? VideoPlayerVieww {
//            cell.resetVisibleVideoPlayer()
            resetPlayerAtIndex(cell: cell)
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
        
        let row = sender.view?.tag ?? 0
        
        if let cell = self.tableViewRelevant.cellForRow(at: IndexPath(row: row, section: articleSection)) as? HomeCardCell {
            
            let content = arrRelevant[articleSection].articles?[row]
            if let bullets = content?.bullets {
                
                if row == self.focussedIndexPath.row {
                    
                    SharedManager.shared.isUserinteractWithHeadlinesOnly = true
                    cell.isAutoScrolling = false
                    SharedManager.shared.bulletPlayer?.pause()
                    SharedManager.shared.bulletPlayer?.stop()
                    
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
                    
                    return
                }
                
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
        let section = Int(sender.view?.accessibilityLabel ?? "0") ?? 0

        if let cell = tableViewRelevant.cellForRow(at: IndexPath(row: row, section: section)) as? HomeListViewCC {
            
            // For selected item , currently playing cell
            if row == focussedIndexPath.row {

                setProgressBarSelectedCell(cell)
                return
            }
            
            // For unselected cell
            self.resetCurrentFocussedCell()
            forceSelectedIndexPath = IndexPath(row: row, section: section)
            focussedIndexPath = IndexPath(row: row, section: section)
            
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
        
        let row = Int(sender.accessibilityIdentifier ?? "0") ?? 0
        let section = Int(sender.accessibilityLabel ?? "0") ?? 0
        
        if let cell = tableViewRelevant.cellForRow(at: IndexPath(row: row, section: section)) as? HomeListViewCC {
         
            if cell.bullets.count <= 0 { return }
            
            if row == focussedIndexPath.row {
                
                //focus cell
                pausePlayAudio(cell)
                
                if sender.tag == 0 {
                    
                    //LEFT
                    let id = arrRelevant[section].articles?[row].id ?? ""
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: id)
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
                    
                    let id = arrRelevant[section].articles?[row].id ?? ""
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: id)
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
                forceSelectedIndexPath = IndexPath(row: row, section: section)
                focussedIndexPath = IndexPath(row: row, section: section)

                if sender.tag == 0 {
                    
                    //LEFT
//                    let id = arrRelevant[section].articles?[row].id ?? ""
//                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.articleSwipeEvent, eventDescription: "", article_id: id)
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
                    
//                    let id = arrRelevant[section].articles?[row].id ?? ""
//                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.articleSwipeEvent, eventDescription: "", article_id: id)
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
        
        
        let row = Int(sender.accessibilityIdentifier ?? "0") ?? 0
        let section = Int(sender.accessibilityLabel ?? "0") ?? 0

        if let cell = tableViewRelevant.cellForRow(at: IndexPath(row: row, section: section)) as? HomeCardCell {
            
            cell.constraintArcHeight.constant = cell.viewGestures.frame.size.height - 20

            //let content = self.articles[index]
            if cell.bullets?.count ?? 0 <= 0 { return }
            
            SharedManager.shared.isManualScrolling = true
                        
            if row == focussedIndexPath.row {
                
                //focus cell
                pausePlayAudio(cell)
                
                if sender.tag == 0 {
                    
                    //LEFT
                    let id = arrRelevant[section].articles?[row].id ?? ""
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: id)
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
//                            
//                            cell.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: false)
//                        }
//                        else {
//                            cell.restartProgressbar()
//                        }
                    }
                }
                else {
                    
                    let id = arrRelevant[section].articles?[row].id ?? ""
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: id)
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
                        //cell.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
                    }
                }
            }
            else {
                
                //unfocussed cell selected
                self.resetCurrentFocussedCell()
                forceSelectedIndexPath = IndexPath(row: row, section: section)
                focussedIndexPath = IndexPath(row: row, section: section)

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
    
}

//MARK:- Webservices
extension RelevantVC {
    
    func performWSToRelevantList(searchText: String, page: String) {
        
        self.searchText = searchText
        if !(SharedManager.shared.isConnectedToNetwork()) {
 
            // if the string is same we will not call the api. I used this check for intert conection alert loop
            if txtNameCount == searchText {
                
                return
            }
            self.txtNameCount = searchText
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.showCustomLoader()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["query": searchText,
                      "reader_mode": true
        ] as [String : Any]
        
        WebService.URLResponse("news/discover/relevant", method: .get, parameters: params, headers: token, withSuccess: { (response) in
            
            self.hideCustomLoader()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(RelevantDC.self, from: response)
               
                let arrRelevantList = FULLResponse
                self.arrRelevant.removeAll()
                self.nextPageData = ""
                // Format Data
                if arrRelevantList.exact_match == searchType.sources.rawValue {
                    
                    if arrRelevantList.sources?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .sources, articles: nil, topics: nil, sources: arrRelevantList.sources, locations: nil, authors: nil, reels: nil, isTopOne: true))
                    }
                    if arrRelevantList.topics?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .topics, articles: nil, topics: arrRelevantList.topics, sources: nil, locations: nil, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.locations?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .locations, articles: nil, topics: nil, sources: nil, locations: arrRelevantList.locations, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.locations?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .locations, articles: nil, topics: nil, sources: nil, locations: arrRelevantList.locations, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.authors?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .authors, articles: nil, topics: nil, sources: nil, locations: nil, authors: arrRelevantList.authors, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.reels?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .reels, articles: nil, topics: nil, sources: nil, locations: nil, authors: nil, reels: arrRelevantList.reels, isTopOne: false))
                    }
                    
                } else if arrRelevantList.exact_match == searchType.topics.rawValue {
                    
                    if arrRelevantList.topics?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .topics, articles: nil, topics: arrRelevantList.topics, sources: nil, locations: nil, authors: nil, reels: nil, isTopOne: true))
                    }
                    if arrRelevantList.sources?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .sources, articles: nil, topics: nil, sources: arrRelevantList.sources, locations: nil, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.locations?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .locations, articles: nil, topics: nil, sources: nil, locations: arrRelevantList.locations, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.authors?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .authors, articles: nil, topics: nil, sources: nil, locations: nil, authors: arrRelevantList.authors, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.reels?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .reels, articles: nil, topics: nil, sources: nil, locations: nil, authors: nil, reels: arrRelevantList.reels, isTopOne: false))
                    }
                    
                } else if arrRelevantList.exact_match == searchType.locations.rawValue {
                    
                    if arrRelevantList.locations?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .locations, articles: nil, topics: nil, sources: nil, locations: arrRelevantList.locations, authors: nil, reels: nil, isTopOne: true))
                    }
                    if arrRelevantList.sources?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .sources, articles: nil, topics: nil, sources: arrRelevantList.sources, locations: nil, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.topics?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .topics, articles: nil, topics: arrRelevantList.topics, sources: nil, locations: nil, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.authors?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .authors, articles: nil, topics: nil, sources: nil, locations: nil, authors: arrRelevantList.authors, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.reels?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .reels, articles: nil, topics: nil, sources: nil, locations: nil, authors: nil, reels: arrRelevantList.reels, isTopOne: false))
                    }
                }
                else if arrRelevantList.exact_match == searchType.authors.rawValue {
                    
                    
                    if arrRelevantList.authors?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .authors, articles: nil, topics: nil, sources: nil, locations: nil, authors: arrRelevantList.authors, reels: nil, isTopOne: true))
                    }
                    if arrRelevantList.sources?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .sources, articles: nil, topics: nil, sources: arrRelevantList.sources, locations: nil, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.topics?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .topics, articles: nil, topics: arrRelevantList.topics, sources: nil, locations: nil, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.locations?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .locations, articles: nil, topics: nil, sources: nil, locations: arrRelevantList.locations, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.reels?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .reels, articles: nil, topics: nil, sources: nil, locations: nil, authors: nil, reels: arrRelevantList.reels, isTopOne: false))
                    }
                    
                }
                else {
                    if arrRelevantList.sources?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .sources, articles: nil, topics: nil, sources: arrRelevantList.sources, locations: nil, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.topics?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .topics, articles: nil, topics: arrRelevantList.topics, sources: nil, locations: nil, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.locations?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .locations, articles: nil, topics: nil, sources: nil, locations: arrRelevantList.locations, authors: nil, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.authors?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .authors, articles: nil, topics: nil, sources: nil, locations: nil, authors: arrRelevantList.authors, reels: nil, isTopOne: false))
                    }
                    if arrRelevantList.reels?.count ?? 0 > 0 {
                        self.arrRelevant.append(Relevant(type: .reels, articles: nil, topics: nil, sources: nil, locations: nil, authors: nil, reels: arrRelevantList.reels, isTopOne: false))
                    }
                }
                
                if arrRelevantList.articles?.count ?? 0 > 0 {
                    
                    self.arrRelevant.append(Relevant(type: .articles, articles: arrRelevantList.articles, topics: nil, sources: nil, locations: nil, authors: nil, reels: nil, isTopOne: false))
                    
                    
//                    if let articles = arrRelevantList.articles {
//
//                        for article in articles {
//
//                            if article.type != Constant.newsArticle.ARTICLE_TYPE_EXTENDED {
//
//                                self.arrRelevant.append(Relevant(type: .articles, articles: arrRelevantList.articles, topics: nil, sources: nil, locations: nil, authors: nil, reels: nil, isTopOne: false))
//                            }
//                        }
//                    }
                }
                
                if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
                    
                    //LOAD ADS
                    //self.refreshAds()
                    for (index, data) in self.arrRelevant.enumerated() {
                        if data.type == .articles {
                            
                            self.arrRelevant[index].articles?.removeAll{ $0.type == Constant.newsArticle.ARTICLE_TYPE_ADS }
                            self.arrRelevant[index].articles = self.arrRelevant[index].articles?.adding(articlesData(id: "", title: "", image: "", link: "", color: "", publish_time: "", source: nil, bullets: nil, topics: nil, status: "", type: Constant.newsArticle.ARTICLE_TYPE_ADS), afterEvery: SharedManager.shared.adsInterval)

                            
                            break
                        }
                    }
                }
                
                
                // Meta data
                if let next = FULLResponse.article_page?.next, next.isEmpty == false {
                    self.nextPageContext = FULLResponse.article_context ?? ""
                    self.nextPageData = next
                } else {
                    self.nextPageData = ""
                }
                
//                if self.isOnSearch {
                    if self.searchText != "" && self.arrRelevant.count == 0 {
                        self.seachNoDataView.isHidden = false
                    }
//                }
                
                self.tableViewRelevant.reloadData()
                
            } catch let jsonerror {
                
                SharedManager.shared.showAPIFailureAlert()
                self.hideCustomLoader()
                print("error parsing json objects", jsonerror)
                
                SharedManager.shared.logAPIError(url: "news/discover/relevant", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            
            self.hideCustomLoader()
            print("error parsing json objects", error)
        }
    }
    
    
    func performWSToGetPaginatedArticles(context: String, page: String) {

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
        }
        
        let param = [
            "page": page,
            "reader_mode": true
        ] as [String : Any]
        
        let querySt = "news/articles?context=\(context)&page=\(page)"
        
        WebService.URLResponse(querySt, method: .get, parameters: param, headers: token, withSuccess: { [weak self] (response) in
            ANLoader.hide()
            self?.pagingLoader.stopAnimating()
            self?.pagingLoader.hidesWhenStopped = true
            guard let self = self else {
                return
            }
            self.isApiCallAlreadyRunning = false
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(articlesDC.self, from: response)
                
                if let articlesDataObj = FULLResponse.articles, articlesDataObj.count > 0 {
                    
                    var articleSec = -1
                    for (articleSection,obj) in self.arrRelevant.enumerated() {
                        if obj.type == .articles {
                            articleSec = articleSection
                            break
                        }
                    }
                    
                    if articleSec != -1 && (self.arrRelevant[articleSec].articles?.count ?? 0) > 0 {
                        
                        self.arrRelevant[articleSec].articles = self.arrRelevant[articleSec].articles! + articlesDataObj
                        
                        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
                            //LOAD ADS
                            self.arrRelevant[articleSec].articles?.removeAll{ $0.type == Constant.newsArticle.ARTICLE_TYPE_ADS }
                            self.arrRelevant[articleSec].articles = self.arrRelevant[articleSec].articles?.adding(articlesData(id: "", title: "", image: "", link: "", color: "", publish_time: "", source: nil, bullets: nil, topics: nil, status: "", type: Constant.newsArticle.ARTICLE_TYPE_ADS), afterEvery: SharedManager.shared.adsInterval)
                        }
                        
                        UIView.performWithoutAnimation {
         
                            self.tableViewRelevant.reloadData()
                        }
                        
                    } else {
                        self.tableViewRelevant.reloadData()
                    }

                    
                } else {
                    
                    print("Empty Result")
                    UIView.performWithoutAnimation {
                        self.tableViewRelevant.reloadData()
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
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: querySt, error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            self.isApiCallAlreadyRunning = false
            ANLoader.hide()
            self.pagingLoader.stopAnimating()
            self.pagingLoader.hidesWhenStopped = true
            print("error parsing json objects",error)
        }
    }
    
    func addPagingLoader() {
        
        if pagingLoader.isAnimating {
            
            self.pagingLoader.stopAnimating()
            self.pagingLoader.hidesWhenStopped = true
        }
        
        if self.tableViewRelevant.tableFooterView != pagingLoader {
            if #available(iOS 13.0, *) {
                pagingLoader.style = .medium
            }
            pagingLoader.theme_color = GlobalPicker.activityViewColor
            
            pagingLoader.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableViewRelevant.bounds.width, height: CGFloat(62))
            
            self.tableViewRelevant.tableFooterView = pagingLoader
            self.tableViewRelevant.tableFooterView?.isHidden = false
        }
        
    }
    
    
}

//MARK:- HomeCardCell Delegate methods
extension RelevantVC: HomeCardCellDelegate, YoutubeCardCellDelegate, VideoPlayerViewwDelegates, FullScreenVideoVCDelegate {
    
    func didTapCardCellFollow(cell: HomeCardCell) {
        
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {
            return
        }
        
        guard let article = self.arrRelevant[indexPath.section].articles?[indexPath.row] else {
            return
        }
        if article.source != nil {
            
            let fav = self.arrRelevant[indexPath.section].articles?[indexPath.row].source?.favorite ?? false
            self.arrRelevant[indexPath.section].articles?[indexPath.row].source?.isShowingLoader = true
            if let articles = self.arrRelevant[indexPath.section].articles?[indexPath.row] {
                cell.setFollowingUI(model: articles)
            }
            
            
            SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [article.source?.id ?? ""], isFav: !fav, type: .sources) {  success in
                
                self.arrRelevant[indexPath.section].articles?[indexPath.row].source?.isShowingLoader = false
                
                if success {
                    self.arrRelevant[indexPath.section].articles?[indexPath.row].source?.favorite = !fav
                }
                
                if let articles = self.arrRelevant[indexPath.section].articles?[indexPath.row] {
                    cell.setFollowingUI(model: articles)
                }
            }
        }
        else if (self.arrRelevant[indexPath.section].articles?[indexPath.row].authors?.count ?? 0) > 0 {
            
            let fav = self.arrRelevant[indexPath.section].articles?[indexPath.row].authors?[0].favorite ?? false
            self.arrRelevant[indexPath.section].articles?[indexPath.row].authors?[0].isShowingLoader = true
            if let articles = self.arrRelevant[indexPath.section].articles?[indexPath.row] {
                cell.setFollowingUI(model: articles)
            }
            
            
            SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [self.arrRelevant[indexPath.section].articles?[indexPath.row].authors?[0].id ?? ""], isFav: !fav, type: .authors) {  success in
                
                self.arrRelevant[indexPath.section].articles?[indexPath.row].authors?[0].isShowingLoader = false
                
                if success {
                    self.arrRelevant[indexPath.section].articles?[indexPath.row].authors?[0].favorite = !fav
                }
                
                if let articles = self.arrRelevant[indexPath.section].articles?[indexPath.row] {
                    cell.setFollowingUI(model: articles)
                }
                
            }
        }
        
        
    }
    
    
    func backButtonPressed(cell: HomeDetailCardCell?) {}
    func backButtonPressed(cell: GenericVideoCell?) {}
    func backButtonPressed(cell: VideoPlayerVieww?) {
        
//        cell?.playVideo(isPause: false)
        if let cell = cell {
            self.playVideoOnFocus(cell: cell, isPause: false)
        }
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
        
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {
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
//            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoDurationEvent, eventDescription: "", article_id: arrRelevant[articleSection][self.focussedIndexPath.row].id ?? "", duration: MediaManager.sharedInstance.player?.currentTime?.formatToMilliSeconds() ?? "")
        }
        else {
            
            if SharedManager.shared.videoAutoPlay {
                guard let status = self.arrRelevant[indexPath.section].articles?[indexPath.row].status else { return }
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
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {
            return
        }
        
        if let player = MediaManager.sharedInstance.player  ,let index = player.indexPath , index == indexPath {
            MediaManager.sharedInstance.player?.stop()
            cell.viewDuration.isHidden = false
            cell.imgPlayButton.isHidden = false
        }
        
    }
    
    func didTapVideoPlayButton(cell: VideoPlayerVieww, isTappedFromCell: Bool) {
        
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {
            return
        }
        
        
        guard let art = self.arrRelevant[indexPath.section].articles?[indexPath.row] else { return }
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
            "fullScreenMode": EZPlayerFullScreenMode.portrait
        ] as [String : Any]
        
        MediaManager.sharedInstance.playEmbeddedVideo(url: url, embeddedContentView: cell.imgPlaceHolder, userinfo: videoInfo, viewController: self, articleID: art.id ?? "")
        MediaManager.sharedInstance.player?.indexPath = indexPath
        MediaManager.sharedInstance.player?.scrollView = tableViewRelevant
        
    }
    
    
    func didSelectFullScreenVideo(cell: VideoPlayerVieww) {
        //        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
        //            return
        //        }
        /*
        cell.playVideo(isPause: true)
        if let playerItem = cell.player.player.currentItem?.copy() as? AVPlayerItem {
            
            let vc = FullScreenVideoVC.instantiate(fromAppStoryboard: .Reels)
            vc.playerItem = playerItem
            vc.url = (playerItem.asset as? AVURLAsset)?.url.absoluteString ?? ""
            vc.playingTime = cell.player.time
            vc.delegate = self
            vc.VideoPlayerVieww = cell
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }
        */
    }
    
    func didSelectCell(cell: VideoPlayerVieww) {
        
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {
            return
        }
        
        // When focus index of card and the user taps index not same then return it
        let row = indexPath.row
        let content = arrRelevant[articleSection].articles?[row]
        updateProgressbarStatus(isPause: true)
        
//        let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
//        vc.delegateVC = self
//        vc.webURL = content.link ?? ""
//        vc.titleWeb = content.source?.name ?? ""
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true, completion: nil)
        
        isOpenedBulletDetails = true
        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.isRelatedArticletNeeded = false
        vc.selectedArticleData = content
        vc.delegate = self
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
    
    func resetSelectedAudio() {
        
        //Reset previous view cell audio -- CARD VIEW
        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
            cell.resetVisibleCard()
        }
        else {
            
            if let cell = tableViewRelevant.cellForRow(at: focussedIndexPath) as? HomeCardCell {
                cell.resetVisibleCard()
            }
        }
        
        //Reset previous view cell audio -- LIST VIEW
        if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
            cell.resetVisibleListCell()
        }
        else {
            
            if let cell = tableViewRelevant.cellForRow(at: focussedIndexPath) as? HomeListViewCC {
                cell.resetVisibleListCell()
            }
        }
    }
    
    //ARTICLES SWIPE
    func layoutUpdate() {
        
        if arrRelevant.count > 0 {
            DispatchQueue.main.async {
                self.tableViewRelevant.beginUpdates()
                self.tableViewRelevant.endUpdates()
            }
        }
    }
    
    @objc func didTapOpenSourceURL(sender: UITapGestureRecognizer) {

        // When focus index of card and the user taps index not same then return it
        let row = sender.view?.tag ?? 0
        print("UITapGestureRecognizer: ", row)
        let content = arrRelevant[articleSection].articles?[row]
        updateProgressbarStatus(isPause: true)
        
//        let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
//        vc.delegateVC = self
//        vc.webURL = content.link ?? ""
//        vc.titleWeb = content.source?.name ?? ""
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true, completion: nil)
        
        isOpenedBulletDetails = true
        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.isRelatedArticletNeeded = false
        vc.selectedArticleData = content
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
        
    @objc func didTapPlayYoutube(_ button: UIButton) {
        
        //EXTENDED/LIST VIEW TAP TO PLAY YOUTUBE
        updateProgressbarStatus(isPause: true)
        
        let index = button.tag
        if let cell = self.tableViewRelevant.cellForRow(at: IndexPath(row: index, section: articleSection)) as? YoutubeCardCell {
            
//            self.curVisibleYoutubeCardCell = cell
            if cell.videoPlayer.ready {
                
                cell.videoPlayer.play()
                //cell.imgPlay.isHidden = true
                cell.activityLoader.startAnimating()
            }
        }
        
    }
    
    @objc func didTapReport(button: UIButton) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.shareClick, eventDescription: "")

        self.updateProgressbarStatus(isPause: true)
        let index = button.tag
        let section = Int(button.accessibilityIdentifier ?? "0")
        if let content = self.arrRelevant[articleSection].articles?[index] {
            performWSToShare(article: content, isOpenForNativeShare: false)
        }
    }
    
    @objc func didTapShare(button: UIButton) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.shareClick, eventDescription: "")

        self.updateProgressbarStatus(isPause: true)
        let index = button.tag
        let section = Int(button.accessibilityIdentifier ?? "0")
        if let content = self.arrRelevant[articleSection].articles?[index] {
            performWSToShare(article: content, isOpenForNativeShare: true)
        }
    }
    
    @objc func didTapSource(button: UIButton) {
        
        //EXTENDED VIEW TAP TO OPEN SOURCE
        //NotificationCenter.default.post(name: Notification.Name.notifyToRemoveVCObservers, object: nil)
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
        
        self.updateProgressbarStatus(isPause: true)
        button.isUserInteractionEnabled = false
        let index = button.tag
        let section = Int(button.accessibilityIdentifier ?? "0")
        if let content = arrRelevant[articleSection].articles?[index] {
            self.performGoToSource(id: content.source?.id ?? "")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            button.isUserInteractionEnabled = true
        }
    }
    
    //<---
    // Public delegate methods for all cells are here
    func handleLongPressHold(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        let index: IndexPath = self.focussedIndexPath
                
        if let cell = tableViewRelevant.cellForRow(at: index) as? HomeCardCell {
            
            if gestureRecognizer.state == .began {
                
                cell.pauseAudioAndProgress(isPause: true)
            }
            if gestureRecognizer.state == .ended {
                
                cell.pauseAudioAndProgress(isPause: false)
            }
        }
        else if let cell = tableViewRelevant.cellForRow(at: index) as? HomeListViewCC {
            
            if gestureRecognizer.state == .began {
                
                cell.pauseAudioAndProgress(isPause: true)
            }
            if gestureRecognizer.state == .ended {
                
                cell.pauseAudioAndProgress(isPause: false)
            }
        }
    }
    
    func autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: Bool) {
        
        //Check for auto scroll is running when the user changed View Type(Extended to List)
        
        
        //Data always load from first position
        let index = self.focussedIndexPath
        self.resetSelectedAudio()
            
        if arrRelevant.count == 0 { return }
        if index.row < arrRelevant[articleSection].articles?.count ?? 0 && (self.arrRelevant[articleSection].articles?.count ?? 0) > 1 {
            
            var newIndex = 0
            newIndex = isMoveNext ? index.row + 1 : index.row - 1
            newIndex = newIndex >= (self.arrRelevant[articleSection].articles?.count ?? 0) ? 0 : newIndex
            let newIndexPath: IndexPath = IndexPath(item: newIndex, section: articleSection)
            
            UIView.animate(withDuration: 0.3) {
                
                self.tableViewRelevant.selectRow(at: newIndexPath, animated: false, scrollPosition: .top)
                //self.tableView.scrollToRow(at: newIndexPath, at: .top, animated: false)
                self.tableViewRelevant.layoutIfNeeded()
                
            } completion: { (finished) in
                
                if let cell = self.tableViewRelevant.cellForRow(at: newIndexPath) as? HomeCardCell {

                    if let content = self.arrRelevant[self.articleSection].articles?[newIndexPath.row] {
                        cell.setupSlideScrollView(article: content, isAudioPlay: true, row: newIndexPath.row, isMute: content.mute ?? true)
                        
                        //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                        self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: self.articleSection)
                    }
                }
                else if let cell = self.tableViewRelevant.cellForRow(at: newIndexPath) as? HomeListViewCC {

                    if let content = self.arrRelevant[self.articleSection].articles?[newIndexPath.row] {
                        cell.setupCellBulletsView(article: content, isAudioPlay: true, row: newIndexPath.row, isMute: content.mute ?? true)
                        
                        //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                        self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: self.articleSection)
                    }
                }
                else if let vCell = self.tableViewRelevant.cellForRow(at: newIndexPath) as? VideoPlayerVieww {
                    
                    vCell.videoControllerStatus(isHidden: true)
//                    vCell.playVideo(isPause: false)
                    self.playVideoOnFocus(cell: vCell, isPause: false)
                    
                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: self.articleSection)
                }
                else if let yCell = self.tableViewRelevant.cellForRow(at: newIndexPath) as? YoutubeCardCell {
                    
                    self.curYoutubeVisibleCell = yCell
                    yCell.setFocussedYoutubeView()
                    
                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: self.articleSection)
                }
            }
        }
        else if (self.arrRelevant[articleSection].articles?.count ?? 0)  == 1 {
            
            //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
            self.setupIndexPathForSelectedArticleCardAndListView(0, section: articleSection)
            self.tableViewRelevant.reloadRows(at: [IndexPath(row: 0, section: articleSection)], with: .none)
        }
    }
    //--->
}


// MARK: - Comment Loike Delegates
extension RelevantVC: LikeCommentDelegate {
    
    func didTapCommentsButtonCollectionView(cell: UITableViewCell) {
    }
    
    func didTapLikeButtonCollectionView(cell: UITableViewCell) {
    }
    
    func didTapCommentsButton(cell: UITableViewCell) {
        
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {return}
        
        let content = self.arrRelevant[articleSection].articles?[indexPath.row]
        
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
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {return}
        
        var content = self.arrRelevant[articleSection].articles?[indexPath.row]
        var likeCount = content?.info?.likeCount
        if (content?.info?.isLiked ?? false) {
            likeCount = (likeCount ?? 0) - 1
        } else {
            likeCount = (likeCount ?? 0) + 1
        }
        let info = Info(viewCount: content?.info?.viewCount, likeCount: likeCount, commentCount: content?.info?.commentCount, isLiked: !(content?.info?.isLiked ?? false), socialLike: content?.info?.socialLike)
        content?.info = info
        self.arrRelevant[articleSection].articles?[indexPath.row].info = info
        
        (cell as? HomeListViewCC)?.setLikeComment(model: content?.info)
//        (cell as? HomeCardCell)?.setLikeComment(model: content?.info)
        (cell as? YoutubeCardCell)?.setLikeComment(model: content?.info)
        (cell as? VideoPlayerVieww)?.setLikeComment(model: content?.info)
        performWSToLikePost(article_id: content?.id ?? "", isLike: content?.info?.isLiked ?? false)
    
    }
}

//MARK:- BottomSheetVC Delegate methods
extension RelevantVC: BottomSheetVCDelegate {
    
    func didTapUpdateAudioAndProgressStatus() {
        
        self.updateProgressbarStatus(isPause: false)
    }
    
    func didTapDissmisReportContent() {
        
        self.updateProgressbarStatus(isPause: false)
        SharedManager.shared.showAlertLoader(message: "Report concern sent successfully.")
    }
}


//MARK:- SCROLL VIEW DELEGATE
extension RelevantVC: UIScrollViewDelegate {
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dismissKeyboard?()
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
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.994000); //0.998000
    }
    
    func scrollToTopVisibleExtended() {
        
        // set hight light to a new first or center cell
        //SharedManager.shared.clearProgressBar()
        var isVisible = false
        var indexPathVisible:  IndexPath?
        for indexPath in tableViewRelevant.indexPathsForVisibleRows ?? [] {
            let cellRect = tableViewRelevant.rectForRow(at: indexPath)
            isVisible = tableViewRelevant.bounds.contains(cellRect)
            if isVisible {
                //print("indexPath is Visible")
                indexPathVisible = indexPath
                break
            }
        }
        if isVisible == false {
            //print("indexPath not Visible")
            let center = self.view.convert(tableViewRelevant.center, to: tableViewRelevant)
            indexPathVisible = tableViewRelevant.indexPathForRow(at: center)
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
            if let cell = tableViewRelevant.cellForRow(at: indexPath) as? HomeCardCell {
                
                // Play audio only when vc is visible
                if isApiCallAlreadyRunning == false && isViewPresenting && (arrRelevant[articleSection].articles?.count ?? 0) > 0 {
                    
                    if let content = self.arrRelevant[articleSection].articles?[indexPath.row] {
                        cell.setupSlideScrollView(article: content, isAudioPlay: true, row: indexPath.row, isMute: content.mute ?? true)
                    }
                    //print("audio playing")
                } else {
                    //print("audio playing skipped")
                }
            }
            else if let cell = tableViewRelevant.cellForRow(at: indexPath) as? HomeListViewCC {
                
                //ASSIGN CELL FOR LSIT VIEW
                // Play audio only when vc is visible
                if isApiCallAlreadyRunning == false && isViewPresenting && arrRelevant[articleSection].articles?.count ?? 0 > 0 {

                    
                    if let content = self.arrRelevant[articleSection].articles?[indexPath.row] {
                        cell.setupCellBulletsView(article: content, isAudioPlay: true, row: indexPath.row, isMute: content.mute ?? true)
                    }
                    print("audio playing")
                } else {
                    print("audio playing skipped")
                }
                
            }
            else if let yCell = tableViewRelevant.cellForRow(at: indexPath) as? YoutubeCardCell {
                
                self.curYoutubeVisibleCell = yCell
                yCell.setFocussedYoutubeView()
            }
            else if let vCell = tableViewRelevant.cellForRow(at: indexPath) as? VideoPlayerVieww {
                
                self.curVideoVisibleCell = vCell
                
//                vCell.playVideo(isPause: false)
                playVideoOnFocus(cell: vCell, isPause: false)
            }
        }
        else {
            
            if let yCell = self.getCurrentFocussedCell() as? YoutubeCardCell {
     
                
                yCell.resetYoutubeCard()
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
           resetPlayerAtIndex(cell: vCell)
        }

    }
}


extension RelevantVC: BulletDetailsVCLikeDelegate {
    
    func likeUpdated(articleID: String, isLiked: Bool, count: Int) {
        
        if let index = self.arrRelevant[articleSection].articles?.firstIndex(where: { $0.id == articleID }) {
            self.arrRelevant[articleSection].articles?[index].info?.isLiked = isLiked
            self.arrRelevant[articleSection].articles?[index].info?.likeCount = count
            let cell = tableViewRelevant.cellForRow(at: IndexPath(row: index, section: articleSection))
            
            (cell as? HomeListViewCC)?.setLikeComment(model: self.arrRelevant[articleSection].articles?[index].info)
//            (cell as? HomeCardCell)?.setLikeComment(model: self.arrRelevant[articleSection].articles?[index].info)
            (cell as? YoutubeCardCell)?.setLikeComment(model: self.arrRelevant[articleSection].articles?[index].info)
            (cell as? VideoPlayerVieww)?.setLikeComment(model: self.arrRelevant[articleSection].articles?[index].info)
        }
    }
    
    func commentUpdated(articleID: String, count: Int) {
        
    }
    func backButtonPressed(isVideoPlaying: Bool) {
        
    }
}

// MARK: - Webservices
extension RelevantVC {
    
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
    
    func performWSToShare(article: articlesData, isOpenForNativeShare: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
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
                    
                    SharedManager.shared.instaMediaUrl = ""
                    self.authorBlock = FULLResponse.author_blocked ?? false
                    self.sourceBlock = FULLResponse.source_blocked ?? false
                    self.sourceFollow = FULLResponse.source_followed ?? false
                    self.article_archived = FULLResponse.article_archived ?? false
                    
                    self.urlOfImageToShare = URL(string: article.link ?? "")
                    self.shareTitle = FULLResponse.share_message ?? ""
                    
                    self.updateProgressbarStatus(isPause: true)
                    if let media = FULLResponse.download_link {
                        
                        SharedManager.shared.instaMediaUrl = media
                    }
                    
                    if isOpenForNativeShare {
                        self.openDefaultShareSheet(shareTitle: self.shareTitle)
                    }
                    else {
                        let vc = BottomSheetVC.instantiate(fromAppStoryboard: .registration)
                        vc.delegateBottomSheet = self
                        vc.article = article
                        vc.isMainScreen = true
                        vc.sourceBlock = self.sourceBlock
                        vc.sourceFollow = self.sourceFollow
                        vc.article_archived = self.article_archived
                        vc.share_message = FULLResponse.share_message ?? ""
                        vc.modalPresentationStyle = .overFullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/articles/\(article.id ?? "")/share/info", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
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
                        
//                        if SharedManager.shared.isShowTopic {
//                            SharedManager.shared.isFromTopic = false
//                        }
//                        else {
//                            SharedManager.shared.isFromTopic = false
//                        }
//
//                        SharedManager.shared.isShowTopic = false
//                        SharedManager.shared.isShowSource = true
                        
//                        if let sources = Info.categories {
//
//                            SharedManager.shared.subSourcesList = sources
//                        }
                        
                        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
                        detailsVC.channelInfo = Info
                        //detailsVC.delegateVC = self
                        //detailsVC.isOpenFromDiscoverCustomListVC = true
                        detailsVC.modalPresentationStyle = .fullScreen
                        let nav = AppNavigationController(rootViewController: detailsVC)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                        //navigationController?.pushViewController(detailsVC, animated: true)

//                        if let source = article.source {
//
//                            detailsVC.selectedID = source.id ?? ""
//                            detailsVC.isFav = Info.favorite ?? false
//                            SharedManager.shared.subSourcesTitle = Info.name ?? ""
//                            detailsVC.modalPresentationStyle = .fullScreen
//
//                            self.navigationController?.pushViewController(detailsVC, animated: true)
////                            if self.showArticleType == .savedArticle {
////
////                                detailsVC.modalPresentationStyle = .overFullScreen
////                                detailsVC.modalTransitionStyle = .crossDissolve
////                                self.present(detailsVC, animated: true, completion: nil)
////                            }
////                            else{
////
////                                self.navigationController?.pushViewController(detailsVC, animated: true)
////                            }
//                        }
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
    
    func performWSToUpdateUserFollow(id:String, isFav: Bool, type: searchType, completionHandler: @escaping CompletionHandler) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        var params = ["topics":id]
        var url = isFav ? "news/topics/follow" : "news/topics/unfollow"
        if type == .sources {
            params = ["sources":id]
            url = isFav ? "news/sources/follow" : "news/sources/unfollow"
        }
        if type == .locations {
            params = ["locations":id]
            url = isFav ? "news/locations/follow" : "news/locations/unfollow"
        }
        if type == .authors {
            params = ["authors":id]
            url = isFav ? "news/authors/follow" : "news/authors/unfollow"
        }
        
        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateTopicDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                completionHandler(false)
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            
            completionHandler(false)
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToOpenTopics(topics: TopicData?) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        let id = topics?.id ?? ""
        let title = topics?.name ?? ""
        let url = "news/topics/related/\(id)"
        let favorite = topics?.favorite ?? false
        
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do {
                let FULLResponse = try
                    JSONDecoder().decode(SubTopicDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let topics = FULLResponse.topics {
                        
                        SharedManager.shared.subTopicsList = topics
//                        SharedManager.shared.articleSearchModeType = ""
                        
                        let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
                        vc.showArticleType = .topic
                        vc.selectedID = id
                        vc.isFav = favorite
                        vc.subTopicTitle = title
                        self.navigationController?.pushViewController(vc, animated: true)
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
    
}


extension RelevantVC: RelevantTopCCDelegate {
    
    func didTapFollow(cell: RelevantTopCC) {
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {
            return
        }
        cell.isUserInteractionEnabled = false
        
        var id = ""
        var isFav = false
        if arrRelevant[indexPath.section].type == .locations {
            id = arrRelevant[indexPath.section].locations?[indexPath.row].id ?? ""
            
            isFav = (arrRelevant[indexPath.section].locations?[indexPath.row].favorite ?? false) ? false : true
            arrRelevant[indexPath.section].locations?[indexPath.row].favorite = isFav
            
        }
        if arrRelevant[indexPath.section].type == .sources {
            id = arrRelevant[indexPath.section].sources?[indexPath.row].id ?? ""
            
            isFav = (arrRelevant[indexPath.section].sources?[indexPath.row].favorite ?? false) ? false : true
            arrRelevant[indexPath.section].sources?[indexPath.row].favorite = isFav
            
        }
        if arrRelevant[indexPath.section].type == .topics {
            id = arrRelevant[indexPath.section].topics?[indexPath.row].id ?? ""
            
            isFav = (arrRelevant[indexPath.section].topics?[indexPath.row].favorite ?? false) ? false : true
            arrRelevant[indexPath.section].topics?[indexPath.row].favorite = isFav
            
        }
        if arrRelevant[indexPath.section].type == .authors {
            id = arrRelevant[indexPath.section].authors?[indexPath.row].id ?? ""
            
            isFav = (arrRelevant[indexPath.section].authors?[indexPath.row].favorite ?? false) ? false : true
            arrRelevant[indexPath.section].authors?[indexPath.row].favorite = isFav
            
        }
        
        
        tableViewRelevant.reloadRows(at: [indexPath], with: .none)
        self.performWSToUpdateUserFollow(id: id, isFav: isFav, type: arrRelevant[indexPath.section].type) { [weak self] status in
            cell.isUserInteractionEnabled = true
            if status {
                
            } else {
                // reset on failure
                if self?.arrRelevant[indexPath.section].type == .locations {
                    self?.arrRelevant[indexPath.section].locations?[indexPath.row].favorite = isFav ? false : true
                }
                if self?.arrRelevant[indexPath.section].type == .sources {
                    self?.arrRelevant[indexPath.section].sources?[indexPath.row].favorite = isFav ? false : true
                }
                if self?.arrRelevant[indexPath.section].type == .topics {
                    self?.arrRelevant[indexPath.section].topics?[indexPath.row].favorite = isFav ? false : true
                }
                if self?.arrRelevant[indexPath.section].type == .authors {
                    self?.arrRelevant[indexPath.section].authors?[indexPath.row].favorite = isFav ? false : true
                }
                
                self?.tableViewRelevant.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func didTapCategory(cell: RelevantTopCC) {
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {
            return
        }
        
        if arrRelevant[indexPath.section].type == .locations {
            SharedManager.shared.subLocationList = [Location]()
//            SharedManager.shared.articleSearchModeType = ""
            
            let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
            vc.showArticleType = .places
            vc.selectedID = arrRelevant[indexPath.section].locations?.first?.id ?? ""
            vc.isFav = arrRelevant[indexPath.section].locations?.first?.favorite ?? false
            vc.placeContextId = arrRelevant[indexPath.section].locations?.first?.context ?? ""
            vc.subTopicTitle = arrRelevant[indexPath.section].locations?.first?.city ?? ""
                    
            self.navigationController?.pushViewController(vc, animated: true)
//            let navVC = AppNavigationController(rootViewController: vc)
//            navVC.modalPresentationStyle = .fullScreen
//            navVC.navigationBar.isHidden = true
//            self.present(navVC, animated: true, completion: nil)
        } else {
            if arrRelevant[indexPath.section].type == .topics {
                performWSToOpenTopics(topics: arrRelevant[indexPath.section].topics?.first)
            }
            if arrRelevant[indexPath.section].type == .sources {
                self.performGoToSource(id: arrRelevant[indexPath.section].sources?.first?.id ?? "")
            }
        }
        
    }
    
}

extension RelevantVC: RelevantCellDelegate {
    
    
    func didSelectViewAll(type: searchType, currentModel: Relevant) {
        
        if type == .articles {
            
        }
        else if type == .topics {
            
            let vc = channelsChildVC.instantiate(fromAppStoryboard: .Main)
            vc.relevant = currentModel
            vc.VcType = "topics"
            self.navigationController?.pushViewController(vc, animated: false)
        }
        else if type == .sources {
            
            let vc = channelsChildVC.instantiate(fromAppStoryboard: .Main)
            vc.relevant = currentModel
            vc.VcType = "sources"
            self.navigationController?.pushViewController(vc, animated: false)
        }
        else if type == .authors {
            
            let vc = channelsChildVC.instantiate(fromAppStoryboard: .Main)
            vc.relevant = currentModel
            vc.VcType = "authors"
            self.navigationController?.pushViewController(vc, animated: false)
        }
        else if type == .locations {
            
            let vc = channelsChildVC.instantiate(fromAppStoryboard: .Main)
            vc.relevant = currentModel
            vc.VcType = "locations"
            self.navigationController?.pushViewController(vc, animated: false)
        }
       
//        self.getRefreshArticlesData()
//        updateProgressbarStatus(isPause: true)
//        self.delegate?.userDidSelectViewAll(type: type)
    }
    
    
    func didSelectCategory(location: Location?, topics: TopicData?, source: ChannelInfo?, author: Author?, reels: Reel?) {
        
        
        if location != nil {
            SharedManager.shared.subLocationList = [Location]()
//            SharedManager.shared.articleSearchModeType = ""
            
            let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
            vc.showArticleType = .places
            vc.selectedID = location?.id ?? ""
            vc.isFav = location?.favorite ?? false
            vc.placeContextId = location?.context ?? ""
            vc.subTopicTitle = location?.city ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
            
//            let navVC = AppNavigationController(rootViewController: vc)
//            navVC.modalPresentationStyle = .fullScreen
//            navVC.navigationBar.isHidden = true
//            self.present(navVC, animated: true, completion: nil)
        } else if topics != nil {
            performWSToOpenTopics(topics: topics)
        }
        else if source != nil {
            self.performGoToSource(id: source?.id ?? "")
        }
        else if author != nil {
            
            if (author?.id ?? "") == SharedManager.shared.userId {
                
                let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
                let navVC = AppNavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen
                //vc.delegate = self
                self.present(navVC, animated: true, completion: nil)
            }
            else {
                
                let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                vc.authors = [Authors(id: author?.id, name: author?.first_name, username: author?.username, image: author?.profile_image, favorite: author?.favorite)]
                let navVC = AppNavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen
                //vc.delegate = self
                self.present(navVC, animated: true, completion: nil)
            }
        }
        else if reels != nil {
            
            let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
            vc.contextID = reels?.context ?? ""
//            vc.titleText = "Newsreels"
            vc.isBackButtonNeeded = true
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            let nav = AppNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .overFullScreen
            self.present(nav, animated: true, completion: nil)
        }
        
    }
    
    
    func didTapAddButton(cell: RelevantCell, secondaryIndex: IndexPath, favorite: Bool) {
        
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {
            return
        }
        
        var selectedType: followType = .topics
        var contentId = ""
        if arrRelevant[indexPath.section].type == .topics {
            selectedType = .topics
            arrRelevant[indexPath.section].topics?[secondaryIndex.item].favorite = favorite
            contentId = arrRelevant[indexPath.section].topics?[secondaryIndex.item].id ?? ""
        }
        else if arrRelevant[indexPath.section].type == .sources {
            selectedType = .sources
            arrRelevant[indexPath.section].sources?[secondaryIndex.item].favorite = favorite
            contentId = arrRelevant[indexPath.section].sources?[secondaryIndex.item].id ?? ""
        }
        else if arrRelevant[indexPath.section].type == .locations {
            selectedType = .locations
            arrRelevant[indexPath.section].locations?[secondaryIndex.item].favorite = favorite
            contentId = arrRelevant[indexPath.section].locations?[secondaryIndex.item].id ?? ""
        }
        else if arrRelevant[indexPath.section].type == .authors {
            selectedType = .authors
            arrRelevant[indexPath.section].authors?[secondaryIndex.item].favorite = favorite
            contentId = arrRelevant[indexPath.section].authors?[secondaryIndex.item].id ?? ""
        } else {
            return
        }
        
        
        SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [contentId], isFav: favorite, type: selectedType) { status in
            if status {
                print("status", status)
            } else {
                print("status", status)
            }
        }
    }
    
}


extension RelevantVC: CommentsVCDelegate {
 
    func commentsVCDismissed(articleID: String) {
        self.updateProgressbarStatus(isPause: false)
        
        
        SharedManager.shared.performWSToGetCommentsCount(id: articleID) { info in
            if info != nil {
                
                if let selectedIndex = self.arrRelevant[self.articleSection].articles?.firstIndex(where: { $0.id == articleID }) {
//                    self.articles[selectedIndex].info = info
                    self.arrRelevant[self.articleSection].articles?[selectedIndex].info?.commentCount = info?.commentCount ?? 0
                    
                    if let cell = self.tableViewRelevant.cellForRow(at: IndexPath(row: selectedIndex, section: self.articleSection)) {
                        (cell as? HomeListViewCC)?.setLikeComment(model: self.arrRelevant[self.articleSection].articles?[selectedIndex].info)
//                        (cell as? HomeCardCell)?.setLikeComment(model: self.arrRelevant[self.articleSection].articles?[selectedIndex].info)
                        (cell as? YoutubeCardCell)?.setLikeComment(model: self.arrRelevant[self.articleSection].articles?[selectedIndex].info)
                        (cell as? VideoPlayerVieww)?.setLikeComment(model: self.arrRelevant[self.articleSection].articles?[selectedIndex].info)
                    }
                    
                }
            }
        }
        
        
    }
    
}



// MARK: - Ads
// Google Ads
extension RelevantVC: GADUnifiedNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
        self.googleNativeAd = nil
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        
        //print("Ad loader came with results")
        print("Received native ad: \(nativeAd)")
        self.googleNativeAd = nativeAd
        
        DispatchQueue.main.async {
            let visibleCells = self.tableViewRelevant.visibleCells
            
            for cell in visibleCells {
                
                if let cell = cell as? HomeListAdsCC {
                    cell.loadGoogleAd(nativeAd: self.googleNativeAd!)
                }
            }
        }
        
        
    }
    
}

// Facebook Ads
extension RelevantVC: FBNativeAdDelegate {
    
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        
        // 1. If there is an existing valid native ad, unregister the view
        if let previousNativeAd = self.fbnNativeAd, previousNativeAd.isAdValid {
            previousNativeAd.unregisterView()
        }
        
        // 2. Retain a reference to the native ad object
        self.fbnNativeAd = nativeAd
        
        DispatchQueue.main.async {
            let visibleCells = self.tableViewRelevant.visibleCells
            
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


extension RelevantVC: SharingDelegate, UIDocumentInteractionControllerDelegate {
    
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
            self.performGoToSource(id: article.source?.id ?? "")
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
    
    func stopIndicatorLoading() {
        
//        if self.indicator.isAnimating {
//
//            DispatchQueue.main.async {
//
//                self.indicator.stopAnimating()
//                self.indicator.isHidden = true
//                self.viewIndicator.isHidden = true
//            }
//        }
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
}

extension RelevantVC: ReelsVCDelegate {
    
    func currentPlayingVideoChanged(newIndex: IndexPath) {
    }
    
    func changeScreen(pageIndex: Int) {
    }
    
    func switchBackToForYou() {
        
    }
    func loaderShowing(status: Bool) {
    }
    
    func backButtonPressed(_ isUpdateSavedArticle: Bool) {
        
//        SharedManager.shared.isOnDiscover = true
//        if SharedManager.shared.videoAutoPlay {
//
//            playCurrentlyFocusedMedia()
//        }
    }
    
}

extension RelevantVC {
    
    func performUnFollowUserSource(_ id: String, name:String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedSource, channel_id: id)

        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        
        ANLoader.showLoading(disableUI: false)
        WebService.URLResponse("news/sources/unfollow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    self.updateProgressbarStatus(isPause: false)
                    if status == Constant.STATUS_SUCCESS {
                        
                        SharedManager.shared.isDiscoverTabReload = true
                        SharedManager.shared.isTabReload = true
                        SharedManager.shared.isFav = false
                        NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
                        SharedManager.shared.showAlertLoader(message: "Unfollowed \(name)", type: .alert)
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/unfollow", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToFollowSource(_ id: String, name:String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.followSource, channel_id: id)

        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: false)
        
        let params = ["sources": id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse("news/sources/follow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateSourceDC.self, from: response)
                
                SharedManager.shared.isDiscoverTabReload = true
                SharedManager.shared.isTabReload = true
                SharedManager.shared.isFav = true
                NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
                self.updateProgressbarStatus(isPause: false)
                if FULLResponse.message == "Success" {
                    
                    SharedManager.shared.showAlertLoader(message: "Followed \(name)", type: .alert)
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/follow", error: jsonerror.localizedDescription, code: "")
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
        ANLoader.showLoading(disableUI: false)
        
        let param = ["sources":id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/unblock", method: .post, parameters:param , headers: token, withSuccess: { (response) in
            
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                self.updateProgressbarStatus(isPause: false)
                if FULLResponse.message == "Success" {
                    
                    SharedManager.shared.showAlertLoader(message: "Unblocked \(name)", type: .alert)
                }
                else {
                    
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                ANLoader.hide()
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/unblock", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            ANLoader.hide()
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
                        
                        SharedManager.shared.isDiscoverTabReload = true
                        SharedManager.shared.isTabReload = true
                        SharedManager.shared.showAlertLoader(message: "Blocked \(sourceName)", type: .alert)
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/block", error: jsonerror.localizedDescription, code: "")

            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToBlockUnblockAuthor(_ id: String, name: String) {
        
        
        if authorBlock == false {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockauthor, eventDescription: "", author_id: id)
        }
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        ANLoader.showLoading(disableUI: false)
        
        let param = ["authors": id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let query = authorBlock ? "news/authors/unblock" : "news/authors/block"
        
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
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")

            }
        }) { (error) in
            print("error parsing json objects",error)
        }
    }
}


extension RelevantVC: AquamanChildViewController {
    
    func aquamanChildScrollView() -> UIScrollView {
        return tableViewRelevant
    }
    
}


extension RelevantVC {
    
    
    // MARK : - Search Methods
    func refreshVC() {
        
        self.seachNoDataView.isHidden = true
        hideCustomLoader(isAnimated: false)
        self.tableViewRelevant.hideLoaderView()
        arrRelevant.removeAll()
        tableViewRelevant.reloadData()
        searchText = ""
        showSearchView()

    }
    
    func getSearchContent(search: String) {
        refreshVC()
        searchText = search
        self.performWSToRelevantList(searchText: searchText, page: "")

    }
    
    
    func appEnteredBackground() {
        

        
    }
    
    
    func appLoadedToForeground() {
        
        //do stuff using the userInfo property of the notification object
        if self.arrRelevant.count > 0 && arrRelevant.count - 1 > articleSection {
            
            let index = self.focussedIndexPath
            
            //reset current visible cell of Card List which is same index of list view
            if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
                cell.clvBullets.isHidden = true
                cell.resetVisibleCard()
            }
            
            if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
                cell.clvBullets.isHidden = true
                cell.resetVisibleListCell()
            }
            
            if let cell = self.getCurrentFocussedCell() as? VideoPlayerVieww {
//                cell.resetVisibleVideoPlayer()
                resetPlayerAtIndex(cell: cell)
            }
            
            else if let cell = self.getCurrentFocussedCell() as? YoutubeCardCell {
                cell.resetYoutubeCard()
            }
            
            self.tableViewRelevant.reloadRows(at: [index], with: .none)
        }
    }
    
    func stopAll() {
        
        self.updateProgressbarStatus(isPause: true)

    }
    
    
    func showCustomLoader() {
        
        self.appLoaderView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.loaderViewHeightConstraint.constant = 100
            self.view.layoutIfNeeded()
        } completion: { status in
        }
    }
    
    func hideCustomLoader(isAnimated: Bool = true) {
        
        if isAnimated {
            UIView.animate(withDuration: 0.25) {
//                self.loaderViewHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            } completion: { status in
                self.appLoaderView.isHidden = true
            }
        }
        else {
//            self.loaderViewHeightConstraint.constant = 0
            self.appLoaderView.isHidden = true
        }
        
    }
    
    
}


extension RelevantVC: RelatedSourcesCCDelegate {
    
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
    
    func didTapSeeAll(cell: RelatedSourcesCC) {
        //        let vc = FollowingAuthorsVC.instantiate(fromAppStoryboard: .Channel)
        //        let nav = AppNavigationController(rootViewController: vc)
        //        vc.delegate = self
        //        self.present(nav, animated: true, completion: nil)
    }
    
    
    func didSelectItem(cell: RelatedSourcesCC, secondaryIndex: IndexPath) {
        
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {
            return
        }
        //        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)
        
        if let channel = self.arrRelevant[indexPath.section].sources?[secondaryIndex.item] {
            openChannelDetails(channel: channel)
        }
    }
    
    func didTapFollowing(cell: RelatedSourcesCC, secondaryIndex: IndexPath) {
        
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {
            return
        }
        
        let fav = self.arrRelevant[indexPath.section].sources?[secondaryIndex.item].favorite ?? false
        let id = self.arrRelevant[indexPath.section].sources?[secondaryIndex.item].id ?? ""
        self.arrRelevant[indexPath.section].sources?[secondaryIndex.item].isShowingLoader = true
        cell.channelsArray[secondaryIndex.item].isShowingLoader = true
        
        cell.collectionView.reloadItems(at: [secondaryIndex])
        
        SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [id], isFav: !fav, type: .sources) {  success in
            
            self.arrRelevant[indexPath.section].sources?[secondaryIndex.item].isShowingLoader = false
            cell.channelsArray[secondaryIndex.item].isShowingLoader = false
            
            if success {
                self.arrRelevant[indexPath.section].sources?[secondaryIndex.item].favorite = !fav
                cell.channelsArray[secondaryIndex.item].favorite = !fav
            }
            
            cell.collectionView.reloadItems(at: [secondaryIndex])
            
        }
        
    }
}

extension RelevantVC: ChannelDetailsVCDelegate {
    
    func backButtonPressedChannelDetailsVC(_ channel: ChannelInfo?) {
    }
    
    func backButtonPressedWhenFromReels(_ channel: ChannelInfo?) {
    }
    
}

extension RelevantVC: AddTopicsVCDelegate, AddLocationVCDelegate, FollowingAuthorsVCDelegate {
    
    func followingListUpdated() {
    }
    
    
    func locationListUpdated() {
    }
    
    func topicsListUpdated() {
    }
}

extension RelevantVC: NewTopicsCCDelegate {
    
    func openAddLocation() {
        
        let vc = AddLocationVC.instantiate(fromAppStoryboard: .Reels)
        vc.delegate = self
        self.present(vc, animated: true)
        
    }
    
    func openAddTopics() {
        
        let vc = AddTopicsVC.instantiate(fromAppStoryboard: .Reels)
        vc.delegate = self
        self.present(vc, animated: true)
        
    }
    
    
    func didTapSeeallTopics(cell: NewTopicsCC) {
        if cell.topicArray.count > 0 {
            // Open add topics
            openAddTopics()
        }
        else if cell.locationsArray.count > 0 {
            // Open add locations
            openAddLocation()
        }
    }
    
    
    func didSelectItem(cell: NewTopicsCC, secondaryIndex: Int) {
        
        guard let indexPath = tableViewRelevant.indexPath(for: cell) else {
            return
        }
        var context = ""
        var topicTitle = ""
        if cell.topicArray.count > 0 {
            context = arrRelevant[indexPath.section].topics?[secondaryIndex].context ?? ""
            topicTitle = arrRelevant[indexPath.section].topics?[secondaryIndex].name ?? ""
        }
        else if cell.locationsArray.count > 0 {
            context = arrRelevant[indexPath.section].locations?[secondaryIndex].context ?? ""
            topicTitle = arrRelevant[indexPath.section].locations?[secondaryIndex].name ?? ""
        }
        
        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
        detailsVC.isOpenFromReel = false
        detailsVC.delegate = self
        detailsVC.isOpenForTopics = true
        detailsVC.context = context
        detailsVC.topicTitle = topicTitle
        detailsVC.modalPresentationStyle = .fullScreen
        
        let nav = AppNavigationController(rootViewController: detailsVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
    }
    
    func openAddOther(cell: NewTopicsCC) {
        
        
        if cell.topicArray.count > 0 {
            // Open add topics
            openAddTopics()
        }
        else if cell.locationsArray.count > 0 {
            // Open add locations
            openAddLocation()
        }
    }
    
    func didCellReloaded(cell: NewTopicsCC) {
        
        guard let indexPath = self.tableViewRelevant.indexPath(for: cell) else {
            return
        }
        if cell.topicArray.count > 0 {
            arrRelevant[indexPath.section].topics = cell.topicArray
        }
        else if cell.locationsArray.count > 0 {
            arrRelevant[indexPath.section].locations = cell.locationsArray
        }
        
        self.tableViewRelevant.reloadData()
        
    }
    
    
    func didTapFollow(cell: NewTopicsCC, secondaryIndex: Int) {
        
        guard let indexPath = self.tableViewRelevant.indexPath(for: cell) else {
            return
        }
        let cellIndex = IndexPath(item: secondaryIndex, section: 0)
        if cell.topicArray.count > 0 {
            //            self.topicsArray = cell.topicArray
            let fav = arrRelevant[indexPath.section].topics?[cellIndex.item].favorite ?? false
            arrRelevant[indexPath.section].topics?[cellIndex.item].isShowingLoader = true
            if let topic = arrRelevant[indexPath.section].topics {
                cell.topicArray = topic
            }
            
            cell.collectionView.reloadItems(at: [cellIndex])
            
            SharedManager.shared.performWSToUpdateUserFollow(id: [arrRelevant[indexPath.section].topics?[cellIndex.item].id ?? ""], isFav: !fav, type: .topics) { status in
                
                self.arrRelevant[indexPath.section].topics?[cellIndex.item].isShowingLoader = false
                self.arrRelevant[indexPath.section].topics?[cellIndex.item].favorite = !fav
                if let topic = self.arrRelevant[indexPath.section].topics {
                    cell.topicArray = topic
                }
                
                cell.collectionView.reloadItems(at: [cellIndex])
                
            }
        }
        else if cell.locationsArray.count > 0 {
            //            self.topicsArray = cell.topicArray
            let fav = arrRelevant[indexPath.section].locations?[cellIndex.item].favorite ?? false
            arrRelevant[indexPath.section].locations?[cellIndex.item].isShowingLoader = true
            if let topic = arrRelevant[indexPath.section].locations {
                cell.locationsArray = topic
            }
            
            cell.collectionView.reloadItems(at: [cellIndex])
            
            SharedManager.shared.performWSToUpdateUserFollow(id: [arrRelevant[indexPath.section].locations?[cellIndex.item].id ?? ""], isFav: !fav, type: .locations) { status in
                
                self.arrRelevant[indexPath.section].locations?[cellIndex.item].isShowingLoader = false
                self.arrRelevant[indexPath.section].locations?[cellIndex.item].favorite = !fav
                if let locations = self.arrRelevant[indexPath.section].locations {
                    cell.locationsArray = locations
                }
                
                cell.collectionView.reloadItems(at: [cellIndex])
                
            }
        }
        
    }
    
}
