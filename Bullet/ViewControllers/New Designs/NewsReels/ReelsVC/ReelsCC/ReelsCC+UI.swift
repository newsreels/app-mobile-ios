//
//  ReelsCC+UI.swift
//  Bullet
//
//  Created by Osman Ahmed on 05/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation
class CustomSlider: UISlider {
    @IBInspectable var trackHeight: CGFloat = 3
    
    // Custom thumb view which will be converted to UIImage
    // and set as thumb. You can customize it's colors, border, etc.
    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = .white//thumbTintColor
        thumb.layer.borderWidth = 0.4
        thumb.layer.borderColor = UIColor.darkGray.cgColor
        return thumb
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateState()

    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
           let expandedBounds = bounds.insetBy(dx: -20, dy: -30)
           return expandedBounds.contains(point)
       }
    private func thumbImage(radius: CGFloat, color: UIColor) -> UIImage {
        // Set proper frame
        // y: radius / 2 will correctly offset the thumb
        
        thumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        thumbView.layer.cornerRadius = radius / 2
        thumbView.backgroundColor = color
        // Convert thumbView to UIImage
        // See this: https://stackoverflow.com/a/41288197/7235585
        
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        // Set custom track height
        // As seen here: https://stackoverflow.com/a/49428606/7235585
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }
    
    func updateState() {
        if isHighlighted {
            self.maximumTrackTintColor = .white.withAlphaComponent(0.4)
            self.minimumTrackTintColor = .white.withAlphaComponent(0.9)
            trackHeight = 5
            layoutSubviews()
            let thumb = thumbImage(radius: 15, color: .white.withAlphaComponent(0.9))
            setThumbImage(thumb, for: .normal)
            setThumbImage(thumb, for: .highlighted)
        } else {
            self.maximumTrackTintColor = .white.withAlphaComponent(0.2)
            self.minimumTrackTintColor = .white.withAlphaComponent(0.8)
            trackHeight = 3
            layoutSubviews()
            let thumb = thumbImage(radius: 6, color: .white.withAlphaComponent(0.8))
            setThumbImage(thumb, for: .normal)
            setThumbImage(thumb, for: .highlighted)
        }
    }
}
extension ReelsCC {
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func setupViews() {
        lblSeeMore.text = "                 "
        lblChannelName.text = "                    "
        lblAuthor.text = "                    "
        setupUIForSkelton()
        viewContent.backgroundColor = .black
        imgVolume.image = nil
        lblChannelName.font = UIFont(name: Constant.FONT_ROBOTO_BOLD, size: 17) ?? UIFont.boldSystemFont(ofSize: 17 + adjustFontSizeForiPad())
        lblChannelName.adjustsFontSizeToFitWidth = true
        lblChannelName.minimumScaleFactor = 0.8
        lblAuthor.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 16 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 16 + adjustFontSizeForiPad())
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAuthor))
        lblChannelName.addGestureRecognizer(tapGestureRecognizer)
        lblChannelName.isUserInteractionEnabled = true
        viewBottomFooter.isHidden = false
        btnUserPlus.layer.cornerRadius = 8
        btnUserPlus.borderWidth = 1
        btnUserPlus.borderColor = .white.withAlphaComponent(0.5)
        btnUserPlus.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        btnUserPlus.layer.masksToBounds = true
        btnUserPlus.titleLabel?.adjustsFontSizeToFitWidth = true
        seekBarDurationView.isHidden = true
