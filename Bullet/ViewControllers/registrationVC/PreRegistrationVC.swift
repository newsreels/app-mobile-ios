//
//  PreRegistrationVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 19/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
//import Auth0
//import FacebookCore
//import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import Combine
//import FBSDKLoginKit
import ActiveLabel
import GoogleSignIn
import Heimdallr

class PreRegistrationVC: UIViewController {
    
    @IBOutlet weak var viewGuest: UIView!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var lblGuest: UILabel!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewEmailLogin: UIView!
    @IBOutlet weak var viewGoogle: UIView!
    @IBOutlet weak var viewFacebook: UIView!
    @IBOutlet weak var viewApple: UIView!
    @IBOutlet weak var constrainViewBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintLogoVerticleSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintEmailViewHight: NSLayoutConstraint!
    @IBOutlet weak var constraintStackViewHight: NSLayoutConstraint!
    @IBOutlet weak var constraintGuestViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lblOrWith: UILabel!
    
    @IBOutlet weak var lblPrivacy: ActiveLabel!
    
    
    //  let keychain = A0SimpleKeychain()
    //  let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
//    var credentials: Credentials?
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private let fbAPIURL = "https://graph.facebook.com/v6.0"
    let privacyText1 = NSLocalizedString("By clicking Continue, you agree with our", comment: "")
    let privacyText2 = NSLocalizedString("Terms", comment: "")
    let privacyText3 = NSLocalizedString("Learn how we process your data in our", comment: "")
    let privacyText4 = NSLocalizedString("Privacy Policy", comment: "")
    
    let termsType = ActiveType.custom(pattern: NSLocalizedString("Terms", comment: ""))
    let privacyType = ActiveType.custom(pattern: NSLocalizedString("Privacy Policy", comment: ""))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self .designSetup()
        setupLocalization()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
                
        print("token :",UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "")
//        self.constraintBottomViewHeight.constant = 0
        constrainViewBottom.constant = -(self.viewBottom.frame.size.height + 60)
        self.constraintLogoVerticleSpace.constant = 0
        
        MyThemes.switchTo(theme: .dark)
        UserDefaults.standard.set(true, forKey: Constant.UD_isLocalTheme)
        UserDefaults.standard.set(true, forKey: "dark")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.showBottomView()
        }
        
        setupSocialLoginButtons()
        lblEmail.addTextSpacing(spacing: 2.0)
        lblGuest.addTextSpacing(spacing: 2.0)
        
        self.lblLanguage.text = UserDefaults.standard.value(forKey: Constant.UD_appLanguageName) as? String
