//
//  LoginWithEmailVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 09/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Heimdallr

class LoginWithEmailVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var passwordImageView: UIImageView!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var linkToken = ""
    var email = ""
    var iconClick = true
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet var forgotPassword: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setLocalization()
        setupUI()
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Methods
    func setupUI() {
        
        passwordContainerView.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)

        passwordContainerView.layer.cornerRadius = 8

        passwordContainerView.layer.borderWidth = 1

        passwordContainerView.layer.borderColor = UIColor(displayP3Red: 0.871, green: 0.908, blue: 0.95, alpha: 1).cgColor
        
        passwordTextField.textColor = .black
        passwordTextField.placeholderColor = UIColor(displayP3Red: 0.744, green: 0.793, blue: 0.846, alpha: 1)
        
        
        saveButton.backgroundColor = Constant.appColor.lightGray

        saveButton.layer.cornerRadius = 15
        
        saveButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)
        
        
        passwordTextField.isSecureTextEntry = true
        passwordImageView.image = UIImage(named: "icn_hide_pwd")
        forgotPassword.setTitle(NSLocalizedString("Forgot Password", comment: ""), for: .normal)
        
    }
    
    func passwordContainerViewUI(isLoadingError:Bool) {
        
        if !isLoadingError {

            passwordContainerView.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)

            passwordContainerView.layer.cornerRadius = 8

            passwordContainerView.layer.borderWidth = 1

            passwordContainerView.layer.borderColor = UIColor(displayP3Red: 0.871, green: 0.908, blue: 0.95, alpha: 1).cgColor
            
            passwordTextField.textColor = .black
            passwordTextField.placeholderColor = UIColor(displayP3Red: 0.744, green: 0.793, blue: 0.846, alpha: 1)
            
            
            
        }
        else {

            passwordContainerView.layer.cornerRadius = 8

            passwordContainerView.layer.borderWidth = 1

            passwordContainerView.layer.borderColor = UIColor(displayP3Red: 0.447, green: 0.184, blue: 0.871, alpha: 1).cgColor
            
            passwordTextField.textColor = UIColor(displayP3Red: 0.447, green: 0.184, blue: 0.871, alpha: 1)
            
//            continueButton.backgroundColor = Constant.appColor.lightGray
//
//            continueButton.layer.cornerRadius = 15
//
//            continueButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)
        }
        
    }
    
    
    func setLocalization() {
        
        titleLabel.text = NSLocalizedString("Welcome back 👋", comment: "")
        passwordLabel.text = NSLocalizedString("Password", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        saveButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textField == self.passwordTextField {
            
            if isValid() {
                saveButton.backgroundColor = Constant.appColor.lightRed
                saveButton.setTitleColor(UIColor.white, for: .normal)
            }
            else {
                saveButton.backgroundColor = Constant.appColor.lightGray
                saveButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)
            }
            passwordContainerViewUI(isLoadingError: false)
            errorLabel.text = ""
            
        }
    }
    
    
    func isValid() -> Bool {
        
        if let passwordTxt = passwordTextField.text {
            
            // 1. Atleast 8 characters
            if passwordTxt.count >= 8 {
                return true
            }
            else {
                return false
            }
        }
        
        return false
    }
    
    // MARK: - Actions
    
    @IBAction func didTapSave(_ sender: Any) {
        
        if isValid() {
            
            self.doOAuthRegistration()
            
        }
        
    }
    
    @IBAction func didTapShowPassword(_ sender: Any) {
        
        
        if(iconClick == true) {
            passwordTextField.isSecureTextEntry = false
            passwordImageView.image = UIImage(named: "icn_show_pwd")
        } else {
            passwordTextField.isSecureTextEntry = true
            passwordImageView.image = UIImage(named: "icn_hide_pwd")
        }
        
        iconClick = !iconClick
        
    }
    
    @IBAction func didTapForgotPassword(_ sender: Any) {
        
        let vc = ResetPasswordNewVC.instantiate(fromAppStoryboard: .RegistrationSB)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


extension LoginWithEmailVC {
    
    func doOAuthRegistration() {
        
        saveButton.showLoader()
                
        let tokenURL = URL(string: WebserviceManager.shared.AUTH_TOKEN_URL)!
        let useCredentials = OAuthClientCredentials(id: WebserviceManager.shared.APP_CLIENT_ID, secret: WebserviceManager.shared.APP_CLIENT_SECRET)
        let heimdall = Heimdallr(tokenURL: tokenURL, credentials: useCredentials)

        var parameters = [String : String]()
        parameters["username"] = self.email
        parameters["password"] = self.passwordTextField.text ?? ""
        parameters["language"] = SharedManager.shared.languageId

        self.errorLabel.text = ""
        self.passwordContainerViewUI(isLoadingError: false)
        heimdall.requestAccessToken(grantType: "password", parameters: parameters) { result in
            
            switch result {
            case .success():
                
                DispatchQueue.main.async {
                    
                    if heimdall.hasAccessToken {
                        
                        if let accessToken = heimdall.accessToken?.accessToken {
                            
                            self.performWSToGetUserInfo(token: accessToken) {
                                
                                DispatchQueue.main.async {
                                    
                                    if SharedManager.shared.isGuestUser && SharedManager.shared.isLinkedUser == false {
                                        
                                        let guestToken = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""

                                        if !SharedManager.shared.isUserSetup {
                                            self.performWSToLinkUser(accessToken: accessToken, token: guestToken) {}
                                        }
                                    }
                                    
                                    //access token for today extension
                                    if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                                        userDefaults.set(accessToken as AnyObject, forKey: "accessToken")
                                        userDefaults.synchronize()
                                    }
                                    
                                    //set new token for guest login
                                    UserDefaults.standard.set(accessToken, forKey: Constant.UD_userToken)
                                    
                                    //let userEmail = self.txtEmail.text ?? ""
                                    //let userPass = self.txtPassword.text ?? ""
                                    UserDefaults.standard.set(self.email, forKey: Constant.UD_userEmail)
                                    //UserDefaults.standard.set(userPass, forKey: Constant.UD_userPassword)
                                    
                                    self.view.endEditing(true)
                                    self.saveButton.hideLoaderView()
                                    
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
                                    else {
                                        
                                        self.performWSToUpdateFirebaseTokenOnServer(userAccessToken: accessToken, fcmToken: fToken)
                                    }
                                    
                                    self.performWSToUserConfig()
                                    
                                }
                                print("Access Token", accessToken)

                            }
                        }
                        
                        if let refreshToken = heimdall.accessToken?.refreshToken {
                            
                            self.saveButton.hideLoaderView()
                            UserDefaults.standard.set(refreshToken, forKey: Constant.UD_refreshToken)
                            
                            if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                                
                                userDefaults.set(refreshToken as AnyObject, forKey: "WRefreshToken")
                                userDefaults.synchronize()
                            }
                        }
                    }
                }
                
            case .failure(let error):
                
                self.saveButton.hideLoaderView()
                let errorAlert = error.localizedDescription
                print("failure: \(errorAlert)")
                DispatchQueue.main.async {
                    self.errorLabel.text = errorAlert
                    self.passwordContainerViewUI(isLoadingError: true)
                }
                
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//
//                    self.viewHintPassword(hintText: errorAlert, textColor: UIColor(displayP3Red: 217.0/255.0, green: 77.0/255.0, blue: 69.0/255.0, alpha: 1), alertImgWidth: 20.0, isHidden: false)
//                }
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
    
    
    func performWSToLinkUser(accessToken: String, token: String, completionHandler: @escaping () -> Void) {
               
        let params = ["link_with": accessToken] //new token
        
        WebService.URLResponseAuth("auth/accounts/link", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            //ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userInfoDC.self, from: response)
                
                //access token for today extension
                if FULLResponse.success == true {
                    
                    self.linkToken = accessToken
                    SharedManager.shared.isGuestUser = false
                }
                else {
                    SharedManager.shared.showAlertLoader(message: FULLResponse.error ?? "")
                }
                
                if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                    userDefaults.set(token as AnyObject, forKey: "accessToken")
                    userDefaults.synchronize()
                }
                
                //set new token for guest login
                UserDefaults.standard.set(token, forKey: Constant.UD_userToken)
                
                completionHandler()
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "auth/accounts/link", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
                completionHandler()
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
            completionHandler()
        }
    }
    
    
    
    func performWSToUpdateFirebaseTokenOnServer(userAccessToken: String, fcmToken:String) {
        
        let HeaderToken  = userAccessToken
        let params = ["token":fcmToken]
        
        WebService.URLResponse("notification/token", method: .post, parameters: params, headers: HeaderToken, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.message?.lowercased() == "success" {
                    
                    UserDefaults.standard.set(true, forKey: Constant.UD_isHapticOn)

                }
                else {
                    
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                 //   print(FULLResponse.message ?? "")
                }
                
            } catch let jsonerror {
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "notification/token", error: jsonerror.localizedDescription, code: "")
            }
            
        }){ (error) in
            print("error parsing json objects",error)
        }
    }
    
    
    
    func performWSToUserConfig() {
        
        self.saveButton.showLoader()
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
                if let onboarded = FULLResponse.onboarded {
                    
                    SharedManager.shared.isOnboardingPreferenceLoaded = onboarded
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
                
                
                if SharedManager.shared.isUserSetup == false {
                    let vc = AddUsernameVC.instantiate(fromAppStoryboard: .RegistrationSB)
                    vc.isPresented = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    var id = ""
                    if let lang = SharedManager.shared.loadJsonLanguages(filename: "languages") {
                        
                        if let selectedIndex = lang.firstIndex(where: { $0.code == code }) {
                            
                            id = lang[selectedIndex].id ?? ""
                        }
                        
                    }
                    
                    self.saveButton.showLoader()
//                    SharedManager.shared.performWSToUpdateLanguage(id: id, isRefreshedToken: true, completionHandler: { status in
//                        self.saveButton.hideLoaderView()
//                        ANLoader.hide()
//                        if status {
//                            print("language updated successfully")
//                        } else {
//                            print("language updated failed")
//                        }
//
//
//                    })
//
                    let token = UserDefaults.standard.object(forKey: Constant.UD_userToken) as? String ?? ""
                    let params = ["region": LanguageHelper.languageShared.selectedRegion?.id ?? "ee4add73-b717-4e32-bffb-fecbf82ee6d9"]

                    WebService.URLResponseJSONRequest("news/regions/", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
                        do{
                            let FULLResponsee = try
                                JSONDecoder().decode(messageData.self, from: response)
                            
                            print("PARMS REGION = \(params)")
                            if FULLResponsee.message?.lowercased() == "success" {
                                
                                LanguageHelper.shared.performWSToUpdateUserContentLanguages {
                                    self.saveButton.hideLoaderView()
                                 
                                    DispatchQueue.main.async {

                                        if SharedManager.shared.isUserSetup == false {
                                            let vc = AddUsernameVC.instantiate(fromAppStoryboard: .RegistrationSB)
                                            vc.isPresented = false
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                        else if FULLResponse.onboarded ==  false {

                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                let vc = SelectTopicsVC.instantiate(fromAppStoryboard: .RegistrationSB)
                                                self.navigationController?.pushViewController(vc, animated: true)
                                            }

                                        }
                                        else {
                                            self.appDelegate?.setHomeVC()

                                        }
                                    }
                                }
                                
//                                SharedManager.shared.performWSToUpdateLanguage(id: LanguageHelper.languageShared.selectedLanguage?.id ?? "ee4add73-b717-4e32-bffb-fecbf82ee6d9", isRefreshedToken: true, completionHandler: { status in
//
//                                })
                            }
                            
                        } catch let jsonerror {
                            self.saveButton.hideLoaderView()
                            print("error parsing json objects",jsonerror)
                        }
                    }) { (error) in
                        self.saveButton.hideLoaderView()
                        print("error parsing json objects",error)

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
