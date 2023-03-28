//
//  HomeDetailCardCell.swift
//  Bullet
//
//  Created by Faris Muhammed on 13/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import PlayerKit
import AVFoundation
import ImageSlideshow

protocol HomeDetailCardCellDelegate: AnyObject {
    func didTapOpenSource(cell: HomeDetailCardCell)
    func didTapShare(cell: HomeDetailCardCell)
    func didTapYoutubePlayButton(cell: HomeDetailCardCell)
    func didTapPlayLocalVideo(cell: HomeDetailCardCell)
    func didTapZoomImages(cell: HomeDetailCardCell)
    func didTapVideoPlayButton(cell: HomeDetailCardCell)
    func didTapViewMoreOptions(cell: HomeDetailCardCell)
    func didTapFollow(cell: HomeDetailCardCell)
}

class HomeDetailCardCell: UITableViewCell {

    // Bottom view
    @IBOutlet weak var viewDot: UIView!
    @IBOutlet weak var viewFooter: UIView!
//    @IBOutlet weak var viewComment: UIView!
//    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var lblCommentsCount: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var imgComment: UIImageView!
    
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSource: UIButton!
    @IBOutlet weak var imgWifi: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblSource: UILabel!
//    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var lblBulletTitle: UILabel!
    
    // Youtube
    @IBOutlet weak var viewPlaceholder: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet var videoPlayer: YouTubePlayerView!
    
    // Video view
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var imgPlaceHolder: UIImageView!
    @IBOutlet weak var imgPlayVideo: UIImageView!
    @IBOutlet weak var playButton: UIButton!
//    @IBOutlet weak var slider: UISlider!
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblVideoTime: UILabel!
//    @IBOutlet weak var btnVolume: UIButton!
//    @IBOutlet weak var btnFullscreen: UIButton!
    @IBOutlet weak var ctVideoHeight: NSLayoutConstraint!
    @IBOutlet weak var viewDuration: UIView!
    
    // Card View
    //@IBOutlet weak var imgBG: UIImageView!
    @IBOutlet var slideshow: ImageSlideshow!

    
    // StackView
    @IBOutlet weak var viewImageArticle: UIView!
    @IBOutlet weak var viewVideoArticle: UIView!
    @IBOutlet weak var viewYoutubeArticle: UIView!
    
    @IBOutlet weak var imgPlayButton: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundDetailsView: UIView!
    
    @IBOutlet weak var sourceInfoLabel: UILabel!
    @IBOutlet weak var verifiedImage: UIImageView!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var moreOptionsView: UIView!
    
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var lblShare: UILabel!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var moreImageView: UIImageView!
    
    
    var langCode = ""
    weak var delegate: HomeDetailCardCellDelegate?
    weak var delegateLikeComment: LikeCommentDelegate?
    var urlThumbnail: String = "" {
        didSet {
            
            imgThumbnail.sd_setImage(with: URL(string: urlThumbnail), placeholderImage: nil)
        }
    }
    var url: String = "" {
        didSet {
            videoPlayer.playerVars = [
                "playsinline": "1",
                "controls": "1",
                "rel" : "0",
                "cc_load_policy" : "0",
                "disablekb": "1",
                "modestbranding": "1",
                "mute": SharedManager.shared.isAudioEnable ? "0" : "1"
                ] as YouTubePlayerView.YouTubePlayerParameters
            videoPlayer.delegate = self
            videoPlayer.loadVideoID(url)
        }
    }
    
    var isVideoPaused = false
    var manualPlay = false
    var isPlayWhenReady = false
    var videoRatio: CGFloat = 0
    var articleID: String = ""
    
    var articleModel: articlesData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        setupUI()
        viewImageArticle.isHidden = true
        viewVideoArticle.isHidden = true
        viewYoutubeArticle.isHidden = true
        videoPlayer.delegate = self
        
        lblBulletTitle.font = SharedManager.shared.getTitleFont()
        imgPlaceHolder.isUserInteractionEnabled = true
        
