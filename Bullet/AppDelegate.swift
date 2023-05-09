//
//  AppDelegate.swift
//  Bullet
//
//  Created by Mahesh on 12/04/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SDWebImage
import IQKeyboardManagerSwift
import SwiftTheme
import Firebase
import UserNotificationsUI
import UserNotifications
import FirebaseCrashlytics
//import Auth0
import FBSDKCoreKit
import FBSDKLoginKit
//import FacebookCore
import FirebaseAnalytics
import GoogleMobileAds
import SwiftRater
import Toast_Swift
import AppsFlyerLib
import GoogleSignIn
import FBAudienceNetwork
import DataCache
import OneSignal
import Heimdallr
import AuthenticationServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    var window: UIWindow?
    var navigationController: UINavigationController!
    
    var isBackground = false
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    var dateWhenBackground: Date?
    var tapOnNotification = false
//    var restrictRotation:UIInterfaceOrientationMask = .portrait
    
    /// set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.portrait
    var shouldResetReels: Bool = false
    var shouldResetArticles: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
//        Thread.sleep(forTimeInterval: 1.5)
        //UIApplication.shared.isIdleTimerDisabled = true
        
        OneSignal.setLogLevel(.LL_NONE, visualLevel: .LL_NONE)
        
        // OneSignal initialization
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("5ca68357-0d2e-4c8c-af93-a04403ee9cb9")
        
        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        OneSignal.promptForPushNotifications(userResponse: { accepted in

        })

        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        // Facebook initialization
        ApplicationDelegate.shared.application( application,didFinishLaunchingWithOptions: launchOptions)
//        FBAudienceNetworkAds.initialize(with: nil, completionHandler: nil)
        // Pass user's consent after acquiring it. For sample app purposes, this is set to YES.
//        FBAdSettings.setAdvertiserTrackingEnabled(true)
        
