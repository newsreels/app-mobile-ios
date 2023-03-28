//
//  EZPlayerControlView.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AVKit


open class EZPlayerControlView: UIView{
    weak public var player: EZPlayer?{
        didSet{
            player?.setControlsHidden(true, animated: true)
            self.autohideControlView()

            if MediaManager.sharedInstance.isOpenCurrnetlyForReels {
                
                if SharedManager.shared.isAudioEnableReels {
                    player?.player?.isMuted = false
                }
                else {
                    player?.player?.isMuted = true
                }
            }
            else {
                if SharedManager.shared.isAudioEnable {
                    player?.player?.isMuted = false
                }
                else {
                    player?.player?.isMuted = true
                }
            }
            
        }
    }

    //    open var tapGesture: UITapGestureRecognizer!

    var hideControlViewTask: Task?

    public var autohidedControlViews = [UIView]()
    //    var controlsHidden = false
    @IBOutlet weak var navBarContainer: UIView!
    @IBOutlet weak var navBarContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var ToolBarContainerBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var toolBarContainer: UIView!
    @IBOutlet weak var safeAreaBottomView: UIView!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var fullEmbeddedScreenButton: UIButton!
    @IBOutlet weak var fullEmbeddedScreenButtonWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var timeSlider: UISlider!

    @IBOutlet weak var videoshotPreview: UIView!
    @IBOutlet weak var videoshotPreviewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoshotImageView: UIImageView!

    @IBOutlet weak var viewSubTitle: UIView!
    @IBOutlet weak var loading: EZPlayerLoading!
    @IBOutlet weak var volumeButton: UIButton!
    
    var currTime = 0.0
    var defaultLeftInset: CGFloat = 20.0
    var captionsArr: [UILabel]?
    var captionsViewArr: [UIView]?
    

    // MARK: - Life cycle

    deinit {

    }
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.timeSlider.value = 0
        self.progressView.progress = 0
        self.progressView.progressTintColor = UIColor.lightGray
        self.progressView.trackTintColor = UIColor.clear
        self.progressView.backgroundColor = UIColor.clear

        self.videoshotPreview.isHidden = true

//        self.audioSubtitleCCButtonWidthConstraint.constant = 0
//        self.pipButtonWidthConstraint.constant = 0

        self.autohidedControlViews = [self.navBarContainer,self.toolBarContainer,self.safeAreaBottomView]
        //        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureTapped(_:)))
        //        self.tapGesture.delegate = self
        //        self.addGestureRecognizer(self.tapGesture)




//        let airplayImage = UIImage(named: "btn_airplay", in: Bundle(for: EZPlayerControlView.self),compatibleWith: nil)
//        let airplayView = MPVolumeView(frame: self.airplayContainer.bounds)
//        airplayView.showsVolumeSlider = false
//        airplayView.showsRouteButton = true
//        airplayView.setRouteButtonImage(airplayImage, for: .normal)
//        self.airplayContainer.addSubview(airplayView)
        //        self.loading.start()


        navBarContainer.isHidden = true
        
        timeSlider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        timeSlider.setThumbImage(UIImage(named: "sliderThumb"), for: .highlighted)
        
