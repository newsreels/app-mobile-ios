//
//  HomeClvHeadlineCC.swift
//  Bullet
//
//  Created by Mahesh on 18/08/2021.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import PlayerKit
import AVFoundation


internal let CELL_IDENTIFIER_HOME_HERO          = "HomeHeroCC"

protocol HomeHeroCCDelegate: AnyObject {
    
    func didTapOpenSource(cell: HomeHeroCC)
    func didTapYoutubePlayButton(cell: HomeHeroCC)
    func didTapHeroVideoPlayButton(cell: HomeHeroCC)
    func didHeroSelectCell(cell: HomeHeroCC)

}

class HomeHeroCC: UITableViewCell {
    
    //PROPERTIES
    @IBOutlet weak var viewContainer: UIView!
    
    //Image
    @IBOutlet weak var viewImgBG: UIView!
    @IBOutlet weak var imgBG: UIImageView!
    @IBOutlet weak var constraintContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var lblHeadline: UILabel!
    
    // Youtube
    @IBOutlet weak var viewYoutubeBG: UIView!
    @IBOutlet weak var viewPlaceholder: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet var videoPlayer: YouTubePlayerView!
    
    // Video view
    @IBOutlet weak var viewVideoBG: UIView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var imgPlaceHolder: UIImageView!
    @IBOutlet weak var imgPlayVideo: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var imgPlayButton: UIImageView!
//    @IBOutlet weak var slider: UISlider!
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblVideoTime: UILabel!
//    @IBOutlet weak var btnVolume: UIButton!
//    @IBOutlet weak var btnFullscreen: UIButton!
//    @IBOutlet weak var ctVideoHeight: NSLayoutConstraint!
    @IBOutlet weak var viewDuration: UIView!
    

    @IBOutlet weak var ctLblHeadlineTop: NSLayoutConstraint!
    @IBOutlet weak var constraintBulletLableHeight: NSLayoutConstraint!
    
    //source info
    @IBOutlet weak var viewChannel: UIView!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewSource: UIView!
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var ctViewChannelLeading: NSLayoutConstraint!
    
    //Channels
    @IBOutlet weak var viewChannel1: UIView!
    @IBOutlet weak var imgChannel: UIImageView!
    @IBOutlet weak var lblTime1: UILabel!
    @IBOutlet weak var lblSource1: UILabel!
    @IBOutlet weak var ctViewChannelHeight: NSLayoutConstraint!
    
    
    //VARIABLES
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
    
    var player = RegularPlayer()
    var isVideoPaused = false
    var manualPlay = false
    var isPlayWhenReady = false
    var videoRatio: CGFloat = 0
    var langCode = ""
    var subType = ""
    
    weak var delegate: HomeHeroCCDelegate?

    var articleID: String = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        viewContainer.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        
        lblHeadline.theme_textColor = GlobalPicker.textBWColor
        viewImgBG.isHidden = true
        viewVideoBG.isHidden = true
        viewYoutubeBG.isHidden = true
        videoPlayer.delegate = self
        
        lblHeadline.font = SharedManager.shared.getCardViewTitleFont()
        
        imgPlaceHolder.isUserInteractionEnabled = true
    }
    
    override func prepareForReuse() {
        
        viewImgBG.isHidden = true
        viewVideoBG.isHidden = true
        viewYoutubeBG.isHidden = true
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
                        
        lblHeadline.font = SharedManager.shared.getCardViewTitleFont()
        
        if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: langCode) {
            DispatchQueue.main.async {
                self.lblHeadline.semanticContentAttribute = .forceRightToLeft
                self.lblHeadline.textAlignment = .right
                self.lblSource.semanticContentAttribute = .forceRightToLeft
                self.lblSource.textAlignment = .right
                self.lblTime.semanticContentAttribute = .forceRightToLeft
                self.lblTime.textAlignment = .right
                
                self.lblSource1.semanticContentAttribute = .forceRightToLeft
                self.lblSource1.textAlignment = .right
                self.lblTime1.semanticContentAttribute = .forceRightToLeft
                self.lblTime1.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblHeadline.semanticContentAttribute = .forceLeftToRight
                self.lblHeadline.textAlignment = .left
                self.lblSource.semanticContentAttribute = .forceLeftToRight
                self.lblSource.textAlignment = .left
                self.lblTime.semanticContentAttribute = .forceLeftToRight
                self.lblTime.textAlignment = .left
                
                self.lblSource1.semanticContentAttribute = .forceLeftToRight
                self.lblSource1.textAlignment = .left
                self.lblTime1.semanticContentAttribute = .forceLeftToRight
                self.lblTime1.textAlignment = .left

            }
        }
        