//        lblGuest.addTextSpacing(spacing: 2.0)
    }
    
    
    func setupLocalization() {
        lblGuest.text = NSLocalizedString("CONTINUE AS GUEST", comment: "")
        lblEmail.text = NSLocalizedString("CONTINUE WITH EMAIL ID", comment: "")
        
        let privacyText = NSLocalizedString("By clicking Continue, you agree with our Terms.", comment: "") + " " + NSLocalizedString("Learn how we process your data", comment: "") + " " + NSLocalizedString("in our Privacy Policy.", comment: "") //privacyText1 + " " + privacyText2 + ". " + privacyText3 + " " + privacyText4 + "."
        lblPrivacy.customize { (label) in
            lblPrivacy.text = privacyText
            lblPrivacy.numberOfLines = 0
            lblPrivacy.enabledTypes = [termsType,privacyType]
            lblPrivacy.customColor = [termsType : Constant.appColor.purple, privacyType : Constant.appColor.purple]
            lblPrivacy.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                atts[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.thick.rawValue
                return atts
            }
            
            lblPrivacy.handleCustomTap(for: termsType, handler: { (string) in
                // action
                let button = UIButton()
                button.tag = 0
                self.didTapTermsAndPrivacyPolicy(button)
            })
            
            lblPrivacy.handleCustomTap(for: privacyType, handler: { (string) in
                // action
                let button = UIButton()
                button.tag = 1
                self.didTapTermsAndPrivacyPolicy(button)
            })
        }
        
        
        lblOrWith.text = NSLocalizedString("Or with", comment: "")
    }
    
    @IBAction func didTapTermsAndPrivacyPolicy(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.termsClick, eventDescription: "")
            let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
            vc.webURL = "https://www.newsinbullets.app/terms/?header=false"
            vc.titleWeb = NSLocalizedString("Terms & Conditions", comment: "")
            self.navigationController?.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        else {
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.policyClick, eventDescription: "")
            let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
            vc.webURL = "https://www.newsinbullets.app/privacy/?header=false"
            vc.titleWeb = NSLocalizedString("Privacy Policy", comment: "")
            self.navigationController?.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        let vc = AppLanguageVC.instantiate(fromAppStoryboard: .Onboarding)
        vc.modalPresentationStyle = .overFullScreen
      //  vc.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.view.isHidden = false
        
        SharedManager.shared.isAudioEnableReels = true
        SharedManager.shared.isAudioEnable = true
    }
    
    
    func designSetup() {
        
        switch UIDevice().type {
        
        case .iPhoneSE, .iPhone5, .iPhone5C, .iPhone5S, .iPhone6, .iPhone7, .iPhone8, .iPhone6S:
                        
            self.constraintGuestViewHeight.constant = 46
            self.constraintEmailViewHight.constant = 46
            self.constraintStackViewHight.constant = 46
            self.btnSignIn.titleLabel?.font = UIFont(name: Constant.FONT_Mulli_EXTRABOLD, size: 11)!
            self.lblPrivacy.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 10) ?? UIFont.boldSystemFont(ofSize: 10)
            break
            
            
        case .iPhone6Plus, .iPhone6SPlus, .iPhone7Plus, .iPhone8Plus, .iPhone11Pro, .iPhoneX, .iPhoneXS, .iPhoneXR:
                        
            self.btnSignIn.titleLabel?.font = UIFont(name: Constant.FONT_Mulli_EXTRABOLD, size: 13) ?? UIFont.boldSystemFont(ofSize: 13)
            self.constraintGuestViewHeight.constant = 48
            self.constraintEmailViewHight.constant = 48
            self.constraintStackViewHight.constant = 48
            self.lblPrivacy.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 11) ?? UIFont.boldSystemFont(ofSize: 11)
            break
            
        default:
            self.constraintGuestViewHeight.constant = 50
            self.constraintEmailViewHight.constant = 50
            self.constraintStackViewHight.constant = 52
            self.lblPrivacy.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
            break
        }
        
        viewGuest.layer.borderWidth = 2
        viewGuest.layer.borderColor = Constant.appColor.purple.cgColor
        viewEmailLogin.layer.cornerRadius = 10
        viewGoogle.layer.cornerRadius = 10
        viewFacebook.layer.cornerRadius = 10
        viewGuest.layer.cornerRadius = 10
        viewApple.layer.cornerRadius = 10
    }
    
    @objc private func didSignInGoogle(_ notification: Notification) {
        // Update screen after user successfully signed in
        print("Update screen after user successfully signed in")
    }
    
    private func setupSocialLoginButtons() {
        
        if #available(iOS 13.0, *) {

            self.viewApple.isHidden = false
            
        } else {
            
            self.viewApple.isHidden = true
        }
    }
    
    func showBottomView() {
        
        constrainViewBottom.constant = -(self.viewBottom.frame.size.height + 60)
//        self.constraintBottomViewHeight.constant = 0
        self.constraintLogoVerticleSpace.constant = 0
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlUp], animations: {
            
            self.viewBottom.isHidden  = false
            self.constrainViewBottom.constant = 0
            let verticleSpace =  self.view.frame.size.height / 5
            self.constraintLogoVerticleSpace.constant = -verticleSpace
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func didTapSignIn(_ sender: UIButton) {
        
        self.view.isHidden = true
//        let vc = UsernameVC.instantiate(fromAppStoryboard: .registration)
//        self.navigationController?.pushViewController(vc, animated: true)
        let vc = RegistrationVC.instantiate(fromAppStoryboard: .registration)
        vc.isSignInVC = true
        setTrasitionAnimation(vc)
    }
    
    @IBAction func didTapSignUp(_ sender: UIButton) {
        
        self.view.isHidden = true
        let vc = RegistrationVC.instantiate(fromAppStoryboard: .registration)
        vc.isSignInVC = false
        setTrasitionAnimation(vc)
        
    }
    
    @IBAction func didTapGuestLogin(_ sender: UIButton) {
        
        //self.performAuthTokenGuestLogin()
        let deviceID =  UIDevice.current.identifierForVendor?.uuidString ?? ""
        self.doAuthRegistration(deviceID, loginType: .Guest)
    }
    
    @IBAction func didTapFBLogin(_ sender: UIButton) {
        
//        if #available(iOS 13.0, *) {
//
//        } else {
//            // Fallback on earlier versions
//            didTapSocialLogin(sender)
//        }
        
        ANLoader.showLoading()
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.facebookSignup, eventDescription: "")
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if (error == nil) {
                
                guard error == nil, let accessToken = result?.token else {
                    
                    ANLoader.hide()
                    return print(error ?? "Facebook access token is nil")
                }
                
                if #available(iOS 13.0, *) {
                    //self.login(with: accessToken)
                    self.doAuthRegistration(accessToken.tokenString, loginType: .Facebook)
                } else {
                    
                    if let token = AccessToken.current,
                        !token.isExpired {
                        // User is logged in, do work such as go to next view controller.
                        self.doAuthRegistration(token.tokenString, loginType: .Facebook)
                    }
                }
            }
        }
        
    }
    
    func setTrasitionAnimation(_ vc: UIViewController) {
        
        vc.modalPresentationStyle = .custom
        vc.setNeedsStatusBarAppearanceUpdate()
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromBottom
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func didTapSocialLogin(_ sender: UIButton) {

        if sender.tag == 0 {

            //Apple
            if #available(iOS 13.0, *) {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.appleidSignup, eventDescription: "")
                self .loginWithApple()
            }

        }
        else if sender.tag == 1 {
            //Google
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.googleSignup, eventDescription: "")
            self .loginWithGoogle()
        }
        else {

            //facebook
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.facebookSignup, eventDescription: "")
          //  self .loginWithFacebook()
        }
    }
}

