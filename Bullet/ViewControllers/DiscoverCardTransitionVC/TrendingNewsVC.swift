//
//  TrendingNewsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 08/07/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FBAudienceNetwork
import SkeletonView
import ImageSlideshow

protocol TrendingNewsVCDelegate: AnyObject {
    func trendingNewsVCDismissButtonPressed()
}

class TrendingNewsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    var selectedArticleData: articlesData?
    var isApiCallAlreadyRunning = false
    var articlesArray = [articlesData]()
    var nextPageData = ""
    var channelInfo: ChannelInfo?
    
    // HomeVC variables
    private var generator = UIImpactFeedbackGenerator()
    var focussedIndexPath = IndexPath(row: 0, section: 0)
    var forceSelectedIndexPath: IndexPath?
    var curVideoVisibleCell: VideoPlayerView?
    var curYoutubeVisibleCell: YoutubeCardCell?
    
    var sourceBlock = false
    var sourceFollow = false
    var article_archived = false
    var urlOfImageToShare: URL?
    var shareTitle = ""
    var isLikeApiRunning = false
    var lastContentOffset: CGFloat = 0
    private var prefetchState: PrefetchState = .idle
    var isViewPresenting: Bool = false
//    weak var delegate: TrendingNewsVCLikeDelegate?
//    weak var delegateVC: TrendingNewsVCDelegate?
    
    var isNestedVC = false
    var cellHeights = [IndexPath: CGFloat]()
    var isFromPostArticle = false
    let pagingLoader = UIActivityIndicatorView()
    
    var adLoader: GADAdLoader? = nil
    var fbnNativeAd: FBNativeAd? = nil
    var googleNativeAd: GADUnifiedNativeAd?
    
    var contextId: String = ""
    var titleString = ""
    var subTitleString = ""
    var cardHeroId = ""
    var pagingLoaderAdded = false
    weak var delegate: TrendingNewsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        self.hero.isEnabled = true
        
        registerCells()
        
//        view.hero.id = cardHeroId
//        lblTitle.hero.id = "lblTitle" + cardHeroId
//        lblSubTitle.hero.id = "lblSubTitle" + cardHeroId
        
        
        lblTitle.text = titleString
        lblSubTitle.text = subTitleString
        
        self.lblTitle.theme_textColor = GlobalPicker.textSubColorDiscover
        self.lblSubTitle.theme_textColor = GlobalPicker.textBWColorDiscover
        
