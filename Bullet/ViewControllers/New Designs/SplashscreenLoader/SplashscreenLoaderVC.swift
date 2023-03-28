//
//  SplashscreenLoaderVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 19/09/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol SplashscreenLoaderVCDelegate: AnyObject {
    
    func dismissSplashscreenLoaderVC()
}

class SplashscreenLoaderVC: UIViewController {

    @IBOutlet weak var imgLogo: UIImageView!
//    @IBOutlet weak var viewLoader: UIView!
    
    weak var delegate: SplashscreenLoaderVCDelegate?
    
    var imageArray = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
//        for i in 1...54 {
//            imageArray.append(UIImage(named: "logo_sequence\(i)") ?? UIImage())
//        }
//        // Set music gif
//        do {
//
//        for i in 1...54 {
//            imageArray.append(UIImage(named: "logo_sequence\(i)") ?? UIImage())
//        }
////        // Set music gif
////        do {
////
////            let gif = try UIImage(gifName: "SplashLoader")
////            self.imgLogo.setGifImage(gif)
////            self.imgLogo.animationRepeatCount = 1
////            self.imgLogo.startAnimatingGif()
////
////
////        } catch {
////            print(error)
////        }
////
//
//        self.imgLogo.animationImages = imageArray
//        self.imgLogo.animationDuration = 2
//        self.imgLogo.animationRepeatCount = 0
//        self.imgLogo.startAnimating()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//
//            if (SharedManager.shared.tabBarIndex == 0) {
//                SharedManager.shared.showLoaderInWindow()
//            }
//
//            self.delegate?.dismissSplashscreenLoaderVC()
//        }
        
        self.delegate?.dismissSplashscreenLoaderVC()
//        self.imgLogo.animationImages = imageArray
//        self.imgLogo.animationDuration = 2
//        self.imgLogo.animationRepeatCount = 0
//        self.imgLogo.startAnimating()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            
//            if (SharedManager.shared.tabBarIndex == 0) {
//                SharedManager.shared.showLoaderInWindow()
//            }
//            
//            self.delegate?.dismissSplashscreenLoaderVC()
//        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidDisappear(_ animated: Bool) {
        
//        self.imgLogo.clear()
//        self.imgLogo = nil
        
    }

}
