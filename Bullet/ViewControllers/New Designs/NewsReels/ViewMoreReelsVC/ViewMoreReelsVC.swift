//
//  ViewMoreReelsVC.swift
//  Bullet
//
//  Created by Mahesh on 09/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation
import LoadingShimmer
//import SkeletonView
import PanModal
import SwiftTheme
import Photos
import FBSDKShareKit


class ViewMoreReelsVC: UIViewController {
    
    @IBOutlet weak var tblExtendedView: UITableView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var viewOrgArticle: UIView!
    @IBOutlet weak var lblViewOriginalArticle: UILabel!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var imgClose: UIImageView!
    
    @IBOutlet weak var viewGoTop: UIView!
    @IBOutlet weak var lblGotTop: UILabel!

    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    
    var isShortFormEnabled = true
    var reelContent: Reel?

    //Tableview list varibles
    var articles: [articlesData] = []
    var nextPaginate = ""
    var isLikeApiRunning = false

    var forceSelectedIndexPath: IndexPath?
    var focussedIndexPath = IndexPath(row: 0, section: 0)
    let pagingLoader = UIActivityIndicatorView()
    private var prefetchState: PrefetchState = .idle
    private var isDirectionFindingNeeded = false
    private var generator = UIImpactFeedbackGenerator()

    //CELL INSTANCES
    private var curVideoVisibleCell: VideoPlayerVieww?
    private var curYoutubeVisibleCell: YoutubeCardCell?

    //sharing variables
    var urlOfImageToShare: URL?
    var shareTitle = ""
    var sourceBlock = false
    var sourceFollow = false
    var article_archived = false

    weak var delegateBulletDetails: BulletDetailsVCLikeDelegate?
    
    var mediaWatermark = MediaWatermark()
    var DocController: UIDocumentInteractionController = UIDocumentInteractionController()
    @IBOutlet weak var indicator: InstagramActivityIndicator!
    @IBOutlet weak var viewIndicator: UIView!

    // Dynamic container constraint
//    @IBOutlet weak var ctContainerViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var ctContainerViewBottom: NSLayoutConstraint!
    
    var showSkeletonLoader = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDesignView()
        registerCell()
        
        showLoader()
        getRefreshRelatedArticlesData()
        
        indicator.animationDuration = 1.0
        indicator.rotationDuration = 3
        indicator.numSegments = 15
        indicator.strokeColor = "#E01335".hexStringToUIColor()
        indicator.lineWidth = 3
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        //NotificationCenter.default.removeObserver(self)
        updateProgressbarStatus(isPause: true)
        
//        if let ptcTBC = tabBarController as? PTCardTabBarController {
//            ptcTBC.showTabBar(true, animated: false)
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        animateShowDimmedView()
        //        animatePresentContainer()
        
        
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
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//                
//        updateProgressbarStatus(isPause: true)
//    }
    
    private func setupDesignView() {
        
        viewOrgArticle.isHidden = (reelContent?.link == nil || (reelContent?.link ?? "").isEmpty) ? true : false
        lblViewOriginalArticle.text = NSLocalizedString("View Source Video", comment: "").uppercased()
        
        if let pubDate = reelContent?.publishTime {
            lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
        }
        lblViews.text = "\(reelContent?.info?.viewCount ?? "0") \(NSLocalizedString("Views", comment: ""))".lowercased()
        
        lblNoData.isHidden = true
        lblNoData.text = NSLocalizedString("No Related Articles Yet", comment: "")

        viewGoTop.isHidden = true
        viewGoTop.cornerRadius = viewGoTop.frame.height / 2
        lblGotTop.text = NSLocalizedString("Go to top", comment: "")

        containerView.backgroundColor = .white
//        let lightImage = UIImage(named: "tbFrowordArrow")?.sd_tintedImage(with: Constant.appColor.blue)
//        imgArrow.image = lightImage
        
        //imgClose.image = UIImage(named: "closeDiscoverListLight")
        imgClose.image = UIImage(named: "Icn_back2")
    }
    
    private func showLoader() {
        
        DispatchQueue.main.async {
            
//            let animation = GradientDirection.leftRight.slidingAnimation()
//                        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftToRight)
//            self.tblExtendedView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient.init(baseColor: GlobalPicker.skeletonColorLightMode), animation: animation, transition: .crossDissolve(0.25))
//            self.tblExtendedView.showSkeleton()
            
//            let gradient = SkeletonGradient(baseColor: GlobalPicker.skeletonColorLightMode)
//            self.tblExtendedView.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
            
//            self.tblExtendedView.showSkeleton(usingColor: GlobalPicker.skeletonColorLightMode)
            
            
            self.showSkeletonLoader = true
            self.tblExtendedView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.viewIndicator.isHidden = true
        }
    }
    
    private func registerCell() {
        
        //register cardcell for storyboard use
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_HOME_LISTVIEW, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_HOME_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_HOME_CARD)
//        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_ADS_LIST, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_ADS_LIST)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_YOUTUBE_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_YOUTUBE_CARD)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_VIDEO_PLAYER, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER)
        
        tblExtendedView.register(UINib(nibName: "HomeSkeltonCardCell", bundle: nil), forCellReuseIdentifier: "HomeSkeltonCardCell")
        tblExtendedView.register(UINib(nibName: "HomeSkeltonListCell", bundle: nil), forCellReuseIdentifier: "HomeSkeltonListCell")

