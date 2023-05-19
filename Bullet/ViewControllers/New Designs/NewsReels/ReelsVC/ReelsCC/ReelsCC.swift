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
    func stopPrevious(cell: ReelsCC)
    func didTapCaptions(cell: ReelsCC)
    func didTapOpenCaptionType(cell: ReelsCC, action: String)
}

// MARK: - ReelsCC

class ReelsCC: UICollectionViewCell {
    @IBOutlet weak var playerContainer: UIView!
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
    @IBOutlet weak var seekBar: UISlider!
    
    var playerLayer = AVPlayerLayer() {
        didSet {
            (playerLayer.player as? NRPlayer)?.bufferStuckHandler = self.bufferStuckHandler
            (playerLayer.player as? NRPlayer)?.stallingHandler = self.stallingHandler
            (playerLayer.player as? NRPlayer)?.reelId = reelModel?.id
        }
    }
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
    weak var delegate: ReelsCCDelegate?
    var isPlaying = false
    var loadingStartingTime: Date?
    var totalDuration: Double?
    var lblSeeMoreNumberOfLines = 2
    var isPlayerEnded = false
    let seekBarInterval = CMTime(value: 1, timescale: 2)
    var isSeeked = false
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        setDescriptionLabel()

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let id = self.reelModel?.id, SharedManager.shared.playingPlayers.count > 0, SharedManager.shared.playingPlayers.contains(id) {
            SharedManager.shared.playingPlayers.remove(object: id)
        }
        seekBar.value = 0
        lblSeeMoreNumberOfLines = 2
        pause()
        imgThumbnailView.image = nil
        imgThumbnailView.isHidden = false
        totalDuration = playerLayer.player?.totalDuration
        playerLayer.player?.seek(to: .zero)
        playerLayer.player?.replaceCurrentItem(with: nil)
        for recognizer in viewSubTitle.gestureRecognizers ?? [] {
            viewSubTitle.removeGestureRecognizer(recognizer)
        }
        lblSeeMore.text = "                 "
        lblChannelName.text = "                    "
        lblAuthor.text = "                    "
        
    }

    
    
    @objc func videoDidEnded() {
        //do something here
        if !isPlayerEnded {
            isPlayerEnded = true
            self.stopVideo()
            self.pause()
            ReelsCacheManager.shared.clearCache()
            self.delegate?.videoPlayingFinished(cell: self)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setDescriptionLabel()
        hideLoader()
        imgThumbnailView?.layoutIfNeeded()
    }

    override func draw(_: CGRect) {}

    @IBAction func seekBarValueChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else {
            return
        }
        let totalTime = self.playerLayer.player?.totalDuration ?? 0
        let seekTime = CMTime(seconds: Double(slider.value) * totalTime, preferredTimescale: 1)
           
        self.playerLayer.player?.seek(to: seekTime)
        isSeeked = true
    }
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

            playerLayer.player?.volume = 1.0
            imgSound.image = UIImage(named: "newUnmuteIC")
        } else {
            SharedManager.shared.isAudioEnableReels = false
            //            SharedManager.shared.isAudioEnable = false
            playerLayer.player?.volume = 0.0
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
    
    @objc func expandTextTapGestureGestureAction(sender: UILongPressGestureRecognizer) {
        lblSeeMoreNumberOfLines = lblSeeMore.numberOfLines == 2 ? 5 : 2
        setSeeMoreLabel()
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .left:
                delegate?.didSwipeRight(cell: self)

            case .up:
                break
            default:
                break
            }
        }
    }

    @objc func longPressGestureAction(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            PauseVideo()
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            if !(playerLayer.player?.isPlaying ?? false) {
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
