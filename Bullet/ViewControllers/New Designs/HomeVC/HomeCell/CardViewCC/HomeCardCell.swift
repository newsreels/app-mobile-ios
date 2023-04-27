//
//  HomeCardCell.swift
//  Bullet
//
//  Created by Mahesh on 13/04/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreHaptics
import SwiftyGif
import NVActivityIndicatorView

internal let CELL_IDENTIFIER_HOME_CARD              = "HomeCardCell"


protocol HomeCardCellDelegate: AnyObject {
    
    func handleLongPressHold(_ gestureRecognizer: UILongPressGestureRecognizer)
    func autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: Bool)
    func layoutUpdate()
    func didTapCardCellFollow(cell: HomeCardCell)
    
}

class HomeCardCell: UITableViewCell {
    
    //PROPERTIES
    @IBOutlet weak var viewImgBG: UIView!
    @IBOutlet weak var clvBullets: UICollectionView!
//    @IBOutlet weak var imgDot: UIImageView!
//    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSource: UIButton!
//    @IBOutlet weak var imgWifi: UIImageView!
//    @IBOutlet weak var viewGradientShadow: UIView!
//    @IBOutlet weak var viewSingleDot: UIView!
    
    @IBOutlet weak var viewBlurBG: UIView!
    @IBOutlet weak var imgBG: UIImageView!
    @IBOutlet weak var imgPreLoaded: UIImageView!
    @IBOutlet weak var imgPreLoaded1: UIImageView!
    @IBOutlet weak var imgBlurBG: UIImageView!
//    @IBOutlet weak var imgVolumeAnimation: UIImageView!
//    @IBOutlet weak var imgVolumeStopAnimation: UIImageView!
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSource: UILabel!
//    @IBOutlet weak var lblAuthor: UILabel!
//    @IBOutlet weak var viewSegmentProgress: UIView!
    @IBOutlet weak var viewDividerLine: UIView!
    @IBOutlet weak var constraintContainerViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var lblDummy: UILabel!
    
//    @IBOutlet weak var viewCount: UIView!
//    @IBOutlet weak var lblViewCount: UILabel!
    
//    @IBOutlet var lblCollection: [UILabel]!
    @IBOutlet weak var btnVolume: UIButton!
    @IBOutlet weak var viewGestures: UIView!
    
    @IBOutlet weak var visualDarkViewBG: UIVisualEffectView!
    @IBOutlet weak var visualLightViewBG: UIVisualEffectView!
//    @IBOutlet weak var viewFooter: UIView!

    // Animation view Outlets and varibale
    @IBOutlet weak var imgNext: UIImageView!
    @IBOutlet weak var imgPrevious: UIImageView!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var constraintArcHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintBulletLableHeight: NSLayoutConstraint!
//    @IBOutlet weak var constraintViewTimeBottom: NSLayoutConstraint!
//
//    @IBOutlet weak var viewComment: UIView!
//    @IBOutlet weak var viewLike: UIView!
//    @IBOutlet weak var lblCommentsCount: UILabel!
//    @IBOutlet weak var lblLikeCount: UILabel!
//    @IBOutlet weak var imgLike: UIImageView!
//    @IBOutlet weak var imgComment: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    
    
    // Segment Progress Bar Constraints
//    @IBOutlet weak var progressbarBottom: NSLayoutConstraint!
//    @IBOutlet weak var progressbarTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var progressbarHeightConstraint: NSLayoutConstraint!
    
    //View Processing Upload Article by User
    @IBOutlet weak var viewProcessingBG: UIView!
    @IBOutlet weak var viewLoader: NVActivityIndicatorView!
    @IBOutlet weak var viewProcess: UIView!
    @IBOutlet weak var lblProcessing: UILabel!
    
    //View Schedule Upload Article by User
    @IBOutlet weak var viewScheduleBG: UIView!
    @IBOutlet weak var viewSchdule: UIView!
    @IBOutlet weak var lblScheduleTime: UILabel!
    
    @IBOutlet weak var ctContainerViewLeading: NSLayoutConstraint!
    @IBOutlet weak var ctContainerViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var verifiedImage: UIImageView!
    @IBOutlet weak var btnReport: UIButton!
    
    @IBOutlet weak var timeSeparatorView: UIView!
    
    let progressbarTopConstraintNormal: CGFloat = 42
    let progressbarBottomNormal: CGFloat = 21
    let progressbarHeightConstraintNormal: CGFloat = 6
    
    
    var swipeGesture = UISwipeGestureRecognizer()
    weak var delegateHomeCard: HomeCardCellDelegate?
    weak var delegateLikeComment: LikeCommentDelegate?
    var bullets: [Bullets]?
    var isCommunityCell = false
    var isViewMoreReels = false
    
    //VARIABLES
    var isAutoScrolling = true
    var mp3Duration = 5.0
    private var longPressGesture = UILongPressGestureRecognizer()
    var currRow = 0
    var currPage = 0
    var currMutedPage = 0
    private var generator = UIImpactFeedbackGenerator()
    var langCode = ""
    var isMuted: Bool = true
    
//    var imageGradient = UIImageView()
    @IBOutlet var cellContainerView: UIView!
//    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var lblShare: UILabel!
    @IBOutlet weak var imgShare: UIImageView!
    @IBOutlet weak var imgMoreOptions: UIImageView!
    
//    @IBOutlet weak var followButton: UIButton!
//    @IBOutlet weak var viewFollowing: UIView!
    
    
    var bulletsMaxHeightIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblSource.isHidden = true
        //View Processing Article
        cellContainerView.backgroundColor = .clear
        viewContainer.backgroundColor = .white
        //theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        //= GlobalPicker.backgroundCardColor
        viewLoader.type = .ballSpinFadeLoader
        viewLoader.startAnimating()
        viewProcess.cornerRadius = viewProcess.frame.height / 2
        viewProcess.theme_backgroundColor = GlobalPicker.backgroundListColor
        lblProcessing.theme_textColor = GlobalPicker.textBWColor
        lblProcessing.text = NSLocalizedString("Processing...", comment: "")
        viewDividerLine.theme_backgroundColor = GlobalPicker.dividerLineBG

