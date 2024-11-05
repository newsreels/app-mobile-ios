//
//  TopStoriesVC.swift
//  Bullet
//
//  Created by Mahesh on 04/08/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Mute
import SwiftRater
import DataCache

class TopStoriesVC: UIViewController {
    
    //HEADER VIEW PROPERTIES
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGColor: UIView!
    @IBOutlet weak var viewBGTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var circularView: GMView!
    
    
    private var isFirstTimeViewLoaded: Bool = false
    var pageControlVC: PageTabMenuViewController?
    
    var topicsArr = [TopicData]()
    var sourceArr = [ChannelInfo]()
    var authorArr = [Author]()

    override func viewDidLoad() {
        super.viewDidLoad()
                      
        //Design View
        self.loaderView.isHidden = true
        viewBG.clipsToBounds = true
//        if UIDevice.current.hasNotch {
//
//            viewBGTopSpaceConstraint.constant = 0
//            constraintCloseCategoriesBtn.constant = 0
//        } else {
//
//            viewBGTopSpaceConstraint.constant = 20
//            constraintCloseCategoriesBtn.constant = 20
//        }
        viewBGTopSpaceConstraint.constant = 0
//        constraintCloseCategoriesBtn.constant = 0
        
        view.backgroundColor = .white
        viewBGColor.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        
//        self.view.theme_backgroundColor = GlobalPicker.tabBarTintColor
//        viewBGColor.theme_backgroundColor = GlobalPicker.tabBarTintColor //was backgroundColor
//        viewDummyTrail.theme_backgroundColor = GlobalPicker.backgroundColor
        
        //self.imgClose.theme_image = GlobalPicker.subcategoriesCloseBG
        //imgCloseIcon.theme_image = GlobalPicker.subcategoriesClose
        //btnSubCategory.theme_setImage(GlobalPicker.btnSubCategoryImage, forState: .normal)
        
//        viewVolumeContainer.isHidden = false
//        SharedManager.shared.isAudioEnable = false
        
        
        isFirstTimeViewLoaded = false
        setNewsTypes()
              
//        showLoader()
    }
    
//    override func viewDidLayoutSubviews() {
//        view.layoutSkeletonIfNeeded()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setStatusBar()
        
        self.setSubCategoryVisiblity(isHidden: true)
        ANLoader.hide()

//        SharedManager.shared.isShowTopic = false
//        SharedManager.shared.isShowSource = false
        
//        viewVolumeContainer.topColor = MyThemes.current == .dark ? UIColor.black : UIColor.white
//        viewVolumeContainer.bottomColor = MyThemes.current == .dark ? UIColor.black : UIColor.white
//        viewVolumeContainer.shadowColor = MyThemes.current == .dark ? UIColor.black : UIColor.white
        
//        if SharedManager.shared.isAudioEnable {
//
//            btnVolumn.theme_setImage(GlobalPicker.imgVolume, forState: .normal)
//        }
//        else {
//            btnVolumn.theme_setImage(GlobalPicker.imgVolumeMute, forState: .normal)
//        }
        
        if isFirstTimeViewLoaded {
            
            Mute.shared.alwaysNotify = false
            Mute.shared.notify = { [weak self] status in
                
                if SharedManager.shared.deviceVolumeStatus == status {
                    return
                }
                SharedManager.shared.deviceVolumeStatus = status
                SharedManager.shared.isDeviceVolume = true
                DispatchQueue.main.async {
                    
                    if status == true {
                        
    //                    self?.btnVolumn.theme_setImage(GlobalPicker.imgVolumeMute, forState: .normal)
                        SharedManager.shared.isAudioEnable = false
                    }
                    else {
                        
                        SharedManager.shared.isAudioEnable = true
    //                    self?.btnVolumn.theme_setImage(GlobalPicker.imgVolume, forState: .normal)
                    }
                    SharedManager.shared.isVolumeOn = false
                    NotificationCenter.default.post(name: Notification.Name.notifyHomeVolumn, object: nil)
                }
            }
            
            if SharedManager.shared.isTabReload {
                
                //clear cache
                DataCache.instance.cleanAll()

                SharedManager.shared.isTopTabBarCurrentlHidden = false
                (self.pageControlVC?.viewControllers?.first as? HomeVC)?.setTopBarInitialLoad()
                self.setNewsTypes()
            }
        }
        else {
            
            SharedManager.shared.isTabReload = false
        }
        
