//
//  LoginVC.swift
//  Bullet
//
//  Created by Mahesh on 20/06/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
//import FacebookCore
//import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import Combine
import ActiveLabel
import GoogleSignIn
import Heimdallr

class LoginVC: UIViewController {

    @IBOutlet weak var lblLoginTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewGoogle: UIView!
    @IBOutlet weak var viewFacebook: UIView!
    @IBOutlet weak var viewApple: UIView!
    
    @IBOutlet weak var imgApple: UIImageView!
    
    @IBOutlet weak var lblApple: UILabel!
    @IBOutlet weak var lblGoogle: UILabel!
    @IBOutlet weak var lblFacebook: UILabel!
    @IBOutlet weak var lblEmail: UILabel!

    @IBOutlet weak var lblPrivacy: ActiveLabel!

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

        if #available(iOS 13.0, *) {

            self.viewApple.isHidden = false
            
        } else {
            
            self.viewApple.isHidden = true
        }
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self

        self.setupLocalization()
        self.designView()
    }
    
    func setupLocalization() {

        lblApple.text = NSLocalizedString("Continue with Apple", comment: "")
        lblGoogle.text = NSLocalizedString("Continue with Google", comment: "")
        lblFacebook.text = NSLocalizedString("Continue with Facebook", comment: "")
        lblEmail.text = NSLocalizedString("Continue with email", comment: "")

        lblLoginTitle.text = NSLocalizedString("Login or create an account", comment: "")
        lblDescription.text = NSLocalizedString("Login or create an account to read, share &, and comment on stories from all your favorite topics.", comment: "")
                
        let privacyText = NSLocalizedString("By clicking Continue, you agree with our Terms.", comment: "") + " " + NSLocalizedString("Learn how we process your data", comment: "") + NSLocalizedString("in our Privacy Policy.", comment: "") //privacyText1 + " " + privacyText2 + ". " + privacyText3 + " " + privacyText4 + "."
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
    }
    
    func designView() {
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        //Apple
        viewApple.cornerRadius = 10
        
        imgApple.image = UIImage(named: "icn_apple")?.withRenderingMode(.alwaysTemplate)
        imgApple.theme_tintColor = GlobalPicker.textWBColor
        viewApple.theme_backgroundColor = GlobalPicker.bgBWColor
        lblApple.theme_textColor = GlobalPicker.textWBColor
        

        //Email
        viewEmail.cornerRadius = 10
        viewEmail.theme_backgroundColor = GlobalPicker.bgLoginColor
        lblEmail.theme_textColor = GlobalPicker.textBWColor

        //Google
        viewGoogle.cornerRadius = 10
        
        //Facebook
        viewFacebook.cornerRadius = 10
        viewFacebook.theme_backgroundColor = GlobalPicker.bgLoginColor
        lblFacebook.theme_textColor = GlobalPicker.textBWColor


        lblLoginTitle.theme_textColor = GlobalPicker.textBWColor
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
    
    //MARK:- Button Actions
    @IBAction func didTapBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSignUp(_ sender: UIButton) {
        
        let vc = RegistrationVC.instantiate(fromAppStoryboard: .registration)
        vc.isSignInVC = false
        setTrasitionAnimation(vc)
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
            self .loginWithFacebook()
        }
    }
    
    func loginWithGoogle() {
        
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func loginWithFacebook() {
        
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
    
    func doAuthRegistration(_ subjectToken: String, loginType: LoginType) {
        
        ANLoader.showLoading(disableUI: false)
        
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
                        
                        self.performWSToGetUserInfo(token: accessToken) {
                            
                            if let refreshToken = heimdall.accessToken?.refreshToken {
                                
                                UserDefaults.standard.set(refreshToken, forKey: Constant.UD_refreshToken)
                                if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                                    
                                    userDefaults.set(refreshToken as AnyObject, forKey: "WRefreshToken")
                                    userDefaults.synchronize()
                                }
                            }
                            self.uploadLinkUserToken(accessToken: accessToken)
                        }

                    }
                }
                
            case .failure(let error):
                
                ANLoader.hide()
                let errorAlert = error.localizedDescription
                print("failure: \(errorAlert)")
            }
        }
    }
    
    func performWSToGetUserInfo(token: String, completionHandler: @escaping () -> Void) {
       
        WebService.URLResponseAuth("auth/info", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            //ANLoader.hide()
            do {
                let FULLResponse = try
                    JSONDecoder().decode(userInfoDC.self, from: response)
                
                SharedManager.shared.isUserSetup = FULLResponse.results?.setup ?? false

                if let userEmail = FULLResponse.results?.email {
                    
                    UserDefaults.standard.set(userEmail, forKey: Constant.UD_userEmail)
                }
                if let isSocialLinked = FULLResponse.results?.hasPassword {
                    
                    UserDefaults.standard.set(isSocialLinked, forKey: Constant.UD_isSocialLinked)
                }
                          
                completionHandler()
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "auth/info", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
                completionHandler()
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
            completionHandler()
        }
    }
}

