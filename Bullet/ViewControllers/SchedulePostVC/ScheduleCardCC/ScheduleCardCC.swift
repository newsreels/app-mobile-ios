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

internal let CELL_IDENTIFIER_SCHEDULE_CARD         = "ScheduleCardCC"


public protocol ScheduleCardCCDelegate: AnyObject {
    
    func handleLongPressHold(_ gestureRecognizer: UILongPressGestureRecognizer)
    func autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: Bool)
    func layoutUpdate()
}

class ScheduleCardCC: UITableViewCell {
    
    //PROPERTIES
    @IBOutlet weak var viewImgBG: UIView!
    @IBOutlet weak var clvBullets: UICollectionView!
    @IBOutlet weak var imgDot: UIImageView!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSource: UIButton!
    @IBOutlet weak var imgWifi: UIImageView!
    @IBOutlet weak var viewGradientShadow: UIView!
    
    @IBOutlet weak var viewBlurBG: UIView!
    @IBOutlet weak var imgBG: UIImageView!
    @IBOutlet weak var imgPreLoaded: UIImageView!
    @IBOutlet weak var imgPreLoaded1: UIImageView!
    @IBOutlet weak var imgBlurBG: UIImageView!
    @IBOutlet weak var imgVolumeAnimation: UIImageView!
    @IBOutlet weak var imgVolumeStopAnimation: UIImageView!
    
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var viewSegmentProgress: UIView!
    
    @IBOutlet weak var lblDummy: UILabel!
    
//    @IBOutlet weak var viewCount: UIView!
//    @IBOutlet weak var lblViewCount: UILabel!
    
    @IBOutlet weak var btnVolume: UIButton!
    @IBOutlet weak var viewGestures: UIView!
    
    @IBOutlet weak var visualDarkViewBG: UIVisualEffectView!
    @IBOutlet weak var visualLightViewBG: UIVisualEffectView!
    @IBOutlet weak var viewFooter: UIView!

    // Animation view Outlets and varibale
    @IBOutlet weak var imgNext: UIImageView!
    @IBOutlet weak var imgPrevious: UIImageView!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var constraintArcHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintBulletLableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewLikeCommentBG: UIView!
    @IBOutlet weak var viewComment: UIView!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var lblCommentsCount: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var imgComment: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    
    // Segment Progress Bar Constraints
    @IBOutlet weak var progressbarBottom: NSLayoutConstraint!
    @IBOutlet weak var progressbarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressbarHeightConstraint: NSLayoutConstraint!
    
    //View Header Timer
    @IBOutlet weak var viewHeaderTimer: UIView!
    @IBOutlet weak var imgTimer: UIImageView!
    @IBOutlet weak var lblPostTimer: UILabel!
    
    //View Option Meu Footer
    @IBOutlet weak var viewOptionPost: UIView!
    @IBOutlet weak var viewPostArticle: UIView!
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var btnPost: UIButton!
    
    @IBOutlet weak var imgEdit: UIImageView!
    @IBOutlet weak var lblEdit: UILabel!
    @IBOutlet weak var btnEdit: UIButton!

    @IBOutlet weak var imgDelete: UIImageView!
    @IBOutlet weak var lblDelete: UILabel!
    @IBOutlet weak var btnDelete: UIButton!

    @IBOutlet weak var ctViewHeaderTimerHeight: NSLayoutConstraint!
    @IBOutlet weak var ctViewOptionPostHeight: NSLayoutConstraint!

    let progressbarTopConstraintNormal: CGFloat = 42
    let progressbarBottomNormal: CGFloat = 21
    let progressbarHeightConstraintNormal: CGFloat = 6
    
    
    var swipeGesture = UISwipeGestureRecognizer()
    weak var delegateScheduleCard: ScheduleCardCCDelegate?
    weak var delegateLikeComment: LikeCommentDelegate?
    var bullets: [Bullets]?
    
    //VARIABLES
    var isAutoScrolling = true
    var mp3Duration = 5.0
    private var longPressGesture = UILongPressGestureRecognizer()
    var currRow = 0
    var currPage = 0
    var currMutedPage = 0
    private var generator = UIImpactFeedbackGenerator()
    //    var arrCellSize = [CGSize]()
    var langCode = ""
    