        //Schedule Article
        viewSchdule.cornerRadius = viewSchdule.frame.height / 2
        lblScheduleTime.textColor = .white
//        self.lblTime.theme_textColor = GlobalPicker.textForYouSubTextSubColor
//        self.lblAuthor.theme_textColor = GlobalPicker.textForYouSubTextSubColor
        
//        self.lblCollection.forEach {
//            $0.theme_textColor = GlobalPicker.textSourceColor
//        }
//        lblSource.theme_textColor = GlobalPicker.textBWColor
        
        self.clvBullets.decelerationRate = UIScrollView.DecelerationRate.fast
        self.viewContainer.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor//GlobalPicker.backgroundColorHomeCell

        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyAudioAndProgressBarStatus, object: nil)
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAudioAndProgressBarStatus(notification:)), name: Notification.Name.notifyAudioAndProgressBarStatus, object: nil)
        
        
        imgMoreOptions.theme_image = GlobalPicker.imgMoreOptions
        
//        imageGradient.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        imageGradient.frame = viewContainer.bounds
//        self.viewContainer.insertSubview(imageGradient, at: 0)
//
//        imageGradient.isHidden = true
//        imageGradient.contentMode = .scaleToFill
//        imageGradient.backgroundColor = .clear
    }
    
//    override func prepareForReuse() {
//        
//        
//    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        viewContainer.layer.cornerRadius = 12
        
        viewImgBG.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        
//        imgWifi.layer.cornerRadius = imgWifi.frame.size.width/2
        if MyThemes.current == .dark {
            visualDarkViewBG.isHidden = false
            visualLightViewBG.isHidden = true
        }
        else {
            visualDarkViewBG.isHidden = true
            visualLightViewBG.isHidden = false
        }
        
        // viewFooter color
        //viewFooter.backgroundColor = MyThemes.current == .dark ? .clear : .white
//        self.viewCount.theme_backgroundColor = GlobalPicker.viewCountColor
//        //self.viewComment.theme_backgroundColor = GlobalPicker.viewCountColor
//        //self.viewLike.theme_backgroundColor = GlobalPicker.viewCountColor
        
//        viewBlurBG.theme_backgroundColor = GlobalPicker.backgroundColor
        //self.theme_backgroundColor = GlobalPicker.backgroundColor
        /*
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
        */
        
        