//MARK:- Webservice
extension LoginVC {
    
    func uploadLinkUserToken(accessToken: String) {
                
        if SharedManager.shared.isUserSetup {
            
            //access token for today extension
            if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                userDefaults.set(accessToken as AnyObject, forKey: "accessToken")
                userDefaults.synchronize()
            }
            
            //set new token for guest login
            UserDefaults.standard.set(accessToken, forKey: Constant.UD_userToken)

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

        }
        else {
            
            self.performWSToLinkUser(accessToken: accessToken)
        }
        
    }
    
    func performWSToLinkUser(accessToken: String) {
       
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        let params = ["link_with": accessToken]
        
        WebService.URLResponseAuth("auth/accounts/link", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            //ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userInfoDC.self, from: response)
                
                if FULLResponse.success == true {
                    SharedManager.shared.isGuestUser = false
                }
                else {
                    SharedManager.shared.showAlertLoader(message: FULLResponse.error ?? "", type: .alert)
                }

                //access token for today extension
                if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                    userDefaults.set(token as AnyObject, forKey: "accessToken")
                    userDefaults.synchronize()
                }
                
                //set new token for guest login
                UserDefaults.standard.set(token, forKey: Constant.UD_userToken)

                let fToken = UserDefaults.standard.string(forKey: Constant.UD_firebaseToken) ?? ""
                if fToken == "" {
                    
                    self.appDelegate?.registerFirebaseToken { (Bool) in
                        
                        let fcmNewToken = UserDefaults.standard.string(forKey: Constant.UD_firebaseToken) ?? ""
                        self.performWSToUpdateFirebaseTokenOnServer(userAccessToken: token, fcmToken: fcmNewToken)
                    }
                }
                else{
                    
                    self.performWSToUpdateFirebaseTokenOnServer(userAccessToken: token, fcmToken: fToken)
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "auth/accounts/link", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUpdateFirebaseTokenOnServer(userAccessToken: String, fcmToken:String) {
        
        let HeaderToken = userAccessToken
        let params = ["token":fcmToken]
        
        WebService.URLResponse("notification/token", method: .post, parameters: params, headers: HeaderToken, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.message?.lowercased() == "success" {

                    self.performWSToUserConfig()
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
                    SharedManager.shared.speedRate = preference.narration?.speed_rate ?? ["1.0x": 1]
                }
                
                if let user = FULLResponse.user {
                    
                    SharedManager.shared.userId = user.id ?? ""
                    
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(user) {
                        SharedManager.shared.userDetails = encoded
                    }
                    
                    SharedManager.shared.isLinkedUser = user.guestValid ?? false
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
                
                self.dismiss(animated: true, completion: nil)
                
            } catch let jsonerror {
            
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
}

//MARK:- Apple Login
@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func loginWithApple() {
        
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.handleAuthorizationAppleIDButtonPress()
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
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

//MARK:- Facebook login for iOS 13+
@available(iOS 13.0, *)
extension LoginVC {
    
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

//MARK:- GIDSignIn Delegate
extension LoginVC: GIDSignInDelegate {
    
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
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("didDisconnectWith", error.localizedDescription)
      // Perform any operations when the user disconnects from app here.
      // ...
    }
}
