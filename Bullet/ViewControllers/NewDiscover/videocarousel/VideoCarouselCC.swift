//
//  VideoCarouselCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 30/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import PlayerKit
import AVFoundation


protocol VideoCarouselCCDelegate: AnyObject {
    
    func openDetailsVC(cell: VideoCarouselCC)
    func playVideo(cell: VideoCarouselCC)
}


class VideoCarouselCC: UICollectionViewCell {

    @IBOutlet weak var lblNews: UILabel!
    @IBOutlet weak var imgThumbnail: UIImageView!
    
    //source
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewDot: UIView!
    @IBOutlet weak var lblAuthor: UILabel!
    
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgPlayButton: UIImageView!
    
    @IBOutlet weak var btnVolume: UIButton!
    
    
    
    var videoPlayer = RegularPlayer()
    var isPlayWhenReady =  false
    weak var delegate: VideoCarouselCCDelegate?
    var langCode = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblSource.textColor = .black
        lblTime.textColor = .black//"#84838B".hexStringToUIColor()
        lblAuthor.textColor = .black//"#84838B".hexStringToUIColor()
        
        lblNews.textColor = .black
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: langCode) {
            
            DispatchQueue.main.async {
                self.lblNews.semanticContentAttribute = .forceRightToLeft
                self.lblNews.textAlignment = .right
                
                self.lblSource.semanticContentAttribute = .forceRightToLeft
                self.lblSource.textAlignment = .right
                
                self.lblTime.semanticContentAttribute = .forceRightToLeft
                self.lblTime.textAlignment = .right
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.lblNews.semanticContentAttribute = .forceLeftToRight
                self.lblNews.textAlignment = .left
                
                self.lblSource.semanticContentAttribute = .forceLeftToRight
                self.lblSource.textAlignment = .left
                
                self.lblTime.semanticContentAttribute = .forceLeftToRight
                self.lblTime.textAlignment = .left
            }
        }
        
    }
    
    
    func setupCell(model: articlesData) {
        
        self.langCode = model.language ?? ""
        lblNews.text = model.title
        imgThumbnail.sd_setImage(with: URL(string: model.image ?? "") , placeholderImage: nil)

//        viewFooter.isHidden = false
        
        
//        if model.source == nil {
//            lblSource.text = model.source?.name ?? ""
//            imgSource.sd_setImage(with: URL(string: model.authors?.first?.image ?? "") , placeholderImage: nil)
//        } else {
//            lblSource.text = model.source?.name ?? ""
//            imgSource.sd_setImage(with: URL(string: model.source?.icon ?? "") , placeholderImage: nil)
//        }
        
        //Check source and author
        if let source = model.source {
            
            let sourceURL = source.icon ?? ""
            imgSource?.sd_setImage(with: URL(string: sourceURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            lblSource.text = source.name ?? ""
        }
        else {
            
            let url = model.authors?.first?.image ?? ""
            imgSource?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
            lblSource.text = model.authors?.first?.username ?? model.authors?.first?.name ?? ""
        }
        
//            videoPlayer.lblAuthor.text = content.authors?.first?.name?.capitalized
        let author = model.authors?.first?.username ?? model.authors?.first?.name ?? ""
        let source = model.source?.name ?? ""
        
        viewDot.clipsToBounds = false
        if author == source || author == "" {
            lblAuthor.isHidden = true
            viewDot.isHidden = true
            viewDot.clipsToBounds = true
            lblSource.text = source
        }
        else {
            
            lblSource.text = source
            lblAuthor.text = author
            
            if source == "" {
                lblAuthor.isHidden = true
                viewDot.isHidden = true
                viewDot.clipsToBounds = true
                lblSource.text = author
            }
            else if author != "" {
                lblAuthor.isHidden = false
                viewDot.isHidden = false
            }
        }

        let pubDate = model.publish_time ?? ""
        lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
        
        if let url = URL(string: model.link ?? "") {
            
            self.videoPlayer.pause()
            self.videoPlayer.seek(to: 0)
            self.videoPlayer.delegate = self
            self.addPlayerToView()
            self.videoPlayer.set(AVURLAsset(url: url))
        }
        
        
        setVolumeUI()
        
    }
    
    
    
    private func addPlayerToView() {
        
        self.videoPlayer.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.videoPlayer.view.frame = self.viewVideo.bounds
        self.videoPlayer.fillMode = .fit
        self.viewVideo.insertSubview(self.videoPlayer.view, at: 0)
    }
    
    func hideVideoControls() {
        
        imgThumbnail.isHidden = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        imgPlayButton.isHidden = true
        
        btnVolume.isHidden = false
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
        
        setVolumeUI()
        if videoPlayer.playing {
            
            self.stopVideo()
            self.delegate?.openDetailsVC(cell: self)
        } else {
            
//            playVideo()
            self.delegate?.playVideo(cell: self)
        }
        
    }
    
    @IBAction func didTapVolumeButton(_ sender: Any) {
        
        
        if SharedManager.shared.isAudioEnable {
            SharedManager.shared.isAudioEnable = false
        }
        else {
            SharedManager.shared.isAudioEnable = true
        }
        
        setVolumeUI()
    }
    
    
    func setVolumeUI() {
        
        if SharedManager.shared.isAudioEnable {
            
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
            videoPlayer.volume = 1
        }
        else {
            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
            videoPlayer.volume = 0
            
        }
        
        
    }
    
    
    
}


extension VideoCarouselCC: PlayerDelegate {
    
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