//        self.seekBar.thumbTintColor = .clear
//        if let thumbImage = UIImage(named: "seekBarThumb") {
//            let thumbSize = CGSize(width: 5, height: 5)
//            let resizedThumbImage = thumbImage.resized(to: thumbSize)
//            self.seekBar.setThumbImage(resizedThumbImage, for: .normal)
//            self.seekBar.setThumbImage(resizedThumbImage, for: .highlighted)
//
//        }
        stackViewButtons.isHidden = false
        lblAuthor.isHidden = true
        cSeeAutherStacViewHeight.constant = 25
        isFullText = false
        setSeeMoreLabel()
        descriptionView.isHidden = true
        lblSeeMore.isHidden = true
        viewBottomTitleDescription.isHidden = false
        authorBottomConstraint?.constant = 0
        descriptionView.isHidden = true

    }

    func setupCell(model: Reel) {
        loadingStartingTime = nil
        pause()
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
        viewTransparentBG.isHidden = true
        if let url = URL(string: model.media ?? "") {
            reelUrl = model.media ?? ""
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
        
        let expandTextTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandTextTapGestureGestureAction(sender:)))
         expandTextTapRecognizer.numberOfTapsRequired = 1
         expandTextTapRecognizer.delegate = self
         lblSeeMore.addGestureRecognizer(expandTextTapRecognizer)
    }
    
    func setImage() {
        if imgThumbnailView.image == nil {
            imgThumbnailView.contentMode = .scaleAspectFill
            imgThumbnailView.frame = playerLayer.bounds
            imgThumbnailView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imgThumbnailView.frame = playerLayer.frame
            imgThumbnailView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imgThumbnailView.frame = viewContent.frame
            SharedManager.shared.loadImageFromCache(imageURL: reelModel?.image ?? "") { [weak self] image in
                if image == nil {
                    self?.imgThumbnailView?.sd_setImage(with: URL(string: self?.reelModel?.image ?? "") , placeholderImage: nil)
                } else {
                    self?.imgThumbnailView?.image = image
                }
            }
        }
        imgThumbnailView.layoutIfNeeded()
    }
    
    func setFollowButton(hidden: Bool) {
        //todo: change follow text

    }

    func setLikeComment(model: Info?, showAnimation: Bool) {
        reelModel?.info = model
        lblLikeCount.minimumScaleFactor = 0.5
        lblCommentCount.minimumScaleFactor = 0.5
        self.lblLikeCount.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 15)
        self.lblLikeCount.textColor = .white
        if let likesCount = model?.likeCount, likesCount > 0 {
            self.lblLikeCount.text = String(likesCount)
        } else {
            self.lblLikeCount.text = ""
        }
        
        if let commentCount = model?.commentCount, commentCount > 0 {
            self.lblCommentCount.text = String(commentCount)
        } else {
            self.lblCommentCount.text = ""
        }
        if (reelModel?.info?.isLiked ?? false) == false {
            imgLike.image = UIImage(named: "newLikeIC")
        } else {
            if showAnimation {
                startLikeAnimation()
            } else {
                imgLike.image = UIImage(named: "newLikedIC")
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

        if newsDescription.length > 85 { 
            lblDescriptionAbove.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 15 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 15 + adjustFontSizeForiPad())
        } else if newsDescription.length > 60 {
            lblDescriptionAbove.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 17 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 17 + adjustFontSizeForiPad())
        } else {
            
            lblDescriptionAbove.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 18 + adjustFontSizeForiPad()) ?? UIFont.boldSystemFont(ofSize: 18 + adjustFontSizeForiPad())
        }
        lblSeeMore.font = UIFont(name: Constant.LibreFranklin_Medium, size: 15) ?? UIFont.boldSystemFont(ofSize: 15 + adjustFontSizeForiPad())
        lblSeeMore.textColor =  UIColor(displayP3Red: 173, green: 173, blue: 173, alpha: 1)
        lblSeeMore.customize { label in

            label.text = newsDescription
            label.numberOfLines = lblSeeMoreNumberOfLines

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
    }
    
    func setupUIForSkelton() {
        imgUser.cornerRadius = imgUser.frame.size.width / 2
        imgUser.borderWidth = 1.0
        imgUser.borderColor = UIColor(hexString: "F73458")
    }

}

extension ReelsCC {
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

        imgVolumeAnimation.isHidden = true
        stackViewButtons.isHidden = true
        lblSeeMore.text = "                 "
        lblChannelName.text = "                    "
        lblAuthor.text = "                    "

        viewContent.backgroundColor = .black
    }

    func hideLoader() {

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
        viewBottomTitleDescription.isHidden = true
        if let type = reelModel?.mediaMeta?.type {
            if type == "fastreel", let nativeTitle = reelModel?.nativeTitle {
                if nativeTitle == true {
                    lblSeeMore.isHidden = nativeTitle
                    viewBottomTitleDescription.isHidden = nativeTitle
                    authorBottomConstraint?.constant = -25
                    descriptionView.isHidden = !nativeTitle
                    lblDescriptionAbove.text = newsDescription.uppercased()
                }
            } else if type == "reel", let nativeTitle = reelModel?.nativeTitle {
                if nativeTitle == true {
                    lblSeeMore.isHidden = !nativeTitle
                    viewBottomTitleDescription.isHidden = !nativeTitle
                    authorBottomConstraint?.constant = 0
                    descriptionView.isHidden = nativeTitle
                }
            } else {
                authorBottomConstraint?.constant = -25
                lblSeeMore.isHidden = true
                viewBottomTitleDescription.isHidden = true
                descriptionView.isHidden = true
            }
        } else if let nativeTitle = reelModel?.nativeTitle {
                if nativeTitle {
                    lblSeeMore.isHidden = !nativeTitle
                    viewBottomTitleDescription.isHidden = !nativeTitle
                    authorBottomConstraint?.constant = 0
                } else if !nativeTitle {
                    authorBottomConstraint?.constant = -25
                }
        } else if !newsDescription.isEmpty {
            lblSeeMore.isHidden = false
            viewBottomTitleDescription.isHidden = false
            authorBottomConstraint?.constant = 0
            descriptionView.isHidden = true
        }

        let formater = NumberFormatter()
        formater.groupingSeparator = ","
        formater.locale = Locale.current
        formater.numberStyle = .decimal
        viewContent.backgroundColor = .black
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

            self.imgLike.image = UIImage(named: "newLikedIC")

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
    
    func stopLikeAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.imgLikeAnimation.isHidden = true
        }
    }
    
    func setVolumeStatus() {
        imgSound.image = nil
        if SharedManager.shared.isAudioEnableReels == false {
            playerLayer.player?.volume = 0.0
            imgSound.image = UIImage(named: "newMuteIC")
        } else {
            playerLayer.player?.volume = 1.0
            imgSound.image = UIImage(named: "newUnmuteIC")
        }
    }


}