        tblExtendedView.register(UINib(nibName: "sugClvReelsCC", bundle: nil), forCellReuseIdentifier: "sugClvReelsCC")
        tblExtendedView.register(UINib(nibName: "RelatedCC", bundle: nil), forCellReuseIdentifier: "RelatedCC")

//        tblExtendedView.register(UINib(nibName: "sugClvAuthorsCC", bundle: nil), forCellReuseIdentifier: "sugClvAuthorsCC")
//        tblExtendedView.register(UINib(nibName: "FeedFooterCC", bundle: nil), forCellReuseIdentifier: "FeedFooterCC")
    }
    
    private func getRefreshRelatedArticlesData() {
        
        tblExtendedView.setContentOffset(.zero, animated: false)
        focussedIndexPath = IndexPath(row: 0, section: 0)
        nextPaginate = ""
        
        if pagingLoader.isAnimating {
            
            self.pagingLoader.stopAnimating()
            self.pagingLoader.hidesWhenStopped = true
        }
        pagingLoader.color = "#3D485F".hexStringToUIColor()
        pagingLoader.startAnimating()
        pagingLoader.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tblExtendedView.bounds.width, height: CGFloat(62))
        
        self.tblExtendedView.tableFooterView = pagingLoader
        self.tblExtendedView.tableFooterView?.isHidden = false
        
        self.performWSToRelatedReels(page: nextPaginate)
    }
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapBackAction(_ button: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapViewArticle(_ button: UIButton) {
                        
        SharedManager.shared.openWebPageViewController(parentVC: self, pageUrlString: reelContent?.link ?? "", isPresenting: true)
    }
    
    @IBAction func didTapGoToTop(_ button: UIButton) {
        
        if prefetchState != .fetching && articles.count == tblExtendedView.numberOfRows(inSection: 0) {
            
            updateProgressbarStatus(isPause: true)
            focussedIndexPath = IndexPath(row: 0, section: 0)
            tblExtendedView.setContentOffset(.zero, animated: false)
            tblExtendedView.reloadData()
            tblExtendedView.layoutIfNeeded()
            tblExtendedView.setContentOffset(.zero, animated: false)

        }
    }
}

//MARK:- Table Customs Methods
extension ViewMoreReelsVC {

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
            resetPlayerAtIndex(cell: vCell)
        }

    }
    
    func updateProgressbarStatus(isPause: Bool) {
        
        print("print 3...")
        SharedManager.shared.bulletPlayer?.pause()
        
        if isPause {
            
            if let cell = self.tblExtendedView.cellForRow(at: self.focussedIndexPath) as? HomeCardCell {
                
                cell.pauseAudioAndProgress(isPause:true)
                
            }
            else if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? HomeListViewCC {
                
                cell.pauseAudioAndProgress(isPause:true)
                
            }
            else if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? VideoPlayerVieww {
                
//                cell.playVideo(isPause: true)
                playVideoOnFocus(cell: cell, isPause: true)
            }
            else if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? YoutubeCardCell {
                
                cell.resetYoutubeCard()
            }
            
        }
        else {
            
            if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? HomeCardCell {
                
                if let visibleIndex = self.getVisibleIndexPath() {
                    
                    if visibleIndex == self.focussedIndexPath {
                        cell.pauseAudioAndProgress(isPause:false)
                    }
                }
            }
            else if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? HomeListViewCC {
                                
                if let visibleIndex = self.getVisibleIndexPath() {
                    
                    if visibleIndex == self.focussedIndexPath {
                        print("audio playing 2")
                        cell.pauseAudioAndProgress(isPause:false)
                    }
                }
            }
            else if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? VideoPlayerVieww {
                
//                cell.playVideo(isPause: false)
                playVideoOnFocus(cell: cell, isPause: false)
            }
            else if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? YoutubeCardCell {
                
                cell.setFocussedYoutubeView()
            }
        }
    }
    
    func getCurrentFocussedCell() -> UITableViewCell {
        
        if let cell = tblExtendedView.cellForRow(at: focussedIndexPath) {
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

//MARK:- TABLE VIEW DELEGATE
extension ViewMoreReelsVC: UITableViewDelegate, UITableViewDataSource {
    
    //gradient for ForYou page
    func setGradientBackground(viewBG:UIView,colours: [UIColor]) {
                
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
        return self.articles.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let skeletonCell = cell as? HomeSkeltonCardCell {
            skeletonCell.slide(to: .right)
        }
        
        if let skeletonCell = cell as? HomeSkeltonListCell {
            skeletonCell.slide(to: .right)
        }
        
        
        if let cell = cell as? HomeListViewCC {
            
            cell.clvBullets.reloadData()
        }
        //cellHeights[indexPath] = cell.frame.size.height
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
        
        let content = self.articles[indexPath.row]
        
        //LOCAL VIDEO TYPE
        if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_VIDEO {

            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            let videoPlayer = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_VIDEO_PLAYER, for: indexPath) as! VideoPlayerVieww
         //   videoPlayer.delegateVideoView = self
            videoPlayer.viewDividerLine.isHidden = true
            videoPlayer.constraintContainerViewBottom.constant = 10
            videoPlayer.isViewMoreReels = true

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
//            videoPlayer.lblSource.addTextSpacing(spacing: 2.5)
            
            if let pubDate = content.publish_time {
                videoPlayer.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
            }
//            videoPlayer.lblTime.addTextSpacing(spacing: 1.25)
            
            if self.focussedIndexPath == indexPath {
                self.curVideoVisibleCell = videoPlayer
            }
            
            if let bullets = content.bullets {
                
                print("audio playing")
                videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: self.focussedIndexPath == indexPath ? true : false)
            }
            
//            //Report concern
//            videoPlayer.btnReport.tag = indexPath.row
//            videoPlayer.btnReport.addTarget(self, action: #selector(didTapReportArticle(button:)), for: .touchUpInside)
            
//            videoPlayer.ctViewContainerLeading.constant = 10
//            videoPlayer.ctViewContainerTrailing.constant = 10
//            videoPlayer.viewContainer.addRoundedShadowCell()
//            videoPlayer.viewContainer.layer.cornerRadius = 12
            videoPlayer.setNeedsUpdateConstraints()
            videoPlayer.updateConstraintsIfNeeded()
            videoPlayer.setNeedsLayout()
            videoPlayer.layoutIfNeeded()
            videoPlayer.btnReport.isHidden = true
            
            //White Color theme color
            //videoPlayer.viewDividerLine.backgroundColor = "#d8d9d8".hexStringToUIColor()
            videoPlayer.viewContainer.backgroundColor = .white
            videoPlayer.lblVideoBullet.textColor = .black
            videoPlayer.lblSource.textColor = .black
            videoPlayer.lblTime.textColor = "#84838B".hexStringToUIColor()
            
            return videoPlayer
        }
        
        //GOOGLE ADS CELL
//        else if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_ADS {
//
//            SharedManager.shared.isVolumnOffCard = true
//
//            SharedManager.shared.bulletPlayer?.stop()
//            SharedManager.shared.bulletPlayer?.currentTime = 0
//            //print("Volume 36")
//
//            let adCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_ADS_LIST, for: indexPath) as! HomeListAdsCC
//
//            adCell.viewDividerLine.isHidden = true
//            adCell.constraintContainerViewBottom.constant = 10
//
//            adCell.selectionStyle = .none
//            if SharedManager.shared.adType.uppercased() == "FACEBOOK" {
//
//                adCell.loadFacebookAd(nativeAd: self.fbnNativeAd, viewController: self)
//            } else {
//
//                adCell.loadGoogleAd(nativeAd: self.googleNativeAd)
//            }
//
//            adCell.contentView.backgroundColor = .clear
//            adCell.viewUnifiedNativeAd.backgroundColor = .clear
//            adCell.viewBackground.theme_backgroundColor =  GlobalPicker.bgBlackWhiteColor
//            return adCell
//
//        }
        
        //YOUTUBE CARD CELL
        else if content.type?.uppercased() == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            
            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            //print("Volume 37")
            
            let youtubeCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_YOUTUBE_CARD, for: indexPath) as! YoutubeCardCell
            
            youtubeCell.isViewMoreReels = true
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
//            youtubeCell.lblTime.addTextSpacing(spacing: 1.25)
            
            //Selected cell
            if self.focussedIndexPath == indexPath {
                self.curYoutubeVisibleCell = youtubeCell
            }
            
            //setup cell
            if let bullets = content.bullets {
                
                youtubeCell.setupSlideScrollView(bullets: bullets, row: indexPath.row)
            }
            
//            //Report concern
//            youtubeCell.btnReport.tag = indexPath.row
//            youtubeCell.btnReport.addTarget(self, action: #selector(didTapReportArticle(button:)), for: .touchUpInside)

//            youtubeCell.ctViewContainerLeading.constant = 10
//            youtubeCell.ctViewContainerTrailing.constant = 10
//            youtubeCell.viewContainer.addRoundedShadowCell()
//            youtubeCell.viewContainer.layer.cornerRadius = 12
            youtubeCell.layoutIfNeeded()
            youtubeCell.btnReport.isHidden = true
            
            //White Color theme only
            youtubeCell.viewDividerLine.backgroundColor = "#d8d9d8".hexStringToUIColor()
            youtubeCell.lblSource.textColor = "#000".hexStringToUIColor()
            youtubeCell.lblTime.textColor = "#84838B".hexStringToUIColor()
            youtubeCell.lblAuthor.textColor = "#84838B".hexStringToUIColor()
            youtubeCell.viewContainer.backgroundColor = .white
            
            return youtubeCell
        }
        
        //HOME ARTICLES CELL
        else {
            
            SharedManager.shared.isVolumnOffCard = false
            
            if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_SIMPLE {
                
                //LIST VIEW DESIGN CELL- SMALL CELL
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_LISTVIEW, for: indexPath) as? HomeListViewCC else { return UITableViewCell() }
            
                cell.isViewMoreReels = true

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
                print("audio playing")
                cell.setupCellBulletsView(article: content, isAudioPlay: self.focussedIndexPath == indexPath ? true : false, row: indexPath.row, isMute: content.mute ?? false)

//                //Report concern
//                cell.btnReport.tag = indexPath.row
//                cell.btnReport.addTarget(self, action: #selector(didTapReportArticle(button:)), for: .touchUpInside)
                
//                cell.ctContainerViewLeading.constant = 10
//                cell.ctContainerViewTrailing.constant = 10
//                cell.viewBackground.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
//                cell.viewBackground.addRoundedShadowCell()
//                cell.viewBackground.layer.cornerRadius = 12
                cell.btnReport.isHidden = true
                cell.layoutIfNeeded()

                //cell.viewDividerLine.backgroundColor = "#d8d9d8".hexStringToUIColor()
                cell.btnLeft.tintColor = "#909090".hexStringToUIColor()
                cell.btnRight.tintColor = "#909090".hexStringToUIColor()

                cell.lblTime.textColor = "#84838B".hexStringToUIColor()
//                cell.lblAuthor.textColor = "#84838B".hexStringToUIColor()
                cell.lblSource.textColor = .black
                //cell.viewLikeCommentBG.backgroundColor = .white
                return cell
            }
            else if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_EXTENDED {

                //CARD VIEW DESIGN CELL- LARGE CELL
                guard let cardCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_HOME_CARD, for: indexPath) as? HomeCardCell else { return UITableViewCell() }
    
                cardCell.isViewMoreReels = true
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

                //Image Pre-loading logic
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
//                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
//                tapGesture.view?.tag = indexPath.row
//                print("cardCell.viewGestures: ", indexPath.row)
//                cardCell.addGestureRecognizer(tapGesture)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
                tapGesture.view?.tag = indexPath.row
                cardCell.tag = indexPath.row

                cardCell.viewGestures.addGestureRecognizer(tapGesture)

                cardCell.btnReport.tag = indexPath.row