//        self.view.theme_backgroundColor = GlobalPicker.backgroundColorHomeCell
        self.view.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 250
        tableView.delegate = self
        tableView.dataSource = self
        
        performWSToGetArticles(page: "")
        
        self.btnClose.theme_setImage(GlobalPicker.imgCloseDiscoverList, forState: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        isViewPresenting = true
        
        print("tblExtendedView.reloadData 1")
        if articlesArray.count > 0 {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.reloadData()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            //tell us if first article youtube then will force to call scrollToTopVisibleExtended for play article
            if tableView.contentOffset == .zero, tableView.numberOfRows(inSection: 0) > 0 {
                if let type = self.articlesArray.first?.type, type == ARTICLE_TYPE_YOUTUBE {
                    self.scrollToTopVisibleExtended()
                }
                if let type = self.articlesArray.first?.type, type == ARTICLE_TYPE_VIDEO {
                    self.scrollToTopVisibleExtended()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
            fetchAds()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isViewPresenting = false
        //        SharedManager.shared.isViewArticleSourceNotification = false
        updateProgressbarStatus(isPause: true)
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
        
        tableView.register(UINib(nibName: "HomeSkeltonCardCell", bundle: nil), forCellReuseIdentifier: "HomeSkeltonCardCell")
        tableView.register(UINib(nibName: "HomeSkeltonListCell", bundle: nil), forCellReuseIdentifier: "HomeSkeltonListCell")
        
        
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
    
    func showLoader() {
        
        if self.tableView.isSkeletonActive {
            // Skeleton already present
            return
        }
        DispatchQueue.main.async {
            
            let animation = GradientDirection.leftRight.slidingAnimation()
                //        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftToRight)
            self.tableView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient.init(baseColor: MyThemes.current == .light ? GlobalPicker.skeletonColorLightMode : GlobalPicker.skeletonColorDarkMode), animation: animation, transition: .crossDissolve(0.25))
//            self.tblExtendedView.showSkeleton()
        }
    }
    
    
    
    @IBAction func didTapClose(_ sender: Any) {
        
        updateProgressbarStatus(isPause: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.isViewPresenting == false {
                SharedManager.shared.bulletPlayer?.pause()
                SharedManager.shared.spbCardView?.isPaused = true
            }
        }
        self.delegate?.trendingNewsVCDismissButtonPressed()
        self.dismiss(animated: true) {
            SharedManager.shared.bulletPlayer?.pause()
            SharedManager.shared.spbCardView?.isPaused = true
        }
    }
    
    
}



extension TrendingNewsVC: UITableViewDelegate, UITableViewDataSource, SkeletonTableViewDataSource {
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        
        if indexPath.row == 0 {
            return "HomeSkeltonCardCell"
        }
        return "HomeSkeltonListCell"
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articlesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let content = self.articlesArray[indexPath.row]
        //LOCAL VIDEO TYPE
        if content.type ?? "" == ARTICLE_TYPE_VIDEO {

            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            let videoPlayer = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER, for: indexPath) as! VideoPlayerView
         //   videoPlayer.delegateVideoView = self
            
            videoPlayer.viewDividerLine.isHidden = true
            videoPlayer.constraintContainerViewBottom.constant = 10
            
            // Set like comment
            videoPlayer.setLikeComment(model: content.info)
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
                videoPlayer.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
                videoPlayer.lblSource.text = source.name ?? ""
            }
            else {
                
                let url = content.authors?.first?.image ?? ""
                videoPlayer.imgWifi?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
                videoPlayer.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            }
            videoPlayer.lblSource.addTextSpacing(spacing: 2.5)

            videoPlayer.btnShare.tag = indexPath.row
            videoPlayer.btnShare.accessibilityIdentifier = "\(indexPath.section)"
            videoPlayer.btnSource.tag = indexPath.row
            videoPlayer.btnSource.accessibilityIdentifier = "\(indexPath.section)"
            videoPlayer.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
            videoPlayer.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            
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
        
        else if content.type ?? "" == ARTICLE_TYPE_ADS {
            
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
        else if content.type?.uppercased() == ARTICLE_TYPE_YOUTUBE {
            
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
            //youtubeCell.lblTime.addTextSpacing(spacing: 1.25)
            
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
            
            if content.type ?? "" == ARTICLE_TYPE_SIMPLE {
                
                //LIST VIEW DESIGN CELL- SMALL CELL
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW, for: indexPath) as? HomeListViewCC else { return UITableViewCell() }
                
                cell.viewDividerLine.isHidden = true
                cell.constraintContainerViewBottom.constant = 10
                
                // Set like comment
                cell.setLikeComment(model: content.info)
                
                cell.backgroundColor = UIColor.clear
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                cell.selectionStyle = .none
                cell.delegateHomeListCC = self
                cell.delegateLikeComment = self
                
                let url = content.image ?? ""
                cell.imageURL = url
                
                cell.lblSource.theme_textColor = GlobalPicker.textSourceColor
//                cell.lblSource.addTextSpacing(spacing: 1.25)
                if let source = content.source {
                    
                    cell.lblSource.text = source.name?.capitalized
                }
                else {
                    
                    cell.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
                }
                
                let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
                let source = content.source?.name ?? ""
                
                cell.viewDot.clipsToBounds = false
                if author == source || author == "" {
                    cell.lblAuthor.isHidden = true
                    cell.viewDot.isHidden = true
                    cell.viewDot.clipsToBounds = true
                    cell.lblSource.text = source
                }
                else {
                    cell.lblSource.text = source
                    cell.lblAuthor.text = author
                    
                    if source == "" {
                        cell.lblAuthor.isHidden = true
                        cell.viewDot.isHidden = true
                        cell.viewDot.clipsToBounds = true
                        cell.lblSource.text = author
                    }
                    else if author != "" {
                        cell.lblAuthor.isHidden = false
                        cell.viewDot.isHidden = false
                    }
                }
                
                cell.langCode = content.language ?? ""
                if let pubDate = content.publish_time {
                    cell.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                }
//                cell.lblTime.addTextSpacing(spacing: 1.25)
                
                cell.btnShare.tag = indexPath.row
                cell.btnShare.accessibilityIdentifier = "\(indexPath.section)"
                cell.btnSource.tag = indexPath.row
                cell.btnSource.accessibilityIdentifier = "\(indexPath.section)"
                cell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
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
                cell.viewLikeCommentBG.theme_backgroundColor = GlobalPicker.textWBColor

                return cell
            }
            else {
                
                //CARD VIEW DESIGN CELL- LARGE CELL
                guard let cardCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_CARD, for: indexPath) as? HomeCardCell else { return UITableViewCell() }
                
                cardCell.viewDividerLine.isHidden = true
                cardCell.constraintContainerViewBottom.constant = 10
                
                // Set like comment
                cardCell.setLikeComment(model: content.info)
                
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

                cardCell.btnShare.tag = indexPath.row
                cardCell.btnShare.accessibilityIdentifier = "\(indexPath.section)"
                cardCell.btnSource.tag = indexPath.row
                cardCell.btnSource.accessibilityIdentifier = "\(indexPath.section)"
                cardCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
                cardCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
                

                if let source = content.source {
                    
                    let sourceURL = source.icon ?? ""
                    cardCell.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
                    cardCell.lblSource.text = source.name ?? ""
//                    cardCell.lblSource.addTextSpacing(spacing: 2.5)
                }
                else {
                    
                    let url = content.authors?.first?.image ?? ""
                    cardCell.imgWifi?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
                    cardCell.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
//                    cardCell.lblSource.addTextSpacing(spacing: 2.5)
                }
                
                let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
                let source = content.source?.name ?? ""
                
                cardCell.viewSingleDot.clipsToBounds = false
                if author == source || author == "" {
                    cardCell.lblAuthor.isHidden = true
                    cardCell.viewSingleDot.clipsToBounds = true
                    cardCell.viewSingleDot.isHidden = true
                    cardCell.lblSource.text = source
                }
                else {
                    
                    cardCell.lblSource.text = source
                    cardCell.lblAuthor.text = author
                    
                    if source == "" {
                        cardCell.lblAuthor.isHidden = true
                        cardCell.viewSingleDot.clipsToBounds = true
                        cardCell.viewSingleDot.isHidden = true
                        cardCell.lblSource.text = author
                    }
                    else if author != "" {
                        cardCell.lblAuthor.isHidden = false
                        cardCell.viewSingleDot.isHidden = false
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
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //print("indexPath:...", indexPath.row)
        if let cell = cell as? VideoPlayerView {
            resetPlayerAtIndex(cell: cell)
        }
        else if let cell = cell as? YoutubeCardCell {
            cell.resetYoutubeCard()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.articlesArray.count > 0 && indexPath.row < self.articlesArray.count {
            
            let content = self.articlesArray[indexPath.row]
            if content.type ?? "" == ARTICLE_TYPE_ADS {
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
        header.lblTitle.text = NSLocalizedString("Related Articles", comment: "")
        header.lblTitle.theme_textColor = GlobalPicker.textBWColor
        return header
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        
        return CGFloat.leastNormalMagnitude
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return CGFloat.leastNormalMagnitude
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == articlesArray.count - 1 {  //numberofitem count
            if nextPageData.isEmpty == false {
                
                if pagingLoaderAdded == false {
                    addPagingLoader()
                }
                pagingLoader.startAnimating()
                self.pagingLoader.hidesWhenStopped = true
                performWSToGetArticles(page: nextPageData)
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
        
        
        pagingLoaderAdded = true
        
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
    @objc func swipeViewList(_ sender: UISwipeGestureRecognizer) {
        
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
            
            cell.btnReport.isHidden = cell.currPage == 0 ? false : true
        }
        
        let row = sender.view?.tag ?? 0
        if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? HomeListViewCC {
            
            // For selected item , currently playing cell
            if row == focussedIndexPath.row {

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
            
            cell.btnReport.isHidden = cell.currMutedPage == 0 ? false : true
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
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articlesArray[focussedIndexPath.row].id ?? "")
                    //LEFT
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
                            SharedManager.shared.spbCardView?.rewind()
                        }
                        else {
                            
                            cell.restartProgressbar()
                        }
                    }
                    else {
                        
                        if focussedIndexPath.row > 0 {
                            
                            SharedManager.shared.bulletsMaxCount = 0
                            cell.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: false)
                        }
                        else {
                            cell.restartProgressbar()
                        }
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
                        SharedManager.shared.spbCardView?.skip()
                    }
                    else {
                        
                        //self.restartProgressbar()
                        SharedManager.shared.bulletsMaxCount = 0
                        cell.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
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
    
    @objc func didTapScrollLeftRightCard(_ sender: UIButton) {
        
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
                            cell.btnReport.isHidden = cell.currPage == 0 ? false : true
                            SharedManager.shared.segementIndex = cell.currPage
                            cell.scrollToItemBullet(at: cell.currPage, animated: true)
                            cell.playAudio()
                            SharedManager.shared.spbCardView?.rewind()
                        }
                        else {
                            
                            cell.restartProgressbar()
                        }
                    }
                    else {
                        if focussedIndexPath.row > 0 {
                            cell.delegateHomeListCC?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: false)
                        }
                        else {
                            cell.restartProgressbar()
                        }
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
                        cell.btnReport.isHidden = cell.currPage > 0 ? true : false
                        SharedManager.shared.segementIndex = cell.currPage
                        cell.scrollToItemBullet(at: cell.currPage, animated: true)
                        cell.playAudio()
                        SharedManager.shared.spbCardView?.skip()
                    }
                    else {
                        
                        //self.restartProgressbar()
                        cell.delegateHomeListCC?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
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
//                        cell.btnReport.isHidden = cell.currMutedPage == 0 ? false : true
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
//                        cell.btnReport.isHidden = cell.currMutedPage > 0 ? true : false
//                        cell.scrollToItemBullet(at: cell.currMutedPage, animated: true)
                        cell.swipeLeftUserSelectedCell()
                    }
                    //cell.animateImageView(isFromRight: true)
                }
            }
        }
    }
}

// MARK: - Webservices
extension TrendingNewsVC {
    
    func performWSToGetArticles(page: String) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: ApplicationAlertMessages.kMsgInternetNotAvailable)
            return
        }
        

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        isApiCallAlreadyRunning = true
        
        if page == "" {
            prefetchState = .fetching
        }
        
        
        var querySt = ""
        querySt = "news/articles?context=\(contextId)&page=\(page)&reader_mode=\(SharedManager.shared.readerMode)"
        
        if self.articlesArray.count == 0 {
            showLoader()
        }
        
        WebService.URLResponse(querySt, method: .get, parameters: nil, headers: token, withSuccess: { [weak self] (response) in
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
                        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
                            //LOAD ADS
                            self.articlesArray.removeAll{ $0.type == ARTICLE_TYPE_ADS }
                            self.articlesArray = self.articlesArray.adding(articlesData(id: "", title: "", image: "", link: "", color: "", publish_time: "", source: nil, bullets: nil, topics: nil, status: "", type: ARTICLE_TYPE_ADS), afterEvery: SharedManager.shared.adsInterval)
                        }
                        
                        DispatchQueue.main.async {
                            if self.tableView.isSkeletonActive {
                                self.tableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.5))
                                if let type = self.articlesArray.first?.type, type == ARTICLE_TYPE_YOUTUBE, self.isViewPresenting {
                                    self.scrollToTopVisibleExtended()
                                }
                            } else {
                                UIView.performWithoutAnimation {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        
                        
                    } else {
                        self.articlesArray = self.articlesArray + articlesDataObj
                        
                        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
                            //LOAD ADS
                            self.articlesArray.removeAll{ $0.type == ARTICLE_TYPE_ADS }
                            self.articlesArray = self.articlesArray.adding(articlesData(id: "", title: "", image: "", link: "", color: "", publish_time: "", source: nil, bullets: nil, topics: nil, status: "", type: ARTICLE_TYPE_ADS), afterEvery: SharedManager.shared.adsInterval)
                        }
                        
                        DispatchQueue.main.async {
                            if self.tableView.isSkeletonActive {
                                self.tableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.5))
                            } else {
                                UIView.performWithoutAnimation {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                    
                } else {
                    
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
                self.isApiCallAlreadyRunning = false
                self.prefetchState = .idle
                DispatchQueue.main.async {
                    if self.tableView.isSkeletonActive {
                        self.tableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.5))
                    } else {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadData()
                        }
                    }
                }
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/articles/\(self.selectedArticleData?.id ?? "")/related", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            self.prefetchState = .idle
            self.isApiCallAlreadyRunning = false
            DispatchQueue.main.async {
                if self.tableView.isSkeletonActive {
                    self.tableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.5))
                } else {
                    UIView.performWithoutAnimation {
                        self.tableView.reloadData()
                    }
                }
            }
            self.pagingLoader.stopAnimating()
            self.pagingLoader.hidesWhenStopped = true
            print("error parsing json objects",error)
        }
    }
    
    func performWSToShare(article: articlesData, idx: Int) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: ApplicationAlertMessages.kMsgInternetNotAvailable)
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
                    if let media = FULLResponse.media {
                        
                        SharedManager.shared.instaMediaUrl = media
                    }
                    
                    self.updateProgressbarStatus(isPause: true)
                    
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
//                        let vc = BottomSheetArticlesVC.instantiate(fromAppStoryboard: .Main)
//                        vc.article_archived = self.article_archived
//                        vc.article = article
//                        vc.index = idx
//                        vc.share_message = FULLResponse.share_message ?? ""
//                        vc.delegate = self
//                        vc.modalPresentationStyle = .overFullScreen
//                        self.present(vc, animated: true)
                    }
                    else {
                        
//                        let vc = BottomSheetVC.instantiate(fromAppStoryboard: .registration)
//                        vc.delegateBottomSheet = self
//                        vc.article = article
//                        vc.isMainScreen = true
//                        vc.sourceBlock = self.sourceBlock
//                        vc.sourceFollow = self.sourceFollow
//                        vc.article_archived = self.article_archived
//                        vc.share_message = FULLResponse.share_message ?? ""
//                        vc.modalPresentationStyle = .overFullScreen
//                        self.present(vc, animated: true, completion: nil)
                        
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
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/articles/\(article.id ?? "")/share/info", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performArticleArchive(_ id: String, isArchived: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: ApplicationAlertMessages.kMsgInternetNotAvailable)
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
                        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                        if var topController = keyWindow?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                            }
                            topController.view.makeToast(isArchived ? ApplicationAlertMessages.kMsgAddToFavorite : ApplicationAlertMessages.kMsRemoveFromFavorite, duration: 2.0, position: .bottom)
                        }
                        
                        
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
    
    func performGoToSource(_ article: articlesData) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: ApplicationAlertMessages.kMsgInternetNotAvailable)
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
//                        self.navigationController?.pushViewController(detailsVC, animated: true)
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
            
            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: ApplicationAlertMessages.kMsgInternetNotAvailable)
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
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: ApplicationAlertMessages.kMsgInternetNotAvailable)
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
                    SharedManager.shared.isTabReload = true
                    
                    if status == Constant.STATUS_SUCCESS {
                        
                        UIApplication.shared.keyWindow?.makeToast("Blocked \(sourceName)", duration: 2.0, position: .bottom)
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
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: ApplicationAlertMessages.kMsgInternetNotAvailable)
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
                
                //self.updateProgressbarStatus(isPause: false)
                if FULLResponse.message == "Success" {
                    
                    if self.sourceBlock {
                        UIApplication.shared.keyWindow?.makeToast("Unblocked \(name)", duration: 2.0, position: .bottom)
                    }
                    else {
                        UIApplication.shared.keyWindow?.makeToast("Blocked \(name)", duration: 2.0, position: .bottom)
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
    
    func performWSToFollowSource(_ id: String, name:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: ApplicationAlertMessages.kMsgInternetNotAvailable)
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
                
                SharedManager.shared.isTabReload = true
                SharedManager.shared.isFav = true
                NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
                self.updateProgressbarStatus(isPause: false)
                if FULLResponse.message == "Success" {
                    
                    UIApplication.shared.keyWindow?.makeToast("Followed \(name)", duration: 2.0, position: .bottom)
                }
                
            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/sources/follow", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performUnFollowUserSource(_ id: String, name:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: ApplicationAlertMessages.kMsgInternetNotAvailable)
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
                        
                        SharedManager.shared.isTabReload = true
                        SharedManager.shared.isFav = false
                        NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
                        
                        UIApplication.shared.keyWindow?.makeToast("Unfollowed \(name)", duration: 2.0, position: .bottom)
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/sources/unfollow", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUnblockSource(_ id: String, name:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: ApplicationAlertMessages.kMsgInternetNotAvailable)
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
                SharedManager.shared.isTabReload = true
                if FULLResponse.message == "Success" {
                    
                    UIApplication.shared.keyWindow?.makeToast("Unblocked \(name)", duration: 2.0, position: .bottom)
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
            
            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: ApplicationAlertMessages.kMsgInternetNotAvailable)
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
                            
                            UIApplication.shared.keyWindow?.makeToast("You'll see more stories like this", duration: 2.0, position: .bottom)
                        }
                        else {
                            
                            UIApplication.shared.keyWindow?.makeToast("You'll see less stories like this", duration: 2.0, position: .bottom)
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
extension TrendingNewsVC {
    
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
            
            if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? HomeCardCell {
                
                cell.pauseAudioAndProgress(isPause:true)
                
            }
            else if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? HomeListViewCC {
                
                cell.pauseAudioAndProgress(isPause:true)
                
            }
            else if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? VideoPlayerView {
                
//                cell.playVideo(isPause: true)
                self.playVideoOnFocus(cell: cell, isPause: true)

                
            }
        }
        else {
            
            if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? HomeCardCell {
                
                cell.pauseAudioAndProgress(isPause:false)
            }
            else if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? HomeListViewCC {
                
                cell.pauseAudioAndProgress(isPause:false)
            }
            else if let cell = self.tableView.cellForRow(at: self.focussedIndexPath) as? VideoPlayerView {
                
//                cell.playVideo(isPause: false)
                self.playVideoOnFocus(cell: cell, isPause: false)

                
            }
            
        }
    }
    
}