//        SharedManager.shared.spbCardView?.topColor = MyThemes.current == .dark ? "#E01335".hexStringToUIColor() : "#FA0815".hexStringToUIColor()
//        SharedManager.shared.spbCardView?.bottomColor = MyThemes.current == .dark ? UIColor.white.withAlphaComponent(0.30) : UIColor.black.withAlphaComponent(0.30)
        
        clvBullets.collectionViewLayout.invalidateLayout()
        
        if SharedManager.shared.isSelectedLanguageRTL() {
//            viewSegmentProgress.transform = CGAffineTransform(scaleX: -1, y: 1)
            btnRight.transform = CGAffineTransform(scaleX: -1, y: -1)
            btnLeft.transform = CGAffineTransform(scaleX: -1, y: -1)
            
        } else {
//            viewSegmentProgress.transform = CGAffineTransform(scaleX: 1, y: 1)
            btnRight.transform = CGAffineTransform(scaleX: 1, y: 1)
            btnLeft.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    
    // MARK: - Actions
    @IBAction func didTapLikeButton(_ sender: Any) {
        self.delegateLikeComment?.didTapLikeButton(cell: self)
    }
    
    @IBAction func didTapCommentButton(_ sender: Any) {
        self.delegateLikeComment?.didTapCommentsButton(cell: self)
    }
        
    //MARK:- Notification Action
    @objc func updateAudioAndProgressBarStatus( notification: NSNotification) {
                
        self.pauseAudioAndProgress(isPause: SharedManager.shared.isPauseAudio)
    }
    
    
    
    func updateCardVloumeStatus() {
        
//        do {
//            let gif = try UIImage(gifName: "equalizer")
//            self.imgVolumeAnimation.setGifImage(gif)
//        } catch {
//            print(error)
//        }

        if SharedManager.shared.isAudioEnable {
            
            SharedManager.shared.isVolumeOn = true
            print("print 15...")
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.volume = 1.0
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
      
            let bullets = SharedManager.shared.articleOnVolume.bullets
            
            if SharedManager.shared.bulletCurrentIndex < bullets?.count ?? 0, let urlstring = bullets?[SharedManager.shared.bulletCurrentIndex].audio, let URLStr = URL(string: urlstring), !urlstring.isEmpty {
                
                self.currPage = SharedManager.shared.bulletCurrentIndex
                if  bullets?[self.currPage].duration == 0 {
                    
                    self.mp3Duration = self.mp3fileTimeDuration(urlStr: URLStr)
                }
                else {
                    
                    if var duration = bullets?[self.currPage].duration {
                        
                        duration = duration / 1000
                        self.mp3Duration = duration / SharedManager.shared.localReadingSpeed
                    }
                }
                if SharedManager.shared.isAudioMuted  == false {
                    
                    self.downloadFileFromURL(url: urlstring)
                }
            }
        }
        else {
            
            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
//            self.imgVolumeAnimation.showFrameAtIndex(0)
//            self.imgVolumeAnimation.stopAnimatingGif()
//            self.imgVolumeAnimation.isHidden = true
//            self.imgVolumeStopAnimation.isHidden = false
            SharedManager.shared.isAudioEnable = false
            SharedManager.shared.bulletPlayer?.volume = 0.0
        }
    }
    
   // @objc func didTapVolume( notification: NSNotification) {}
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
//        if gestureRecognizer.state == .began {
//
//            if SharedManager.shared.isAudioMuted == false {
//
//                SharedManager.shared.bulletPlayer?.pause()
//            }
//            SharedManager.shared.isLongPressed = true
////        }
//        if gestureRecognizer.state == .ended {
//
//            if SharedManager.shared.isAudioMuted == false {
//
//                SharedManager.shared.bulletPlayer?.play()
//            }
//            SharedManager.shared.isLongPressed = false
////        }
        
        self.delegateHomeCard?.handleLongPressHold(gestureRecognizer)
    }
    
    
    override func prepareForReuse() {
        
        self.bulletsMaxHeightIndex = 0
        //REMOVE SWIPE GESTURE
        SharedManager.shared.segementIndex = 0
        self.currPage = 0
        SharedManager.shared.isUserinteractWithHeadlinesOnly = false
        
        
        self.bullets = [Bullets]()
        //
        clvBullets.reloadData()
        
    }
    
    func resetVisibleCard() {
        
        //we will reset all values
//        if let gestures = self.viewGestures.gestureRecognizers {
//            for gesture in gestures {
//                if gesture == longPressGesture {
//                    gesture.isEnabled = false
//                }
//            }
//        }
        
        self.bulletsMaxHeightIndex = 0
        //REMOVE SWIPE GESTURE
        SharedManager.shared.segementIndex = 0
        self.currPage = 0
        SharedManager.shared.isUserinteractWithHeadlinesOnly = false
        
        
//        self.viewSegmentProgress.isHidden = true
//        constraintViewTimeBottom.constant = 0
//        self.viewCount.isHidden = true
        self.btnVolume.isHidden = true
//        self.imgVolumeAnimation.showFrameAtIndex(0)
//        self.imgVolumeAnimation.stopAnimatingGif()
//        self.imgVolumeAnimation.clear()
//        self.imgVolumeAnimation.image = nil
//        self.imgVolumeAnimation.isHidden = true
//        self.imgVolumeStopAnimation.isHidden = true
        
        self.lblDummy.text = self.bullets?.first?.data ?? ""
        
        let point = CGPoint(x: 0, y: self.clvBullets.contentOffset.y)
        self.clvBullets.setContentOffset(point, animated: false)
        
        self.layoutIfNeeded()
        self.clvBullets.reloadData()
        
    }
    
    func setLikeComment(model: Info?) {
        
        /*
        if model?.isLiked ?? false {
            //viewLike.theme_backgroundColor = GlobalPicker.themeCommonColor
            imgLike.theme_image = GlobalPicker.likedImage
//            lblLikeCount.theme_textColor = GlobalPicker.likeCountColor
        } else {
            //self.viewLike.theme_backgroundColor = GlobalPicker.viewCountColor
            imgLike.theme_image = GlobalPicker.likeDefaultImage
        }
        //.textColor = .gray
        lblCommentsCount.theme_textColor = GlobalPicker.textBWColor
        lblLikeCount.theme_textColor = GlobalPicker.textBWColor
        lblShare.theme_textColor = GlobalPicker.textBWColor
        
        //self.viewComment.theme_backgroundColor = GlobalPicker.viewCountColor
        imgShare.theme_image = GlobalPicker.commonShare
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
        */
        
    }
    
    func setFollowingUI(model: articlesData) {
        
        if let source = model.source {
            
            if source.isShowingLoader == true {
//                followButton.showLoader()
            }
            else {
//                followButton.hideLoaderView()
            }
            
            if source.favorite ?? false {
//                viewFollowing.isHidden = true
            }
            else {
//                viewFollowing.isHidden = false
            }
            
        }
        else if let author = model.authors?.first {
            
            if author.isShowingLoader == true {
//                followButton.showLoader(size: CGSize(width: 35, height: 35))
            }
            else {
//                followButton.hideLoaderView()
            }
            
            if author.favorite ?? false {
//                viewFollowing.isHidden = true
            }
            else {
//                viewFollowing.isHidden = false
            }
            
        }
        else {
//            followButton.hideLoaderView()
//            viewFollowing.isHidden = true
        }
        
    }
    
    
    func setupSlideScrollView(article: articlesData, isAudioPlay: Bool, row: Int, isMute: Bool) {
        
        if let source = article.source {
            
            let sourceURL = source.icon ?? ""
//            self.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            self.lblSource.text = source.name ?? ""
        }
        else {
            
            let url = article.authors?.first?.image ?? ""
//            self.imgWifi?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
            self.lblSource.text = article.authors?.first?.username ?? article.authors?.first?.name ?? ""
        }
//        self.lblSource.addTextSpacing(spacing: 2.0)

        
        let author = article.authors?.first?.username ?? article.authors?.first?.name ?? ""
        let source = article.source?.name ?? ""
//        if author == ""  && source == "" {
//            lblAuthor.text = ""
//            timeSeparatorView.isHidden = true
//        }
//        else {
//            timeSeparatorView.isHidden = false
//            
//            lblAuthor.text = "by \(author.isEmpty ? source :  author)"
//        }
        
//        lblAuthor.text = ""
//        timeSeparatorView.isHidden = true
        
        setFollowingUI(model: article)
        
        if let pubDate = article.publish_time {
            self.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
        }
//        self.lblTime.addTextSpacing(spacing: 0.5)
        
        setLikeComment(model: article.info)
        
        clvBullets.setContentOffset(.zero, animated: false)
        currRow = row
        currPage = 0
        currMutedPage = 0
        btnVolume.isHidden = true
//        imgVolumeAnimation.isHidden = true
        clvBullets.isHidden = false
        isMuted = isMute
        self.bulletsMaxHeightIndex = 0
//        viewSegmentProgress.isHidden = true
//        self.viewCount.isHidden = true
        
        self.bullets?.removeAll()
        self.bullets = article.bullets
        if self.bullets?.count == 0 {return}
        lblDummy.text = self.bullets?.first?.data
        lblDummy.font = SharedManager.shared.getCardViewTitleFont()
        lblDummy.sizeToFit()
//        lblDummy.theme_textColor = GlobalPicker.bgBlackWhiteColor
        
        let url = article.image ?? ""
        imgBlurBG?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        
        imgBG.contentMode = .scaleAspectFill
        imgBG.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"), completed: { (image, error, cacheType, imageURL) in
            
            if image == nil {
                
                self.imgBG.accessibilityIdentifier = "image_placeholder"
            }
            else {
                
                self.imgBG.accessibilityIdentifier = ""
                self.imgBG.contentMode = .scaleAspectFill
                self.imgBG.image = image
            }
        })

                
        self.clvBullets.register(UINib(nibName: CELL_IDENTIFIER_BULLET, bundle: nil), forCellWithReuseIdentifier: CELL_IDENTIFIER_BULLET)
        self.clvBullets.delegate = self
        self.clvBullets.dataSource = self
        self.clvBullets.tag = row
                        
        DispatchQueue.main.async {
            self.clvBullets.reloadData()
        }
        
        //Long press Gesture for active cell
        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        self.longPressGesture.numberOfTouchesRequired = 1
        self.longPressGesture.minimumPressDuration = 0.2 // 1 second press
        self.longPressGesture.view?.tag = self.currRow
        self.longPressGesture.delegate = self
        self.viewGestures.addGestureRecognizer(self.longPressGesture)

                
        let status = article.status ?? ""
        if isAudioPlay && status != Constant.newsArticle.ARTICLE_STATUS_SCHEDULED && status != Constant.newsArticle.ARTICLE_STATUS_PROCESSING {
            
            //VOLUMN MUTE/UNMUTE
            SharedManager.shared.isAudioMuted = isMute

            
            self.btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)


            if article.bullets?.first?.audio == nil || article.bullets?.first?.audio == "" {
                self.btnVolume.isHidden = true
//                self.imgVolumeAnimation.isHidden = true
//                self.imgVolumeStopAnimation.isHidden = true
            } else {
                self.btnVolume.isHidden = isMute
//                self.imgVolumeAnimation.isHidden = isMute
            }
            
            self.btnVolume.alpha = SharedManager.shared.isAudioMuted ? 0.5 : 1.0
            NotificationCenter.default.post(name: Notification.Name.notifyAudioEnableStatus, object: nil)
            
            SharedManager.shared.segementIndex = 0

