//
//  EndCardCell.swift
//  Bullet
//
//  Created by Mahesh on 03/09/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AVFoundation

internal let CELL_IDENTIFIER_YOUTUBE_CARD           = "YoutubeCardCell"
//internal let CELL_IDENTIFIER_YOUTUBE_BULLET         = "YoutubeBulletCell"

protocol YoutubeCardCellDelegate: AnyObject {
    
    //func handleSwipeLeftRightArticleDelegate(isLeftToRight: Bool)
    func autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: Bool)
}

class YoutubeCardCell: UITableViewCell {
    
    @IBOutlet weak var viewPlaceholder: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    //@IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet var videoPlayer: YouTubePlayerView!
    
    @IBOutlet weak var clvBullets: UICollectionView!
    
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSource: UIButton!
    @IBOutlet weak var imgWifi: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var btnPlayYoutube: UIButton!
    @IBOutlet weak var viewBGBullet: UIView!

    @IBOutlet weak var viewGestures: UIView!
    @IBOutlet weak var lblDummy: UILabel!
    
//    @IBOutlet weak var lblViewCount: UILabel!
//    @IBOutlet weak var viewCount: UIView!
//    @IBOutlet weak var viewComment: UIView!
//    @IBOutlet weak var viewLike: UIView!
//    @IBOutlet weak var lblCommentsCount: UILabel!
//    @IBOutlet weak var lblLikeCount: UILabel!
//    @IBOutlet weak var imgLike: UIImageView!
//    @IBOutlet weak var imgComment: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    
    //View Processing Upload Article by User
    @IBOutlet weak var viewProcessingBG: UIView!
    @IBOutlet weak var viewLoader: NVActivityIndicatorView!
    @IBOutlet weak var viewProcess: UIView!
    @IBOutlet weak var lblProcessing: UILabel!
    
    //View Schedule Upload Article by User
    @IBOutlet weak var viewScheduleBG: UIView!
    @IBOutlet weak var viewSchdule: UIView!
    @IBOutlet weak var lblScheduleTime: UILabel!

    @IBOutlet weak var lblAuthor: UILabel!
//    @IBOutlet weak var imgDot: UIImageView!
//    @IBOutlet weak var viewDot: UIView!
    
    @IBOutlet weak var viewDividerLine: UIView!
    @IBOutlet weak var constraintContainerViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var ctViewContainerLeading: NSLayoutConstraint!
    @IBOutlet weak var ctViewContainerTrailing: NSLayoutConstraint!

    weak var delegateYoutubeCardCell: YoutubeCardCellDelegate?
    weak var delegateLikeComment: LikeCommentDelegate?
    private var currRow = 0
    private var bullets: [Bullets]?
    private var swipeGesture = UISwipeGestureRecognizer()

    var isPlayWhenReady = false
    var langCode = ""
    var status = ""
    var isCommunityCell = false
    var isViewMoreReels = false

    var url: String = ""
    var urlThumbnail: String = "" {
        didSet {
            
            imgThumbnail.sd_setImage(with: URL(string: urlThumbnail), placeholderImage: nil)
        }
    }
    var articleID: String = ""
//    var imageGradient = UIImageView()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //View Processing Article
        viewDividerLine.theme_backgroundColor = GlobalPicker.dividerLineBG
        viewLoader.type = .ballSpinFadeLoader
        viewLoader.startAnimating()
        viewProcess.cornerRadius = viewProcess.frame.height / 2
        viewProcess.theme_backgroundColor = GlobalPicker.backgroundListColor
        lblProcessing.theme_textColor = GlobalPicker.textBWColor
        lblProcessing.text = NSLocalizedString("Processing...", comment: "")

        //Schedule Article
        viewSchdule.cornerRadius = viewSchdule.frame.height / 2
        lblScheduleTime.textColor = .white //GlobalPicker.textBWColor

        lblSource.theme_textColor = GlobalPicker.textBWColor
        lblTime.theme_textColor = GlobalPicker.textForYouSubTextSubColor
        lblAuthor.theme_textColor = GlobalPicker.textForYouSubTextSubColor
        
