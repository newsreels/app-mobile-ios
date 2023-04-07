//
//  TabbarVC.swift
//  Bullet
//
//  Created by Mahesh on 08/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Reachability
import SwiftUI
import SwiftAutoLayout
import OneSignal
import Firebase

class TabbarVC: PTCardTabBarController {
    
    var reachability: Reachability?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var reelsTab: ReelsContainerVC?
    var homeTab: ArticlesVC?
    var discoverTab: DiscoverVC?
    var profileTab: SettingsVC?
    var followingTab: FollowingViewController?
    
    override func viewDidLoad() {
        
        self.tabBar.isHidden = true
        self.view.theme_backgroundColor = GlobalPicker.tabBarTintColor
        
        homeTab = ArticlesVC.instantiate(fromAppStoryboard: .Main)
        
        discoverTab = DiscoverVC.instantiate(fromAppStoryboard: .Discover)
        
//        vc3 = ReelsVC.instantiate(fromAppStoryboard: .Reels)
        reelsTab = ReelsContainerVC.instantiate(fromAppStoryboard: .Reels)
        
        
//        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
//        detailsVC.isOpenFromReel = false
//        detailsVC.channelInfo = nil
//        detailsVC.isShowingMenuProfile = true
        
        profileTab = SettingsVC.instantiate(fromAppStoryboard: .Profile)
//        let vc5 = CommunityFeedVC.instantiate(fromAppStoryboard: .Schedule)
        
        followingTab = FollowingViewController.instantiate(fromAppStoryboard: .FollowingSB)
        
        
        let nav1 = AppNavigationController(rootViewController: homeTab!)
        //nav1.navigationBar.isHidden = true
        
        let nav2 = UINavigationController(rootViewController: discoverTab!)
        nav2.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        nav2.navigationBar.shadowImage = UIImage()
        nav2.navigationBar.isTranslucent = true
        nav2.view.backgroundColor = .clear
        nav2.navigationBar.topItem?.title = "Following"
        nav2.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .heavy), NSAttributedString.Key.foregroundColor: UIColor.black]
        nav2.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .heavy), NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let nav3 = AppNavigationController(rootViewController: reelsTab!)
        //nav3.navigationBar.isHidden = true
        
        let nav4 = AppNavigationController(rootViewController: profileTab!)
        
        let nav5 = CustomNavigationController(rootViewController: followingTab!)
        nav5.titleString = "Following"
//        nav5.title = "Following"
        
        //AppNavigationController(rootViewController: followingTab!)
        //nav4.navigationBar.isHidden = true

//        let nav5 = AppNavigationController(rootViewController: vc5)

        nav1.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "icn_home_gray"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "ReelsIcon"), tag: 2)
//        nav5.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "icn_search_gray"), tag: 3)
        nav2.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "icn_search_gray"), tag: 3)
        nav4.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "icn_profile_gray"), tag: 4)
        nav5.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "icn_profile_gray"), tag: 5)
        
        // initaial tab bar index
        self.viewControllers = [nav3, nav1, BaseNavigationController(rootViewController: BaseHostingController(rootView: DiscoverMain().navigationBarHidden(true))), nav5,  BaseNavigationController(rootViewController: BaseHostingController(rootView: SettingsMainview().navigationBarHidden(true)))]
//        self.viewControllers = [nav3, nav1, nav2, nav5,  nav4]

        
        //Taps on Recived push notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.notifyGetPushNotificationArticleData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getArticleDataPayLoad(_:)), name: NSNotification.Name.notifyGetPushNotificationArticleData, object: nil)
        SharedManager.shared.isAppOpenFromDeepLink = true
        
        SwiftUIManager.shared.navigationController = self.navigationController
        SwiftUIManager.shared.addObservers()
        
        checkInternetConnection()

        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                
                let externalUserId = result.token // You will supply the external user id to the OneSignal SDK
                OneSignal.setExternalUserId(externalUserId)                
            }
        })

        super.viewDidLoad()
    }
    
