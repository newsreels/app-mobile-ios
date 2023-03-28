//
//  ReelsFullScreenVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 04/09/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation


protocol ReelsFullScreenVCDelegate: AnyObject {
    
    func rotatedVideoWatchingFinished(time: TimeInterval?)
    
}

class ReelsFullScreenVC: UIViewController {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgPlaceHolder: UIImageView!
    
    var imgthumb: UIImage?
    var url: URL?
    
    var customDuration: CMTime?
    var timer: ResumableTimer?
    
    weak var delegate: ReelsFullScreenVCDelegate?
    var videoPlayTime: TimeInterval?
    var captions: [Captions]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imgPlaceHolder.image = imgthumb
        self.imgPlaceHolder.isUserInteractionEnabled = true
        
        if let url = url {
    
            let videoInfo = [
                "autoPlay":true,
                "floatMode": EZPlayerFloatMode.none,
                "fullScreenMode": EZPlayerFullScreenMode.portrait
            ] as [String : Any]
            
            
            MediaManager.sharedInstance.playEmbeddedVideo(url: url, embeddedContentView: imgPlaceHolder, userinfo: videoInfo, isOpenForReels: true, seekTime: customDuration, viewController: self, captions: captions)
            
        }
        
        
        self.view.backgroundColor = .black
        
    }
    
//
//    override open var shouldAutorotate : Bool {
//
//        return true
//    }
//
//    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
//
//        return [.landscapeRight, .landscapeLeft] //[.portrait]
//    }
//
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reelsCompletedPlaying), name: Notification.Name.notifyReelsCompleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reelsOrientationChange), name: Notification.Name.notifyOrientationChange, object: nil)
        
        (UIApplication.shared.delegate as! AppDelegate).setOrientationBothLandscape()
        
        timer?.invalidate()
        timer = nil
        timer = ResumableTimer(interval: 0.1, callback: {
            
//            if (MediaManager.sharedInstance.player?.state ?? .unknown) == EZPlayerState.readyToPlay {
//
//            }
//            print("video time \((MediaManager.sharedInstance.player?.currentTime ?? 0))")
            self.videoPlayTime = MediaManager.sharedInstance.player?.currentTime
            
        })
        timer?.isRepeatable = true
        timer?.start()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        (UIApplication.shared.delegate as! AppDelegate).setOrientationBothLandscape()
        
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            MediaManager.sharedInstance.currentOrientation = UIDevice.current.orientation
        }
        
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
//        super.viewwilld
        
        NotificationCenter.default.removeObserver(self)
        
        (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()
        
        timer?.invalidate()
        timer = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
//
//        SharedManager.shared.canRotate = false
//        SharedManager.shared.orientationLock = [.portrait]
        
        
        (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            MediaManager.sharedInstance.isLandscapeReelPresenting = false
        }
        
        self.delegate?.rotatedVideoWatchingFinished(time: videoPlayTime)
    }
    
//    override open var shouldAutorotate : Bool {
//
//        return true
//    }
//
//    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
//
//        if MediaManager.sharedInstance.currentOrientation == nil && UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
//            MediaManager.sharedInstance.currentOrientation = UIDevice.current.orientation
//        } else if MediaManager.sharedInstance.currentOrientation != nil {
//            if MediaManager.sharedInstance.currentOrientation != UIDevice.current.orientation  {
//                MediaManager.sharedInstance.currentOrientation = UIDevice.current.orientation
//                MediaManager.sharedInstance.currentOrientationChanged = true
////                (UIApplication.shared.delegate as! AppDelegate).restrictRotation = [.portrait]
////                return [.portrait]
//
//                MediaManager.sharedInstance.releasePlayer()
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//
//        return [.landscapeLeft,.landscapeRight] //[.portrait]
//    }


    @objc func reelsOrientationChange() {
     
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight  {
            print("orientation landscape")
        } else if UIDevice.current.orientation == .portrait {
            print("orientation portrait")
        } else {
            print("orientation other")
        }
        
        if MediaManager.sharedInstance.currentOrientation == nil && UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            MediaManager.sharedInstance.currentOrientation = UIDevice.current.orientation
        }
        if MediaManager.sharedInstance.currentOrientation != nil && UIDevice.current.orientation == .portrait && (MediaManager.sharedInstance.player?.currentTime ?? 0) > 0.3  {
            MediaManager.sharedInstance.releasePlayer()
            (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func reelsCompletedPlaying() {
        
        MediaManager.sharedInstance.releasePlayer()
        (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
}
