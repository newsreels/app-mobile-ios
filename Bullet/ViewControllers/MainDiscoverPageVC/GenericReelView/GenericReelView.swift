//
//  GenericReelView.swift
//  Bullet
//
//  Created by Khadim Hussain on 12/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation
import PlayerKit

class GenericReelView: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var viewGesture: UIView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var imgVolume: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var player: RegularPlayer?
    var isPlayWhenReady = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.theme_backgroundColor = GlobalPicker.backgroundDiscoverMainColor
        self.viewVideo.backgroundColor = .black
        self.selectionStyle = .none
        self.viewShadow.backgroundColor = MyThemes.current == .dark ? .black : .white
        self.viewShadow.layer.cornerRadius = 12
        self.viewShadow.layer.masksToBounds = true
        self.viewShadow.addBottomShadowForDiscoverPage()
    }
    
    override func layoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                self.lblSubTitle.semanticContentAttribute = .forceRightToLeft
                self.lblSubTitle.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                self.lblSubTitle.semanticContentAttribute = .forceLeftToRight
                self.lblSubTitle.textAlignment = .left
            }
        }
    }
    
    func setupCell(model: Discover?, isFocused: Bool) {
        
        self.lblTitle.text = model?.subtitle?.uppercased() ?? ""
        self.lblSubTitle.text = model?.title ?? ""
        let url = model?.data?.reel?.media ?? ""
        
       // self.imgReel?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
        
        if let url = URL(string: url) {
            
            if player == nil {
                player = RegularPlayer()
                self.addPlayerToView(videoInfo: model?.data?.reel?.media_meta)
                player?.delegate = self
                
            }
            
            self.player!.set(AVURLAsset(url: url))
            PauseVideo()
            
            if isFocused {

                self.playVideo()
            }
            
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureAction(sender:)))
            longPressRecognizer.minimumPressDuration = 0.5
            longPressRecognizer.delegate = self
            self.viewGesture.addGestureRecognizer(longPressRecognizer)

            imgVolume.image = nil
            imgVolume.alpha = 0
        
            self.setNeedsLayout()
            self.layoutIfNeeded()
 
        }
    }
    
    @objc func longPressGestureAction(sender: UILongPressGestureRecognizer) {
        
        print("sender.state", sender.state)

        if sender.state == .began {
            PauseVideo()
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            if player?.playing == false {
                playVideo()
            }
        }
    }
    
    @objc func tapGestureGestureAction(sender: UILongPressGestureRecognizer) {

        
        if SharedManager.shared.isAudioEnable == false {
            SharedManager.shared.isAudioEnable = true
            player?.volume = 1
            showVolumeOnAnimation()
        } else {
            SharedManager.shared.isAudioEnable = false
            player?.volume = 0
            showVolumeOffAnimation()
        }
    }
    
    func showVolumeOnAnimation() {
        imgVolume.image = UIImage(named: "ReelsSoundOn")
        UIView.animate(withDuration: 0.5) {
            self.imgVolume.alpha = 1
            self.layoutIfNeeded()
        } completion: { (status) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.5) {
                    self.imgVolume.alpha = 0
                    self.layoutIfNeeded()
                } completion: { (status) in
                    self.imgVolume.alpha = 0
                    self.layoutIfNeeded()
                }
            }
        }

        
    }
    
    func showVolumeOffAnimation() {
        imgVolume.image = UIImage(named: "ReelsSoundOff")
        UIView.animate(withDuration: 0.5) {
            self.imgVolume.alpha = 1
            self.layoutIfNeeded()
        } completion: { (status) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 0.5) {
                    self.imgVolume.alpha = 0
                    self.layoutIfNeeded()
                } completion: { (status) in
                    self.imgVolume.alpha = 0
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    func PauseVideo() {
        
        isPlayWhenReady = false
        player?.pause()
    }
    

    func playVideo() {
        
        if SharedManager.shared.videoAutoPlay &&  SharedManager.shared.isOnDiscover {
            
            isPlayWhenReady = true
            if SharedManager.shared.isAudioEnable == false {
                player?.volume = 0
            } else {
                player?.volume = 1
            }
            
            self.player?.play()
            self.imgPlay.isHidden = true
            
        }
        else {
            
            self.imgPlay.isHidden = false
            self.player?.pause()
        }
    }
    
    private func addPlayerToView(videoInfo: MediaMeta?) {
        
        player?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player?.view.frame = self.viewVideo.bounds
        if videoInfo?.width ?? 0 >  videoInfo?.height ?? 0 {
            player?.fillMode = .fit
        } else {
            player?.fillMode = .fill
        }
        self.viewVideo.insertSubview(player?.view ?? UIView(), at: 0)
        
        self.viewVideo.layer.cornerRadius = 12
        self.viewVideo.layer.masksToBounds = true
        self.viewVideo.clipsToBounds = true
    }
    
    
    func stopVideo() {
        isPlayWhenReady = false
        player?.seek(to: .zero)
        player?.pause()
        self.layoutIfNeeded()
    }
}

extension GenericReelView: PlayerDelegate {
    
    // MARK: VideoPlayerDelegate
    func playerDidUpdateState(player: Player, previousState: PlayerState) {

        switch player.state {
        case .loading:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if player.state == .loading {
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                }
            }
            break
        case .ready:
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            if isPlayWhenReady && player.playing == false {
                player.play()
                isPlayWhenReady = false
            }
            break

        case .failed:
            isPlayWhenReady = false
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            NSLog("🚫 \(String(describing: player.error))")
        }
        
    }
    
    func playerDidUpdatePlaying(player: Player) {
        
    }
    
    func playerDidUpdateTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
        
//        let ratio = player.time / player.duration
        if player.duration == player.time {
          //  self.delegate?.videoPlayingFinished(cell: self)
        }
        
    }
    
    func playerDidUpdateBufferedTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
//        let ratio = Int((player.bufferedTime / player.duration) * 100)
        //self.label.text = "Buffer: \(ratio)%"
    }
}