//            self.viewSegmentProgress.isHidden = false
//            self.viewCount.isHidden = false
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleViewed, eventDescription: "", article_id: article.id ?? "")
            SharedManager.shared.performWSToUpdateArticleAnalytics(ArticleId: article.id ?? "", isFromReel: false)

            if let urlstring = self.bullets?[0].audio, let URLStr = URL(string: urlstring), !urlstring.isEmpty {

                if self.bullets?[0].duration == 0 {

                    self.mp3Duration = self.mp3fileTimeDuration(urlStr: URLStr)
                }
                else {

                    if var duration = self.bullets?[0].duration {

                        duration = duration / 1000
                        self.mp3Duration = (duration / SharedManager.shared.localReadingSpeed) + 1.0
                    }
                }
                
            }
            else {

                self.mp3Duration = 7
                
            }
            
            self.currPage = 0

            DispatchQueue.main.async {
                
                if SharedManager.shared.isAudioMuted  == false {
                    
                    if let urlstring = self.bullets?[0].audio, !urlstring.isEmpty {

                        self.downloadFileFromURL(url: urlstring)
                    }
                }
            }
        }
    }
    
    func mp3fileTimeDuration(urlStr: URL) -> Double {
        
        //Segment Duration
        let audioAsset = AVURLAsset.init(url: urlStr, options: nil)
        let duration = audioAsset.duration
        let durationInSeconds = CMTimeGetSeconds(duration)
        let doubleStr = String(format: "%.1f", durationInSeconds)
        let timeInDouble = Double(doubleStr) ?? 10.0
        let timeWithSpeed = timeInDouble / SharedManager.shared.localReadingSpeed
        return timeWithSpeed
    }
    
    func downloadFileFromURL(url: String) {
        
        var downloadTask: URLSessionDownloadTask
        
        if let url = URL(string: url) {
            
            downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (URL, response, error) -> Void in
                if error != nil {
                    SharedManager.shared.bulletPlayer = nil
                }
                if let downloadURL = URL {
                    
                    if SharedManager.shared.articleURLPageLoaded == false && SharedManager.shared.viewSubCategoryIshidden {
                        print("audio playing downloaded 03")
                     //   SharedManager.shared.spbCardView?.isPaused = false
                        self.play(url: downloadURL)
                    }
                }
            })
            downloadTask.resume()
        }
    }
    
    func play(url: URL) {
        
        //playing
        do {
            
            print("print 8...")
            SharedManager.shared.bulletPlayer?.pause()
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer = nil
            
            SharedManager.shared.bulletCurrentIndex = self.currPage
            
            let session = AVAudioSession.sharedInstance()
            //_ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .duckOthers)
            _ = try? session.setCategory(.playback, mode: .default, options: .mixWithOthers)
            
            SharedManager.shared.bulletPlayer = try AVAudioPlayer(contentsOf: url)
            SharedManager.shared.bulletPlayer?.enableRate = true
            SharedManager.shared.bulletPlayer?.rate = self.speedRate()
            if SharedManager.shared.isAudioEnable {
                
                SharedManager.shared.bulletPlayer?.volume = 1.0
            }
            else {
                
                SharedManager.shared.bulletPlayer?.volume = 0.0
            }
            SharedManager.shared.bulletPlayer?.prepareToPlay()
            SharedManager.shared.bulletPlayer?.play()
            
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
        }
    }
    
    func playAudio() {
        
        SharedManager.shared.bulletCurrentIndex = self.currPage
        var urlstring = ""
        
        if let bullets = self.bullets {
            
            if bullets.count > 0 {
                
                if self.currPage <= bullets.count {
                    
                    urlstring = bullets[self.currPage].audio ?? ""
                }
                
                if let URL = URL(string: urlstring), !urlstring.isEmpty  {
                    
                    if  bullets[self.currPage].duration == 0 {
                        
                        self.mp3Duration = self.mp3fileTimeDuration(urlStr: URL)
                    }
                    else {
                        
                        if var duration = bullets[self.currPage].duration {
                            
                            duration = duration / 1000
                            self.mp3Duration = duration / SharedManager.shared.localReadingSpeed
                        }
                    }
                    
                }
                else {
                    
                    
                }
                
                if !urlstring.isEmpty {
                    
                    if SharedManager.shared.isAudioEnable {
                        
                        if SharedManager.shared.isAudioMuted == false {
                            
                            self.downloadFileFromURL(url: urlstring)
                        }
                    }
                    else {
                        
                        print("print 9...")
                        SharedManager.shared.bulletPlayer?.pause()
                        SharedManager.shared.bulletPlayer?.stop()
                    }
                }
            }
        }
    }
    
    func updateCardViewVolumeStatus() {
    
        if SharedManager.shared.isAudioEnable {
            
            
            SharedManager.shared.bulletPlayer?.volume = 1.0
            SharedManager.shared.isVolumeOn = true
            SharedManager.shared.bulletPlayer?.stop()
            print("print 16...")
            
            let bullets = SharedManager.shared.articleOnVolume.bullets
            if SharedManager.shared.bulletCurrentIndex < bullets?.count ?? 0, let urlstring = bullets?[SharedManager.shared.bulletCurrentIndex].audio, let URLStr = URL(string: urlstring), !urlstring.isEmpty {
                
                self.currPage = SharedManager.shared.bulletCurrentIndex
                if  bullets?[self.currPage].duration == 0 {
                    
                    self.mp3Duration = self.mp3fileTimeDuration(urlStr: URLStr)
                }
                else {
                    
                    if var duration = bullets?[self.currPage].duration {
                        
                        duration = duration / 1000
                        self.mp3Duration = duration / SharedManager.shared.localReadingSpeed
                    }
                }
                if SharedManager.shared.isAudioMuted  == false {
                    
                    self.downloadFileFromURL(url: urlstring)
                }
            }
        }
        else {
            
            SharedManager.shared.bulletPlayer?.volume = 0.0
        }
    }
    
    @IBAction func didTapFollow(_ sender: Any) {
        
        self.delegateHomeCard?.didTapCardCellFollow(cell: self)
    }
    
    
    @IBAction func didTapVolume(_ sender: UIButton) {
        
        if SharedManager.shared.isAudioMuted == true {
            
//            self.parentViewController?.showAlertLoader(message: <#T##String#>)
            return
        }
        
        SharedManager.shared.isDeviceVolume = false
        if SharedManager.shared.isAudioEnable {
            
            //volume off
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.mute, eventDescription: "")
//            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
//            self.imgVolumeAnimation.stopAnimatingGif()
//            self.imgVolumeAnimation.isHidden = true
//            self.imgVolumeStopAnimation.isHidden = false
            SharedManager.shared.isAudioEnable = false
        }
        else {
            
            //volume on
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unmute, eventDescription: "")
            SharedManager.shared.isAudioEnable = true