//                cardCell.btnShare.tag = indexPath.row
                cardCell.btnSource.tag = indexPath.row
                cardCell.btnReport.addTarget(self, action: #selector(didTapReport(button:)), for: .touchUpInside)
//                cardCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
                cardCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)

                if let source = content.source {
                    
                    let sourceURL = source.icon ?? ""
//                    cardCell.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
                    cardCell.lblSource.text = source.name ?? ""
//                    cardCell.lblSource.addTextSpacing(spacing: 2.5)
                }
                else {
                    
                    let url = content.authors?.first?.image ?? ""
//                    cardCell.imgWifi?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
                    cardCell.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
//                    cardCell.lblSource.addTextSpacing(spacing: 2.5)
                }
                
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
                
                //cardCell.setupSlideScrollView(article: content, isAudioPlay: false, row: indexPath.row, isMute: true)
                print("audio playing")
                cardCell.setupSlideScrollView(article: content, isAudioPlay: self.focussedIndexPath == indexPath ? true : false, row: indexPath.row, isMute: content.mute ?? false)

//                //Report concern
//                cardCell.btnReport.tag = indexPath.row
//                cardCell.btnReport.addTarget(self, action: #selector(didTapReportArticle(button:)), for: .touchUpInside)
                
//                cardCell.ctContainerViewLeading.constant = 10
//                cardCell.ctContainerViewTrailing.constant = 10
//                cardCell.viewContainer.backgroundColor = .white
//                cardCell.viewContainer.addRoundedShadowCell()
//                cardCell.viewContainer.layer.cornerRadius = 12
                cardCell.btnReport.isHidden = true
                cardCell.layoutIfNeeded()

                //White color theme only
                cardCell.viewContainer.backgroundColor = .white
                //cardCell.viewDividerLine.backgroundColor = "#d8d9d8".hexStringToUIColor()
                cardCell.lblTime.textColor = "#84838B".hexStringToUIColor()