//        FBAdSettings.setLogLevel(.none)
//        #if DEBUG
//        FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
//        #else
//        FBAdSettings.clearTestDevice(FBAdSettings.testDeviceHash())
//        #endif
        
        SharedManager.shared.isAppLaunchFirstTIME = true
        if SharedManager.shared.AppFirstEverLaunch == false {
            SharedManager.shared.AppFirstEverLaunch = true
            SharedManager.shared.isAudioEnableReels = true
        }
        setAppTheme()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.disabledToolbarClasses.append(ChangeEmailVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(ChangePasswordVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(contactUsVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(CommentsVC.self)
        IQKeyboardManager.shared.disabledTouchResignedClasses.append(CommentsVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(RepliesVC.self)
        IQKeyboardManager.shared.disabledTouchResignedClasses.append(RepliesVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(ChannelNameVC.self)
        IQKeyboardManager.shared.disabledTouchResignedClasses.append(ChannelNameVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(ChannelDescriptionVC.self)
        IQKeyboardManager.shared.disabledTouchResignedClasses.append(ChannelDescriptionVC.self)
        
        //        //SVG Image
        //        let SVGCoder = SDImageSVGCoder.shared
        //        SDImageCodersManager.shared.addCoder(SVGCoder)
        
        //setup Language
        setAppLanguage()
        
        //Setup AppsFlyer SDK
        AppsFlyerLib.shared().appsFlyerDevKey = "ZajnjsVaGHX9SQURHUCwfV"
        AppsFlyerLib.shared().appleAppID = "1540932937"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = false
        
        self.configureNotification(application)
        
        
        setCrashLyticsUserDetails()
        let deviceID =  UIDevice.current.identifierForVendor?.uuidString ?? ""
        
        if let _ = launchOptions?[.url] as? [AnyHashable: Any] {
            
            SharedManager.shared.isAppLaunchedThroughNotification = true
        }
        
        if let _ = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            
            //App launch from notification handler
            SharedManager.shared.isAppLaunchedThroughNotification = true
        }
        storeStackTrace()
        let vc = TabbarVC.instantiate(fromAppStoryboard: .Main)
        NotificationCenter.default.addObserver(self, selector: #selector(setHome), name: .SwiftUIDidChangeLanguage, object: nil)

        // Initialize Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        //<--- AppStore Prompt
        let count = SharedManager.shared.appUsageCount ?? 0
        SharedManager.shared.appUsageCount = count + 1

        let intervel = UserDefaults.standard.value(forKey: Constant.ratingTimeIntervel)
        if intervel == nil {
            
            SwiftRater.usesUntilPrompt = 100
        }
        else {
            SwiftRater.usesUntilPrompt = intervel as! Int
        }
//        SwiftRater.daysBeforeReminding = 1
        SwiftRater.appID = "1540932937"
        SwiftRater.showLaterButton = true
        SwiftRater.showLog = false
        SwiftRater.resetWhenAppUpdated = false
        
        // Set to false before submitting to App Store!!!!
//        #if DEBUG
//        SwiftRater.debugMode = true
//        #else
//        SwiftRater.debugMode = false
//        #endif

        SwiftRater.appLaunched()
        //--->

        // Loading cache to singleton
        UploadManager.shared.readCacheOfDownloads()
        UploadManager.shared.clearUncompletedItems()
        UploadManager.shared.resetUncompletedItems()
//
//        let vc = SplashscreenLoaderVC.instantiate(fromAppStoryboard: .OnboardingSB)
//        vc.delegate = self
//        if let window = window {
//            window.rootViewController = vc
//        }
        
      
        self.setHome()
        
        return true
    }
    
    func storeStackTrace() {
        NSSetUncaughtExceptionHandler { exception in
            let userInfo = exception.userInfo as? [String: Any] ?? [:]
            let error = NSError(domain: exception.name.rawValue, code: exception.reason?.hashValue ?? 0, userInfo: userInfo)
            print("Uncaught exception: \(error)")
            Crashlytics.crashlytics().record(error: error)
        }
     }
    
    func doAuthRegistration(_ subjectToken: String, loginType: LoginType, completion: @escaping (Bool)->()) {
        // only Guest login here
        
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
                            completion(false)
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
                        completion(true)
                        self.uploadTheToken(accessToken: accessToken, userEmail: "", loginType: loginType)
                    }
                }
                
            case .failure(let error):
                completion(false)

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
            
            self.registerFirebaseToken { (Bool) in
                
                let fcmNewToken = UserDefaults.standard.string(forKey: Constant.UD_firebaseToken) ?? ""
                self.performWSToUpdateFirebaseTokenOnServer(userAccessToken: accessToken, fcmToken: fcmNewToken, loginType: loginType)
            }
        }
        else{
            
            self.performWSToUpdateFirebaseTokenOnServer(userAccessToken: accessToken, fcmToken: fToken, loginType: loginType)
        }
        
    }
    
    
    // resigter user webservice Respones
    func performWSToUpdateFirebaseTokenOnServer(userAccessToken: String, fcmToken:String, loginType : LoginType = .Guest) {
        
        let HeaderToken  = userAccessToken
        let params = ["token":fcmToken]
        
        WebService.URLResponse("notification/token", method: .post, parameters: params, headers: HeaderToken, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.message?.lowercased() == "success" {

                    self.performWSToUserConfig(loginType: loginType)
                }
         
                
            } catch let jsonerror {
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "notification/token", error: jsonerror.localizedDescription, code: "")
            }
            
        }){ (error) in
            
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
                
                var id = ""
                if let lang = SharedManager.shared.loadJsonLanguages(filename: "languages") {
                    
                    if let selectedIndex = lang.firstIndex(where: { $0.code == code }) {
                        
                        id = lang[selectedIndex].id ?? ""
                    }
                }
                                    
                
                let token = UserDefaults.standard.object(forKey: Constant.UD_userToken) as? String ?? ""
                var languageID = SharedManager.shared.languageId == "en" ? "ee4add73-b717-4e32-bffb-fecbf82ee6d9" : "a635d498-d2c7-48e4-a8e5-2566c5cf4e2e"
                
                let params = ["region": LanguageHelper.languageShared.selectedRegion?.id ?? languageID]

                
                WebService.URLResponseJSONRequest("news/regions/", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
                    ANLoader.hide()
                    do{
                        let FULLResponsee = try
                            JSONDecoder().decode(messageData.self, from: response)
                        
                        if FULLResponsee.message?.lowercased() == "success" {
                            SharedManager.shared.isTabReload = true
                            
                            SharedManager.shared.performWSToUpdateLanguage(id: LanguageHelper.languageShared.selectedLanguage?.id ?? languageID, isRefreshedToken: true, completionHandler: { status in
                              
                                
//                                DispatchQueue.main.async {
//                                    if FULLResponse.onboarded ?? false {
//
//                                        self.setHomeVC()
//                                    }
//                                    else {
//
//                                        let vc = SelectTopicsVC.instantiate(fromAppStoryboard: .RegistrationSB)
//                                        let navVC = UINavigationController(rootViewController: vc)
////                                            self.navigationController?.present(navVC, animated: true, completion: nil)
//                                    }
//                                }
                                self.setHomeVC()

                            })
                        }
                        
                    } catch let jsonerror {
                        print("error parsing json objects",jsonerror)
                    }
                }) { (error) in
                    ANLoader.hide()
                    print("error parsing json objects",error)

                }
                
