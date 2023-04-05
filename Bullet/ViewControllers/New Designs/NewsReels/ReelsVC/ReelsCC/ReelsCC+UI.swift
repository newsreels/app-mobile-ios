//
//  ReelsCC+UI.swift
//  Bullet
//
//  Created by Osman Ahmed on 05/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation

extension ReelsCC {
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
    
    func stopLikeAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.imgLikeAnimation.isHidden = true
        }
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


}
