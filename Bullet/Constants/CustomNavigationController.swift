//
//  CustomNavigationController.swift
//  Bullet
//
//  Created by Faris Muhammed on 27/05/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//


import Foundation
import UIKit



class CustomNavigationController: UINavigationController {
    
    var titleString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.prefersLargeTitles = true
        self.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = .clear
        self.navigationBar.topItem?.title = titleString
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .heavy), NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .heavy), NSAttributedString.Key.foregroundColor: UIColor.black]
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
//    override var shouldAutorotate: Bool {
//        return SharedManager.shared.canRotate///self.viewControllers.last!.shouldAutorotate
//    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versions
            return .default
        }
    }
    
}