//                if userLang != code {
//
//
//
//                }
//                else {
//
//
//                    DispatchQueue.main.async {
//
//                        if FULLResponse.onboarded ?? false {
//
//                            self.setHomeVC()
//                        }
//                        else {
//
//                            let vc = SelectTopicsVC.instantiate(fromAppStoryboard: .RegistrationSB)
//                            let navVC = UINavigationController(rootViewController: vc)
////                            self.navigationController?.present(navVC, animated: true, completion: nil)
//
//                        }
//                    }
//
//                }
                
            } catch let jsonerror {
            
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    @objc func setHome() {
        checkSecondaryLang()
        SharedManager.shared.curReelsCategoryId = ""
        SharedManager.shared.curArticlesCategoryId = ""
        let vc = SplashscreenLoaderVC.instantiate(fromAppStoryboard: .OnboardingSB)
        vc.delegate = self
        self.window?.rootViewController = vc
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        NotificationCenter.default.post(name: Notification.Name.notifyOrientationChange, object: nil)
//        MediaManager.sharedInstance.orientationChanged()
//        return orientationLock//self.restrictRotation
        return .portrait
    }
    
    func setOrientationPortraitInly() {
        
        self.orientationLock = [.portrait]
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    func setOrientationLandscapeOnly() {
        
        self.orientationLock = [.landscapeRight]
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    
    func setOrientationBothLandscape() {
        
        self.orientationLock = [.landscapeLeft,.landscapeRight]
        if UIDevice.current.orientation == .landscapeLeft {
            UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        }
        else if UIDevice.current.orientation == .landscapeRight {
            UIDevice.current.setValue(UIDeviceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
        else {
            UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        }
    }
    
    
    func setCrashLyticsUserDetails() {
        
        let deviceID =  UIDevice.current.identifierForVendor?.uuidString ?? ""
         let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
        let email = (UserDefaults.standard.value(forKey: Constant.UD_userEmail) as? String) ?? ""
        
        if userToken as! String == "" {
            Crashlytics.crashlytics().setUserID("No token")
        }
        else {
            if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {
                let name = user.first_name ?? ""
                let keysAndValues = [
                                 "email" : email,
                                 "name" : name,
                                 "API_Base" : WebserviceManager.shared.APP_BUILD_TYPE.rawValue,
                    "Profile_Completed": user.setup ?? false ? "Yes" : "No",
                                ] as [String : Any]
                
                Crashlytics.crashlytics().setCustomKeysAndValues(keysAndValues)
            } else {
                
                let keysAndValues = [
                                 "email" : email,
                                 "name" : "Guest",
                                 "API_Base" : WebserviceManager.shared.APP_BUILD_TYPE.rawValue,
                    "Profile_Completed": "No",
                                ] as [String : Any]
                
                Crashlytics.crashlytics().setCustomKeysAndValues(keysAndValues)
                
            }
            
            Crashlytics.crashlytics().setUserID("\(userToken)")
        }
    }
    
    func setAppLanguage() {
        
        let langCode = UserDefaults.standard.string(forKey: Constant.UD_languageSelected)
        if let code = langCode, !code.isEmpty {
            var id = ""
            if let lang = SharedManager.shared.loadJsonLanguages(filename: "languages") {

                if let selectedIndex = lang.firstIndex(where: { $0.code == code }) {
                    
                    id = lang[selectedIndex].id ?? ""
                }
                
            }
            SharedManager.shared.languageId = id
            Bundle.setLanguage(code)
            SharedManager.shared.isLanguageRTL = Bundle.isLanguageRTL(code) ? true : false
        }
        else {
            
            UserDefaults.standard.set("https://cdn.newsinbullets.app/flags/us.png", forKey: Constant.UD_languageFlag)
            UserDefaults.standard.set("en", forKey: Constant.UD_languageSelected)
            SharedManager.shared.languageId = "ee4add73-b717-4e32-bffb-fecbf82ee6d9"
            UserDefaults.standard.synchronize()
            Bundle.setLanguage("en")
            SharedManager.shared.isLanguageRTL = false
        }
    }
    
    func setAppTheme() {
        
        let selectedThemeType = UserDefaults.standard.bool(forKey: Constant.UD_isLocalTheme)
        if selectedThemeType == true {
            
            if #available(iOS 13.0, *) {
                
                let theme = UserDefaults.standard.bool(forKey: "dark")
                if theme {
                    
                    MyThemes.switchTo(theme: .dark)
                }
                else {
                    
                    MyThemes.switchTo(theme: .light)
                }
            }
            else {
                
                MyThemes.switchTo(theme: .dark)
            }
        }
        else{
            
            if UIViewController().isDarkMode {
                
                MyThemes.switchTo(theme: .dark)
            }
            else {
                
                MyThemes.switchTo(theme: .light)
            }
        }
        
        MyThemes.saveLastTheme()
        
        var style = ToastStyle()
        style.backgroundColor = MyThemes.current == .dark ? UIColor.white.withAlphaComponent(0.8) : UIColor.black.withAlphaComponent(0.8)
        style.messageColor = MyThemes.current == .dark ? "#3D485F".hexStringToUIColor(): "#FFFFFF".hexStringToUIColor()
        ToastManager.shared.style = style
    }
    
    
    //Firebase configuration
    func configureNotification(_ application: UIApplication) {
        
        // Set firebase analytics for staging and production.
        if WebserviceManager.shared.APP_BUILD_TYPE == .staging {
            
            if let filePath = Bundle.main.path(forResource: "GoogleService-InfoStaging", ofType: "plist") {
                if let fileopts = FirebaseOptions(contentsOfFile: filePath) {
                    FirebaseApp.configure(options: fileopts)
                } else {
                    return
                }
            }
        }
        else {
            if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
                if let fileopts = FirebaseOptions(contentsOfFile: filePath) {
                    FirebaseApp.configure(options: fileopts)
                } else {
                    return
                }
            }
        }
        
        if WebserviceManager.shared.APP_BUILD_TYPE == .staging {
            WebserviceManager.shared.API_BASE = Constant.Staging.apiBase
            WebserviceManager.shared.APP_CLIENT_ID = Constant.Staging.appClientID
            WebserviceManager.shared.APP_CLIENT_SECRET = Constant.Staging.appClientSecret
            WebserviceManager.shared.GOOGLE_CLIENT_ID = Constant.Staging.googleClientID
            WebserviceManager.shared.AUTH_BASE_URL = Constant.Staging.authBaseURL
            WebserviceManager.shared.AUTH_TOKEN_URL = Constant.Staging.authTokenURL
            
        }
        else {
            WebserviceManager.shared.API_BASE = Constant.Production.apiBase
            WebserviceManager.shared.APP_CLIENT_ID = Constant.Production.appClientID
            WebserviceManager.shared.APP_CLIENT_SECRET = Constant.Production.appClientSecret
            WebserviceManager.shared.GOOGLE_CLIENT_ID = Constant.Production.googleClientID
            WebserviceManager.shared.AUTH_BASE_URL = Constant.Production.authBaseURL
            WebserviceManager.shared.AUTH_TOKEN_URL = Constant.Production.authTokenURL
            
        }
        
        //GOOGLE LOGIN
        GIDSignIn.sharedInstance().clientID = WebserviceManager.shared.GOOGLE_CLIENT_ID
        
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        //   FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        // Override point for customization after application launch.
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        
        setCrashLyticsUserDetails()
        
        // Set analytics
        let id: String = UserDefaults.standard.string(forKey: Constant.UD_userId) ?? ""
        Analytics.setUserProperty(id, forName: "user")
    }
    
    //MARK:- LifeCycle
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        application.isIdleTimerDisabled = true

        // Start the SDK (start the IDFA timeout set above, for iOS 14 or later)
        
        //this delay is for data conflict with home/news api and homescreen UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            
            AppsFlyerLib.shared().start()
            
            //We have this delay for AppsFlyer starting time
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                
                let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
                if userToken as! String == "" {
                    
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.appInstall, eventDescription: "")
                    //SharedManager.shared.setAppsFlyerEventsReport(eventType: Constant.analyticsEvents.NewZealandiOSVoluum, eventDescription: "")
                }
            }
        }
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        //  print(" user info \(userInfo)")
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
    
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        
        guard let incomingURL = dynamicLink.url else {
             
            return
        }
        SharedManager.shared.isAppOpenFromDeepLink = true  //whenever open from Link set the flag true

        if self.isContainString(incomingURL.absoluteString, subString: "/articles?id=") {
            
            SharedManager.shared.isAppLaunchedThroughNotification = true
            SharedManager.shared.clearProgressBar()
            
            if let range = incomingURL.absoluteString.range(of: "/articles?id=") {
                let urlID = incomingURL.absoluteString[range.upperBound...]
                print(urlID)
                
                SharedManager.shared.articleIdNotification = String(urlID)
                
                if SharedManager.shared.isAppOpenFromDeepLink {
                    
                    NotificationCenter.default.post(name: Notification.Name.notifyGetPushNotificationArticleData, object: nil, userInfo: nil)
                    
                }
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.widgetOpen, eventDescription: "")
            }
        }
        else if self.isContainString(incomingURL.absoluteString, subString: "/reel?context=") {
            
            SharedManager.shared.isAppLaunchedThroughNotification = true
            SharedManager.shared.clearProgressBar()
            
            if let range = incomingURL.absoluteString.range(of: "/reel?context=") {
                let urlID = incomingURL.absoluteString[range.upperBound...]
                print(urlID)
                
                SharedManager.shared.reelsContextNotification = String(urlID)
                
                if SharedManager.shared.isAppOpenFromDeepLink {
                    
                    NotificationCenter.default.post(name: Notification.Name.notifyGetPushNotificationArticleData, object: nil, userInfo: nil)
                    
                }
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.widgetOpen, eventDescription: "")
            }
        }
    }

    
    // Open URI-scheme for iOS 9 and above
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
    
    
    // Open Deeplinks
    // Reports app open from deep link for iOS 10 or later
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        
        if let incomingURL = userActivity.webpageURL {

            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { ( dynamicLink, error) in
                guard error == nil else {
                    print("Found an error \(error!.localizedDescription)")
                    return
                }
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
            if linkHandled {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
//        application.isIdleTimerDisabled = true
    }
        
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        NotificationCenter.default.post(name: Notification.Name.notifyPauseAudio, object: nil)
        NotificationCenter.default.post(name: Notification.Name.notifyCloseSubCategoryView, object: nil)
        //SharedManager.shared.bulletPlayer?.stop()
        self.isBackground = true
        dateWhenBackground = Date.init()
        //self.doBackgroundTask()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        let count = SharedManager.shared.appUsageCount ?? 0
        SharedManager.shared.appUsageCount = count + 1
        
        SwiftRater.appLaunched()
        
//        if SharedManager.shared.isAppLaunchFirstTIME { return }
        
        //Invalidate background timer
        if let fromDate = self.dateWhenBackground {
            SharedManager.shared.refreshFeedOnKillApp = self.dateWhenBackground
            SharedManager.shared.refreshReelsOnKillApp = self.dateWhenBackground
            
            let interval = Date().timeIntervalSince(fromDate)
            let minutes = (interval / 60).truncatingRemainder(dividingBy: 60)
            //print("background time....", minutes)
            if minutes >= 2 {
                shouldResetReels = true
                shouldResetArticles = true
                self.appRefreshInBackground()
                return
            }
            else {
                
                if self.tapOnNotification  {
                    
                    self.tapOnNotification = false
                }
                else {
                    
                    self.fireNotificationAppFromBackground()
                }

            }
        }
        else {
        
            if self.tapOnNotification  {
                
                self.tapOnNotification = false
            }
            else {
                
                self.fireNotificationAppFromBackground()
            }
        }
        
        shouldResetReels = false
        shouldResetArticles = false

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        SharedManager.shared.bulletPlayer?.stop()
        self.isBackground = false
        
        //save as Date
        SharedManager.shared.refreshFeedOnKillApp = Date.init()
        SharedManager.shared.refreshReelsOnKillApp = Date.init()
        print("applicationWillTerminate", Date.init())
    }
    
    
    //MARK:- Custom Methods
    func setLoginVC() {
        
        /*
        if SharedManager.shared.isONBOARD == true {
            
            let vc = PreRegistrationVC.instantiate(fromAppStoryboard: .registration)
            navigationController = AppNavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            self.window?.rootViewController = self.navigationController
        }
        else {
            
//            let vc = AppLanguageVC.instantiate(fromAppStoryboard: .Onboarding)
//            self.window?.rootViewController = vc
            let vc = OnboardingNewVC.instantiate(fromAppStoryboard: .OnboardingSB)
            navigationController = AppNavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            self.window?.rootViewController = self.navigationController
            
        }*/
        
        setOnBoardVC()
    }
    
    func setHomeVC(_ isAnimated: Bool = true) {
        
        if let language = LanguageHelper.shared.getSavedLanguage(){
            LanguageHelper.shared.saveLanguage(language: language, isInSettings: true)
        }
        LanguageHelper.languageShared.saveSelectedRegionAndLanguage {
            DispatchQueue.main.async { [weak self] in
            let vc = TabbarVC.instantiate(fromAppStoryboard: .Main)
            self?.navigationController = AppNavigationController.init(rootViewController: vc)
            self?.navigationController.navigationBar.isHidden = true
                self?.window?.rootViewController = self?.navigationController
                SharedManager.shared.isFirstimeSplashScreenLoaded = false
                if (SharedManager.shared.tabBarIndex == 0) {
//                    SharedManager.shared.showLoaderInWindow()
                    self?.perform(#selector(self?.autohideloader), with: nil, afterDelay: 5)
                }
                
            }
        }
        
       
    }
    
    @objc func autohideloader() {
        
        SharedManager.shared.hideLaoderFromWindow()
    }
    
    
//    func setUserTopicVC() {
//
//        let vc = userTopicVC.instantiate(fromAppStoryboard: .registration)
//        navigationController = AppNavigationController(rootViewController: vc)
//        navigationController.navigationBar.isHidden = true
//        if let window = (UIApplication.shared.delegate as! AppDelegate).window {
//            window.rootViewController = self.navigationController
//        }
//    }
    
//    func setUserEditionsVC() {
//
////        let vc = EditionVC.instantiate(fromAppStoryboard: .registration)
//
//        let vc = OnboardingVC.instantiate(fromAppStoryboard: .Onboarding)
//  //      vc.isFromRegistration = true
//        navigationController = AppNavigationController(rootViewController: vc)
//        navigationController.navigationBar.isHidden = true
//        if let window = (UIApplication.shared.delegate as! AppDelegate).window {
//            window.rootViewController = self.navigationController
//        }
//    }
    
//    func setUserSourceVC() {
//
//        let vc = UserChannelsVC.instantiate(fromAppStoryboard: .registration)
//        navigationController = AppNavigationController(rootViewController: vc)
//        navigationController.navigationBar.isHidden = true
//        if let window = (UIApplication.shared.delegate as! AppDelegate).window {
//            window.rootViewController = self.navigationController
//        }
//    }
    
    @objc func setOnBoardVC() {
        
        /*
        let vc = PreRegistrationVC.instantiate(fromAppStoryboard: .registration)
        navigationController = AppNavigationController(rootViewController: vc)
        navigationController.navigationBar.isHidden = true
        if let window = window {
            window.rootViewController = self.navigationController
        }
        */
        
        
        
        let vc = OnboardingNewVC.instantiate(fromAppStoryboard: .OnboardingSB)
        navigationController = AppNavigationController(rootViewController: vc)
        navigationController.navigationBar.isHidden = true
        self.window?.rootViewController = self.navigationController
        
        
    }
    
//    func setThemeVC() {
//
//        let vc = ThemesVC.instantiate(fromAppStoryboard: .registration)
//        navigationController = AppNavigationController(rootViewController: vc)
//        navigationController.navigationBar.isHidden = true
//        if let window = (UIApplication.shared.delegate as! AppDelegate).window {
//            window.rootViewController = self.navigationController
//        }
//    }

    func newLogout() {
        DataCache.instance.cleanAll()
        
        //Reset all stored data
        SharedManager.shared.curReelsCategoryId = ""
        SharedManager.shared.curArticlesCategoryId = ""
        SharedManager.shared.isGuestUser = false
        
        let code = UserDefaults.standard.string(forKey: Constant.UD_languageSelected) ?? ""
        let flag = UserDefaults.standard.string(forKey: Constant.UD_languageFlag) ?? ""
        let languageName = UserDefaults.standard.value(forKey: Constant.UD_appLanguageName)
        let langId = SharedManager.shared.languageId
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.logout, eventDescription: "")
//        SharedManager.shared.isViewArticleSourceNotification = false
        SharedManager.shared.isAppLaunchedThroughNotification = false
        //        SharedManager.shared.isShowTopic = false
        //        SharedManager.shared.isShowSource = false
        
        //SharedManager.shared.focussedCardIndex = 0
        //        SharedManager.shared.focussedCardTopicIndex = 0
        //        SharedManager.shared.focussedCardSourceIndex = 0
        
        let languageHolder = LanguageHelper.shared.getSavedLanguage()
        let regionHolder = LanguageHelper.shared.getSavedRegion()
        
        UserDefaults.standard.removeSuite(named: "group.app.newsreels")
        UserDefaults.standard.removeSuite(named: "accessToken")
        UserDefaults.standard.removePersistentDomain(forName: "group.app.newsreels")
        UserDefaults.standard.synchronize()
        
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        self.unregisterFirebaseToken()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            
            SharedManager.shared.isAppOnboardScreensLoaded = true
            ANLoader.hide()
            
            SharedManager.shared.languageId = langId
            UserDefaults.standard.set(code, forKey: Constant.UD_languageSelected)
            UserDefaults.standard.set(flag, forKey: Constant.UD_languageFlag)
            UserDefaults.standard.set(languageName, forKey: Constant.UD_appLanguageName)
            UserDefaults.standard.synchronize()
            
//            self.setAppLanguage()
            self.setLoginVC()
        })
        
        UserDefaults.standard.setValue(true, forKey: Constant.UD_new_has_selected_language)
        if let regionHolder = regionHolder {
            LanguageHelper.shared.saveRegion(region: regionHolder)
        }
        if let languageHolder = languageHolder {
            LanguageHelper.shared.saveLanguage(language: languageHolder, isInSettings: false)
        }

    }
    
    func logout() {
        
        return
        //clear cache
        DataCache.instance.cleanAll()
        
        //Reset all stored data
        SharedManager.shared.curReelsCategoryId = ""
        SharedManager.shared.curArticlesCategoryId = ""
        SharedManager.shared.isGuestUser = false
        
        let code = UserDefaults.standard.string(forKey: Constant.UD_languageSelected) ?? ""
        let flag = UserDefaults.standard.string(forKey: Constant.UD_languageFlag) ?? ""
        let languageName = UserDefaults.standard.value(forKey: Constant.UD_appLanguageName)
        let langId = SharedManager.shared.languageId
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.logout, eventDescription: "")
//        SharedManager.shared.isViewArticleSourceNotification = false
        SharedManager.shared.isAppLaunchedThroughNotification = false
        //        SharedManager.shared.isShowTopic = false
        //        SharedManager.shared.isShowSource = false
        
        //SharedManager.shared.focussedCardIndex = 0
        //        SharedManager.shared.focussedCardTopicIndex = 0
        //        SharedManager.shared.focussedCardSourceIndex = 0
        
        let languageHolder = LanguageHelper.shared.getSavedLanguage()
        let regionHolder = LanguageHelper.shared.getSavedRegion()
        
        UserDefaults.standard.removeSuite(named: "group.app.newsreels")
        UserDefaults.standard.removeSuite(named: "accessToken")
        UserDefaults.standard.removePersistentDomain(forName: "group.app.newsreels")
        UserDefaults.standard.synchronize()
        
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        self.unregisterFirebaseToken()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            
            SharedManager.shared.isAppOnboardScreensLoaded = true
            ANLoader.hide()
            
            SharedManager.shared.languageId = langId
            UserDefaults.standard.set(code, forKey: Constant.UD_languageSelected)
            UserDefaults.standard.set(flag, forKey: Constant.UD_languageFlag)
            UserDefaults.standard.set(languageName, forKey: Constant.UD_appLanguageName)
            UserDefaults.standard.synchronize()
            