//        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
//        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .highlighted)
        
        self.viewVideo.cornerRadius = 12
        self.viewVideo.layer.masksToBounds = true
        self.viewVideo.clipsToBounds = true
    }
    
    func animationSourceShowHide(isShow: Bool) {

        if subType == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE || subType == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
            
            if isShow {
                
                DispatchQueue.main.async {

                    UIView.animate(withDuration: 0.4, delay: 0, options: [.transitionFlipFromLeft], animations: {

                        self.ctViewChannelLeading.constant = 0
                        self.layoutIfNeeded()
                    })
                }
            }
            else {
                    
                DispatchQueue.main.async {
                    
                    UIView.animate(withDuration: 0.4, delay: 0, options: [.transitionFlipFromRight], animations: {

                        self.ctViewChannelLeading.constant = -(self.viewChannel.frame.width + 150)
                        self.layoutIfNeeded()
                    })
                }
            }
        }
        else {
            
            DispatchQueue.main.async {

                UIView.animate(withDuration: 0.4, delay: 0, options: [.transitionFlipFromLeft], animations: {

                    self.ctViewChannelLeading.constant = 0
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    //MARK:- setupCell
    func setupCell(content: articlesData?, isAutoPlay: Bool, isFromDetailScreen: Bool) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleHero, eventDescription: "", article_id: content?.id ?? "")
        animationSourceShowHide(isShow: true)
        
        articleID = content?.id ?? ""
        subType = content?.subType?.uppercased() ?? ""
        //LOCAL VIDEO TYPE
        if subType == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
            
//            videoRatio = CGFloat((content?.media_meta?.width ?? 1) / (content?.media_meta?.height ?? 1))
//            if videoRatio.isNaN {
//                videoRatio = 1.7
//            }
//    //        self.setNeedsLayout(
//    //        self.layoutIfNeeded()
//            var newHeight = UIScreen.main.bounds.width / videoRatio
//            newHeight = newHeight > (UIScreen.main.bounds.height * 0.7) ? UIScreen.main.bounds.height * 0.7 : newHeight
//            ctVideoHeight.constant = newHeight
            
            viewVideoBG.isHidden = false
            
            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            imgPlaceHolder.sd_setImage(with: URL(string: content?.image ?? ""), placeholderImage: nil)
//            imgPlaceHolder.isHidden = false
            
//            player.delegate = self
//            self.addPlayerToView()
//            if let url = URL(string: content?.link ?? "") {
//                player.set(AVURLAsset(url: url))
//            }
            
//            if isAutoPlay {
//
//                if SharedManager.shared.isAudioEnable == false {
//
//                    player.volume = 0
//                    btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
//                }
//                else {
//
//                    player.volume = 1
//                    btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
//                }
//
//                self.btnVolume.isHidden = false
//                self.btnFullscreen.isHidden = false
//                self.slider.value = 0
//                player.seek(to: .zero)
//
//                if isFromDetailScreen {
//
//                    self.imgPlaceHolder.contentMode = .scaleAspectFit
//                    isPlayWhenReady = true
//                    player.play()
//                    self.videoControllerStatus(isHidden: true)
//                }
//                else {
//
//                    if SharedManager.shared.videoAutoPlay {
//                        self.imgPlaceHolder.contentMode = .scaleAspectFit
//                        isPlayWhenReady = true
//                        player.play()
//                        self.videoControllerStatus(isHidden: true)
//                    }
//                    else {
//                        self.imgPlaceHolder.contentMode = .scaleAspectFill
//                        self.videoControllerStatus(isHidden: false)
//                    }
//                }
//            }
            lblVideoTime.text = content?.media_meta?.duration?.formatFromMilliseconds()
            
        }
        
        //YOUTUBE CARD CELL
        else if subType == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            
            viewYoutubeBG.isHidden = false
            
            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
                        
            langCode = content?.language ?? ""
            
            url = content?.link ?? ""
            urlThumbnail = content?.bullets?.first?.image ?? ""
            
//            if let pubDate = content?.publish_time {
//                lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate)
//            }
//            lblTime.addTextSpacing(spacing: 0.5)
            
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
        
        //HOME IMAGE CELL
        else {
            
            if SharedManager.shared.readerMode {
                viewImgBG.isHidden = true
                ctLblHeadlineTop.constant = 12
            }
            else {
                viewImgBG.isHidden = false
                ctLblHeadlineTop.constant = 30
                imgBG.sd_setImage(with: URL(string: content?.image ?? ""), placeholderImage: nil)
            }
        }
        
        lblHeadline.text = content?.title
        
        if SharedManager.shared.readerMode {
            
            //Check source image or text
            imgChannel.sd_setImage(with: URL(string: content?.source?.icon ?? "") , placeholderImage: nil)
            if let source = content?.source {
                
                lblSource1.text = source.name
            }
            else {
                
                //if source not exist then show author
                lblSource.text = content?.authors?.first?.name
            }
            lblSource1.theme_textColor = GlobalPicker.textBWColor
            lblSource1.addTextSpacing(spacing: 2.0)
                        
            if subType == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE || subType == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                viewChannel1.isHidden = true
                ctViewChannelHeight.constant = 0
            }
            else {
                viewChannel1.isHidden = false
                ctViewChannelHeight.constant = 60
            }
        }
        else {
            
            ctViewChannelHeight.constant = 0
            viewChannel1.isHidden = true
        }
        
        //Check source image or text
        if let source = content?.source {
            
            if let nameUrl = source.name_image, !nameUrl.isEmpty {
                lblSource.isHidden = true
                viewSource.isHidden = false
                imgSource.sd_setImage(with: URL(string: nameUrl), placeholderImage: nil)
            }
            else {
                lblSource.isHidden = false
                viewSource.isHidden = true
                lblSource.text = source.name?.uppercased()
                //lblSource.theme_textColor = GlobalPicker.textSourceColor
                lblSource.addTextSpacing(spacing: 2.0)
            }
        }
        else {
            
            //if source not exist then show author
            lblSource.isHidden = false
            viewSource.isHidden = true
            lblSource.text = content?.authors?.first?.name?.uppercased()
            lblSource.addTextSpacing(spacing: 2.0)
        }
        
        langCode = content?.language ?? ""
        
        if let pubDate = content?.publish_time {
            //lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
            lblTime1.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
        }
        //lblTime.addTextSpacing(spacing: 0.5)
        lblTime1.addTextSpacing(spacing: 0.5)
        self.viewChannel.layoutIfNeeded()
        
        SharedManager.shared.performWSToUpdateArticleAnalytics(ArticleId: content?.id ?? "", isFromReel: false)

    }
    