        imgPlaceHolder.contentMode = .scaleAspectFit
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            imageHeightConstraint.constant = 500
        }
        
        moreImageView.theme_image = GlobalPicker.imgMoreOptions
    }

    override func prepareForReuse() {
        
        viewImageArticle.isHidden = true
        viewVideoArticle.isHidden = true
        viewYoutubeArticle.isHidden = true
        videoPlayer.stop()
        imgWifi.cornerRadius = imgWifi.frame.size.width / 2
    }
    
    override func layoutSubviews() {
        
        lblBulletTitle.font = SharedManager.shared.getTitleFont()
        imgWifi.cornerRadius = imgWifi.frame.size.width / 2
        followButton.cornerRadius = 12
        
        if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: langCode) {
            DispatchQueue.main.async {
                self.lblBulletTitle.semanticContentAttribute = .forceRightToLeft
                self.lblBulletTitle.textAlignment = .right
                self.lblSource.semanticContentAttribute = .forceRightToLeft
                self.lblSource.textAlignment = .right
                self.lblAuthor.semanticContentAttribute = .forceRightToLeft
                self.lblAuthor.textAlignment = .right
                self.lblTime.semanticContentAttribute = .forceRightToLeft
                self.lblTime.textAlignment = .right
//                self.lblViews.semanticContentAttribute = .forceRightToLeft
//                self.lblViews.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblBulletTitle.semanticContentAttribute = .forceLeftToRight
                self.lblBulletTitle.textAlignment = .left
                self.lblAuthor.semanticContentAttribute = .forceLeftToRight
                self.lblAuthor.textAlignment = .left
                self.lblSource.semanticContentAttribute = .forceLeftToRight
                self.lblSource.textAlignment = .left
                self.lblTime.semanticContentAttribute = .forceLeftToRight
                self.lblTime.textAlignment = .left
//                self.lblViews.semanticContentAttribute = .forceLeftToRight
//                self.lblViews.textAlignment = .left
            }
        }
        