//            self.setAppLanguage()
            self.setLoginVC()
        })
        
        UserDefaults.standard.setValue(true, forKey: Constant.UD_new_has_selected_language)
        if let regionHolder = regionHolder {
            LanguageHelper.shared.saveRegion(region: regionHolder)
        }
        if let languageHolder = languageHolder {
            LanguageHelper.shared.saveLanguage(language: languageHolder, isInSettings: false)
        }
    }
    
    func unregisterFirebaseToken() {
        // Delete the Firebase instance ID
        //        InstanceID.instanceID().deleteID { (error) in
        //            if error != nil{
        //                print("FIREBASE: ", error.debugDescription)
        //            } else {
        //                print("FIREBASE: Token Deleted")
        //            }
        //        }
        
        
    }
    
    func registerFirebaseToken(completion: @escaping (Bool)->()) {
        
        Messaging.messaging().deleteToken { err in
            
            Messaging.messaging().token { token, err in
                if let error = err {
    

                    completion(false)
                }
                if let token = token {

                    //                            print(token)
                    UserDefaults.standard.set(token, forKey: Constant.UD_firebaseToken)
                    completion(true)
                }
                
            }
            
        }
        //        InstanceID.instanceID().instanceID { (result, error) in
//                    if let error = error {
//
//                        print("Error fetching remote instange ID: \(error)")
//                        completion(false)
//                    }
        //            else if let result = result {
        //
        //                print("Remote instance ID token: \(result.token)")
        //                UserDefaults.standard.set(result.token, forKey: Constant.UD_firebaseToken)
        //                completion(true)
        //            }
        //        }
    }
    
    // Implementation for widgets
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        AppsFlyerLib.shared().handleOpen(url, options: options)
        
        let urlPath : String = url.absoluteString
        print(urlPath)
        self.tapOnNotification = true
        //  let state: UIApplication.State = UIApplication.shared.applicationState
        if let range = urlPath.range(of: "BW") {
            
            let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
            if token.isEmpty {
                
                self.setLoginVC()
            }
            else {
                
//                SharedManager.shared.articleSearchModeType = ""
                SharedManager.shared.clearProgressBar()
                
                let urlID = urlPath[range.upperBound...]
                SharedManager.shared.articleIdNotification = String(urlID)
                
                SharedManager.shared.isAppLaunchedThroughNotification = true
                NotificationCenter.default.post(name: Notification.Name.notifyGetPushNotificationArticleData, object: nil, userInfo: nil)
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.widgetOpen, eventDescription: "")
            }
        }
        else if self.isContainString(urlPath, subString: "homevc") {
            
            SharedManager.shared.tabBarIndex = TabbarType.Home.rawValue
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.widgetMoreLikeThis, eventDescription: "")
            setHomeVC()
        }
        else if self.isContainString(urlPath, subString: "login") {
            
            setLoginVC()
        }
        else if (url.scheme?.hasPrefix("fb"))! {
            
            return FBSDKCoreKit.ApplicationDelegate.shared.application(app, open: url, options: options)
        }
        //Set the callback URL type for google login for staging
        else if (url.scheme?.hasPrefix("com.googleusercontent.apps.883200977297-v760ap6sa48thpd1r4u5pf1kpbtfn0ia"))! {
            
            return GIDSignIn.sharedInstance().handle(url)
        }
        //Set the callback URL type for google login for production
        else if (url.scheme?.hasPrefix("com.googleusercontent.apps.709274277066-s297ov3fk0444eul8bedmubl4h98kpkk"))! {
            
            return GIDSignIn.sharedInstance().handle(url)
        }
        else {
            
//            SharedManager.shared.articleSearchModeType = ""
            SharedManager.shared.clearProgressBar()
            
            let id = urlPath.deletingPrefix("open://")
            SharedManager.shared.articleIdNotification = id
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.widgetOpen, eventDescription: "")
            if self.isBackground {
                
                NotificationCenter.default.post(name: Notification.Name.notifyGetPushNotificationArticleData, object: nil, userInfo: nil)
            }
            else {
                
//                SharedManager.shared.isViewArticleSourceNotification = false
                SharedManager.shared.isAppLaunchedThroughNotification = true
            }
        }
        return true
    }
    
    func isContainString(_ string: String, subString: String) -> Bool {
        if (string as NSString).range(of: subString).location != NSNotFound { return true }
        else { return false }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
                        deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        //   print("Registration succeeded!")
        
    }
    
    //get error here
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error:
                        Error) {
        print("Registration failed!")
    }
    
}

