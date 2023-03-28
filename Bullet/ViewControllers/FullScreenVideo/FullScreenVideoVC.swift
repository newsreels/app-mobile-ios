//
//  FullScreenVideoVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 10/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation
import PlayerKit

protocol FullScreenVideoVCDelegate: AnyObject {
    
    func backButtonPressed(cell: VideoPlayerVieww?)
    func backButtonPressed(cell: HomeDetailCardCell?)
    func backButtonPressed(cell: GenericVideoCell?)
}


class FullScreenVideoVC: UIViewController {

    @IBOutlet weak var viewVideoBG: UIView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var imgPlaceHolder: UIImageView!
    @IBOutlet weak var lblVideoTime: UILabel!
    @IBOutlet weak var viewDuration: UIView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var btnFullScreen: UIButton!
    @IBOutlet weak var btnVolume: UIButton!
    
    @IBOutlet weak var slider: UISlider!

    var player = RegularPlayer()
    weak var delegate: FullScreenVideoVCDelegate?
    
    var playingTime: TimeInterval?
    var playerItem: AVPlayerItem?
    var url: String = ""
    var sliderValue: Float = 0
    var playerID = ""
    var homeDetailCardCell: HomeDetailCardCell?
    var VideoPlayerVieww: VideoPlayerVieww?
    var genericVideoCell: GenericVideoCell?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.hero.isEnabled = true
//        viewVideo.hero.id = playerID
        
        self.player.pause()
        self.player.seek(to: 0)
        self.player.delegate = self
        
        
        player.volume = SharedManager.shared.isAudioEnable ? 1 : 0
        if playerItem != nil {
            self.addPlayerToView(asset: nil, playingTime: playingTime, playerItem: playerItem)
        } else {
            if let url = URL(string: url) {
                self.addPlayerToView(asset: AVAsset(url: url), playingTime: playingTime, playerItem: nil)
            }
        }
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    // MARK: Methods
    private func addPlayerToView(asset: AVAsset?,playingTime: TimeInterval?, playerItem: AVPlayerItem?) {
        
     //   SharedManager.shared.isVideoPlaying = true
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
        
        
        if playerItem != nil {
            if let url = URL(string: url) {
                
                self.player.set(AVAsset(url: url), playerItem: playerItem)
                self.player.seek(to: playingTime ?? .zero)
                if SharedManager.shared.isVideoPlaying {
                    
                    self.player.play()
                }
                self.imgPlay.image = UIImage(named: "videoPause")
            }
        } else {
            if let url = URL(string: url) {
                
                self.player.set(AVAsset(url: url), playerItem: playerItem)
                self.player.seek(to: playingTime ?? .zero)
                if SharedManager.shared.isVideoPlaying {
                    
                    self.player.play()
                }
                self.imgPlay.image = UIImage(named: "videoPause")
            }
        }
        
    }
    
    
    // MARK: - Button Actions

    @IBAction func didTapPlayButton(_ sender: Any) {
        
        if self.player.playing {
            
            self.player.pause()
            SharedManager.shared.isVideoPlaying = false
            self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
            
        } else {
            
            self.player.play()
            SharedManager.shared.isVideoPlaying = true
            self.imgPlay.image = UIImage(named: "videoPause")
            
        }
        
    }
    
    @IBAction func didTapFullScreen(_ sender: Any) {
        
        self.player.pause()
        self.dismiss(animated: true, completion: nil)
        
        self.delegate?.backButtonPressed(cell: homeDetailCardCell)
        self.delegate?.backButtonPressed(cell: genericVideoCell)
        self.delegate?.backButtonPressed(cell: VideoPlayerVieww)
    }
    
    
    @IBAction func didChangeSliderValue() {
        
        // player.pause()
        let value = Double(self.slider.value)
        let time = value * player.duration
        player.seek(to: time)
    }
}


extension FullScreenVideoVC: PlayerDelegate {
    
    // MARK: VideoPlayerDelegate
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        self.activityIndicator.stopAnimating()
        
        switch player.state {
        case .loading:
            
         //   self.lblVideoTime.text = "00:00"
            if player.time > 0 {
                self.activityIndicator.startAnimating()
            }
//            self.imgPlaceHolder.isHidden = false
            
        case .ready:
            
            self.lblVideoTime.text = "\(player.duration.stringFromTimeInterval())"
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
            
//            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.videoFinishedPlaying, eventDescription: "", article_id: currentArticleID)
//
//            self.videoControllerStatus(isHidden: false)
//            self.delegate?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
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

