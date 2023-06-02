//
//  ProfileArticlesVC.swift
//  Bullet
//
//  Created by Mahesh on 13/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds
import FBAudienceNetwork
import Photos
import FBSDKShareKit

class ProfileArticlesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgNoPost: UIImageView!
    @IBOutlet weak var lblNoPost: UILabel!
    @IBOutlet weak var viewNoPost: UIView!
    @IBOutlet weak var imgUploadBorder: UIImageView!
    @IBOutlet weak var btnUpload: UIButton!
    
    @IBOutlet weak var appLoaderView: UIView!
    @IBOutlet weak var loaderView: GMView!
    @IBOutlet weak var loaderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var seachNoDataView: UIView!
    
    
    var dismissKeyboard : (()-> Void)?
    var isOpenForTopics = false
    var context = ""
    
    var isApiCallAlreadyRunning = false
    var nextPageData = ""
    var articlesArray = [articlesData]()
    var focussedIndexPath = IndexPath(row: 0, section: 0)
    var forceSelectedIndexPath: IndexPath?
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
    
    var authorID = ""
    var channelInfo: ChannelInfo?
    var isOwnChannel = false
    var isFromChannelView = false

    
    var adLoader: GADAdLoader? = nil
    var fbnNativeAd: FBNativeAd? = nil
    var googleNativeAd: GADUnifiedNativeAd?
    
    var isFromDrafts = false
    var isFromSaveArticles = false
    
    var mediaWatermark = MediaWatermark()
    var DocController: UIDocumentInteractionController = UIDocumentInteractionController()
    
    var searchText = ""
    var isOnSearch = false
    
    
    @IBOutlet weak var indicator: InstagramActivityIndicator!
    @IBOutlet weak var viewIndicator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
