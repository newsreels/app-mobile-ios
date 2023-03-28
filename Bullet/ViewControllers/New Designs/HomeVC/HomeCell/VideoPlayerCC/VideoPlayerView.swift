//
//  VideoPlayerVieww.swift
//  Bullet
//
//  Created by Khadim Hussain on 28/03/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import PlayerKit
import AVFoundation
import NVActivityIndicatorView

internal let CELL_IDENTIFIER_VIDEO_PLAYER           = "VideoPlayerVieww"

protocol VideoPlayerViewwDelegates: AnyObject {
    
    func resetSelectedArticle()
    func autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: Bool)
    func focusedIndex(index:Int)
    func didSelectCell(cell: VideoPlayerVieww)
    
    
    func didTapVideoPlayButton(cell: VideoPlayerVieww, isTappedFromCell: Bool)
    
}

@objc protocol LikeCommentDelegate: AnyObject {
    
    func didTapCommentsButton(cell: UITableViewCell)
    func didTapLikeButton(cell: UITableViewCell)
    func didTapCommentsButtonCollectionView(cell: UITableViewCell)
    func didTapLikeButtonCollectionView(cell: UITableViewCell)
}


class VideoPlayerVieww: UITableViewCell {
    
    @IBOutlet weak var btnSource: UIButton!
//    @IBOutlet weak var imgWifi: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSource: UILabel!
//    @IBOutlet weak var lblAuthor: UILabel!
//    @IBOutlet weak var btnShare: UIButton!
    
    @IBOutlet weak var lblVideoTime: UILabel!
    @IBOutlet weak var viewDuration: UIView!

    @IBOutlet weak var viewGestures: UIView!
    @IBOutlet weak var lblVideoBullet: UILabel!
    
    @IBOutlet weak var viewVideoBG: UIView!
    @IBOutlet weak var imgPlaceHolder: UIImageView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var ctVideoHeight: NSLayoutConstraint!
    
    //View Processing Upload Article by User
    @IBOutlet weak var viewProcessingBG: UIView!
    @IBOutlet weak var viewLoader: NVActivityIndicatorView!
    @IBOutlet weak var viewProcess: UIView!
    @IBOutlet weak var lblProcessing: UILabel!
    
    //View Schedule Upload Article by User
    @IBOutlet weak var viewScheduleBG: UIView!
    @IBOutlet weak var viewSchdule: UIView!
    @IBOutlet weak var lblScheduleTime: UILabel!

    
    @IBOutlet weak var viewDividerLine: UIView!
    @IBOutlet weak var constraintContainerViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var ctViewContainerLeading: NSLayoutConstraint!
    @IBOutlet weak var ctViewContainerTrailing: NSLayoutConstraint!
    @IBOutlet weak var imgPlayButton: UIImageView!
    
    @IBOutlet weak var timeSeparatorView: UIView!
    
//    @IBOutlet weak var lblCommentsCount: UILabel!
//    @IBOutlet weak var lblLikeCount: UILabel!
//    @IBOutlet weak var imgLike: UIImageView!
//    @IBOutlet weak var imgComment: UIImageView!
    
//    @IBOutlet weak var lblShare: UILabel!
//    @IBOutlet weak var imgShare: UIImageView!
    @IBOutlet weak var imgMoreOptions: UIImageView!
    
    @IBOutlet weak var shadowView: ShadowView!
    
    var bullets: [Bullets]?
    var swipeGesture = UISwipeGestureRecognizer()
    var videoRatio: CGFloat = 0
    var isCommunityCell = false
    var isViewMoreReels = false

    weak var delegate: VideoPlayerViewwDelegates?
    weak var delegateLikeComment: LikeCommentDelegate?
//    var isVideoPaused = false
//    var manualPlay = false
    var status = ""
    var videoThumbnail: String = "" {
        didSet {
            
            imgPlaceHolder.sd_setImage(with: URL(string: videoThumbnail), placeholderImage: nil)
        }
    }
    
//    var imageGradient = UIImageView()
    // Test
    var langCode = ""
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        //View Processing Article
        viewDividerLine.theme_backgroundColor = GlobalPicker.dividerLineBG
        viewLoader.type = .ballSpinFadeLoader
        viewLoader.stopAnimating()
        viewProcess.cornerRadius = viewProcess.frame.height / 2
        viewProcess.theme_backgroundColor = GlobalPicker.backgroundListColor
        lblProcessing.theme_textColor = GlobalPicker.textBWColor
        lblProcessing.text = NSLocalizedString("Processing...", comment: "")

