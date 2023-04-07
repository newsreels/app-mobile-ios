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
    @IBOutlet var imgPlayButton: UIImageView!
    @IBOutlet var imgLikeAnimation: UIImageView!
    @IBOutlet var viewPlayButton: UIView!
    @IBOutlet var viewUser: UIView!
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var btnUserPlus: UIButton!
    @IBOutlet weak var followStack: UIStackView!
    @IBOutlet weak var btnUserPlusWidth: NSLayoutConstraint!
    @IBOutlet var viewSubTitle: UIView!
    @IBOutlet var cSeeAutherStacViewHeight: NSLayoutConstraint!
    @IBOutlet var imgThumbnailView: CustomImageView!
    @IBOutlet var viewBottomFooter: UIView!
    @IBOutlet var viewBottomTitleDescription: UIView!
    @IBOutlet var constraintImgLikeHeight: NSLayoutConstraint!
    @IBOutlet var constraintImgCommentHeight: NSLayoutConstraint!
    @IBOutlet var viewMoreReels: UIView!
    @IBOutlet var viewMoreOptions: UIView!
    @IBOutlet var imageMoreOptions: UIImageView!
    @IBOutlet var viewSound: UIView!
    @IBOutlet var imgSound: UIImageView!
    @IBOutlet var authorBottomConstraint: NSLayoutConstraint!
    
    var currTime = -1.0
    var defaultLeftInset: CGFloat = 20.0
    var captionsArr: [UILabel]?
    var captionsViewArr: [UIView]?
    let likedScale: CGFloat = 1.3
    var generator = UIImpactFeedbackGenerator()
    var tapPressRecognizer = UITapGestureRecognizer()
    var isFullText = false
    var newsDescription = ""
    var reelUrl = ""
    var imageView: UIImageView?
    var isPlayWhenReady = false
    var reelModel: Reel?
    var isLoaderShowing = false
    weak var delegate: ReelsCCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        loader.isHidden = true
        loader.stopAnimating()
        pause()
        player.seek(to: .zero)
        for recognizer in viewSubTitle.gestureRecognizers ?? [] {
            viewSubTitle.removeGestureRecognizer(recognizer)
        }
        lblSeeMore.text = "                 "
        lblChannelName.text = "                    "
        lblAuthor.text = "                    "
        btnUserPlus.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
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

    override func draw(_: CGRect) {}

    @IBAction func didTapPlayButton(_: Any) {
        delegate?.didTapPlayVideo(cell: self)
    }

    @IBAction func didTapRotate(_: Any) {
        delegate?.didTapRotateVideo(cell: self)
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


extension ReelsCC {
    
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
}