//            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
//            do {
//                let gif = try UIImage(gifName: "equalizer")
//                self.imgVolumeAnimation.setGifImage(gif)
//            } catch {
//                print(error)
//            }
        }
        
        SharedManager.shared.isVolumeOn = false
        //NotificationCenter.default.post(name: Notification.Name.notifyHomeVolumn, object: nil)
        
//        if SharedManager.shared.isVolumnOffCard == true {
//            return
//        }
//
//        do {
//            let gif = try UIImage(gifName: "equalizer")
//            self.imgVolumeAnimation.setGifImage(gif)
//        } catch {
//            print(error)
//        }
//        self.imgVolumeAnimation.startAnimatingGif()
//        self.imgVolumeAnimation.isHidden = false
//        self.imgVolumeStopAnimation.isHidden = true
        
        if SharedManager.shared.isAudioEnable {
            
            
            if SharedManager.shared.isVolumeOn {
                
                return
            }
        //    SharedManager.shared.isAudioEnable = false
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)

            SharedManager.shared.isVolumeOn = true
            print("print 17...")
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.volume = 1.0

            //let bullets = SharedManager.shared.articleOnVolume.bullets
            if SharedManager.shared.bulletCurrentIndex < bullets?.count ?? 0, let urlstring = self.bullets?[SharedManager.shared.bulletCurrentIndex].audio, let URLStr = URL(string: urlstring), !urlstring.isEmpty {
                
                self.currPage = SharedManager.shared.bulletCurrentIndex
                if self.bullets?[self.currPage].duration == 0 {
                    
                    self.mp3Duration = self.mp3fileTimeDuration(urlStr: URLStr)
                }
                else {
                    
                    if var duration = bullets?[self.currPage].duration {
                        
                        duration = duration / 1000
                        self.mp3Duration = duration / SharedManager.shared.localReadingSpeed
                    }
                }
                if SharedManager.shared.isAudioMuted  == false {
                    
                    self.downloadFileFromURL(url: urlstring)
                }
            }
        }
        else {
            
            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
//            self.imgVolumeAnimation.showFrameAtIndex(0)
//            self.imgVolumeAnimation.stopAnimatingGif()
//            self.imgVolumeAnimation.isHidden = true
//            self.imgVolumeStopAnimation.isHidden = false
  //          SharedManager.shared.isAudioEnable = true
            SharedManager.shared.bulletPlayer?.volume = 0.0
        }
    }
    
    func pauseAudioAndProgress(isPause:Bool) {
        
        if isPause {
   
            print("print 10...")
            SharedManager.shared.bulletPlayer?.pause()
        }
        else {

            if bullets?.first?.audio == nil || bullets?.first?.audio == "" {
                SharedManager.shared.bulletPlayer = nil
            }
            else {
                if SharedManager.shared.isAudioMuted == false {
                    
                    SharedManager.shared.bulletPlayer?.play()
                }
            }
        }
    }
    
    func swipeRightFocusedCell(bullets: [Bullets], tag: Int) {
        
        if self.currPage > 0 {
            
            if self.currPage < bullets.count {
                
                self.currPage -= 1
                self.scrollToItemBullet(at: self.currPage, animated: true)
                self.playAudio()
                //SharedManager.shared.spbCardView?.rewind()
            }
            else {
                
                self.restartProgressbar()
            }
        }
        else {
//            if tag > 0 {
//                self.bulletsMaxHeightIndex = 0
//                self.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: false)
//            }
//            else {
//                self.restartProgressbar()
//            }
        }
    }
    
    func swipeLeftFocusedCell(bullets: [Bullets]) {
        
        if self.currPage < bullets.count - 1 {
            
            self.currPage += 1
            self.scrollToItemBullet(at: self.currPage, animated: true)
            self.playAudio()
            //SharedManager.shared.spbCardView?.skip()
        }
        else {
            
            //self.restartProgressbar()
//            self.bulletsMaxHeightIndex = 0
//            self.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
    }
    
    func swipeRightNormalCell(bullets: [Bullets]) {
        
        self.forceRestartProgressbar {
            
            if self.currMutedPage > 0 {
                
                if self.currMutedPage < bullets.count {
                    
                    self.currMutedPage -= 1
                    self.currPage -= 1
                    self.scrollToItemBullet(at: self.currMutedPage, animated: true)
                    self.playAudio()
                    //SharedManager.shared.spbCardView?.rewind()
                }
                else {
                    
                    self.scrollToItemBullet(at: self.currMutedPage, animated: true)
                }
            }
            else {
                
                self.currMutedPage = 0
                self.currRow = 0
                self.scrollToItemBullet(at: self.currMutedPage, animated: false)
            }
        }
    }
    
    func swipeLeftNormalCell(bullets: [Bullets]) {
        
        self.forceRestartProgressbar {
            
            if self.currMutedPage < bullets.count - 1 {
                
                self.currMutedPage += 1
                self.currPage += 1
                self.scrollToItemBullet(at: self.currMutedPage, animated: true)
                self.playAudio()
                //SharedManager.shared.spbCardView?.skip()
            }
            else {
                self.currMutedPage = 0
                self.currRow = 0
                self.scrollToItemBullet(at: self.currMutedPage, animated: false)
            }
        }
    }
    
    @objc func autoScrollBullet() {
        
        print("print 11...")
        SharedManager.shared.bulletPlayer?.pause()
        SharedManager.shared.bulletPlayer?.stop()
 
        if let butteltsArr = self.bullets, butteltsArr.count > 0 {
            
            if self.currPage >= butteltsArr.count - 1  {
                
                self.restartProgressbar()
            }
            else {
                
                self.currPage += 1
                SharedManager.shared.segementIndex = self.currPage
                self.downloadAudio()
                self.scrollToItemBullet(at: self.currPage, animated: true)
            }
        }
        
        if isCommunityCell {
            btnReport.isHidden = self.currPage == 0 ? false : true
        }
    }
    
    func downloadAudio() {
        
        SharedManager.shared.bulletCurrentIndex = self.currPage
        var urlstring = ""
        
        if let bulletsArr = self.bullets, bulletsArr.count > 0 {
            
            if self.currPage <= bulletsArr.count {
                
                urlstring = bulletsArr[self.currPage].audio ?? ""
            }
            
            if let URL = URL(string: urlstring), !urlstring.isEmpty  {
                
                if  bulletsArr[self.currPage].duration == 0 {
                    
                    self.mp3Duration = self.mp3fileTimeDuration(urlStr: URL)
                }
                else {
                    
                    if var duration = bulletsArr[self.currPage].duration {
                        
                        duration = duration / 1000
                        self.mp3Duration = duration / SharedManager.shared.localReadingSpeed
                    }
                }
                
            }
            else {
                
                
            }
            if !urlstring.isEmpty {
                
                if SharedManager.shared.isAudioEnable {
                    
                    if SharedManager.shared.isAudioMuted  == false {
                        
                        self.downloadFileFromURL(url: urlstring)
                    }
                }
                else {
                    
                    print("print 12...")
                    SharedManager.shared.bulletPlayer?.pause()
                    SharedManager.shared.bulletPlayer?.stop()
                        }
            }
        }
    }
    
    func scrollToItemBullet(at index: Int, animated: Bool) {
        
        guard
            index >= 0,
            index < clvBullets.numberOfItems(inSection: 0)
        else { return }
        
        if let bulletsArr = self.bullets, let url = bulletsArr[index].image {
            
            self.imgBG.contentMode = .scaleAspectFill
            self.imgBG.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"), completed: { (image, error, cacheType, imageURL) in
                
                if image == nil {
                    
                    self.imgBG.accessibilityIdentifier = "image_placeholder"
                }
                else {
                    
                    self.imgBG.accessibilityIdentifier = ""
                    self.imgBG.contentMode = .scaleAspectFill
                    self.imgBG.image = image
                }
            })
        }
        
        var currentHight = 0
        if index > 0 {

            currentHight = self.bullets?[index - 1].data?.count ?? 0
            lblDummy.text = self.bullets?[index].data
            lblDummy.font = SharedManager.shared.getCardViewTitleFont()
        }
        
        UIView.animate(withDuration: 0.2) {

//            self.clvBullets.layoutIfNeeded()
//            self.clvBullets.layoutSubviews()

        } completion: { (finished) in

            var x: CGFloat = 0
            for _ in 0..<index {
                x += self.clvBullets.frame.width
            }

            let point = CGPoint(x: x, y: self.clvBullets.contentOffset.y)
            self.clvBullets.setContentOffset(point, animated: animated)

            if index != 0 {
                
                let newHeight = self.bullets?[index].data?.count ?? 0
                
                if newHeight > currentHight && newHeight > self.bulletsMaxHeightIndex {
                    
                    self.bulletsMaxHeightIndex = newHeight
                    self.delegateHomeCard?.layoutUpdate()
                }
            }
        }
    }
}

