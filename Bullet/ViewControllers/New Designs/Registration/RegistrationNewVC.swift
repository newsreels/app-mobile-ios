//
//  RegistrationNewVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 07/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import GoogleSignIn
import Combine
import Heimdallr
import NVActivityIndicatorView
import IQKeyboardManagerSwift

class RegistrationNewVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    
    @IBOutlet weak var appleLoginView: UIView!
    @IBOutlet weak var googleLoginView: UIView!
    @IBOutlet weak var fbLoginView: UIView!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var appleLabel: UILabel!
    @IBOutlet weak var googleLabel: UILabel!
    @IBOutlet weak var fbLabel: UILabel!
    
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var continueTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var orLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private let fbAPIURL = "https://graph.facebook.com/v6.0"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setLocalization()
        setupUI()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Methods
    func setupUI() {
        
        
        
        emailContainerViewUI(isLoadingError: false)
        
        continueButton.layer.cornerRadius = 15
        
        continueButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)
        continueButton.backgroundColor = Constant.appColor.lightGray
        
        
        appleLoginView.layer.cornerRadius = 8

        appleLoginView.layer.borderWidth = 1

        appleLoginView.layer.borderColor = UIColor.black.cgColor
        
        googleLoginView.layer.cornerRadius = 8

        googleLoginView.layer.borderWidth = 1

        googleLoginView.layer.borderColor = UIColor.black.cgColor
        
        fbLoginView.layer.cornerRadius = 8

        fbLoginView.layer.borderWidth = 1

        fbLoginView.layer.borderColor = UIColor.black.cgColor
        
        blurView.alpha = 0
        
        if self.view.frame.size.height < 670 {
            continueHeightConstraint.constant = 48
            continueTopConstraint.constant = 20
            continueBottonConstraint.constant = 15
            orLabelBottomConstraint.constant = 20
            appleHeightConstraint.constant = 48
            titleTopConstraint.constant = 15
        }
        else {
            continueHeightConstraint.constant = 48
            continueTopConstraint.constant = 40
            continueBottonConstraint.constant = 30
            orLabelBottomConstraint.constant = 40
            appleHeightConstraint.constant = 55
            titleTopConstraint.constant = 35
        }
    }
    
    
    func setLocalization() {
        
        titleLabel.text = NSLocalizedString("Welcome to Newsreels", comment: "")
        descriptionLabel.text = NSLocalizedString("Let’s start with your email", comment: "")
        emailLabel.text = NSLocalizedString("Email", comment: "")
        continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        orLabel.text = NSLocalizedString("or", comment: "")
        appleLabel.text = NSLocalizedString("Continue with Apple", comment: "")
        googleLabel.text = NSLocalizedString("Continue with Google", comment: "")
        fbLabel.text = NSLocalizedString("Continue with Facebook", comment: "")
        
        btnClose.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
    }
    
    func emailContainerViewUI(isLoadingError:Bool) {
        
        if !isLoadingError {

            emailContainerView.layer.cornerRadius = 8

            emailContainerView.layer.borderWidth = 1

            emailContainerView.layer.borderColor = UIColor(displayP3Red: 0.871, green: 0.908, blue: 0.95, alpha: 1).cgColor
            
            emailTextField.textColor = .black
            emailTextField.placeholderColor = UIColor(displayP3Red: 0.744, green: 0.793, blue: 0.846, alpha: 1)
        }
        else {

            emailContainerView.layer.cornerRadius = 8

            emailContainerView.layer.borderWidth = 1

            emailContainerView.layer.borderColor = UIColor(displayP3Red: 0.447, green: 0.184, blue: 0.871, alpha: 1).cgColor
            
            emailTextField.textColor = UIColor(displayP3Red: 0.447, green: 0.184, blue: 0.871, alpha: 1)
        }
    }
    
    func showLoader(button: UIButton) {
        
        DispatchQueue.main.async {
            
            self.view.bringSubviewToFront(button)
            self.blurView.alpha = 0.5
            button.titleLabel?.removeFromSuperview()
            
            if button == self.continueButton {
                self.continueButton.showLoader()
                self.view.bringSubviewToFront(self.continueButton)
            }
            else if button == self.appleButton {
                self.appleButton.showLoader(color: Constant.appColor.lightRed)
                self.view.bringSubviewToFront(self.appleLoginView)
            }
            else if button == self.googleButton {
                self.googleButton.showLoader(color: Constant.appColor.lightRed)
                self.view.bringSubviewToFront(self.googleLoginView)
            }
            else if button == self.fbButton {
                self.fbButton.showLoader(color: Constant.appColor.lightRed)
                self.view.bringSubviewToFront(self.fbLoginView)
            }
            
        }
        
        
    }
    
    func hideloader() {
        DispatchQueue.main.async {
            self.continueButton.hideLoaderView()
            self.appleButton.hideLoaderView()
            self.googleButton.hideLoaderView()
            self.fbButton.hideLoaderView()
            
            self.blurView.alpha = 0
            self.view.bringSubviewToFront(self.blurView)

            self.continueButton.addSubview(self.continueButton.titleLabel ?? UILabel())
            self.appleButton.addSubview(self.appleButton.titleLabel ?? UILabel())
            self.googleButton.addSubview(self.googleButton.titleLabel ?? UILabel())
            self.fbButton.addSubview(self.fbButton.titleLabel ?? UILabel())
        }
    }
    
    // MARK: - Actions
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        let user_Name = self.emailTextField.text ?? ""
        if user_Name.isEmpty {
            
//            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: NSLocalizedString("Enter email.", comment: ""))
        }
        else {
            errorLabel.text = ""
            self.performWSToCheckEmail()
            
        }
    }
    @IBAction func didTapAppleLogin(_ sender: Any) {
        //Apple
        if #available(iOS 13.0, *) {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.appleidSignup, eventDescription: "")
            self.loginWithApple()
        }
    }
    
    @IBAction func didTapGoogleLogin(_ sender: Any) {
        //Google
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.googleSignup, eventDescription: "")
        self.loginWithGoogle()
    }
    
    @IBAction func didTapFBLogin(_ sender: Any) {
        
        showLoader(button: self.fbButton)
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.facebookSignup, eventDescription: "")
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if (error == nil) {
                
                guard error == nil, let accessToken = result?.token else {
                    
                    self.hideloader()
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
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textField == self.emailTextField {
            
            errorLabel.text = ""
            emailContainerViewUI(isLoadingError: false)
            if let emailTxt = textField.text {
                if emailTxt.isValidEmail() {
                    
                    self.continueButton.backgroundColor = Constant.appColor.lightRed
                    self.continueButton.setTitleColor(.white, for: .normal)
                }
                else {
                    
                    self.continueButton.backgroundColor = Constant.appColor.lightGray
                    continueButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)
                    
                }
            }
        }
    }
    
    
    
}


