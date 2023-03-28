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
import Foundation

internal let CELL_IDENTIFIER_SCHEDULE_VIDEO           = "ScheduleVideoCC"

protocol ScheduleVideoCCDelegates: AnyObject {
    
    func resetSelectedArticle()
    func autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: Bool)
    func focusedIndex(index:Int)
    func didSelectCell(cell: ScheduleVideoCC)
}

class ScheduleVideoCC: UITableViewCell {
    
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSource: UIButton!
    @IBOutlet weak var imgWifi: UIImageView!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblVideoTime: UILabel!
    @IBOutlet weak var viewDuration: UIView!

    @IBOutlet weak var viewGestures: UIView!
    @IBOutlet weak var lblVideoBullet: UILabel!
    
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgPlaceHolder: UIImageView!
    
    @IBOutlet weak var btnVolume: UIButton!
    @IBOutlet weak var viewComment: UIView!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var lblCommentsCount: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    
    @IBOutlet weak var ctVideoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var imgComment: UIImageView!
    
    @IBOutlet weak var lblAuthor: UILabel!
    
    //View Header Timer
    @IBOutlet weak var viewHeaderTimer: UIView!
    @IBOutlet weak var imgTimer: UIImageView!
    @IBOutlet weak var lblPostTimer: UILabel!
    
    //View Option Meu Footer
    @IBOutlet weak var viewOptionPost: UIView!
    @IBOutlet weak var viewPostArticle: UIView!
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var lblPost: UILabel!

    @IBOutlet weak var imgEdit: UIImageView!
    @IBOutlet weak var lblEdit: UILabel!

    @IBOutlet weak var imgDelete: UIImageView!
    @IBOutlet weak var lblDelete: UILabel!
    
    @IBOutlet weak var viewLikeCommentBG: UIView!
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!

    @IBOutlet weak var ctViewHeaderTimerHeight: NSLayoutConstraint!
    @IBOutlet weak var ctViewOptionPostHeight: NSLayoutConstraint!

    
    var bullets: [Bullets]?
    var swipeGesture = UISwipeGestureRecognizer()
    
    weak var delegate: ScheduleVideoCCDelegates?
//    weak var delegateLikeComment: LikeCommentDelegate?
    var player = RegularPlayer()
    var isVideoPaused = false
    var manualPlay = false
    var status = ""
    
    private var timer: Timer?
    private var timeInterval: TimeInterval = 0
    var pubDate: String = "" {
        didSet {
            startTimer()
        }
    }
        
    override func awakeFromNib() {
        
        super.awakeFromNib()

        timer?.invalidate()

    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.viewContainer.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor //GlobalPicker.backgroundColorHomeCell
        self.lblVideoBullet.theme_textColor = GlobalPicker.textBWColor
        lblSource.theme_textColor = GlobalPicker.textBWColor
        imgTimer.theme_image = GlobalPicker.imgTimePicker
        lblPostTimer.theme_textColor = GlobalPicker.textBWColor
        lblAuthor.theme_textColor = GlobalPicker.textColor

        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .highlighted)
        
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
        
