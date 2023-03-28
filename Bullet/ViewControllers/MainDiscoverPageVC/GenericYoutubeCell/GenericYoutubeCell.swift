//
//  GenericYoutubeCell.swift
//  Bullet
//
//  Created by Faris Muhammed on 14/07/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol GenericYoutubeCellDelegate: class {
    
    func didTapYoutubePlayButton(cell: GenericYoutubeCell)
}

class GenericYoutubeCell: UITableViewCell {
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var viewGestures: UIView!
    
    @IBOutlet weak var viewPlaceholder: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    //@IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet var videoPlayer: YouTubePlayerView!
    var isPlayWhenReady = false
    var modelDiscover: Discover?
    weak var delegate: GenericYoutubeCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblTitle.theme_textColor = GlobalPicker.textSubColorDiscover
        self.lblSubTitle.theme_textColor = GlobalPicker.textBWColorDiscover
        self.viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        self.theme_backgroundColor = GlobalPicker.backgroundDiscoverMainColor
        
        self.viewPlaceholder.isHidden = false
        self.activityLoader.stopAnimating()
        
        self.videoPlayer.backgroundColor = .clear
        
        self.viewBG.addBottomShadowForDiscoverPage()
        
    }
    
    override func prepareForReuse() {
        
        resetYoutubeCard()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func loadVideo() {
        
        videoPlayer.playerVars = [
            "playsinline": "1",
            "controls": "1",
            "rel" : "0",
            "cc_load_policy" : "0",
            "disablekb": "1",
            "modestbranding": "1",
            
            "autohide": "1",
            "autoplay": "0",
            //"controls": "0",
            "ps": "docs",
            "showinfo": "0",
            "color": "white",
            //"modestbranding": "1",
            "iv_load_policy": "3",
            //"playsinline": "1",
            //"rel": "0",
            "theme": "dark",
            "enablejsapi": "1",
            "mute": SharedManager.shared.isAudioEnable ? "0" : "1"
        ] as YouTubePlayerView.YouTubePlayerParameters
        
        videoPlayer.delegate = self
        videoPlayer.loadVideoID(modelDiscover?.data?.video?.link ?? "")
    }
    
    func setupCell(model: Discover?) {
        
        modelDiscover = model
        //self.imgPlay.isHidden = false
        self.activityLoader.stopAnimating()
        
        
        self.lblTitle.text = model?.subtitle?.uppercased() ?? ""
        self.lblSubTitle.text = model?.title ?? ""
        
        SharedManager.shared.bulletPlayer?.stop()
        SharedManager.shared.bulletPlayer?.currentTime = 0
        
        imgThumbnail.sd_setImage(with: URL(string: model?.data?.video?.image ?? ""), placeholderImage: nil)
        
        lblDuration.text = model?.data?.video?.bullets?.first?.duration?.formatFromMilliseconds()
        
    }
 
    
    func playVideo() {
        
        isPlayWhenReady = true
        loadVideo()
        self.videoPlayer.play()
        //self.imgPlay.isHidden = true
        self.activityLoader.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.isPlayWhenReady {
                self.videoPlayer.play()
            }
        }
    }
    
    
    
    func resetYoutubeCard() {
        
        self.videoPlayer.stop()
        self.viewPlaceholder.isHidden = false
        self.activityLoader.stopAnimating()
        self.isPlayWhenReady = false
    }
    
    
    @IBAction func didTapPlay(_ sender: Any) {
        
        playVideo()
        
        self.delegate?.didTapYoutubePlayButton(cell: self)
    }
    
}


extension GenericYoutubeCell: YouTubePlayerDelegate {
    
    
    func playerUpdateCurrentTime(_ videoPlayer: YouTubePlayerView, time: String) {
        
        if SharedManager.shared.isAudioEnable && videoPlayer.isMuted {
            SharedManager.shared.isAudioEnable = false
        }
        if SharedManager.shared.isAudioEnable == false && videoPlayer.isMuted == false {
            SharedManager.shared.isAudioEnable = true
        }
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        print("playerViewDidBecomeReady isPlayWhenReady", isPlayWhenReady)
        if self.isPlayWhenReady {
            isPlayWhenReady = false
            viewPlaceholder.isHidden = true
            videoPlayer.play()
        }
    }
    
//    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
//        return MyThemes.current == .dark ? .black : .white
//    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if playerState == .Paused {
            self.activityLoader.stopAnimating()
            //self.imgPlay.isHidden = false
        }
        else if playerState == .Ended {
            
        }
        else if playerState == .Playing {
            viewPlaceholder.isHidden = true
            
            if SharedManager.shared.isAudioEnable {
                videoPlayer.unMute()
            } else {
                videoPlayer.mute()
            }
            
        }
        else if playerState == .Unstarted {
            viewPlaceholder.isHidden = true
        }
    }
    
}

