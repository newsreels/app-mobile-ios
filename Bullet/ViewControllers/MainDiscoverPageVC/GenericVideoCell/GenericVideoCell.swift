//
//  GenericVideoCell.swift
//  Bullet
//
//  Created by Khadim Hussain on 12/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import PlayerKit
import AVFoundation
//import SkeletonView

@objc protocol GenericVideoCellDelegate: AnyObject {
    
    func didTapPause(index: Int)
    func didSelectFullScreenVideo(cell: GenericVideoCell)
}

class GenericVideoCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblVideoTime: UILabel!
    @IBOutlet weak var viewDuration: UIView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var btnVolume: UIButton!
    @IBOutlet weak var imgPlayIcon: UIImageView!
    @IBOutlet weak var btnFullscreen: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgPlaceHolder: UIImageView!
    
    @IBOutlet weak var ctViewVideoHeight: NSLayoutConstraint!
    var isVideoPaused = false
    weak var delegate: GenericVideoCellDelegate?

    var videoPlayer = RegularPlayer()
    var isPlayWhenReady =  false
    var currentArticleID = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblTitle.theme_textColor = GlobalPicker.textSubColorDiscover
        self.lblSubTitle.theme_textColor = GlobalPicker.textBWColorDiscover
        self.viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        self.theme_backgroundColor = GlobalPicker.backgroundDiscoverMainColor
        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .highlighted)
        self.selectionStyle = .none
        self.viewBG.addBottomShadowForDiscoverPage()
        
        self.slider.isHidden = true
    //    viewDuration.isHidden = false
    }
    
    override func prepareForReuse() {
        self.slider.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func hideAnimation() {
        
//        viewDuration.isHidden = false
//        btnVolume.isHidden = false
//        btnFullscreen.isHidden = false
//        [lblTitle, lblSubTitle, viewVideo, viewDuration, lblVideoTime, viewBG].forEach {
//
//            $0?.stopSkeletonAnimation()
//            $0?.hideSkeleton(transition: .crossDissolve(0.25))
//        }
    }
    func showAnimation() {
        viewDuration.isHidden = true
        btnVolume.isHidden = true
        btnFullscreen.isHidden = true
        lblTitle.text = ""
        lblSubTitle.text = ""
        lblVideoTime.text = ""
        imgPlaceHolder.isHidden = true
//        [lblTitle, lblSubTitle, viewVideo, lblVideoTime, viewBG].forEach {
//
//            let animation = GradientDirection.leftRight.slidingAnimation()
//            $0?.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient.init(baseColor: MyThemes.current == .light ? GlobalPicker.skeletonColorLightMode : GlobalPicker.skeletonColorDarkMode), animation: animation, transition: .crossDissolve(0.25))
//        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                self.lblSubTitle.semanticContentAttribute = .forceRightToLeft
                self.lblSubTitle.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                self.lblSubTitle.semanticContentAttribute = .forceLeftToRight
                self.lblSubTitle.textAlignment = .left
            }
        }
    }
    
    func setupCell(model: Discover?, isFocused: Bool) {
        
        self.hideAnimation()
        self.lblTitle.text = model?.subtitle?.uppercased() ?? ""
        self.lblSubTitle.text = model?.title ?? ""
        
        currentArticleID = model?.data?.video?.id ?? ""
        var ratio = (model?.data?.video?.media_meta?.width ?? 1) / (model?.data?.video?.media_meta?.height ?? 1)
        if ratio.isNaN {
            ratio = 1.7
        }
        var newHeight = viewVideo.frame.width / CGFloat(ratio)
        newHeight = newHeight > (UIScreen.main.bounds.height * 0.7) ? UIScreen.main.bounds.height * 0.7 : newHeight
        ctViewVideoHeight.constant = newHeight
        self.layoutIfNeeded()
    
        if let url = URL(string: model?.data?.video?.link ?? "") {
            
            self.videoPlayer.pause()
            self.videoPlayer.seek(to: 0)
            self.videoPlayer.delegate = self
            self.addPlayerToView()
            self.videoPlayer.set(AVURLAsset(url: url))
        }
        
        imgPlaceHolder.sd_setImage(with: URL(string: model?.data?.video?.image ?? ""), placeholderImage: nil)
//        imgPlaceHolder.isHidden = false

        if SharedManager.shared.isAudioEnable == false {
        
            videoPlayer.volume = 0
            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
        }
        else {
            
            videoPlayer.volume = 1
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
        }

        if isFocused {
            
            if SharedManager.shared.videoAutoPlay &&  SharedManager.shared.isOnDiscover  {
                
                
                self.playVideo()
             //   videoControllerStatusOnFirstLoading(isHidden: true)
                self.imgPlayIcon.isHidden = true
                SharedManager.shared.isVideoPlaying = true
            }
            else {
                
                self.imgPlayIcon.isHidden = false
                SharedManager.shared.isVideoPlaying = false
             //   videoControllerStatusOnFirstLoading(isHidden: false)
            }
        }
    }
    
    // MARK: Setup Player
    
    
    
    private func addPlayerToView() {
        
        self.videoPlayer.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.videoPlayer.view.frame = self.viewVideo.bounds
        self.videoPlayer.fillMode = .fill
        self.viewVideo.insertSubview(self.videoPlayer.view, at: 0)
    }
    
    func updateVideoPlayerStatus(isPause:Bool) {
        
        if isPause {
            
            self.videoPlayer.pause()
           // self.videoPlayer.seek(to: 0)
        }
        else {
            
            if SharedManager.shared.isOnDiscover {
                self.activityIndicator.startAnimating()
                self.videoPlayer.play()
            }
        }
    }
    
    
    func playVideo() {

//        imgPlaceHolder.isHidden = true
        isPlayWhenReady = true
        self.imgPlayIcon.isHidden = true
        self.activityIndicator.startAnimating()
        videoPlayer.play()
        SharedManager.shared.isVideoPlaying = true
    }
    
    
    func stopVideoPlayer(_ isReset: Bool) {

        isPlayWhenReady = false
        self.videoPlayer.pause()
        if isReset {
            self.videoPlayer.seek(to: 0)
        }
        self.videoControllerStatus(isHidden: true)
    }
    
    func videoControllerStatusOnFirstLoading(isHidden:Bool) {
        
        if isHidden {
            
//            self.imgPlaceHolder.isHidden = true
            self.imgPlay.image = UIImage(named: "videoPause")
            self.btnVolume.isHidden = true
            self.btnFullscreen.isHidden = true
            self.viewDuration.isHidden = true
            self.slider.isHidden = true
        }
        else {
            
            if self.videoPlayer.duration <= self.videoPlayer.time {
        
                self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
            }
            else {
                
                self.imgPlay.image = UIImage(named: "videoPause")
            }
            self.slider.isHidden = true
            self.btnVolume.isHidden = false
            self.btnFullscreen.isHidden = false
            self.viewDuration.isHidden = false
        }
    }
    
    func videoControllerStatus(isHidden:Bool) {
        
        if isHidden {
            
//            self.imgPlaceHolder.isHidden = true
            self.imgPlay.image = UIImage(named: "videoPause")
            self.btnVolume.isHidden = true
            self.btnFullscreen.isHidden = true
            self.slider.isHidden = true
            self.viewDuration.isHidden = true
            //self.imgPlay.isHidden = true
            //self.lblVideoTime.isHidden = true
        }
        else {
            
            if self.videoPlayer.duration <= self.videoPlayer.time {
        
                self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
            }
            else {
                
                self.imgPlay.image = UIImage(named: "videoPause")
            }
            //self.imgPlay.isHidden = false
            self.btnVolume.isHidden = false
            self.btnFullscreen.isHidden = false
            self.slider.isHidden = false
            //self.lblVideoTime.isHidden = false
            self.viewDuration.isHidden = false
        }
    }
    
    // MARK: Actions
    @IBAction func didTapVolume(_ sender: Any) {
        
        if SharedManager.shared.isAudioEnable {
        
            SharedManager.shared.isAudioEnable = false
            videoPlayer.volume = 0
            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)

        }
        else {
           
            SharedManager.shared.isAudioEnable = true
            videoPlayer.volume = 1
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
        
        }
    }
    
    @IBAction func didTapExpandVideo(_ sender: Any) {
        
        self.delegate?.didSelectFullScreenVideo(cell: self)
    }
    
    @IBAction func didTapPlayVideo(_ sender: UIButton) {
        
//        self.imgPlaceHolder.isHidden = true
        self.isVideoPaused = false
        if viewDuration.isHidden {
            
            if self.videoPlayer.playing {
                
                self.videoControllerStatus(isHidden: false)
            }
            else {
                
                self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
                //self.imgPlay.isHidden = false
                self.btnVolume.isHidden = false
                self.btnFullscreen.isHidden = false
                self.slider.isHidden = false
                //self.lblVideoTime.isHidden = false
                self.viewDuration.isHidden = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                
                if self.videoPlayer.playing {
                    
                    self.videoControllerStatus(isHidden: true)
                }
            }
        }
        else {
            
            if self.videoPlayer.duration <= self.videoPlayer.time {
                
                self.slider.value = 0
                self.videoPlayer.seek(to: .zero)
                if SharedManager.shared.isOnDiscover {
                    
                    self.delegate?.didTapPause(index: sender.tag)
                    self.activityIndicator.startAnimating()
                    self.videoPlayer.play()
                }
                
                if self.videoPlayer.playing {
                    
                    self.videoControllerStatus(isHidden: true)
                }
            }
            else {
                
                if self.videoPlayer.playing {
                    
                    self.isVideoPaused = true
                    self.videoPlayer.pause()
                    self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
                }
                else {
       
                    SharedManager.shared.bulletPlayer?.pause()
                    SharedManager.shared.bulletPlayer?.stop()
                    SharedManager.shared.clearProgressBar()
  
                    if SharedManager.shared.isOnDiscover {
                        
                        self.delegate?.didTapPause(index: sender.tag)
                        self.activityIndicator.startAnimating()
                        self.videoPlayer.play()
                    }
                    self.imgPlay.image = UIImage(named: "videoPause")
                    SharedManager.shared.videoFocusedIndex = sender.tag
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        
                        self.videoControllerStatus(isHidden: true)
                    }
                }
            }
        }
    }
    
    @IBAction func didChangeSliderValue() {
        
       // player.pause()
        let value = Double(self.slider.value)
        let time = value * self.videoPlayer.duration
        self.videoPlayer.seek(to: time)
    }

}