//                cardCell.lblAuthor.textColor = cardCell.lblTime.textColor

//                cardCell.lblCollection.forEach {
//                    $0.textColor = "#84838B".hexStringToUIColor()
//                }
                cardCell.lblSource.textColor = .black

                
                // Color change not needed for view more reels
                cardCell.cellContainerView.backgroundColor = .clear
                return cardCell
            }
            else if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_REELS {

                guard let sugcell = tableView.dequeueReusableCell(withIdentifier: "sugClvReelsCC", for: indexPath) as? sugClvReelsCC else { return UITableViewCell() }
                sugcell.selectionStyle = .none
                sugcell.delegateSugReels = self
                sugcell.setupCell(content: content, row: indexPath.row)
                sugcell.lblTitle.textColor = .black
                sugcell.layoutIfNeeded()
                return sugcell
            }
            else if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_RELATED_CELL {

                guard let rCell = tableView.dequeueReusableCell(withIdentifier: "RelatedCC", for: indexPath) as? RelatedCC else { return UITableViewCell() }
                rCell.selectionStyle = .none
                rCell.lblTitle.textColor = .black
                rCell.lblTitle.text = NSLocalizedString("Related Articles", comment: "")
                rCell.layoutIfNeeded()
                return rCell
            }
            
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.articles.count > 0 {
            
            let content = self.articles[indexPath.row]
            if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_REELS {
                //let height = CGFloat(210 + 50)
                return COLLECTION_HEIGHT_REELS
            }
            else if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_RELATED_CELL {
                return 45
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension
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
        
    func focusedIndex(index: Int) {
        
        //EXTENDED/LIST VIEW TAP TO PLAY YOUTUBE
        updateProgressbarStatus(isPause: true)
        
        focussedIndexPath = IndexPath(row: index, section: 0)

        if let vCell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? VideoPlayerVieww {
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
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: row, section: 0)) as? HomeCardCell {
            
            let content = self.articles[row]
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
            
        }
        
        let row = sender.view?.tag ?? 0
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: row, section: 0)) as? HomeListViewCC {
            
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
                        
            if index == focussedIndexPath.row {
                
                //focus cell
                pausePlayAudio(cell)
                
                if sender.tag == 0 {
                    
                    //LEFT
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articles[focussedIndexPath.row].id ?? "")
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
                    
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articles[focussedIndexPath.row].id ?? "")
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
            
            if index == focussedIndexPath.row {
                
                //focus cell
                pausePlayAudio(cell)
                
                if sender.tag == 0 {
                    
                    //LEFT
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articles[focussedIndexPath.row].id ?? "")
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
                    
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articles[focussedIndexPath.row].id ?? "")
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
}

//MARK:- Suggested Reels and authors Delegate
extension ViewMoreReelsVC: sugClvReelsCCDelegate, sugClvAuthorsCCDelegate {
    
    //Reels
    func didTapOnReelsCell(cell: UITableViewCell, reelRow: Int) {
        
        updateProgressbarStatus(isPause: true)
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else { return }

        let content = self.articles[indexPath.row]
        if let reelsArray = content.suggestedReels {
            
//            let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
//            vc.contextID = reelsArray[reelRow].context ?? ""
//            vc.titleText = content.title ?? ""
//            vc.isBackButtonNeeded = true
//            //vc.delegate = self
//            let navVC = AppNavigationController(rootViewController: vc)
//            navVC.modalPresentationStyle = .overFullScreen
//            self.present(navVC, animated: true, completion: nil)
            
            let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
            vc.isBackButtonNeeded = true
            vc.modalPresentationStyle = .overFullScreen
            vc.reelsArray = reelsArray
            
            vc.isSugReels = true
            //vc.delegate = self
            vc.userSelectedIndexPath = IndexPath(item: reelRow, section: 0)
            vc.authorID = reelsArray[reelRow].authors?.first?.id ?? ""
            vc.scrollToItemFirstTime = true

            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .overFullScreen
            self.present(navVC, animated: true, completion: nil)

        }
    }
    
    //Authors
    func didTapFollowAuthorCollection(content: articlesData, authorIdx: Int, tapOnFollow: Bool) {
        
        if let row = self.articles.firstIndex(where: { $0.id == content.id }) {
            self.articles[row] = content
        }
        
        let author = content.suggestedAuthors?[authorIdx]
        if tapOnFollow {
            
            self.performWSToAuthorFollowUnfollow(id: author?.id ?? "", isFav: author?.favorite ?? false)
        }
        else {
            
            self.updateProgressbarStatus(isPause: true)

            if (author?.id ?? "") == SharedManager.shared.userId {
                
                let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
                let navVC = AppNavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .overFullScreen
                //vc.delegate = self
                self.present(navVC, animated: true, completion: nil)
            }
            else {
                
                let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                vc.content = content
                vc.delegateVC = self
                let name = ((author?.first_name ?? "") + " " + (author?.last_name ?? "")).trim()
                vc.authors = [Authors(id: author?.id, name: name, username: author?.username, image: author?.profile_image, favorite: author?.favorite)]
                let navVC = AppNavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .overFullScreen
                self.present(navVC, animated: true, completion: nil)
            }

        }
    }
    
    func performWSToAuthorFollowUnfollow(id: String, isFav: Bool) {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["authors":id]
        let url = isFav ? "news/authors/follow" : "news/authors/unfollow"

        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let _ = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    
    func openViewController(article: articlesData) {
        
        if (article.authors?.first?.id ?? "") == SharedManager.shared.userId {
            
            let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .overFullScreen
            //vc.delegate = self
            self.present(navVC, animated: true, completion: nil)
        }
        else {
            
            let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
            vc.authors = article.authors
            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .overFullScreen
            //vc.delegate = self
            self.present(navVC, animated: true, completion: nil)
        }

    }
}

//MARK:- HomeCardCell Delegate methods
extension ViewMoreReelsVC: HomeCardCellDelegate, YoutubeCardCellDelegate, VideoPlayerViewwDelegates, FullScreenVideoVCDelegate {
    
    func backButtonPressed(cell: HomeDetailCardCell?) {}
    func backButtonPressed(cell: GenericVideoCell?) {}
    func backButtonPressed(cell: VideoPlayerVieww?) {
        
//        cell?.playVideo(isPause: false)
        guard let cell = cell else { return }
        playVideoOnFocus(cell: cell, isPause: false)
    }
    
    
    func didTapCardCellFollow(cell: HomeCardCell) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
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
            
