//
//  SingleArticleCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 30/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation
import PlayerKit

protocol SingleArticleCCDelegate: AnyObject {
    func openDetailsVC(cell: SingleArticleCC)
    func didTapPlayVideo(cell: SingleArticleCC)
}

class SingleArticleCC: UICollectionViewCell {

    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var videoPlayButton: UIView!
    @IBOutlet weak var lblSourceName: UILabel!
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNews: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewNews: UIView!
    @IBOutlet var youtubePlayer: YouTubePlayerView!
    
    var selectedModel: DiscoverData?
    var videoPlayer = RegularPlayer()
    var isPlayWhenReady =  false
    
    weak var delegate: SingleArticleCCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        activityIndicator.isHidden = true
    }

    
    override func prepareForReuse() {
        
        activityIndicator.isHidden = true
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL() {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
            } else {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
            }
        }
        
    }
    
    
    func setUpCell(model: DiscoverData?) {
        
        selectedModel = model
        
        lblTitle.textColor = .black
        lblTitle.text = model?.title ?? ""
        
        if model?.data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO || model?.data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            videoPlayButton.isHidden = false
            
            // video article
            if model?.data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                youtubePlayer.isHidden = true
                viewVideo.isHidden = false
                if let url = URL(string: model?.data?.article?.link ?? "") {
                    
                    self.videoPlayer.pause()
                    self.videoPlayer.seek(to: 0)
                    self.videoPlayer.delegate = self
                    self.addPlayerToView()
                    self.videoPlayer.set(AVURLAsset(url: url))
                }
            }
            else {
                
                // youtube
                youtubePlayer.isHidden = false
                viewVideo.isHidden = true
                
            }
            
            
        } else {
            
            // image Article
            videoPlayButton.isHidden = true
        }
        
        
        
        imgThumbnail.sd_setImage(with: URL(string: model?.data?.article?.image ?? "") , placeholderImage: UIImage(named: "icn_placeholder_dark"))
        
        lblSourceName.text = ""
        if model?.data?.article?.source == nil {
            
            lblSourceName.text = model?.data?.article?.authors?.first?.name ?? ""
            imgSource.sd_setImage(with: URL(string: model?.data?.article?.authors?.first?.image ?? "") , placeholderImage: nil)
        } else {
            lblSourceName.text = model?.data?.article?.source?.name ?? ""
            imgSource.sd_setImage(with: URL(string: model?.data?.article?.source?.icon ?? "") , placeholderImage: nil)
        }
        
        lblNews.text = model?.data?.article?.title ?? ""
        lblTime.text = ""
        if let pubDate = model?.data?.article?.publish_time {
            lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
        }
        
    }
    
    // MARK; - Video Methods
    private func addPlayerToView() {
        
        self.videoPlayer.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.videoPlayer.view.frame = self.viewVideo.bounds
        self.videoPlayer.fillMode = .fill
        self.viewVideo.insertSubview(self.videoPlayer.view, at: 0)
    }
    
    func loadVideo() {
        
        youtubePlayer.playerVars = [
            "playsinline": "1",
            "controls": "0",
            "mute": SharedManager.shared.isAudioEnable ? "0" : "1"
        ] as YouTubePlayerView.YouTubePlayerParameters
        
        
        youtubePlayer.delegate = self
        youtubePlayer.loadVideoID(selectedModel?.data?.article?.link ?? "")
        
    }
    
    
    func hideVideoControls() {
        
        if selectedModel?.data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
            imgThumbnail.isHidden = true
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            videoPlayButton.isHidden = true
        } else if selectedModel?.data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            imgThumbnail.isHidden = true
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            videoPlayButton.isHidden = true
        }
        
    }
    
    func playVideo() {
        
        if selectedModel?.data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
            viewNews.isHidden = true
            videoPlayButton.isHidden = true
            self.videoPlayer.seek(to: 0)
            self.videoPlayer.delegate = self
            
            videoPlayer.play()
            isPlayWhenReady = true
            
            if videoPlayer.playing == false {
                activityIndicator.startAnimating()
                activityIndicator.isHidden = false
            }
        } else if selectedModel?.data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            
            loadVideo()
            viewNews.isHidden = true
            videoPlayButton.isHidden = true
            youtubePlayer.delegate = self
            youtubePlayer.play()
            isPlayWhenReady = true
            
            if youtubePlayer.playerState != .Playing {
                activityIndicator.startAnimating()
                activityIndicator.isHidden = false
            }
        }
        
    }
    
    
    func stopVideo() {
        
        if selectedModel?.data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
            
            imgThumbnail.isHidden = false
            viewNews.isHidden = false
            videoPlayButton.isHidden = false
            videoPlayer.seek(to: .zero)
            videoPlayer.pause()
            isPlayWhenReady = false
        } else if selectedModel?.data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            
            imgThumbnail.isHidden = false
            viewNews.isHidden = false
            videoPlayButton.isHidden = false
            
            youtubePlayer.pause()
            isPlayWhenReady = false
        }
        
        
    }
    
    
    @IBAction func didTapPlayVideo(_ sender: Any) {
        
        if selectedModel?.data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
            
            if videoPlayButton.isHidden {
                self.stopVideo()
                self.delegate?.openDetailsVC(cell: self)
            } else {
                playVideo()
                
                self.delegate?.didTapPlayVideo(cell: self)
            }
            
        }
        else if selectedModel?.data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO || selectedModel?.data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            
            if videoPlayButton.isHidden {
                self.stopVideo()
                self.delegate?.openDetailsVC(cell: self)
            } else {
                playVideo()
                
                self.delegate?.didTapPlayVideo(cell: self)
            }
            
        }
        else {
            self.delegate?.openDetailsVC(cell: self)
        }
    }
    
    
   
    
    
    
}