// MARK:- UserNotifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //This is the two delegate method to get the notification in iOS 10..
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                    -> Void) {
        
        // custom code to handle push while app is in the foreground
        //        print("Handle push from foreground \(notification.request.content.userInfo)")
        //        completionHandler([.alert, .badge, .sound])
        
        completionHandler([])
        
//        let userInfo = notification.request.content.userInfo
//        print("Receive notification in the foreground \(userInfo)")
//        let pref = UserDefaults.init(suiteName: "group.app.newsreels")
//        pref?.set(userInfo, forKey: "NOTIF_DATA")
//        //        guard let vc = UIApplication.shared.windows.first?.rootViewController as? ViewController else { return }
//        //        vc.handleNotifData()
//        completionHandler([.alert, .badge, .sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        //print(type ?? "")
        //print(articleId ?? "")
        self.tapOnNotification = true
        handleNotificationTapped(userInfo: userInfo)
        
        // tell the app that we have finished processing the user’s action / response
//        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        

        if UserDefaults.standard.string(forKey: Constant.UD_firebaseToken) == ""{
            UserDefaults.standard.set(fcmToken, forKey: Constant.UD_firebaseToken)
        }
    }
}

extension AppDelegate {
    
    //MARK: Handle Notification
    func handleNotificationTapped(userInfo: [AnyHashable : Any]) {

        
        if let userInfoData = userInfo["custom"] as? [String:Any] {
            let notiData = userInfoData["a"] as? [String:Any]
            
            let type = notiData?["type"] as? String ?? ""
            if type == "reel" { //reel.new
             SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.notificationOpenReel, eventDescription: "")
             //SharedManager.shared.reelsContextNotification = userInfo["article_id"] as? String ?? ""
             SharedManager.shared.reelsContextNotification = notiData?["context"] as? String ?? ""
             }
             else {
             SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.notificationOpenArticle, eventDescription: "")
             //SharedManager.shared.articleIdNotification = userInfo["article_id"] as? String ?? ""
             SharedManager.shared.articleIdNotification = notiData?["id"] as? String ?? ""
             }
             