extension GenericVideoCell: PlayerDelegate {
    
    // MARK: VideoPlayerDelegate
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        self.activityIndicator.isHidden = true
        
        switch player.state {
        case .loading:
            
            self.lblVideoTime.text = "00:00"
            if player.time > 0 {
                self.activityIndicator.startAnimating()
            }
            //self.imgPlaceHolder.isHidden = false

        case .ready:
            self.lblVideoTime.text = "\(player.duration.stringFromTimeInterval())"
            
            if isPlayWhenReady {
                player.play()
            }
            break
            
        case .failed:
            
            NSLog("🚫 \(String(describing: player.error))")
        }
    }
    
    func playerDidUpdatePlaying(player: Player) {
        
        self.playButton.isSelected = player.playing
    }
    
    func playerDidUpdateTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
        
        activityIndicator.stopAnimating()
        
        if player.time > 0 {
            if self.imgPlaceHolder.isHidden == false {
                self.imgPlaceHolder.isHidden = true
            }
        } else {
            if self.imgPlaceHolder.isHidden {
                self.imgPlaceHolder.isHidden = false
            }
        }
        
        let ratio = player.time / player.duration
        
        if self.slider.isHighlighted == false {
            
            UIView.animate(withDuration: 0.3) {
                
                self.lblVideoTime.text = "\(player.time.stringFromTimeInterval()) / \(player.duration.stringFromTimeInterval()) "
                self.slider.value = Float(ratio)
            }
        }
        
        if player.duration <= player.time {
    
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoFinishedPlaying, eventDescription: "", article_id: currentArticleID)
            self.videoPlayer.seek(to: .zero)
            self.videoPlayer.play()
        //    self.videoControllerStatus(isHidden: false)
        }
    }
    
    func playerDidUpdateBufferedTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
       //   let ratio = Int((player.bufferedTime / player.duration) * 100)
        //self.label.text = "Buffer: \(ratio)%"
    }
}