        timeSlider.tintColor = Constant.appColor.purple
        
        
        // Set volume initially
        if MediaManager.sharedInstance.isOpenCurrnetlyForReels {
            if SharedManager.shared.isAudioEnableReels {
                player?.player?.isMuted = false
                volumeButton.setImage(UIImage(named: "volumeReelOn"), for: .normal)
            }
            else {
                player?.player?.isMuted = true
                volumeButton.setImage(UIImage(named: "volumeReelOff"), for: .normal)
            }
        } else {
            if SharedManager.shared.isAudioEnable {
                player?.player?.isMuted = false
                volumeButton.setImage(UIImage(named: "volumeReelOn"), for: .normal)
            }
            else {
                player?.player?.isMuted = true
                volumeButton.setImage(UIImage(named: "volumeReelOff"), for: .normal)
            }
        }
        
        
    }

    // MARK: - EZPlayerCustomControlView
    fileprivate var isProgressSliderSliding = false {
        didSet{
            if !(self.player?.isM3U8 ?? true) {
                //                self.videoshotPreview.isHidden = !isProgressSliderSliding
            }
        }

    }

    @IBAction func progressSliderTouchBegan(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        self.player(player, progressWillChange: TimeInterval(self.timeSlider.value))
    }

    @IBAction func progressSliderValueChanged(_ sender: Any) {
        guard let player = self.player else {
            return
        }

        self.player(player, progressChanging: TimeInterval(self.timeSlider.value))
    }

    @IBAction func progressSliderTouchEnd(_ sender: Any) {
        self.videoshotPreview.isHidden = true
        guard let player = self.player else {
            return
        }
        self.player(player, progressDidChange: TimeInterval(self.timeSlider.value))
    }


    //    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
    //        self.autohideControlView()
    //        return !self.autohidedControlViews.contains(touch.view!) && !self.autohidedControlViews.contains(touch.view!.superview!)
    //        //        return true
    //    }
    //
    // MARK: - private
    //    @objc fileprivate func tapGestureTapped(_ sender: UIGestureRecognizer) {
    //        guard let player = self.player else {
    //            return
    //        }
    //        player.controlsHidden = !player.controlsHidden
    //    }


    fileprivate func hideControlView(_ animated: Bool) {
        //        if self.controlsHidden == true{
        //          return
        //        }
        if animated{
            UIView.setAnimationsEnabled(false)
            UIView.animate(withDuration: EZPlayerAnimatedDuration, delay: 0,options: .curveEaseInOut, animations: {
                self.autohidedControlViews.forEach{
                    $0.alpha = 0
                }
            }, completion: {finished in
                self.autohidedControlViews.forEach{
                    $0.isHidden = true
                }
                UIView.setAnimationsEnabled(true)
            })
        }else{
            self.autohidedControlViews.forEach{
                $0.alpha = 0
                $0.isHidden = true
            }
        }
    }
    
    
    @IBAction func didTapVolumeButton(_ sender: Any) {
        
        
        if MediaManager.sharedInstance.isOpenCurrnetlyForReels {
            
            if SharedManager.shared.isAudioEnableReels {
                
                SharedManager.shared.isAudioEnableReels = false
                player?.player?.isMuted = true
                volumeButton.setImage(UIImage(named: "volumeReelOff"), for: .normal)
                
            }
            else {
                
                SharedManager.shared.isAudioEnableReels = true
                player?.player?.isMuted = false
                volumeButton.setImage(UIImage(named: "volumeReelOn"), for: .normal)
                
            }
        } else {
            
            if SharedManager.shared.isAudioEnable {
                
                SharedManager.shared.isAudioEnable = false
                player?.player?.isMuted = true
                volumeButton.setImage(UIImage(named: "volumeReelOff"), for: .normal)
                
            }
            else {
                
                SharedManager.shared.isAudioEnable = true
                player?.player?.isMuted = false
                volumeButton.setImage(UIImage(named: "volumeReelOn"), for: .normal)
                
            }
        }
    }
    
    fileprivate func showControlView(_ animated: Bool) {
        //        if self.controlsHidden == false{
        //            return
        //        }

        if animated{
            UIView.setAnimationsEnabled(false)
            self.autohidedControlViews.forEach{
                $0.isHidden = false
            }
            UIView.animate(withDuration: EZPlayerAnimatedDuration, delay: 0,options: .curveEaseInOut, animations: {
                if self.player?.displayMode == .fullscreen{
                    self.navBarContainerTopConstraint.constant =  ((EZPlayerUtils.hasSafeArea || (ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 13)) && (UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .landscapeLeft)) ? 20 : EZPlayerUtils.statusBarHeight
//                    self.navBarContainerTopConstraint.constant =  ((EZPlayerUtils.hasSafeArea || (ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 13)) && self.player?.fullScreenMode == .landscape) ? 20 : EZPlayerUtils.statusBarHeight
                    //                    self.ToolBarContainerBottomConstraint.constant = EZPlayerUtils.hasSafeArea ? self.player?.fullScreenMode == .portrait ? 34 : 21 : 0
                    self.ToolBarContainerBottomConstraint.constant = EZPlayerUtils.hasSafeArea ?  !(UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .landscapeLeft)  ? 34 : 21 : 0

                }else{
                    self.navBarContainerTopConstraint.constant = 0
                    self.ToolBarContainerBottomConstraint.constant = 0
                }
                self.autohidedControlViews.forEach{
                    $0.alpha = 1
                }
            }, completion: {finished in
                self.autohideControlView()
                UIView.setAnimationsEnabled(true)
                
                self.self.customizeControls()
            })
        }else{
            self.autohidedControlViews.forEach{
                $0.isHidden = false
                $0.alpha = 1
            }
            if self.player?.displayMode == .fullscreen{
                self.navBarContainerTopConstraint.constant =  ((EZPlayerUtils.hasSafeArea || (ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 13)) && self.player?.fullScreenMode == .landscape) ? 20 : EZPlayerUtils.statusBarHeight
                self.ToolBarContainerBottomConstraint.constant = EZPlayerUtils.hasSafeArea ? self.player?.fullScreenMode == .portrait ? 34 : 21 : 0
            }else{
                self.navBarContainerTopConstraint.constant = 0
            }
            self.autohideControlView()
        }
        
        
        customizeControls()
        
        
    }
    
    func customizeControls() {
        
        if player?.displayMode == .embedded {
            navBarContainer.isHidden = true
        }
        
        if MediaManager.sharedInstance.isOpenCurrnetlyForReels {
            self.navBarContainerTopConstraint.constant = 0
            self.ToolBarContainerBottomConstraint.constant = 0
            
            navBarContainer.isHidden = false
            self.navBarContainer.subviews.forEach{
                $0.isHidden = false
                $0.alpha = 1
            }
            
            fullEmbeddedScreenButton.isHidden = true
            fullEmbeddedScreenButtonWidthConstraint.constant = 0
        }
        
    }

    fileprivate func autohideControlView(){
        guard let player = self.player , player.autohiddenTimeInterval > 0 else {
            return
        }
        cancel(self.hideControlViewTask)
        self.hideControlViewTask = delay(5, task: { [weak self]  in
            guard let weakSelf = self else {
                return
            }
            //            weakSelf.hideControlView()
            weakSelf.player?.setControlsHidden(true, animated: true)
        })
    }

    fileprivate func showThumbnail(){
        guard let player = self.player  else {
            return
        }

        if !player.isM3U8 {
//            self.videoshotPreview.isHidden = false
            player.generateThumbnails(times:  [ TimeInterval(self.timeSlider.value)],maximumSize:CGSize(width: self.videoshotImageView.bounds.size.width, height: self.videoshotImageView.bounds.size.height)) { (thumbnails) in
                let trackRect = self.timeSlider.convert(self.timeSlider.bounds, to: nil)
                let thumbRect = self.timeSlider.thumbRect(forBounds: self.timeSlider.bounds, trackRect: trackRect, value: self.timeSlider.value)
                var lead = thumbRect.origin.x + thumbRect.size.width/2 - self.videoshotPreview.bounds.size.width/2
                if lead < 0 {
                    lead = 0
                }else if lead + self.videoshotPreview.bounds.size.width > player.view.bounds.width {
                    lead = player.view.bounds.width - self.videoshotPreview.bounds.size.width
                }
                self.videoshotPreviewLeadingConstraint.constant = lead
                if thumbnails.count > 0 {
                    let thumbnail = thumbnails[0]
                    if thumbnail.result == .succeeded {
                        self.videoshotImageView.image = thumbnail.image
                    }
                }
            }
        }
    }

}