             if !SharedManager.shared.isAppLaunchedThroughNotification {
             
             NotificationCenter.default.post(name: Notification.Name.notifyGetPushNotificationArticleData, object: nil, userInfo: nil)
             }
            
           //Open the notification using deepLink
//            let deepLink = notiData?["deeplink"] as? String ?? ""
//            if deepLink == "" {
//                print("No deepLink found for notification")
//                return
//            }else{
//                print("incoming URL is \(deepLink)")
//                guard let sharedLink = URL(string: deepLink) else {
//                    return
//                }
//                DynamicLinks.dynamicLinks().handleUniversalLink(sharedLink) { ( dynamicLink, error) in
//                    guard error == nil else {
//                        print("Found an error \(error!.localizedDescription)")
//                        return
//                    }
//                    if let dynamicLink = dynamicLink {
//                        self.handleIncomingDynamicLink(dynamicLink)
//                    }
//                }
//            }
            
            
        } 
    }
    
}

extension AppDelegate {
    
    func showAlertOnUIWindow(alertTitle: String, alertMessage: String) {
        
        var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
        topWindow?.rootViewController = UIViewController()
        topWindow?.windowLevel = UIWindow.Level.alert + 1
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { _ in
            
            topWindow?.isHidden = true
            topWindow = nil
        })
        topWindow?.makeKeyAndVisible()
        topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func fireNotificationAppFromBackground() {
        
        //1
        if let navMain = self.window?.rootViewController as? AppNavigationController,
           let tabBarController = navMain.viewControllers.first as? TabbarVC, let viewControllers = tabBarController.viewControllers {
            
            //2
            for viewController in viewControllers {
                //3
                if let nav = viewController as? AppNavigationController,
                   let mainVC = nav.viewControllers.first as? TopStoriesVC {
                    //4
                    NotificationCenter.default.post(name: Notification.Name.notifyAppFromBackground, object: nil)
                    break
//                    if let _ = mainVC.pageControlVC?.viewControllers?.first as? HomeVC {
//
//                        //NotificationCenter.default.post(name: Notification.Name.notifyToRemoveVCObservers, object: nil)
//                        if let _ = UIApplication.getTopViewController() as? TopStoriesVC {
//
//                            NotificationCenter.default.post(name: Notification.Name.notifyAppFromBackground, object: nil)
//                            break
//                        }
//                        else if let _ = UIApplication.getTopViewController() as? MainTopicSourceVC {
//
//                            NotificationCenter.default.post(name: Notification.Name.notifyAppFromBackground, object: nil)
//                            break
//                        }
//                        else if let _ = UIApplication.getTopViewController() as? SearchAllVC {
//
//                            if  SharedManager.shared.subTabBarType == .Articles {
//
//                                NotificationCenter.default.post(name: Notification.Name.notifyAppFromBgChildArticle, object: nil)
//                                break
//                            }
//                        }
//                    }
                }
            }
        }
    }
}

