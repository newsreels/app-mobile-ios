//
//  EZFullScreenViewController.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit

open class EZPlayerFullScreenViewController: UIViewController {
    weak  var player: EZPlayer!
    private var statusbarBackgroundView: UIView!
    public var preferredlandscapeForPresentation = UIInterfaceOrientation.landscapeLeft
    public var currentOrientation = UIDevice.current.orientation


    // MARK: - Life cycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
//        (UIApplication.shared.delegate as! AppDelegate).orientationLock = .all
        (UIApplication.shared.delegate as! AppDelegate).orientationLock = [.landscapeLeft, .landscapeRight,.portrait]
//        let value = UIInterfaceOrientation.portrait.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerControlsHiddenDidChange(_:)), name: NSNotification.Name.EZPlayerControlsHiddenDidChange, object: nil)

        self.view.backgroundColor = UIColor.black

        self.statusbarBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: UIApplication.shared.statusBarFrame.size.height))
        self.statusbarBackgroundView.backgroundColor = self.player.fullScreenStatusbarBackgroundColor
        self.statusbarBackgroundView.autoresizingMask = [ .flexibleWidth,.flexibleLeftMargin,.flexibleRightMargin,.flexibleBottomMargin]
        self.view.addSubview(self.statusbarBackgroundView)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (UIApplication.shared.delegate as! AppDelegate).orientationLock = [.landscapeLeft, .landscapeRight,.portrait]
    }


    open override func viewDidAppear(_ animated: Bool) {
        
        (UIApplication.shared.delegate as! AppDelegate).orientationLock = [.landscapeLeft, .landscapeRight,.portrait]
        
    }
    
    
    open override func viewWillDisappear(_ animated: Bool) {
        (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()
    }
    
    
    open override func viewDidDisappear(_ animated: Bool) {
        
        (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if MediaManager.sharedInstance.player?.displayMode == .embedded {
                MediaManager.sharedInstance.isFullScreenButtonPressed = false
            }
        }
        
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }


    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // MARK: - Orientations
    
    override open var shouldAutorotate : Bool {
        return true
    }
    
    /*
    override open var shouldAutorotate : Bool {
        
        if MediaManager.sharedInstance.isOpenCurrnetlyForReels {
            return false
        } else {
            return true
        }
    }*/

//    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
//        if self.player != nil {
//            switch self.player.fullScreenMode {
//            case .portrait:
//                return [.portrait,.landscapeLeft,.landscapeRight] //[.portrait]
//            case .landscape:
//                return [.landscapeLeft,.landscapeRight]
//            }
//        } else {
//            return [.portrait]
//        }
//
//    }

//    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
//        self.currentOrientation = preferredlandscapeForPresentation == .landscapeLeft ? .landscapeRight : .landscapeLeft
//
//        switch self.player.fullScreenMode {
//        case .portrait:
//            self.currentOrientation = .portrait
//            return .portrait
//        case .landscape:
////            self.statusbarBackgroundView.isHidden = (EZPlayerUtils.hasSafeArea || (ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 13))
//            return self.preferredlandscapeForPresentation
//        }
//    }

    // MARK: - status bar
    private var statusBarHiddenAnimated = true

    override open var prefersStatusBarHidden: Bool{
        self.statusbarBackgroundView.frame = CGRect(x: 0, y: 0, width: self.statusbarBackgroundView.bounds.width, height: (self.player.fullScreenMode == .portrait) ? EZPlayerUtils.statusBarHeight : 20.0)
        if self.statusBarHiddenAnimated {
            UIView.animate(withDuration: EZPlayerAnimatedDuration, animations: {
                self.statusbarBackgroundView.alpha = self.player.controlsHidden ? 0 : 1
            }, completion: {finished in
            })
        }else{
            self.statusbarBackgroundView.alpha = self.player.controlsHidden ? 0 : 1
        }
        return self.player.controlsHidden
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle{
        return self.player.fullScreenPreferredStatusBarStyle
    }

    // MARK: - notification
    @objc func playerControlsHiddenDidChange(_ notifiaction: Notification) {
        self.statusBarHiddenAnimated = notifiaction.userInfo?[Notification.Key.EZPlayerControlsHiddenDidChangeByAnimatedKey] as? Bool ?? true
        _ = self.prefersStatusBarHidden
        self.setNeedsStatusBarAppearanceUpdate()
        if #available(iOS 11.0, *) {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.currentOrientation = UIDevice.current.orientation

    }

    open override var prefersHomeIndicatorAutoHidden: Bool{
        return self.player.controlsHidden
    }


}
