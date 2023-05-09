//
//  TabBarControllerViewController.swift
//  SketchNUR
//
//  Created by Hussein Al-Ryalat on 11/12/18.
//  Copyright © 2018 SketchMe. All rights reserved.
//

import UIKit

open class PTCardTabBarController: UITabBarController {
    
    @IBInspectable public var tintColor: UIColor? {
        didSet {
            //customTabBar.tintColor = tintColor
            customTabBar.reloadApperance()
        }
    }
    
    @IBInspectable public var tabBarBackgroundColor: UIColor? {
        didSet {
            customTabBar.reloadApperance()
        }
    }
    
    lazy var customTabBar: PTCardTabBar = {
        return PTCardTabBar()
    }()
    
    fileprivate lazy var smallBottomView: UIView = {
        let anotherSmallView = UIView()
        anotherSmallView.backgroundColor = .clear
        anotherSmallView.translatesAutoresizingMaskIntoConstraints = false

        return anotherSmallView
    }()
    
    override open var selectedIndex: Int {
        didSet {
            customTabBar.select(at: selectedIndex, notifyDelegate: false)
        }
    }

    override open var selectedViewController: UIViewController? {
        didSet {
            customTabBar.select(at: selectedIndex, notifyDelegate: false)
        }
    }
    
    fileprivate var bottomSpacing: CGFloat = 0
    fileprivate var tabBarHeight: CGFloat = 50
    fileprivate var horizontleSpacing: CGFloat = (UIScreen.main.bounds.width * 0.25)
    fileprivate var previousController: UIViewController?

    fileprivate var ctbTopAnchor: NSLayoutConstraint!
    fileprivate var ctbBotAnchor: NSLayoutConstraint!

    open func showTabBar(_ bShow: Bool, animated: Bool) {

        // we want to show it, but it's already showing, or
        // we want to hide it, but it's already hidden
        if bShow && ctbBotAnchor.isActive || !bShow && ctbTopAnchor.isActive { return }
        
        if !bShow {
            ctbBotAnchor.isActive = false
            ctbTopAnchor.isActive = true
        } else {
            ctbTopAnchor.isActive = false
            ctbBotAnchor.isActive = true
        }
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets = bShow ? UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpacing, right: 0) : .zero
        }
        
        let dur = animated ? 0.25 : 0.0
        UIView.animate(withDuration: dur, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    open override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        // move "built-in" tab bar below view frame
        var r = tabBar.frame
        r.origin.y = self.view.frame.maxY + 1
        tabBar.frame = r
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpacing, right: 0)
        }
        
        self.tabBar.isHidden = true

        addAnotherSmallView()
        setupTabBar()
        
        customTabBar.items = tabBar.items!
        
//        if SharedManager.shared.tabBarIndex == TabbarType.Reels.rawValue {
//            SharedManager.shared.isAppLaunchFirstTIME = false
//        }
        /*
        if SharedManager.shared.tabBarIndex == TabbarType.Reels.rawValue {
            selectedIndex = TabbarType.Reels.rawValue
        }
        else if SharedManager.shared.tabBarIndex == TabbarType.Home.rawValue {
            selectedIndex = TabbarType.Home.rawValue
        }
        else if SharedManager.shared.tabBarIndex == TabbarType.Search.rawValue {
            selectedIndex = TabbarType.Search.rawValue
        }
        else {
            selectedIndex = TabbarType.Profile.rawValue
        }
        */
        SharedManager.shared.tabBarIndex = TabbarType.Reels.rawValue
        selectedIndex = TabbarType.Reels.rawValue
        customTabBar.select(at: selectedIndex)
        //customTabBar.select(at: SharedManager.shared.tabBarIndex == TabbarType.Reels.rawValue ? SharedManager.shared.tabBarIndex : selectedIndex)
    }
    
    
    fileprivate func addAnotherSmallView() {
        self.view.addSubview(smallBottomView)
        
        smallBottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        let cr: NSLayoutConstraint
        
        if #available(iOS 11.0, *) {
            cr = smallBottomView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: tabBarHeight)
        } else {
            cr = smallBottomView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: tabBarHeight)
        }
        
        cr.priority = .defaultHigh
        cr.isActive = true
        
        smallBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        smallBottomView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setupTabBar() {
        
        customTabBar.delegate = self
        self.view.addSubview(customTabBar)
        
        ctbBotAnchor = customTabBar.bottomAnchor.constraint(equalTo: smallBottomView.topAnchor, constant: 0)
        ctbTopAnchor = customTabBar.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        
        ctbBotAnchor.isActive = true
        
        customTabBar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        customTabBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        customTabBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        customTabBar.heightAnchor.constraint(equalToConstant: tabBarHeight).isActive = true
        //customTabBar.backgroundColor = .green
        
        self.view.bringSubviewToFront(customTabBar)
        self.view.bringSubviewToFront(smallBottomView)
        
        customTabBar.tintColor = tintColor
        
        // Safe area color
        //smallBottomView.backgroundColor = .red
//        smallBottomView.theme_backgroundColor = GlobalPicker.customTabbarBGColor
    }
    
    func reloadViewOnBlock() {
        SharedManager.shared.isTabReload = true
        
        if let controller = viewControllers?[selectedIndex] {
            if let navVC = controller as? AppNavigationController, let vc = navVC.rootViewController as? TopStoriesVC {
                
                vc.viewWillAppear(true)
            }
        }
    }
}

extension PTCardTabBarController: CardTabBarDelegate {
    
