//
//  HomeListViewCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 04/10/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import IQKeyboardManagerSwift
import NVActivityIndicatorView
import CoreLocation

internal let CELL_IDENTIFIER_HOME_LISTVIEW      = "HomeListViewCC"
internal let HEIGHT_HOME_LISTVIEW: CGFloat      = 250


class HomeListViewCC: UITableViewCell {
    
    //Proporties
    @IBOutlet weak var viewContainer: UIView!
//    @IBOutlet weak var imgDot: UIImageView!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSource: UIButton!
//    @IBOutlet weak var imgWifi: UIImageView!
//    @IBOutlet weak var viewListSegmentProgress: UIView!
    @IBOutlet weak var imgMore: UIImageView!
//    @IBOutlet weak var viewDot: UIView!
    
    @IBOutlet weak var imgNext: UIImageView!
    @IBOutlet weak var imgPrevious: UIImageView!
    
//    @IBOutlet weak var viewCount: UIView!
//    @IBOutlet weak var lblViewCount: UILabel!

    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSource: UILabel!
//    @IBOutlet weak var lblAuthor: UILabel!

    @IBOutlet weak var clvBullets: UICollectionView!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var btnVolume: UIButton!
    
//    @IBOutlet weak var viewLikeCommentBG: UIView!
//    @IBOutlet weak var viewComment: UIView!
//    @IBOutlet weak var viewLike: UIView!
//    @IBOutlet weak var lblCommentsCount: UILabel!
//    @IBOutlet weak var lblLikeCount: UILabel!
//    @IBOutlet weak var imgLike: UIImageView!
//    @IBOutlet weak var imgComment: UIImageView!
    @IBOutlet weak var lblDummy: UILabel!
    
//    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var ctLabelDummyHeight: NSLayoutConstraint!
//    @IBOutlet weak var lblDummyTrailing: NSLayoutConstraint!
    @IBOutlet weak var viewImageBG: UIView!
    @IBOutlet weak var imgArticle: UIImageView!
    @IBOutlet weak var backgrView: UIView!
    //    @IBOutlet weak var ctViewTimeBottom: NSLayoutConstraint!

//    @IBOutlet weak var viewBlurBG: UIView!
//    @IBOutlet weak var visualDarkViewBG: UIVisualEffectView!
//    @IBOutlet weak var visualLightViewBG: UIVisualEffectView!
//    @IBOutlet weak var viewArticelImageWidth: NSLayoutConstraint!
    
    //View Processing Upload Article by User
    @IBOutlet weak var viewProcessingBG: UIView!
    @IBOutlet weak var viewLoader: NVActivityIndicatorView!
    @IBOutlet weak var viewProcess: UIView!
    @IBOutlet weak var lblProcessing: UILabel!
    
    //View Schedule Upload Article by User
    @IBOutlet weak var viewScheduleBG: UIView!
    @IBOutlet weak var viewSchdule: UIView!
    @IBOutlet weak var lblScheduleTime: UILabel!
    
//    @IBOutlet weak var viewDividerLine: UIView!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var ctViewImageBGHeight: NSLayoutConstraint!
    @IBOutlet weak var timeSeparatorView: UIView!
    
    
    //variables
    var bullets = [Bullets]()
    var isAutoScrolling = true
    var currRow = 0
    var currPage = 0
    var currMutedPage = 0
    var mp3Duration = 0.0
    var imageURL = ""
    var isMuted: Bool = true
    var isCommunityCell = false
    var isViewMoreReels = false

    private var swipeGesture = UISwipeGestureRecognizer()
    private var longPressGesture = UILongPressGestureRecognizer()
    
    weak var delegateHomeListCC: HomeCardCellDelegate?
    weak var delegateLikeComment: LikeCommentDelegate?
    let animationDuration: TimeInterval = 0.20
    var transition = CATransition()
    private var generator = UIImpactFeedbackGenerator()
    var langCode = ""
    let minHeight: CGFloat = 115
//    let billetImageWidth: CGFloat = 103
//    var imageGradient = UIImageView()
    
    var bulletsMaxHeightIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //View Processing Article
//        viewDividerLine.theme_backgroundColor = GlobalPicker.dividerLineBG
        backgrView.backgroundColor = .white
        
        imgMore.theme_image = GlobalPicker.imgMoreOptions
        
        viewLoader.type = .ballSpinFadeLoader
        viewLoader.startAnimating()
        viewProcess.cornerRadius = viewProcess.frame.height / 2
        viewProcess.theme_backgroundColor = GlobalPicker.backgroundListColor
        lblProcessing.theme_textColor = GlobalPicker.textBWColor
        lblProcessing.text = NSLocalizedString("Processing...", comment: "")