//MARK:- HomeCardCell Delegate methods
extension TrendingNewsVC: HomeCardCellDelegate, YoutubeCardCellDelegate, videoPlayerViewDelegates, FullScreenVideoVCDelegate {
    
    func backButtonPressed(cell: HomeDetailCardCell?) {}
    func backButtonPressed(cell: GenericVideoCell?) {}
    func backButtonPressed(cell: VideoPlayerView?) {
        
//        cell?.playVideo(isPause: false)
        if let cell = cell {
            self.playVideoOnFocus(cell: cell, isPause: false)
        }
    }
    
    func playVideoOnFocus(cell: VideoPlayerView, isPause: Bool) {
        
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
                let status = articlesArray[indexPath.row].status
                if status != ARTICLE_STATUS_SCHEDULED && status != ARTICLE_STATUS_PROCESSING {
                    didTapVideoPlayButton(cell: cell, isTappedFromCell: false)
                }
            }
            
        }
    }
    
    func resetPlayerAtIndex(cell: VideoPlayerView) {
        
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
    
    func didTapVideoPlayButton(cell: VideoPlayerView, isTappedFromCell: Bool) {
        
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
            "fullScreenMode": EZPlayerFullScreenMode.portrait
        ] as [String : Any]
        
        MediaManager.sharedInstance.playEmbeddedVideo(url: url, embeddedContentView: cell.imgPlaceHolder, userinfo: videoInfo, viewController: self)
        MediaManager.sharedInstance.player?.indexPath = indexPath
        MediaManager.sharedInstance.player?.scrollView = tableView
        
    }
    
    func didSelectFullScreenVideo(cell: VideoPlayerView) {
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
            vc.videoPlayerView = cell
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }
        */
    }
    
    func didSelectCell(cell: VideoPlayerView) {
        
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
        
        if self.articlesArray.count > 0 {
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
    
    
    @objc func didTapShare(button: UIButton) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.shareClick, eventDescription: "")

        self.updateProgressbarStatus(isPause: true)
        let index = button.tag
        let content = self.articlesArray[index]
        performWSToShare(article: content, idx: index)
        
    }
    
    @objc func didTapSource(button: UIButton) {
        
        //EXTENDED VIEW TAP TO OPEN SOURCE
        let index = button.tag
        
        let content = self.articlesArray[index]

        if let _ = content.source {
            
            //EXTENDED VIEW TAP TO OPEN SOURCE
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
            
            self.updateProgressbarStatus(isPause: true)
            button.isUserInteractionEnabled = false
            self.performGoToSource(content)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                button.isUserInteractionEnabled = true
            }
        }
        else {
            self.updateProgressbarStatus(isPause: true)

            let authors = content.authors
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
        
        //Check for auto scroll is running when the user changed View Type(Extended to List)
        SharedManager.shared.bulletsMaxCount = 0
        
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

        
        if index.row < self.articlesArray.count && self.articlesArray.count > 1 {
            
            var newIndex = 0
            newIndex = isMoveNext ? index.row + 1 : index.row - 1
            newIndex = newIndex >= self.articlesArray.count ? 0 : newIndex
            let newIndexPath: IndexPath = IndexPath(item: newIndex, section: 0)
            
            UIView.animate(withDuration: 0.3) {
                
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
                else if let vCell = self.tableView.cellForRow(at: newIndexPath) as? VideoPlayerView {
                    
                    vCell.videoControllerStatus(isHidden: true)
//                    vCell.playVideo(isPause: false)
                    self.playVideoOnFocus(cell: vCell, isPause: false)

                    
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
extension TrendingNewsVC: LikeCommentDelegate {
    
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
        let info = Info(viewCount: content.info?.viewCount, likeCount: likeCount, commentCount: content.info?.commentCount, isLiked: !(content.info?.isLiked ?? false))
        content.info = info
        self.articlesArray[indexPath.row].info = info
        
        (cell as? HomeListViewCC)?.setLikeComment(model: content.info)
        (cell as? HomeCardCell)?.setLikeComment(model: content.info)
        (cell as? YoutubeCardCell)?.setLikeComment(model: content.info)
        (cell as? VideoPlayerView)?.setLikeComment(model: content.info)
        (cell as? HomeDetailCardCell)?.setLikeComment(model: content.info)
        performWSToLikePost(article_id: content.id ?? "", isLike: content.info?.isLiked ?? false)
        
    }
    
}


//MARK:- BottomSheetVC Delegate methods
extension TrendingNewsVC: BottomSheetVCDelegate {
    
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
            if let _ = article.source {
                self.performGoToSource(article)
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
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.lessLikeThisClick, eventDescription: "")
            self.performWSuggestMoreOrLess(article.id ?? "", isMoreOrLess: false)
        }
    }
}

//extension TrendingNewsVC: MainTopicSourceVCDelegate {
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
//        else if let cell = self.getCurrentFocussedCell() as? VideoPlayerView {
//            cell.playVideo(isPause: false)
//        }
//    }
//}


//MARK:- SCROLL VIEW DELEGATE
extension TrendingNewsVC: UIScrollViewDelegate {
        
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
        
//        if indexPathVisible == 0 {
//            // Skip
//            return
//        }
        if let indexPath = indexPathVisible, indexPath != getIndexPathForSelectedArticleCardAndListView() {
            
            //Reset Cells
            resetCurrentFocussedCell()
            
            //set index
            self.setupIndexPathForSelectedArticleCardAndListView(indexPath.row, section: indexPath.section)

            //ASSIGN CELL FOR CARD VIEW
            setSelectedCellAndPlay(index: indexPath.row, indexPath: indexPath)
        }
        else {
            
            //Reset Home Card View
//            if let cell = self.getCurrentFocussedCell() as? HomeDetailCardCell {
//                if cell.viewYoutubeArticle.isHidden == false {
//                    cell.videoPlayer.pause()
//                    cell.resetYoutubeCard()
//                }
//                else if cell.viewVideoArticle.isHidden == false {
//                    cell.player.pause()
//                    resetPlayerAtIndex(cell: cell)
//                }
//            }
            if let videoCell = self.getCurrentFocussedCell() as? VideoPlayerView {

                playVideoOnFocus(cell: videoCell, isPause: false)
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
        if let vCell = self.getCurrentFocussedCell() as? VideoPlayerView {
            resetPlayerAtIndex(cell: vCell)
        }
    }
    
    private func setSelectedCellAndPlay(index: Int, indexPath: IndexPath) {
        
        self.setupIndexPathForSelectedArticleCardAndListView(indexPath.row, section: indexPath.section)
        
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
        else if let vCell = tableView.cellForRow(at: indexPath) as? VideoPlayerView {
            
            self.curVideoVisibleCell = vCell
            
//            vCell.playVideo(isPause: false)
            self.playVideoOnFocus(cell: vCell, isPause: false)

        }

    }
}


extension TrendingNewsVC: CustomBulletsCCDelegate {

    func didTapViewFullArticle(cell: CustomBulletsCC) {
//        let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
//        //vc.delegateVC = self
//        vc.webURL = self.selectedArticleData?.link ?? ""
//        vc.titleWeb = self.selectedArticleData?.source?.name ?? ""
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true, completion: nil)
        
        SharedManager.shared.openWebPageViewController(parentVC: self, pageUrlString: self.selectedArticleData?.original_link ?? "", isPresenting: true)
    }
}

//extension TrendingNewsVC: webViewVCDelegate {
//
//    func dismissWebViewVC() {
//        if let cell = self.getCurrentFocussedCell() as? HomeCardCell {
//            cell.restartProgressbar()
//        }
//        else if let cell = self.getCurrentFocussedCell() as? HomeListViewCC {
//            cell.restartProgressbar()
//        }
//        else if let cell = self.getCurrentFocussedCell() as? VideoPlayerView {
//            cell.playVideo(isPause: false)
//        }
//    }
//
//}

//MARK:- POST ARTICLE BOTTOM SHEET
extension TrendingNewsVC: BottomSheetArticlesVCDelegate {

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
            if content?.type == ARTICLE_TYPE_VIDEO {
                vc.postArticleType = .media
                vc.selectedMediaType = .video
            }
            else if content?.type == ARTICLE_TYPE_IMAGE {
                vc.postArticleType = .media
                vc.selectedMediaType = .photo
            }
            else if content?.type == ARTICLE_TYPE_YOUTUBE {
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
            
            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: ApplicationAlertMessages.kMsgInternetNotAvailable)
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
                
                self.view.makeToast(NSLocalizedString("Article removed successfully", comment: ""), duration: 1.0, position: .bottom)
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



extension TrendingNewsVC: CommentsVCDelegate {
    
    func commentsVCDismissed(articleID: String) {
        self.updateProgressbarStatus(isPause: false)
        
        
        SharedManager.shared.performWSToGetCommentsCount(id: articleID) { info in
            if info != nil {
                
                
                if self.selectedArticleData?.id == articleID {
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                        self.selectedArticleData?.info?.commentCount = info?.commentCount
                        (cell as? HomeDetailCardCell)?.setLikeComment(model: self.selectedArticleData?.info)
                    }
                } else {
                    if let selectedIndex = self.articlesArray.firstIndex(where: { $0.id == articleID }) {
    //                    self.articles[selectedIndex].info = info
                        self.articlesArray[selectedIndex].info?.commentCount = info?.commentCount ?? 0
                        
                        
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) {
                            (cell as? HomeListViewCC)?.setLikeComment(model: self.articlesArray[selectedIndex].info)
                            (cell as? HomeCardCell)?.setLikeComment(model: self.articlesArray[selectedIndex].info)
                            (cell as? YoutubeCardCell)?.setLikeComment(model: self.articlesArray[selectedIndex].info)
                            (cell as? VideoPlayerView)?.setLikeComment(model: self.articlesArray[selectedIndex].info)
                        }
                        
                    }
                }
                
            }
        }
        
        
    }
}



// MARK: - Ads
// Google Ads
extension TrendingNewsVC: GADUnifiedNativeAdLoaderDelegate {
    
    
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
extension TrendingNewsVC: FBNativeAdDelegate {
    
    
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
//                    if let indexPath = self.tableView.indexPath(for: cell) {
//                        self.tableView.reloadRows(at: [indexPath], with: .none)
//                    }
                }
            }
            
//            let view = self.tableView.footerView(forSection: 0) as? AdHeaderFooter
//            view?.loadFacebookAd(nativeAd: nativeAd, viewController: self)
            
            self.tableView.reloadSections([0], with: .none)
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

extension TrendingNewsVC: BulletDetailsVCLikeDelegate {
    
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
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            
            (cell as? HomeListViewCC)?.setLikeComment(model: self.articlesArray[index].info)
            (cell as? HomeCardCell)?.setLikeComment(model: self.articlesArray[index].info)
            (cell as? YoutubeCardCell)?.setLikeComment(model: self.articlesArray[index].info)
            (cell as? VideoPlayerView)?.setLikeComment(model: self.articlesArray[index].info)
        }
    }
    
    func commentUpdated(articleID: String, count: Int) {
    }
    func backButtonPressed(isVideoPlaying: Bool) {    }
    
}