//
//    override open var shouldAutorotate : Bool {
//
//        return false
//
//    }
//
//    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
//
//        return [.portrait]
//    }
    
    //Check Internet
    func checkInternetConnection() {
        
        do {
            reachability = try Reachability()
        } catch {
            print("reachability init failed")
        }
        
        guard let reachabilitySwift = reachability  else {
            return
        }
        
        reachabilitySwift.whenReachable = { reachability in
            
 
            self.performWSToUserConfig()
        }
        
        reachabilitySwift.whenUnreachable = { _ in
            
            print("reachability Not reachable")
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
        }
        
        do {
            try reachabilitySwift.startNotifier()
        } catch {
            print("reachability Unable to start notifier")
        }
    }
    
    @objc func getArticleDataPayLoad(_ notification: Notification) {
        
        if SharedManager.shared.articleIdNotification != "" {
            self.performWSViewArticle(SharedManager.shared.articleIdNotification)
            SharedManager.shared.articleIdNotification = ""
        }
        else if SharedManager.shared.reelsContextNotification != "" {
//            SharedManager.shared.isAppLaunchedThroughNotification = false
//            self.openReels(context: SharedManager.shared.reelsContextNotification)
//            SharedManager.shared.reelsContextNotification = ""
            if SharedManager.shared.tabBarIndex != 0 {
                SharedManager.shared.tabBarIndex = 0
                SharedManager.shared.isFromPNBackground = true
                self.customTabBar.select(at: 0)
//                NotificationCenter.default.post(name: Notification.Name.notifyGetPushNotificationToReelsView, object: nil, userInfo: nil)
            }

        }
    }
    
    func performWSToUserConfig() {

        if !(SharedManager.shared.isConnectedToNetwork()){

            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

//        self.activityIndicator.startAnimating()
//        self.activityIndicator.isHidden = false
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config", method: .get, parameters: nil, headers: token, withSuccess: { (response) in

            
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userConfigDC.self, from: response)

                if let ads = FULLResponse.ads {

                    UserDefaults.standard.set(ads.enabled, forKey: Constant.UD_adsAvailable)
                    UserDefaults.standard.set(ads.ad_unit_key, forKey: Constant.UD_adsUnitKey)
                    UserDefaults.standard.set(ads.type, forKey: Constant.UD_adsType)
                    SharedManager.shared.adsInterval = ads.interval ?? 10

                    if ads.type?.uppercased() == "FACEBOOK" {

                        UserDefaults.standard.set(ads.facebook?.feed, forKey: Constant.UD_adsUnitFeedKey)
                        UserDefaults.standard.set(ads.facebook?.reel, forKey: Constant.UD_adsUnitReelKey)
                    } else {

                        UserDefaults.standard.set(ads.admob?.feed, forKey: Constant.UD_adsUnitFeedKey)
                        UserDefaults.standard.set(ads.admob?.reel, forKey: Constant.UD_adsUnitReelKey)
                    }

                }
                
                if let walletLink = FULLResponse.wallet {
                    
                    UserDefaults.standard.set(walletLink, forKey: Constant.UD_WalletLink)
                }


                //For Community Guildelines
                if let terms = FULLResponse.terms {
                    SharedManager.shared.community = terms.community ?? true
                }

                if let preference = FULLResponse.home_preference {

                    SharedManager.shared.isTutorialDone = preference.tutorial_done ?? false
                    SharedManager.shared.bulletsAutoPlay = preference.bullets_autoplay ?? false
                    SharedManager.shared.reelsAutoPlay = preference.reels_autoplay ?? false
                    SharedManager.shared.videoAutoPlay = preference.videos_autoplay ?? false
                    SharedManager.shared.readerMode = preference.reader_mode ?? false
                    SharedManager.shared.speedRate = preference.narration?.speed_rate ?? ["1.0x":1]

//                    if let mode = preference.view_mode {
//
//                        SharedManager.shared.menuViewModeType = mode.uppercased()
//                        self.updateViewTypeIcon()
//                    }
                }

                if let user = FULLResponse.user {
                    SharedManager.shared.userId = user.id ?? ""

                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(user) {
                        SharedManager.shared.userDetails = encoded
                    }

                    SharedManager.shared.isLinkedUser = user.guestValid ?? false
                    
                    if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                        userDefaults.set(user.first_name as AnyObject, forKey: "first_name")
                        userDefaults.synchronize()
                    }
                }

                if let rating = FULLResponse.rating {
                    
                    let interval = rating.interval ?? 100
                    let nextInt = rating.next_interval ?? 100
                    
                    if interval > SharedManager.shared.appUsageCount ?? 0 {
                        UserDefaults.standard.setValue(interval, forKey: Constant.ratingTimeIntervel)
                    }
                    else {
                        UserDefaults.standard.setValue(nextInt, forKey: Constant.ratingTimeIntervel)
                    }
                }

                if let alert = FULLResponse.alert {

                    SharedManager.shared.userAlert = alert
                }
                
                
                if let onboarded = FULLResponse.onboarded {
                    
                    SharedManager.shared.isFromTabbarVC = true
                    SharedManager.shared.isOnboardingPreferenceLoaded = onboarded
                }