//MARK:- Apple Login
@available(iOS 13.0, *)
extension RegistrationNewVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
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
                hideloader()
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
        hideloader()
    }
}


//MARK: - Login With Google
extension RegistrationNewVC {
    
    func loginWithGoogle() {
        
        GIDSignIn.sharedInstance()?.signIn()
    }

}


//MARK:- Facebook login for iOS 13+
@available(iOS 13.0, *)
extension RegistrationNewVC {
    
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
extension RegistrationNewVC : GIDSignInDelegate {
    
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

extension RegistrationNewVC {
    
    func performWSToCheckEmail() {
        
        let emailTxt = self.emailTextField.text ?? ""
        if !emailTxt.isValidEmail() {
 
//            self.viewHintEmail(hintText: NSLocalizedString("Invalid email format", comment: ""), buttonTittle: NSLocalizedString("NEXT", comment: ""), isHidden: false)
            
//            errorLabel.text = NSLocalizedString("Invalid email format", comment: "")
//            emailContainerViewUI(isLoadingError: true)
            return
        }
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let params = ["email": emailTxt.removeWhitespace()]
        
        
        showLoader(button: continueButton)
        
        WebService.URLResponseAuth("auth/verify", method: .post, parameters: params, headers: nil, withSuccess: { (response) in
            
            self.hideloader()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.exist == true {
//
//                    self.isSignInVC = true
//                    self .animateShowHidePasseordView()
//                    self.viewHintEmail(hintText:"", buttonTittle: "", isHidden: true)
//                self.errorLabel.text = NSLocalizedString("Username already taken. Enter a new one.", comment: "")
//                self.emailContainerViewUI(isLoadingError: true)
                
                    // Login
                    self.errorLabel.text = ""
                    self.emailContainerViewUI(isLoadingError: false)
                    self.emailTextField.resignFirstResponder()
                    let vc = LoginWithEmailVC.instantiate(fromAppStoryboard: .RegistrationSB)
                    vc.email = self.emailTextField.text ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    // Signup
                    self.errorLabel.text = ""
                    self.emailContainerViewUI(isLoadingError: false)
                    self.emailTextField.resignFirstResponder()
                    
                    let vc = AddPasswordVC.instantiate(fromAppStoryboard: .RegistrationSB)
                    vc.email = self.emailTextField.text?.trim() ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                    
//                    let vc = AddUsernameVC.instantiate(fromAppStoryboard: .RegistrationSB)
//                    self.navigationController?.pushViewController(vc, animated: true)
//
                    
//                    self.isSignInVC = false
//                    self.txtEmail.resignFirstResponder()
//                    self.viewHintEmail(hintText:"", buttonTittle: "", isHidden: true)
//                    self.animateShowHideOTPView()
                }
                
            } catch let jsonerror {
                self.hideloader()
                do{
                    let FULLResponse = try
                        JSONDecoder().decode(checkEmailErrors.self, from: response)
//                    self.viewHintEmail(hintText: FULLResponse.errors?.email ?? "", buttonTittle: NSLocalizedString("NEXT", comment: ""), isHidden: false)
                    
                    self.errorLabel.text = NSLocalizedString(FULLResponse.errors?.email ?? "", comment: "")
                    self.emailContainerViewUI(isLoadingError: true)
                    print("error parsing json objects",jsonerror)
                    
                }
                catch let jsonerror {
                    self.hideloader()
                    do{
                        
                        print("error parsing json objects",jsonerror)
                        SharedManager.shared.logAPIError(url: "auth/register", error: jsonerror.localizedDescription, code: "")
                    }
                }
            }
            
            self.hideloader()
            
        }){ (error) in
            
            self.hideloader()
            print("error parsing json objects",error)
        }
    }
    
}