        viewPlaceholder.isHidden = false
        //self.imgPlay.isHidden = false
        activityLoader.stopAnimating()

//        self.videoPlayer.delegate = self
        videoPlayer.backgroundColor = .clear
        viewContainer.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor//GlobalPicker.backgroundColorHomeCell
        
//        imageGradient.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        imageGradient.frame = viewContainer.bounds
//        viewContainer.insertSubview(imageGradient, at: 0)
//        
//        imageGradient.isHidden = true
//        imageGradient.contentMode = .scaleToFill
//        imageGradient.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        
        viewContainer.layer.cornerRadius = 12
        //        self.layer.cornerRadius = 12
        
    //    self.theme_backgroundColor = GlobalPicker.backgroundColor
        //self.imgBG.roundCorners([.bottomLeft, .bottomRight], radius: 12)
        
//        self.viewCount.theme_backgroundColor = GlobalPicker.viewCountColor
//        //self.viewComment.theme_backgroundColor = GlobalPicker.viewCountColor
//        //self.viewLike.theme_backgroundColor = GlobalPicker.viewCountColor
        
        switch UIDevice().type {
        
        case .iPhone6, .iPhone7, .iPhone8, .iPhone6S, .iPhoneSE, .iPhoneSE2:
            lblSource.font = lblSource.font.withSize(11)
            break
            
        case .iPhone6Plus, .iPhone6SPlus, .iPhone7Plus, .iPhone8Plus:
            lblSource.font = lblSource.font.withSize(12)
            break
            
        case .iPhoneXR, .iPhoneXSMax:
            lblSource.font = lblSource.font.withSize(12)
            break
            
        case .iPhoneX, .iPhoneXS, .iPhone11Pro:
            lblSource.font = lblSource.font.withSize(12)
            break
            
        default:
            //For iphone 11 and 11 pro max
            lblSource.font = lblSource.font.withSize(12)
            break
            
        }
        
        
        DispatchQueue.main.async {
            
            if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: self.langCode) {
                DispatchQueue.main.async {
                    self.lblSource.semanticContentAttribute = .forceRightToLeft
                    self.lblSource.textAlignment = .right
                    self.lblTime.semanticContentAttribute = .forceRightToLeft
                    self.lblTime.textAlignment = .right
                    self.lblAuthor.semanticContentAttribute = .forceRightToLeft
                    self.lblAuthor.textAlignment = .right
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.lblSource.semanticContentAttribute = .forceLeftToRight
                    self.lblSource.textAlignment = .left
                    self.lblTime.semanticContentAttribute = .forceLeftToRight
                    self.lblTime.textAlignment = .left
                    self.lblAuthor.semanticContentAttribute = .forceLeftToRight
                    self.lblAuthor.textAlignment = .left
                    
                }
            }
            
        }
        
    }
    
    // MARK: - Actions
    @IBAction func didTapLikeButton(_ sender: Any) {
        self.delegateLikeComment?.didTapLikeButton(cell: self)
    }
    
    @IBAction func didTapCommentButton(_ sender: Any) {
        self.delegateLikeComment?.didTapCommentsButton(cell: self)
    }
    
    
    @IBAction func didTapVolume(_ sender: Any) {
        
        if SharedManager.shared.isAudioEnable {
            
            SharedManager.shared.isAudioEnable = false
            videoPlayer.mute()
            
        }
        else {
            
            SharedManager.shared.isAudioEnable = true
            videoPlayer.unMute()
            
        }
    }
    
    
    func resetYoutubeCard() {
        
        self.videoPlayer.pause()
        self.viewPlaceholder.isHidden = false
        //self.imgPlay.isHidden = false
        self.activityLoader.stopAnimating()
        self.isPlayWhenReady = false
//        self.viewCount.isHidden = true
    }
    
    func pauseYoutube(isPause: Bool) {
        
        if isPause {
            isPlayWhenReady = false
            self.videoPlayer.pause()
            
        }
        else {
            loadVideo()
            isPlayWhenReady = true
            self.videoPlayer.play()
            self.activityLoader.startAnimating()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.isPlayWhenReady {
                    self.videoPlayer.play()
                }
            }
        }
    }
    
    func setFocussedYoutubeView() {

        if SharedManager.shared.videoAutoPlay && status != Constant.newsArticle.ARTICLE_STATUS_SCHEDULED && status != Constant.newsArticle.ARTICLE_STATUS_PROCESSING {

            pauseYoutube(isPause: false)
            
        }
    }
    
    func setLikeComment(model: Info?) {
        
        /*
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
        imgComment.theme_image = GlobalPicker.commentDefaultImage
        lblCommentsCount.textColor = .gray
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
        
        */
    }
    
    
    func loadVideo() {
        
        videoPlayer.playerVars = [
            "playsinline": "1",
            "controls": "1",
            "rel" : "0",
            "cc_load_policy" : "0",
            "disablekb": "1",
            "modestbranding": "1",
            
            "autohide": "1",
            "autoplay": "0",
            //"controls": "0",
            "ps": "docs",
            "showinfo": "0",
            "color": "white",
            //"modestbranding": "1",
            "iv_load_policy": "3",
            //"playsinline": "1",
            //"rel": "0",
            "theme": "dark",
            "enablejsapi": "1",
            "mute": SharedManager.shared.isAudioEnable ? "0" : "1"
        ] as YouTubePlayerView.YouTubePlayerParameters
        
        videoPlayer.delegate = self
        videoPlayer.loadVideoID(url)
    }
    
    func setupSlideScrollView(bullets: [Bullets], row: Int) {
        
        self.viewPlaceholder.isHidden = false
        //self.imgPlay.isHidden = false
        self.activityLoader.stopAnimating()

        lblDummy.font = SharedManager.shared.getCardViewTitleFont()
        lblDummy.text = bullets.first?.data ?? ""
        lblDummy.sizeToFit()

        self.clvBullets.setContentOffset(.zero, animated: false)
//        self.viewCount.isHidden = true
        
        self.bullets?.removeAll()
        self.bullets = bullets
        self.currRow = row
        SharedManager.shared.bulletPlayer?.stop()
        SharedManager.shared.bulletPlayer?.currentTime = 0
    
        self.clvBullets.register(UINib(nibName: CELL_IDENTIFIER_BULLET, bundle: nil), forCellWithReuseIdentifier: CELL_IDENTIFIER_BULLET)
        self.clvBullets.delegate = self
        self.clvBullets.dataSource = self
        self.clvBullets.isUserInteractionEnabled = true
        self.clvBullets.tag = row
        
        DispatchQueue.main.async {
            self.clvBullets.reloadData()
        }
        //Pan Gestures
        let panLeft = PanDirectionGestureRecognizer(direction: .horizontal(.left), target: self, action: #selector(handlePanGesture(_:)))
        panLeft.cancelsTouchesInView = false
        viewGestures.addGestureRecognizer(panLeft)

        let panRight = PanDirectionGestureRecognizer(direction: .horizontal(.right), target: self, action: #selector(handlePanGesture(_:)))
        panRight.cancelsTouchesInView = false
        viewGestures.addGestureRecognizer(panRight)
        
        lblDuration.text = self.bullets?.first?.duration?.formatFromMilliseconds()
        
        
        //Swipe Gestures
//        let direction: [UISwipeGestureRecognizer.Direction] = [.left, .right]
//        for dir in direction {
//            self.swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeView(_:)))
//            self.swipeGesture.direction = dir
//            viewGestures.addGestureRecognizer(self.swipeGesture)
////            panUp.require(toFail: self.swipeGesture)
////            panDown.require(toFail: self.swipeGesture)
//            panLeft.require(toFail: self.swipeGesture)
//            panRight.require(toFail: self.swipeGesture)
//        }
    }
    
//    @objc func swipeView(_ sender: UISwipeGestureRecognizer) {
//
//        if sender.direction == .right {
//            print("swipe right")
//            self.delegateYoutubeCardCell?.handleSwipeLeftRightArticleDelegate(isLeftToRight: false)
//        }
//        else if sender.direction == .left {
//            print("swipe left")
//            self.delegateYoutubeCardCell?.handleSwipeLeftRightArticleDelegate(isLeftToRight: true)
//        }
//    }
    
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
}

//MARK:- UICollectionView Delegate And DataSource

extension YoutubeCardCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bullets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER_BULLET, for: indexPath) as? BulletCell else { return UICollectionViewCell() }
        
        cell.langCode = langCode
        if indexPath.row < (self.bullets?.count ?? 0), let bullet = self.bullets?[indexPath.row] {
            
            if indexPath.item == 0 {
                                
                cell.configCell(bullet: bullet.data ?? "", titleFont: SharedManager.shared.getCardViewTitleFont())
                lblDummy.font = SharedManager.shared.getCardViewTitleFont()
            }
            else {
                                
                cell.configCell(bullet: bullet.data ?? "", titleFont: SharedManager.shared.getCardViewBulletFont())
                lblDummy.font = SharedManager.shared.getCardViewBulletFont()
            }
            
            if isViewMoreReels {
                cell.lblBullet.textColor = .black
            }
            else {
                cell.lblBullet.theme_textColor = GlobalPicker.textBWColor
            }
            
            lblDummy.text = bullet.data ?? ""
            lblDummy.sizeToFit()
        }
        
        // Make sure layout subviews
        cell.layoutIfNeeded()
        return cell
    }
    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    //VERTICAL
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return 0 }
    
    //HORIZONTAL
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return 0 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