extension EZPlayerControlView: EZPlayerCustom {
    // MARK: - EZPlayerCustomAction
    @IBAction public func playPauseButtonPressed(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        if player.isPlaying {
            player.pause()
        }else{
            if (player.currentTime ?? .zero) >= (player.duration ?? .zero) {
                player.seek(to: .zero) { status in
                    print(status)
                }
            }
            player.play()
        }
    }

    @IBAction public func fullEmbeddedScreenButtonPressed(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        switch player.displayMode {
        case .embedded:
            MediaManager.sharedInstance.isFullScreenButtonPressed = true
//            player.fullScreenMode = .landscape
            player.toFull()
        case .fullscreen:
            if player.lastDisplayMode == .embedded{
                (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()
                player.toEmbedded()
            }else  if player.lastDisplayMode == .float{
                player.toFloat()
            }

        default:
            break
        }
    }
    
    

    @IBAction public func audioSubtitleCCButtonPressed(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        let audibleLegibleViewController = EZPlayerAudibleLegibleViewController(nibName:  String(describing: EZPlayerAudibleLegibleViewController.self),bundle: Bundle(for: EZPlayerAudibleLegibleViewController.self),player:player, sourceView:sender as? UIView)
        EZPlayerUtils.viewController(from: self)?.present(audibleLegibleViewController, animated: true, completion: {

        })
    }



    @IBAction public func backButtonPressed(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        
        if MediaManager.sharedInstance.isOpenCurrnetlyForReels {
            NotificationCenter.default.post(name: Notification.Name.notifyReelsCompleted, object: nil)
            return
        }
        
//        let floatModelSupported = EZPlayerUtils.floatModelSupported(player)
        let displayMode = player.displayMode
        if displayMode == .fullscreen {
            if player.lastDisplayMode == .embedded{
                (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()
                player.toEmbedded()
            }else  if player.lastDisplayMode == .float{
                player.toFloat()
            }
        }
//        else if(displayMode == .float){
//
//        }
        (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()
        player.backButtonBlock?(displayMode)
    }

    @IBAction public func pipButtonPressed(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        player.toFloat()
    }

    // MARK: - EZPlayerGestureRecognizer
    public func player(_ player: EZPlayer, singleTapGestureTapped singleTap: UITapGestureRecognizer) {
        player.setControlsHidden(!player.controlsHidden, animated: true)

    }

    public func player(_ player: EZPlayer, doubleTapGestureTapped doubleTap: UITapGestureRecognizer) {
        self.playPauseButtonPressed(doubleTap)
    }

    // MARK: - EZPlayerHorizontalPan
    public func player(_ player: EZPlayer, progressWillChange value: TimeInterval) {
        if player.isLive ?? true{
            return
        }
        self.showControlView(true)
        cancel(self.hideControlViewTask)
        self.isProgressSliderSliding = true
    }

    public func player(_ player: EZPlayer, progressChanging value: TimeInterval) {
        if player.isLive ?? true{
            return
        }
        self.timeLabel.text = EZPlayerUtils.formatTime(position: value, duration: self.player?.duration ?? 0)
        if !self.timeSlider.isTracking {
            self.timeSlider.value = Float(value)
        }

//        self.showThumbnail()
    }

    public func player(_ player: EZPlayer, progressDidChange value: TimeInterval) {
        if player.isLive ?? true{
            return
        }
        self.autohideControlView()
        //        self.isProgressSliderSliding = false
        self.player?.seek(to: value, completionHandler: { (isFinished) in
            self.isProgressSliderSliding = false

        })
    }

    // MARK: - EZPlayerDelegate

    public func playerHeartbeat(_ player: EZPlayer) {
//        if let asset = player.playerasset, let  playerIntem = player.playerItem ,playerIntem.status == .readyToPlay{
//            if asset.audios != nil || asset.subtitles != nil || asset.closedCaption != nil{
//                self.audioSubtitleCCButtonWidthConstraint.constant = 50
//            }else{
//                self.audioSubtitleCCButtonWidthConstraint.constant = 0
//            }
//        }
//        self.airplayContainer.isHidden = !player.allowsExternalPlayback
//        self.pipButtonWidthConstraint.constant = (player.scrollView != nil || player.floatMode == .none || player.displayMode == .float || player.displayMode == .none) ? 0 : 50

    }


    public func player(_ player: EZPlayer, playerDisplayModeDidChange displayMode: EZPlayerDisplayMode) {
        switch displayMode {
        case .none:
            break
        case .embedded:
            self.fullEmbeddedScreenButtonWidthConstraint.constant = 50
            self.fullEmbeddedScreenButton.setImage(UIImage(named: "btn_fullscreen22x22", in: Bundle(for: EZPlayerControlView.self), compatibleWith: nil), for: .normal)
//            self.pipButtonWidthConstraint.constant = (player.scrollView != nil || player.floatMode == .none ) ? 0 : 50
        case .fullscreen:
            self.fullEmbeddedScreenButtonWidthConstraint.constant = 50
            self.fullEmbeddedScreenButton.setImage(UIImage(named: "btn_normalscreen22x22", in: Bundle(for: EZPlayerControlView.self), compatibleWith: nil), for: .normal)
            if player.lastDisplayMode == .none{
                self.fullEmbeddedScreenButtonWidthConstraint.constant = 0
            }
//            self.pipButtonWidthConstraint.constant = (player.scrollView != nil || player.floatMode == .none) ? 0 : 50
        case .float:
            self.fullEmbeddedScreenButtonWidthConstraint.constant = 0
//            self.pipButtonWidthConstraint.constant = 0
            break

        }
    }

    public func player(_ player: EZPlayer, playerStateDidChange state: EZPlayerState) {
        //播放器按钮状态
        switch state {
        case .playing ,.buffering:
            //播放状态
            //            self.playPauseButton.isSelected = true //暂停按钮
            self.playPauseButton.setImage(UIImage(named: "btn_pause22x22", in: Bundle(for: EZPlayerControlView.self), compatibleWith: nil), for: .normal)

        case .seekingBackward ,.seekingForward:
            break
        default:
            //            self.playPauseButton.isSelected = false // 播放按钮
            self.playPauseButton.setImage(UIImage(named: "btn_play22x22", in: Bundle(for: EZPlayerControlView.self), compatibleWith: nil), for: .normal)

        }



        //        switch state {
        //        case  .playing ,.pause,.seekingForward,.seekingBackward,.stopped,.bufferFinished:
        //            self.loading.stop()
        //            break
        //        default:
        //            self.loading.start()
        //            break
        //        }

    }

    public func player(_ player: EZPlayer, bufferDurationDidChange bufferDuration: TimeInterval, totalDuration: TimeInterval) {
        if totalDuration.isNaN || bufferDuration.isNaN || totalDuration == 0 || bufferDuration == 0{
            self.progressView.progress = 0
        }else{
            self.progressView.progress = Float(bufferDuration/totalDuration)
        }
    }

    public func player(_ player: EZPlayer, currentTime: TimeInterval, duration: TimeInterval) {
        
        if let captions = MediaManager.sharedInstance.currentCaptions {
            
            let time = currentTime
            if time != self.currTime {
                
                self.currTime = time
                self.updateSubTitlesWithTime(currTime: (currentTime), captions: captions)

            }
        }
        
        if currentTime.isNaN || (currentTime == 0 && duration.isNaN){
            return
        }
        
//        if (player.currentTime ?? 0) > 0.3 && UIDevice.current.orientation == .portrait && MediaManager.sharedInstance.isOpenCurrnetlyForReels && MediaManager.sharedInstance.currentOrientationChanged  {
//            //            backButtonPressed(UIButton())
//
////            NotificationCenter.default.post(name: Notification.Name.notifyReelsCompleted, object: nil)
//
//        }
        
        if (player.currentTime ?? 0) >= (player.duration ?? 0) && MediaManager.sharedInstance.isOpenCurrnetlyForReels {
//            backButtonPressed(UIButton())
            NotificationCenter.default.post(name: Notification.Name.notifyReelsCompleted, object: nil)
        }
        
        self.timeSlider.isEnabled = !duration.isNaN
        self.timeSlider.minimumValue = 0
        self.timeSlider.maximumValue = duration.isNaN ? Float(currentTime) : Float(duration)
        self.titleLabel.text = player.contentItem?.title ?? player.playerasset?.title
        if !self.isProgressSliderSliding {
            self.timeSlider.value = Float(currentTime)
            self.timeLabel.text = duration.isNaN ? "Live" : EZPlayerUtils.formatTime(position: currentTime, duration: duration)
        }
        
        
    }


    public func player(_ player: EZPlayer, playerControlsHiddenDidChange controlsHidden: Bool, animated: Bool) {
        if controlsHidden {
            self.hideControlView(animated)
        }else{
            self.showControlView(animated)
        }
    }

    public func player(_ player: EZPlayer ,showLoading: Bool){
        if showLoading {
            self.loading.start()
        }else{
            self.loading.stop()
        }
    }





}



// Subtitles

extension EZPlayerControlView {
    
    func setupSubTitleForReels(label: UILabel, containerView:UIView, caption:Captions) {
        
        let aniName = (caption.animation ?? "").isEmpty ? "" : caption.animation ?? ""
        var aniDuration = (caption.animation_duration ?? 0) <= 0 ? 2000 : caption.animation_duration ?? 2000
        aniDuration = aniDuration / 1000 //(ms/1000)milliseconds to seconds

        if let position = caption.position {
                        
            var containerViewTrailing: CGFloat = 0.0
            var containerViewBottom: CGFloat = 0.0
            var containerViewTop: CGFloat = 0.0
            var containerViewLeading: CGFloat = 0.0
            
            let xPosition = (self.viewSubTitle.frame.size.width * CGFloat(position.x ?? 0)) / 100
            let yPosition = (self.viewSubTitle.frame.size.height * CGFloat(position.y ?? 0)) / 100
    
            if let margin = caption.margin {
                
                containerViewTrailing = CGFloat(margin.right ?? 0.0)
                containerViewBottom = CGFloat(margin.bottom ?? 0.0)
                containerViewTop = CGFloat(margin.top ?? 0.0)
                containerViewLeading = CGFloat(margin.left ?? 0.0)
            }
            
            
            if caption.y_direction == "top" {
                
                containerView.constrain(to: viewSubTitle).top(constant: yPosition + containerViewTop)
                containerView.constrain(to: viewSubTitle).bottom(.greaterThanOrEqual, constant: xPosition + containerViewBottom, multiplier: 0.5, priority: .defaultLow, activate: false)
                
                if caption.rotation != 0 {
                    
                    print("side Label-- Top")
                    containerView.constrain(to: viewSubTitle).leading( multiplier: 0.5, priority: .defaultLow, activate: false)
                }
                else {
                    
                    containerView.constrain(to: viewSubTitle).leading(constant: xPosition + containerViewLeading)
                    if let wrapping = caption.wrapping, wrapping == true {
                        
                        containerView.constrain(to: viewSubTitle).trailing(.greaterThanOrEqual, constant: xPosition + containerViewTrailing)
                    }
                    else {
                        
                        containerView.constrain(to: viewSubTitle).trailing(constant: xPosition + containerViewTrailing)
                    }
                }
            }
            else {
                
                containerView.constrain(to: viewSubTitle).bottom(constant: yPosition + containerViewBottom)
                containerView.constrain(to: viewSubTitle).top(.greaterThanOrEqual, constant: xPosition + containerViewTop, multiplier: 0.5, priority: .defaultLow, activate: false)
                
                if caption.rotation != 0 {
                    
                    print("side Label-- Bottom")
                    containerView.constrain(to: viewSubTitle).leading( multiplier: 0.5, priority: .defaultLow, activate: false)
           
                } else {
                    
                    
                    containerView.constrain(to: viewSubTitle).leading(constant: xPosition + containerViewLeading)
                    if let wrapping = caption.wrapping, wrapping == true {
                        
                        containerView.constrain(to: viewSubTitle).trailing(.greaterThanOrEqual, constant: xPosition + containerViewTrailing)
                        
                    }
                    else {
                        
                        containerView.constrain(to: viewSubTitle).trailing(constant: xPosition + containerViewTrailing)
                    }
                }
            }
            if let padding = caption.padding {
              
                label.constrain(to: containerView).leading(constant: CGFloat(padding.left ?? 0.0))
                label.constrain(to: containerView).trailing(constant: CGFloat(padding.right ?? 0.0))
                label.constrain(to: containerView).top(constant: CGFloat(padding.top ?? 0.0))
                label.constrain(to: containerView).bottom(constant: CGFloat(padding.bottom ?? 0.0))
            }
            
        }
        
        if (caption.sentence ?? "").detectRightToLeft() {
            if caption.alignment == "left" {
                
                label.textAlignment = .right
            }
            else if caption.alignment == "center" {
                
                label.textAlignment = .center
            }
            else {
                
                label.textAlignment = .left
            }
        }
        else {
            if caption.alignment == "left" {
                
                label.textAlignment = .left
            }
            else if caption.alignment == "center" {
                
                label.textAlignment = .center
            }
            else {
                
                label.textAlignment = .right
            }
        }

        
       // if caption.rotation != 0 {
        label.numberOfLines = caption.rotation != 0 ? 1 : 0
        label.sizeToFit()
        
        if let bgColor = caption.text_background, bgColor.isEmpty || bgColor == "" {
            
            containerView.backgroundColor = .clear
        }
        else {
            
            containerView.backgroundColor = caption.text_background?.hexStringToUIColor()
        }
     //   containerView.backgroundColor = .red
        containerView.cornerRadius = CGFloat(caption.corner_radius)
        containerView.clipsToBounds = true
        containerView.alpha = 0
        
        if caption.rotation != 0 {
            
            containerView.alpha = 1.0
        }
        else {
            
            if aniName.contains("fade_in") {
                
                UIView.transition(with: containerView, duration: aniDuration, options: .transitionCrossDissolve,
                  animations: {
                    containerView.alpha = 1.0
                  },completion: nil)
            }
            else if aniName.contains("zoom_in") {
                
                containerView.transform = CGAffineTransform.identity.scaledBy(x: 0.2, y: 0.2)
                UIView.animate(withDuration: aniDuration, delay: 0.0, options: .curveEaseIn, animations: {
                        
                    containerView.alpha = 1.0
                    containerView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1) // Scale your image

                 }) { (finished) in
                     UIView.animate(withDuration: aniDuration, animations: {
                       
                         containerView.transform = CGAffineTransform.identity // undo in 1 seconds
                   })
                }
            }
            else if aniName.contains("curveEase_Out") {
                
                UIView.transition(with: containerView, duration: aniDuration, options: .curveEaseOut,
                  animations: {
                    containerView.alpha = 1.0
                  },completion: nil)
            }
            else if aniName.contains("curve_Linear") {
                
                UIView.transition(with: containerView, duration: aniDuration, options: .curveLinear,
                  animations: {
                    containerView.alpha = 1.0
                  },completion: nil)
            }
            containerView.alpha = 1.0
        }
        
        let isClickable = caption.is_clickable ?? false
        let actionName = caption.action ?? ""

//        if isClickable {
//            let tapClick = UITapGestureRecognizer(target: self, action: #selector(singleTapClickable(_:)))
//            tapClick.numberOfTapsRequired = 1
//            tapClick.view?.accessibilityIdentifier = actionName
//            containerView.isUserInteractionEnabled = true
//            containerView.addGestureRecognizer(tapClick)
//        }
    }
    
//    @objc func singleTapClickable(_ sender: UITapGestureRecognizer) {
//
//        let actionType = sender.view?.accessibilityIdentifier ?? ""
//        if !actionType.isEmpty {
//            self.delegate?.didTapOpenCaptionType(cell: self, action: actionType)
//        }
//    }
    
    func updateSubTitlesWithTime(currTime: Double, captions:[Captions]) {
        
        print("Video add label called")
        //I'm checking all caption with loop. using Index as caption id
        for (index, caption) in captions.enumerated() {
            
            // Skip iteration
            if caption.landscape == false {
                continue
            }
            
            //If we are getting only one caption and that is source name for right side alignment then i'm showing default
        
            if let duration = caption.duration {
                
                var startTime = 0.0
                var endTime = 0.0
                if let timeMS = duration.start {
                    
                    startTime = (timeMS / 1000)
                }
                if let timeMS = duration.end {
                    
                    endTime = (timeMS / 1000)
                }
                
                if SharedManager.shared.isCaptionsEnableReels == false {
                    
                    if viewSubTitle != nil && captionsArr?.count ?? 0 > 0 {
                        
                        for (i, captionRemoved) in captions.enumerated() {
                            
                            if let viewCaption = self.viewSubTitle.viewWithTag(i + 1) {
                                
                                if captionRemoved.forced == false {
                                    
                                    let labels = getLabelsInView(view:viewCaption)
                                    for captionLabel in labels {
                                        
                                        if captionLabel.tag == viewCaption.tag {
                                     
                                            captionLabel.removeFromSuperview()
                                            self.captionsArr?.remove(object: captionLabel)
                                        }
                                    }
                                    
                                    viewCaption.removeFromSuperview()
                                    self.captionsViewArr?.remove(object: viewCaption)
                                    
                                }
                            }
                        }
                    }
                }
                
                //I'm checking the Caption that are in current video time
                if currTime >= startTime && currTime <= endTime {
                    
                    //Here i'm checking on the base captions array count that i have captions or not
                    if let captionsArray = captionsArr, captionsArray.count >= 0 {
                        
                        if captionsArray.contains(where: {$0.tag == index + 1}) {
                            
                            if viewSubTitle != nil, let viewCaption = self.viewSubTitle.viewWithTag(index + 1) {
                                
                                if currTime >= endTime {
                                    
                                    //we need to hide both view and label
                                    let labels = getLabelsInView(view:viewCaption)
                                    for captionLabel in labels {
                                        
                                        if captionLabel.tag == viewCaption.tag {
                                            
                                            captionLabel.removeFromSuperview()
                                            self.captionsArr?.remove(object: captionLabel)
                                        }
                                    }
                                   
                                    viewCaption.removeFromSuperview()
                                    self.captionsViewArr?.remove(object: viewCaption)
                                    
                                }
                                else {
                                    
                                    //If captions time not over then i'm updating text only
                                    if let captionLabel = viewCaption.viewWithTag(viewCaption.tag) as? UILabel {
                                        
                                        self.updateSelectedSubTitleLable(label: captionLabel, caption: caption, containerView: viewCaption)
                                    }
                                    
                                }
                            }
                        }
                        else {
                            
                            //Multi captions
                            // If we have news caption then i'm creating.
                            
                            //If caption is off by user butt still we need to show caption.
                            if SharedManager.shared.isCaptionsEnableReels == false && caption.forced == false {
                         
                            }
                            else {
                                
                                let containerView = UIView()
                                let label = UILabel()
                                
                                self.setupSubTitleForReels(label: label, containerView: containerView, caption: caption)
                                label.tag = index + 1
                                containerView.tag = index + 1
                         
                                self.captionsArr?.append(label)
                                self.captionsViewArr?.append(containerView)
                                self.updateSelectedSubTitleLable(label: label, caption: caption, containerView: containerView)
                            }
                        }
                    }
                    else {
                        
                        
                        //The very 1st caption
                        //If caption is off by user butt still we need to show caption.
                        if SharedManager.shared.isCaptionsEnableReels == false && caption.forced == false {
                            
                            
                        }
                        else {
                            
                            let containerView = UIView()
                            let label = UILabel()
                            
                            self.setupSubTitleForReels(label: label, containerView: containerView, caption: caption)
                            label.tag = index + 1
                            containerView.tag = index + 1
                            
                            self.captionsArr?.removeAll()
                            self.captionsViewArr?.removeAll()
                            
                            self.captionsArr = [UILabel]()
                            self.captionsViewArr = [UIView]()
                            
                            self.captionsArr?.append(label)
                            self.captionsViewArr?.append(containerView)
                            
                            self.updateSelectedSubTitleLable(label: label, caption: caption, containerView: containerView)
                            
                        }
                    }
                }
                else {
                    
                    // For fixing overlapping issues added this
                    // remove labels if still showing after time period
                    self.viewSubTitle.viewWithTag(index + 1)?.removeFromSuperview()
                    
                    if let captionsArr = captionsArr {
                        for label in captionsArr {
                            if label.tag == index + 1 {
                                label.removeFromSuperview()
                                self.captionsArr?.remove(object: label)
                            }
                        }
                    }
                    
                    if let captionsViewArr = captionsViewArr {
                        for viewCaption in captionsViewArr {
                            if viewCaption.tag == index + 1 {
                                viewCaption.removeFromSuperview()
                                self.captionsViewArr?.remove(object: viewCaption)
                            }
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    func updateSelectedSubTitleLable(label: UILabel, caption: Captions, containerView: UIView) {
        
        if let words = caption.words {
            
            if words.count == 1 {
                
                let color = words.first?.font?.color ?? ""
                let word = words.first?.word ?? ""
                let size = words.first?.font?.size ?? 22
                let shadowColor = words.first?.shadow?.color ?? "#000000"
                let style = SharedManager.shared.getFamilyName(font: words.first?.font)

                var highlightColor: UIColor = .clear
                if let color = words.first?.highlight_color, color == "" {
                    
                    highlightColor = UIColor(r: 0, g: 0, b: 0, a: 0)
                }
                else {
                    
                    highlightColor = (words.first?.highlight_color ?? "").hexStringToUIColor()
                }
                
                let shadow = NSShadow()
                shadow.shadowColor = shadowColor.hexStringToUIColor()
                shadow.shadowOffset = CGSize(width: words.first?.shadow?.x ?? 0, height: words.first?.shadow?.y ?? 0)
                shadow.shadowBlurRadius = CGFloat(words.first?.shadow?.radius ?? 0)
//                if words.first?.shadow_color == nil {
//                    shadow.shadowBlurRadius = 0
//                } else {
//                    shadow.shadowBlurRadius = 3
//                }
                

                var myAttribute = [NSAttributedString.Key : Any]()
                if let isUnderLine = words.first?.underline, isUnderLine {
                    
                    myAttribute = [.foregroundColor: color.hexStringToUIColor(),
                                   .font: UIFont(name: style, size: CGFloat(size)) ?? UIFont.boldSystemFont(ofSize: 18),
                                   .underlineStyle:NSUnderlineStyle.single.rawValue,
                                   .backgroundColor:highlightColor,
                                   .strokeColor: shadowColor.hexStringToUIColor(),
                                   .strokeWidth: -1.5,
                                   .shadow: shadow] as [NSAttributedString.Key : Any]
                }
                else {
                    
                    myAttribute = [.foregroundColor: color.hexStringToUIColor(),
                                   .font: UIFont(name: style, size: CGFloat(size)) ?? UIFont.boldSystemFont(ofSize: 18),
                                   .backgroundColor:highlightColor,
                                   .strokeColor: shadowColor.hexStringToUIColor(),
                                   .strokeWidth: -1.5,
                                   .shadow: shadow] as [NSAttributedString.Key : Any]
                }
                
                let myString = NSMutableAttributedString(string: word, attributes: myAttribute)
                
                label.attributedText =  myString
    
                
                if let imageBG = caption.image_background, imageBG != "" && label.text != "" {
                     
                    let image = UIImageView()
                    let width = label.frame.size.width
                    let height = label.frame.size.height
                    image.frame = CGRect(x: 0, y: 0, width: width, height: height)
                    image.constrain(to: containerView).leading(constant: 0.0)
                //    image.constrain(to: containerView).trailing(constant: 0.0)
//                    image.constrain(to: containerView).top(constant: 0.0)
//                    image.constrain(to: containerView).bottom(constant: 0.0)
                    image.contentMode = .scaleToFill
                    image.clipsToBounds = true
                    image.sd_setImage(with: URL(string: imageBG))
                    containerView.bringSubviewToFront(label)
                }
                
                if caption.rotation != 0 {
                    
                    print("side Label single word")
                    
                    self.viewSubTitle.layoutIfNeeded()
                    containerView.layoutIfNeeded()
                    
                    let xPosition = (self.viewSubTitle.frame.size.width * CGFloat(caption.position?.x ?? 0)) / 100
                    let width = (label.frame.size.width / 2)  + (label.frame.size.height / 2)
                    var trailingSpace = self.viewSubTitle.frame.size.width - (xPosition + CGFloat(caption.margin?.left ?? 0.0))
                    trailingSpace = trailingSpace - width

                    let rotation = CGFloat(caption.rotation ?? 90.0)
                    let angle = ((rotation * -1.0) * CGFloat.pi/180.0)
                    containerView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))

                    containerView.constrain(to: viewSubTitle).trailing(constant:(trailingSpace))
                    containerView.constrain(to: viewSubTitle).leading( multiplier: 0.5, priority: .defaultLow, activate: false)
                    
                    self.viewSubTitle.layoutIfNeeded()
                    containerView.layoutIfNeeded()
                    
                }
            }
            else {
                
                var i = 0
                var attrStringArr = [NSMutableAttributedString]()
                
                let delay = words[i].delay ?? 0
                Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { (timer) in
                    
                    //label.text = label.text! + String(words[i].word ?? "") + " "
                    let color = words[i].font?.color ?? "#000000"
                    let shadowColor = words[i].shadow?.color ?? "#000000"
                    let word = words[i].word ?? ""
                    let size = words[i].font?.size ?? 22
                    let styl = SharedManager.shared.getFamilyName(font: words[i].font)
                    

                    var highlightColor: UIColor = .clear
                    if let color = words[i].highlight_color, color == "" {
                        
                        highlightColor = UIColor(r: 0, g: 0, b: 0, a: 0)
                    }
                    else {
                        //print("mahesh....", words.first?.word ?? "", words.first?.highlight_color ?? "")
                        highlightColor = (words[i].highlight_color ?? "").hexStringToUIColor()
                    }
                    
                    let shadow = NSShadow()
                    shadow.shadowColor = shadowColor.hexStringToUIColor()
                    shadow.shadowOffset = CGSize(width: words[i].shadow?.x ?? 0, height: words[i].shadow?.y ?? 0)
                    shadow.shadowBlurRadius = CGFloat(words.first?.shadow?.radius ?? 0)
//                    if words[i].shadow?.color == nil {
//                        shadow.shadowBlurRadius = 0
//                    }
//                    else {
//                        shadow.shadowBlurRadius = 3
//                    }
//

                    var myAttribute = [NSAttributedString.Key : Any]()
                    if words[i].underline ?? false {
                        
                        myAttribute = [.foregroundColor: color.hexStringToUIColor(),
                                        .font: UIFont(name: styl, size: CGFloat(size)) ?? UIFont.boldSystemFont(ofSize: 14),
                                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                                        .backgroundColor: highlightColor,
                                       .strokeColor: shadowColor.hexStringToUIColor(),
                                       .strokeWidth: -1.5,
                                        .shadow: shadow] as [NSAttributedString.Key : Any]
                    }
                    else {
                        
                        myAttribute = [.foregroundColor: color.hexStringToUIColor(),
                                       .font: UIFont(name: styl, size: CGFloat(size)) ?? UIFont.boldSystemFont(ofSize: 14),
                                       .backgroundColor: highlightColor,
                                       .strokeColor: shadowColor.hexStringToUIColor(),
                                       .strokeWidth: -1.5,
                                       .shadow: shadow] as [NSAttributedString.Key : Any]
                    }
                    
                    let myString = NSMutableAttributedString(string: word, attributes: myAttribute)

                    label.attributedText = myString
                    attrStringArr.append(myString)

                    let mergeString = NSMutableAttributedString()
                    for attstr in attrStringArr {
                        mergeString.append(attstr)
                    }
                    label.attributedText = mergeString

   
                    if i == words.count - 1 {
                        timer.invalidate()
                    } else {
                        i = i + 1
                    }
                }
            }
            label.isHidden = false
       
            if let imageBG = caption.image_background, imageBG != "" && label.text != "" {
                
                let image = UIImageView()
                let width = label.frame.size.width
                let height = label.frame.size.height
                image.frame = CGRect(x: 0, y: 0, width: width, height: height)
                image.constrain(to: containerView).leading(constant: 0.0)
//                image.constrain(to: containerView).trailing(constant: 0.0)
//                image.constrain(to: containerView).top(constant: 0.0)
//                image.constrain(to: containerView).bottom(constant: 0.0)
                image.contentMode = .scaleToFill
                image.clipsToBounds = true
               // image.image = UIImage(named: "testBG")
                image.sd_setImage(with: URL(string: imageBG))
                containerView.bringSubviewToFront(label)
            }
            if caption.rotation != 0 {

                print("side Label Multi word")

                containerView.layoutIfNeeded()
                let xPosition = (self.viewSubTitle.frame.size.width * CGFloat(caption.position?.x ?? 0)) / 100
                let width = (label.frame.size.width / 2) + (label.frame.size.height / 2)
                var trailingSpace = self.viewSubTitle.frame.size.width - (xPosition + CGFloat(caption.margin?.left ?? 0.0))
                trailingSpace = trailingSpace - width
                
                let rotation = CGFloat(caption.rotation ?? 90.0)
                let angle = ((rotation * -1.0) * CGFloat.pi/180.0)
                containerView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
                
               // containerView.transform = CGAffineTransform(rotationAngle: .pi/2*3)
                containerView.constrain(to: viewSubTitle).trailing(constant:(trailingSpace))
                containerView.layoutIfNeeded()
                containerView.constrain(to: viewSubTitle).leading( multiplier: 0.5, priority: .defaultLow, activate: false)
            }
        }
    }

    func getLabelsInView(view: UIView) -> [UILabel] {
        var results = [UILabel]()
        for subview in view.subviews as [UIView] {
            if let labelView = subview as? UILabel {
                results += [labelView]
            } else {
                results += getLabelsInView(view: subview)
            }
        }
        return results
    }
}