    func cardTabBar(_ sender: PTCardTabBar, didSelectItemAt index: Int) {
        
        SharedManager.shared.isSubSourceView = false
        SharedManager.shared.tabBarIndex = TabbarType.Search.rawValue
        SharedManager.shared.isUserTapOnTabbar = true
        if SharedManager.shared.subTabBarType == .Articles {
            
            SharedManager.shared.isLoadWebFromArticles = true
        }
        
        
        ANLoader.hide()
   
        switch index {
        case 0:
            
            //reels
            NotificationCenter.default.post(name: Notification.Name.stopVideoNotification, object: nil, userInfo: nil)
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.reelsPageClick, eventDescription: "")
//            SharedManager.shared.articleSearchModeType = ""
            SharedManager.shared.tabBarIndex = TabbarType.Reels.rawValue
                        
            //SharedManager.shared.isTabReload = false

            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
//            self.customTabBar.theme_backgroundColor = GlobalPicker.customTabbarBGColorReels//UIColor.black
//            smallBottomView.theme_backgroundColor = GlobalPicker.customTabbarBGColorReels
            
            customTabBar.backgroundColor = .black
            smallBottomView.backgroundColor = .black
            
            NotificationCenter.default.post(name: Notification.Name.notifyReelsTabBarTapped, object: nil, userInfo: nil)
            break

        case 1:
            //Home
            NotificationCenter.default.post(name: Notification.Name.stopVideoNotification, object: nil, userInfo: nil)
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.homePageClick, eventDescription: "")
//            SharedManager.shared.articleSearchModeType = ""
            SharedManager.shared.tabBarIndex = TabbarType.Home.rawValue
            
            //customTabBar.theme_backgroundColor = GlobalPicker.customTabbarBGColor
            //smallBottomView.theme_backgroundColor = GlobalPicker.customTabbarBGColor
            customTabBar.backgroundColor = .white
            smallBottomView.backgroundColor = .white
            NotificationCenter.default.post(name: Notification.Name.notifyArticlesTabBarTapped, object: nil, userInfo: nil)

            break
            
            
        case 2:

            //search
            NotificationCenter.default.post(name: Notification.Name.stopVideoNotification, object: nil, userInfo: nil)
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.searchPageClick, eventDescription: "")
//            SharedManager.shared.articleSearchModeType = "LIST"
            SharedManager.shared.tabBarIndex = TabbarType.Search.rawValue
            //SharedManager.shared.isTabReload = false

            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            //customTabBar.theme_backgroundColor = GlobalPicker.customTabbarBGColor
            //smallBottomView.theme_backgroundColor = GlobalPicker.customTabbarBGColor
            customTabBar.backgroundColor = .white
            smallBottomView.backgroundColor = .white
            
            NotificationCenter.default.post(name: Notification.Name.notifySearchTabBarTapped, object: nil, userInfo: nil)
            break
        case 3:
            
            //Following
            NotificationCenter.default.post(name: Notification.Name.stopVideoNotification, object: nil, userInfo: nil)
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.accountPageClick, eventDescription: "")
//            SharedManager.shared.articleSearchModeType = ""
            SharedManager.shared.tabBarIndex = TabbarType.Following.rawValue
                        
            //SharedManager.shared.isTabReload = false

            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            //customTabBar.theme_backgroundColor = GlobalPicker.customTabbarBGColor
            //smallBottomView.theme_backgroundColor = GlobalPicker.customTabbarBGColor
            customTabBar.backgroundColor = .white
            smallBottomView.backgroundColor = .white
            break
            
        case 4:
            
            //account
            NotificationCenter.default.post(name: Notification.Name.stopVideoNotification, object: nil, userInfo: nil)
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.accountPageClick, eventDescription: "")
//            SharedManager.shared.articleSearchModeType = ""
            SharedManager.shared.tabBarIndex = TabbarType.Profile.rawValue
                        
            //SharedManager.shared.isTabReload = false

            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            //customTabBar.theme_backgroundColor = GlobalPicker.customTabbarBGColor
            //smallBottomView.theme_backgroundColor = GlobalPicker.customTabbarBGColor
            customTabBar.backgroundColor = .white
            smallBottomView.backgroundColor = .white
            break
            
        default:
            break
        }
        
        //Set selected View Controller
        self.selectedIndex = index
                
        if let controller = viewControllers?[index] {
            
            if let navVC = controller as? AppNavigationController {
                
                for viewController in navVC.viewControllers {
                    // some process
                    if viewController.isKind(of: MainTopicSourceVC.self) {
                        viewController.navigationController?.popViewController(animated: false)
                    }
                }
            }
                
//            if let navVC = controller as? AppNavigationController, let vc = navVC.rootViewController as? TopStoriesVC {
//
//                (vc.pageControlVC?.viewControllers?.first as? HomeVC)?.onTabSelected(isTheSame: previousController == controller)
//                //NotificationCenter.default.post(name: Notification.Name.notifyTabbarTapEvent, object: nil, userInfo: nil)
//            }
                        
            if let navVC = controller as? AppNavigationController, let _ = navVC.viewControllers.last as? BulletDetailsVC {
                
                navVC.popToRootViewController(animated: true)
            }
            else if let navVC = controller as? AppNavigationController, let vc = navVC.rootViewController as? TopStoriesVC {
                
                (vc.pageControlVC?.viewControllers?.first as? HomeVC)?.onTabSelected(isTheSame: previousController == controller)
                //NotificationCenter.default.post(name: Notification.Name.notifyTabbarTapEvent, object: nil, userInfo: nil)
            }
//            else if let navVC = controller as? AppNavigationController, let vc = navVC.rootViewController as? CommunityFeedVC {
//
//                vc.onTabSelected(isTheSame: previousController == controller)
//            }
//            else if let navVC = controller as? AppNavigationController, let _ = navVC.rootViewController as? MainDiscoverPageVC {
//                
//                if previousController == controller {
//                    navVC.popToRootViewController(animated: false)
//                }
//            }
            previousController = controller
        }
    }
}