            player.pause()
            print("player.pause at indexPath", indexPath)
//            if self.isCommunityCell {
//                self.btnReport.isHidden = false
//            }
            
//            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoDurationEvent, eventDescription: "", article_id: self.articles[self.focussedIndexPath.row].id ?? "", duration: MediaManager.sharedInstance.player?.currentTime?.formatToMilliSeconds() ?? "")
            
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
            cell.viewDuration.isHidden = false
            cell.imgPlayButton.isHidden = false
        }
        
    }
    
    func didTapVideoPlayButton(cell: VideoPlayerVieww, isTappedFromCell: Bool) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
        
        let art = self.articles[indexPath.row]
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
        MediaManager.sharedInstance.player?.scrollView = tblExtendedView
        
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
        
        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.selectedArticleData = content
        vc.delegate = self
//        vc.delegateVC = self
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
        
//        let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
//        vc.delegateVC = self
//        vc.webURL = content.link ?? ""
//        vc.titleWeb = content.source?.name ?? ""
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true, completion: nil)
        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.selectedArticleData = content
        vc.delegate = self
//        vc.delegateVC = self
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalTransitionStyle = .crossDissolve
        self.present(navVC, animated: true, completion: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
//        self.presentDetail(navVC)
        
    }
        
    @objc func didTapPlayYoutube(_ button: UIButton) {
        
        //EXTENDED/LIST VIEW TAP TO PLAY YOUTUBE
        updateProgressbarStatus(isPause: true)
        
        let index = button.tag
        self.focussedIndexPath = IndexPath(row: index, section: 0)
        
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? YoutubeCardCell {
            
            //self.curVisibleYoutubeCardCell = cell
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
        let content = self.articles[index]
        performWSToShare(article: content, isOpenForNativeShare: false)
    }
    
    @objc func didTapShare(button: UIButton) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.shareClick, eventDescription: "")

        self.updateProgressbarStatus(isPause: true)
        let index = button.tag
        let content = self.articles[index]
        performWSToShare(article: content, isOpenForNativeShare: true)
    }
    
    @objc func didTapSource(button: UIButton) {
        
        //EXTENDED VIEW TAP TO OPEN SOURCE
        let index = button.tag
        let content = self.articles[index]
        
        if let _ = content.source {
            
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
            openViewController(article: content)
            
//            let authors = content.authors
//            if (authors?.first?.id ?? "") == SharedManager.shared.userId {
//
//                let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
//                let navVC = AppNavigationController(rootViewController: vc)
//                navVC.modalPresentationStyle = .overFullScreen
//                //vc.delegate = self
//                self.present(navVC, animated: true, completion: nil)
//            }
//            else {
//
//                let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
//                vc.authors = authors
//                let navVC = AppNavigationController(rootViewController: vc)
//                navVC.modalPresentationStyle = .overFullScreen
////                vc.delegateVC = self
//                self.present(navVC, animated: true, completion: nil)
//            }
        }
    }
    
    @objc func didTapReportArticle(button: UIButton) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reportClick, eventDescription: "")

        self.updateProgressbarStatus(isPause: true)
        let index = button.tag
        let content = self.articles[index]
        
        let vc = BottomSheetVC.instantiate(fromAppStoryboard: .registration)
        vc.delegateBottomSheet = self
        vc.article = content
//        vc.isFromCommunityFeed = true
        vc.openReportList = true
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    //<---
    // Public delegate methods for all cells are here
    func handleLongPressHold(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        var index: Int = 0
        index = self.focussedIndexPath.row

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
        
        
        //Data always load from first position
        var index = 0
        index = focussedIndexPath.row

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
                if content.type == Constant.newsArticle.ARTICLE_TYPE_RELATED_CELL || content.type == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_REELS || content.type == Constant.newsArticle.ARTICLE_TYPE_ADS {
                    newIndex += 1
                    
//                    if newIndex < self.articles.count {
//                        let content = self.articles[newIndex]
//                        if content.type == ARTICLE_TYPE_TITLE {
//                            newIndex += 1
//                        }
//                    }
                    newIndexPath = IndexPath(row: newIndex, section: newIndexPath.section)
                }
            }
            else if newIndex == self.articles.count - 1 {
                let content = self.articles[newIndex]
                if content.type == Constant.newsArticle.ARTICLE_TYPE_RELATED_CELL || content.type == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_REELS || content.type == Constant.newsArticle.ARTICLE_TYPE_ADS {
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
                    self.focussedIndexPath = newIndexPath
                }
                else if let cell = self.tblExtendedView.cellForRow(at: newIndexPath) as? HomeListViewCC {

                    let content = self.articles[newIndexPath.row]
                    cell.setupCellBulletsView(article: content, isAudioPlay: true, row: newIndexPath.row, isMute: content.mute ?? true)

                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.focussedIndexPath = newIndexPath
                }
                else if let vCell = self.tblExtendedView.cellForRow(at: newIndexPath) as? VideoPlayerVieww {
                    
                    vCell.videoControllerStatus(isHidden: true)
//                    vCell.playVideo(isPause: false)
                    self.playVideoOnFocus(cell: vCell, isPause: false)
                    
                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.focussedIndexPath = newIndexPath
                }
                
                else if let yCell = self.tblExtendedView.cellForRow(at: newIndexPath) as? YoutubeCardCell {
                    
                    self.curYoutubeVisibleCell = yCell
                    yCell.setFocussedYoutubeView()
                    
                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.focussedIndexPath = newIndexPath
                }
            }
        }
        else if self.articles.count == 1 {
            
            //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
            focussedIndexPath = IndexPath(row: 0, section: 0)
            tblExtendedView.reloadRows(at: [focussedIndexPath], with: .none)
        }
    }
    //--->
}

