//
//  AppNavigationController.swift
//  Bullet
//
//  Created by Mahesh on 09/06/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import Foundation
import UIKit

@objc protocol AppNavigationControllerDelegate {
    
    @objc optional func appNavigationController_SearchAction()
    @objc optional func appNavigationController_ProfileAction()
    @objc optional func appNavigationController_LeftMenuAction()
}


class AppNavigationController: UINavigationController {
    
    //MARK: VARIABLE
    weak var navigationDelegate: AppNavigationControllerDelegate?

    var frameTitleView = CGRect.zero
    var btnWidth = CGFloat()

    var btnSearch: UIButton!
    var btnProfile: UIButton!
    var lblTitle: UILabel!
    var btnClose: UIButton!
    
    var rootViewController: UIViewController? {
        return viewControllers.first
    }

    var showDarkStatusBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.theme_barTintColor = GlobalPicker.barTintColor //RGBCOLOR(72, g: 152, b: 154)
        self.navigationBar.theme_barStyle = GlobalPicker.barStyle
//        self.navigationBar.barTintColor = UIColor.green
        self.navigationBar.isTranslucent = false
//        self.navigationBar.tintColor = UIColor.red
        self.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.layoutIfNeeded()
        self.navigationBar.isHidden = true
        self.interactivePopGestureRecognizer?.isEnabled = false

//        let height: CGFloat = 50 //whatever height you want to add to the existing height
//        let bounds = self.navigationBar.bounds
//        self.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        
        let dict = [NSAttributedString.Key.font: UIFont(name: Constant.FONT_Mulli_BOLD, size: 24),
                    NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationBar.titleTextAttributes = dict
        //self.setValue(CustomNavigationBar.init(), forKeyPath: "navigationBar")

        btnWidth = 40;
        frameTitleView = CGRect(x: 0, y: 0, width: self.navigationBar.frame.width, height: self.navigationBar.frame.height)
//        frameTitleView = CGRect(x: btnWidth, y: 0, width: self.navigationBar.frame.width - (btnWidth * 2) - 10, height: self.navigationBar.frame.height)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
//    override var shouldAutorotate: Bool {
//        return SharedManager.shared.canRotate///self.viewControllers.last!.shouldAutorotate
//    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if showDarkStatusBar {
            print("statusbar dark")
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                // Fallback on earlier versions
                return .default
            }
            
        }
        else {
            print("statusbar light")
            if #available(iOS 13.0, *) {
    //            if SharedManager.shared.tabBarIndex == 0 || SharedManager.shared.tabBarIndex == 1 || SharedManager.shared.tabBarIndex == 3 {
    //                return .lightContent
    //            }
                return .lightContent//MyThemes.current == .dark ? .lightContent : .darkContent
            } else {
                // Fallback on earlier versions
    //            if SharedManager.shared.tabBarIndex == 0 || SharedManager.shared.tabBarIndex == 1 || SharedManager.shared.tabBarIndex == 3 {
    //                return .lightContent
    //            }
                return .default//MyThemes.current == .dark ? .lightContent : .default
            }
            
        }
    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return SharedManager.shared.orientationLock
//        //.portrait//self.viewControllers.last!.supportedInterfaceOrientations
//    }
//
    //MARK:- NAV Functions
    
    internal func setLeftMenu(_ viewController: UIViewController) {

        btnClose = UIButton(type: .custom)
        btnClose.frame = CGRect(x: 0, y: 0, width: btnWidth, height: btnWidth)
//        btnClose.layer.borderWidth = 1
//        btnClose.layer.borderColor = UIColor.red.cgColor
//        btnClose.theme_setImage(GlobalPicker.btnImgBack, forState: .normal)
        btnClose.setImage(#imageLiteral(resourceName: "Icn_back2"), for: .normal)
        btnClose.addTarget(self, action: #selector(didTapLeftMenuAction), for: .touchUpInside)
        btnClose.showsTouchWhenHighlighted = true
        btnClose.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: -16, bottom: 0, right: 0)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btnClose)
    }
    
    internal func setLeftLogo(_ viewController: UIViewController) {

        btnClose = UIButton(type: .custom)
        btnClose.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnClose.theme_setImage(GlobalPicker.navLogo, forState: .normal)
        btnClose.contentMode = .scaleAspectFit
        btnClose.showsTouchWhenHighlighted = false
//        btnClose.layer.borderWidth = 1
//        btnClose.layer.borderColor = UIColor.red.cgColor
        btnClose.isUserInteractionEnabled = false
        btnClose.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
//        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
//        negativeSpacer.width = -25;
//        let left = UIBarButtonItem(customView: btnClose)
//        viewController.navigationItem.leftBarButtonItems = [negativeSpacer,left]
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btnClose)
    }
    
    internal func setRightButton(_ viewController: UIViewController) {
        
        btnClose = UIButton(type: .custom)
        btnClose.frame = CGRect(x: 0, y: 0, width: btnWidth, height: btnWidth)
        btnClose.theme_setImage(GlobalPicker.navClose, forState: .normal)
        btnClose.addTarget(self, action: #selector(didTapLeftMenuAction), for: .touchUpInside)
        btnClose.showsTouchWhenHighlighted = true
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btnClose)
    }
    
    internal func setCustomTitle(_ viewController: UIViewController, title: String) {
        
        //self.lblTitle.removeFromSuperview()
        self.lblTitle = UILabel(frame: frameTitleView)
        self.lblTitle.text = title
        self.lblTitle.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 24)!
        self.lblTitle.textAlignment = .left
        self.lblTitle.numberOfLines = 0
        self.lblTitle.theme_textColor = GlobalPicker.textColor
