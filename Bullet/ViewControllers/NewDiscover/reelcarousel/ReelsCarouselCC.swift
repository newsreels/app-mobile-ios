//
//  ReelsCarouselCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 26/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import PlayerKit
import AVFoundation

protocol ReelsCarouselCCDelegate: AnyObject {
    
    func openDetailsVC(cell: ReelsCarouselCC)
    func openChannelDetailVC(cell: ReelsCarouselCC)
    func playVideo(cell: ReelsCarouselCC)
    
}


class ReelsCarouselCC: UICollectionViewCell {

    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgPlayButton: UIImageView!
    
    @IBOutlet weak var imgChannel: UIImageView!
    @IBOutlet weak var lblChannel: UILabel!
    @IBOutlet weak var btnVolume: UIButton!
    
    var videoPlayer = RegularPlayer()
    var isPlayWhenReady =  false
    weak var delegate: ReelsCarouselCCDelegate?
    var langCode = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        
        imgChannel.cornerRadius = imgChannel.frame.size.height / 2
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgChannel.cornerRadius = imgChannel.frame.size.height / 2
        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: self.langCode) {
                self.lblChannel.semanticContentAttribute = .forceRightToLeft
                self.lblChannel.textAlignment = .right
            } else {
                self.lblChannel.semanticContentAttribute = .forceLeftToRight
                self.lblChannel.textAlignment = .left
            }
        }
        
    }
    
    
    func setUpCell(reel: Reel?) {
        
        imgThumbnail.sd_setImage(with: URL(string: reel?.image ?? "") , placeholderImage: UIImage(named: "icn_placeholder_dark"))
//UIImage(named: "img_news_test")
        
        if let source = reel?.source {
            imgChannel.sd_setImage(with: URL(string: source.icon ?? "") , placeholderImage: nil)
            lblChannel.text = source.name
        }
        else {
            imgChannel.sd_setImage(with: URL(string: reel?.authors?.first?.image ?? "") , placeholderImage: nil)
            lblChannel.text = reel?.authors?.first?.name
        }

        
        if let url = URL(string: reel?.media ?? "") {
            
            self.videoPlayer.pause()
            self.videoPlayer.seek(to: 0)
            self.videoPlayer.delegate = self
            self.addPlayerToView()
            self.videoPlayer.set(AVURLAsset(url: url))
        }
        
         
        setVolumeUI()
        
    }

    
    func transformToLarge() {
        
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
    }
    
    func transformToNormal() {
        
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            
        }
    }
    
    
    private func addPlayerToView() {
        
        self.videoPlayer.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.videoPlayer.view.frame = self.viewVideo.bounds
        self.videoPlayer.fillMode = .fill
        self.viewVideo.insertSubview(self.videoPlayer.view, at: 0)
    }
    
    func hideVideoControls() {
        
        btnVolume.isHidden = false
        imgThumbnail.isHidden = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        imgPlayButton.isHidden = true
        
    }
    
    
    
    
    func playVideo() {
        
        btnVolume.isHidden = false
        setVolumeUI()
        imgPlayButton.isHidden = true
        self.videoPlayer.seek(to: 0)
        videoPlayer.play()
        isPlayWhenReady = true
    }
    
    
    func stopVideo() {
        
        btnVolume.isHidden = true
        imgPlayButton.isHidden = false
        videoPlayer.seek(to: .zero)
        videoPlayer.pause()
        isPlayWhenReady = false
        
    }
    
    
    @IBAction func didTapPlayVideo(_ sender: Any) {
        
        if videoPlayer.playing {
            
            self.stopVideo()
            self.delegate?.openDetailsVC(cell: self)
        } else {
            
//            playVideo()
            
            self.delegate?.playVideo(cell: self)
        }
        
    }
    
    
    @IBAction func didTapChannel(_ sender: Any) {
        
        if videoPlayer.playing {
            
            self.stopVideo()
            self.delegate?.openChannelDetailVC(cell: self)
        } else {
            
            playVideo()
        }
    }
    
    
    @IBAction func didTapVolume(_ sender: Any) {
        
        
        if SharedManager.shared.isAudioEnableReels {
            SharedManager.shared.isAudioEnableReels = false
        }
        else {
            SharedManager.shared.isAudioEnableReels = true
        }
        
        setVolumeUI()
    }
    
    
    
    func setVolumeUI() {
        
        if SharedManager.shared.isAudioEnableReels {
            
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
            videoPlayer.volume = 1
        }
        else {
            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
            videoPlayer.volume = 0
            
        }
        
        
    }
    
    
    
    
    
}



extension ReelsCarouselCC: PlayerDelegate {
    
    // MARK: VideoPlayerDelegate
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        self.activityIndicator.isHidden = true
        
        switch player.state {
        case .loading:
            if player.time > 0 {
                self.activityIndicator.startAnimating()
            }
            //self.imgPlaceHolder.isHidden = false

        case .ready:
            if isPlayWhenReady {
                player.play()
            }
            break
            
        case .failed:
            
            NSLog("🚫 \(String(describing: player.error))")
        }
    }
    
    func playerDidUpdatePlaying(player: Player) {
        
        if player.playing {
            
        }
    }
    
    func playerDidUpdateTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
        
        activityIndicator.stopAnimating()
        
        if player.time > 0 {
            if self.imgThumbnail.isHidden == false {
                self.imgThumbnail.isHidden = true
            }
        } else {
            if self.imgThumbnail.isHidden {
                self.imgThumbnail.isHidden = false
            }
        }
        
//        let ratio = player.time / player.duration
        
        
        if player.duration <= player.time {
    
//            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.videoFinishedPlaying, eventDescription: "", article_id: currentArticleID)
            self.videoPlayer.seek(to: .zero)
            self.videoPlayer.play()
        //    self.videoControllerStatus(isHidden: false)
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