//MARK:- SCROLL VIEW DELEGATE
extension ViewMoreReelsVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                
        viewGoTop.isHidden = !(scrollView.contentOffset.y > 50)
        if scrollView.contentOffset.y > 50 {
            viewGoTop.alpha = max(scrollView.contentOffset.y / 1000, 1)
        }

        //Pagination
        let prefetchThreshold: CGFloat = Constant.newsArticle.BOTTOM_INSET + 30 // prefetching will start prefetchThreshold (ex.100pts) above the bottom of the scroll view
        if scrollView.contentOffset.y > scrollView.contentSize.height - tblExtendedView.frame.height - prefetchThreshold {
            
            if prefetchState == .idle {
                
                //print("mahesh nextPaginate", nextPaginate)
                guard prefetchState == .idle && !(nextPaginate.isEmpty) else { return }
                prefetchState = .fetching
                //check page before calling API
                self.performWSToRelatedReels(page: nextPaginate)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
                    
        //showHideBottomBar(scrollView)

//        previousScrollOffset = self.tblExtendedView.contentOffset.y

        isDirectionFindingNeeded = false
        
        ////print("scrollViewWillBeginDragging")
        updateProgressbarStatus(isPause: true)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {

        //showHideBottomBar(scrollView)
        
        ////print("scrollViewWillBeginDecelerating")
        updateProgressbarStatus(isPause: true)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if decelerate { return }
        
        updateProgressbarStatus(isPause: false)
        scrollToTopVisibleExtended()

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //ScrollView for ListView Mode
        updateProgressbarStatus(isPause: false)
        scrollToTopVisibleExtended()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        
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
        
        if viewWillAppear {
            
            //Set Selected index into focus variables
            if let indexPath = indexPathVisible {
                focussedIndexPath = indexPath
            }
        }
        
        if var indexPath = indexPathVisible, indexPath != focussedIndexPath {
            
            var index = indexPath.row
            
            //Reset cell
            self.resetCurrentFocussedCell()
            
            //For Skip Reels and Author cell
            if index < self.articles.count && index != self.articles.count - 1 {
                
                let content = self.articles[index]
                if content.type == Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_REELS || content.type == Constant.newsArticle.ARTICLE_TYPE_RELATED_CELL || content.type == Constant.newsArticle.ARTICLE_TYPE_ADS {
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
            
            if let yCell = self.getCurrentFocussedCell() as? YoutubeCardCell {
     
                
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
    
    func setSelectedCellAndPlay(index: Int, indexPath: IndexPath) {
        
        focussedIndexPath = indexPath
        
        //ASSIGN CELL FOR CARD VIEW
        if let cell = tblExtendedView.cellForRow(at: indexPath) as? HomeCardCell {
            
            if self.prefetchState == .idle && articles.count > 0 {
                
                
                let content = self.articles[index]
                cell.setupSlideScrollView(article: content, isAudioPlay: true, row: index, isMute: content.mute ?? true)
                print("audio playing")
            }
        }
        else if let cell = tblExtendedView.cellForRow(at: indexPath) as? HomeListViewCC {
            
            //ASSIGN CELL FOR LSIT VIEW
            if self.prefetchState == .idle && articles.count > 0 {
                
                
                let content = self.articles[index]
                cell.setupCellBulletsView(article: content, isAudioPlay: true, row: index, isMute: content.mute ?? true)
                print("audio playing")
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
                vCell.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: self.focussedIndexPath == indexPath ? true : false)
            }
        }
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
}

// MARK: - Comment Like Delegates
extension ViewMoreReelsVC: LikeCommentDelegate {
    
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
//        (cell as? HomeCardCell)?.setLikeComment(model: self.articles[indexPath.row].info)
        (cell as? YoutubeCardCell)?.setLikeComment(model: self.articles[indexPath.row].info)
        (cell as? VideoPlayerVieww)?.setLikeComment(model: self.articles[indexPath.row].info)

        performWSToLikePost(article_id: self.articles[indexPath.row].id ?? "", isLike: self.articles[indexPath.row].info?.isLiked ?? false)
        
        
        self.delegateBulletDetails?.likeUpdated(articleID: self.articles[indexPath.row].id ?? "", isLiked: self.articles[indexPath.row].info?.isLiked ?? false, count: likeCount ?? 0)
        
    }
}

// MARK: - BulletDetails Like Delegates
extension ViewMoreReelsVC: BulletDetailsVCLikeDelegate, CommentsVCDelegate {
    
    func likeUpdated(articleID: String, isLiked: Bool, count: Int) {
        
        if let index = self.articles.firstIndex(where: { $0.id == articleID }) {
            self.articles[index].info?.isLiked = isLiked
            self.articles[index].info?.likeCount = count
            let cell = tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0))
            
            (cell as? HomeListViewCC)?.setLikeComment(model: self.articles[index].info)
//            (cell as? HomeCardCell)?.setLikeComment(model: self.articles[index].info)
            (cell as? YoutubeCardCell)?.setLikeComment(model: self.articles[index].info)
            (cell as? VideoPlayerVieww)?.setLikeComment(model: self.articles[index].info)
        }
        
    }
    
    func commentUpdated(articleID: String, count: Int) {
    }
    
    func backButtonPressed(isVideoPlaying: Bool) {
        
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
//                        (cell as? HomeCardCell)?.setLikeComment(model: self.articles[selectedIndex].info)
                        (cell as? YoutubeCardCell)?.setLikeComment(model: self.articles[selectedIndex].info)
                        (cell as? VideoPlayerVieww)?.setLikeComment(model: self.articles[selectedIndex].info)
                    }
                    
                }
            }
        }
    }
}

//MARK:- BottomSheetVC Delegate methods
extension ViewMoreReelsVC: BottomSheetVCDelegate, SharingDelegate, UIDocumentInteractionControllerDelegate {
    
    func didTapUpdateAudioAndProgressStatus() {
        
        self.updateProgressbarStatus(isPause: false)
    }
    