        self.viewVideo.cornerRadius = 12
        self.viewVideo.layer.masksToBounds = true
        self.viewVideo.clipsToBounds = true
    }
    
    private func startTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onComplete), userInfo: nil, repeats: true)
        timer?.fire()
    }

    @objc func onComplete() {
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        //Check pulbished date is nil with format
        if let pDate = dateFormatter.date(from: pubDate), let currDate = dateFormatter.date(from: SharedManager.shared.localToUTC(date: Date())) {
            
            let componentsPdate = pDate.get(.year)
            let componentsCurrentDate = currDate.get(.year)
            
            if componentsPdate != componentsCurrentDate {
                timer?.invalidate()
                timer = nil
                lblPostTimer.text = "\(NSLocalizedString("Will be posted on", comment: "")) \(pDate.dateString("MMM dd, yyyy hh:mm a"))"
            }
            else {
                    
                timeInterval = pDate - currDate
                
                let hours = Int(timeInterval) / 3600
                if hours > 24 {
                    
                    timer?.invalidate()
                    timer = nil
                    lblPostTimer.text = "\(NSLocalizedString("Will be posted on", comment: "")) \(pDate.dateString("MMM dd, hh:mm a"))"
                }
                else {
                    
                    if timeInterval <= 0 {
                        timer?.invalidate()
                        timer = nil
                        lblPostTimer.text = NSLocalizedString("Will be posted now", comment: "")
                        return
                    }
                    lblPostTimer.text = "\(NSLocalizedString("Will be posted in", comment: "")) \(timeInterval.stringTime)"
                }
            }
        }
    }

    func setupSlideScrollView(bullets: [Bullets], article: articlesData, row: Int, isAutoPlay: Bool) {
                
        var videoRatio = CGFloat((article.media_meta?.width ?? 1) / (article.media_meta?.height ?? 1))
        if videoRatio.isNaN {
            videoRatio = 1.7
        }
        
        
        var newHeight = (UIScreen.main.bounds.width - 40) / videoRatio
        newHeight = newHeight > (UIScreen.main.bounds.height * 0.7) ? UIScreen.main.bounds.height * 0.7 : newHeight
        ctVideoHeight.constant = newHeight
        
        status = article.status ?? ""
        if let url = URL(string: article.link ?? "") {
            
            self.player.pause()
            self.player.seek(to: 0)
            self.player.delegate = self
            self.addPlayerToView()
            self.player.set(AVURLAsset(url: url))
        }
        
        imgPlaceHolder.sd_setImage(with: URL(string: article.image ?? ""), placeholderImage: nil)
        imgPlaceHolder.isHidden = false
        
        self.btnVolume.isHidden = true
        if SharedManager.shared.videoAutoPlay {
            self.videoControllerStatusOnCellSetup(isHidden: true)
        }
        else {
            self.videoControllerStatusOnCellSetup(isHidden: false)
        }
        
        if isAutoPlay {
            
            if SharedManager.shared.isAudioEnable == false {
                
                player.volume = 0
                btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
            }
            else {
                
                player.volume = 1
                btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
            }
            
            self.btnVolume.isHidden = false
            self.slider.value = 0
            player.seek(to: .zero)
            
            if SharedManager.shared.videoAutoPlay {
                
                player.play()
                self.videoControllerStatusOnCellSetup(isHidden: true)
            }
            else {
                
                self.videoControllerStatusOnCellSetup(isHidden: false)
            }
            SharedManager.shared.performWSToUpdateArticleAnalytics(ArticleId: article.id ?? "", isFromReel: false)
            
        }
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
    }
    
    // MARK: Setup Player
    private func addPlayerToView() {
        
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.frame = self.viewVideo.frame
        player.fillMode = .fit
        self.viewVideo.insertSubview(player.view, at: 0)
        
        self.viewVideo.cornerRadius = 12
        self.viewVideo.layer.masksToBounds = true
        self.viewVideo.clipsToBounds = true
 
        self.viewVideo.layoutIfNeeded()
        for view in self.viewVideo.subviews {
            view.layoutIfNeeded()
            view.clipsToBounds = true
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 12
        }
        
    }
    
    func resetVisibleVideoPlayer() {
        
     //   imgPlay.image = UIImage(named: "youtubePlay_Icon")
       // btnVolume.isHidden = true
    //    player.volume = 0
        player.pause()
        player.seek(to: .zero)
        self.videoControllerStatus(isHidden: true)
        
//        self.videoPlayer.pause()
//        self.videoPlayer.seek(to: 0)
    }
    
    func setLikeComment(model: Info?) {
        
        if model?.isLiked ?? false {
            
            imgLike.theme_image = GlobalPicker.likedImage
            lblLikeCount.theme_textColor = GlobalPicker.likeCountColor
        }
        else {
            
            imgLike.theme_image = GlobalPicker.likeDefaultImage
            lblLikeCount.textColor = .gray
        }
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
    }
    
    func playVideo(isPause: Bool) {
        
        self.btnVolume.isHidden = false
        if SharedManager.shared.isAudioEnable == false {
            
            player.volume = 0
            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
        }
        else {
            
            player.volume = 1
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
        }
        
        if isPause {
            
            player.pause()
        }
        else {
            
            //if user pause the video and he went to category view.. I'm cheking video status
            if self.isVideoPaused {
                
                imgPlaceHolder.isHidden = false
                player.pause()
            }
            else {
                
                if SharedManager.shared.videoAutoPlay || manualPlay == true {
                    
                    manualPlay = false
                    self.videoControllerStatus(isHidden: true)
                    player.play()
                }
                else {
                    
                    self.videoControllerStatus(isHidden: false)
                }
            }
        }
    }
    
    func videoControllerStatusOnCellSetup(isHidden:Bool) {
        
        if isHidden {
            
            self.imgPlaceHolder.isHidden = true
            self.imgPlay.image = UIImage(named: "videoPause")
            //self.imgPlay.isHidden = true
            self.slider.isHidden = true
            //self.lblVideoTime.isHidden = true
            self.viewDuration.isHidden = true
        }
        else {
            
            if  player.time == 0 {
                
                self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
            }
            else {
                
                self.imgPlay.image = UIImage(named: "videoPause")
            }
            //self.imgPlay.isHidden = false
            self.slider.isHidden = false
            //self.lblVideoTime.isHidden = false
            self.viewDuration.isHidden = true
        }
    }
    
    func videoControllerStatus(isHidden:Bool) {
        
        if isHidden {
            
            self.imgPlaceHolder.isHidden = true
            self.imgPlay.image = UIImage(named: "videoPause")
            //self.imgPlay.isHidden = true
            self.slider.isHidden = true
            //self.lblVideoTime.isHidden = true
            self.viewDuration.isHidden = true
        }
        else {
            
            if  player.time == 0 {
                
                self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
            }
            else {
                
                self.imgPlay.image = UIImage(named: "videoPause")
            }
            //self.imgPlay.isHidden = false
            self.slider.isHidden = false
            //self.lblVideoTime.isHidden = false
            self.viewDuration.isHidden = false
        }
    }
    
    // MARK: Actions
    @IBAction func didTapPlayVideo(_ sender: UIButton) {
        
        imgPlaceHolder.isHidden = true
        self.isVideoPaused = false
        if self.viewDuration.isHidden  {
            
            if self.player.playing {
                
                self.videoControllerStatus(isHidden: false)
            }
            else {
                
                self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
                //self.imgPlay.isHidden = false
                self.btnVolume.isHidden = false
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
    }
    
    @IBAction func didSelectCell(_ sender: Any) {
        
        self.delegate?.didSelectCell(cell: self)
    }
    
//    @IBAction func didTapLikeButton(_ sender: Any) {
//
//        self.delegateLikeComment?.didTapLikeButton(cell: self)
//    }
//
//    @IBAction func didTapCommentButton(_ sender: Any) {
//        self.delegateLikeComment?.didTapCommentsButton(cell: self)
//    }
    
    
    @IBAction func didChangeSliderValue() {
        
        // player.pause()
        let value = Double(self.slider.value)
        let time = value * player.duration
        player.seek(to: time)
    }
    
    @IBAction func didTapVolume(_ sender: Any) {
        
        if SharedManager.shared.isAudioEnable {
            
            SharedManager.shared.isAudioEnable = false
            player.volume = 0
            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
            
        }
        else {
            
            SharedManager.shared.isAudioEnable = true
            player.volume = 1
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
            
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
}

extension ScheduleVideoCC: PlayerDelegate {
    
    // MARK: VideoPlayerDelegate
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        self.activityIndicator.isHidden = true
        
        switch player.state {
        case .loading:
            
            self.lblVideoTime.text = "00:00"
            self.activityIndicator.isHidden = false
            imgPlaceHolder.isHidden = true
            
        case .ready:
            
            self.lblVideoTime.text = "\(player.duration.stringFromTimeInterval())"
            
            if !SharedManager.shared.viewSubCategoryIshidden {
                self.playVideo(isPause: true)
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
        
        let ratio = player.time / player.duration
        
        if self.slider.isHighlighted == false {
            
            UIView.animate(withDuration: 0.3) {
                
                self.lblVideoTime.text = "\(player.time.stringFromTimeInterval()) / \(player.duration.stringFromTimeInterval()) "
                self.slider.value = Float(ratio)
            }
        }
        
        if player.duration <= player.time {
            
            self.videoControllerStatus(isHidden: false)
//            self.delegate?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
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