//        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
//        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .highlighted)
        
        self.viewVideo.cornerRadius = 12
        self.viewVideo.layer.masksToBounds = true
        self.viewVideo.clipsToBounds = true
        
        
        if articleModel?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO || articleModel?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            self.backgroundDetailsView.roundCorners(corners: .allCorners, radius: 0)
        }
        else {
            self.backgroundDetailsView.roundCorners(corners: [.topLeft,.topRight], radius: 14)
        }
        
        
        
        
    }
    
    
    func setupUI() {
        //self.viewComment.theme_backgroundColor = GlobalPicker.viewCountColor
        //self.viewLike.theme_backgroundColor = GlobalPicker.viewCountColor
        self.lblBulletTitle.theme_textColor = GlobalPicker.textBWColor
        self.lblSource.theme_textColor = GlobalPicker.textBWColor
        
        self.lblAuthor.textColor = Constant.appColor.mediumGray
        
        self.lblTime.textColor = Constant.appColor.mediumGray
        self.sourceInfoLabel.textColor = Constant.appColor.mediumGray
        //theme_textColor = GlobalPicker.textBWColor
//        self.backgroundDetailsView.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        self.backgroundDetailsView.backgroundColor = Constant.appColor.backgroundGray
        
        moreImageView.theme_image = GlobalPicker.imgMoreOptions
    }
    
    func setFollowingUI() {
        
        
        if let source = articleModel?.source {
            
            if articleModel?.source?.isShowingLoader ?? false {
                followButton.showLoader()
            }
            else {
                followButton.hideLoaderView()
            }
            
            let fav = source.favorite ?? false
            if fav {
                followButton.setTitle("Following", for: .normal)
                followButton.backgroundColor = Constant.appColor.lightGray
                followButton.setTitleColor(.white, for: .normal)
            }
            else {
                followButton.setTitle("Follow", for: .normal)
                followButton.backgroundColor = Constant.appColor.lightRed
                followButton.setTitleColor(.white, for: .normal)
                
            }
            
        } else {
            
            if articleModel?.authors?.first?.isShowingLoader ?? false {
                followButton.showLoader()
            }
            else {
                followButton.hideLoaderView()
            }
            
            //author
            let fav = articleModel?.authors?.first?.favorite ?? false
            if fav {
                followButton.setTitle("Following", for: .normal)
                followButton.backgroundColor = .white
                followButton.setTitleColor(Constant.appColor.darkGray, for: .normal)
            }
            else {
                followButton.setTitle("Follow", for: .normal)
                followButton.backgroundColor = Constant.appColor.lightRed
                followButton.setTitleColor(.white, for: .normal)
                
            }
            
        }
        
    }
    
    
    func setLikeComment(model: Info?) {
        
        if model?.isLiked ?? false {
            //viewLike.theme_backgroundColor = GlobalPicker.themeCommonColor
            imgLike.theme_image = GlobalPicker.likedImage
//            lblLikeCount.theme_textColor = GlobalPicker.likeCountColor
        } else {
            //self.viewLike.theme_backgroundColor = GlobalPicker.viewCountColor
            imgLike.theme_image = GlobalPicker.likeDefaultImage
//            lblLikeCount.textColor = .gray
        }
        //self.viewComment.theme_backgroundColor = GlobalPicker.viewCountColor
        lblCommentsCount.theme_textColor = GlobalPicker.textBWColor
        lblLikeCount.theme_textColor = GlobalPicker.textBWColor
        lblShare.theme_textColor = GlobalPicker.textBWColor
        
        shareImageView.theme_image = GlobalPicker.commonShare
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
    @IBAction func didTapViewMoreOptions(_ sender: Any) {
        
        self.delegate?.didTapViewMoreOptions(cell: self)
    }
    
    @IBAction func didTapExpandVideo(_ sender: Any) {
        
//        self.delegate?.didSelectFullScreenVideo(cell: self)
    }
    
    @IBAction func didTapVolumeYoutube(_ sender: Any) {
        
        if SharedManager.shared.isAudioEnable {
            
            SharedManager.shared.isAudioEnable = false
            videoPlayer.mute()
        }
        else {
            
            SharedManager.shared.isAudioEnable = true
            videoPlayer.unMute()
        }
    }
    
    
    @IBAction func didTapPlay(_ sender: Any) {
        
        self.delegate?.didTapVideoPlayButton(cell: self)
    }
    
    
    func setupCell(content: articlesData?, isAutoPlay: Bool, isFromDetailScreen: Bool) {
        
        articleModel = content
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleViewed, eventDescription: "", article_id: content?.id ?? "")

        //LOCAL VIDEO TYPE
        
        articleID = content?.id ?? ""
        
        if content?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO || content?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            backgroundTopConstraint.constant = 0
        }
        else {
            backgroundTopConstraint.constant = -26
        }
        
        if content?.type == Constant.newsArticle.ARTICLE_TYPE_REEL {
            viewImageArticle.isHidden = false
            
            //imgBG.sd_setImage(with: URL(string: content?.image ?? ""), placeholderImage: nil)
            
            slideshow.slideshowInterval = 0
            //slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
            slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill
            //slideshow.pageIndicator = UIPageControl.withSlideshowColors()

            // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
            slideshow.activityIndicator = DefaultActivityIndicator()
            slideshow.delegate = self

            var sdWebImageSource = [SDWebImageSource]()
//            if let bullets = content?.bullets {
//                for bul in bullets {
//                    let img = bul.image ?? ""
//                    if !img.isEmpty {
//                        sdWebImageSource.append(SDWebImageSource(urlString: img)!)
//                    }
//                }
//            }
            if let source =  SDWebImageSource(urlString: content?.image ?? "") {
                sdWebImageSource.append(source)
            }
            
            
            sdWebImageSource = sdWebImageSource.uniq(by: { $0.url })
            slideshow.setImageInputs(sdWebImageSource)

            let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnImage))
            slideshow.addGestureRecognizer(recognizer)
        }
        else if content?.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
            
            videoRatio = CGFloat((content?.media_meta?.width ?? 1) / (content?.media_meta?.height ?? 1))
            if videoRatio.isNaN {
                videoRatio = 1.7
            }
    //        self.setNeedsLayout()
    //        self.layoutIfNeeded()
            var newHeight = (UIScreen.main.bounds.width) / videoRatio //(UIScreen.main.bounds.width - 40) / videoRatio
            newHeight = newHeight > (UIScreen.main.bounds.height * 0.7) ? UIScreen.main.bounds.height * 0.7 : newHeight
            ctVideoHeight.constant = newHeight
            
            
            viewVideoArticle.isHidden = false
            
            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            setLikeComment(model: content?.info)
            
            imgPlaceHolder.sd_setImage(with: URL(string: content?.image ?? ""), placeholderImage: nil)

            lblVideoTime.text = content?.media_meta?.duration?.formatFromMilliseconds()
            
            SharedManager.shared.performWSToUpdateArticleAnalytics(ArticleId: content?.id ?? "", isFromReel: false)
        }
        //YOUTUBE CARD CELL
        else if content?.type?.uppercased() == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            
            viewYoutubeArticle.isHidden = false
            
            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            
            // Set like comment
            self.setLikeComment(model: content?.info)
            
            langCode = content?.language ?? ""
            
            url = content?.link ?? ""
            urlThumbnail = content?.bullets?.first?.image ?? ""
            
