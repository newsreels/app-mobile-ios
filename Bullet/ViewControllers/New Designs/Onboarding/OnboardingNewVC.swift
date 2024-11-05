//
//  OnboardingNewVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 03/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AuthenticationServices
import GoogleSignIn
import Combine
import Heimdallr
import NVActivityIndicatorView
import DataCache
import SwiftUI

class OnboardingNewVC: UIViewController {

    @IBOutlet weak var langButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var continueButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueLoader: NVActivityIndicatorView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //    var pageVC: OnboardingPageVC?
    var selectedIndex = 2
    //SharedManager.shared.isAppOnboardScreensLoaded ? 2 : 0
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var animationNeeded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
        // Loading from appdelegate directly so animation not needed
        
        titleLabel.text = NSLocalizedString("The world at your", comment: "")
        if selectedIndex == 2 {
            animationNeeded = false
        }
        else {
            animationNeeded = true
        }
        
        if let hasSelectedLanguage = UserDefaults.standard.object(forKey: Constant.UD_new_has_selected_language) as? Bool {
            if !hasSelectedLanguage {
                self.presentSwiftUILanguageSelector()
            }
        } else {
            self.presentSwiftUILanguageSelector()
        }
         
    }
    
    private func presentSwiftUILanguageSelector() {
        let swiftUIController = UIHostingController(rootView: LanguageOnboardingView(dismiss: {
            self.appDelegate?.setOnBoardVC()
        }))
        swiftUIController.modalPresentationStyle = .fullScreen
        present(swiftUIController, animated: false)
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? OnboardingPageVC {
            pageVC = vc
            pageVC?.selectedIndex = selectedIndex
            pageVC?.delegatePage = self
        }
        
    }
*/
    
    // MARK: - Methods
    
    func setupUI() {
        
        loadCurrentLanguage()
//        nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
//        continueButton.transform = CGAffineTransform(scaleX: 1, y: 1)
//        continueButton.setTitle(NSLocalizedString("Skip", comment: ""), for: .normal)
        continueButtonHeightConstraint.constant = 48
//        continueButton.layer.borderWidth = 1
//        continueButton.layer.borderColor = UIColor.white.cgColor//Constant.appColor.lightRed.cgColor
        langButton.layer.borderWidth = 1
        langButton.layer.borderColor = UIColor.white.cgColor//Constant.appColor.lightRed.cgColor
        
        nextButton.backgroundColor = Constant.appColor.lightRed
        
        continueButton.backgroundColor = UIColor.white
        continueButton.setTitleColor(UIColor.black, for: .normal)
        
        if selectedIndex == 2 {
            self.continueButtonHeightConstraint.constant = 48
            if animationNeeded {
                UIView.animate(withDuration: 0.5) {
                    self.continueButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.view.layoutIfNeeded()
                }
            }
            else {
                self.continueButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.view.layoutIfNeeded()
            }
            
            nextButton.setTitle(NSLocalizedString("Register or Log in", comment: ""), for: .normal)
            continueButton.setTitle(NSLocalizedString("Continue as a Guest", comment: ""), for: .normal)
        }

        
    }

    func loadCurrentLanguage() {
        if let selectedLang = UserDefaults.standard.string(forKey: Constant.UD_appLanguageName) {
            langButton.setTitle(selectedLang.capitalized, for: .normal)
        }
    }
    
    
    func showLoader(button: UIButton) {
        
        DispatchQueue.main.async {
            
            self.view.bringSubviewToFront(button)
            self.blurView.alpha = 0.4
            button.titleLabel?.removeFromSuperview()
            
            if button == self.continueButton {
                self.continueLoader.startAnimating()
                self.view.bringSubviewToFront(self.continueLoader)
            }
            
        }
        
        
    }
    
    func hideloader() {
        
        DispatchQueue.main.async {
            self.continueLoader.stopAnimating()
            
            self.blurView.alpha = 0
            self.view.bringSubviewToFront(self.blurView)

            self.continueButton.addSubview(self.continueButton.titleLabel ?? UILabel())
        }
        
        
    }
    
    
    // MARK: - Actions
    @IBAction func didTapNext(_ sender: Any) {
        
        if selectedIndex == 2 {
            SharedManager.shared.isAppOnboardScreensLoaded = true
            
            let vc = RegistrationNewVC.instantiate(fromAppStoryboard: .RegistrationSB)
            let navVC = UINavigationController(rootViewController: vc)
            self.navigationController?.present(navVC, animated: true, completion: nil)
            
        }
        else {
            if selectedIndex < 2 {
                selectedIndex += 1
            }
            
//            pageVC?.setViewControllerAtIndex(index: selectedIndex, isAnimated: true)
            setupUI()
        }
        
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        if selectedIndex == 2 {
            SharedManager.shared.isAppOnboardScreensLoaded = true
            
            let deviceID =  UIDevice.current.identifierForVendor?.uuidString ?? ""
            self.doAuthRegistration(deviceID, loginType: .Guest)
        }
        else {
            selectedIndex = 2
//            pageVC?.setViewControllerAtIndex(index: selectedIndex, isAnimated: true)
            setupUI()
        }
    }
    
    @IBAction func didTapLanguage(_ sender: Any) {
        
//        let vc = SelectLanguageVC.instantiate(fromAppStoryboard: .OnboardingSB)
//        vc.modalPresentationStyle = .overCurrentContext
//        vc.modalTransitionStyle = .crossDissolve
//        vc.delegate = self
//        self.navigationController?.present(vc, animated: true, completion: nil)
//        
        
        self.presentSwiftUILanguageSelector()
    }
    
    
}