        //Schedule Article
        viewSchdule.cornerRadius = viewSchdule.frame.height / 2
        lblScheduleTime.theme_textColor = GlobalPicker.textBWColor//.white

//        imgWifi.layer.cornerRadius = imgWifi.frame.height / 2
        //self.imgBG.sd_cancelCurrentImageLoad()
//        btnLeft.theme_tintColor = GlobalPicker.btnCellTintColor
//        btnRight.theme_tintColor = GlobalPicker.btnCellTintColor
//        viewBackground.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor//GlobalPicker.backgroundColorHomeCell
//        viewBackground.backgroundColor = .white
        
        //self.imgWifi.theme_image = GlobalPicker.imgWifi
//        lblTime.theme_textColor = GlobalPicker.textForYouSubTextSubColor
//        lblAuthor.theme_textColor = GlobalPicker.textForYouSubTextSubColor
//        lblSource.theme_textColor = GlobalPicker.textBWColor
        clvBullets.decelerationRate = UIScrollView.DecelerationRate.fast
    
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyAudioAndProgressBarStatus, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAudioAndProgressBarStatus(notification:)), name: Notification.Name.notifyAudioAndProgressBarStatus, object: nil)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        self.bringSubviewToFront(btnShare)
        
        
//        imageGradient.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        imageGradient.frame = viewBackground.bounds
//        self.viewBackground.insertSubview(imageGradient, at: 0)
//
//        imageGradient.isHidden = true
//        imageGradient.contentMode = .scaleToFill
//        imageGradient.backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgrView.layer.cornerRadius = 12
        
//        self.viewCount.theme_backgroundColor = GlobalPicker.viewCountColor
//        //self.viewComment.theme_backgroundColor = GlobalPicker.viewCountColor
//        //self.viewLike.theme_backgroundColor = GlobalPicker.viewCountColor
        
//        imgDot.theme_image = GlobalPicker.imgSingleDot
        
        
//        SharedManager.shared.spbCardView?.topColor = MyThemes.current == .dark ? "#E01335".hexStringToUIColor() : "#FA0815".hexStringToUIColor()
//        SharedManager.shared.spbCardView?.bottomColor = MyThemes.current == .dark ? UIColor.white.withAlphaComponent(0.30) : "#E7E7E7".hexStringToUIColor()
        
