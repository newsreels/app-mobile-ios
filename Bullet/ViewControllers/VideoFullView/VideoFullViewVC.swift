//
//  VideoFullViewVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 09/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import PlayerKit

class VideoFullViewVC: UIViewController {

    @IBOutlet weak var lblVideoTime: UILabel!
    
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var imgPlaceHolder: UIImageView!
    
    @IBOutlet weak var btnVolume: UIButton!
    @IBOutlet weak var btnFullVideo: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var viewDuration: UIView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var viewVideoBG: UIView!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var player = RegularPlayer()
    var isVideoPaused = false
    var manualPlay = false
    var status = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewVideo.cornerRadius = 12
        self.viewVideo.layer.masksToBounds = true
        self.viewVideo.clipsToBounds = true
        
        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        slider.setThumbImage(UIImage(named: "sliderThumb"), for: .highlighted)
    }
    
    @IBAction func didTapVolume(_ sender: Any) {
        
        if SharedManager.shared.isAudioEnable {
            
            SharedManager.shared.isAudioEnable = false
            player.volume = 0
            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
            
        }
        else {
            
            SharedManager.shared.isAudioEnable = true
            player.volume = 1
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
            
        }
    }
    
    @IBAction func didTapCollapseVideo(_ sender: Any) {
        
      
    }
    
    @IBAction func didTapPlayVideo(_ sender: UIButton) {

        self.isVideoPaused = false
        if self.viewDuration.isHidden {

            if self.player.playing {

                self.videoControllerStatus(isHidden: false)
            }
            else {

                self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
                self.slider.isHidden = false
                self.viewDuration.isHidden = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

                if self.player.playing {

                    self.videoControllerStatus(isHidden: true)
                }
            }
        }
        else {

            if player.duration == player.time {

                self.slider.value = 0
                player.seek(to: .zero)
                player.play()

                if self.player.playing {

                    self.videoControllerStatus(isHidden: true)
                }
            }
            else {

                if self.player.playing {

                    self.isVideoPaused = true
                   // self.delegate?.focusedIndex(index: sender.tag)
                    self.playVideo(isPause: true)
                    self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
                }
                else {

                    SharedManager.shared.bulletPlayer?.pause()
                    SharedManager.shared.bulletPlayer?.stop()
                //    self.delegate?.focusedIndex(index: sender.tag)

                    self.manualPlay = true
                    self.playVideo(isPause: false)
                    self.imgPlay.image = UIImage(named: "videoPause")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

                        self.videoControllerStatus(isHidden: true)
                    }
                }
            }
        }
    }
    
    @IBAction func didChangeSliderValue() {
        
        // player.pause()
        let value = Double(self.slider.value)
        let time = value * player.duration
        player.seek(to: time)
    }
}

//MARK:- Video Player setup
extension VideoFullViewVC {

    func playVideo(isPause: Bool) {
        
        if SharedManager.shared.isAudioEnable == false {
            
            player.volume = 0
            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
        }
        else {
            
            player.volume = 1
            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
        }
        
        if isPause {
            
            player.pause()
        }
        else {
            
            //if user pause the video and he went to category view.. I'm cheking video status
            if self.isVideoPaused {

                player.pause()
            }
            else {
                
                if SharedManager.shared.videoAutoPlay || manualPlay == true {
                    
                    manualPlay = false
                    self.videoControllerStatus(isHidden: true)
                    
                    if status != Constant.newsArticle.ARTICLE_STATUS_SCHEDULED && status != Constant.newsArticle.ARTICLE_STATUS_PROCESSING {
         
                        self.activityIndicator.startAnimating()
                        player.play()
                    }
                }
                else {
                    
                    self.slider.isHidden = true
                    self.videoControllerStatus(isHidden: false)
                }
            }
        }
    }
    
    private func addPlayerToView() {
        
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.frame = self.viewVideo.frame
        player.fillMode = .fit
        self.viewVideo.insertSubview(player.view, at: 0)
        
        self.viewVideo.cornerRadius = 12
        self.viewVideo.layer.masksToBounds = true
        self.viewVideo.clipsToBounds = true

        self.viewVideo.layoutIfNeeded()
        for view in self.viewVideo.subviews {
            view.layoutIfNeeded()
            view.clipsToBounds = true
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 12
        }
    }
    
    func resetVisibleVideoPlayer() {
        
    
        if player.state == .loading {
            
        }
        player.pause()
        player.seek(to: .zero)
        self.videoControllerStatus(isHidden: true)
    }
    
    func videoControllerStatus(isHidden:Bool) {
        
        UIView.animate(withDuration: 0.2) {
            if isHidden {

                self.imgPlay.image = UIImage(named: "videoPause")
                self.slider.isHidden = true
                self.viewDuration.isHidden = true
                self.btnVolume.isHidden = true
            }
            else {
                
                if self.player.time == 0 {
                    
                    self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
                }
                else {
                    
                    self.imgPlay.image = UIImage(named: "videoPause")
                }
                self.slider.isHidden = false
                self.viewDuration.isHidden = false
                self.btnVolume.isHidden = false
            }
        }
        
    }
}

// MARK:- VideoPlayerDelegate
extension VideoFullViewVC: PlayerDelegate {
    
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        self.activityIndicator.stopAnimating()
        
        switch player.state {
        case .loading:
       
            if player.time > 0 {
                self.activityIndicator.startAnimating()
            }
            
        case .ready:
            
            self.lblVideoTime.text = "\(player.duration.stringFromTimeInterval())"
            if !SharedManager.shared.viewSubCategoryIshidden {
                self.playVideo(isPause: true)
            }
            break
            
        case .failed:
            
            NSLog("🚫 \(String(describing: player.error))")
        }
    }
    
    func playerDidUpdatePlaying(player: Player) {
        
        self.playButton.isSelected = player.playing
    }
    
    func playerDidUpdateTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
        
        self.activityIndicator.stopAnimating()
        if player.time > 0 {
            if self.imgPlaceHolder.isHidden == false {
                self.imgPlaceHolder.isHidden = true
            }
        } else {
            if self.imgPlaceHolder.isHidden {
                self.imgPlaceHolder.isHidden = false
            }
        }
        
        let ratio = player.time / player.duration
        
        if self.slider.isHighlighted == false {
            
            UIView.animate(withDuration: 0.3) {
                
                if player.time > 0 {
                    self.lblVideoTime.text = "\(player.time.stringFromTimeInterval()) / \(player.duration.stringFromTimeInterval()) "
                }
                else {
                    self.lblVideoTime.text = "\(player.duration.stringFromTimeInterval()) "
                }
                self.slider.value = Float(ratio)
            }
        }
        
        if player.duration <= player.time {
            
            self.videoControllerStatus(isHidden: false)
        }
    }
    
    func playerDidUpdateBufferedTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
    }
}
