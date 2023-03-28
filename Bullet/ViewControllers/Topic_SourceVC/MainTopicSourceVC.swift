//
//  MainTopicSourceVC.swift
//  Bullet
//
//  Created by Mahesh on 04/08/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Mute

//protocol MainTopicSourceVCDelegate: class {
//    func dismissMainTopicSourceVC()
//}

class MainTopicSourceVC: UIViewController {
    
    //LOCALIZABLE LABEL
//    weak var delegateVC: MainTopicSourceVCDelegate?

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGColor: UIView!
    @IBOutlet weak var viewHeader: UIView!
    
    //Navigation Design
    @IBOutlet weak var viewFav: UIView!
    @IBOutlet weak var imgFav: UIImageView!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var viewMore: UIView!
    @IBOutlet weak var imgMore: UIImageView!
    @IBOutlet weak var imgBack: UIImageView!
    
    //SOurce Detail View
    @IBOutlet weak var viewSourceDetail: UIView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblPlacesTitle: UILabel!
    @IBOutlet weak var lblLanguageTitle: UILabel!

    //View List Menu Properties
    private var isFirstTimeViewLoaded: Bool = false
    var stViewMode = ""
    
    var isFollowBtnNeeded = true
    var showArticleType: ArticleType = .home
    var pageControlVC: PageTabMenuViewController?
    
    var isFav = true
    var selectedID = ""
    var subSourcesInfo: sourceInfo?
    var isOpenFromCustomBulletDetails = false
    var isOpenFromDiscoverCustomListVC = false
    
    weak var delegateBulletDetails: BulletDetailsVCLikeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bringSubviewToFront(viewHeader)
        
        //LOCALIZABLE STRING
        lblPlacesTitle.text = NSLocalizedString("PLACES", comment: "")
        lblLanguageTitle.text = NSLocalizedString("LANGUAGE", comment: "")

        //Design View
        //view.theme_backgroundColor = GlobalPicker.tabBarTintColor //viewHeaderTabColor
        //viewHeader.theme_backgroundColor = GlobalPicker.tabBarTintColor
        view.backgroundColor = .black
        viewHeader.backgroundColor = .black
        viewBGColor.theme_backgroundColor = GlobalPicker.backgroundColor
        
        //lblTitle.theme_textColor = GlobalPicker.textColor
        lblTitle.textColor = .white
        imgMore.theme_image = GlobalPicker.navMore
        imgBack.theme_image = GlobalPicker.imgBack

        viewSourceDetail.roundCorners([.allCorners], 12)
        viewSourceDetail.isHidden = true
        lblLocation.theme_textColor = GlobalPicker.textColor
        lblLanguage.theme_textColor = GlobalPicker.textColor
        viewSourceDetail.theme_backgroundColor = GlobalPicker.backgroundListColor
        
        //Header set for source/channels only
        viewMore.isHidden = true
//        SharedManager.shared.isTabReload = false
      //  if SharedManager.shared.isShowSource || SharedManager.shared.isViewArticleSourceNotification {
                
        SharedManager.shared.isSubSourceView = true
        
        if self.showArticleType == .savedArticle {
            lblTitle.text = NSLocalizedString("Favorites Articles", comment: "")
            imgFav.isHidden = true
            btnFav.isHidden = true
        }
        
        else {
            
            if self.showArticleType == .source {
                
                viewMore.isHidden = false
                
                if let sourceInfo  = subSourcesInfo {
                    
                    if let lang = sourceInfo.language {
                        lblLanguage.text = lang.isEmpty ? "N/A" : lang
                    }
                    else  {
                        lblLanguage.text = "N/A"
                    }
                    
                    if let global = sourceInfo.category {
                        
                        lblLocation.text = global.isEmpty ? "N/A" : global
                    }
                    else {
                        lblLocation.text = "N/A"
                    }
                }
            }
            
            imgFav.isHidden = !isFollowBtnNeeded
            btnFav.isHidden = !isFollowBtnNeeded

            if self.showArticleType == .source {
                
                lblTitle.text = SharedManager.shared.subSourcesTitle
                
            }
            else if self.showArticleType == .source {
                lblTitle.text = SharedManager.shared.subSourcesTitle
                ANLoader.hide()
            }
            else if self.showArticleType == .topic {
//                lblTitle.text = SharedManager.shared.subTopicTitle
            }
            else if self.showArticleType == .places {
                
//                lblTitle.text = SharedManager.shared.subTopicTitle
            }
        }

        isFirstTimeViewLoaded = true
        
