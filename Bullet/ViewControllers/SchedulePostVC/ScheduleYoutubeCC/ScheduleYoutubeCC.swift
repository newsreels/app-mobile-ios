//
//  EndCardCell.swift
//  Bullet
//
//  Created by Mahesh on 03/09/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

internal let CELL_IDENTIFIER_SCHEDULE_YOUTUBE           = "ScheduleYoutubeCC"

protocol ScheduleYoutubeCCDelegate: AnyObject {
    
    func autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: Bool)
}

class ScheduleYoutubeCC: UITableViewCell {
    
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
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var btnPlayYoutube: UIButton!
    @IBOutlet weak var viewBGBullet: UIView!

    @IBOutlet weak var viewGestures: UIView!
    @IBOutlet weak var lblDummy: UILabel!
    
//    @IBOutlet weak var lblViewCount: UILabel!
//    @IBOutlet weak var viewCount: UIView!
    @IBOutlet weak var viewLikeCommentBG: UIView!
    @IBOutlet weak var viewComment: UIView!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var lblCommentsCount: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var imgComment: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var lblAuthor: UILabel!
    
    //View Header Timer
    @IBOutlet weak var viewHeaderTimer: UIView!
    @IBOutlet weak var imgTimer: UIImageView!
    @IBOutlet weak var lblPostTimer: UILabel!
    
    //View Option Meu Footer
    @IBOutlet weak var viewOptionPost: UIView!
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var viewPostArticle: UIView!
    
    @IBOutlet weak var imgEdit: UIImageView!
    @IBOutlet weak var lblEdit: UILabel!

    @IBOutlet weak var imgDelete: UIImageView!
    @IBOutlet weak var lblDelete: UILabel!

    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!

    @IBOutlet weak var ctViewHeaderTimerHeight: NSLayoutConstraint!
    @IBOutlet weak var ctViewOptionPostHeight: NSLayoutConstraint!


    weak var delegateYoutubeCardCell: ScheduleYoutubeCCDelegate?
//    weak var delegateLikeComment: LikeCommentDelegate?
    private var currRow = 0
    private var bullets: [Bullets]?
    private var swipeGesture = UISwipeGestureRecognizer()

    var isPlayWhenReady = false
    var langCode = ""
    var status = ""

    var url: String = "" {
        didSet {
            videoPlayer.playerVars = [
                "playsinline": "1",
                "controls": "1",
                "rel" : "0",
                "cc_load_policy" : "0",
                "disablekb": "1",
                "modestbranding": "1",
                ] as YouTubePlayerView.YouTubePlayerParameters
            videoPlayer.delegate = self
            videoPlayer.loadVideoID(url)
        }
    }
    
    var urlThumbnail: String = "" {
        didSet {
            
            imgThumbnail.sd_setImage(with: URL(string: urlThumbnail), placeholderImage: nil)
        }
    }
    
    private var timer: Timer?
    private var timeInterval: TimeInterval = 0
    var pubDate: String = "" {
        didSet {
            startTimer()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
      
        imgTimer.theme_image = GlobalPicker.imgTimePicker
        lblPostTimer.theme_textColor = GlobalPicker.textBWColor
        lblSource.theme_textColor = GlobalPicker.textBWColor
        
        viewPlaceholder.isHidden = false
        //self.imgPlay.isHidden = false
        activityLoader.stopAnimating()

//        self.videoPlayer.delegate = self
        videoPlayer.backgroundColor = .clear
        viewContainer.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor//GlobalPicker.backgroundColorHomeCell
        lblAuthor.theme_textColor = GlobalPicker.textColor
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
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

        
    // MARK: - Actions
    
//    @IBAction func didTapLikeButton(_ sender: Any) {
//        self.delegateLikeComment?.didTapLikeButton(cell: self)
//    }
//
//    @IBAction func didTapCommentButton(_ sender: Any) {
//        self.delegateLikeComment?.didTapCommentsButton(cell: self)
//    }
    
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
            
            self.videoPlayer.pause()
        }
        else {
            self.videoPlayer.play()
        }
    }
    
    func setFocussedYoutubeView() {

        if SharedManager.shared.videoAutoPlay {

            self.videoPlayer.play()
            //self.imgPlay.isHidden = true
            self.activityLoader.startAnimating()
        }
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
    
    
    func setupSlideScrollView(bullets: [Bullets], row: Int, isAutoPlay: Bool) {
        
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
        
        if isAutoPlay {
            isPlayWhenReady = true
            self.setFocussedYoutubeView()
        }
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

extension ScheduleYoutubeCC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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

extension ScheduleYoutubeCC: YouTubePlayerDelegate {
    
    func playerUpdateCurrentTime(_ videoPlayer: YouTubePlayerView, time: String) {
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        
//        disableYoutubePlayerControls()
        print("\(#function)")
        //self.imgThumbnail.isHidden = true
//        videoPlayer.getDuration(completion: { (duration) in
//            //self.lblDuration.text = "\(String(describing: duration))"
//            //print("getDuration", String(describing: duration))
//            self.lblDuration.text = duration?.stringFromTimeInterval()
//        })
        print("playerViewDidBecomeReady isPlayWhenReady", isPlayWhenReady)
        if self.isPlayWhenReady && SharedManager.shared.viewSubCategoryIshidden {
            self.setFocussedYoutubeView()
        }
    }
    
//    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
//        return MyThemes.current == .dark ? .black : .white
//    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        
        if playerState == .Paused {
            self.activityLoader.stopAnimating()
            //self.imgPlay.isHidden = false
        }
        else if playerState == .Ended {
            //self.imgPlay.isHidden = false
//            self.delegateYoutubeCardCell?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
        else if playerState == .Playing {
            viewPlaceholder.isHidden = true
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
