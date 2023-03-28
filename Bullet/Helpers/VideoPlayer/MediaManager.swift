//
//  MediaManager.swift
//  EZPlayerExample
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit
import AVFoundation

class MediaManager {
     var player: EZPlayer?
     var mediaItem: MediaItem?
     var embeddedContentView: UIView?

    var currentlyFullScreenCell: UITableViewCell?
    var isFullScreenButtonPressed = false
    
    static let sharedInstance = MediaManager()
    var isOpenCurrnetlyForReels = false
    var currentOrientation: UIDeviceOrientation?
    var isLandscapeReelPresenting = false
    var currentVC: UIViewController?
    
    var playerDidPlayToEndCallBack: (() -> Void)?
    
    var playerDidChangeDisplayModeCallBack: (() -> Void)?
    
    var currentArticleID = ""
    
    var currentCaptions: [Captions]?
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    private init(){

        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidPlayToEnd(_:)), name: .EZPlayerPlaybackDidFinish, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidChangeDisplayMode(_:)), name: .EZPlayerDisplayModeChangedDidAppear, object: nil)

    }

    func playEmbeddedVideo(url: URL, embeddedContentView contentView: UIView? = nil, userinfo: [AnyHashable : Any]? = nil, isOpenForReels: Bool = false, seekTime: CMTime? = nil, viewController: UIViewController?, articleID: String = "", captions: [Captions]? = nil) {
        var mediaItem = MediaItem()
        mediaItem.url = url
        self.playEmbeddedVideo(mediaItem: mediaItem, embeddedContentView: contentView, userinfo: userinfo, isOpenForReels: isOpenForReels, seekTime: seekTime, viewController: viewController, articleID: articleID, captions: captions)

    }

    func playEmbeddedVideo(mediaItem: MediaItem, embeddedContentView contentView: UIView? = nil , userinfo: [AnyHashable : Any]? = nil, isOpenForReels: Bool, seekTime: CMTime? = nil, viewController: UIViewController?, articleID: String, captions: [Captions]? = nil) {
        //stop
        self.releasePlayer()

        if let skinView = userinfo?["skin"] as? UIView{
         self.player =  EZPlayer(controlView: skinView)
        }else{
          self.player = EZPlayer()
        }
        

//        self.player!.slideTrigger = (left:EZPlayerSlideTrigger.none,right:EZPlayerSlideTrigger.none)

        if let autoPlay = userinfo?["autoPlay"] as? Bool{
            self.player!.autoPlay = autoPlay
        }

        if let floatMode = userinfo?["floatMode"] as? EZPlayerFloatMode{
            self.player!.floatMode = floatMode
        }

        if let fullScreenMode = userinfo?["fullScreenMode"] as? EZPlayerFullScreenMode{
            self.player!.fullScreenMode = fullScreenMode
        }
        
        if let videoGravity = userinfo?["videoGravity"] as? EZPlayerVideoGravity {
            self.player!.videoGravity = videoGravity
        }
        

        self.player!.backButtonBlock = { fromDisplayMode in
            
//            (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
            
            if fromDisplayMode == .embedded {
                self.releasePlayer()
            }else if fromDisplayMode == .fullscreen {
                if self.embeddedContentView == nil && self.player!.lastDisplayMode != .float{
                    self.releasePlayer()
                }

            }else if fromDisplayMode == .float {
                if self.player!.lastDisplayMode == .none{
                    self.releasePlayer()
                }
            }
//            (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        }

        self.embeddedContentView = contentView

        if isOpenForReels {
            isOpenCurrnetlyForReels = true
        } else {
            isOpenCurrnetlyForReels = false
            
        }
        
        if let captions = captions {
            currentCaptions = captions
        } else {
            currentCaptions = nil
        }
        
        self.currentArticleID = articleID
        
        self.currentVC = viewController
        currentOrientation = nil
        self.player!.playWithURL(mediaItem.url! , embeddedContentView: self.embeddedContentView, playTime: seekTime)
    }




    func releasePlayer(){
        
        if self.currentArticleID != "" {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoDurationEvent, eventDescription: "", article_id: self.currentArticleID, duration: MediaManager.sharedInstance.player?.currentTime?.formatToMilliSeconds() ?? "")
        }
        
        self.player?.stop()
        self.player?.view.removeFromSuperview()

        self.player = nil
        self.embeddedContentView = nil
        self.mediaItem = nil

    }

    @objc  func playerDidPlayToEnd(_ notifiaction: Notification) {
       //结束播放关闭播放器
       //self.releasePlayer()
        
        if (MediaManager.sharedInstance.player?.currentTime ?? 0) >= (MediaManager.sharedInstance.player?.duration ?? 0)  {
            if self.currentArticleID != "" {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoFinishedPlaying, eventDescription: "", article_id: self.currentArticleID)
            }
            
            self.playerDidPlayToEndCallBack?()
        } else {
            if self.currentArticleID != "" {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.videoDurationEvent, eventDescription: "", article_id: self.currentArticleID, duration: MediaManager.sharedInstance.player?.currentTime?.formatToMilliSeconds() ?? "")
            }
        }
        
        
    }
    
    
    @objc  func playerDidChangeDisplayMode(_ notifiaction: Notification) {
       //结束播放关闭播放器
       //self.releasePlayer()
        self.playerDidChangeDisplayModeCallBack?()
    }
    
    
    
    func orientationChanged() {
        
        
//        if isOpenCurrnetlyForReels == false && player != nil && player?.displayMode == .embedded && (player?.currentTime ?? 0) > 0.3 && (player?.state ?? .unknown) == EZPlayerState.playing {
//            self.player?.toFull()
//        }
        
    }
    

}