        //self.imgFav.theme_image = self.isFav ? GlobalPicker.imgBookmarkSelectedWB : GlobalPicker.imgBookmarkTopic
        imgFav.image = self.isFav ? UIImage(named: "tickSelected") : UIImage(named: "plus")
        SharedManager.shared.isLoadWebFromArticles = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
//        SharedManager.shared.isTabReload = true
        SharedManager.shared.isAppLaunchedThroughNotification = false
//        SharedManager.shared.isViewArticleSourceNotification = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        performWSToUserConfig()
        
        Mute.shared.alwaysNotify = false
        Mute.shared.notify = { [weak self] status in
            
            if SharedManager.shared.deviceVolumeStatus == status {
                return
            }
            SharedManager.shared.deviceVolumeStatus = status
            SharedManager.shared.isDeviceVolume = true
            DispatchQueue.main.async {
                
                if status == true {
                    
                    SharedManager.shared.isAudioEnable = false
                }
                else {
                    
                    SharedManager.shared.isAudioEnable = true
                }
                SharedManager.shared.isVolumeOn = false
                NotificationCenter.default.post(name: Notification.Name.notifyHomeVolumn, object: nil)
            }
        }

        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyUpdateFollowIcon, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapUpdateFollowIcon(notification:)), name: Notification.Name.notifyUpdateFollowIcon, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return MyThemes.current == .dark ? .lightContent : .darkContent
        } else {
            // Fallback on earlier versions
            return MyThemes.current == .dark ? .lightContent : .default
        }
    }
 
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
            }
        }
    }
    
    @objc func didTapUpdateFollowIcon( notification: NSNotification) {
     
        if SharedManager.shared.isFav {
            
            //self.imgFav.theme_image = GlobalPicker.imgBookmarkSelectedWB
            imgFav.image = UIImage(named: "tickSelected")
        }
        else {
            
            //self.imgFav.theme_image = GlobalPicker.imgBookmarkTopic
            imgFav.image = UIImage(named: "plus")
        }
    }
    
    @IBAction func didTapSourceDetailsClose(_ sender: UIButton) {
        
        viewSourceDetail.isHidden = true
    }
    
    @IBAction func didTapSourceDetails(_ sender: UIButton) {
        
        viewSourceDetail.isHidden = false
    }
    
    @IBAction func didTapAddToFav(_ sender:Any) {
        
        SharedManager.shared.isTabReload = true
        SharedManager.shared.isDiscoverTabReload = true
        if self.showArticleType == .source {
            
            if self.isFav {
                self.performUnFollowUserSource(id: self.selectedID, isFav: false)
            }
            else {
                
                self.performWSTofollowedSource(id: self.selectedID, isFav: true)
            }
        }
        else if self.showArticleType == .topic {
            
            if self.isFav {
                self.performTabUserTopicUnfollow(id: self.selectedID, isFav: false)
            }
            else {
                
                self.performWSToFollowedTopics(id: self.selectedID, isFav: true)
            }
        }
        
        else if self.showArticleType == .places {
            
            if self.isFav {
                
                self.performWSToUpdateUserLocation(id: self.selectedID, isFav: false)
            }
            else {
                
                self.performWSToUpdateUserLocation(id: self.selectedID, isFav: true)
            }
        }
    }
    
    @IBAction func didTapBackAction(_ sender: Any) {
           
        if self.showArticleType != .savedArticle {
            
            NotificationCenter.default.post(name: Notification.Name.notifyPauseAudio, object: nil)
        }
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(true, animated: true)
        }
        
//        SharedManager.shared.isViewArticleSourceNotification = false
        SharedManager.shared.isSubSourceView = false
//        SharedManager.shared.isSavedArticle = false
        
//        //CHECK USER COMES FROM TOPIC TO SOURCE VIEW
//        if SharedManager.shared.isFromTopic && !SharedManager.shared.isShowTopic {
//
//            SharedManager.shared.isShowSource = false
//            SharedManager.shared.isShowTopic = true
//        }
//        else {
//
//            //RESET VARIABLE OF TOPIC
//            SharedManager.shared.isFromTopic = false
//
//            SharedManager.shared.isShowTopic = false
//            SharedManager.shared.isShowSource = false
//        }

        SharedManager.shared.isAppLaunchedThroughNotification = false
