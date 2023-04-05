//
//  ReelsCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 29/03/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import ActiveLabel
import AVFoundation
import PlayerKit
import UIKit

import CoreHaptics
import GSPlayer

// MARK: - ReelsCCDelegate

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

// MARK: - ReelsCC

class ReelsCC: UICollectionViewCell {
    @IBOutlet var player: VideoPlayerView!

    @IBOutlet var descriptionViewHeight: NSLayoutConstraint!
    @IBOutlet var lblDescriptionAbove: UILabel!
    @IBOutlet var lblDescriptionGradient: UILabel!
    @IBOutlet var descriptionView: UIView!
    @IBOutlet var viewContent: UIView!
    @IBOutlet var imgVolume: UIImageView!
    @IBOutlet var lblSeeMore: ActiveLabel!
    @IBOutlet var viewGesture: UIView!
    @IBOutlet var viewGradient: UIView!
    @IBOutlet var imgVolumeAnimation: UIImageView!
    @IBOutlet var viewTransparentBG: UIView!
    @IBOutlet var lblLikeCount: UILabel!
    @IBOutlet var lblCommentCount: UILabel!
    @IBOutlet var imgLike: UIImageView!
    @IBOutlet var viewBackground: UIView!
    @IBOutlet var stackViewButtons: UIStackView!
    @IBOutlet var viewEditArticle: UIView!
    @IBOutlet var btnEditArticle: UIButton!
    @IBOutlet var loader: UIActivityIndicatorView!

    @IBOutlet var lblChannelName: UILabel!
    @IBOutlet var lblAuthor: UILabel!
    @IBOutlet var btnAuthor: UIButton!
    @IBOutlet var imgChannel: UIImageView!

    @IBOutlet var imgPlayButton: UIImageView!
    @IBOutlet var imgLikeAnimation: UIImageView!
    @IBOutlet var viewPlayButton: UIView!

    @IBOutlet var viewUser: UIView!
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var imgUserPlus: UIImageView!
    @IBOutlet var btnUserPlus: UIButton!
    @IBOutlet var btnUserView: UIButton!
    @IBOutlet var viewSubTitle: UIView!

    @IBOutlet var cSeeAutherStacViewHeight: NSLayoutConstraint!

    weak var delegate: ReelsCCDelegate?
    var isFullText = false
    var newsDescription = ""
    var reelUrl = ""
    var imageView: UIImageView?
    var isPlayWhenReady = false
    var reelModel: Reel?
    var isLoaderShowing = false
    @IBOutlet var imgThumbnailView: CustomImageView!

    let likedScale: CGFloat = 1.3
    private var generator = UIImpactFeedbackGenerator()

    var tapPressRecognizer = UITapGestureRecognizer()

    @IBOutlet var viewBottomFooter: UIView!
    @IBOutlet var viewBottomTitleDescription: UIView!

    @IBOutlet var constraintImgLikeHeight: NSLayoutConstraint!
    @IBOutlet var constraintImgCommentHeight: NSLayoutConstraint!

    @IBOutlet var viewMoreReels: UIView!

    @IBOutlet var viewMoreOptions: UIView!
    @IBOutlet var imageMoreOptions: UIImageView!

    @IBOutlet var viewSound: UIView!
    @IBOutlet var imgSound: UIImageView!

    @IBOutlet var gradientView: UIView!
    var currTime = -1.0
    var defaultLeftInset: CGFloat = 20.0
    var captionsArr: [UILabel]?
    var captionsViewArr: [UIView]?

    @IBOutlet var authorBottomConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()

        lblSeeMore.text = "                 "
        lblChannelName.text = "                    "
        lblAuthor.text = "                    "

        setupUIForSkelton()

        viewContent.backgroundColor = .black
        loader.isHidden = true
        loader.stopAnimating()

        imgVolume.image = nil