        //Schedule Article
        viewSchdule.cornerRadius = viewSchdule.frame.height / 2
        lblScheduleTime.textColor = .white
        
//        imageGradient.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        imageGradient.frame = viewContainer.bounds
//        self.viewContainer.insertSubview(imageGradient, at: 0)
//
//        imageGradient.isHidden = true
//        imageGradient.contentMode = .scaleToFill
//        imageGradient.backgroundColor = .clear
        
        imgPlaceHolder.isUserInteractionEnabled = true
    }
    
    
    override func prepareForReuse() {
        
        viewLoader.stopAnimating()
//        self.activityIndicator.stopAnimating()
    }
    
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        layoutIfNeeded()
//    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        //print("viewVideoBG.frame.width:  \(contentView.frame.width)")
        
        viewContainer.layer.cornerRadius = 12
        viewGestures.roundCorners(corners: [.topLeft, .topRight], radius: 12)

//        imgWifi.layer.cornerRadius = imgWifi.frame.size.width/2
        
        if isViewMoreReels {
            viewContainer.backgroundColor = .white

            lblVideoBullet.textColor = .black
//            lblSource.textColor = .black
//            lblTime.textColor = "#84838B".hexStringToUIColor()
//            lblAuthor.textColor = "#84838B".hexStringToUIColor()
        }
        else {
            viewContainer.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor //GlobalPicker.backgroundColorHomeCell

            lblVideoBullet.theme_textColor = GlobalPicker.textBWColor
//            lblSource.theme_textColor = GlobalPicker.textBWColor
//            lblTime.theme_textColor = GlobalPicker.textForYouSubTextSubColor
//            lblAuthor.theme_textColor = GlobalPicker.textForYouSubTextSubColor
        }
        
        
