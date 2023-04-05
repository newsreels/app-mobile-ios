//
//  ReelsCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 29/03/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation
import PlayerKit
import ActiveLabel
//import SkeletonView
import CoreHaptics
import GSPlayer

protocol ReelsCCDelegate: AnyObject {
    
    func videoPlayingStarted(cell: ReelsCC)
    func videoPlayingFinished(cell: ReelsCC)
    func videoVolumeStatusChanged(cell: ReelsCC)
    func didTapComment(cell: ReelsCC)
    func didTapLike(cell: ReelsCC)
    func didTapShare(cell: ReelsCC)
    func didTapOpenSource(cell: ReelsCC)
    func didTapEditArticle(cell: ReelsCC)
    func didTapAuthor(cell: ReelsCC)
    func didTapFollow(cell: ReelsCC, tagNo: Int)
    func didSingleTapDetected(cell: ReelsCC)
    func didTapHashTag(cell: ReelsCC, text: String)
    func didPangestureDetected(cell: ReelsCC, panGesture: UIPanGestureRecognizer, view: UIView)
    func didTapViewMore(cell: ReelsCC)
    func didTapViewMoreOptions(cell: ReelsCC)
    func didSwipeRight(cell: ReelsCC)
    func didTapRotateVideo(cell: ReelsCC)
    func didTapPlayVideo(cell: ReelsCC)
    
    func didTapCaptions(cell: ReelsCC)
    func didTapOpenCaptionType(cell: ReelsCC, action: String)
}

class ReelsCC: UICollectionViewCell {
    
    @IBOutlet var player: VideoPlayerView!
    
    @IBOutlet weak var descriptionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lblDescriptionAbove: UILabel!
    @IBOutlet weak var lblDescriptionGradient: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var imgVolume: UIImageView!
    @IBOutlet weak var lblSeeMore: ActiveLabel!
    @IBOutlet weak var viewGesture: UIView!
    @IBOutlet weak var viewGradient: UIView!
    @IBOutlet weak var imgVolumeAnimation: UIImageView!
    @IBOutlet weak var viewTransparentBG: UIView!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var lblCommentCount: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var stackViewButtons: UIStackView!
    @IBOutlet weak var viewEditArticle: UIView!
    @IBOutlet weak var btnEditArticle: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var lblChannelName: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var btnAuthor: UIButton!
    @IBOutlet weak var imgChannel: UIImageView!
    
    //    @IBOutlet weak var viewRotate: UIView!
    //    @IBOutlet weak var imgRotate: UIImageView!
    @IBOutlet weak var imgPlayButton: UIImageView!
    @IBOutlet weak var imgLikeAnimation: UIImageView!
    @IBOutlet weak var viewPlayButton: UIView!
    
    @IBOutlet weak var viewUser: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgUserPlus: UIImageView!
    @IBOutlet weak var btnUserPlus: UIButton!
    @IBOutlet weak var btnUserView: UIButton!
    @IBOutlet weak var viewSubTitle: UIView!
    
    //    @IBOutlet weak var ctHeadlineViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cSeeAutherStacViewHeight: NSLayoutConstraint!
    
    //    @IBOutlet weak var viewVolume: UIView!
    
    weak var delegate: ReelsCCDelegate?
    var isFullText = false
    var newsDescription = ""
    var reelUrl = ""
    var imageView: UIImageView?
    var isPlayWhenReady = false
    var reelModel: Reel?
    var isLoaderShowing = false
    @IBOutlet weak var imgThumbnailView: CustomImageView!
    
    let unlikedScale: CGFloat = 0.7
    let likedScale: CGFloat = 1.3
    private var generator = UIImpactFeedbackGenerator()
    
    var tapPressRecognizer = UITapGestureRecognizer()
    var imageGradient = UIImageView()
    
    // SubTitleView Constraints and Outlets
    
    @IBOutlet weak var viewBottomFooter: UIView!
    @IBOutlet weak var viewBottomTitleDescription: UIView!
    
    @IBOutlet weak var constraintImgLikeHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintImgCommentHeight: NSLayoutConstraint!
    
    //    @IBOutlet weak var viewCaptions: UIView!
    
    @IBOutlet weak var viewMoreReels: UIView!
    //    @IBOutlet weak var imgCaptions: UIImageView!
    
    @IBOutlet weak var viewMoreOptions: UIView!
    @IBOutlet weak var imageMoreOptions: UIImageView!
    
    @IBOutlet weak var viewSound: UIView!
    @IBOutlet weak var imgSound: UIImageView!
    
    
    @IBOutlet var gradientView: UIView!
    var currTime = -1.0
    var defaultLeftInset: CGFloat = 20.0
    var captionsArr: [UILabel]?
    var captionsViewArr: [UIView]?
    
    @IBOutlet var authorBottomConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //        lblTime.text = "        "
        //        lblViews.text = "        "
        lblSeeMore.text = "                 "
        lblChannelName.text = "                    "
        lblAuthor.text = "                    "
        //        viewDotTime.isHidden = true
        setupUIForSkelton()
        //        stopVideo()
        self.viewContent.backgroundColor = .black
        loader.isHidden = true
        loader.stopAnimating()
        