        lblChannelName.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 17 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 17 + adjustFontSizeForiPad())
        lblAuthor.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 12 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 12 + adjustFontSizeForiPad())

        player.seek(to: .zero)

        if SharedManager.shared.bulletsAutoPlay {
            player.isHidden = false
        } else {
            player.isHidden = true
        }

        player.playToEndTime = {
            self.delegate?.videoPlayingFinished(cell: self)
        }
    }

    func setupUIForSkelton() {
        imgUser.cornerRadius = imgUser.frame.size.width / 2
        imgUser.borderWidth = 1.0
        imgUser.borderColor = UIColor(hexString: "F73458")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        loader.isHidden = true
        loader.stopAnimating()
        pause()
        player.seek(to: .zero)
        viewBottomFooter.isHidden = true
        viewBottomTitleDescription.isHidden = true

        for recognizer in viewSubTitle.gestureRecognizers ?? [] {
            viewSubTitle.removeGestureRecognizer(recognizer)
        }

        lblSeeMore.text = "                 "
        lblChannelName.text = "                    "
        lblAuthor.text = "                    "

        btnUserPlus.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        btnUserView.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        hideLoader()
        ANLoader.hide()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setDescriptionLabel()

        player.frame = CGRectMake(0, 0, viewContent.frame.size.width, viewContent.frame.size.height)
        player.backgroundColor = .clear
        imgThumbnailView.isHidden = false
        player.stateDidChanged = { state in
            switch state {
            case .none:
                print("none")
            case let .error(error):
                print("error - \(error.localizedDescription)")
            case .loading:
                print("loading")
            case let .paused(playing, buffering):
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

    func pause() {
        player.pause(reason: .hidden)
    }

    func play() {
        setImage()

        if let url = URL(string: reelModel?.media ?? "") {
            player.play(for: url)
            if SharedManager.shared.isAudioEnableReels == false {
                player.volume = 0
                imgSound.image = UIImage(named: "newMuteIC")
            } else {
                player.volume = 1
                imgSound.image = UIImage(named: "newUnmuteIC")
            }
        }
    }

    override func draw(_: CGRect) {}

    func cellLayoutUpdate() {
        if (reelModel?.captions?.count ?? 0) > 0 {
            viewBottomFooter.isHidden = true
            viewBottomTitleDescription.isHidden = true

            currTime = -1
            loadCaptions(time: 0)
        } else {
            if reelModel?.captionAPILoaded ?? false {
                viewBottomFooter.isHidden = false
                viewBottomTitleDescription.isHidden = false
            } else {
                viewBottomFooter.isHidden = true
                viewBottomTitleDescription.isHidden = true
            }
        }
    }

    func setupCell(model: Reel) {
        reelModel = model
        if let captionsLabel = captionsArr {
            for label in captionsLabel {
                label.removeFromSuperview()
            }
        }

        if let captionsView = captionsViewArr {
            for view in captionsView {
                view.removeFromSuperview()
            }
        }

        viewSubTitle.subviews.forEach { $0.removeFromSuperview() }
        captionsArr?.removeAll()
        captionsViewArr?.removeAll()

        imgChannel.image = nil
        viewTransparentBG.isHidden = true
        if let url = URL(string: model.media ?? "") {
            reelUrl = model.media ?? ""

            // Geasture for video like
            if SharedManager.shared.bulletsAutoPlay {
                player.play(for: url)
            }
            pause()
            player.pause()

            let asset = AVURLAsset(url: url)
            asset.loadValuesAsynchronously(forKeys: ["playable", "tracks", "duration"])
            DispatchQueue.main.async {}

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
            viewTransparentBG.addGestureRecognizer(tapPressRecognizer2)

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

        // update like status of video
        imgLike.image = nil
        if model.info?.isLiked ?? false {
            imgLike.image = UIImage(named: "newLikedIC")
        } else {
            imgLike.image = UIImage(named: "newLikeIC")
        }

        // Volumne status
        setVolumeStatus()

        currTime = -1
        currTime = -1
        cellLayoutUpdate()
    }

    func setVolumeStatus() {
        imgSound.image = nil
        if SharedManager.shared.isAudioEnableReels == false {
            player.volume = 0.0
            imgSound.image = UIImage(named: "newMuteIC")
        } else {
            player.volume = 1.0
            imgSound.image = UIImage(named: "newUnmuteIC")
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
                delegate?.didSwipeRight(cell: self)

            case .up:
                print("Swiped up")
            default:
                break
            }
        }
    }

    func setLikeComment(model: Info?, showAnimation: Bool) {
        reelModel?.info = model
        lblLikeCount.minimumScaleFactor = 0.5
        lblCommentCount.minimumScaleFactor = 0.5

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

    func setDescriptionLabel() {
        lblDescriptionAbove.text = (reelModel?.reelDescription ?? "").uppercased()
        lblDescriptionAbove.textColor = UIColor.white
        lblDescriptionAbove.font = UIFont(name: Constant.FONT_Gilroy_ExtraBold, size: 22 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 20 + adjustFontSizeForiPad())

        lblDescriptionGradient.backgroundColor = UIColor(patternImage: UIImage(named: "labelGradeintBackkground")!)
    }

    func setSeeMoreLabel() {
        viewUser.isHidden = false
        lblSeeMore.textColor = UIColor.white

        if newsDescription.length > 85 {
            lblSeeMore.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 15 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 15 + adjustFontSizeForiPad())
            lblDescriptionAbove.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 15 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 15 + adjustFontSizeForiPad())
        } else if newsDescription.length > 60 {
            lblSeeMore.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 17 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 17 + adjustFontSizeForiPad())
            lblDescriptionAbove.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 17 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 17 + adjustFontSizeForiPad())
        } else {
            lblSeeMore.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 18 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 18 + adjustFontSizeForiPad())
            lblDescriptionAbove.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 18 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 18 + adjustFontSizeForiPad())
        }

        lblSeeMore.customize { label in

            label.text = newsDescription
            label.numberOfLines = 5

            label.enabledTypes = [.hashtag]
            label.hashtagColor = UIColor.white

            label.handleHashtagTap { string in
                if string.contains("...") {
                    return
                }
                // action
                self.delegate?.didTapHashTag(cell: self, text: string)
            }
        }
        print("Reels text", newsDescription)
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

    @objc func doubleTapGestureAction(sender _: UILongPressGestureRecognizer) {
        if reelModel?.info?.isLiked == false {
            delegate?.didTapLike(cell: self)
        } else {
            startLikeAnimation()
        }
    }

    @objc func singleTapGestureGestureAction(sender _: UILongPressGestureRecognizer) {
        delegate?.didSingleTapDetected(cell: self)
    }

    @objc func tapGestureGestureAction(sender _: UILongPressGestureRecognizer) {}

    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        delegate?.didPangestureDetected(cell: self, panGesture: panGesture, view: viewSubTitle)
    }

    func startLikeAnimation() {
        tapPressRecognizer.isEnabled = false
        imgLikeAnimation.isHidden = false
        if #available(iOS 13.0, *) {
            generator = UIImpactFeedbackGenerator(style: .rigid)
        } else {
            generator = UIImpactFeedbackGenerator(style: .light)
        }
        generator.impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            let newScale = self.likedScale
            self.imgLikeAnimation.transform = self.transform.scaledBy(x: newScale, y: newScale)

            self.imgLike.transform = self.transform.scaledBy(x: newScale, y: newScale)

            self.imgLike.isHighlighted = true

        }, completion: { _ in

            UIView.animate(withDuration: 0.2) {
                self.imgLikeAnimation.transform = CGAffineTransform.identity
                self.imgLike.transform = CGAffineTransform.identity
                self.stopLikeAnimation()
            } completion: { _ in
                self.tapPressRecognizer.isEnabled = true
            }

        })
    }

    @IBAction func didTapPlayButton(_: Any) {
        delegate?.didTapPlayVideo(cell: self)
    }

    @IBAction func didTapRotate(_: Any) {
        delegate?.didTapRotateVideo(cell: self)
    }

    func stopLikeAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.imgLikeAnimation.isHidden = true
        }
    }

    func setImage() {
        if reelModel?.mediaMeta?.width ?? 0 > reelModel?.mediaMeta?.height ?? 0 {
            imgThumbnailView?.contentMode = .scaleAspectFit
            player.contentMode = .scaleAspectFit
        } else {
            let containerRatio = frame.size.height / frame.size.width
            let videoRatio = (reelModel?.mediaMeta?.height ?? 1) / (reelModel?.mediaMeta?.width ?? 1)

            if containerRatio >= CGFloat(videoRatio) {
                imgThumbnailView?.contentMode = .scaleAspectFit
            } else {
                imgThumbnailView?.contentMode = .scaleAspectFill
            }
        }

        imgThumbnailView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imgThumbnailView?.frame = viewContent.frame

        SharedManager.shared.loadImageFromCache(imageURL: reelModel?.image ?? "") { [weak self] image in
            if image == nil {
                self?.imgThumbnailView?.sd_setImage(with: URL(string: self?.reelModel?.image ?? ""), placeholderImage: nil)
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
            imgSound.image = UIImage(named: "newMuteIC")
        } else {
            player.volume = 1.0
            imgSound.image = UIImage(named: "newUnmuteIC")
        }

        if player.state != .playing {
            play()
        } else if (player.totalDuration) >= (player.currentDuration) {
            player.seek(to: .zero)
            play()
        }

        SharedManager.shared.performWSToUpdateArticleAnalytics(ArticleId: reelModel?.id ?? "", isFromReel: true)
    }

    func resumeVideoPlay(time: TimeInterval?) {
        viewPlayButton.isHidden = true
        isPlayWhenReady = true
        if SharedManager.shared.isAudioEnableReels == false {
            player.volume = 0.0
            imgSound.image = UIImage(named: "newMuteIC")
        } else {
            player.volume = 1.0
            imgSound.image = UIImage(named: "newUnmuteIC")
        }

        if let time = time {
            player.seek(to: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }

        play()

        removeAllCaptions()
    }

    func removeAllCaptions() {
        if let captionsLabel = captionsArr {
            for label in captionsLabel {
                label.removeFromSuperview()
            }
        }
        if let captionsView = captionsViewArr {
            for view in captionsView {
                view.removeFromSuperview()
            }
        }
        viewSubTitle.subviews.forEach { $0.removeFromSuperview() }
        captionsArr?.removeAll()
        captionsViewArr?.removeAll()

        currTime = -1.0
    }

    func stopVideo() {
        print("Stop Video called")
        removeAllCaptions()

        if SharedManager.shared.reelsAutoPlay == false {
            viewPlayButton.isHidden = false
        }
        isPlayWhenReady = false
        pause()

        viewTransparentBG.isHidden = true
        isFullText = false
        setSeeMoreLabel()

        currTime = -1
        cellLayoutUpdate()
    }

    func PauseVideo() {
        isPlayWhenReady = false
    }

    func showVolumeOnAnimation() {
        imgVolume.image = UIImage(named: "ReelsSoundOn")
        UIView.animate(withDuration: 0.5) {
            self.imgVolume.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.5) {
                    self.imgVolume.alpha = 0
                } completion: { _ in
                    self.imgVolume.alpha = 0
                }
            }
        }
    }

    func showVolumeOffAnimation() {
        imgVolume.image = UIImage(named: "ReelsSoundOff")
        UIView.animate(withDuration: 0.5) {
            self.imgVolume.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.5) {
                    self.imgVolume.alpha = 0
                } completion: { _ in
                    self.imgVolume.alpha = 0
                }
            }
        }
    }

    func showLoader() {
        isLoaderShowing = true

        imgVolumeAnimation.isHidden = true
        stackViewButtons.isHidden = true
        lblSeeMore.text = "                 "
        lblChannelName.text = "                    "
        lblAuthor.text = "                    "

        viewContent.backgroundColor = .black
    }

    func hideLoader() {
        isLoaderShowing = false

        stackViewButtons.isHidden = false

        // Check source if its not available then use author
        if let source = reelModel?.source {
            setFollowButton(hidden: source.favorite ?? false)
            lblChannelName.text = source.name?.capitalized ?? ""
            imgUser.sd_setImage(with: URL(string: source.icon ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" : "icn_profile_placeholder_light"))
        } else {
            setFollowButton(hidden: reelModel?.authors?.first?.favorite ?? false)
            lblChannelName.text = reelModel?.authors?.first?.username ?? reelModel?.authors?.first?.name ?? ""
            imgUser.sd_setImage(with: URL(string: reelModel?.authors?.first?.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" : "icn_profile_placeholder_light"))
        }

        let author = reelModel?.authors?.first?.username ?? reelModel?.authors?.first?.name ?? ""
        let source = reelModel?.source?.name ?? ""

        if author == source || author == "" {
            lblAuthor.isHidden = true
            lblChannelName.text = source
            cSeeAutherStacViewHeight.constant = 25
        } else {
            lblChannelName.text = source
            //            lblAuthor.text = author
            cSeeAutherStacViewHeight.constant = 25
            if source == "" {
                lblAuthor.isHidden = true
                lblChannelName.text = author
                cSeeAutherStacViewHeight.constant = 25
            }
        }

        newsDescription = reelModel?.reelDescription ?? ""
        isFullText = false
        setSeeMoreLabel()
        descriptionView.isHidden = true
        lblSeeMore.isHidden = true
        if let type = reelModel?.mediaMeta?.type {
            if type == "fastreel", let nativeTitle = reelModel?.nativeTitle {
                if nativeTitle == true {
                    lblSeeMore.isHidden = nativeTitle
                    authorBottomConstraint?.constant = -25
                    descriptionView.isHidden = !nativeTitle
                    lblDescriptionAbove.text = newsDescription.uppercased()
                }
            } else if type == "reel", let nativeTitle = reelModel?.nativeTitle {
                if nativeTitle == true {
                    lblSeeMore.isHidden = !nativeTitle
                    authorBottomConstraint?.constant = 0
                    descriptionView.isHidden = nativeTitle
                }
            } else {
                authorBottomConstraint?.constant = -25
                lblSeeMore.isHidden = true
                descriptionView.isHidden = true
            }
        } else {
            if let nativeTitle = reelModel?.nativeTitle {
                if nativeTitle {
                    lblSeeMore.isHidden = !nativeTitle
                    authorBottomConstraint?.constant = 0
                } else if !nativeTitle {
                    authorBottomConstraint?.constant = -25
                }
            }
        }

        let formater = NumberFormatter()
        formater.groupingSeparator = ","
        formater.locale = Locale.current
        formater.numberStyle = .decimal
        viewContent.backgroundColor = .black
    }

    @IBAction func didTapLikeButton(_: Any) {
        delegate?.didTapLike(cell: self)
    }

    @IBAction func didTapCommentButton(_: Any) {
        delegate?.didTapComment(cell: self)
    }

    @IBAction func didTapShareButton(_: Any) {
        delegate?.didTapShare(cell: self)
    }

    @IBAction func didTapOpenSource(_: Any) {
        delegate?.didTapOpenSource(cell: self)
    }

    @IBAction func didTapEditArticle(_: Any) {
        delegate?.didTapEditArticle(cell: self)
    }

    @IBAction func didTapAuthor(_: Any) {
        delegate?.didTapAuthor(cell: self)
    }

    @IBAction func didTapFollow(_ sender: UIButton) {
        delegate?.didTapFollow(cell: self, tagNo: sender.tag)
    }

    @IBAction func didTapVolumeButton(_: Any) {
        if SharedManager.shared.isAudioEnableReels == false {
            SharedManager.shared.isAudioEnableReels = true
            //            SharedManager.shared.isAudioEnable = true

            player.volume = 1.0
            imgSound.image = UIImage(named: "newUnmuteIC")
        } else {
            SharedManager.shared.isAudioEnableReels = false
            //            SharedManager.shared.isAudioEnable = false
            player.volume = 0.0
            imgSound.image = UIImage(named: "newMuteIC")
        }

        delegate?.videoVolumeStatusChanged(cell: self)
    }

    @IBAction func didTapViewMoreReels(_: Any) {
        delegate?.didTapViewMore(cell: self)
    }

    @IBAction func didTapViewMoreOptions(_: Any) {
        delegate?.didTapViewMoreOptions(cell: self)
    }
}

// MARK: UIGestureRecognizerDelegate

extension ReelsCC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf _: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            return false
        } else if gestureRecognizer is UILongPressGestureRecognizer {
            return false
        } else {
            return true
        }
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: PlayerDelegate

extension ReelsCC: PlayerDelegate {
    // MARK: VideoPlayerDelegate

    func playerDidUpdateState(player: Player, previousState _: PlayerState) {
        switch player.state {
        case .loading:

            break
        case .ready:
            if loader.isHidden == false {
                loader.isHidden = true
                loader.stopAnimating()
            }
            hideLoader()
            if isPlayWhenReady, player.playing == false {
                player.play()
            }

        case .failed:
            hideLoader()
            ANLoader.hide()
            print("video loading failed")
        }
    }

    func playerDidUpdatePlaying(player _: Player) {
        if isLoaderShowing {
            hideLoader()
        }
    }

    func loadCaptions(time: Double) {
        if let captions = reelModel?.captions, captions.count > 0 {
            if currTime != time {
                currTime = time
                updateSubTitlesWithTime(currTime: time, captions: captions)
            }
        }
    }

    // MARK: - Captions setup

    func playerDidUpdateTime(player: Player) {
        let time = (player.time)
        loadCaptions(time: time)

        if imgThumbnailView?.isHidden == false {
            imgThumbnailView?.isHidden = true
        }

        
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
            delegate?.videoPlayingFinished(cell: self)
        }
    }

    func playerDidUpdateBufferedTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
    }
}

public extension RegularPlayer {
    var automaticallyWaitsToMinimizeStalling: Bool {
        get {
            return player.automaticallyWaitsToMinimizeStalling
        }
        set {
            player.automaticallyWaitsToMinimizeStalling = newValue
        }
    }
}

// MARK: - CustomImageView

class CustomImageView: UIImageView {}

extension UIView {
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