//                self.activityIndicator.stopAnimating()
//                self.activityIndicator.isHidden = true

            } catch let jsonerror {

//                self.activityIndicator.stopAnimating()
//                self.activityIndicator.isHidden = true
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
            }

        }) { (error) in

            //SharedManager.shared.showAPIFailureAlert()
            DispatchQueue.main.async {
//                self.activityIndicator.stopAnimating()
//                self.activityIndicator.isHidden = true
                print("error parsing json objects",error)
            }
        }
    }
    
    func performWSViewArticle(_ id: String) {
        
        //        SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/articles/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(viewArticleDC.self, from: response)
                
                if let article = FULLResponse.article {
                    
                    //                    SharedManager.shared.isViewArticleSourceNotification = true
                    //                    SharedManager.shared.viewArticleArray = [article]
                    
                    //                    if let source = article.source {
                                        
                    //self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                    if let vc = UIApplication.getTopViewController() as? BulletDetailsVC, vc.selectedArticleData?.id == article.id {
                        print("same article already presented no need to dismiss")
                    } else {
                        
//                        if let vc = UIApplication.getTopViewController() as? TestTransitionVC  {
//                            vc.dismiss(animated: true, completion: nil)
//                        }
//                        else {
//
//
//                        }
                        
                        NotificationCenter.default.post(name: Notification.Name.notifyProfileVC, object: nil)
                        self.appDelegate.window!.rootViewController?.dismiss(animated: false, completion: nil)
                        
                        let isViewpresent = UIApplication.getTopViewController()
                            
                            if let vc = UIApplication.getTopViewController() as? BulletDetailsVC {
                                
                                vc.dismiss(animated: false, completion: nil)
                            }else if (isViewpresent != nil) {
                                isViewpresent?.dismiss(animated: false, completion: nil)
                            }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
                            vc.selectedArticleData = article
                            let navVC = AppNavigationController(rootViewController: vc)
                            //navVC.navigationBar.isHidden = true
                            navVC.modalTransitionStyle = .crossDissolve
                            navVC.modalPresentationStyle = .fullScreen
                            
                            if SharedManager.shared.tabBarIndex == TabbarType.Reels.rawValue {
//                                self.vc3?.present(navVC, animated: true, completion: nil)
                                if let vc = UIApplication.getTopViewController() {
                                    vc.present(navVC, animated: true, completion: nil)
                                }
                            }else if SharedManager.shared.tabBarIndex == TabbarType.Home.rawValue {
                                if let vc = UIApplication.getTopViewController() {
                                    vc.present(navVC, animated: true, completion: nil)
                                }
                            }
                            else {
                                if let vc = UIApplication.getTopViewController(){
                                    vc.present(navVC, animated: true, completion: nil)
                                }
                            }
                            
//                            let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
//                            vc.delegateVC = self
//                            vc.selectedID = source.id ?? ""
//                            vc.isFav = source.favorite ?? false
//                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
//                     }
                }
                else {
                    
                    ANLoader.hide()
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                
            } catch let jsonerror {
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/articles/\(id)", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func openReels(context: String) {
        self.appDelegate.window!.rootViewController?.dismiss(animated: false, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { //Add delay to play the reels when app is in background
            
            NotificationCenter.default.post(name: Notification.Name.notifyProfileVC, object: nil)
            
            if let vc = UIApplication.getTopViewController() as? BulletDetailsVC {
                
                vc.dismiss(animated: false, completion: nil)
            }
            
            let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
            vc.contextID = context
//            vc.titleText = content?.title ?? ""
            vc.isBackButtonNeeded = true
//            vc.delegate = self
//            vc.fromMain = true
            vc.fromMain = false //SharedManager.shared.isAppOpenFromDeepLink ? false : true // set flase to play specific shared/copy reels
            vc.modalPresentationStyle = .fullScreen
            let nav = AppNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            
            
            if SharedManager.shared.tabBarIndex == TabbarType.Reels.rawValue {
                self.reelsTab?.dismiss(animated: false, completion: {
                    self.reelsTab?.present(nav, animated: true, completion: nil)
                })
            }
            else if SharedManager.shared.tabBarIndex == TabbarType.Home.rawValue {
                self.homeTab?.dismiss(animated: false, completion: {
                    self.reelsTab?.present(nav, animated: true, completion: nil)
                })
            }
            else if SharedManager.shared.tabBarIndex == TabbarType.Search.rawValue {
                self.discoverTab?.dismiss(animated: false, completion: {
                    self.reelsTab?.present(nav, animated: true, completion: nil)
                })
            }
            else if SharedManager.shared.tabBarIndex == TabbarType.Profile.rawValue {
                self.profileTab?.dismiss(animated: false, completion: {
                    self.reelsTab?.present(nav, animated: true, completion: nil)
                })
            }
            else {
                
                let nav = AppNavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                if let vc = UIApplication.getTopViewController(){
                    vc.dismiss(animated: false, completion: {
                        if let vc2 = UIApplication.getTopViewController(){
                            vc2.present(nav, animated: true, completion: nil)
                        }
                    })
                }
               // self.present(nav, animated: true, completion: nil)
            }
        }
    }
}

//MARK:- WEBVIEW DISMISS
//extension TabbarVC: MainTopicSourceVCDelegate {
//
//    func dismissMainTopicSourceVC() {
//
//        //Open article from Widget and come back to Home screen, then delegate tells to start from top of list
//        if let nav = viewControllers?.first as? AppNavigationController, let vc = nav.viewControllers.first as? TopStoriesVC {
//
//            if (vc.pageControlVC?.viewControllers?.first as? HomeVC)?.tblExtendedView.contentOffset == CGPoint.zero {
//                (vc.pageControlVC?.viewControllers?.first as? HomeVC)?.tblExtendedView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
//            }
//            else {
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//
//                    (vc.pageControlVC?.viewControllers?.first as? HomeVC)?.tblExtendedView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
//                })
//            }
//            //print("dismissMainTopicSourceVC called....")
//        }
//    }
//}