        self.isFirstTimeViewLoaded = true
                
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyCloseSubCategoryView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapCloseSubCatView(_:)), name: Notification.Name.notifyCloseSubCategoryView, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        
        (self.pageControlVC?.viewControllers?.first as? HomeVC)?.resetCurrentFocussedCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setStatusBar()
        DispatchQueue.main.async {
            if let ptcTBC = self.tabBarController as? PTCardTabBarController {
                ptcTBC.showTabBar(true, animated: true)
            }
            
            (self.pageControlVC?.viewControllers?.first as? HomeVC)?.loadDataForShowSkeleton()
        }
        
    }
    
    func setStatusBar() {
        var navVC = (self.navigationController?.navigationController as? AppNavigationController)
        if navVC == nil {
            navVC = (self.navigationController as? AppNavigationController)
        }
        if navVC?.showDarkStatusBar == false {
            navVC?.showDarkStatusBar = true
            navVC?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
     
    
    @objc func didTapCloseSubCatView(_ notification: NSNotification) {
//
//        UIView.transition(with: viewSubCategory, duration: 0.3, options: .transitionCrossDissolve, animations: {
//
//            self.setSubCategoryVisiblity(isHidden: true)
//        })
    }
    
    func setSubCategoryVisiblity(isHidden: Bool) {
        
        SharedManager.shared.viewSubCategoryIshidden = isHidden
//        self.viewSubCategory.isHidden = isHidden
    }
    
    func showLoader() {
        DispatchQueue.main.async {
            
            self.loaderView.isHidden = false
        }
    }
    
    func hideLoader() {
        
        DispatchQueue.main.async {
            self.loaderView.isHidden = true
        }
    }
    
    func forceRemoveLoader() {
        
        self.loaderView.isHidden = true
    }
    
    func setNewsTypes() {
                
        //NotificationCenter.default.post(name: Notification.Name.notifyToRemoveVCObservers, object: nil)
        SharedManager.shared.bulletPlayer?.pause()
        SharedManager.shared.bulletPlayer?.stop()
        SharedManager.shared.isSubSourceView = false
        
        let setUpHomeCategory = {
            
            //clear cache
            DataCache.instance.cleanAll()
            
            self.children.forEach {
                
                if let pageVC = $0 as? PageTabMenuViewController {
                    pageVC.removeNSNotifications()
                }
                $0.willMove(toParent: nil)
                $0.view.removeFromSuperview()
                $0.removeFromParent()
            }
            
            self.performWSToNewsHome()
        }
        
        if SharedManager.shared.isTabReload {
            SharedManager.shared.isTabReload = false
            setUpHomeCategory()
        }
        else {
            
            //Read cache
            do {
                
                let categories: [MainCategoriesData]? = try DataCache.instance.readCodable(forKey: Constant.CACHE_HOME_CATEGORIES)
                
                if let categories = categories, categories.count > 0 {
                    
                    self.children.forEach {
                        
                        if let pageVC = $0 as? PageTabMenuViewController {
                            pageVC.removeNSNotifications()
                        }
                        $0.willMove(toParent: nil)
                        $0.view.removeFromSuperview()
                        $0.removeFromParent()
                    }
                    
                    SharedManager.shared.reelsCategories = categories
                          
                                        
                    pageControlVC = PageTabMenuViewController(type: .home, isGradientRequired: true)
                    
                    if let pageVC = pageControlVC {
                        pageVC.delegateTabView = self
                        pageVC.view.backgroundColor = .clear
                        pageVC.view.frame = CGRect(x: 0, y: 0, width: viewBG.frame.width, height: viewBG.frame.height)
                        addChild(pageVC)
                        viewBG.addSubview(pageVC.view)
                        pageVC.didMove(toParent: self)
                    }
                    else {

                        SharedManager.shared.showAPIFailureAlert()
                    }
                }
                else {
                    setUpHomeCategory()
                }
                
            } catch {
                
                print("Read error \(error.localizedDescription)")
                setUpHomeCategory()
            }
        }
    }
    
    @IBAction func didTapSubCategory(_ sender: UIButton) {
        
        
        SharedManager.shared.bulletPlayer?.pause()
        
        let userInfo = [ "isPause" : true]
        NotificationCenter.default.post(name: Notification.Name.notifyVideoVolumeStatus, object: nil, userInfo: userInfo)
        
//        imgCloseIcon.transform = CGAffineTransform(rotationAngle: 45)
//        UIView.transition(with: viewSubCategory, duration: 0.3, options: .transitionCrossDissolve, animations: {
//
//            self.setSubCategoryVisiblity(isHidden: false)
//        })
//        UIView.animate(withDuration: 0.3) {
//            self.imgCloseIcon.transform = CGAffineTransform.identity
//        }
        
        let vc = ForYouPreferencesVC.instantiate(fromAppStoryboard: .Reels)
        vc.delegate = self
        vc.currentCategory = SharedManager.shared.curReelsCategoryId
        vc.isOpenFromHome = true
        let nav = AppNavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
        
    }
    
    @IBAction func didTapCloseSubCategory(_ sender: UIButton) {
        
//        UIView.transition(with: viewSubCategory, duration: 0.3, options: .transitionCrossDissolve, animations: {
//
//            self.setSubCategoryVisiblity(isHidden: true)
//        })
//
        let userInfo = [ "isPause" : false]
        NotificationCenter.default.post(name: Notification.Name.notifyVideoVolumeStatus, object: nil, userInfo: userInfo)
        
    }
 
}


//MARK:- WEB SERVICE
extension TopStoriesVC {
    
    func performWSToViewUpdate() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let params = ["view_mode": "EXTENDED",
                      "narration_enabled": SharedManager.shared.isAudioEnable,
                      "narration_mode": SharedManager.shared.showHeadingsOnly,
                      "reading_speed": "1.0", //was \(slider.value)
                      "auto_scroll": 0] as [String : Any]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config/view", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userConfigViewDC.self, from: response)
                
                if let _ = FULLResponse.message {
                    
                    //Success
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config/view", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            //SharedManager.shared.showAPIFailureAlert()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToNewsHome() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let params = ["reader_mode": SharedManager.shared.readerMode]
        
        showLoader()
        WebService.URLResponse("news/home", method: .get, parameters: params, headers: token, withSuccess:{ (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(subCategoriesDC.self, from: response)
                
                //Don't remove this line...its on hold
               // SharedManager.shared.force = FULLResponse.force ?? false
                self.hideLoader()
                
                if let homeData = FULLResponse.data {
                    
                    
                    //write Cache Codable types object
                    do {
                        try DataCache.instance.write(codable: homeData, forKey: Constant.CACHE_HOME_CATEGORIES)
                    } catch {
                        print("Write error \(error.localizedDescription)")
                    }

                    SharedManager.shared.reelsCategories = homeData
                }
                
                //page controller for feed
                self.pageControlVC = PageTabMenuViewController(type: .home, isGradientRequired: true)
                if let pageVC = self.pageControlVC {
                    pageVC.delegateTabView = self
                    pageVC.view.backgroundColor = .clear
                    pageVC.view.frame = CGRect(x: 0,y: 0, width: self.viewBG.frame.width, height: self.viewBG.frame.height)
                    self.addChild(pageVC)
                    self.viewBG.addSubview(pageVC.view)
                    pageVC.didMove(toParent: self)
                }
                else {
                    
                    SharedManager.shared.showAPIFailureAlert()
                }
                
                ANLoader.hide()
                
            } catch let jsonerror {
                
                self.hideLoader()
                
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/home", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            self.hideLoader()
            
            print("error parsing json objects",error)
            let error = error.description
            if error.contains("The request timed out") {
                SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            }
        }
    }
        
}


extension TopStoriesVC: TabViewDelegate {
    func didTapBtnSubCategory() {
        didTapSubCategory(UIButton())
    }
}


extension TopStoriesVC: ForYouPreferencesVCDelegate {
    
    func userChangedCategory() {
        
        //we will save article id and selected index to update list on home screen
       // let subData = self.homeCategoriesArray[indexPath.section].data
        NotificationCenter.default.post(name: Notification.Name.notifyTapSubcategories, object: nil)
    }
    
    
    func userDismissed(vc: ForYouPreferencesVC, selectedPreference: Int, selectedCategory: String) {
        if SharedManager.shared.curArticlesCategoryId != selectedCategory {
            
        }
        else {
            
        }
        
        if SharedManager.shared.isTabReload {
            
            //clear cache
            DataCache.instance.cleanAll()

            SharedManager.shared.isTopTabBarCurrentlHidden = false
            (self.pageControlVC?.viewControllers?.first as? HomeVC)?.setTopBarInitialLoad()
            self.setNewsTypes()
            
        }
        else {
            didTapCloseSubCategory(UIButton())
        }
        
    }
    
}