//        self.lblTitle.layer.borderColor = UIColor.green.cgColor
//        self.lblTitle.layer.borderWidth = 1

        viewController.navigationItem.titleView = self.lblTitle
    }
    
    internal func setCustomCenterTitle(_ viewController: UIViewController, title: String) {
        
        //self.lblTitle.removeFromSuperview()
        self.lblTitle = UILabel(frame: frameTitleView)
        self.lblTitle.text = title
        self.lblTitle.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 24)!
        self.lblTitle.textAlignment = .left
        self.lblTitle.numberOfLines = 0
        self.lblTitle.theme_textColor = GlobalPicker.textColor
//        self.lblTitle.layer.borderColor = UIColor.red.cgColor
//        self.lblTitle.layer.borderWidth = 1

        viewController.navigationItem.titleView = self.lblTitle
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: UIButton())
    }
    
    internal func setRightViewImageButton(_ viewController: UIViewController) {
        
        let width: CGFloat = 30
        let viewRight = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat((width * 2)), height: width))
        self.btnSearch = UIButton(type: .custom)
        self.btnSearch.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(width), height: CGFloat(width))
        btnSearch.theme_setImage(GlobalPicker.navSearch, forState: .normal)

        self.btnSearch.addTarget(self, action: #selector(didTapSearchAction), for: .touchUpInside)
        self.btnSearch.showsTouchWhenHighlighted = true
        viewRight.addSubview(self.btnSearch)
        
        btnProfile = UIButton(type: .custom)
        btnProfile.frame = CGRect(x: CGFloat(self.btnSearch.frame.maxX), y: CGFloat(0), width: CGFloat(width), height: CGFloat(width))
        btnProfile.layer.cornerRadius = btnProfile.frame.size.width / 2
        btnProfile.layer.masksToBounds = true
        btnProfile.theme_setImage(GlobalPicker.navProfile, forState: .normal)
        btnProfile.showsTouchWhenHighlighted = true
        btnProfile.addTarget(self, action: #selector(didTapProfileAction), for: .touchUpInside)
        viewRight.addSubview(btnProfile)
        
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: viewRight)
    }
    
    @objc internal func didTapSearchAction() {
        self.navigationDelegate?.appNavigationController_SearchAction!()
    }
    
    @objc internal func didTapProfileAction() {
        self.navigationDelegate?.appNavigationController_ProfileAction!()
    }
    
    @objc internal func didTapLeftMenuAction() {
        self.navigationDelegate?.appNavigationController_LeftMenuAction!()
    }
    
}

class CustomNavigationBar: UINavigationBar {
  
    // NavigationBar height
    var customHeight : CGFloat = 120
  
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: customHeight)
    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
      
        let y = UIApplication.shared.statusBarFrame.height
        frame = CGRect(x: frame.origin.x, y:  y, width: frame.size.width, height: customHeight)
      
//        for subview in self.subviews {
//            var stringFromClass = NSStringFromClass(subview.classForCoder)
//            if stringFromClass.contains("BarBackground") {
//                subview.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: customHeight)
//                subview.backgroundColor = self.backgroundColor
//            }
//
//            stringFromClass = NSStringFromClass(subview.classForCoder)
//            if stringFromClass.contains("BarContent") {
//                subview.frame = CGRect(x: subview.frame.origin.x, y: 20, width: subview.frame.width, height: customHeight)
//                subview.backgroundColor = self.backgroundColor
//            }
//        }
    }
}