extension OnboardingNewVC: OnboardingPageVCDelegate {
    
    func didChangePage() {
        
//        selectedIndex = pageVC?.selectedIndex ?? 0
        setupUI()
    }
}

extension OnboardingNewVC: SelectLanguageVCDelegate {
    
    func didSaveLanguage() {
        
//        loadCurrentLanguage()
        self.appDelegate?.setOnBoardVC()
        
    }
}


extension OnboardingNewVC {
    
    func doAuthRegistration(_ subjectToken: String, loginType: LoginType) {
        // only Guest login here
        self.showLoader(button: self.continueButton)
        
        let tokenURL = URL(string: WebserviceManager.shared.AUTH_TOKEN_URL)!
        let useCredentials = OAuthClientCredentials(id: WebserviceManager.shared.APP_CLIENT_ID, secret: WebserviceManager.shared.APP_CLIENT_SECRET)
        let heimdall = Heimdallr(tokenURL: tokenURL, credentials: useCredentials)
        
        var parameters = [String : String]()
        var grantType = ""
        
        parameters["language"] = SharedManager.shared.languageId
        if loginType == .Guest {
            
            grantType = "device_code"
            parameters["device_code"] = subjectToken
            SharedManager.shared.isGuestUser = true
        }

//        let oauthparams = OAuthAuthorizationGrant.extension("token_exchange", parameters)
//        oauthparams["scope"] = "offline_access"
//        oauthparams["audience"] = Constant.authAudienceURL
        
        heimdall.requestAccessToken(grantType: grantType, parameters: parameters) { result in
            
            switch result {
            case .success():
                
                DispatchQueue.main.async {
                    
                    if heimdall.hasAccessToken {
                        
                        guard let accessToken = heimdall.accessToken?.accessToken else {
                            
                            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Access token missing.", comment: ""))
                            self.hideloader()
                            return
                        }
                        print("accessToken: ", accessToken)
                        if let refreshToken = heimdall.accessToken?.refreshToken {
                            
                            UserDefaults.standard.set(refreshToken, forKey: Constant.UD_refreshToken)
                            if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                                
                                userDefaults.set(refreshToken as AnyObject, forKey: "WRefreshToken")
                                userDefaults.synchronize()
                            }
                        }
                        self.uploadTheToken(accessToken: accessToken, userEmail: "", loginType: loginType)
                    }
                }
                
            case .failure(let error):
                
                self.hideloader()
                let errorAlert = error.localizedDescription
                print("failure: \(errorAlert)")
                DispatchQueue.main.async {
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Oops! Something went wrong. Please try again.", comment: ""), type: .alert)
                }
            }
        }
    }
    
    func uploadTheToken(accessToken:String, userEmail: String, loginType: LoginType) {
        
        //access token for today extension
        if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
            userDefaults.set(accessToken as AnyObject, forKey: "accessToken")
            userDefaults.synchronize()
        }
        
        UserDefaults.standard.set(accessToken, forKey: Constant.UD_userToken)
        UserDefaults.standard.set(userEmail, forKey: Constant.UD_userEmail)
        
        SharedManager.shared.performWSToGetReelsData(completionHandler: { status in
            print("status", status)
        })

        let fToken = UserDefaults.standard.string(forKey: Constant.UD_firebaseToken) ?? ""
        if fToken == "" {
            
            self.appDelegate?.registerFirebaseToken { (Bool) in
                
                let fcmNewToken = UserDefaults.standard.string(forKey: Constant.UD_firebaseToken) ?? ""
                self.performWSToUpdateFirebaseTokenOnServer(userAccessToken: accessToken, fcmToken: fcmNewToken)
            }
        }
        else{
            
            self.performWSToUpdateFirebaseTokenOnServer(userAccessToken: accessToken, fcmToken: fToken)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            self.performWSToUserConfig(loginType: loginType)
        }
    }
    
    
    // resigter user webservice Respones
    func performWSToUpdateFirebaseTokenOnServer(userAccessToken: String, fcmToken:String) {
        
        let HeaderToken  = userAccessToken
        let params = ["token":fcmToken]
        
        WebService.URLResponse("notification/token", method: .post, parameters: params, headers: HeaderToken, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.message?.lowercased() == "success" {

//                    self.performWSToUserConfig()
                }
                else {

                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                
                self.hideloader()
            } catch let jsonerror {
                
                self.hideloader()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "notification/token", error: jsonerror.localizedDescription, code: "")
            }
            
        }){ (error) in
            
            self.hideloader()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUserConfig(loginType: LoginType) {
        
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
                
                if let onboarded = FULLResponse.onboarded {
                    
                    SharedManager.shared.isOnboardingPreferenceLoaded = onboarded
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
//                        SharedManager.shared.menuViewModeType = mode
//
//                    }
                    
                    if let narrMode = preference.narration?.mode {
                        
                        SharedManager.shared.showHeadingsOnly = narrMode

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
                
                SharedManager.shared.isLinkedUser = FULLResponse.user?.guestValid ?? false
                
                // Load default theme settings
                SharedManager.shared.setThemeAutomatic()
                
                let userLang = FULLResponse.user?.language ?? "en"
                let code = UserDefaults.standard.string(forKey: Constant.UD_languageSelected) ?? "en"
                
                if userLang != code {
                        
                    var id = ""
                    if let lang = SharedManager.shared.loadJsonLanguages(filename: "languages") {
                        
                        if let selectedIndex = lang.firstIndex(where: { $0.code == code }) {
                            
                            id = lang[selectedIndex].id ?? ""
                        }
                        
                    }
                    
                    self.showLoader(button: self.continueButton)
                    
                    
                    let token = UserDefaults.standard.object(forKey: Constant.UD_userToken) as? String ?? ""
                    let params = ["region": LanguageHelper.languageShared.selectedRegion?.id ?? "ee4add73-b717-4e32-bffb-fecbf82ee6d9"]

                    
                    WebService.URLResponseJSONRequest("news/regions/", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
                        ANLoader.hide()
                        do{
                            let FULLResponsee = try
                                JSONDecoder().decode(messageData.self, from: response)
                            
                            print("PARMS REGION = \(params)")
                            if FULLResponsee.message?.lowercased() == "success" {
                                SharedManager.shared.isTabReload = true
                                
                                SharedManager.shared.performWSToUpdateLanguage(id: LanguageHelper.languageShared.selectedLanguage?.id ?? "ee4add73-b717-4e32-bffb-fecbf82ee6d9", isRefreshedToken: true, completionHandler: { status in
                                    self.hideloader()
                                    if status {
                                        print("SELECTED LANGUAGE = \(LanguageHelper.languageShared.selectedLanguage?.id ?? "ee4add73-b717-4e32-bffb-fecbf82ee6d9")")
                                        print("language updated successfully")
                                    } else {
                                        print("language updated failed")
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.hideloader()
//                                        if FULLResponse.onboarded ?? false {
//
//                                            self.appDelegate?.setHomeVC()
//                                        }
//                                        else {
//
//                                            let vc = SelectTopicsVC.instantiate(fromAppStoryboard: .RegistrationSB)
//                                            let navVC = UINavigationController(rootViewController: vc)
//                                            self.navigationController?.present(navVC, animated: true, completion: nil)
//                                        }
                                        self.appDelegate?.setHomeVC()
                                    }
                                })
                            }
                            
                        } catch let jsonerror {
                            print("error parsing json objects",jsonerror)
                        }
                    }) { (error) in
                        ANLoader.hide()
                        print("error parsing json objects",error)

                    }
                  
                }
                else {
                    
                    
                    DispatchQueue.main.async {
                        self.hideloader()
                        self.appDelegate?.setHomeVC()
                        
//                        if FULLResponse.onboarded ?? false {
//
//                            self.appDelegate?.setHomeVC()
//                        }
//                        else {
//
//                            let vc = SelectTopicsVC.instantiate(fromAppStoryboard: .RegistrationSB)
//                            let navVC = UINavigationController(rootViewController: vc)
//                            self.navigationController?.present(navVC, animated: true, completion: nil)
//
//                        }
                    }
                    
                }
                
            } catch let jsonerror {
            
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
}