//        DispatchQueue.main.async {
//            if SharedManager.shared.isSelectedLanguageRTL() {
//                self.viewListSegmentProgress.transform = CGAffineTransform(scaleX: -1, y: 1)
//            } else {
//                self.viewListSegmentProgress.transform = CGAffineTransform(scaleX: 1, y: 1)
//            }
//        }
        
        self.contentView.updateConstraintsIfNeeded()
        self.contentView.layoutIfNeeded()
        
        
        clvBullets.collectionViewLayout.invalidateLayout()
    }
    
    override func prepareForReuse() {
        
        self.contentView.updateConstraintsIfNeeded()
        self.contentView.layoutIfNeeded()
        
        self.lblDummy.text = ""
        self.lblDummy.layoutIfNeeded()
        ctLabelDummyHeight.constant = minHeight

        
        self.bullets = [Bullets]()
        //
        clvBullets.reloadData()
    }
    
    func resetVisibleListCell() {
        
        //Always show Iamge
//        self.viewSeperatorLine.isHidden = true
        //self.viewImageBG.isHidden = false
        //self.btnShare.isHidden = false
        //self.imgMore.isHidden = false
        
        //we will reset all values
//        if let gestures = self.viewContainer.gestureRecognizers {
//            for gesture in gestures {
//                if gesture == longPressGesture {
//                    gesture.isEnabled = false
//                }
//            }
//        }
                
        SharedManager.shared.segementIndex = 0
        SharedManager.shared.isUserinteractWithHeadlinesOnly = false
//        
//
//        SharedManager.shared.spbCardView?.removeFromSuperview()
//        viewListSegmentProgress.isHidden = true
//        DispatchQueue.main.async {
//            self.ctViewTimeBottom.constant = 12
//        }
//        self.viewCount.isHidden = true
        btnVolume.isHidden = true
        
//        clvBullets.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
//        ctLabelDummyHeight.constant = minHeight
//        lblDummyTrailing.constant = SharedManager.shared.getBulletListLabelTrailing(selectedLanguage: langCode) + billetImageWidth
//        lblDummy.text = self.bullets.first?.data
//        lblDummy.font = SharedManager.shared.getListViewTitleFont()
//        lblDummy.sizeToFit()
        
        //print("mahesh resetVisibleListCell...")
        
        self.lblDummy.text = self.bullets.first?.data ?? ""
        let newHeight = heightForLabel(text: lblDummy.text ?? "", font: SharedManager.shared.getListViewTitleFont(), width: lblDummy.frame.width)
        if newHeight > minHeight {
            ctLabelDummyHeight.constant = newHeight
        }
        else {
            ctLabelDummyHeight.constant = minHeight
        }
        
        let point = CGPoint(x: 0, y: self.clvBullets.contentOffset.y)
        self.clvBullets.setContentOffset(point, animated: false)
        
        self.contentView.layoutIfNeeded()
        self.clvBullets.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            
            self.lblDummy.layoutIfNeeded()
            self.contentView.layoutIfNeeded()
            self.clvBullets.reloadData()
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
    
    //MARK:- Configure cell
    func setupCellBulletsView(article: articlesData, isAudioPlay: Bool, row: Int, isMute: Bool) {
    
        //ctLabelDummyHeight.constant = minHeight
//        self.ctViewTimeBottom.constant = 12
        
        self.currRow = row
        self.currMutedPage = 0
//        self.viewListSegmentProgress.isHidden = true
        self.btnVolume.isHidden = true
        self.clvBullets.isHidden = false
        self.isMuted = isMute
        
        if let bull = article.bullets {
            
            if bull.count == 0 {
                return
            }
            self.bullets = bull
        }

        self.bulletsMaxHeightIndex = 0
//        lblDummyTrailing.constant = SharedManager.shared.getBulletListLabelTrailing(selectedLanguage: langCode) + billetImageWidth
        lblDummy.text = self.bullets.first?.data
        lblDummy.font = SharedManager.shared.getListViewTitleFont()
        lblDummy.sizeToFit()
        lblDummy.isHidden = true
        //lblDummy.theme_textColor = GlobalPicker.bgBlackWhiteColor
        //clvBullets.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        if SharedManager.shared.readerMode {
            ctViewImageBGHeight.constant = 0
            viewImageBG.isHidden = true
        }
        else {
            viewImageBG.isHidden = false
            ctViewImageBGHeight.constant = 120
            if let image = UIImage(contentsOfFile: (article.image ?? "").replace(string: "file://", replacement: "")) {
                imgArticle.image = image
            } else {
                imgArticle.sd_setImage(with: URL(string: article.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            }
//
//            imgArticle.sd_setImage(with: URL(string: article.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        }

        let url = article.image ?? ""
        imageURL = url
        
//        lblSource.theme_textColor = GlobalPicker.textSourceColor
        
        
        let author = article.authors?.first?.username ?? article.authors?.first?.name ?? ""
        let source = article.source?.name ?? ""
        
        lblSource.text = "\(author.isEmpty ? source :  author)"
        
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
        
        langCode = article.language ?? ""
        if let pubDate = article.publish_time {
            lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
        }
//        lblTime.addTextSpacing(spacing: 0.5)
        


        clvBullets.register(UINib(nibName: CELL_IDENTIFIER_NO_IMG_LIST, bundle: nil), forCellWithReuseIdentifier: CELL_IDENTIFIER_NO_IMG_LIST)
        clvBullets.delegate = self
        clvBullets.dataSource = self
//        self.clvBullets.backgroundColor = UIColor.clear
        clvBullets.tag = row
                        
        if SharedManager.shared.isAudioEnable {
            
            self.btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
        }
        else {
            
            self.btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
        }
        
        //Long press Gesture for active cell
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.numberOfTouchesRequired = 1
        longPressGesture.minimumPressDuration = 0.2 // 1 second press
        longPressGesture.view?.tag = self.currRow
        longPressGesture.delegate = self
        viewContainer.addGestureRecognizer(longPressGesture)

        //called when selected cell is active
//        for gesture in self.viewContainer.gestureRecognizers! {
//            gesture.isEnabled = true
//        }
        
        let status = article.status ?? ""
        if isAudioPlay && status != Constant.newsArticle.ARTICLE_STATUS_SCHEDULED && status != Constant.newsArticle.ARTICLE_STATUS_PROCESSING {

//            DispatchQueue.main.async {
//                self.ctViewTimeBottom.constant = 36
//            }
            self.scrollToItemBullet(at: 0, animated: false)

            //VOLUMN MUTE/UNMUTE
            if article.bullets?.first?.audio == nil || article.bullets?.first?.audio == "" {
                SharedManager.shared.isAudioMuted = true
                self.btnVolume.isHidden = true
            } else {
                SharedManager.shared.isAudioMuted = isMute
                self.btnVolume.isHidden = isMute
            }
            
            self.btnVolume.alpha = SharedManager.shared.isAudioMuted ? 0.5 : 1.0
            NotificationCenter.default.post(name: Notification.Name.notifyAudioEnableStatus, object: nil)
            
            SharedManager.shared.segementIndex = 0
         //   self.btnVolume.isHidden = false

//            self.viewListSegmentProgress.isHidden = false
//            self.viewCount.isHidden = false
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleViewed, eventDescription: "", article_id: article.id ?? "")
            SharedManager.shared.performWSToUpdateArticleAnalytics(ArticleId: article.id ?? "", isFromReel: false)

            if let urlstring = self.bullets[0].audio, let URLStr = URL(string: urlstring), !urlstring.isEmpty {

                if self.bullets[0].duration == 0 {

                    self.mp3Duration = self.mp3fileTimeDuration(urlStr: URLStr)
                }
                else {

                    if var duration = self.bullets[0].duration {

                        duration = duration / 1000
                        self.mp3Duration = duration / SharedManager.shared.localReadingSpeed
                        self.mp3Duration = self.mp3Duration < 2.0 ? 2.5  : self.mp3Duration + 0.5
                    }
                }
                
            }
            else {

                
                self.mp3Duration = 7
            }

            //Progress segment bar
            
            self.currPage = 0
            

            if SharedManager.shared.isAudioMuted  == false {
                
                if let urlstring = self.bullets[0].audio, !urlstring.isEmpty {
                    
                    self.downloadFileFromURL(url: urlstring)
                }
            }
        }
        else {
         
            self.scrollToItemBullet(at: 0, animated: false)
        }
    }
    
    // MARK: - Actions
    @IBAction func didTapLikeButton(_ sender: Any) {
        self.delegateLikeComment?.didTapLikeButton(cell: self)
    }
    
    @IBAction func didTapCommentButton(_ sender: Any) {
        self.delegateLikeComment?.didTapCommentsButton(cell: self)
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
            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
            SharedManager.shared.isAudioEnable = false
        }
        else {
            
            //volume on
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unmute, eventDescription: "")
            SharedManager.shared.isAudioEnable = true
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
        }
        
        SharedManager.shared.isVolumeOn = false
        //NotificationCenter.default.post(name: Notification.Name.notifyHomeVolumn, object: nil)
//
//        if SharedManager.shared.menuViewModeType == "EXTENDED" {
//            return
//        }
        
        if SharedManager.shared.isAudioEnable {
            
            
            if SharedManager.shared.isVolumeOn {
                
                return
            }
            print("print 19...")
            SharedManager.shared.isVolumeOn = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.volume = 1.0
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)

            //let bullets = SharedManager.shared.articleOnVolume.bullets
            if SharedManager.shared.bulletCurrentIndex < bullets.count, let urlstring = self.bullets[SharedManager.shared.bulletCurrentIndex].audio, let URLStr = URL(string: urlstring), !urlstring.isEmpty {
                
                self.currPage = SharedManager.shared.bulletCurrentIndex
                if self.bullets[self.currPage].duration == 0 {
                    
                    self.mp3Duration = self.mp3fileTimeDuration(urlStr: URLStr)
                }
                else {
                    
                    if var duration = bullets[self.currPage].duration {
                        
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
            SharedManager.shared.isAudioEnable = false
            SharedManager.shared.bulletPlayer?.volume = 0.0
        }
    }
    
//    @objc func handleUpPanGesture(_ pan: UIPanGestureRecognizer) {
//
//        if let gesture = pan as? PanDirectionGestureRecognizer {
//
//            switch gesture.state {
//            case .began:
//                break
//            case .changed:
//                break
//            case .ended,
//                 .cancelled:
//                break
//            default:
//                break
//            }
//        }
//    }
    
//    @objc func handleDownPanGesture(_ pan: UIPanGestureRecognizer) {
//
//        if let gesture = pan as? PanDirectionGestureRecognizer {
//
//            switch gesture.state {
//            case .began:
//                break
//
//            case .changed:
//                break
//            case .ended,
//                 .cancelled:
//                break
//
//            default:
//                break
//            }
//        }
//    }
    
    @objc func updateAudioAndProgressBarStatus( notification: NSNotification) {
        
        self.pauseAudioAndProgress(isPause: SharedManager.shared.isPauseAudio)
    }
    
    func updateListViewVolumeStatus() {
    
        if SharedManager.shared.isAudioEnable {
            
            
            SharedManager.shared.bulletPlayer?.volume = 1.0
            SharedManager.shared.isVolumeOn = true
            SharedManager.shared.bulletPlayer?.stop()
            print("print 20...")
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
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
                
        self.delegateHomeListCC?.handleLongPressHold(gestureRecognizer)
    }
    
    func swipeRightCurrentlyFocusedCell(_ tag: Int) {
        if self.currPage > 0 {
            
            if self.currPage < self.bullets.count {
                
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
//                self.delegateHomeListCC?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: false)
//            }
//            else {
//                self.restartProgressbar()
//            }
        }
    }
    
    func swipeLeftCurrentlyFocusedCell() {
        if self.currPage < self.bullets.count - 1 {
            
            self.currPage += 1
            self.scrollToItemBullet(at: self.currPage, animated: true)
            self.playAudio()
            //SharedManager.shared.spbCardView?.skip()
        }
        else {
            
            //self.restartProgressbar()
//            self.delegateHomeListCC?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
    }
    
    func swipeRightUserSelectedCell() {
        
        self.forceRestartProgressbar {
            
            if self.currMutedPage > 0 {
                
                if self.currMutedPage < self.bullets.count {
                    
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
                
                self.bulletsMaxHeightIndex = 0
                self.currMutedPage = 0
                self.currPage = 0
                self.scrollToItemBullet(at: self.currMutedPage, animated: false)
            }
        }
    }
    
    func swipeLeftUserSelectedCell() {
        
        self.forceRestartProgressbar {
            
            if self.currMutedPage < self.bullets.count - 1 {
                
                self.currMutedPage += 1
                self.currPage += 1
                self.scrollToItemBullet(at: self.currMutedPage, animated: true)
                self.playAudio()
                //SharedManager.shared.spbCardView?.skip()
            }
            else {
                
                self.bulletsMaxHeightIndex = 0
                self.currMutedPage = 0
                self.currPage = 0
                self.scrollToItemBullet(at: self.currMutedPage, animated: false)
            }
        }
    }
    
    func pauseAudioAndProgress(isPause: Bool) {
        
        if isPause {
            
            if SharedManager.shared.bulletPlayer?.rate != 0 {
                print("print 1...")
                SharedManager.shared.bulletPlayer?.pause()
                }
        }
        else {
            
            if bullets.first?.audio == nil || bullets.first?.audio == "" {
                SharedManager.shared.bulletPlayer = nil
            }
            else {
                if SharedManager.shared.isAudioMuted == false {
                    
                    SharedManager.shared.bulletPlayer?.play()
                }
            }
        }
    }
    
    @objc func autoScrollBullet() {
        
        print("print 13...")
        SharedManager.shared.bulletPlayer?.pause()
        SharedManager.shared.bulletPlayer?.stop()
        
        if self.currPage >= self.bullets.count - 1  {
            
            self.restartProgressbar()
            //self.animateImageView(isFromRight: false)
        }
        else {
            
            self.currPage += 1
            SharedManager.shared.segementIndex = self.currPage
            self.playAudio()
            self.scrollToItemBullet(at: currPage, animated: true)
            //self.animateImageView(isFromRight: true)
        }
        
        if isCommunityCell {
            btnReport.isHidden = currPage == 0 ? false : true
        }
    }
    
    func playAudio() {
        
        SharedManager.shared.bulletCurrentIndex = self.currPage
        var urlstring = ""
        
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
                    
                    if SharedManager.shared.isAudioMuted  == false {
                        
                        self.downloadFileFromURL(url: urlstring)
                    }
                }
                else {
                    
                    print("print 14...")
                    SharedManager.shared.bulletPlayer?.pause()
                    SharedManager.shared.bulletPlayer?.stop()
                        }
            }
        }
    }
}

//MARK:- SegmentedProgressBar Delegate
extension HomeListViewCC: SegmentedProgressBarDelegate {
    
    func segmentedProgressBarChangedIndex(index: Int) {
                
        if SharedManager.shared.showHeadingsOnly == "HEADLINES_ONLY" && SharedManager.shared.isUserinteractWithHeadlinesOnly == false  {
            
//            self.bulletsMaxHeightIndex = 0
//            self.delegateHomeListCC?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
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
        
        
        if SharedManager.shared.showHeadingsOnly == "HEADLINES_ONLY" && SharedManager.shared.isUserinteractWithHeadlinesOnly == false  {
        
            self.bulletsMaxHeightIndex = 0
            self.delegateHomeListCC?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
        else {
            
            //Finish
            SharedManager.shared.segementIndex = 0
            self.bulletsMaxHeightIndex = 0
            self.delegateHomeListCC?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
        }
    }
    
    func forceRestartProgressbar(completionBlock: @escaping () -> ()) {
        
        
        
//        self.viewListSegmentProgress.isHidden = false
        self.currPage = 0
        self.currMutedPage = 0
        SharedManager.shared.segementIndex = 0
        
        if bullets.count > 0 {
            
            //VOLUMN MUTE/UNMUTE
            if bullets.first?.audio == nil || bullets.first?.audio == "" {
                SharedManager.shared.isAudioMuted = true
                self.btnVolume.isHidden = true
            } else {
                SharedManager.shared.isAudioMuted = isMuted
                self.btnVolume.isHidden = isMuted
            }
            self.btnVolume.alpha = SharedManager.shared.isAudioMuted ? 0.5 : 1.0
            
            SharedManager.shared.isVolumeOn = false

            if SharedManager.shared.isAudioEnable {
                                
                if SharedManager.shared.isVolumeOn {
                    
                    return
                }
                print("print 19...")
                SharedManager.shared.isVolumeOn = true
                SharedManager.shared.bulletPlayer?.stop()
                SharedManager.shared.bulletPlayer?.volume = 1.0
                btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
            }
            else {
                
                btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
                SharedManager.shared.isAudioEnable = false
                SharedManager.shared.bulletPlayer?.volume = 0.0
            }

            
            if let urlstring = bullets[0].audio, !urlstring.isEmpty {
                
                if let URL = URL(string: urlstring) {
                    
                    if bullets[0].duration == 0 {
                        
                        self.mp3Duration = self.mp3fileTimeDuration(urlStr: URL)
                    }
                    else {
                        
                        if var duration = bullets[0].duration {
                            
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
        
        
        
//        SharedManager.shared.spbCardView?.frame = CGRect(x: 0, y: 0, width: self.viewListSegmentProgress.frame.size.width, height: self.viewListSegmentProgress.frame.size.height)
//        self.viewListSegmentProgress.addSubview(SharedManager.shared.spbCardView!)

        
        
        DispatchQueue.main.async {
            
//            UIView.animate(withDuration: 0.25) {
//                self.ctViewTimeBottom.constant = 36
//            }
            
            
            if SharedManager.shared.isAudioMuted  == false {
                
                if let urlstring = self.bullets[0].audio, !urlstring.isEmpty {
                    
                    self.downloadFileFromURL(url: urlstring)
                }
            }
            
            completionBlock()
        }
        
        //self.scrollToItemBullet(at: self.currPage, animated: false)
    }
    
    
    func restartProgressbar() {
        
        
        
//        self.viewListSegmentProgress.isHidden = false
        self.currPage = 0
        self.currMutedPage = 0
        SharedManager.shared.segementIndex = 0
        
        if bullets.count > 0 {
            
            if let urlstring = bullets[0].audio, !urlstring.isEmpty {
                
                if let URL = URL(string: urlstring) {
                    
                    if  bullets[0].duration == 0 {
                        
                        self.mp3Duration = self.mp3fileTimeDuration(urlStr: URL)
                    }
                    else {
                        
                        if var duration = bullets[0].duration {
                            
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
        
        
        
//        SharedManager.shared.spbCardView?.frame = CGRect(x: 0, y: 0, width: self.viewListSegmentProgress.frame.size.width, height: self.viewListSegmentProgress.frame.size.height)
//        self.viewListSegmentProgress.addSubview(SharedManager.shared.spbCardView!)
//        SharedManager.shared.spbCardView?.topColor = MyThemes.current == .dark ? "#E01335".hexStringToUIColor() : "#FA0815".hexStringToUIColor()
//        SharedManager.shared.spbCardView?.bottomColor = MyThemes.current == .dark ? UIColor.white.withAlphaComponent(0.30) : "#E7E7E7".hexStringToUIColor()
        
        
        DispatchQueue.main.async {
            
            
            
            if SharedManager.shared.isAudioMuted  == false {
                
                if let urlstring = self.bullets[0].audio, !urlstring.isEmpty {
                    
                    self.downloadFileFromURL(url: urlstring)
                }
            }
        }
        
        self.scrollToItemBullet(at: self.currPage, animated: false)
    }
}

extension HomeListViewCC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.bullets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if SharedManager.shared.readerMode {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER_NO_IMG_LIST, for: indexPath) as? BulletListCellWithoutImg else { return UICollectionViewCell() }
            
            cell.langCode = langCode
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            cell.item = self.bullets[indexPath.row].data ?? ""
//            if isViewMoreReels {
//                cell.lblBullet.textColor = Constant.appColor.darkGray
//            }
//            else {
//                cell.lblBullet.theme_textColor = GlobalPicker.textBWColor
//            }
            cell.lblBullet.theme_textColor = GlobalPicker.textBWColor
            //Constant.appColor.darkGray
            
            cell.lblBullet.font = SharedManager.shared.getListViewBulletFont()
            cell.lblBullet.numberOfLines = 0
            //            cell.lblBullet.minimumScaleFactor = 10 / (UIFont.labelFontSize)
            //            cell.lblBullet.adjustsFontSizeToFitWidth = true
            
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
            
        }
        else {
            
            //            if indexPath.row == 0 {
            //
            //                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER_LIST_BULLET, for: indexPath) as? BulletListCell else { return UICollectionViewCell() }
            //
            ////                cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.green : UIColor.red
            //                cell.langCode = langCode
            //                cell.setNeedsLayout()
            //                cell.layoutIfNeeded()
            //
            //                cell.imgBG.sd_setImage(with: URL(string: self.imageURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            //                cell.item = self.bullets[indexPath.row].data ?? ""
            //
            //                if isViewMoreReels {
            //                    cell.lblBullet.textColor = .black
            //                } else {
            //                    cell.lblBullet.theme_textColor = GlobalPicker.textBWColor
            //                }
            //                cell.lblBullet.font = SharedManager.shared.getListViewTitleFont()
            //                cell.lblBullet.numberOfLines = 0
            //
            //
            ////                lblDummy.text = self.bullets[indexPath.row].data ?? ""
            ////                lblDummy.font = SharedManager.shared.getListViewTitleFont() // UIFont(name: Constant.FONT_Mulli_BOLD, size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
            ////                lblDummy.sizeToFit()
            //
            ////                cell.lblBullet.minimumScaleFactor = 10 / (UIFont.labelFontSize)
            ////                cell.lblBullet.adjustsFontSizeToFitWidth = true
            //
            //                cell.setNeedsLayout()
            //                cell.layoutIfNeeded()
            //                return cell
            //            }
            //            else {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER_NO_IMG_LIST, for: indexPath) as? BulletListCellWithoutImg else { return UICollectionViewCell() }
            
            //                cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.green : UIColor.red
            if indexPath.row == 0 {
                cell.lblBullet.font = SharedManager.shared.getListViewTitleFont()
                lblDummy.font = SharedManager.shared.getListViewTitleFont()
            }
            else {
                cell.lblBullet.font = SharedManager.shared.getListViewBulletFont()
                lblDummy.font = SharedManager.shared.getListViewBulletFont()
            }
            
            cell.lblBullet.numberOfLines = 0
            lblDummy.numberOfLines = 0

            cell.langCode = langCode
            //cell.setNeedsLayout()
            //cell.layoutIfNeeded()
            cell.item = bullets[indexPath.row].data ?? ""
            lblDummy.text = bullets[indexPath.row].data ?? ""
            lblDummy.sizeToFit()
            
            cell.lblBullet.theme_textColor = GlobalPicker.textBWColor //Constant.appColor.darkGray
            
            //cell.setNeedsLayout()
            //cell.layoutIfNeeded()
            return cell
        }
        
        //        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollToItemBullet(at index: Int, animated: Bool) {
        
        guard
            index >= 0,
            index < clvBullets.numberOfItems(inSection: 0), bullets.count > 0
        else {
            return
        }
        
        if !(SharedManager.shared.readerMode) {
            imgArticle.sd_setImage(with: URL(string: bullets[index].image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        }
        
        clvBullets.isHidden = true
        let prevFont = lblDummy.font
        //let prevTrailing = lblDummyTrailing.constant
        let prevText = lblDummy.text
        var prevHeight = lblDummy.frame.height
        
//        print("max height prevText", prevText ?? "")
//        print("max height prev frame", lblDummy.frame.size.height)
        
        var newHeight = prevHeight
        
        var currentHight = 0
        if index > 0 {

            currentHight = self.bullets[index - 1].data?.count ?? 0
            lblDummy.font = SharedManager.shared.getListViewBulletFont() //UIFont(name: Constant.FONT_Mulli_Semibold, size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
            //lblDummyTrailing.constant = 0
            lblDummy.text = self.bullets[index].data
            lblDummy.sizeToFit()
            lblDummy.layoutIfNeeded()
            newHeight = heightForLabel(text: lblDummy.text ?? "", font: SharedManager.shared.getListViewBulletFont(), width: clvBullets.frame.width)
//            lblDummy.layoutIfNeeded()
//
//            print("homelist lbldummy.frame", self.lblDummy.frame)
//            print("homelist clvBullets.frame", self.clvBullets.frame)
//            ctLabelDummyHeight.constant = lblDummy.frame.height > 95 ? lblDummy.frame.height + 20 : 95
        } else {
            
            lblDummy.font = SharedManager.shared.getListViewTitleFont()
            //lblDummyTrailing.constant = SharedManager.shared.getBulletListLabelTrailing(selectedLanguage: langCode) + billetImageWidth
            lblDummy.text = self.bullets[index].data
            lblDummy.sizeToFit()
            lblDummy.layoutIfNeeded()
            
            newHeight = heightForLabel(text: lblDummy.text ?? "", font: SharedManager.shared.getListViewTitleFont(), width: clvBullets.frame.width)
            
//
//            print("homelist lbldummy.frame", self.lblDummy.frame)
//            print("homelist clvBullets.frame", self.clvBullets.frame)
        }
    
//        print("max height new text", lblDummy.frame.size.height)
        if prevHeight < minHeight {
            prevHeight = minHeight
        }
        if newHeight < minHeight {
            newHeight = minHeight
        }
        
        if newHeight > prevHeight {
            ctLabelDummyHeight.constant = newHeight
            // New height will set
            
//            print("max height new set", newHeight)
        } else {
            ctLabelDummyHeight.constant = prevHeight
            // Previouse data will load
            lblDummy.text = prevText
            lblDummy.font = prevFont
            //lblDummyTrailing.constant = prevTrailing
            lblDummy.sizeToFit()
            
//            print("max height prev set", prevHeight)
        }
//
//        lblDummy.layoutIfNeeded()
        clvBullets.isHidden = false
        
        var x: CGFloat = 0
        for _ in 0..<index {
            x += self.clvBullets.frame.width
        }

        let point = CGPoint(x: x, y: self.clvBullets.contentOffset.y)
        self.clvBullets.setContentOffset(point, animated: animated)

        if index > self.bullets.count - 1 {
            return
        }
        
        if index != 0 {
            
            let newHeight = self.bullets[index].data?.count ?? 0
//
            if newHeight > currentHight && newHeight > self.bulletsMaxHeightIndex {

                self.bulletsMaxHeightIndex = newHeight
            }
            self.delegateHomeListCC?.layoutUpdate()
        } else {
            self.delegateHomeListCC?.layoutUpdate()
        }
        
        self.clvBullets.reloadData()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//            self.layoutIfNeeded()
//            self.clvBullets.reloadData()
//        }
//        
        /*
        UIView.animate(withDuration: 0.2) {
//            self.clvBullets.layoutIfNeeded()
//            self.clvBullets.layoutSubviews()
//            if SharedManager.shared.tabBarIndex == TabbarType.Feed.rawValue {
//                self.btnReport.isHidden = index == 0 ? false : true
//            }
            
            
//            if index > 0 {
//                if self.ctViewImageBGHeight.constant > 99 {
//                    self.ctViewImageBGHeight.constant -= 10
//                }
//            }
//            else {
//                self.ctViewImageBGHeight.constant = 120
//            }
//            self.clvBullets.collectionViewLayout.invalidateLayout()

        } completion: { (finished) in

            var x: CGFloat = 0
            for _ in 0..<index {
                x += self.clvBullets.frame.width
            }

            let point = CGPoint(x: x, y: self.clvBullets.contentOffset.y)
            self.clvBullets.setContentOffset(point, animated: animated)

            if index > self.bullets.count - 1 {
                return
            }
            
            if index != 0 {
                
                let newHeight = self.bullets[index].data?.count ?? 0
//
                if newHeight > currentHight && newHeight > self.bulletsMaxHeightIndex {

                    self.bulletsMaxHeightIndex = newHeight
                }
                self.delegateHomeListCC?.layoutUpdate()
            } else {
                self.delegateHomeListCC?.layoutUpdate()
            }
            
            if self.clvBullets.numberOfItems(inSection: 0) > 0 && index < self.clvBullets.numberOfItems(inSection: 0) {
                self.clvBullets.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
            
        }
        */
    }
    
    func heightForLabel(text: String, font: UIFont, width: CGFloat) -> CGFloat {

       let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
       label.numberOfLines = 0
       label.lineBreakMode = NSLineBreakMode.byWordWrapping
       label.font = font
       label.text = text
       label.sizeToFit()

       return label.frame.height
    }
    
}

//MARK: - Audio: Text to speech
extension HomeListViewCC {
    
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
                    
                    //    SharedManager.shared.spbCardView?.isPaused = false
                        print("audio playing downloaded 01")
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
            print("re-playing")
            SharedManager.shared.bulletPlayer?.pause()
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer = nil

            SharedManager.shared.bulletCurrentIndex = self.currPage
            _ = try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            //_ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, option: .duckOthers)
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
}

extension HomeListViewCC {
    
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
    
//    func animateImageView(isFromRight: Bool) {
//
//        if MyThemes.current == .light {
//            return
//        }
//
//        self.viewSwipeAnimation.isHidden = false
//        self.viewSwipeAnimation.fadeIn(0.10, delay: 0) { _ in
//
//            self.viewSwipeAnimation.fadeOut(0.10, delay: 0) { _ in
//
//                self.viewSwipeAnimation.isHidden = true
//            }
//        }
//        if isFromRight {
//
//            transition.type = CATransitionType.push
//            transition.subtype = CATransitionSubtype.fromRight
//        }
//        else {
//
//            transition.type = CATransitionType.push
//            transition.subtype = CATransitionSubtype.fromLeft
//        }
//
//        transition.duration = animationDuration
//        viewSwipeAnimation.layer.add(transition, forKey: kCATransition)
//        CATransaction.commit()
//    }
}