//    @IBAction func didChangeSliderValue() {
//
//       // player.pause()
//        let value = Double(self.slider.value)
//        let time = value * player.duration
//        player.seek(to: time)
//    }
    
//    @IBAction func didTapVolume(_ sender: Any) {
//
//        if SharedManager.shared.isAudioEnable {
//
//            SharedManager.shared.isAudioEnable = false
//            player.volume = 0
//            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
//
//        }
//        else {
//
//            SharedManager.shared.isAudioEnable = true
//            player.volume = 1
//            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
//
//        }
//    }
    
//    @IBAction func didTapExpandVideo(_ sender: Any) {
//
//        self.delegate?.didSelectFullScreenVideo(cell: self)
//    }
    
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
        
        self.delegate?.didTapHeroVideoPlayButton(cell: self)

////        self.imgPlaceHolder.isHidden = true
//        self.isVideoPaused = false
//        if self.viewDuration.isHidden  {
//
//            self.videoControllerStatus(isHidden: false)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//
//                if self.player.playing {
//
//                    self.videoControllerStatus(isHidden: true)
//                }
//            }
//        }
//        else {
//
//            if player.duration == player.time {
//
//                self.slider.value = 0
//                player.seek(to: .zero)
//                player.play()
//
//                if self.player.playing {
//
//                    self.videoControllerStatus(isHidden: true)
//                }
//            }
//            else {
//
//                if self.player.playing {
//
//                    SharedManager.shared.isVideoPlaying = false
//                    self.isVideoPaused = true
//                    self.playVideo(isPause: true)
//                    self.imgPlayVideo.image = UIImage(named: "youtubePlay_Icon")
//                }
//                else {
//
//                    SharedManager.shared.bulletPlayer?.pause()
//                    SharedManager.shared.bulletPlayer?.stop()
//                    SharedManager.shared.clearProgressBar()
//                    SharedManager.shared.isVideoPlaying = true
//
//                    self.manualPlay = true
//                    self.playVideo(isPause: false)
//                    self.imgPlayVideo.image = UIImage(named: "videoPause")
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//
//                        self.videoControllerStatus(isHidden: true)
//                    }
//                }
//            }
//        }
    }
    