    private var timer: Timer?
    private var timeInterval: TimeInterval = 0
    var pubDate: String = "" {
        didSet {
            startTimer()
        }
    }

    var bulletsMaxHeightIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()

        imgTimer.theme_image = GlobalPicker.imgTimePicker
        lblPostTimer.theme_textColor = GlobalPicker.textBWColor
        lblSource.theme_textColor = GlobalPicker.textBWColor
        lblAuthor.theme_textColor = GlobalPicker.textColor
        
        clvBullets.decelerationRate = UIScrollView.DecelerationRate.fast
        viewContainer.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor//GlobalPicker.backgroundColorHomeCell
        
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyAudioAndProgressBarStatus, object: nil)
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAudioAndProgressBarStatus(notification:)), name: Notification.Name.notifyAudioAndProgressBarStatus, object: nil)
    }
    
//    override func prepareForReuse() {
//        
//
//    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
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
        
        viewBlurBG.theme_backgroundColor = GlobalPicker.backgroundColor
        //self.theme_backgroundColor = GlobalPicker.backgroundColor
        
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
        
        
//        SharedManager.shared.spbCardView?.topColor = MyThemes.current == .dark ? "#E01335".hexStringToUIColor() : "#FA0815".hexStringToUIColor()
//        SharedManager.shared.spbCardView?.bottomColor = MyThemes.current == .dark ? UIColor.white.withAlphaComponent(0.30) : UIColor.black.withAlphaComponent(0.30)
        
        clvBullets.collectionViewLayout.invalidateLayout()
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            viewSegmentProgress.transform = CGAffineTransform(scaleX: -1, y: 1)
            btnRight.transform = CGAffineTransform(scaleX: -1, y: -1)
            btnLeft.transform = CGAffineTransform(scaleX: -1, y: -1)
            
        } else {
            viewSegmentProgress.transform = CGAffineTransform(scaleX: 1, y: 1)
            btnRight.transform = CGAffineTransform(scaleX: 1, y: 1)
            btnLeft.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
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
                lblPostTimer.text = "\(NSLocalizedString("Will be posted in", comment: "")) \(pDate.dateString("EE, MMM dd, yyyy hh:mm a"))"
            }
            else {
                    
                timeInterval = pDate - currDate
                
                let hours = Int(timeInterval) / 3600
                if hours > 96 {
                    
                    timer?.invalidate()
                    timer = nil
                    lblPostTimer.text = "\(NSLocalizedString("Will be posted in", comment: "")) \(pDate.dateString("EE, MMM dd, hh:mm a"))"
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

    
//    // MARK: - Actions
//    @IBAction func didTapLikeButton(_ sender: Any) {
//        self.delegateLikeComment?.didTapLikeButton(cell: self)
//    }
//
//    @IBAction func didTapCommentButton(_ sender: Any) {
//        self.delegateLikeComment?.didTapCommentsButton(cell: self)
//    }
        
    //MARK:- Notification Action
    @objc func updateAudioAndProgressBarStatus( notification: NSNotification) {
                
        self.pauseAudioAndProgress(isPause: SharedManager.shared.isPauseAudio)
    }
    
    
    // Progress Bar hide and show
    func showProgressBar() {
        
        progressbarBottom.constant = progressbarBottomNormal
        progressbarTopConstraint.constant = progressbarTopConstraintNormal
        progressbarHeightConstraint.constant = progressbarHeightConstraintNormal
        
    }
    
    func hideProgressBar() {
        
        progressbarBottom.constant = 0
        progressbarTopConstraint.constant = 0
        progressbarHeightConstraint.constant = 0
        
    }
    
    
    func updateCardVloumeStatus() {
        
        if SharedManager.shared.isAudioEnable {
            
            SharedManager.shared.isVolumeOn = true
            print("print 15...")
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.volume = 1.0
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
            do {
                let gif = try UIImage(gifName: "equalizer")
                self.imgVolumeAnimation.setGifImage(gif)
            } catch {
                print(error)
            }
      
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
            self.imgVolumeAnimation.showFrameAtIndex(0)
            self.imgVolumeAnimation.stopAnimatingGif()
            self.imgVolumeAnimation.isHidden = true
            self.imgVolumeStopAnimation.isHidden = false
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
        
        self.delegateScheduleCard?.handleLongPressHold(gestureRecognizer)
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
        
        bulletsMaxHeightIndex = 0
        //REMOVE SWIPE GESTURE
        SharedManager.shared.segementIndex = 0
        self.currPage = 0
        SharedManager.shared.isUserinteractWithHeadlinesOnly = false
        
        
        self.viewSegmentProgress.isHidden = true
//        self.viewCount.isHidden = true
        self.btnVolume.isHidden = true
        self.imgVolumeAnimation.showFrameAtIndex(0)
        self.imgVolumeAnimation.stopAnimatingGif()
        self.imgVolumeAnimation.clear()
        self.imgVolumeAnimation.image = nil
        self.imgVolumeAnimation.isHidden = true
        self.imgVolumeStopAnimation.isHidden = true
        
    }
    
    func setLikeComment(model: Info?) {
        
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
    }
    
    func setupSlideScrollView(article: articlesData, isAudioPlay: Bool, row: Int, isMute: Bool) {
        
        self.clvBullets.setContentOffset(.zero, animated: false)
        self.currRow = row
        self.currPage = 0
        self.currMutedPage = 0
        self.btnVolume.isHidden = true
        self.imgVolumeAnimation.isHidden = true
        self.clvBullets.isHidden = false
   
        
        self.viewSegmentProgress.isHidden = true
//        self.viewCount.isHidden = true
        
        self.bullets?.removeAll()
        self.bullets = article.bullets
        if self.bullets?.count == 0 {return}
        lblDummy.text = self.bullets?.first?.data
        lblDummy.font = SharedManager.shared.getCardViewTitleFont()
        lblDummy.sizeToFit()
        
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

        //called when selected cell is active
//        for gesture in self.viewGestures.gestureRecognizers! {
//            gesture.isEnabled = true
//        }
                
        if isAudioPlay {
            
            //VOLUMN MUTE/UNMUTE
            SharedManager.shared.isAudioMuted = isMute
            do {
                let gif = try UIImage(gifName: "equalizer")
                
                if imgVolumeAnimation.isAnimating {
                    
                    self.imgVolumeAnimation.clear()
                }
                self.imgVolumeAnimation.setGifImage(gif)
            } catch {
                print(error)
            }
            
            self.btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
            self.imgVolumeAnimation.startAnimatingGif()
            self.imgVolumeAnimation.isHidden = false
            self.imgVolumeStopAnimation.isHidden = true

            //Wave of audio should be hidden/show based on mute/unmute
//            if SharedManager.shared.isAudioEnable {
//
//                do {
//                    let gif = try UIImage(gifName: "equalizer")
//
//                    if imgVolumeAnimation.isAnimating {
//
//                        self.imgVolumeAnimation.clear()
//                    }
//                    self.imgVolumeAnimation.setGifImage(gif)
//                } catch {
//                    print(error)
//                }
//
//                self.btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
//                self.imgVolumeAnimation.startAnimatingGif()
//                self.imgVolumeAnimation.isHidden = false
//                self.imgVolumeStopAnimation.isHidden = true
//            }
//            else {
//
//                self.btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
//                self.imgVolumeAnimation.showFrameAtIndex(0)
//                self.imgVolumeAnimation.stopAnimatingGif()
//                self.imgVolumeAnimation.clear()
//                self.imgVolumeAnimation.image = nil
//                self.imgVolumeAnimation.isHidden = true
//                self.imgVolumeStopAnimation.isHidden = false
//            }

            if article.bullets?.first?.audio == nil || article.bullets?.first?.audio == "" {
                self.btnVolume.isHidden = true
                self.imgVolumeAnimation.isHidden = true
                self.imgVolumeStopAnimation.isHidden = true
            } else {
                self.btnVolume.isHidden = isMute
                self.imgVolumeAnimation.isHidden = isMute
            }
            
            self.btnVolume.alpha = SharedManager.shared.isAudioMuted ? 0.5 : 1.0
            NotificationCenter.default.post(name: Notification.Name.notifyAudioEnableStatus, object: nil)
            
            SharedManager.shared.segementIndex = 0

            self.viewSegmentProgress.isHidden = false
//            self.viewCount.isHidden = false
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

            //Progress segment bar
            
            self.currPage = 0
            
//            SharedManager.shared.spbCardView?.topColor = .clear
//            SharedManager.shared.spbCardView?.bottomColor = .clear

            

            
//            SharedManager.shared.spbCardView?.topColor = MyThemes.current == .dark ? "#E01335".hexStringToUIColor() : "#FA0815".hexStringToUIColor()
//            SharedManager.shared.spbCardView?.bottomColor = MyThemes.current == .dark ? UIColor.white.withAlphaComponent(0.30) : UIColor.black.withAlphaComponent(0.30)

            

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
    
    @IBAction func didTapVolume(_ sender: UIButton) {
        
        if SharedManager.shared.isAudioMuted == true {
            
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Speech not available for this article", comment: ""), type: .alert)
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
        
        if SharedManager.shared.isAudioEnable {
            
            
            if SharedManager.shared.isVolumeOn {
                
                return
            }
        //    SharedManager.shared.isAudioEnable = false
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
            do {
                let gif = try UIImage(gifName: "equalizer")
                self.imgVolumeAnimation.setGifImage(gif)
            } catch {
                print(error)
            }
            SharedManager.shared.isVolumeOn = true
            print("print 17...")
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.volume = 1.0
            self.imgVolumeAnimation.startAnimatingGif()
            self.imgVolumeAnimation.isHidden = false
            self.imgVolumeStopAnimation.isHidden = true

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
            self.imgVolumeAnimation.showFrameAtIndex(0)
            self.imgVolumeAnimation.stopAnimatingGif()
            self.imgVolumeAnimation.isHidden = true
            self.imgVolumeStopAnimation.isHidden = false
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
                
                self.currPage = self.currPage - 1
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
//                
//                self.delegateScheduleCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: false)
//            }
//            else {
//                self.restartProgressbar()
//            }
        }
    }
    
    func swipeLeftFocusedCell(bullets: [Bullets]) {
        
        if self.currPage < bullets.count - 1 {
            
            self.currPage = self.currPage + 1
            self.scrollToItemBullet(at: self.currPage, animated: true)
            self.playAudio()
            //SharedManager.shared.spbCardView?.skip()
        }
        else {
            
            //self.restartProgressbar()
//            
//            self.delegateScheduleCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
    }
    
    func swipeRightNormalCell(bullets: [Bullets]) {
        
        if self.currMutedPage > 0 {
            
            if self.currMutedPage < bullets.count {
                
                self.currMutedPage -= 1
                self.scrollToItemBullet(at: self.currMutedPage, animated: true)
            }
            else {
                
                self.scrollToItemBullet(at: self.currMutedPage, animated: true)
            }
        }
        else {
            
            self.currMutedPage = 0
            self.scrollToItemBullet(at: self.currMutedPage, animated: true)
        }
    }
    
    func swipeLeftNormalCell(bullets: [Bullets]) {
        
        if self.currMutedPage < bullets.count - 1 {
            
            self.currMutedPage += 1
            self.scrollToItemBullet(at: self.currMutedPage, animated: true)
        }
        else {
            self.currMutedPage = 0
            self.scrollToItemBullet(at: self.currMutedPage, animated: true)
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
                    self.delegateScheduleCard?.layoutUpdate()
                }
            }
        }
    }
}

//MARK:- UICollectionView Delegate And DataSource

extension ScheduleCardCC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
            }
            else {
                                
                cell.configCell(bullet: bullet.data ?? "", titleFont: SharedManager.shared.getCardViewBulletFont())
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
extension ScheduleCardCC: SegmentedProgressBarDelegate {
    
    func segmentedProgressBarChangedIndex(index: Int) {
                
        SharedManager.shared.isManualScrolling = false
        if SharedManager.shared.showHeadingsOnly == "HEADLINES_ONLY" && SharedManager.shared.isUserinteractWithHeadlinesOnly == false  {
            
            //self.spb?.isPaused = true
//            
//            self.delegateScheduleCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
        else {
            
            //progress Delegate
            if isAutoScrolling {
                
             //   SharedManager.shared.spbCardView?.isPaused = true
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
            
            
            self.delegateScheduleCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
        else {
            
            //Finish
            SharedManager.shared.segementIndex = 0
            
            self.delegateScheduleCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
    }
    
    func restartProgressbar() {
        
        
        
        self.viewSegmentProgress.isHidden = false
        self.currPage = 0
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

extension ScheduleCardCC {
    
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