//MARK: AppsFlyerLibDelegate
extension AppDelegate: AppsFlyerLibDelegate {
    
    // Handle Organic/Non-organic installation
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
         
        for (key, value) in data {
            print(key, ":", value)
        }
        
        if let status = data["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = data["media_source"],
                   let campaign = data["campaign"] {
                   
                }
            } else {
             }
            if let is_first_launch = data["is_first_launch"] as? Bool,
               is_first_launch {
                 
            } else {
             }
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        print("\(error)")
    }
}

//MARK:- APP REFRESH IN BACKGROUND
extension AppDelegate {
    
    @objc func appRefreshInBackground() {
        
        DispatchQueue.main.async {
            
            //1
            if let navMain = self.window?.rootViewController as? AppNavigationController,
               let tabBarController = navMain.viewControllers.first as? TabbarVC, let viewControllers = tabBarController.viewControllers {
                
                //2
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OpenedFromBackground"), object: nil)
                for viewController in viewControllers {
                    //3
                    if let nav = viewController as? AppNavigationController,
                       let mainVC = nav.viewControllers.first as? TopStoriesVC {
                        //4
                        if let vc = mainVC.pageControlVC?.viewControllers?.first as? HomeVC {
                            
                            if let topVC = UIApplication.getTopViewController() as? TopStoriesVC {
                                print("TopStoriesVC refreshed in background", topVC)
                                
                                vc.reloadDataFromBG()
                            }
                            else if let topVC = UIApplication.getTopViewController() as? MainTopicSourceVC {
                                print("MainTopicSourceVC app refreshed in background", topVC)
                                
                                vc.reloadDataFromBG()
                            }
                        }
                    }
                }
            }
        }
    }
}