//MARK:- UICollectionView Delegate And DataSource

extension HomeCardCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bullets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER_BULLET, for: indexPath) as? BulletCell else { return UICollectionViewCell() }
                
        cell.langCode = langCode
        if indexPath.item < (self.bullets?.count ?? 0), let bullet = self.bullets?[indexPath.item] {
            
            if indexPath.item == 0 {
                                
                cell.configCell(bullet: bullet.data ?? "", titleFont: SharedManager.shared.getCardViewTitleFont())
                
                if isViewMoreReels {
                    cell.lblBullet.textColor = .black
                } else {
//                    cell.lblBullet.theme_textColor = GlobalPicker.textBWColor
                    //            cell.lblBullet.setLineSpacing(lineSpacing: 5)
                }
            }
            else {
                                
                cell.configCell(bullet: bullet.data ?? "", titleFont: SharedManager.shared.getCardViewBulletFont())
                
                if isViewMoreReels {
                    cell.lblBullet.textColor = .black
                } else {
//                    cell.lblBullet.theme_textColor = GlobalPicker.textBWColor
                }
            }
        }
        
        // Make sure layout subviews
        cell.layoutIfNeeded()
        return cell
    }
    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT Delegate
    
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

//MARK:- SegmentedProgressBar Delegate
extension HomeCardCell: SegmentedProgressBarDelegate {
    
