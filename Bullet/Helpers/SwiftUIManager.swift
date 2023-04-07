//
//  SwiftUIManager.swift
//  Bullet
//
//  Created by Yeshua Lagac on 8/7/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let SwiftUIGoToOnboarding = Notification.Name("SwiftUIGoToOnboarding")
    static let SwiftUIGoToArticles = Notification.Name("SwiftUIGoToArticles")
    static let SwiftUIGoToRegister = Notification.Name("SwiftUIGoToRegister")
    static let SwfitUIGoToFontSize = Notification.Name("SwiftUIGoToFontSize")
    static let SwfitUIGoToFavArticles = Notification.Name("SwiftUIGoToFavArticles")
    static let SwiftUIGoToBlockList = Notification.Name("SwiftUIGoToBlockList")
    static let SwiftUIGoToChangePassword = Notification.Name("SwiftUIGoToChangePassword")
    static let SwiftUIGoToArticleTopic = Notification.Name("SwiftUIGoToArticleTopic")
    static let SwiftUIGoToChannelData = Notification.Name("SwiftUIGoToChannelData")
    static let SwiftUIDidChangeLanguage = Notification.Name("SwiftUIDidChangeLanguage")
    static let SwiftUIGoToReelsDetails = Notification.Name("SwiftUIGoToReelsDetails")

}



class SwiftUIManager {
    
    static let shared = SwiftUIManager()
    var navigationController: UINavigationController?

    
    func setObserver(name: Notification.Name, object: Any?) {
        NotificationCenter.default.post(name: name, object: object)
    }
    
    func addObservers() {
        
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToArticles(notif:)), name: .SwiftUIGoToArticles, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToRegister), name: .SwiftUIGoToRegister, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToFontSize), name: .SwfitUIGoToFontSize, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToBlockList), name: .SwiftUIGoToBlockList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToFavList), name: .SwfitUIGoToFavArticles, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToChangePassword), name: .SwiftUIGoToChangePassword, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToArticleByTopic(notif:)), name: .SwiftUIGoToArticleTopic, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeLanguage), name: .SwiftUIDidChangeLanguage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToSpecificReels(notif:)), name: .SwiftUIGoToReelsDetails, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToChannelPage(notif:)), name: .SwiftUIGoToChannelData, object: nil)

    }
    
    @objc func goToSpecificReels(notif: Notification) {
        if let reel = notif.object
            as? [String: Any], let reels = reel["reels"] as? [Reel], let index = reel["index"] as? Int {
                                                
            let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
            vc.isBackButtonNeeded = true
            vc.modalPresentationStyle = .overFullScreen
            vc.reelsArray = reels
             
            vc.isFromDiscover = true
//            vc.authorID = reel.authors?.first?.id ?? ""
            vc.scrollToItemFirstTime = true
            vc.userSelectedIndexPath = IndexPath(row: index, section: 0)
//            let navVC = AppNavigationController(rootViewController: vc)
//            navVC.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }
    
    @objc func didChangeLanguage() {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
//        if userToken as! String == "" {
//            let vc = OnboardingNewVC.instantiate(fromAppStoryboard: .OnboardingSB)
//            let viewController = AppNavigationController(rootViewController: vc)
//            viewController.navigationBar.isHidden = true
//            appDelegate.window?.rootViewController = self.navigationController
//        }
//        else {
//            let vc = TabbarVC.instantiate(fromAppStoryboard: .Main)
//            let viewController = AppNavigationController.init(rootViewController: vc)
//            viewController.navigationBar.isHidden = true
//            appDelegate.window?.rootViewController = self.navigationController
//        }
//        
//        
//        // Reset the selected articles
//        SharedManager.shared.curReelsCategoryId = ""
//        SharedManager.shared.curArticlesCategoryId = ""
    }
    
    @objc func goToArticleByTopic(notif: Notification) {
        if let topic = notif.object as? TopicData {
//            SharedManager.shared.curArticlesCategoryId = contentID
            let vc = ArticlesVC.instantiate(fromAppStoryboard: .Main)
            vc.fromDiscover = true
            vc.contextID = topic.context
            vc.topicData = topic
            vc.categoryTitleString = topic.name ?? ""
            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            navVC.modalTransitionStyle = .crossDissolve
            self.navigationController?.pushViewController(vc, animated: true)
        }

//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
//               tabBarController.selectedIndex = 0
//           }
    }
    
    @objc func goToChannelPage(notif: Notification) {
        
        if let source = notif.object as? ChannelInfo {
             let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
            detailsVC.isOpenFromReel = true
            detailsVC.isOpenForTopics = false
            detailsVC.fromDiscover = true
            detailsVC.channelInfo = source
            self.navigationController?.pushViewController(detailsVC  , animated: true)
        }
        
    }
    
    @objc func goToChangePassword() {
        let vc = ChangePasswordVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
//            self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)

    }
    @objc func goToFavList() {
        let vc = DraftSavedArticlesVC.instantiate(fromAppStoryboard: .Schedule)
        vc.isFromSaveArticles = true
//            let nav = AppNavigationController(rootViewController: vc)
//            if MyThemes.current == .light {
//                nav.showDarkStatusBar = true
//            }
//            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: true, completion: nil)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func goToBlockList() {
        let vc = blockListVC.instantiate(fromAppStoryboard: .registration)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToFontSize(notif: Notification) {
        let vc = TextSizeVC.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToArticles(notif: Notification) {
        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.selectedArticleData = notif.object as! articlesData
//        vc.delegate = self
//        vc.delegateVC = self
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalTransitionStyle = .crossDissolve
//        self.present(navVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @objc func goToRegister() {
        let vc = RegistrationNewVC.instantiate(fromAppStoryboard: .RegistrationSB)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navVC, animated: true, completion: nil)
    }
    
}