extension AppDelegate {
    func checkSecondaryLang() {
        if LanguageHelper.shared.getSecondaryLanguage()?.id != LanguageHelper.shared.getSavedLanguage()?.id {
            guard let primary = LanguageHelper.shared.getSavedLanguage() else { return }
            LanguageHelper.shared.saveSecondaryLanguage(language: primary)
        }
    }
}



extension AppDelegate: SplashscreenLoaderVCDelegate {
    
    func dismissSplashscreenLoaderVC() {
        if let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) as? String, !userToken.isEmpty {
            SharedManager.shared.bulletsAutoPlay = true
            let vc = TabbarVC.instantiate(fromAppStoryboard: .Main)
            self.navigationController = AppNavigationController.init(rootViewController: vc)
            self.navigationController.navigationBar.isHidden = true
            self.window?.rootViewController = self.navigationController
        } else {
            let deviceID =  UIDevice.current.identifierForVendor?.uuidString ?? ""
            self.doAuthRegistration(deviceID, loginType: .Guest) { value in }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.navigationController = AppNavigationController.init(rootViewController: storyboard.instantiateViewController(withIdentifier: "AnimationLaunch"))
            self.navigationController.navigationBar.isHidden = true
            self.window?.rootViewController = self.navigationController
        }
    }
}