    func segmentedProgressBarChangedIndex(index: Int) {
                
        SharedManager.shared.isManualScrolling = false
        if SharedManager.shared.showHeadingsOnly == "HEADLINES_ONLY" && SharedManager.shared.isUserinteractWithHeadlinesOnly == false  {
            
            //self.spb?.isPaused = true
//            self.bulletsMaxHeightIndex = 0
//            self.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
        else {
            
            //progress Delegate
            if isAutoScrolling {
                
             //   
                self.autoScrollBullet()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.mp3Duration - 1.0)) { [self] in
                
                self.isAutoScrolling = true
            }
        }
    }
    
    func segmentedProgressBarFinished() {
        
        SharedManager.shared.isManualScrolling = false
        if SharedManager.shared.showHeadingsOnly == "HEADLINES_ONLY" && SharedManager.shared.isUserinteractWithHeadlinesOnly == false  {
            
            self.bulletsMaxHeightIndex = 0
            self.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
        else {
            
            //Finish
            SharedManager.shared.segementIndex = 0
            self.bulletsMaxHeightIndex = 0
            self.delegateHomeCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
    }
    
    func forceRestartProgressbar(completionBlock: @escaping () -> ()) {

        
        
//        self.viewSegmentProgress.isHidden = false
        self.currPage = 0
        self.currMutedPage = 0
        SharedManager.shared.segementIndex = 0
        
        if let bulletsArr = self.bullets, bulletsArr.count > 0 {
            
            //VOLUMN MUTE/UNMUTE
            
//            do {
//                let gif = try UIImage(gifName: "equalizer")
//
//                if imgVolumeAnimation.isAnimating {
//
//                    self.imgVolumeAnimation.clear()
//                }
//                self.imgVolumeAnimation.setGifImage(gif)
//            } catch {
//                print(error)
//            }

//            self.imgVolumeAnimation.startAnimatingGif()
//            self.imgVolumeAnimation.isHidden = false
//            self.imgVolumeStopAnimation.isHidden = true

            SharedManager.shared.isAudioMuted = isMuted
            if SharedManager.shared.isAudioEnable {
                
                self.btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
            }
            else {
                
                self.btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
//                self.imgVolumeAnimation.showFrameAtIndex(0)
//                self.imgVolumeAnimation.stopAnimatingGif()
//                self.imgVolumeAnimation.clear()
//                self.imgVolumeAnimation.image = nil
//                self.imgVolumeAnimation.isHidden = true
//                self.imgVolumeStopAnimation.isHidden = false
            }

            if bullets?.first?.audio == nil || bullets?.first?.audio == "" {
                self.btnVolume.isHidden = true
//                self.imgVolumeAnimation.isHidden = true
//                self.imgVolumeStopAnimation.isHidden = true
            } else {
                self.btnVolume.isHidden = isMuted
//                self.imgVolumeAnimation.isHidden = isMuted
            }
            
            self.btnVolume.alpha = SharedManager.shared.isAudioMuted ? 0.5 : 1.0

            
            if bulletsArr.count > 0 {
                
                if let urlstring = bulletsArr[0].audio, !urlstring.isEmpty {
                    
                    if let URL = URL(string: urlstring) {
                        
                        if  bulletsArr[0].duration == 0 {
                            
                            self.mp3Duration = self.mp3fileTimeDuration(urlStr: URL)
                        }
                        else {
                            
                            if var duration = bulletsArr[0].duration {
                                
                                duration = duration / 1000
                                self.mp3Duration = duration / SharedManager.shared.localReadingSpeed
                            }
                        }
                            
                    }
                    else {
                        
                        
                        }
                }
                else {
                    
                    
                }
            }
            else { return }
            
            
            
//            SharedManager.shared.spbCardView?.frame = CGRect(x: 0, y: 0, width: self.viewSegmentProgress.frame.size.width, height: self.viewSegmentProgress.frame.size.height)
//            self.viewSegmentProgress.addSubview(SharedManager.shared.spbCardView!)
            
            
//            SharedManager.shared.spbCardView?.topColor = MyThemes.current == .dark ? "#E01335".hexStringToUIColor() : "#FA0815".hexStringToUIColor()
//            SharedManager.shared.spbCardView?.bottomColor = MyThemes.current == .dark ? UIColor.white.withAlphaComponent(0.30) : UIColor.black.withAlphaComponent(0.30)
            
            
            
            DispatchQueue.main.async {
                
//                UIView.animate(withDuration: 0.25) {
//                    self.constraintViewTimeBottom.constant = -24
//                }
                
                
                if SharedManager.shared.isAudioMuted  == false {
                    
                    if let urlstring = bulletsArr[0].audio, !urlstring.isEmpty {
                        
                        self.downloadFileFromURL(url: urlstring)
                    }
                }
                completionBlock()
            }
            
            //self.scrollToItemBullet(at: self.currPage, animated: true)
        }
    }
    
    func restartProgressbar() {
        
        
        
//        self.viewSegmentProgress.isHidden = false
        self.currPage = 0
        self.currMutedPage = 0
        SharedManager.shared.segementIndex = 0
        
        if let bulletsArr = self.bullets, bulletsArr.count > 0{
            
            if bulletsArr.count > 0 {
                
                if let urlstring = bulletsArr[0].audio, !urlstring.isEmpty {
                    
                    if let URL = URL(string: urlstring) {
                        
                        if  bulletsArr[0].duration == 0 {
                            
                            self.mp3Duration = self.mp3fileTimeDuration(urlStr: URL)
                        }
                        else {
                            
                            if var duration = bulletsArr[0].duration {
                                
                                duration = duration / 1000
                                self.mp3Duration = duration / SharedManager.shared.localReadingSpeed
                            }
                        }
                            
                    }
                    else {
                        
                        
                        }
                }
                else {
                    
                    
                }
            }
            else { return }
            
            
            
//            SharedManager.shared.spbCardView?.frame = CGRect(x: 0, y: 0, width: self.viewSegmentProgress.frame.size.width, height: self.viewSegmentProgress.frame.size.height)
//            self.viewSegmentProgress.addSubview(SharedManager.shared.spbCardView!)
            
            
//            SharedManager.shared.spbCardView?.topColor = MyThemes.current == .dark ? "#E01335".hexStringToUIColor() : "#FA0815".hexStringToUIColor()
//            SharedManager.shared.spbCardView?.bottomColor = MyThemes.current == .dark ? UIColor.white.withAlphaComponent(0.30) : UIColor.black.withAlphaComponent(0.30)
            
            
            
            DispatchQueue.main.async {
                
                
                
                if SharedManager.shared.isAudioMuted  == false {
                    
                    if let urlstring = bulletsArr[0].audio, !urlstring.isEmpty {
                        
                        self.downloadFileFromURL(url: urlstring)
                    }
                }
            }
            
            self.scrollToItemBullet(at: self.currPage, animated: true)
        }
    }
}

extension HomeCardCell {
    
    func speedRate() -> Float {
        
        let saveSpeed = SharedManager.shared.readingSpeed
        let allKeys = [String](SharedManager.shared.speedRate.keys)
        for key in allKeys {
            
            if key == saveSpeed {
                let value = SharedManager.shared.speedRate[key]
                SharedManager.shared.localReadingSpeed = value ?? 1.0
                return Float(value ?? 1)
            }
        }
        return 1.0
    }
}

//We are using arc images
extension UIImageView {
    
    func setImage(_ image: UIImage?, animated: Bool = true) {
        let duration = animated ? 0.3 : 0.0
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.image = image
        }, completion: nil)
    }
}