//        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
//        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .highlighted)
        
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
        
        
        DispatchQueue.main.async {
            
            if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: self.langCode) {
                DispatchQueue.main.async {
                    self.lblVideoBullet.semanticContentAttribute = .forceRightToLeft
                    self.lblVideoBullet.textAlignment = .right
                    self.lblSource.semanticContentAttribute = .forceRightToLeft
                    self.lblSource.textAlignment = .right
                    self.lblTime.semanticContentAttribute = .forceRightToLeft
//                    self.lblTime.textAlignment = .right
//                    self.lblAuthor.semanticContentAttribute = .forceRightToLeft
//                    self.lblAuthor.textAlignment = .right
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.lblVideoBullet.semanticContentAttribute = .forceLeftToRight
                    self.lblVideoBullet.textAlignment = .left
                    self.lblSource.semanticContentAttribute = .forceLeftToRight
                    self.lblSource.textAlignment = .left
                    self.lblTime.semanticContentAttribute = .forceLeftToRight
                    self.lblTime.textAlignment = .left
//                    self.lblAuthor.semanticContentAttribute = .forceLeftToRight
//                    self.lblAuthor.textAlignment = .left
                    
                }
            }
            
        }
    }
    
    
    func setupSlideScrollView(bullets: [Bullets], article: articlesData, row: Int, isAutoPlay: Bool) {
        
        
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
        
        if let pubDate = article.publish_time {
            self.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
        }
//        self.lblTime.addTextSpacing(spacing: 0.5)
        
        
        setLikeComment(model: article.info)
        
        
        self.langCode = article.language ?? ""
        videoRatio = CGFloat((article.media_meta?.width ?? 1) / (article.media_meta?.height ?? 1))
        if videoRatio.isNaN {
            videoRatio = 1.7
        }

        var newHeight = (UIScreen.main.bounds.width - 40) / videoRatio
//        var newHeight = (UIScreen.main.bounds.width) / videoRatio
        newHeight = newHeight > (UIScreen.main.bounds.height * 0.7) ? UIScreen.main.bounds.height * 0.7 : newHeight
        ctVideoHeight.constant = newHeight
        
        status = article.status ?? ""
//        if let url = URL(string: article.link ?? "") {
//
//            self.player.pause()
//            self.player.seek(to: 0)
//            self.player.delegate = self
//
////            if let view = viewVideo.subviews.first(where: { $0 != self.player.view }) {
//                //print(view)
//                self.addPlayerToView()
////            }
//            self.player.set(AVURLAsset(url: url))
//        }
      
//        self.imgPlaceHolder.isHidden = false
        if SharedManager.shared.videoAutoPlay {
            self.imgPlaceHolder.contentMode = .scaleAspectFit
            self.videoControllerStatusOnCellSetup(isHidden: true)
            
        }
        else {
            self.imgPlaceHolder.contentMode = .scaleAspectFill
            self.videoControllerStatusOnCellSetup(isHidden: false)
        }
        
        if isAutoPlay {
            
//            if SharedManager.shared.isAudioEnable == false {
//
//                player.volume = 0
//                btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
//            }
//            else {
//
//                player.volume = 1
//                btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
//            }
            
//            self.slider.value = 0
//            player.seek(to: .zero)
            
            if SharedManager.shared.videoAutoPlay && status != Constant.newsArticle.ARTICLE_STATUS_SCHEDULED && status != Constant.newsArticle.ARTICLE_STATUS_PROCESSING {
//                self.activityIndicator.startAnimating()
//                player.play()
                self.videoControllerStatusOnCellSetup(isHidden: true)
            }
            else {
                
                self.videoControllerStatusOnCellSetup(isHidden: false)
            }
            SharedManager.shared.performWSToUpdateArticleAnalytics(ArticleId: article.id ?? "", isFromReel: false)
            
        }
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleViewed, eventDescription: "", article_id: article.id ?? "")

        lblVideoBullet.font = SharedManager.shared.getCardViewTitleFont()
        lblVideoBullet.text = bullets.first?.data ?? ""
        lblVideoBullet.sizeToFit()
        
        //Pan Gestures
        let panLeft = PanDirectionGestureRecognizer(direction: .horizontal(.left), target: self, action: #selector(handlePanGesture(_:)))
        panLeft.cancelsTouchesInView = false
        viewGestures.addGestureRecognizer(panLeft)
        
        let panRight = PanDirectionGestureRecognizer(direction: .horizontal(.right), target: self, action: #selector(handlePanGesture(_:)))
        panRight.cancelsTouchesInView = false
        viewGestures.addGestureRecognizer(panRight)
        
        
        self.lblVideoTime.text = article.media_meta?.duration?.formatFromMilliseconds()

        
        
    }
    
    // MARK: Setup Player
//    private func addPlayerToView() {
//
////        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////        player.view.frame = self.viewVideo.frame
////        player.fillMode = .fit
////        self.viewVideo.insertSubview(player.view, at: 0)
//
//        self.viewVideo.layer.cornerRadius = 12
//        self.viewVideo.layer.masksToBounds = true
//        self.viewVideo.clipsToBounds = true
//
//        self.viewVideo.layoutIfNeeded()
//        for view in self.viewVideo.subviews {
//            view.layoutIfNeeded()
//            view.clipsToBounds = true
//            view.layer.masksToBounds = true
//            view.layer.cornerRadius = 12
//        }
//    }
    
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

    
    func videoControllerStatusOnCellSetup(isHidden:Bool) {
        
        UIView.animate(withDuration: 0.2) {
            if isHidden {

//                self.imgPlaceHolder.isHidden = true
//                self.imgPlay.image = UIImage(named: "videoPause")
                //self.imgPlay.isHidden = true
//                self.slider.isHidden = true
                //self.lblVideoTime.isHidden = true
//                self.viewDuration.isHidden = true
                
//                self.btnVolume.isHidden = true
//                self.btnFullscreen.isHidden = true
            }
            else {
                
//                if self.player.time == 0 {
//
//                    self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
//                }
//                else {
//
//                    self.imgPlay.image = UIImage(named: "videoPause")
//                }
                //self.imgPlay.isHidden = false
//                self.slider.isHidden = true
                //self.lblVideoTime.isHidden = false
//                self.viewDuration.isHidden = false
                
//                self.btnVolume.isHidden = false
//                self.btnFullscreen.isHidden = false
                
            }
        }
    }
    
    
    func videoControllerStatus(isHidden:Bool) {
        
        UIView.animate(withDuration: 0.2) {
            if isHidden {

//                self.imgPlaceHolder.isHidden = true
//                self.imgPlay.image = UIImage(named: "videoPause")
                //self.imgPlay.isHidden = true
//                self.slider.isHidden = true
                //self.lblVideoTime.isHidden = true
//                self.viewDuration.isHidden = true
                
//                self.btnVolume.isHidden = true
//                self.btnFullscreen.isHidden = true
                if self.isCommunityCell {
                    self.btnReport.isHidden = true
                }
            }
            else {
                
//                if self.player.time == 0 {
//
//                    self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
//                    if self.isCommunityCell {
//                        self.btnReport.isHidden = false
//                    }
//                }
//                else {
//
//                    self.imgPlay.image = UIImage(named: "videoPause")
//                }
                //self.imgPlay.isHidden = false
//                self.slider.isHidden = false
                //self.lblVideoTime.isHidden = false
//                self.viewDuration.isHidden = false
                
//                self.btnVolume.isHidden = false
//                self.btnFullscreen.isHidden = false
                
            }
        }
        
    }
    
    // MARK: Actions
    @IBAction func didTapPlayVideo(_ sender: UIButton) {

        self.delegate?.didTapVideoPlayButton(cell: self, isTappedFromCell: true)
        
        /*
//        self.imgPlaceHolder.isHidden = true
        self.isVideoPaused = false
        if self.viewDuration.isHidden {

            if self.player.playing {

                self.videoControllerStatus(isHidden: false)
            }
            else {

                self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
                //self.imgPlay.isHidden = false
                self.slider.isHidden = false
                //self.lblVideoTime.isHidden = false
                self.viewDuration.isHidden = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

                if self.player.playing {

                    self.videoControllerStatus(isHidden: true)
                }
            }
        }
        else {

            if player.duration == player.time {

                self.slider.value = 0
                player.seek(to: .zero)
                player.play()

                if self.player.playing {

                    self.videoControllerStatus(isHidden: true)
                }
            }
            else {

                if self.player.playing {

                    self.isVideoPaused = true
                    self.delegate?.focusedIndex(index: sender.tag)
                    self.playVideo(isPause: true)
                    self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
                }
                else {


//                    self.resetVisibleVideoPlayer()
//                    self.delegate?.resetSelectedArticle()


                    SharedManager.shared.bulletPlayer?.pause()
                    SharedManager.shared.bulletPlayer?.stop()
//                    SharedManager.shared.clearProgressBar()
                    self.delegate?.focusedIndex(index: sender.tag)

                    self.manualPlay = true
                    self.playVideo(isPause: false)
                    self.imgPlay.image = UIImage(named: "videoPause")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

                        self.videoControllerStatus(isHidden: true)
                    }

                }
            }
        }
        
        */
        
    }
    
    @IBAction func didSelectCell(_ sender: Any) {
        
        self.delegate?.didSelectCell(cell: self)
    }
    
    @IBAction func didTapLikeButton(_ sender: Any) {
        
        self.delegateLikeComment?.didTapLikeButton(cell: self)
    }
    
    @IBAction func didTapCommentButton(_ sender: Any) {
        self.delegateLikeComment?.didTapCommentsButton(cell: self)
    }
    
    
    @IBAction func didChangeSliderValue() {
        
        // player.pause()
//        let value = Double(self.slider.value)
//        let time = value * player.duration
//        player.seek(to: time)
    }
    
    @IBAction func didTapVolume(_ sender: Any) {
        
        if SharedManager.shared.isAudioEnable {
            
            SharedManager.shared.isAudioEnable = false
//            player.volume = 0
//            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
            
        }
        else {
            
            SharedManager.shared.isAudioEnable = true
//            player.volume = 1
//            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
            
        }
    }
    
    @IBAction func didTapExpandVideo(_ sender: Any) {
        
//        self.delegate?.didSelectFullScreenVideo(cell: self)
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
}

extension TimeInterval {
    
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
        //let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        // let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d",minutes,seconds)
        
    }
}


class ShadowView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // border
//        self.layer.borderWidth = 0.25
//        self.layer.borderColor = UIColor.black.cgColor

        // shadow
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: 3, height: 3)
//        self.layer.shadowOpacity = 0.7
//        self.layer.shadowRadius = 4.0
    }

    override func layoutSubviews() {
        
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 12
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = 1.0
        self.layer.masksToBounds = false
    }
}
