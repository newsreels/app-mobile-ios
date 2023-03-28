//
//  RegistrationCompletedVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 09/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Heimdallr

class RegistrationCompletedVC: UIViewController {

    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var email = ""
    var password = ""
    var linkToken = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setLocalization()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    
    // MARK : - Methods
    func setupUI() {
        continueButton.backgroundColor = Constant.appColor.lightRed

        continueButton.layer.cornerRadius = 15
        
        continueButton.setTitleColor(.white, for: .normal)
    }
    
    func setLocalization() {
        title1Label.text = NSLocalizedString("You have completed the registration!", comment: "")
        title2Label.text = NSLocalizedString("A cofirmation email has been sent to you.", comment: "")
        continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
    }
    
    
    // MARK: - Actions
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
    
        // Check email verified api
        performWSToCheckEmail()
        
//        appDelegate?.setHomeVC()
    }
    
    
    
}

extension RegistrationCompletedVC {
    
    func performWSToCheckEmail() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        continueButton.showLoader()
        
        let params = ["email": email]
        WebService.URLResponseAuth("auth/verify", method: .post, parameters: params, headers: nil, withSuccess: { (response) in
            
            self.continueButton.hideLoaderView()
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.exist == true {
                    // Email verified
                    
                    SharedManager.shared.showAlertLoader(message: "Email verifcation completed successfully.", type: .alert)
                    
                    self.doOAuthRegistration()
                    
                }
                else {
                    // Signup
                    SharedManager.shared.showAlertLoader(message: "Please verify your email.", type: .error)
                }
                
            } catch let jsonerror {
                self.continueButton.hideLoaderView()
                print("error parsing json objects",jsonerror)
            }
        }){ (error) in
            
            self.continueButton.hideLoaderView()
            print("error parsing json objects",error)
        }
    }
    
}


extension RegistrationCompletedVC {
    
    func doOAuthRegistration() {
        
        continueButton.showLoader()
//        self.showLoaderInVC()
        let tokenURL = URL(string: WebserviceManager.shared.AUTH_TOKEN_URL)!
        let useCredentials = OAuthClientCredentials(id: WebserviceManager.shared.APP_CLIENT_ID, secret: WebserviceManager.shared.APP_CLIENT_SECRET)
        let heimdall = Heimdallr(tokenURL: tokenURL, credentials: useCredentials)

        var parameters = [String : String]()
        parameters["username"] = self.email
        parameters["password"] = self.password
        parameters["language"] = SharedManager.shared.languageId

        heimdall.requestAccessToken(grantType: "password", parameters: parameters) { result in
            self.continueButton.hideLoaderView()
//            self.hideLoaderVC()
            switch result {
            case .success():
                
                DispatchQueue.main.async {
                    
                    if heimdall.hasAccessToken {
                        
                        if let accessToken = heimdall.accessToken?.accessToken {
                            
                            self.performWSToGetUserInfo(token: accessToken) {
                                
                                DispatchQueue.main.async {
                                    
                                    if SharedManager.shared.isGuestUser && SharedManager.shared.isLinkedUser == false {
                                        
                                        let guestToken = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""

//                                        if !SharedManager.shared.isUserSetup {
//                                            self.performWSToLinkUser(accessToken: accessToken, token: guestToken) {}
//                                        }
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
                                    
//                                    SharedManager.shared.performWSToGetReelsData(completionHandler: { status in
//                                        print("status", status)
//                                    })
                                    
                                    let token = UserDefaults.standard.object(forKey: Constant.UD_userToken) as? String ?? ""
                                    let params = ["region": LanguageHelper.languageShared.selectedRegion?.id ?? "ee4add73-b717-4e32-bffb-fecbf82ee6d9"]

                                    
                                    WebService.URLResponseJSONRequest("news/regions/", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
                                        do{
                                            let FULLResponsee = try
                                                JSONDecoder().decode(messageData.self, from: response)
                                            
                                            print("PARMS REGION = \(params)")
                                            if FULLResponsee.message?.lowercased() == "success" {
                                                SharedManager.shared.isTabReload = true
                                                
                                                SharedManager.shared.performWSToUpdateLanguage(id: LanguageHelper.languageShared.selectedLanguage?.id ?? "ee4add73-b717-4e32-bffb-fecbf82ee6d9", isRefreshedToken: true, completionHandler: { status in
                                                    ANLoader.hide()
                                                    if status {
                                                        print("SELECTED LANGUAGE = \(LanguageHelper.languageShared.selectedLanguage?.id ?? "ee4add73-b717-4e32-bffb-fecbf82ee6d9")")
                                                        print("language updated successfully")
                                                    } else {
                                                        print("language updated failed")
                                                    }
                                                    
                                                    DispatchQueue.main.async {
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
                                                        
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                            if SharedManager.shared.isUserSetup {
                                                                self.appDelegate?.setHomeVC()
                                                            }
                                                            else {
                                                                let vc = AddUsernameVC.instantiate(fromAppStoryboard: .RegistrationSB)
                                                                self.navigationController?.pushViewController(vc, animated: true)
                                                            }
                                                        }
                                                        
                                                       
                                                        
                                                    }
                                                })
                                            }
                                            
                                        } catch let jsonerror {
                                            ANLoader.hide()
                                            print("error parsing json objects",jsonerror)
                                        }
                                    }) { (error) in
                                        ANLoader.hide()
                                        print("error parsing json objects",error)

                                    }

                                    
                                }
                                print("Access Token", accessToken)

                            }
                        }
                        
                        if let refreshToken = heimdall.accessToken?.refreshToken {
                            
                            self.continueButton.hideLoaderView()
//                            self.hideLoaderVC()
                            UserDefaults.standard.set(refreshToken, forKey: Constant.UD_refreshToken)
                            
                            if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                                
                                userDefaults.set(refreshToken as AnyObject, forKey: "WRefreshToken")
                                userDefaults.synchronize()
                            }
                        }
                    }
                }
                
            case .failure(let error):
                
                self.continueButton.hideLoaderView()
//                self.hideLoaderVC()
                let errorAlert = error.localizedDescription
                print("failure: \(errorAlert)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    
//                    self.viewHintPassword(hintText: errorAlert, textColor: UIColor(displayP3Red: 217.0/255.0, green: 77.0/255.0, blue: 69.0/255.0, alpha: 1), alertImgWidth: 20.0, isHidden: false)
                }
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
    
}