//MARK:- Apple Login
@available(iOS 13.0, *)
extension PreRegistrationVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func loginWithApple() {
        
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.handleAuthorizationAppleIDButtonPress()
    }
    
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        // Create the authorization request
        let request = ASAuthorizationAppleIDProvider().createRequest()
        
        // Set scopes
        request.requestedScopes = [.email, .fullName]
        
        // Setup a controller to display the authorization flow
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        // Set delegates to handle the flow response.
        controller.delegate = self
        controller.presentationContextProvider = self
        
        // Action
        controller.performRequests()
    }
    
    //Delegates
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    // Handle authorization success
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Convert Data -> String
            guard let authorizationCode = appleIDCredential.authorizationCode, let authCode = String(data: authorizationCode, encoding: .utf8) else
            {
                ANLoader.hide()
                print("Problem with the authorizationCode")
                return
            }
            
            print("authorizationCode: ", authCode)
            //let authCode1 = String(data: authorizationCode, encoding: .ascii)
            //print("ASCII: ", authCode1)
            self.doAuthRegistration(authCode, loginType: .Apple)
        }
    }
    
    // Handle authorization failure
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("SIWA Authorization Failed: \(error)")
        ANLoader.hide()
    }
}

//MARK: - Login With Google
extension PreRegistrationVC {
    
    func loginWithGoogle() {
        
        GIDSignIn.sharedInstance()?.signIn()
    }

}

//MARK:- Facebook login for iOS 13+
@available(iOS 13.0, *)
extension PreRegistrationVC {
    