//    func playVideo(isPause: Bool) {
//
//        self.btnVolume.isHidden = false
//        self.btnFullscreen.isHidden = false
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
//
//        if isPause {
//
//            player.pause()
//        }
//        else {
//
//            //if user pause the video and he went to category view.. I'm cheking video status
//            if self.isVideoPaused {
//
////                imgPlaceHolder.isHidden = false
//                player.pause()
//            }
//            else {
//
//                if SharedManager.shared.videoAutoPlay || manualPlay == true {
//
////                    imgPlaceHolder.isHidden = true
//                    manualPlay = false
//                    player.play()
//                }
//            }
//        }
//
//    }
    
//    private func addPlayerToView() {
//
//        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        player.view.frame = self.viewVideo.frame
//        player.fillMode = .fit
//        self.viewVideo.insertSubview(player.view, at: 0)
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
    
//    func resetVisibleVideoPlayer() {
//
//     //   imgPlay.image = UIImage(named: "youtubePlay_Icon")
//       // btnVolume.isHidden = true
//    //    player.volume = 0
//        player.pause()
//        player.seek(to: .zero)
//        self.videoControllerStatus(isHidden: true)
//
////        self.videoPlayer.pause()
////        self.videoPlayer.seek(to: 0)
//    }
    
    
//    func videoControllerStatus(isHidden:Bool) {
//
//        if isHidden {
//
////            imgPlaceHolder.isHidden = true
//            self.imgPlayVideo.image = UIImage(named: "videoPause")
//            //self.imgPlayVideo.isHidden = true
//          //  self.btnVolume.isHidden = true
//            self.slider.isHidden = true
//            //self.lblVideoTime.isHidden = true
//            self.viewDuration.isHidden = true
//
//            self.btnVolume.isHidden = true
//            self.btnFullscreen.isHidden = true
//        }
//        else {
//
////            if player.duration == player.time {
//            if player.time == 0 {
//                self.imgPlayVideo.image = UIImage(named: "youtubePlay_Icon")
//            }
//            else {
//
//                self.imgPlayVideo.image = UIImage(named: "videoPause")
//            }
//            //self.imgPlayVideo.isHidden = false
//       //     self.btnVolume.isHidden = false
//            self.slider.isHidden = false
//            //self.lblVideoTime.isHidden = false
//            self.viewDuration.isHidden = false
//
//            self.btnVolume.isHidden = false
//            self.btnFullscreen.isHidden = false
//        }
//    }

    @IBAction func didTapOpenSource(_ sender: Any) {
        self.delegate?.didTapOpenSource(cell: self)
    }

    @IBAction func didTapPlayYoutube(_ sender: Any) {
        self.delegate?.didTapYoutubePlayButton(cell: self)
    }

    @IBAction func didTapSelectCell() {
        self.delegate?.didHeroSelectCell(cell: self)
    }
    
}

extension HomeHeroCC: YouTubePlayerDelegate {
    
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
            animationSourceShowHide(isShow: false)
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
            self.animationSourceShowHide(isShow: true)
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoDurationEvent, eventDescription: "", article_id: articleID, duration: MediaManager.sharedInstance.player?.currentTime?.formatToMilliSeconds() ?? "")
        }
        else if playerState == .Playing {
            viewPlaceholder.isHidden = true
            self.animationSourceShowHide(isShow: false)

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