//            lblSource.addTextSpacing(spacing: 2.5)
            
            if let pubDate = content?.publish_time {
                lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate)
            }
            lblTime.addTextSpacing(spacing: 1.25)
            
//            lblViewCount.text = "0"
            if let info = content?.meta {
                
//                lblViewCount.text = info.view_count
            }
            
            
            viewPlaceholder.isHidden = false
            //imgPlayVideo.isHidden = false
            viewDuration.isHidden = false
            activityLoader.stopAnimating()
            lblDuration.text = content?.bullets?.first?.duration?.formatFromMilliseconds()
            
            if isAutoPlay {
                isPlayWhenReady = true
                self.setFocussedYoutubeView()
            }
            
        }
        
        //HOME ARTICLES CELL
        else {
            if content?.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_SIMPLE {
                
                //LIST VIEW DESIGN CELL- SMALL CELL
                
            }
            else {
                
                //CARD VIEW DESIGN CELL- LARGE CELL
            }
            viewImageArticle.isHidden = false
            
            //imgBG.sd_setImage(with: URL(string: content?.image ?? ""), placeholderImage: nil)
            
            slideshow.slideshowInterval = 0
            //slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
            slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill
            //slideshow.pageIndicator = UIPageControl.withSlideshowColors()

            // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
            slideshow.activityIndicator = DefaultActivityIndicator()
            slideshow.delegate = self

            var sdWebImageSource = [SDWebImageSource]()
            if let bullets = content?.bullets {
                for bul in bullets {
                    let img = bul.image ?? ""
                    if !img.isEmpty {
                        sdWebImageSource.append(SDWebImageSource(urlString: img)!)
                    }
                }
            }
//            sdWebImageSource.append(SDWebImageSource(urlString: content?.image ?? "")!)
            sdWebImageSource = sdWebImageSource.uniq(by: { $0.url })
            slideshow.setImageInputs(sdWebImageSource)

            let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnImage))
            slideshow.addGestureRecognizer(recognizer)
        }
        
        lblBulletTitle.text = content?.title ?? ""
        if let source = content?.source {
            sourceInfoLabel.text = "by \(source.name ?? "")"
            lblSource.text = source.name ?? ""
            imgWifi?.sd_setImage(with: URL(string: content?.source?.icon ?? ""), placeholderImage: nil)
            
            
        } else {
            
            //author
            lblSource.text = content?.authors?.first?.username ?? content?.authors?.first?.name ?? ""
            sourceInfoLabel.text = "by \(content?.authors?.first?.username ?? content?.authors?.first?.name ?? "")"
            imgWifi?.sd_setImage(with: URL(string: content?.authors?.first?.image ?? ""), placeholderImage: nil)
        }
        
        var name = content?.authors?.first?.username ?? content?.authors?.first?.name ?? ""
        if name.isEmpty {
            name = content?.source?.name ?? ""
        }
        lblAuthor.text = "@\(name)"
        lblAuthor.isHidden = name.isEmpty ? true : false
    
        