    fileprivate func login(with accessToken: FBSDKLoginKit.AccessToken) {
        // Get the request publishers
        let sessionAccessTokenPublisher = fetchSessionAccessToken(appId: accessToken.appID,
                                                                  accessToken: accessToken.tokenString)
        let profilePublisher = fetchProfile(userId: accessToken.userID, accessToken: accessToken.tokenString)
        
        // Start both requests in parallel and wait until all finish
        _ = Publishers
            .Zip(sessionAccessTokenPublisher, profilePublisher)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { sessionAccessToken, profile in
                // Perform the token exchange
                self.doAuthRegistration(sessionAccessToken, loginType: .Facebook)
            })
    }
    
    private func fetch(url: URL) -> AnyPublisher<[String: Any], URLError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated)) // Execute the request on a background thread
            .receive(on: DispatchQueue.main) // Execute the sink callbacks on the main thread
            .compactMap { try? JSONSerialization.jsonObject(with: $0.data) as? [String: Any] } // Get a JSON dictionary
            .eraseToAnyPublisher()
    }
    
    private func fetchSessionAccessToken(appId: String, accessToken: String) -> AnyPublisher<String, URLError> {
        var components = URLComponents(string: "\(fbAPIURL)/oauth/access_token")!
        components.queryItems = [URLQueryItem(name: "grant_type", value: "fb_attenuate_token"),
                                 URLQueryItem(name: "fb_exchange_token", value: accessToken),
                                 URLQueryItem(name: "client_id", value: appId)]
        
        return fetch(url: components.url!)
            .compactMap { $0["access_token"] as? String } // Get the Session Access Token
            .eraseToAnyPublisher()
    }
    
    private func fetchProfile(userId: String, accessToken: String) -> AnyPublisher<[String: Any], URLError> {
        var components = URLComponents(string: "\(fbAPIURL)/\(userId)")!
        components.queryItems = [URLQueryItem(name: "access_token", value: accessToken),
                                 URLQueryItem(name: "fields", value: "first_name,last_name,email")]
        
        return fetch(url: components.url!)
    }
}


// MARK:- Webservice Respones
extension PreRegistrationVC {
    
    func performAuthTokenGuestLogin() {
        
        let deviceID =  UIDevice.current.identifierForVendor?.uuidString ?? ""
        let params = ["device": deviceID]
        ANLoader.showLoading()
        WebService.URLResponse("auth/public/register/device", method: .post, parameters: params, headers: nil, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(deviceTokenDC.self, from: response)
                
                if FULLResponse.message?.lowercased() == "success" {
                    
                    guard let accessToken = FULLResponse.token else {
                        
                        ANLoader.hide()
                        SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Access token missing.", comment: ""))
                        return
                    }
                    
                    if let refreshToken = FULLResponse.token {
                        
                        UserDefaults.standard.set(refreshToken, forKey: Constant.UD_refreshToken)
                        if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                            
                            userDefaults.set(refreshToken as AnyObject, forKey: "WRefreshToken")
                            userDefaults.synchronize()
                        }
                    }
                    
                    self.uploadTheToken(accessToken: accessToken, userEmail: "")
                }
                else {

                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                
                ANLoader.hide()
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "auth/public/register/device", error: jsonerror.localizedDescription, code: "")
            }
            
        }){ (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func uploadTheToken(accessToken:String, userEmail: String) {
        
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
            
            self.performWSToUserConfig()
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
                
                ANLoader.hide()
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "notification/token", error: jsonerror.localizedDescription, code: "")
            }
            
        }){ (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUserConfig() {
        
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
                    
                    ANLoader.showLoading(disableUI: true)
                    SharedManager.shared.performWSToUpdateLanguage(id: id, isRefreshedToken: true, completionHandler: { status in
                        ANLoader.hide()
                        if status {
                            print("language updated successfully")
                        } else {
                            print("language updated failed")
                        }
                        
                        DispatchQueue.main.async {
                            ANLoader.hide()
                            self.appDelegate?.setHomeVC()
                        }
                    })
                }
                else {
                    
                    
                    DispatchQueue.main.async {
                        ANLoader.hide()
                        self.appDelegate?.setHomeVC()
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
    
    func doAuthRegistration(_ subjectToken: String, loginType: LoginType) {
        
        ANLoader.showLoading(disableUI: true)
        
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
                            ANLoader.hide()
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
                        self.uploadTheToken(accessToken: accessToken, userEmail: "")
                    }
                }
                
            case .failure(let error):
                
                ANLoader.hide()
                let errorAlert = error.localizedDescription
                print("failure: \(errorAlert)")
                DispatchQueue.main.async {
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Oops! Something went wrong. Please try again.", comment: ""), type: .alert)
                }
            }
        }
    }
}

//MARK:- GIDSignIn Delegate
extension PreRegistrationVC : GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        // Check for sign in error
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        // Perform any operations on signed in user here.
//        let userId = user.userID                  // For client-side use only!
//        let fullName = user.profile.name
//        let givenName = user.profile.givenName
//        let familyName = user.profile.familyName
        
        let idToken = user.authentication.idToken ?? "" // Safe to send to the server
        self.doAuthRegistration(idToken, loginType: .Google)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        print("didDisconnectWith", error.localizedDescription)
      // Perform any operations when the user disconnects from app here.
      // ...
    }
}