//        self.view.theme_backgroundColor = GlobalPicker.backgroundColor //GlobalPicker.backgroundColorHomeCell
        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        registerCells()
        
        performWSToGetArticles(page: "")
        setupNoPostView()
        
        indicator.animationDuration = 1.0
        indicator.rotationDuration = 3
        indicator.numSegments = 15
        indicator.strokeColor = "#E01335".hexStringToUIColor()
        indicator.lineWidth = 3
        
        seachNoDataView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        isViewPresenting = true
        
        if isFirstTimeCalled {
            articlesArray.removeAll()
            tableView.reloadData()
            performWSToGetArticles(page: "")
        }
        isFirstTimeCalled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedFromBackgroundToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        stopAllData()
        
    }
    
    func stopAllData() {
        
        updateProgressbarStatus(isPause: true)
        
        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.viewIndicator.isHidden = true
        }
    }
    
    
    func reloadData() {
        
//        if let visibleIndexPath = tableView.indexPathsForVisibleRows {
//            self.tableView.reloadData()
////            if visibleIndexPath.contains(focussedIndexPath) {
////                self.tableView.reloadRows(at: [focussedIndexPath], with: .none)
////            }
////            else {
////                self.tableView.reloadData()
////            }
//           // updateProgressbarStatus(isPause: false)
//        }
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
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        isViewPresenting = false
        NotificationCenter.default.removeObserver(self)
    }

    func registerCells() {
        
        //tableView.register(UINib(nibName: "CustomBulletsCC", bundle: nil), forCellReuseIdentifier: "CustomBulletsCC")
        //tableView.register(UINib(nibName: "HeaderRelatedArticles", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderRelatedArticles")
        
        tableView.register(UINib(nibName: CELL_IDENTIFIER_HOME_LISTVIEW, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW)
        tableView.register(UINib(nibName: CELL_IDENTIFIER_HOME_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_CARD)
        tableView.register(UINib(nibName: CELL_IDENTIFIER_ADS_LIST, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_ADS_LIST)
        tableView.register(UINib(nibName: CELL_IDENTIFIER_YOUTUBE_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_YOUTUBE_CARD)
        tableView.register(UINib(nibName: CELL_IDENTIFIER_VIDEO_PLAYER, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER)
        
    }
    
    func setupNoPostView() {
        // #212123
        viewNoPost.isHidden = true
        
        if isFromChannelView {
            
            //For Channels view
            if isOwnChannel == false {
                
                imgUploadBorder.isHidden = true
                btnUpload.isHidden = true
                if isFromSaveArticles {
                    lblNoPost.text = NSLocalizedString("No Posts", comment: "")
                }
                lblNoPost.text = NSLocalizedString("No Posts Yet", comment: "")
                
                imgNoPost.image = UIImage(named: "NoPost")
                imgNoPost.theme_tintColor = GlobalPicker.noPostColor
                lblNoPost.theme_textColor = GlobalPicker.noPostColor
                
            } else {
                
                imgUploadBorder.isHidden = false
                btnUpload.isHidden = false
                lblNoPost.text = NSLocalizedString("Upload", comment: "")
                
                imgUploadBorder.theme_tintColor = GlobalPicker.backgroundColorBlackWhite
                imgNoPost.image = UIImage(named: "UploadPost")
                imgNoPost.theme_tintColor = GlobalPicker.uploadPostColor
                lblNoPost.theme_textColor = GlobalPicker.uploadPostColor
            }
        }
        else {
            
            //For Author view
            if authorID != SharedManager.shared.userId {
                
                imgUploadBorder.isHidden = true
                btnUpload.isHidden = true
                if isFromSaveArticles {
                    lblNoPost.text = NSLocalizedString("No Posts", comment: "")
                }
                lblNoPost.text = NSLocalizedString("No Posts Yet", comment: "")
                
                imgNoPost.image = UIImage(named: "NoPost")
                imgNoPost.theme_tintColor = GlobalPicker.noPostColor
                lblNoPost.theme_textColor = GlobalPicker.noPostColor
                
            } else {
                
                imgUploadBorder.isHidden = false
                btnUpload.isHidden = false
                lblNoPost.text = NSLocalizedString("Upload", comment: "")
                
                imgUploadBorder.theme_tintColor = GlobalPicker.backgroundColorBlackWhite
                imgNoPost.image = UIImage(named: "UploadPost")
                imgNoPost.theme_tintColor = GlobalPicker.uploadPostColor
                lblNoPost.theme_textColor = GlobalPicker.uploadPostColor
            }
        }

        
    }
    
    @IBAction func didTapUpload(_ sender: Any) {
        
        if SharedManager.shared.isGuestUser && SharedManager.shared.isLinkedUser == false {
                        
            let vc = RegistrationNewVC.instantiate(fromAppStoryboard: .RegistrationSB)
            let navVC = UINavigationController(rootViewController: vc)
            self.navigationController?.present(navVC, animated: true, completion: nil)

        }
        else {
            
            if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails), (user.setup ?? false) {
                
                if SharedManager.shared.community == false {

                    let vc = CommunityGuideVC.instantiate(fromAppStoryboard: .Schedule)
                    vc.delegate = self
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else {
                    
                    let vc = UploadArticleBottomSheetVC.instantiate(fromAppStoryboard: .Schedule)
                    vc.delegate = self
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true)
                }
            }
            else {
                
                let vc = PopupVC.instantiate(fromAppStoryboard: .Home)
                vc.isFromProfileView = true
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK: - Background Service Methods
    @objc func appMovedToBackground() {
        
        //do stuff using the userInfo property of the notification object
        updateProgressbarStatus(isPause: true)
    }
    
    @objc func appMovedFromBackgroundToForeground() {
        
        //do stuff using the userInfo property of the notification object
        if self.articlesArray.count > 0 {
            
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
            
            self.tableView.reloadRows(at: [index], with: .none)
        }
        
    }
}

//MARK:-
extension ProfileArticlesVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Related Articles
        return self.articlesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let content = self.articlesArray[indexPath.row]
        
        //LOCAL VIDEO TYPE
        if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_VIDEO {

            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            let videoPlayer = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER, for: indexPath) as! VideoPlayerVieww
            
            //Check Upload Processing/scheduled on Article by User
            let status = content.status ?? ""
            if status == Constant.newsArticle.ARTICLE_STATUS_PROCESSING {
                
                videoPlayer.isUserInteractionEnabled = false
                videoPlayer.viewProcessingBG.isHidden = false
                videoPlayer.viewScheduleBG.isHidden = true
                
                if let pubDate = content.publish_time {
                    videoPlayer.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                }
            }
            else if status == Constant.newsArticle.ARTICLE_STATUS_SCHEDULED {
                
                videoPlayer.isUserInteractionEnabled = false
                videoPlayer.viewProcessingBG.isHidden = true
                videoPlayer.viewScheduleBG.isHidden = false
                videoPlayer.lblScheduleTime.text = NSLocalizedString("Scheduled on:", comment: "") + "\n" + SharedManager.shared.utcToLocal(dateStr: content.publish_time ?? "")

                if let pubDate = content.publish_time {
                    videoPlayer.lblTime.text = SharedManager.shared.utcToLocal(dateStr: pubDate)
                }
                //videoPlayer.lblTime.addTextSpacing(spacing: 1.25)
            }
            else {
             
                if let pubDate = content.publish_time {
                    videoPlayer.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                }
                //videoPlayer.lblTime.addTextSpacing(spacing: 1.25)
                
                videoPlayer.isUserInteractionEnabled = true
                videoPlayer.viewProcessingBG.isHidden = true
                videoPlayer.viewScheduleBG.isHidden = true
            }
            
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
            
            videoPlayer.playButton.tag = indexPath.row

            if self.focussedIndexPath == indexPath {
                self.curVideoVisibleCell = videoPlayer
            }
            
            if let bullets = content.bullets {
                
//                    videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: false)
                videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: self.focussedIndexPath == indexPath ? true : false)
            }
            
            videoPlayer.viewDividerLine.isHidden = true
            videoPlayer.constraintContainerViewBottom.constant = 10
            
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
            return adCell
            
        }
        
        //YOUTUBE CARD CELL
        else if content.type?.uppercased() == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            
            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            //print("Volume 37")
            
            let youtubeCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_YOUTUBE_CARD, for: indexPath) as! YoutubeCardCell
            
            //Check Upload Processing/scheduled on Article by User
            let status = content.status ?? ""
            youtubeCell.status = status
            if status == Constant.newsArticle.ARTICLE_STATUS_PROCESSING {
                
                youtubeCell.isUserInteractionEnabled = false
                youtubeCell.viewProcessingBG.isHidden = false
                youtubeCell.viewScheduleBG.isHidden = true
                
                if let pubDate = content.publish_time {
                    youtubeCell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                }
            }
            else if status == Constant.newsArticle.ARTICLE_STATUS_SCHEDULED {
                
                youtubeCell.isUserInteractionEnabled = false
                youtubeCell.viewProcessingBG.isHidden = true
                youtubeCell.viewScheduleBG.isHidden = false
                youtubeCell.lblScheduleTime.text = NSLocalizedString("Scheduled on:", comment: "") + "\n" + SharedManager.shared.utcToLocal(dateStr: content.publish_time ?? "")

                if let pubDate = content.publish_time {
                    youtubeCell.lblTime.text = SharedManager.shared.utcToLocal(dateStr: pubDate)
                }
            }
            else {
             
                youtubeCell.isUserInteractionEnabled = true
                youtubeCell.viewProcessingBG.isHidden = true
                youtubeCell.viewScheduleBG.isHidden = true
                
                if let pubDate = content.publish_time {
                    youtubeCell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                }
    //            youtubeCell.lblTime.addTextSpacing(spacing: 1.25)
            }

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
            //youtubeCell.lblSource.addTextSpacing(spacing: 2.5)
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
            youtubeCell.btnShare.accessibilityIdentifier = "\(indexPath.section)"
            youtubeCell.btnSource.tag = indexPath.row
            youtubeCell.btnSource.accessibilityIdentifier = "\(indexPath.section)"
            youtubeCell.btnPlayYoutube.tag = indexPath.row
            youtubeCell.btnPlayYoutube.accessibilityIdentifier = "\(indexPath.section)"
            
            youtubeCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
            youtubeCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            youtubeCell.btnPlayYoutube.addTarget(self, action: #selector(didTapPlayYoutube(_:)), for: .touchUpInside)

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
            youtubeCell.constraintContainerViewBottom.constant = 10
            
            return youtubeCell
        }
        
        //HOME ARTICLES CELL
        else {
            
            SharedManager.shared.isVolumnOffCard = false
            
            if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_SIMPLE {
                
                //LIST VIEW DESIGN CELL- SMALL CELL
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW, for: indexPath) as? HomeListViewCC else { return UITableViewCell() }
                
                //Check Upload Processing/scheduled on Article by User
                let status = content.status ?? ""
                if status == Constant.newsArticle.ARTICLE_STATUS_PROCESSING {
                    
                    cell.isUserInteractionEnabled = false
                    cell.viewProcessingBG.isHidden = false
                    cell.viewScheduleBG.isHidden = true
                    
                    if let pubDate = content.publish_time {
                        cell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                    }
                }
                else if status == Constant.newsArticle.ARTICLE_STATUS_SCHEDULED {
                    
                    cell.isUserInteractionEnabled = false
                    cell.viewProcessingBG.isHidden = true
                    cell.viewScheduleBG.isHidden = false
                    cell.lblScheduleTime.text = NSLocalizedString("Scheduled on:", comment: "") + "\n" + SharedManager.shared.utcToLocal(dateStr: content.publish_time ?? "")
                    
                    if let pubDate = content.publish_time {
                        cell.lblTime.text = SharedManager.shared.utcToLocal(dateStr: pubDate)
                    }
                }
                else {
                 
                    cell.isUserInteractionEnabled = true
                    cell.viewProcessingBG.isHidden = true
                    cell.viewScheduleBG.isHidden = true
                    
                    if let pubDate = content.publish_time {
                        cell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                    }
    //                cell.lblTime.addTextSpacing(spacing: 1.25)
                }

            
                
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
                
                
                return cell
            }
            else {
                
                //CARD VIEW DESIGN CELL- LARGE CELL
                guard let cardCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_CARD, for: indexPath) as? HomeCardCell else { return UITableViewCell() }
                
                //Check Upload Processing/scheduled on Article by User
                let status = content.status ?? ""
                if status == Constant.newsArticle.ARTICLE_STATUS_PROCESSING {
                    
                    cardCell.isUserInteractionEnabled = false
                    cardCell.viewProcessingBG.isHidden = false
                    cardCell.viewScheduleBG.isHidden = true
                    
                    if let pubDate = content.publish_time {
                        cardCell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                    }
                }
                else if status == Constant.newsArticle.ARTICLE_STATUS_SCHEDULED {
                    
                    cardCell.isUserInteractionEnabled = false
                    cardCell.viewProcessingBG.isHidden = true
                    cardCell.viewScheduleBG.isHidden = false
                    cardCell.lblScheduleTime.text = NSLocalizedString("Scheduled on:", comment: "") + "\n" + SharedManager.shared.utcToLocal(dateStr: content.publish_time ?? "")
                    
                    if let pubDate = content.publish_time {
                        cardCell.lblTime.text = SharedManager.shared.utcToLocal(dateStr: pubDate)
                    }
    //                cardCell.lblTime.addTextSpacing(spacing: 1.25)
                }
                else {
                 
                    cardCell.isUserInteractionEnabled = true
                    cardCell.viewProcessingBG.isHidden = true
                    cardCell.viewScheduleBG.isHidden = true
                    
                    if let pubDate = content.publish_time {
                        cardCell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                    }
    //                cardCell.lblTime.addTextSpacing(spacing: 1.25)
                }

                
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
//                cardCell.btnShare.tag = indexPath.row
//                cardCell.btnShare.accessibilityIdentifier = "\(indexPath.section)"
                cardCell.btnSource.tag = indexPath.row
                cardCell.btnSource.accessibilityIdentifier = "\(indexPath.section)"
                
                cardCell.btnReport.addTarget(self, action: #selector(didTapReport(button:)), for: .touchUpInside)
//                cardCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
                cardCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
                
                if let source = content.source {
                    
                    let sourceURL = source.icon ?? ""
//                    cardCell.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
                    cardCell.lblSource.text = source.name ?? ""
                }
                else {
                    
                    let url = content.authors?.first?.image ?? ""
//                    cardCell.imgWifi?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
                    cardCell.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
                }
//                cardCell.lblSource.addTextSpacing(spacing: 2.5)

                let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
                let source = content.source?.name ?? ""
                
//                cardCell.viewSingleDot.clipsToBounds = false
                if author == source || author == "" {
//                    cardCell.lblAuthor.isHidden = true
//                    cardCell.viewSingleDot.isHidden = true
//                    cardCell.viewSingleDot.clipsToBounds = true
                    cardCell.lblSource.text = source
                }
                else {
                    
                    cardCell.lblSource.text = source
//                    cardCell.lblAuthor.text = author
                    
                    if source == "" {
//                        cardCell.lblAuthor.isHidden = true
//                        cardCell.viewSingleDot.isHidden = true
//                        cardCell.viewSingleDot.clipsToBounds = true
                        cardCell.lblSource.text = author
                    }
                    else if author != "" {
//                        cardCell.lblAuthor.isHidden = false
//                        cardCell.viewSingleDot.isHidden = false
                    }
                }

                
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
                cardCell.constraintContainerViewBottom.constant = 10
                
                return cardCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let content = self.articlesArray[indexPath.row]
        if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_ADS {
            return 200
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if articlesArray.count > 0 && indexPath.row == articlesArray.count - 1 {  //numberofitem count
            if nextPageData.isEmpty == false {
                performWSToGetArticles(page: nextPageData)
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
        if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? HomeCardCell {
            
            let content = self.articlesArray[row]
            if let bullets = content.bullets {
                
                if row == focussedIndexPath.row {
                    setProgressBarSelectedCardCell(cell, bullets)
                    return
                }
                
                // For unselected cell
                self.resetCurrentFocussedCell()
                forceSelectedIndexPath = IndexPath(row: row, section: 0)
                focussedIndexPath = IndexPath(row: row, section: 0)

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
        if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? HomeListViewCC {
            
            // For selected item , currently playing cell
            if row == focussedIndexPath.row
            {

                setProgressBarSelectedCell(cell)
                return
            }
            
            // For unselected cell
            self.resetCurrentFocussedCell()
            forceSelectedIndexPath = IndexPath(row: row, section: 0)
            focussedIndexPath = IndexPath(row: row, section: 0)
            
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
        
        let index = Int(sender.accessibilityIdentifier ?? "0") ?? 0
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeListViewCC {
         
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
                            //SharedManager.shared.spbCardView?.rewind()
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
                forceSelectedIndexPath = IndexPath(row: index, section: 0)
                focussedIndexPath = IndexPath(row: index, section: 0)

                pausePlayAudio(cell)
                
                if sender.tag == 0 {
                    
                    //LEFT
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
        
        
        let index = Int(sender.accessibilityIdentifier ?? "0") ?? 0

        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeCardCell {
            
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
                            //SharedManager.shared.spbCardView?.rewind()
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
                forceSelectedIndexPath = IndexPath(row: index, section: 0)
                focussedIndexPath = IndexPath(row: index, section: 0)

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



// MARK: - Webservices
extension ProfileArticlesVC {
    
    func performWSToGetArticles(page: String) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
//        if self.articlesArray.count == 0 {
//            ANLoader.showLoading(disableUI: false)
//        }
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        isApiCallAlreadyRunning = true
        
        var url = ""
        
        var param = ["page": page]
        
        if isOnSearch {
            url = "news/articles?query=\(searchText)"
        }
        else if isOpenForTopics {
            url = "news/articles?context=\(context)"
        }
        else if isFromDrafts {
            param = [
                "page": page,
                "status": "draft"
            ]
            url = "studio/articles"
        } else if isFromSaveArticles {
            param = [
                "page": page
            ]
            url = "news/articles/archive"
        } else if isFromChannelView {
            
            //For Channels view
            if isOwnChannel {
                url = "studio/articles?source=\(self.channelInfo?.id ?? "")"
            }
            else {
                url = "news/articles?context=\(self.channelInfo?.context ?? "")"
            }
        }
        else {
            
            //For Author view
            url = "studio/articles?source"
            if authorID != SharedManager.shared.userId {
                url = "news/authors/\(authorID)/articles"
            }
        }
        
        if page == "" {
            if isOnSearch {
                self.showCustomLoader()
            }
            else {
                self.showLoaderInVC()
            }
        }
        
        
        WebService.URLResponse(url, method: .get, parameters: param, headers: token, withSuccess: { [weak self] (response) in
            
            self?.hideCustomLoader()
            self?.hideLoaderVC()
            guard let self = self else {
                return
            }
            self.isApiCallAlreadyRunning = false
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(articlesDC.self, from: response)
                
                if let articlesDataObj = FULLResponse.articles, articlesDataObj.count > 0 {
                    
                    self.viewNoPost.isHidden = true
                    if self.articlesArray.count == 0 {
                        self.articlesArray = articlesDataObj
                        
                        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
                            
                            //LOAD ADS
                            //self.refreshAds()
                            self.articlesArray.removeAll{ $0.type == Constant.newsArticle.ARTICLE_TYPE_ADS }
                            self.articlesArray = self.articlesArray.adding(articlesData(id: "", title: "", image: "", link: "", color: "", publish_time: "", source: nil, bullets: nil, topics: nil, status: "", type: Constant.newsArticle.ARTICLE_TYPE_ADS), afterEvery: SharedManager.shared.adsInterval)
                        }
                        
                        UIView.performWithoutAnimation {
                            self.tableView.reloadData {
                                
                                if self.nextPageData.isEmpty {
                                    if let type = self.articlesArray.first?.type, type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                                        self.scrollToTopVisibleExtended()
                                    }
                                }
                            }
                        }
                        
                    } else {
                        
                        for news in articlesDataObj  {
                            if self.articlesArray.contains(where: {$0.id == news.id }) == false {
                                self.articlesArray.append(news)
                            }
                        }
                        
                        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
                            
                            //LOAD ADS
                            //self.refreshAds()
                            self.articlesArray.removeAll{ $0.type == Constant.newsArticle.ARTICLE_TYPE_ADS }
                            self.articlesArray = self.articlesArray.adding(articlesData(id: "", title: "", image: "", link: "", color: "", publish_time: "", source: nil, bullets: nil, topics: nil, status: "", type: Constant.newsArticle.ARTICLE_TYPE_ADS), afterEvery: SharedManager.shared.adsInterval)
                        }
                        
                        UIView.performWithoutAnimation {
                            self.tableView.reloadData()
                        }
                    }
                    
                } else {
                    
                    if self.isOnSearch {
                        self.articlesArray.removeAll()
                        if self.searchText != "" {
                            self.seachNoDataView.isHidden = false
                        }
                    }
                    else {
                        if page == "" {
                            self.articlesArray.removeAll()
                            self.viewNoPost.isHidden = false
                        }
                    }
                    
                    print("Empty Result")
                    UIView.performWithoutAnimation {
                        self.tableView.reloadData()
                    }
                }
                
                // Meta data
                if let next = FULLResponse.meta?.next, next.isEmpty == false {
                    self.nextPageData = next
                } else {
                    self.nextPageData = ""
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                self.hideCustomLoader()
                self.hideLoaderVC()
                self.isApiCallAlreadyRunning = false
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            self.isApiCallAlreadyRunning = false
            self.hideCustomLoader()
            self.hideLoaderVC()
            print("error parsing json objects",error)
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
                
                SharedManager.shared.showAlertLoader(message: NSLocalizedString("Article removed successfully", comment: ""), type: .alert)
                if let index = self.articlesArray.firstIndex(where: { $0.id == id }) {
                    self.articlesArray.remove(at: index)
                    self.tableView.reloadData()
                }
                
                if self.articlesArray.count == 0 {
                    self.performWSToGetArticles(page: "")
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


// Home VC Methods
extension ProfileArticlesVC {
    
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
            
            if let cell = tableView.cellForRow(at: focussedIndexPath) as? HomeCardCell {
                
                cell.pauseAudioAndProgress(isPause:true)
                
            }
            else if let cell = tableView.cellForRow(at: focussedIndexPath) as? HomeListViewCC {
                
                cell.pauseAudioAndProgress(isPause:true)
                
            }
            else if let cell = tableView.cellForRow(at: focussedIndexPath) as? VideoPlayerVieww {
                
//                cell.playVideo(isPause: true)
                playVideoOnFocus(cell: cell, isPause: true)
            }
            else if let cell = tableView.cellForRow(at: focussedIndexPath) as? YoutubeCardCell {
                
                cell.resetYoutubeCard()
            }
            
        }
        else {
            
            if let cell = tableView.cellForRow(at: focussedIndexPath) as? HomeCardCell {
                
                cell.pauseAudioAndProgress(isPause:false)
            }
            else if let cell = tableView.cellForRow(at: focussedIndexPath) as? HomeListViewCC {
                                
                cell.pauseAudioAndProgress(isPause:false)

            }
            else if let cell = tableView.cellForRow(at: focussedIndexPath) as? VideoPlayerVieww {
                
                print("audio playing 3")
//                cell.playVideo(isPause: false)
                playVideoOnFocus(cell: cell, isPause: false)

            }
            else if let cell = tableView.cellForRow(at: focussedIndexPath) as? YoutubeCardCell {
                
                cell.setFocussedYoutubeView()
            }
        }
    }
    
}

//MARK:- HomeCardCell Delegate methods
extension ProfileArticlesVC: HomeCardCellDelegate, YoutubeCardCellDelegate, VideoPlayerViewwDelegates, FullScreenVideoVCDelegate {
    
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
    
    func backButtonPressed(cell: HomeDetailCardCell?) {}
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
            MediaManager.sharedInstance.releasePlayer()
            cell.viewDuration.isHidden = false
            cell.imgPlayButton.isHidden = false
        }
        
    }
    
    
    func didTapVideoPlayButton(cell: VideoPlayerVieww, isTappedFromCell: Bool) {
        
        if isTappedFromCell {
            updateProgressbarStatus(isPause: true)
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let oldFocus = self.focussedIndexPath
        if oldFocus == indexPath {
            
            let art = self.articlesArray[oldFocus.row]
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
        
        MediaManager.sharedInstance.releasePlayer()
        MediaManager.sharedInstance.playEmbeddedVideo(url: url, embeddedContentView: cell.imgPlaceHolder, userinfo: videoInfo, viewController: self, articleID: art.id ?? "")
        MediaManager.sharedInstance.player?.indexPath = indexPath
        MediaManager.sharedInstance.player?.scrollView = tableView
        
    }
    
    
    func resetOldPlayer(oldFocus: IndexPath) {
        
        
        if let cell = tableView.cellForRow(at: oldFocus) as? VideoPlayerVieww {
            
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
        
        // When focus index of card and the user taps index not same then return it
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        // When focus index of card and the user taps index not same then return it
        let row = indexPath.row
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
        vc.isRelatedArticletNeeded = false
        vc.isFromPostArticle = true
        vc.selectedArticleData = content
        vc.delegate = self
        vc.delegateVC = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func seteMaxHeightForIndexPathHomeList(cell: UITableViewCell, maxHeight: CGFloat) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
//        SharedManager.shared.maxHeightForIndexPath[indexPath] = maxHeight
    }
    
    func focusedIndex(index: Int) {
        
        updateProgressbarStatus(isPause: true)
        
        if let vCell = self.tableView.cellForRow(at: self.focussedIndexPath) as? VideoPlayerVieww {
//            vCell.playVideo(isPause: true)
            playVideoOnFocus(cell: vCell, isPause: true)
        }

        self.setupIndexPathForSelectedArticleCardAndListView(index, section: 0)
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
    }
    
    //ARTICLES SWIPE
    func layoutUpdate() {
        
        if articlesArray.count == tableView.numberOfRows(inSection: 0) {
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
        vc.isRelatedArticletNeeded = false
        vc.isFromPostArticle = true
        vc.selectedArticleData = content
        vc.channelInfo = self.channelInfo
        vc.delegate = self
        vc.delegateVC = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
        
    @objc func didTapPlayYoutube(_ button: UIButton) {
        
        //EXTENDED/LIST VIEW TAP TO PLAY YOUTUBE
        updateProgressbarStatus(isPause: true)
        
        let index = button.tag
        if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? YoutubeCardCell {
            
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
        let content = self.articlesArray[index]
        performWSToShare(article: content, idx: index, isOpenForNativeShare: false)
    }
    
    @objc func didTapShare(button: UIButton) {
        
        self.updateProgressbarStatus(isPause: true)
        let index = button.tag
        let content = self.articlesArray[index]
        performWSToShare(article: content, idx: index, isOpenForNativeShare: true)

    }
    
    @objc func didTapSource(button: UIButton) {
        
        //EXTENDED VIEW TAP TO OPEN SOURCE
        //NotificationCenter.default.post(name: Notification.Name.notifyToRemoveVCObservers, object: nil)
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
        
        let index = button.tag
        let section = Int(button.accessibilityIdentifier ?? "0")
        let content = self.articlesArray[index]
        
        if let _ = content.source {
            
            let channelId = self.channelInfo?.id ?? ""
            if channelId == content.source?.id ?? "" {
                return
            }
            
            self.updateProgressbarStatus(isPause: true)
            button.isUserInteractionEnabled = false
            self.performGoToSource(content)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                button.isUserInteractionEnabled = true
            }
        }
        else {
//            self.updateProgressbarStatus(isPause: true)
//
//            let authors = content.authors
//            let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
//            vc.authors = authors
//            let navVC = AppNavigationController(rootViewController: vc)
//            navVC.modalPresentationStyle = .fullScreen
//            //vc.delegate = self
//            self.present(navVC, animated: true, completion: nil)
        }

        
    }
    
    //<---
    // Public delegate methods for all cells are here
    func handleLongPressHold(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        let index: IndexPath = self.focussedIndexPath
                
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
        
        //Check for auto scroll is running when the user changed View Type(Extended to List)
        
        
        //Data always load from first position
        let index = self.focussedIndexPath
        
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

        
        if index.row < self.articlesArray.count && self.articlesArray.count > 1 {
            
            var newIndex = 0
            newIndex = isMoveNext ? index.row + 1 : index.row - 1
            newIndex = newIndex >= self.articlesArray.count ? 0 : newIndex
            let newIndexPath: IndexPath = IndexPath(item: newIndex, section: 0)
            
            UIView.animate(withDuration: 0.3) {
                
              //  self.tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .top)
                self.tableView.layoutIfNeeded()
                self.tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .top)
                //self.tableView.scrollToRow(at: newIndexPath, at: .top, animated: false)
                self.tableView.layoutIfNeeded()
                
            } completion: { (finished) in
                
                if let cell = self.tableView.cellForRow(at: newIndexPath) as? HomeCardCell {

                    let content = self.articlesArray[newIndexPath.row]
                    cell.setupSlideScrollView(article: content, isAudioPlay: true, row: newIndexPath.row, isMute: content.mute ?? true)

                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: 0)
                }
                else if let cell = self.tableView.cellForRow(at: newIndexPath) as? HomeListViewCC {

                    let content = self.articlesArray[newIndexPath.row]
                    cell.setupCellBulletsView(article: content, isAudioPlay: true, row: newIndexPath.row, isMute: content.mute ?? true)

                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: 0)
                }
                else if let vCell = self.tableView.cellForRow(at: newIndexPath) as? VideoPlayerVieww {
                    
                    vCell.videoControllerStatus(isHidden: true)
//                    vCell.playVideo(isPause: false)
                    self.playVideoOnFocus(cell: vCell, isPause: false)
                    
                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: 0)
                }
                else if let yCell = self.tableView.cellForRow(at: newIndexPath) as? YoutubeCardCell {
                    
                    self.curYoutubeVisibleCell = yCell
                    yCell.setFocussedYoutubeView()
                    
                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: 0)
                }
            }
        }
        else if self.articlesArray.count == 1 {
            
            //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
            self.setupIndexPathForSelectedArticleCardAndListView(0, section: 0)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    //--->
}


// MARK: - Comment Loike Delegates
extension ProfileArticlesVC: LikeCommentDelegate {
    
    func didTapCommentsButtonCollectionView(cell: UITableViewCell) {
    }
    
    func didTapLikeButtonCollectionView(cell: UITableViewCell) {
    }
    
    func didTapCommentsButton(cell: UITableViewCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        let content = self.articlesArray[indexPath.row]
        
        updateProgressbarStatus(isPause: true)
        
        let vc = CommentsVC.instantiate(fromAppStoryboard: .Home)
        vc.articleID = content.id ?? ""
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
        
        var content = self.articlesArray[indexPath.row]
        var likeCount = content.info?.likeCount
        if (content.info?.isLiked ?? false) {
            likeCount = (likeCount ?? 0) - 1
        } else {
            likeCount = (likeCount ?? 0) + 1
        }
        let info = Info(viewCount: content.info?.viewCount, likeCount: likeCount, commentCount: content.info?.commentCount, isLiked: !(content.info?.isLiked ?? false), socialLike: content.info?.socialLike)
        content.info = info
        self.articlesArray[indexPath.row].info = info
        
        (cell as? HomeListViewCC)?.setLikeComment(model: content.info)
        (cell as? HomeCardCell)?.setLikeComment(model: content.info)
        (cell as? YoutubeCardCell)?.setLikeComment(model: content.info)
        (cell as? VideoPlayerVieww)?.setLikeComment(model: content.info)
        performWSToLikePost(article_id: content.id ?? "", isLike: content.info?.isLiked ?? false)
        
        
    }
    
}


//MARK:- BottomSheetVC Delegate methods
extension ProfileArticlesVC: BottomSheetVCDelegate, SharingDelegate, UIDocumentInteractionControllerDelegate {
    
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
            self.performGoToSource(article)
            
        }
        else if sender.tag == 4 {
            
            //Follow Source
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

//extension ProfileArticlesVC: MainTopicSourceVCDelegate {
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
extension ProfileArticlesVC: UIScrollViewDelegate {
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
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
        
//        if let visibleRows = tblExtendedView.indexPathsForVisibleRows, let focusIdx = forceSelectedIndexPath {
//
//            if visibleRows.contains(focusIdx) {
//                print("not same focussed cell...")
//                updateProgressbarStatus(isPause: false)
//                return
//            }
//        }
        
        
        if var indexPath = indexPathVisible, indexPath != getIndexPathForSelectedArticleCardAndListView() {
            
            var index = indexPath.row
            
            //Reset cell
            self.resetCurrentFocussedCell()
            
            //For Skip header and footer cell
            if index < self.articlesArray.count && index != self.articlesArray.count - 1 {
                
                let content = self.articlesArray[index]
                if content.type == Constant.newsArticle.ARTICLE_TYPE_HEADER || content.type == Constant.newsArticle.ARTICLE_TYPE_FOOTER || content.type == Constant.newsArticle.ARTICLE_TYPE_ADS {
                    index += 1
                    indexPath = IndexPath(row: index, section: indexPath.section)
                }
            }
            
            //Set Selected index into focus variables
            focussedIndexPath = indexPath

            //set selected cell
            self.setSelectedCellAndPlay(index: index, indexPath: indexPath)
        }
        else {
            
            if let vCell = self.getCurrentFocussedCell() as? VideoPlayerVieww {
     
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
        self.setupIndexPathForSelectedArticleCardAndListView(index, section: 0)
        
        //ASSIGN CELL FOR CARD VIEW
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

//MARK;- EDIT ARTICLE BOTTOM SHEET
extension ProfileArticlesVC: BottomSheetArticlesVCDelegate {

    func dismissBottomSheetArticlesVCDelegateAction(type: Int, idx: Int) {
        
        if type == -1 {
            //When user only dismiss bottom sheet
            updateProgressbarStatus(isPause: false)
            return
        }
        
        let content = self.articlesArray[idx]
        if type == 0 {
            
            //edit
            let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
            if content.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                vc.postArticleType = .media
                vc.selectedMediaType = .video
            }
            else if content.type == Constant.newsArticle.ARTICLE_TYPE_IMAGE {
                vc.postArticleType = .media
                vc.selectedMediaType = .photo
            }
            else if content.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                vc.postArticleType = .youtube
            }
            vc.selectedChannel = self.channelInfo
            vc.isScheduleRequired = false
            vc.isEditable = true
            vc.yArticle = content
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        else if type == 1 {
            
            //delete
            self.performWSToArticleUnpublished(content.id ?? "")
        }
        
        else if type == 2 {
            
            //Save article
            performArticleArchive(content.id ?? "", isArchived: !self.article_archived)
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
}



extension ProfileArticlesVC: BulletDetailsVCLikeDelegate {
    
    func likeUpdated(articleID: String, isLiked: Bool, count: Int) {
        
        if let index = self.articlesArray.firstIndex(where: { $0.id == articleID }) {
            self.articlesArray[index].info?.isLiked = isLiked
            self.articlesArray[index].info?.likeCount = count
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            
            (cell as? HomeListViewCC)?.setLikeComment(model: self.articlesArray[index].info)
//            (cell as? HomeCardCell)?.setLikeComment(model: self.articlesArray[index].info)
            (cell as? YoutubeCardCell)?.setLikeComment(model: self.articlesArray[index].info)
            (cell as? VideoPlayerVieww)?.setLikeComment(model: self.articlesArray[index].info)
        }
    }
    
    func commentUpdated(articleID: String, count: Int) {
        
    }
    func backButtonPressed(isVideoPlaying: Bool) {
        
    }
}




// MARK: - Webservices
extension ProfileArticlesVC {
    
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
    
    func performWSToShare(article: articlesData, idx: Int, isOpenForNativeShare: Bool) {
        
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
                    self.sourceBlock = FULLResponse.source_blocked ?? false
                    self.sourceFollow = FULLResponse.source_followed ?? false
                    self.article_archived = FULLResponse.article_archived ?? false
                    
                    self.urlOfImageToShare = URL(string: article.link ?? "")
                    self.shareTitle = FULLResponse.share_message ?? ""
                    
                    self.updateProgressbarStatus(isPause: true)
                    if let media = FULLResponse.download_link {
                        
                        SharedManager.shared.instaMediaUrl = media
                    }
                    
                    if (self.isFromChannelView && (self.channelInfo?.own ?? false)) || (article.authors?.first?.id == SharedManager.shared.userId) {
                        
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
                            if article.authors?.first?.id == SharedManager.shared.userId {
                                vc.isSameAuthor = true
                            }
                            vc.isSameAuthor = true
                            vc.isMainScreen = false
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
                
                SharedManager.shared.logAPIError(url: "news/articles/\(article.id ?? "")/share/info", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    
    func performGoToSource(_ article: articlesData) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let id = article.source?.id ?? ""
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
                
                SharedManager.shared.logAPIError(url: "social/likes/article/\(article_id)", error: jsonerror.localizedDescription, code: "")
                self.isLikeApiRunning = false
                print("error parsing json objects",jsonerror)
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
                        
                        self.articlesArray.removeAll()
                        self.tableView.reloadData()
                        self.performWSToGetArticles(page: "")
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
        
        if sourceBlock == false {
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
    
}



extension ProfileArticlesVC: CommentsVCDelegate {
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
                
                if let selectedIndex = self.articlesArray.firstIndex(where: { $0.id == articleID }) {
//                    self.articles[selectedIndex].info = info
                    self.articlesArray[selectedIndex].info?.commentCount = info?.commentCount ?? 0
                    
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) {
                        (cell as? HomeListViewCC)?.setLikeComment(model: self.articlesArray[selectedIndex].info)
//                        (cell as? HomeCardCell)?.setLikeComment(model: self.articlesArray[selectedIndex].info)
                        (cell as? YoutubeCardCell)?.setLikeComment(model: self.articlesArray[selectedIndex].info)
                        (cell as? VideoPlayerVieww)?.setLikeComment(model: self.articlesArray[selectedIndex].info)
                    }
                    
                }
            }
        }
        
        
    }
    
}


//MARK:- CommunityGuideVC Delegate
extension ProfileArticlesVC: CommunityGuideVCDelegate {
    
    func dimissCommunityGuideApprovedDelegate() {
        
        SharedManager.shared.performWSToCommunityGuide()

        if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails), (user.setup ?? false) {
            
            let vc = UploadArticleBottomSheetVC.instantiate(fromAppStoryboard: .Schedule)
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
        else {
            
            let vc = PopupVC.instantiate(fromAppStoryboard: .Home)
            vc.isFromProfileView = true
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }

    }
}


//MARK:- UploadArticleBottomSheetVC Delegate
extension ProfileArticlesVC: UploadArticleBottomSheetVCDelegate {
    
    func UploadArticleSelectedTypeDelegate(type: Int) {
        
        if type == 0 {
            //Media
            print("Media")
            openMediaPicker(isForReels: false)
            
        }
        else if type == 1 {
            
            //Newsreels
            print("Newsreels")
            openMediaPicker(isForReels: true)
        }
        else {
            
            //Youtube
            print("Youtube")
            let vc = YoutubeArticleVC.instantiate(fromAppStoryboard: .Schedule)
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }

    }
}


extension ProfileArticlesVC: PopupVCDelegate {
    
    func popupVCDismissed() {

        let vc = EditProfileVC.instantiate(fromAppStoryboard: .Main)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}


// MARK : - Media Picker
extension ProfileArticlesVC: YPImagePickerDelegate {
    
    func noPhotos() {}

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true// indexPath.row != 2
    }
        
    func openMediaPicker(isForReels: Bool) {
        
        var config = YPImagePickerConfiguration()

        /* Uncomment and play around with the configuration 👨‍🔬 🚀 */

        /* Set this to true if you want to force the  library output to be a squared image. Defaults to false */
         config.library.onlySquare = true

        /* Set this to true if you want to force the camera output to be a squared image. Defaults to true */
        // config.onlySquareImagesFromCamera = false

        /* Ex: cappedTo:1024 will make sure images from the library or the camera will be
           resized to fit in a 1024x1024 box. Defaults to original image size. */
        // config.targetImageSize = .cappedTo(size: 1024)

        /* Choose what media types are available in the library. Defaults to `.photo` */
        config.library.mediaType = .photoAndVideo
        config.library.itemOverlayType = .grid
        
        config.libraryPhotoOnly.mediaType = .photo
        config.libraryPhotoOnly.itemOverlayType = .grid
        
        config.libraryVideoOnly.mediaType = .video
        config.libraryVideoOnly.itemOverlayType = .grid
        
        /* Enables selecting the front camera by default, useful for avatars. Defaults to false */
        // config.usesFrontCamera = true

        /* Adds a Filter step in the photo taking process. Defaults to true */
         config.showsPhotoFilters = false

        /* Manage filters by yourself */
        // config.filters = [YPFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        //                   YPFilter(name: "Normal", coreImageFilterName: "")]
        // config.filters.remove(at: 1)
        // config.filters.insert(YPFilter(name: "Blur", coreImageFilterName: "CIBoxBlur"), at: 1)

        /* Enables you to opt out from saving new (or old but filtered) images to the
           user's photo library. Defaults to true. */
        config.shouldSaveNewPicturesToAlbum = false

        /* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
        config.video.compression = AVAssetExportPresetPassthrough

        /* Choose the recordingSizeLimit. If not setted, then limit is by time. */
        // config.video.recordingSizeLimit = 10000000

        /* Defines the name of the album when saving pictures in the user's photo library.
           In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
         config.albumName = ApplicationAlertMessages.kAppName

        /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
           Default value is `.photo` */
        config.startOnScreen = .library

        /* Defines which screens are shown at launch, and their order.
           Default value is `[.library, .photo]` */
        if isForReels {
            config.screens = [.libraryVideoOnly]
        } else {
            config.screens = [.library, .libraryPhotoOnly, .libraryVideoOnly]
        }
        

        /* Can forbid the items with very big height with this property */
        // config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* Defines the time limit for recording videos.
           Default is 30 seconds. */
        // config.video.recordingTimeLimit = 5.0

        /* Defines the time limit for videos from the library.
           Defaults to 60 seconds. */
        config.video.libraryTimeLimit = 14400

        config.video.libraryTimeLimit = 14400

        config.video.minimumTimeLimit = 1
        
        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .none//.rectangle(ratio: (16/9))

        /* Defines the overlay view for the camera. Defaults to UIView(). */
        // let overlayView = UIView()
        // overlayView.backgroundColor = .red
        // overlayView.alpha = 0.3
        // config.overlayView = overlayView

        /* Customize wordings */
//        config.wordings.libraryTitle = "Gallery"
//        config.wordings.libraryPhotoTitle = "Photos"
//        config.wordings.libraryVideoTitle = "Videos"
        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = 1
        config.libraryPhotoOnly.maxNumberOfItems = 1
        config.libraryVideoOnly.maxNumberOfItems = 1
        config.gallery.hidesRemoveButton = false

        /* Disable scroll to change between mode */
        // config.isScrollToChangeModesEnabled = false
        // config.library.minNumberOfItems = 2

        /* Skip selection gallery after multiple selections */
        // config.library.skipSelectionsGallery = true

        /* Here we use a per picker configuration. Configuration is always shared.
           That means than when you create one picker with configuration, than you can create other picker with just
           let picker = YPImagePicker() and the configuration will be the same as the first picker. */

        /* Only show library pictures from the last 3 days */
        //let threDaysTimeInterval: TimeInterval = 3 * 60 * 60 * 24
        //let fromDate = Date().addingTimeInterval(-threDaysTimeInterval)
        //let toDate = Date()
        //let options = PHFetchOptions()
        // options.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", fromDate as CVarArg, toDate as CVarArg)
        //
        ////Just a way to set order
        //let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        //options.sortDescriptors = [sortDescriptor]
        //
        //config.library.options = options

//        config.library.preselectedItems = selectedItems
//        config.libraryPhotoOnly.preselectedItems = selectedItems
//        config.libraryVideoOnly.preselectedItems = selectedItems

        // Customise fonts
        //config.fonts.menuItemFont = UIFont.systemFont(ofSize: 22.0, weight: .semibold)
        //config.fonts.pickerTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .black)
        //config.fonts.rightBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        //config.fonts.navigationBarTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        //config.fonts.leftBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)

        
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

//            self.selectedItems = items
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
                        vc.selectedChannel = self!.channelInfo
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
                        vc.selectedChannel = self!.channelInfo
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

        /* Single Photo implementation. */
        // picker.didFinishPicking { [unowned picker] items, _ in
        //     self.selectedItems = items
        //     self.selectedImageV.image = items.singlePhoto?.image
        //     picker.dismiss(animated: true, completion: nil)
        // }

        /* Single Video implementation. */
        //picker.didFinishPicking { [unowned picker] items, cancelled in
        //    if cancelled { picker.dismiss(animated: true, completion: nil); return }
        //
        //    self.selectedItems = items
        //    self.selectedImageV.image = items.singleVideo?.thumbnail
        //
        //    let assetURL = items.singleVideo!.url
        //    let playerVC = AVPlayerViewController()
        //    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
        //    playerVC.player = player
        //
        //    picker.dismiss(animated: true, completion: { [weak self] in
        //        self?.present(playerVC, animated: true, completion: nil)
        //        print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
        //    })
        //}

        present(picker, animated: true, completion: nil)
    }
}

extension ProfileArticlesVC: YoutubeArticleVCDelegate {
    
    func submitYoutubeArticlePost(_ article: articlesData) {
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(false, animated: true)
        }
        
        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
        vc.yArticle = article
        vc.selectedChannel = self.channelInfo
        vc.postArticleType = .youtube
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- ScrollView Delegate
extension ProfileArticlesVC: AquamanChildViewController {

    func aquamanChildScrollView() -> UIScrollView {
        return tableView
    }
}



// MARK: - Ads
// Google Ads
extension ProfileArticlesVC: GADUnifiedNativeAdLoaderDelegate {
    
    
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
        }
        
        
    }
    
}

// Facebook Ads
extension ProfileArticlesVC: FBNativeAdDelegate {
    
    
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


extension ProfileArticlesVC: BulletDetailsVCDelegate {
    
    func dismissBulletDetailsVC(selectedArticle: articlesData?) {
        tableView.reloadData()
    }
}

extension ProfileArticlesVC {
    
    
    // MARK : - Search Methods
    func refreshVC() {
        
        seachNoDataView.isHidden = true
        searchText = ""
        hideCustomLoader(isAnimated: false)
        hideLoaderVC()
        nextPageData = ""
        articlesArray.removeAll()
        self.tableView.reloadData()

    }
    
    func getSearchContent(search: String) {
        
        refreshVC()
        searchText = search
        self.performWSToGetArticles(page: "")

    }
    
    
    func appEnteredBackground() {
        
        //            relevantVC?.appEnteredBackground()

        
    }
    
    
    func appLoadedToForeground() {
        //            relevantVC?.appLoadedToForeground()
    }
    
    func stopAll() {
        
        //        self.relevantVC?.updateProgressbarStatus(isPause: true)

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