    func didTapDissmisReportContent() {
        
        self.updateProgressbarStatus(isPause: false)
        SharedManager.shared.showAlertLoader(message: "Report concern sent successfully.",type: .alert)
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
                self.performGoToSource(article)
            }
            else {
                
                openViewController(article: article)
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
                    self.performWSToUnblockSource(article .source?.id ?? "", name: article.source?.name ?? "")
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

//MARK:- Popup Delegate
extension ViewMoreReelsVC: PopupVCDelegate {
    
    func popupVCDismissed() {

        let vc = EditProfileVC.instantiate(fromAppStoryboard: .Main)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK:- YoutubeArticle Delegate
extension ViewMoreReelsVC: YoutubeArticleVCDelegate {
    
    func submitYoutubeArticlePost(_ article: articlesData) {
        
        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
        vc.yArticle = article
        vc.postArticleType = .youtube
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- YoutubeArticle Delegate
extension ViewMoreReelsVC: AuthorProfileVCDelegate {
    
    func updateAuthorWhenDismiss(article: articlesData) {
        
        if let row = self.articles.firstIndex(where: { $0.id == article.id }) {
            self.articles[row] = article
        }
    }
}

//MARK:- Custom Method
//extension ViewMoreReelsVC: UIGestureRecognizerDelegate {
//
//    private func setupView() {
//         view.backgroundColor = .clear
//
//         containerView.theme_backgroundColor = GlobalPicker.backgroundColor
//         containerView.layer.cornerRadius = 16
//         containerView.clipsToBounds = true
//
//         dimmedView.backgroundColor = .black
//         dimmedView.alpha = maxDimmedAlpha
//
//     }
//
//    private func setupPanGesture() {
//        // add pan gesture recognizer to the view controller's view (the whole screen)
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
//        // change to false to immediately listen on gesture movement
//        panGesture.delaysTouchesBegan = false
//        panGesture.delaysTouchesEnded = false
//        panGesture.delegate = self
//        view.addGestureRecognizer(panGesture)
//    }
//
//     @objc func handleCloseAction() {
//         animateDismissView()
//     }
//
//     // MARK: Pan gesture handler
//     @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
//         let translation = gesture.translation(in: view)
//         // Drag to top will be minus value and vice versa
//         print("Pan gesture y offset: \(translation.y)")
//
//         // Get drag direction
//         let isDraggingDown = translation.y > 0
//         print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
//
//         // New height is based on value of dragging plus current container height
//         let newHeight = currentContainerHeight - translation.y
//
//         // Handle based on gesture state
//         switch gesture.state {
//         case .changed:
//             // This state will occur when user is dragging
//             if newHeight < maximumContainerHeight {
//                 // Keep updating the height constraint
//                 ctContainerViewHeight.constant = newHeight
//                 // refresh layout
//                 view.layoutIfNeeded()
//             }
//         case .ended:
//             // This happens when user stop drag,
//             // so we will get the last height of container
//
//             // Condition 1: If new height is below min, dismiss controller
//             if newHeight < dismissibleHeight {
//                 self.animateDismissView()
//             }
//             else if newHeight < defaultHeight {
//                 // Condition 2: If new height is below default, animate back to default
//                 animateContainerHeight(defaultHeight)
//             }
//             else if newHeight < maximumContainerHeight && isDraggingDown {
//                 // Condition 3: If new height is below max and going down, set to default height
//                 animateContainerHeight(defaultHeight)
//             }
//             else if newHeight > defaultHeight && !isDraggingDown {
//                 // Condition 4: If new height is below max and going up, set to max height at top
//                 animateContainerHeight(maximumContainerHeight)
//             }
//         default:
//             break
//         }
//     }
//
//     func animateContainerHeight(_ height: CGFloat) {
//         UIView.animate(withDuration: 0.4) {
//             // Update container height
//             self.ctContainerViewHeight.constant = height
//             // Call this to trigger refresh constraint
//             self.view.layoutIfNeeded()
//         }
//         // Save current height
//         currentContainerHeight = height
//     }
//
//     // MARK: Present and dismiss animation
//     func animatePresentContainer() {
//         // update bottom constraint in animation block
//         UIView.animate(withDuration: 0.3) {
//             self.ctContainerViewBottom?.constant = 0
//             // call this to trigger refresh constraint
//             self.view.layoutIfNeeded()
//         }
//     }
//
//     func animateShowDimmedView() {
//         dimmedView.alpha = 0
//         UIView.animate(withDuration: 0.4) {
//             self.dimmedView.alpha = self.maxDimmedAlpha
//         }
//     }
//
//     func animateDismissView() {
//         // hide blur view
//         dimmedView.alpha = maxDimmedAlpha
//         UIView.animate(withDuration: 0.4) {
//             self.dimmedView.alpha = 0
//         } completion: { _ in
//             // once done, dismiss without animation
//             self.dismiss(animated: false)
//         }
//         // hide main view by updating bottom constraint in animation block
//         UIView.animate(withDuration: 0.3) {
//             self.ctContainerViewBottom?.constant = -(self.defaultHeight)
//             // call this to trigger refresh constraint
//             self.view.layoutIfNeeded()
//         }
//     }
//
////    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
////
////        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
////            let translation = panGestureRecognizer.translation(in: view)
////            if abs(translation.x) > abs(translation.y) {
////                return true
////            }
////            return false
////        }
////        return false
////        //return true // obviously this could be more refined if you have other gesture recognizers
////    }
//
//    //This method helped me stopped up/down pangesture of UITableviewCell and allow only vertical scroll
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
//            let translation = panGestureRecognizer.translation(in: view)
//            print(translation.y)
//            if abs(translation.x) > abs(translation.y) {
//                return true
//            }
//            return false
//        }
//        return false
//    }
//}


//MARK:- Webservice Method
extension ViewMoreReelsVC {
    
    func performWSToRelatedReels(page: String) {

        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        if self.nextPaginate.isEmpty {
            
            DispatchQueue.main.async {
                if self.articles.count == 0 {
                    self.showLoader()
                }
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                self.pagingLoader.startAnimating()
                if self.showSkeletonLoader {
                    self.showSkeletonLoader = false
                    self.tblExtendedView.reloadData()
                }
            }
        }
                
        let param = ["page": page] as [String : Any]
//        let param = ["page": page]
        let reelId = reelContent?.id ?? ""
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
               
        let query = "news/articles/\(reelId)/related"
        WebService.URLResponse(query, method: .get, parameters: param, headers: token, withSuccess: { [weak self] (response) in
            
            guard let self = self else {
                return
            }
            
            do {
                
                let FULLResponse = try
                    JSONDecoder().decode(relatedReelsDC.self, from: response)
                
                
                DispatchQueue.main.async {
                    
                    //print(FULLR esponse.articles?.first?.id ?? "")
                    if self.nextPaginate == "" {
                        
                        self.articles.removeAll()
                    }
                    
                    //Load Data in tableview
                    if let arr = FULLResponse.articles, arr.count > 0 {
                        
                        for news in arr  {
                            if self.articles.contains(where: {$0.id == news.id }) == false {
                                self.articles.append(news)
                            }
                        }
                        
//                        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitFeedID != "" {
//
//                            //LOAD ADS
//                            self.articles.removeAll{ $0.type == Constant.newsArticle.ARTICLE_TYPE_ADS }
//                            self.articles = self.articles.adding(articlesData(id: "", title: "", image: "", link: "", color: "", publish_time: "", source: nil, bullets: nil, topics: nil, status: "", type: Constant.newsArticle.ARTICLE_TYPE_ADS), afterEvery: SharedManager.shared.adsInterval)
//                        }
                        
                        //<--- Insert suggest   ed reels and authors view
                        if self.nextPaginate == "" {
                            
                            var insertRow = 0
                            if let suggReels = FULLResponse.reels, suggReels.count > 0 {
                                
                                self.articles.insert(articlesData(id: "reels", title: nil, image: nil, link: nil, color: nil, publish_time: nil, source: nil, bullets: nil, topics: nil, status: "", type: Constant.newsArticle.ARTICLE_TYPE_SUGGESTED_REELS, suggestedReels: suggReels), at: insertRow)
                                
                                insertRow += 1
                            }
                            else {
                                insertRow = 0
                            }
                            
                            self.articles.insert(articlesData(id: "related", title: nil, image: nil, link: nil, color: nil, publish_time: nil, source: nil, bullets: nil, topics: nil, status: nil, type: Constant.newsArticle.ARTICLE_TYPE_RELATED_CELL), at: insertRow)
                        }
                        //--->

                        if let meta = FULLResponse.meta {
                            self.nextPaginate = meta.next ?? ""
                        }
                                    
                        //Reload data
                        //viewNoData.isHidden = true
                        self.tblExtendedView.isHidden = false
                        DispatchQueue.main.async {
                            if self.showSkeletonLoader {
                                self.showSkeletonLoader = false
                            }
                            self.tblExtendedView.reloadData()
                            //self.tblExtendedView.layoutIfNeeded()
                        }
                        self.isDirectionFindingNeeded = true
                        self.lblNoData.isHidden = true
                    }
                    else {
                        
                        //viewNoData.isHidden = articles.count > 0 ? true : false
                        self.lblNoData.isHidden = false
                        DispatchQueue.main.async {
                            if self.showSkeletonLoader {
                                self.showSkeletonLoader = false
                                self.tblExtendedView.reloadData()
                            }
                        }
                    }

                    self.prefetchState = .idle
                    self.pagingLoader.stopAnimating()
                    self.pagingLoader.hidesWhenStopped = true
                }
                
            } catch let jsonerror {
                
                DispatchQueue.main.async {
                    if self.showSkeletonLoader {
                        self.showSkeletonLoader = false
                    }
                    self.tblExtendedView.reloadData()
                    self.pagingLoader.stopAnimating()
                    self.pagingLoader.hidesWhenStopped = true
                    self.lblNoData.isHidden = false
                }
                self.prefetchState = .idle
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects", jsonerror)
                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            DispatchQueue.main.async {
                if self.showSkeletonLoader {
                    self.showSkeletonLoader = false
                }
                self.tblExtendedView.reloadData()
                self.pagingLoader.stopAnimating()
                self.pagingLoader.hidesWhenStopped = true
                self.lblNoData.isHidden = false
            }
            self.prefetchState = .idle
            //SharedManager.shared.showAPIFailureAlert()
            print("error parsing json objects",error)
        }
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
    
    func performWSToShare(article: articlesData, isOpenForNativeShare: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/articles/\(article.id ?? "")/share/info", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do {
                
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
                    
                    if isOpenForNativeShare {
                        self.openDefaultShareSheet(shareTitle: self.shareTitle)
                    }
                    else {
                        let vc = BottomSheetVC.instantiate(fromAppStoryboard: .registration)
    //                    vc.isFromCommunityFeed = true
                        vc.openReportList = false

                        if let _ = article.source { /* If article source */ }
                        else {
                            //If article author data
                            vc.isSameAuthor = true
                        }
                        
                        vc.showArticleType = .home
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
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/articles/\(article.id ?? "")/share/info", error: jsonerror.localizedDescription, code: "")
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
                        
//                        if let ptcTBC = self.tabBarController as? PTCardTabBarController {
//                            ptcTBC.showTabBar(false, animated: true)
//                        }
                        
                        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
                        detailsVC.channelInfo = Info
                        //detailsVC.delegateVC = self
                        //detailsVC.isOpenFromDiscoverCustomListVC = true
                        detailsVC.modalPresentationStyle = .fullScreen
                        let nav = AppNavigationController(rootViewController: detailsVC)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)

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
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: "Related Sources not available")
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
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
                        
                        self.updateProgressbarStatus(isPause: false)
                        SharedManager.shared.showAlertLoader(message: isArchived ? ApplicationAlertMessages.kMsgAddToFavorite : ApplicationAlertMessages.kMsRemoveFromFavorite, type: .alert)
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
    
    func performUnFollowUserSource(_ id: String, name:String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedSource, channel_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
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
                    
                    SharedManager.shared.isDiscoverTabReload = true
                    SharedManager.shared.isTabReload = true
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
    
    func performBlockSource(_ id: String, sourceName: String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockSource, eventDescription: "", source_id: id)

        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        WebService.URLResponse("news/sources/block", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do {
                let FULLResponse = try
                    JSONDecoder().decode(BlockTopicDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    self.updateProgressbarStatus(isPause: false)
                    if status == Constant.STATUS_SUCCESS {
                        
                        SharedManager.shared.showAlertLoader(message: "Blocked \(sourceName)", type: .alert)
                        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//                            if let ptcTBC = self.tabBarController as? PTCardTabBarController {
//                                ptcTBC.reloadViewOnBlock()
//                            }
//                        }
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
}

// MARK: - Pan Modal Presentable
extension ViewMoreReelsVC: PanModalPresentable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var panScrollable: UIScrollView? {
        return tblExtendedView
    }

//    var showDragIndicator: Bool {
//        return false
//    }
//
//    var shortFormHeight: PanModalHeight {
//        return isShortFormEnabled ? .contentHeight(300.0) : longFormHeight
//    }
//
////    var scrollIndicatorInsets: UIEdgeInsets {
////        let bottomOffset = presentingViewController?.bottomLayoutGuide.length ?? 0
////        return UIEdgeInsets(top: headerView.frame.size.height, left: 0, bottom: bottomOffset, right: 0)
////    }
//
//    var longFormHeight: PanModalHeight {
//        return .maxHeight
//    }
//
//    var anchorModalToLongForm: Bool {
//        return true
//    }
//
//    func willTransition(to state: PanModalPresentationController.PresentationState) {
//        guard isShortFormEnabled, case .longForm = state
//            else { return }
//
//        isShortFormEnabled = false
//        panModalSetNeedsLayoutUpdate()
//    }
}
    