//        SharedManager.shared.bulletPlayer?.stop()
//        SharedManager.shared.bulletPlayer?.currentTime = 0
//        self.delegateVC?.dismissMainTopicSourceVC()
        if isOpenFromCustomBulletDetails || isOpenFromDiscoverCustomListVC {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK:- WEB SERVICE

extension MainTopicSourceVC {
    
    func performWSToUserConfig() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
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
//                        self.stViewMode = mode.uppercased()
//                        SharedManager.shared.menuViewModeType = self.stViewMode
//                    }
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
                
                if self.isFirstTimeViewLoaded {
                    
                    //DispatchQueue.main.async {
                    
                    self.pageControlVC = PageTabMenuViewController(type: self.showArticleType, isGradientRequired: false)
                    if let pageVC = self.pageControlVC {
                        pageVC.delegateBulletDetails = self.delegateBulletDetails
                        pageVC.view.backgroundColor = .clear
                        pageVC.view.frame = CGRect(x: 0,y: 0, width: self.viewBG.frame.width, height: self.viewBG.frame.height)
                        self.addChild(pageVC)
                        self.viewBG.addSubview(pageVC.view)
                        pageVC.didMove(toParent: self)
                    }
                    //                    }
                }
                self.isFirstTimeViewLoaded = false
                
            } catch let jsonerror {
                
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
                
            }
            
        }) { (error) in
            
            //SharedManager.shared.showAPIFailureAlert()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToFollowedTopics(id:String, isFav: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let params = ["topics": "\(id)"]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse("news/topics/follow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateTopicDC.self, from: response)
            
                if FULLResponse.message?.uppercased() == Constant.STATUS_SUCCESS {
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    self.isFav = isFav
                    //self.imgFav.theme_image = isFav ? GlobalPicker.imgBookmarkSelectedWB : GlobalPicker.imgBookmarkTopic
                    self.imgFav.image = self.isFav ? UIImage(named: "tickSelected") : UIImage(named: "plus")
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/topics/follow", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performTabUserTopicUnfollow(id:String, isFav: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["topics": "\(id)"]
        
        ANLoader.showLoading(disableUI: true)
        
        WebService.URLResponse("news/topics/unfollow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(DeleteTopicDC.self, from: response)
                
                if let status = FULLResponse.message {
                    
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    let message = status
                    if status.uppercased() == Constant.STATUS_SUCCESS {
                        
                        self.isFav = isFav
                        //self.imgFav.theme_image = isFav ? GlobalPicker.imgBookmarkSelectedWB : GlobalPicker.imgBookmarkTopic
                        self.imgFav.image = self.isFav ? UIImage(named: "tickSelected") : UIImage(named: "plus")
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: message)
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/topics/unfollow", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSTofollowedSource(id:String, isFav: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        let params = ["sources": "\(id)"]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse("news/sources/follow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateSourceDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    
                    SharedManager.shared.isDiscoverTabReload = true
                    SharedManager.shared.isTabReload = true
                    self.isFav = isFav
                    //self.imgFav.theme_image = isFav ? GlobalPicker.imgBookmarkSelectedWB : GlobalPicker.imgBookmarkTopic
                    self.imgFav.image = self.isFav ? UIImage(named: "tickSelected") : UIImage(named: "plus")
                }
            
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/follow", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performUnFollowUserSource(id:String, isFav: Bool) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedSource, channel_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        
        ANLoader.showLoading(disableUI: true)
        WebService.URLResponse("news/sources/unfollow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    if status == Constant.STATUS_SUCCESS {
                        
                        SharedManager.shared.isDiscoverTabReload = true
                        SharedManager.shared.isTabReload = true
                        //print("Deleted SOURCE SUCCESSFULLY...")
                        self.isFav = isFav
                        //self.imgFav.theme_image = isFav ? GlobalPicker.imgBookmarkSelectedWB : GlobalPicker.imgBookmarkTopic
                        self.imgFav.image = self.isFav ? UIImage(named: "tickSelected") : UIImage(named: "plus")
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/unfollow", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
}

//MARK:- Saved Location APIs
extension MainTopicSourceVC {
    
    func performWSToUpdateUserLocation(id:String, isFav: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
      
        ANLoader.showLoading()
        let params = ["locations":id]
        let url = isFav ? "news/locations/follow" : "news/locations/unfollow"
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateSourceDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    self.isFav = isFav
                    //self.imgFav.theme_image = isFav ? GlobalPicker.imgBookmarkSelectedWB : GlobalPicker.imgBookmarkTopic
                    self.imgFav.image = self.isFav ? UIImage(named: "tickSelected") : UIImage(named: "plus")
                }
                ANLoader.hide()
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
      
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}