        //        viewMore.backgroundColor = "#E01335".hexStringToUIColor()
        imgVolume.image = nil
        //        lblViewMore.text = NSLocalizedString("VIEW MORE", comment: "").capitalized
        
        
        lblChannelName.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 17 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 17 + adjustFontSizeForiPad())
        lblAuthor.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 12 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 12 + adjustFontSizeForiPad())
        
        player.seek(to: .zero)
        
        if SharedManager.shared.bulletsAutoPlay {
            self.player.isHidden = false
        } else {
            self.player.isHidden = true
        }

        player.playToEndTime = {
            self.delegate?.videoPlayingFinished(cell: self)
        }
        
    }
    
    
    func setupUIForSkelton() {
        
        imgUser.cornerRadius = imgUser.frame.size.width / 2
        imgUser.borderWidth = 1.0
        imgUser.borderColor = UIColor.init(hexString: "F73458")
        //
        //        imgChannel.skeletonCornerRadius =  Float(imgChannel.frame.size.width / 2)
        //        lblTime.linesCornerRadius = 5
        //        lblViews.linesCornerRadius = 5
        //        lblSeeMore.linesCornerRadius = 5
        //        lblChannelName.linesCornerRadius = 5
        //        lblAuthor.linesCornerRadius = 5
        //
        //        viewMore.skeletonCornerRadius =  4
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //        player.isHidden = true
        self.loader.isHidden = true
        self.loader.stopAnimating()
        self.pause()
        player.seek(to: .zero)
        viewBottomFooter.isHidden = true
        viewBottomTitleDescription.isHidden = true
        
        for recognizer in viewSubTitle.gestureRecognizers ?? [] {
            viewSubTitle.removeGestureRecognizer(recognizer)
        }
        //        self.player?.view.removeFromSuperview()
        //        self.player = nil
        //        lblTime.text = "        "
        //        lblViews.text = "        "
        lblSeeMore.text = "                 "
        lblChannelName.text = "                    "
        lblAuthor.text = "                    "
        //        viewDotTime.isHidden = true
        btnUserPlus.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        btnUserView.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
        hideLoader()
        ANLoader.hide()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setDescriptionLabel()
        
        //        if UIDevice.current.hasNotch {
        //            ctHeadlineViewHeight.constant = 120
        //        }
        //        else {
        //            ctHeadlineViewHeight.constant = 80
        //        }
        
        player.frame = CGRectMake(0, 0, self.viewContent.frame.size.width, self.viewContent.frame.size.height)
        player.backgroundColor = .clear
        self.imgThumbnailView.isHidden = false
        player.stateDidChanged = { state in
            switch state {
            case .none:
                print("none")
            case .error(let error):
                print("error - \(error.localizedDescription)")
            case .loading:
                print("loading")
            case .paused(let playing, let buffering):
                print("paused - progress \(Int(playing * 100))% buffering \(Int(buffering * 100))%")
                DispatchQueue.main.async {
                    self.imgThumbnailView.isHidden = true
                    if self.loader.isHidden == false {
                        self.loader.isHidden = true
                        self.loader.stopAnimating()
                    }
                    self.hideLoader()
                }
            case .playing:
                DispatchQueue.main.async {
                    self.imgThumbnailView.isHidden = true
                    if self.loader.isHidden == false {
                        self.loader.isHidden = true
                        self.loader.stopAnimating()
                    }
                    self.play()
                    self.loader.stopAnimating()
                    self.hideLoader()
                }
            }
        }
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblSeeMore.semanticContentAttribute = .forceRightToLeft
                self.lblSeeMore.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblSeeMore.semanticContentAttribute = .forceLeftToRight
                self.lblSeeMore.textAlignment = .left
            }
        }
        
    }
    
    override func layoutIfNeeded() {
        //        self.layoutSkeletonIfNeeded()
        
        //        setupUIForSkelton()
    }
    
    //    override func didMoveToSuperview() {
    //        super.didMoveToSuperview()
    //        setNeedsLayout()
    //    }
    
    func pause() {
        player.pause(reason: .hidden)
    }
    func play() {
        
        setImage()
        
        if let url = URL(string: reelModel?.media ?? "") {
            player.play(for: url)
            if SharedManager.shared.isAudioEnableReels == false {
                player.volume = 0
                self.imgSound.image = UIImage(named: "newMuteIC")
            } else {
                
                player.volume = 1
                self.imgSound.image = UIImage(named: "newUnmuteIC")
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        //        self.layoutSkeletonIfNeeded()
    }
    
    func cellLayoutUpdate() {
        
        if (reelModel?.captions?.count ?? 0) > 0 {
            viewBottomFooter.isHidden = true
            viewBottomTitleDescription.isHidden = true
            
            self.currTime = -1
            loadCaptions(time: 0)
            
        }
        else {
            
            if (reelModel?.captionAPILoaded ?? false) {
                self.viewBottomFooter.isHidden = false
                self.viewBottomTitleDescription.isHidden = false
            }
            else {
                self.viewBottomFooter.isHidden = true
                self.viewBottomTitleDescription.isHidden = true
            }
            
        }
    }
    
    func setupCell(model: Reel) {
        
        reelModel = model
        if let captionsLabel = self.captionsArr {
            
            for label in captionsLabel {
                
                label.removeFromSuperview()
            }
        }
        
        if let captionsView = self.captionsViewArr {
            
            for view in captionsView {
                
                view.removeFromSuperview()
            }
        }
        
        self.viewSubTitle.subviews.forEach { $0.removeFromSuperview() }
        self.captionsArr?.removeAll()
        self.captionsViewArr?.removeAll()
        
        //        // Gradient image
        //        imageGradient.isHidden = false
        //        imageGradient.image = nil
        //        if imageGradient.image == nil {
        //            let grad = SharedManager.shared.getGradient(viewGradient: viewGradient, colours: [UIColor.clear, "#131313".hexStringToUIColor()], locations: [0.0, 1.0])
        //            imageGradient.image = SharedManager.shared.getImageFrom(gradientLayer: grad)
        //        }
        //
        //        //imageGradient.backgroundColor = "#131313".hexStringToUIColor()
        //        print("gardient added ")
        
        
        imgChannel.image = nil
        viewTransparentBG.isHidden = true
        if let url = URL(string:model.media ?? "") {
            self.reelUrl = model.media ?? ""
            //            player?.delegate = self
            //Geasture for video like
            if SharedManager.shared.bulletsAutoPlay {
                self.player.play(for: url)
            }
            self.pause()
            self.player.pause()
            
            let asset = AVURLAsset(url: url)
            asset.loadValuesAsynchronously(forKeys: ["playable", "tracks", "duration"])
            DispatchQueue.main.async {
                
            }
            
            let tapDoublePressRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureAction(sender:)))
            tapDoublePressRecognizer.numberOfTapsRequired = 2
            tapDoublePressRecognizer.delegate = self
            viewSubTitle.addGestureRecognizer(tapDoublePressRecognizer)
            
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureAction(sender:)))
            longPressRecognizer.minimumPressDuration = 0.5
            longPressRecognizer.delegate = self
            viewSubTitle.addGestureRecognizer(longPressRecognizer)
            
            tapPressRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapGestureGestureAction(sender:)))
            tapPressRecognizer.numberOfTapsRequired = 1
            tapPressRecognizer.delegate = self
            viewSubTitle.addGestureRecognizer(tapPressRecognizer)
            
            tapPressRecognizer.require(toFail: tapDoublePressRecognizer)
            tapPressRecognizer.delaysTouchesBegan = true
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeRight.direction = .left
            viewSubTitle.addGestureRecognizer(swipeRight)
            
            
            let tapPressRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(tapGestureGestureAction(sender:)))
            tapPressRecognizer2.numberOfTapsRequired = 1
            tapPressRecognizer2.delegate = self
            self.viewTransparentBG.addGestureRecognizer(tapPressRecognizer2)
            
            
            if SharedManager.shared.reelsAutoPlay {
                viewPlayButton.isHidden = true
            } else {
                viewPlayButton.isHidden = false
            }
        }
        
        setLikeComment(model: model.info, showAnimation: false)
        
        imgVolume.image = nil
        imgVolume.alpha = 0
        
        hideLoader()
        setImage()
        
        //update like status of video
        imgLike.image = nil
        if model.info?.isLiked ?? false {
            
            imgLike.image = UIImage(named: "newLikedIC")
        } else {
            
            imgLike.image = UIImage(named: "newLikeIC")
        }
        
        //Volumne status
        setVolumeStatus()
        
        /*
         if URL(string: model.media_landscape ?? "") != nil {
         viewRotate.isHidden = false
         } else {
         viewRotate.isHidden = true
         }*/
        
        
        self.setCaptionImage()
        
        self.currTime = -1
        self.currTime = -1
        self.cellLayoutUpdate()
        
    }
    
    func setVolumeStatus(){
        self.imgSound.image = nil
        if SharedManager.shared.isAudioEnableReels == false {
            player.volume = 0.0
            self.imgSound.image = UIImage(named: "newMuteIC")
        }
        else {
            player.volume = 1.0
            self.imgSound.image = UIImage(named: "newUnmuteIC")
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
            case .down:
                print("Swiped down")
            case .left:
                print("Swiped left")
                self.delegate?.didSwipeRight(cell: self)
                break;
                
            case .up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    func clearPlayer() {
        
        //        if let url = URL(string: reelModel?.media ?? "") {
        //            self.player!.set(AVURLAsset(url: url),clear: true)
        //        }
    }
    
    func setLikeComment(model: Info?, showAnimation: Bool) {
        
        reelModel?.info = model
        lblLikeCount.minimumScaleFactor = 0.5
        lblCommentCount.minimumScaleFactor = 0.5
        //        if model?.likeCount ?? 0 == 0 {
        //            lblLikeCount.text = ""
        //            constraintImgLikeHeight.constant = 0
        //        }
        //        else {
        //            lblLikeCount.text = SharedManager.shared.formatPoints(num: Double((model?.likeCount ?? 0)))
        //            constraintImgLikeHeight.constant = 15
        //        }
        //
        //        if (model?.commentCount ?? 0) == 0 {
        //            lblCommentCount.text = ""
        //            constraintImgCommentHeight.constant = 0
        //        }
        //        else {
        //            lblCommentCount.text = SharedManager.shared.formatPoints(num: Double((model?.commentCount ?? 0)))
        //            constraintImgCommentHeight.constant = 15
        //        }
        //
        
        if (reelModel?.info?.isLiked ?? false) == false {
            imgLike.isHighlighted = false
        } else {
            if showAnimation {
                startLikeAnimation()
            } else {
                imgLike.isHighlighted = true
            }
        }
    }
    
    func setDescriptionLabel(){
        lblDescriptionAbove.text = (reelModel?.reelDescription ?? "").uppercased()
        lblDescriptionAbove.textColor = UIColor.white
        lblDescriptionAbove.font = UIFont(name: Constant.FONT_Gilroy_ExtraBold, size: 22 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 20 + adjustFontSizeForiPad())
//        lblDescriptionGradient.removeGradient()
//        descriptionViewHeight.constant = lblDescriptionAbove.frame.height
//        let colorLeading =  UIColor(hexString: "#00000000").cgColor
//        let colorCenter = UIColor(hexString: "#2E000000").cgColor
//        let colorTrailing = UIColor(hexString: "#00000000").cgColor
        
        lblDescriptionGradient.backgroundColor = UIColor(patternImage: UIImage(named: "labelGradeintBackkground")!)

        
//        lblDescriptionGradient.gradient(colors: [colorLeading, colorCenter, colorTrailing])
    }
    
    func setSeeMoreLabel() {
        
        viewUser.isHidden = false
        lblSeeMore.textColor = UIColor.white
        
        
        if newsDescription.length > 85 {
            lblSeeMore.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 15 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 15 + adjustFontSizeForiPad())
            lblDescriptionAbove.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 15 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 15 + adjustFontSizeForiPad())
        }
        else if newsDescription.length > 60 {
            lblSeeMore.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 17 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 17 + adjustFontSizeForiPad())
            lblDescriptionAbove.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 17 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 17 + adjustFontSizeForiPad())
        } else {
            lblSeeMore.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 18 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 18 + adjustFontSizeForiPad())
            lblDescriptionAbove.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 18 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 18 + adjustFontSizeForiPad())
        }
        
        lblSeeMore.customize { (label) in
            
            label.text = newsDescription
            label.numberOfLines = 5
            //            switch UIDevice().type {
            //
            //            case .iPhoneXR, .iPhoneXSMax, .iPhoneX, .iPhoneXS, .iPhone11Pro, .iPhone11ProMax, .iPhone12Pro, .iPhone12, .iPhone12ProMax, .iPhone13Pro, .iPhone13, .iPhone13ProMax:
            //                label.numberOfLines = 4
            //                break
            //
            //            default:
            //                label.numberOfLines = 2
            //                break
            //            }
            
            label.enabledTypes = [.hashtag]
            label.hashtagColor = UIColor.white
            
            label.handleHashtagTap { (string) in
                if string.contains("...") {
                    return
                }
                // action
                self.delegate?.didTapHashTag(cell: self, text: string)
            }
        }
        print("Reels text", newsDescription)
        
        //    lblSeeMore.addTextSpacing(spacing: 1.0)
    }
    
    
    @objc func longPressGestureAction(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            PauseVideo()
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            if player.state != .playing {
                playVideo()
            }
        }
    }
    
    @objc func doubleTapGestureAction(sender: UILongPressGestureRecognizer) {
        
        if self.reelModel?.info?.isLiked == false {
            self.delegate?.didTapLike(cell: self)
        } else {
            startLikeAnimation()
        }
    }
    
    
    @objc func singleTapGestureGestureAction(sender: UILongPressGestureRecognizer) {
        
        self.delegate?.didSingleTapDetected(cell: self)
    }
    
    @objc func tapGestureGestureAction(sender: UILongPressGestureRecognizer) {
        
    }
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        
        self.delegate?.didPangestureDetected(cell: self, panGesture: panGesture, view: viewSubTitle)
    }
    
    func startLikeAnimation() {
        
        tapPressRecognizer.isEnabled = false
        self.imgLikeAnimation.isHidden = false
        if #available(iOS 13.0, *) {
            generator = UIImpactFeedbackGenerator(style: .rigid)
        } else {
            
            generator = UIImpactFeedbackGenerator(style: .light)
        }
        generator.impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            
            //            let newImage = UIImage(named: "likeAnimateHeart")
            let newScale = self.likedScale//self.isLiked ? self.likedScale : self.unlikedScale
            self.imgLikeAnimation.transform = self.transform.scaledBy(x: newScale, y: newScale)
            //            self.imgLikeAnimation.image = newImage
            
            self.imgLike.transform = self.transform.scaledBy(x: newScale, y: newScale)
            //always send false for only like animation
            //            let likedImage = UIImage(named: "ReelsLiked")
            self.imgLike.isHighlighted = true
            
            
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.2) {
                self.imgLikeAnimation.transform = CGAffineTransform.identity
                self.imgLike.transform = CGAffineTransform.identity
                self.stopLikeAnimation()
            } completion: { status in
                self.tapPressRecognizer.isEnabled = true
            }
            
            
        })
    }
    
    @IBAction func didTapPlayButton(_ sender: Any) {
        
        self.delegate?.didTapPlayVideo(cell: self)
    }
    
    
    @IBAction func didTapRotate(_ sender: Any) {
        
        self.delegate?.didTapRotateVideo(cell: self)
    }
    
    func stopLikeAnimation() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.imgLikeAnimation.isHidden = true
        }
    }
    
    private func addPlayerToView(videoInfo: MediaMeta?) {
        
        
        //        if player?.preferredBufferTime ?? 2 > 1 {
        //            player?.preferredBufferTime = 1
        //        }
        //        player?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //        player?.view.frame = self.viewContent.frame
        //        if videoInfo?.width ?? 0 >  videoInfo?.height ?? 0 {
        //            imgThumbnailView?.contentMode = .scaleAspectFit
        //            player?.fillMode = .fit
        //        } else {
        //            self.layoutIfNeeded()
        //            let containerRatio = self.frame.size.height / self.frame.size.width
        //            let videoRatio = (videoInfo?.height ?? 1) / (videoInfo?.width ?? 1)
        //            print("aspect containerRatio", containerRatio)
        //            print("aspect videoRatio", videoRatio)
        //            print("aspect difference", videoRatio)
        //
        //            if containerRatio >= CGFloat(videoRatio) {
        //                imgThumbnailView?.contentMode = .scaleAspectFit
        //                player?.fillMode = .fit
        //                print("aspect video fit", reelModel?.reelDescription ?? "")
        //            } else {
        //                imgThumbnailView?.contentMode = .scaleAspectFill
        //                player?.fillMode = .fill
        //                print("aspect video fill", reelModel?.reelDescription ?? "")
        //            }
        //
        //        }
        //
        //        self.viewContent.insertSubview(player?.view ?? UIView(), at: 0)
        //
        //
        //        if player?.automaticallyWaitsToMinimizeStalling ?? true {
        //            player?.automaticallyWaitsToMinimizeStalling = false
        //        }
        
        
        //        self.viewContent.insertSubview(player, at: 0)
        
        
        
        //        self.viewBackground.insertSubview(imgThumbnailView!, at: 0)
        //        self.player.insertSubview(imgThumbnailView!, at: 0)
        self.player.addSubview(imgThumbnailView!)
        
        imgThumbnailView?.layoutIfNeeded()
        imgThumbnailView?.isHidden = false
    }
    
    func setImage() {
        
        if reelModel?.mediaMeta?.width ?? 0 >  reelModel?.mediaMeta?.height ?? 0 {
            imgThumbnailView?.contentMode = .scaleAspectFit
            player.contentMode = .scaleAspectFit
        } else {
            let containerRatio = self.frame.size.height / self.frame.size.width
            let videoRatio = (reelModel?.mediaMeta?.height ?? 1) / (reelModel?.mediaMeta?.width ?? 1)
            
            if containerRatio >= CGFloat(videoRatio) {
                imgThumbnailView?.contentMode = .scaleAspectFit
            } else {
                imgThumbnailView?.contentMode = .scaleAspectFill
            }
            
        }
        
        imgThumbnailView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imgThumbnailView?.frame = self.viewContent.frame
        
        SharedManager.shared.loadImageFromCache(imageURL: reelModel?.image ?? "") { [weak self] image in
            if image == nil {
                self?.imgThumbnailView?.sd_setImage(with: URL(string: self?.reelModel?.image ?? "") , placeholderImage: nil)
            } else {
                self?.imgThumbnailView?.image = image
            }
        }
        
    }
    
    func setFollowButton(hidden: Bool) {
        
        imgUserPlus.isHidden = hidden
    }
    
    func playVideo() {
        
        setFollowButton(hidden: reelModel?.source?.favorite ?? false)
        viewPlayButton.isHidden = true
        isPlayWhenReady = true
        if SharedManager.shared.isAudioEnableReels == false {
            player.volume = 0.0
            self.imgSound.image = UIImage(named: "newMuteIC")
        } else {
            
            player.volume = 1.0
            self.imgSound.image = UIImage(named: "newUnmuteIC")
        }
        
        self.setCaptionImage()
        
        if player.state != .playing {
            self.play()
        } else if (player.totalDuration) >= (player.currentDuration) {
            player.seek(to: .zero)
            self.play()
        }
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        //            if self.player != nil && self.isPlayWhenReady && self.player?.time == 0 {
        //                self.loader.isHidden = false
        //                self.loader.startAnimating()
        //                self.player?.play()
        //            }
        //        }
        
        SharedManager.shared.performWSToUpdateArticleAnalytics(ArticleId: reelModel?.id ?? "", isFromReel: true)
    }
    
    func resumeVideoPlay(time: TimeInterval?) {
        
        viewPlayButton.isHidden = true
        isPlayWhenReady = true
        if SharedManager.shared.isAudioEnableReels == false {
            
            player.volume = 0.0
            self.imgSound.image = UIImage(named: "newMuteIC")
        }
        else {
            
            player.volume = 1.0
            self.imgSound.image = UIImage(named: "newUnmuteIC")
        }
        
        self.setCaptionImage()
        
        if let time = time {
            player.seek(to: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }
        
        self.play()
        
        removeAllCaptions()
        
    }
    
    
    func removeAllCaptions() {
        
        if let captionsLabel = self.captionsArr {
            
            for label in captionsLabel {
                
                label.removeFromSuperview()
            }
        }
        if let captionsView = self.captionsViewArr {
            
            for view in captionsView {
                
                view.removeFromSuperview()
            }
        }
        self.viewSubTitle.subviews.forEach { $0.removeFromSuperview() }
        self.captionsArr?.removeAll()
        self.captionsViewArr?.removeAll()
        
        self.currTime = -1.0
    }
    
    func stopVideo() {
        
        print("Stop Video called")
        removeAllCaptions()
        
        if SharedManager.shared.reelsAutoPlay == false {
            viewPlayButton.isHidden = false
        }
        isPlayWhenReady = false
        //        player.seek(to: .zero)
        //        player.pause()
        self.pause()
        
        self.viewTransparentBG.isHidden = true
        self.isFullText = false
        self.setSeeMoreLabel()
        
        self.currTime = -1
        cellLayoutUpdate()
    }
    
    func PauseVideo() {
        
        isPlayWhenReady = false
        //        player.pause()
        
    }
    
    func showVolumeOnAnimation() {
        imgVolume.image = UIImage(named: "ReelsSoundOn")
        UIView.animate(withDuration: 0.5) {
            self.imgVolume.alpha = 1
        } completion: { (status) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.5) {
                    self.imgVolume.alpha = 0
                } completion: { (status) in
                    self.imgVolume.alpha = 0
                }
            }
        }
    }
    
    func showVolumeOffAnimation() {
        imgVolume.image = UIImage(named: "ReelsSoundOff")
        UIView.animate(withDuration: 0.5) {
            self.imgVolume.alpha = 1
        } completion: { (status) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.5) {
                    self.imgVolume.alpha = 0
                } completion: { (status) in
                    self.imgVolume.alpha = 0
                }
            }
        }
    }
    
    func showLoader() {
        
        isLoaderShowing = true
        
        imgVolumeAnimation.isHidden = true
        stackViewButtons.isHidden = true
        //        lblTime.text = "        "
        //        lblViews.text = "        "
        lblSeeMore.text = "                 "
        lblChannelName.text = "                    "
        lblAuthor.text = "                    "
        //        viewDotTime.isHidden = true
        //        self.updateSkeleton(usingColor: .gray)
        //        self.layoutSkeletonIfNeeded()
        //        self.showAnimatedSkeleton(usingColor: .gray)
        //        self.layoutSkeletonIfNeeded()
        
        self.viewContent.backgroundColor = .black
    }
    
    func hideLoader() {
        
        isLoaderShowing = false
        
        stackViewButtons.isHidden = false
        //        self.layoutSkeletonIfNeeded()
        //        self.hideSkeleton(transition: .crossDissolve(0.25))
        //        self.layoutSkeletonIfNeeded()
        //        if let publishDate = reelModel?.publishTime {
        //
        //            lblTime.text = SharedManager.shared.generateDatTimeOfNews(publishDate).uppercased()
        //            lblTime.addTextSpacing(spacing: 2.0)
        //
        //            viewDotTime.isHidden = false
        //        }
        
        //Check source if its not available then use author
        if let source = reelModel?.source {
            
            setFollowButton(hidden: source.favorite ?? false)
            lblChannelName.text = source.name?.capitalized ?? ""
            imgUser.sd_setImage(with: URL(string: source.icon ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
        }
        else {
            
            setFollowButton(hidden: reelModel?.authors?.first?.favorite ?? false)
            lblChannelName.text = reelModel?.authors?.first?.username ?? reelModel?.authors?.first?.name ?? ""
            imgUser.sd_setImage(with: URL(string: reelModel?.authors?.first?.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
        }
        
        let author = reelModel?.authors?.first?.username ?? reelModel?.authors?.first?.name ?? ""
        let source = reelModel?.source?.name ?? ""
        
        if author == source || author == "" {
            lblAuthor.isHidden = true
            lblChannelName.text = source
            cSeeAutherStacViewHeight.constant = 25
        }
        else {
            
            lblChannelName.text = source
            //            lblAuthor.text = author
            cSeeAutherStacViewHeight.constant = 25
            if source == "" {
                lblAuthor.isHidden = true
                lblChannelName.text = author
                cSeeAutherStacViewHeight.constant = 25
            }
            //            else if author != "" {
            //                lblAuthor.isHidden = false
            //                cSeeAutherStacViewHeight.constant = 43
            //            }
        }
        
        newsDescription = reelModel?.reelDescription ?? ""
        isFullText = false
        setSeeMoreLabel()
//        setDescriptionLabel()
        descriptionView.isHidden = true
        lblSeeMore.isHidden = true
        if let type = reelModel?.mediaMeta?.type{
            if type == "fastreel", let nativeTitle = reelModel?.nativeTitle{
                if nativeTitle == true {
                    lblSeeMore.isHidden = nativeTitle
                    authorBottomConstraint?.constant = -25
                    descriptionView.isHidden = !nativeTitle
                    lblDescriptionAbove.text = newsDescription.uppercased()
                }
            }else if type == "reel", let nativeTitle = reelModel?.nativeTitle{
                if nativeTitle == true {
                    lblSeeMore.isHidden = !nativeTitle
                    authorBottomConstraint?.constant = 0
                    descriptionView.isHidden = nativeTitle
                }
            }else{
                authorBottomConstraint?.constant = -25
                lblSeeMore.isHidden = true
                descriptionView.isHidden = true
            }
        }else{
            if let nativeTitle = reelModel?.nativeTitle {
                if nativeTitle {
                    lblSeeMore.isHidden = !nativeTitle
                    authorBottomConstraint?.constant = 0
                } else if !nativeTitle {
                    authorBottomConstraint?.constant = -25
                }
            }
        }
        
//        if let nativeTitle = reelModel?.nativeTitle {
//            lblSeeMore.isHidden = !nativeTitle
//            if nativeTitle {
//                if let type = reelModel?.mediaMeta?.type{
//                    if type == "fastreel"{
//                        lblSeeMore.isHidden = nativeTitle
//                        authorBottomConstraint?.constant = -25
//                        descriptionView.isHidden = !nativeTitle
//                        lblDescriptionAbove.text = newsDescription.uppercased()
//                    }else{
//                        lblSeeMore.isHidden = !nativeTitle
//                        authorBottomConstraint?.constant = 0
//                        descriptionView.isHidden = nativeTitle
//                    }
//                }
//            } else if !nativeTitle {
//                authorBottomConstraint?.constant = -25
//            } else {
//                authorBottomConstraint?.constant = 0
//            }
//        } else {
//            lblSeeMore.isHidden = false
//            authorBottomConstraint?.constant = 0
//        }
        
        let formater = NumberFormatter()
        formater.groupingSeparator = ","
        formater.locale = Locale.current
        formater.numberStyle = .decimal
        let formattedNumber = formater.string(from: NSNumber(value: Int(reelModel?.info?.viewCount ?? "0") ?? 0))
        //        lblViews.text = "\(formattedNumber ?? "") \(NSLocalizedString("Views", comment: ""))".uppercased()
        
        viewContent.backgroundColor = .black
    }
    
    //MARK:- Button Actions
    //    @IBAction func didTapViewMore(_ sender: Any) {
    //        self.delegate?.didTapViewMore(cell: self)
    //    }
    
    @IBAction func didTapLikeButton(_ sender: Any) {
        self.delegate?.didTapLike(cell: self)
    }
    
    @IBAction func didTapCommentButton(_ sender: Any) {
        
        self.delegate?.didTapComment(cell: self)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        
        self.delegate?.didTapShare(cell: self)
    }
    
    @IBAction func didTapOpenSource(_ sender: Any) {
        
        self.delegate?.didTapOpenSource(cell: self)
    }
    
    @IBAction func didTapEditArticle(_ sender: Any) {
        
        self.delegate?.didTapEditArticle(cell: self)
    }
    
    @IBAction func didTapAuthor(_ sender: Any) {
        
        self.delegate?.didTapAuthor(cell: self)
    }
    
    @IBAction func didTapFollow(_ sender: UIButton) {
        
        self.delegate?.didTapFollow(cell: self, tagNo: sender.tag)
    }
    
    @IBAction func didTapVolumeButton(_ sender: Any) {
        
        if SharedManager.shared.isAudioEnableReels == false {
            
            SharedManager.shared.isAudioEnableReels = true
            //            SharedManager.shared.isAudioEnable = true
            
            player.volume = 1.0
            self.imgSound.image = UIImage(named: "newUnmuteIC")
        }
        else {
            
            SharedManager.shared.isAudioEnableReels = false
            //            SharedManager.shared.isAudioEnable = false
            player.volume = 0.0
            self.imgSound.image = UIImage(named: "newMuteIC")
        }
        
        self.delegate?.videoVolumeStatusChanged(cell: self)
    }
    
    /*
     @IBAction func didTapCaptions(_ sender: Any) {
     
     SharedManager.shared.isCaptionsEnableReels = !SharedManager.shared.isCaptionsEnableReels
     
     self.setCaptionImage()
     
     self.delegate?.didTapCaptions(cell: self)
     }*/
    
    func setCaptionImage() {
        
        /*
         let forcedCaptions = reelModel?.captions?.filter({ $0.forced == true })
         if (reelModel?.captions?.count ?? 0) > 0 {
         if forcedCaptions?.count == (reelModel?.captions?.count ?? 0) {
         viewCaptions.isHidden = true
         }
         else {
         viewCaptions.isHidden = false
         }
         } else {
         viewCaptions.isHidden = true
         }
         
         cellLayoutUpdate()
         
         if SharedManager.shared.isCaptionsEnableReels == false {
         
         self.imgCaptions.image = UIImage(named: "captionsUnselected")
         
         //            for (index, caption) in reelModel?.captions?.enumerated() {
         //
         //
         //            }
         //            if let captionsLabel = self.captionsArr {
         //
         //                for label in captionsLabel {
         //
         //                    label.removeFromSuperview()
         //                }
         //            }
         //
         //            if let captionsView = self.captionsViewArr {
         //
         //                for view in captionsView {
         //
         //                    view.removeFromSuperview()
         //                }
         //            }
         //
         //            self.captionsArr?.removeAll()
         //            self.captionsViewArr?.removeAll()
         }
         else {
         self.imgCaptions.image = UIImage(named: "captionsSelected")
         
         }
         
         */
    }
    
    
    
    @IBAction func didTapViewMoreReels(_ sender: Any) {
        
        self.delegate?.didTapViewMore(cell: self)
    }
    
    
    
    @IBAction func didTapViewMoreOptions(_ sender: Any) {
        self.delegate?.didTapViewMoreOptions(cell: self)
    }
    
    
    
}

extension ReelsCC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        else if gestureRecognizer is UILongPressGestureRecognizer {
            return false
        } else {
            return true
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ReelsCC: PlayerDelegate {
    
    // MARK: VideoPlayerDelegate
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        
        switch player.state {
        case .loading:
            
            
            break
        case .ready:
            if loader.isHidden == false {
                loader.isHidden = true
                loader.stopAnimating()
            }
            hideLoader()
            if isPlayWhenReady && player.playing == false {
                player.play()
            }
            break
            
        case .failed:
            hideLoader()
            ANLoader.hide()
            print("video loading failed")
            
        }
    }
    
    func playerDidUpdatePlaying(player: Player) {
        if isLoaderShowing {
            hideLoader()
        }
    }
    
    func loadCaptions(time: Double) {
        
        if let captions = reelModel?.captions, captions.count > 0 {
            
            if self.currTime != time {
                self.currTime = time
                self.updateSubTitlesWithTime(currTime: time, captions: captions)
            }
            
        }
        
    }
    
    //MARK:- Captions setup
    func playerDidUpdateTime(player: Player) {
        
        let time = (player.time)
        loadCaptions(time: time)
        
        
        if imgThumbnailView?.isHidden == false {
            imgThumbnailView?.isHidden = true
        }
        
        //        print("playerDidUpdateTime")
        guard player.duration > 0 else {
            return
        }
        
        if loader.isHidden == false {
            loader.isHidden = true
            loader.stopAnimating()
        }
        
        if isLoaderShowing {
            hideLoader()
        }
        
        if player.duration <= player.time {
            self.delegate?.videoPlayingFinished(cell: self)
        }
    }
    
    func playerDidUpdateBufferedTime(player: Player) {
        
        guard player.duration > 0 else {
            return
        }
    }
}


extension RegularPlayer
{
    public var automaticallyWaitsToMinimizeStalling: Bool {
        get {
            return self.player.automaticallyWaitsToMinimizeStalling
        }
        set {
            self.player.automaticallyWaitsToMinimizeStalling = newValue
        }
    }
    
    public var preferredBufferTime: Double {
        get {
            return self.player.currentItem?.preferredForwardBufferDuration ?? 2
        }
        set {
            self.player.currentItem?.preferredForwardBufferDuration = newValue
        }
    }
}


let imageCache = NSCache<AnyObject, AnyObject>()
class CustomImageView: UIImageView {
    var imageUrlString: String?
    
    func loadImageUsingUrlString(urlString: String) {
        imageUrlString = urlString
        let url = URL(string: urlString)
        image = nil
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
//        self.image = UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light")
        if let url {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                if error != nil {
                    return
                }
                DispatchQueue.main.async {
                    let imageToCache = UIImage (data: data)
                    if self.imageUrlString == urlString {
                        self.image = imageToCache
                    }
                    imageCache.setObject(imageToCache!, forKey: urlString as AnyObject)
                }
            }.resume()
        }
    }
    
}


extension UIView
{
    func gradient(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.transform = CATransform3DMakeRotation(270 / 180 * CGFloat.pi, 0, 0, 1) // New line
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.opacity = 1.0
        gradientLayer.name = "gradient"
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