extension YoutubeCardCell: YouTubePlayerDelegate {
    
    
    func playerUpdateCurrentTime(_ videoPlayer: YouTubePlayerView, time: String) {
        
        if SharedManager.shared.isAudioEnable && videoPlayer.isMuted {
            SharedManager.shared.isAudioEnable = false
        }
        if SharedManager.shared.isAudioEnable == false && videoPlayer.isMuted == false {
            SharedManager.shared.isAudioEnable = true
        }
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        
//        disableYoutubePlayerControls()
        print("\(#function)")
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleViewed, eventDescription: "", article_id: articleID)
        //self.imgThumbnail.isHidden = true
//        videoPlayer.getDuration(completion: { (duration) in
//            //self.lblDuration.text = "\(String(describing: duration))"
//            //print("getDuration", String(describing: duration))
//            self.lblDuration.text = duration?.stringFromTimeInterval()
//        })
        print("playerViewDidBecomeReady isPlayWhenReady", isPlayWhenReady)
        if self.isPlayWhenReady && SharedManager.shared.viewSubCategoryIshidden {
            videoPlayer.play()
        }
    }
    
//    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
//        return MyThemes.current == .dark ? .black : .white
//    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        
        if playerState == .Paused {
            activityLoader.stopAnimating()
            
            if isCommunityCell  {
                btnReport.isHidden = false
            }
            //self.imgPlay.isHidden = false
        }
        else if playerState == .Ended {
            //self.imgPlay.isHidden = false
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoDurationEvent, eventDescription: "", article_id: articleID, duration: MediaManager.sharedInstance.player?.currentTime?.formatToMilliSeconds() ?? "")

            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoFinishedPlaying, eventDescription: "", article_id: articleID)
            
//            self.delegateYoutubeCardCell?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
        else if playerState == .Playing {
            viewPlaceholder.isHidden = true
            
            if isCommunityCell  {
                btnReport.isHidden = true
            }
            
            videoPlayer.getCurrentTime(completion: { time in
                
                if time == 0 {
                    if SharedManager.shared.isAudioEnable {
                        videoPlayer.unMute()
                    } else {
                        videoPlayer.mute()
                    }
                }
                
            })
            
        }
        else if playerState == .Unstarted {
            viewPlaceholder.isHidden = true
        }
    }
    
//    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
//
//        self.imgThumbnail.isHidden = true
//    }
//
//    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
//        return MyThemes.current == .dark ? .black : .white
//    }
//
//    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
//        print("playerViewPreferredInitialLoading")
//        return nil
//    }
    
}