extension SingleArticleCC: PlayerDelegate {
    
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
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
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



extension SingleArticleCC: YouTubePlayerDelegate {
    
    
    func playerUpdateCurrentTime(_ videoPlayer: YouTubePlayerView, time: String) {
        
        if SharedManager.shared.isAudioEnable && videoPlayer.isMuted {
            SharedManager.shared.isAudioEnable = false
        }
        if SharedManager.shared.isAudioEnable == false && videoPlayer.isMuted == false {
            SharedManager.shared.isAudioEnable = true
        }
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
        if self.isPlayWhenReady {
            videoPlayer.play()
        }
    }
    
    //    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
    //        return MyThemes.current == .dark ? .black : .white
    //    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        
        if playerState == .Paused {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
           
            //self.imgPlay.isHidden = false
            videoPlayer.getCurrentTime { time in
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoDurationEvent, eventDescription: "", article_id: self.selectedModel?.data?.article?.id ?? "", duration: time?.formatToMilliSeconds() ?? "")
            }
            
        }
        else if playerState == .Ended {
            //self.imgPlay.isHidden = false
//            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.videoFinishedPlaying, eventDescription: "", article_id: articleID)
            
            videoPlayer.getCurrentTime { time in
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoDurationEvent, eventDescription: "", article_id: self.selectedModel?.data?.article?.id ?? "", duration: time?.formatToMilliSeconds() ?? "")
            }
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoFinishedPlaying, eventDescription: "", article_id: selectedModel?.data?.article?.id ?? "")
            
        }
        else if playerState == .Playing {
            imgThumbnail.isHidden = true
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            
            videoPlayer.getCurrentTime(completion: { time in
                
                if time == 0 {
                    if SharedManager.shared.isAudioEnable {
                        videoPlayer.unMute()
                    } else {
                        videoPlayer.mute()
                    }
                }
                
            })
            
        }
        else if playerState == .Unstarted {
            imgThumbnail.isHidden = true
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
