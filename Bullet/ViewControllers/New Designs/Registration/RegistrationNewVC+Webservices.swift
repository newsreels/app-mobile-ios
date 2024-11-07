//
//  RegistrationNewVC+Webservices.swift
//  Bullet
//
//  Created by Faris Muhammed on 08/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import GoogleSignIn
import Combine
import Heimdallr

extension RegistrationNewVC {
    
    
    
    func doAuthRegistration(_ subjectToken: String, loginType: LoginType) {
        
        if loginType == .Email {
            self.showLoader(button: self.continueButton)
        }
        else if loginType == .Apple {
            self.showLoader(button: self.appleButton)
        }
        else if loginType == .Google {
            self.showLoader(button: self.googleButton)
        }
        else if loginType == .Facebook {
            self.showLoader(button: self.fbButton)
        }
        
        let tokenURL = URL(string: WebserviceManager.shared.AUTH_TOKEN_URL)!
        let useCredentials = OAuthClientCredentials(id: WebserviceManager.shared.APP_CLIENT_ID, secret: WebserviceManager.shared.APP_CLIENT_SECRET)
        let heimdall = Heimdallr(tokenURL: tokenURL, credentials: useCredentials)
        
        var parameters = [String : String]()
        var grantType = ""
        
        parameters["language"] = SharedManager.shared.languageId
        if loginType == .Google {
            
            grantType = "token_exchange"
            parameters["subject_token"] = subjectToken
            parameters["subject_token_type"] = "google_access_token"
        }
        else if loginType == .Facebook {
            
            grantType = "token_exchange"
            parameters["subject_token"] = subjectToken
            parameters["subject_token_type"] = "facebook_access_token"
        }
        else if loginType == .Apple {
            
            grantType = "token_exchange"
            parameters["subject_token"] = subjectToken
            parameters["subject_token_type"] = "apple_access_token"
        }
        else if loginType == .Guest {
            
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
                        print("SHAHZAIB accessToken: ", accessToken)
                        self.performWSToGetUserInfo(token: accessToken) {
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
                }
                
            case .failure(let error):
                
                self.hideloader()
                let errorAlert = error.localizedDescription
                print("SHAHZAIB failure: \(errorAlert)")
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
        
        print("SHAHZAIB uploadTheToken() 1")

        let fToken = UserDefaults.standard.string(forKey: Constant.UD_firebaseToken) ?? ""
        if fToken == "" {
            print("SHAHZAIB uploadTheToken() 2")
            self.appDelegate?.registerFirebaseToken { (Bool) in
                print("SHAHZAIB uploadTheToken() 3")
                let fcmNewToken = UserDefaults.standard.string(forKey: Constant.UD_firebaseToken) ?? ""
                self.performWSToUpdateFirebaseTokenOnServer(userAccessToken: accessToken, fcmToken: fcmNewToken)
            }
        }
        else{
            print("SHAHZAIB uploadTheToken() 4")
            self.performWSToUpdateFirebaseTokenOnServer(userAccessToken: accessToken, fcmToken: fToken)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            self.performWSToUserConfig()
        }
    }
    
    
    // resigter user webservice Respones
    func performWSToUpdateFirebaseTokenOnServer(userAccessToken: String, fcmToken:String) {
        
        let HeaderToken  = userAccessToken
        let params = ["token":fcmToken]
        
        print("SHAHZAIB performWSToUpdateFirebaseTokenOnServer() ")
        self.performWSToUserConfig()
//        WebService.URLResponse("notification/token", method: .post, parameters: params, headers: HeaderToken, withSuccess: { (response) in
//            
//            print("SHAHZAIB performWSToUpdateFirebaseTokenOnServer() response ",String(data:response,encoding:.utf8))
//            do{
//                let FULLResponse = try
//                    JSONDecoder().decode(userDC.self, from: response)
//                
//                print("SHAHZAIB performWSToUpdateFirebaseTokenOnServer() FULLResponse ",FULLResponse)
//                if FULLResponse.message?.lowercased() == "success" {
//
//                    self.performWSToUserConfig()
//                }
//                else {
//
//                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
//                }
//                print("SHAHZAIB performWSToUpdateFirebaseTokenOnServer() hideloader() ",FULLResponse)
//                self.hideloader()
//            } catch let jsonerror {
//                
//                self.hideloader()
//                print("error parsing json objects",jsonerror)
//                SharedManager.shared.logAPIError(url: "notification/token", error: jsonerror.localizedDescription, code: "")
//            }
//            
//        }){ (error) in
//            
//            self.hideloader()
//            print("error parsing json objects",error)
//        }
    }
    
    func performWSToGetUserInfo(token: String, completionHandler: @escaping () -> Void) {
       
        WebService.URLResponseAuth("auth/info", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            //ANLoader.hide()
            do {
                print("SHAHZAIB auth/info: ", String(data:response,encoding: .utf8))
                let FULLResponse = try
                    JSONDecoder().decode(userInfoDC.self, from: response)
                
              
                SharedManager.shared.isUserSetup = FULLResponse.results?.setup ?? false

                if let userEmail = FULLResponse.results?.email {
                    print("email id \(userEmail)")
                    UserDefaults.standard.set(userEmail, forKey: Constant.UD_userEmail)
                }
                if let isSocialLinked = FULLResponse.results?.hasPassword {
                    
                    UserDefaults.standard.set(isSocialLinked, forKey: Constant.UD_isSocialLinked)
                }
                          
                completionHandler()
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "auth/info", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
                print("SHAHZAIB performWSToGetUserInfo() rror parsing json object ")
                completionHandler()
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
            print("SHAHZAIB performWSToGetUserInfo() error parsing json object ")
            completionHandler()
        }
    }
    
    func performWSToUserConfig() {
        print("SHAHZAIB performWSToUserConfig()")
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
                
                let token = UserDefaults.standard.object(forKey: Constant.UD_userToken) as? String ?? ""
                let params = ["region": LanguageHelper.languageShared.selectedRegion?.id ?? "ee4add73-b717-4e32-bffb-fecbf82ee6d9"]
                
                var id = ""
                if let lang = SharedManager.shared.loadJsonLanguages(filename: "languages") {
                    
                    if let selectedIndex = lang.firstIndex(where: { $0.code == code }) {
                        
                        id = lang[selectedIndex].id ?? ""
                    }
                    
                }
                
                //                if loginType == .Email {
                //                    self.showLoader(button: self.continueButton)
                //                }
                //                else if loginType == .Apple {
                //                    self.showLoader(button: self.appleButton)
                //                }
                //                else if loginType == .Google {
                //                    self.showLoader(button: self.googleButton)
                //                }
                //                else if loginType == .Facebook {
                //                    self.showLoader(button: self.fbButton)
                //                }
                
                
                LanguageHelper.shared.performWSToUpdateUserContentLanguages {
                    
                    print("SHAHZAIB news/regions/() performWSToUpdateUserContentLanguages() RESP")
                    DispatchQueue.main.async {
                        //TODO: unforce onboarded
                        //                                    if SharedManager.shared.isUserSetup && FULLResponse.onboarded ?? false {
                        if SharedManager.shared.isUserSetup  {
                            self.appDelegate?.setHomeVC()
                        }
                        else {
                            
                            if SharedManager.shared.isUserSetup == false {
                                let vc = AddUsernameVC.instantiate(fromAppStoryboard: .RegistrationSB)
                                vc.isPresented = true
                                let navVC = UINavigationController(rootViewController: vc)
                                self.navigationController?.present(navVC, animated: true, completion: nil)
                            }
                            else {
                                self.appDelegate?.setHomeVC()
                                
                            }
                            
                        }
                        
                    }
                }
        
                    
//                                SharedManager.shared.performWSToUpdateLanguage(id: LanguageHelper.languageShared.selectedLanguage?.id ?? "ee4add73-b717-4e32-bffb-fecbf82ee6d9", isRefreshedToken: true, completionHandler: { status in
//
//                                })
            
                
                
//                print("SHAHZAIB news/regions/()")
//                WebService.URLResponseJSONRequest("news/regions/", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
//                    do{
//                        let FULLResponsee = try
//                            JSONDecoder().decode(messageData.self, from: response)
//                        print("SHAHZAIB news/regions/() FULLResponsee",FULLResponsee)
//                        print("PARMS REGION = \(params)")
//                        if FULLResponsee.message?.lowercased() == "success" {
//                            self.hideloader()
//                            
//                            print("SHAHZAIB news/regions/() performWSToUpdateUserContentLanguages()")
//                            LanguageHelper.shared.performWSToUpdateUserContentLanguages {
//                             
//                                print("SHAHZAIB news/regions/() performWSToUpdateUserContentLanguages() RESP")
//                                DispatchQueue.main.async {
//                                    //TODO: unforce onboarded
////                                    if SharedManager.shared.isUserSetup && FULLResponse.onboarded ?? false {
//                                    if SharedManager.shared.isUserSetup  {
//                                        self.appDelegate?.setHomeVC()
//                                    }
//                                    else {
//                                        
//                                        if SharedManager.shared.isUserSetup == false {
//                                            let vc = AddUsernameVC.instantiate(fromAppStoryboard: .RegistrationSB)
//                                            vc.isPresented = true
//                                            let navVC = UINavigationController(rootViewController: vc)
//                                            self.navigationController?.present(navVC, animated: true, completion: nil)
//                                        }
//                                        else {
//                                            self.appDelegate?.setHomeVC()
//                                            
//                                        }
//                                        
//                                    }
//                                    
//                                }
//                            }
//                            
////                                SharedManager.shared.performWSToUpdateLanguage(id: LanguageHelper.languageShared.selectedLanguage?.id ?? "ee4add73-b717-4e32-bffb-fecbf82ee6d9", isRefreshedToken: true, completionHandler: { status in
////
////                                })
//                        }
//                        
//                    } catch let jsonerror {
//                        print("SHAHZAIB news/regions/() jsonerror1")
//                        
//                        DispatchQueue.main.async {
//                            self.hideloader()
//                            
//                            if SharedManager.shared.isUserSetup == false {
//                                let vc = AddUsernameVC.instantiate(fromAppStoryboard: .RegistrationSB)
//                                vc.isPresented = true
//                                let navVC = UINavigationController(rootViewController: vc)
//                                self.navigationController?.present(navVC, animated: true, completion: nil)
//                            }
//                            else {
//                                self.appDelegate?.setHomeVC()
//                                
//                            }
//                            
//                        }
//                        
//                        print("error parsing json objects",jsonerror)
//                    }
//                }) { (error) in
//                    
//                    print("SHAHZAIB news/regions/() error 2",error)
//                    DispatchQueue.main.async {
//                        self.hideloader()
//                        
//                        if SharedManager.shared.isUserSetup == false {
//                            let vc = AddUsernameVC.instantiate(fromAppStoryboard: .RegistrationSB)
//                            vc.isPresented = true
//                            let navVC = UINavigationController(rootViewController: vc)
//                            self.navigationController?.present(navVC, animated: true, completion: nil)
//                        }
//                        else {
//                            self.appDelegate?.setHomeVC()
//                            
//                        }
//                        
//                    }
//                    print("error parsing json objects",error)
//
//                }
                
                
            } catch let jsonerror {
                print("SHAHZAIB news/regions/() jsonerror 2",jsonerror)
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            print("SHAHZAIB news/regions/() error 3",error)
            print("error parsing json objects",error)
        }
    }
    
    
}