//        lblAuthor.theme_textColor = GlobalPicker.textSourceColor
//        lblSource.theme_textColor = GlobalPicker.textSourceColor
        //lblSource.addTextSpacing(spacing: 1.25)
        self.langCode = content?.language ?? ""
        
        if let pubDate = content?.publish_time {
            lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
        }
        //lblTime.addTextSpacing(spacing: 1.25)
        
//        lblViews.text = "\(content?.info?.viewCount ?? "0") \(NSLocalizedString("Views", comment: ""))"
        setLikeComment(model: content?.info)
        
        setFollowingUI()
        
        
        sourceInfoLabel.text = ""
        underlineView.isHidden = true
    }
    
    @objc private func didTapOnImage() {
        
        self.delegate?.didTapZoomImages(cell: self)
    }
    
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
//
//    }
    
    func setFocussedYoutubeView() {
        
        if SharedManager.shared.videoAutoPlay {
         
            self.videoPlayer.play()
            //self.imgPlay.isHidden = true
            self.activityLoader.startAnimating()
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
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTapLike(_ sender: Any) {
        self.delegateLikeComment?.didTapLikeButton(cell: self)
    }
    
    @IBAction func didTapComment(_ sender: Any) {
        self.delegateLikeComment?.didTapCommentsButton(cell: self)
    }
    
    @IBAction func didTapOpenSource(_ sender: Any) {
        
        self.delegate?.didTapOpenSource(cell: self)
    }
    
    @IBAction func didTapShare(_ sender: Any) {
        self.delegate?.didTapShare(cell: self)
    }
    
    
    @IBAction func didTapPlayYoutube(_ sender: Any) {
        self.delegate?.didTapYoutubePlayButton(cell: self)
    }
    
    @IBAction func didTapFollow(_ sender: Any) {
        
        self.delegate?.didTapFollow(cell: self)
        
    }
    
}


extension HomeDetailCardCell: YouTubePlayerDelegate {
    
    func playerUpdateCurrentTime(_ videoPlayer: YouTubePlayerView, time: String) {
        
        if SharedManager.shared.isAudioEnable && videoPlayer.isMuted {
            SharedManager.shared.isAudioEnable = false
        }
        if SharedManager.shared.isAudioEnable == false && videoPlayer.isMuted == false {
            SharedManager.shared.isAudioEnable = true
        }
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        
        print("\(#function)")
        //self.imgThumbnail.isHidden = true
        
//        videoPlayer.duration { duration, error in
//            self.lblDuration.text = duration.stringFromTimeInterval()
//        }
//        disableYoutubePlayerControls()
        
        if isPlayWhenReady {
            videoPlayer.play()
        }
        
//        videoPlayer.getDuration(completion: { (duration) in
//            //self.lblDuration.text = "\(String(describing: duration))"
//            //print("getDuration", String(describing: duration))
//            self.lblDuration.text = duration?.stringFromTimeInterval()
//        })
    }
    
//    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
//        return MyThemes.current == .dark ? .black : .white
//    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        
        
        if playerState == .Ended {
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoFinishedPlaying, eventDescription: "", article_id: articleID)
        }
        if playerState == .Paused || playerState == .Ended {
            self.activityLoader.stopAnimating()
            self.imgPlay.isHidden = false
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoDurationEvent, eventDescription: "", article_id: articleID, duration: MediaManager.sharedInstance.player?.currentTime?.formatToMilliSeconds() ?? "")
        }
        else if playerState == .Playing {
            viewPlaceholder.isHidden = true
            
            if SharedManager.shared.isAudioEnable {
                videoPlayer.unMute()
            } else {
                videoPlayer.mute()
            }
            
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



//MARK:- Image slider
extension HomeDetailCardCell: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
