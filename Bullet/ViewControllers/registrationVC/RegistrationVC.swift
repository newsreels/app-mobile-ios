//
//  RegistrationVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 16/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Heimdallr
import OTPFieldView

enum backButtonTapped {
    
    case emailStage
    case otp
    case passwordStage
}

class RegistrationVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lblEmailForUser: UILabel!
    @IBOutlet weak var lblPaswordTitle: UILabel!
    @IBOutlet weak var lblPaswordHintText: UILabel!
    @IBOutlet weak var lblEmailHintText: UILabel!
    @IBOutlet weak var lblNextBtnText: UILabel!
    @IBOutlet weak var lblPrivecy: UILabel!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnAgreement: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    
    @IBOutlet weak var imgPwd: UIImageView!
    @IBOutlet weak var imgPwdAlert: UIImageView!
    //@IBOutlet weak var imgNextArrow: UIImageView!
    
    @IBOutlet weak var lblPasswordStrength: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var testEmailField: UITextField!
    
    @IBOutlet weak var lblPassword: UILabel!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPasswordSignUp: UIView!
    @IBOutlet weak var viewNextButtonBG: GradientShadowView!
    @IBOutlet weak var viewAgreement: UIView!
    @IBOutlet weak var viewEmailHint: UIView!
    @IBOutlet weak var viewPasswordHint: UIView!
    @IBOutlet weak var viewShowHidePassword: UIView!
    
    @IBOutlet weak var constraintViewEmailBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintimgPwdAlertWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintPasswordAlert: NSLayoutConstraint!
    @IBOutlet weak var constraintPasswordAlertLeading: NSLayoutConstraint!
    @IBOutlet weak var choosePasswordLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewUnderLineEmail: UIView!
    @IBOutlet weak var viewUnderLinePassword: UIView!
    
    //VIew OTP
    @IBOutlet weak var viewOTP: UIView!
    @IBOutlet weak var lblOtpTitle: UILabel!
    @IBOutlet weak var lblOtpEmail: UILabel!
    @IBOutlet var otpTextFieldView: OTPFieldView!
    @IBOutlet weak var lblOtpError: UILabel!
    @IBOutlet weak var btResendOtp: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var backButtonCurrentStage = backButtonTapped.emailStage
    var isSignInVC = false
    var isFromProfileVC = false
    var linkToken = ""

    var hasEnteredOTP = false
    var OTPString = ""
    
    var user_Name = ""
    var user_Pass = ""
    var audiance = ""
    var isForgotPwd = "false"
    var isAgreementAccepted = "false"
    var isHelpVCPresented = false
    
    // let pageControl = DefaultPageControl()
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()
        self.constraintPasswordAlertLeading.constant = 24
        pageControl.currentPage = 0
        
        lblNextBtnText.text = NSLocalizedString("NEXT", comment: "")
//        self.ConstraintNextBtnLeading.constant = 6
//        self.imgNextArrow.isHidden = true
        self .setupUserUI()
        
        if self.isFromProfileVC {
            
            self.isForgotPwd = "true"
            self.backButtonCurrentStage = .passwordStage
            self.backButtonnStages()
        }
        
        
        self.view.backgroundColor = .black
    }
    
    func setupLocalization() {
        
        lblEmail.text = NSLocalizedString("What's your email?", comment: "")
        txtEmail.placeholder = NSLocalizedString("Your Email", comment: "")
//        lblEmailHintText.text = NSLocalizedString("", comment: "")
        lblPassword.text = NSLocalizedString("Choose your password", comment: "")

        txtPassword.placeholder = NSLocalizedString("Enter password", comment: "")
        lblEmailForUser.text = NSLocalizedString("for ___", comment: "")
        btnForgotPassword.setTitle(NSLocalizedString("Forgot Password?", comment: ""), for: .normal)
        btnHelp.setTitle(NSLocalizedString("HELP", comment: ""), for: .normal)
        
        //OTP VIEW
        lblOtpTitle.text = NSLocalizedString("Enter verification code", comment: "")
        btResendOtp.setTitle(NSLocalizedString("RESEND", comment: ""), for: .normal)
//        lblNextBtnText.text = NSLocalizedString("", comment: "")
    }
    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.txtEmail.semanticContentAttribute = .forceRightToLeft
                self.txtEmail.textAlignment = .right
                self.txtPassword.semanticContentAttribute = .forceRightToLeft
                self.txtPassword.textAlignment = .right
                
                self.lblEmail.semanticContentAttribute = .forceRightToLeft
                self.lblEmail.textAlignment = .right
                
                self.lblPassword.semanticContentAttribute = .forceRightToLeft
                self.lblPassword.textAlignment = .right
                
                self.lblEmailForUser.semanticContentAttribute = .forceRightToLeft
                self.lblEmailForUser.textAlignment = .right
                
                self.lblOtpEmail.semanticContentAttribute = .forceRightToLeft
                self.lblOtpEmail.textAlignment = .right

                self.btnForgotPassword.semanticContentAttribute = .forceRightToLeft
                
                self.btnHelp.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
                
                self.lblOtpTitle.semanticContentAttribute = .forceRightToLeft
                self.lblOtpTitle.textAlignment = .right
                
                self.otpTextFieldView.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            
        } else {
            DispatchQueue.main.async {
                self.txtEmail.semanticContentAttribute = .forceLeftToRight
                self.txtEmail.textAlignment = .left
                self.txtPassword.semanticContentAttribute = .forceLeftToRight
                self.txtPassword.textAlignment = .left
                
                self.lblEmail.semanticContentAttribute = .forceLeftToRight
                self.lblEmail.textAlignment = .left
                
                self.lblPassword.semanticContentAttribute = .forceLeftToRight
                self.lblPassword.textAlignment = .left
                
                self.lblEmailForUser.semanticContentAttribute = .forceLeftToRight
                self.lblEmailForUser.textAlignment = .left
                
                self.lblOtpEmail.semanticContentAttribute = .forceLeftToRight
                self.lblOtpEmail.textAlignment = .left

                self.btnForgotPassword.semanticContentAttribute = .forceLeftToRight
                
                self.btnHelp.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
                
                self.lblOtpTitle.semanticContentAttribute = .forceLeftToRight
                self.lblOtpTitle.textAlignment = .left
                
                self.otpTextFieldView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isSignInVC {
            
            self.txtEmail.textContentType = .username
            self.txtEmail.keyboardType = .emailAddress
            self.txtPassword.textContentType = .password
        }
        else{
            
            // self.txtEmail.textContentType = .username
            self.txtEmail.textContentType = .emailAddress
            self.txtEmail.keyboardType = .emailAddress
            if #available(iOS 12.0, *) {
                self.txtPassword.textContentType = .newPassword
            } else {
                // Fallback on earlier versions
            }
        }
        txtPassword.delegate = self // if this is programmatic make sure to add UITextFieldDelegate after the class name
        
        // 3A. Add a KVO observer to the passwordTextField's "text" keypath
        txtPassword.addObserver(self, forKeyPath: "text", options: [.old, .new], context: nil)
        self.setPrivacyAndTermsText()
        
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        IQKeyboardManager.shared.keyboardAppearance = .dark
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        
        self.txtEmail.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        self.txtPassword.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        if self.isFromProfileVC {
            
            self.viewEmail.isHidden = true
        }
        else {
            self.txtEmail.becomeFirstResponder()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "text" {
            handleTextInputChanged()
        }
    }
    
    //OTP
    func setupOtpView() {
        
        self.otpTextFieldView.fieldsCount = 6
        self.otpTextFieldView.fieldBorderWidth = 3
        self.otpTextFieldView.defaultBorderColor = "#E01335".hexStringToUIColor()
        self.otpTextFieldView.filledBorderColor = "#E01335".hexStringToUIColor()
        self.otpTextFieldView.fieldFont = UIFont(name: Constant.FONT_Mulli_EXTRABOLD, size: 22)!
        self.otpTextFieldView.cursorColor = UIColor.white
        self.otpTextFieldView.displayType = .underlinedBottom
        self.otpTextFieldView.fieldSize = 45
        self.otpTextFieldView.separatorSpace = 12
        self.otpTextFieldView.shouldAllowIntermediateEditing = false
        self.otpTextFieldView.delegate = self
        self.otpTextFieldView.initializeUI()
        
        for view in self.otpTextFieldView.subviews {
            
            if let _  = view as? UITextField {
                (view as? UITextField)?.textColor = .white
            }
            
        }
    }
    
    // 4. this checks what's typed into the password textField from step 3
    @objc fileprivate func handleTextInputChanged() {
        
        let isFormValid = !isPasswordTextFieldIsEmpty() // if the textField ISN'T empty then the form is valid
        
        if isFormValid {
            
            self.lblPasswordStrength.isHidden = true
            print("not Empty")
            
        }
        else {
            
            // self.lblPasswordStrength.isHidden = false
            if isSignInVC {
                
                self.txtPassword.isSecureTextEntry = true
            }
            else {
                
                self.txtPassword.isSecureTextEntry = false
            }
        }
    }
    
    // 5. create a function to check to see if the password textField is empty
    func isPasswordTextFieldIsEmpty() -> Bool {
        
        // 6. this checks for blank space
        let whiteSpace = CharacterSet.whitespaces
        
        // 7. if the passwordTextField has all blank spaces in it or is empty then return true
        if txtPassword.text!.trimmingCharacters(in: whiteSpace) == "" || txtPassword.text!.isEmpty {
            return true
        }
        return false // if it has valid characters in it then return false
    }
    
    // 8. target method from step 1
    @objc func signUpButtonTapped() {
        // run firebase code
    }
    
    func setPrivacyAndTermsText() {
        
        lblPrivecy.text = ""
        let newString = NSMutableAttributedString()
        var boldAttribute = [NSAttributedString.Key: NSObject]()
        
        boldAttribute = [
            NSAttributedString.Key.font: UIFont(name: Constant.FONT_Mulli_Semibold, size: 12.0)!, NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        
        let regularAttribute = [
            NSAttributedString.Key.font: UIFont(name: Constant.FONT_Mulli_Semibold, size: 11.0)!, NSAttributedString.Key.foregroundColor : Constant.appColor.customGrey
        ]
        
        let firstStr = NSAttributedString(string: NSLocalizedString("By checking this box, you agree to our ", comment: ""), attributes: regularAttribute)
        let secondStr = NSAttributedString(string: NSLocalizedString("Terms of Service", comment: ""), attributes: boldAttribute)
        let thirdStr = NSAttributedString(string: ". \(NSLocalizedString("We’ll handle your data according to our\n", comment: ""))", attributes: regularAttribute)
        let fourthStr = NSAttributedString(string: NSLocalizedString("Privacy Policy", comment: ""), attributes: boldAttribute)
        let fifthStr = NSAttributedString(string: ".", attributes: regularAttribute)
        
        newString.append(firstStr)
        newString.append(secondStr)
        newString.append(thirdStr)
        newString.append(fourthStr)
        newString.append(fifthStr)
        lblPrivecy.attributedText = newString
        
        lblPrivecy.isUserInteractionEnabled = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        tapgesture.numberOfTapsRequired = 1
        self.lblPrivecy.addGestureRecognizer(tapgesture)
    }
    
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        
        guard let text = self.lblPrivecy.text else { return }
        let privacyPolicyRange = (text as NSString).range(of: NSLocalizedString("Privacy Policy", comment: ""))
        let termsAndConditionRange = (text as NSString).range(of: NSLocalizedString("Terms of Service", comment: ""))
        
        if gesture.didTapAttributedTextInLabel(label: self.lblPrivecy, inRange: privacyPolicyRange) {
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.policyClick, eventDescription: "")
            let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
            vc.webURL = "https://www.newsinbullets.app/privacy/?header=false"
            vc.titleWeb = NSLocalizedString("Privacy Policy", comment: "")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
        else if gesture.didTapAttributedTextInLabel(label: self.lblPrivecy, inRange: termsAndConditionRange){
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.termsClick, eventDescription: "")
            let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
            vc.webURL = "https://www.newsinbullets.app/terms/?header=false"
            vc.titleWeb = NSLocalizedString("Terms & Conditions", comment: "")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: - user interface setup on loading
    func setupUserUI(){
        
        //DesignView
        viewUnderLineEmail.backgroundColor = Constant.appColor.purple
        viewUnderLinePassword.backgroundColor = Constant.appColor.purple
        pageControl.currentPageIndicatorTintColor = Constant.appColor.purple
//        txtEmail.tintColor = Constant.appColor.purple
        
        viewNextButtonBG.borderWidth = 2.5
        viewNextButtonBG.borderColor = Constant.appColor.purple
        viewNextButtonBG.topColor = UIColor.clear
        viewNextButtonBG.bottomColor = UIColor.clear
        viewNextButtonBG.cornerRadius  = viewNextButtonBG.frame.size.height / 2
        
        btnHelp.addTextSpacing(spacing: 2.0)
        lblNextBtnText.addTextSpacing(spacing: 2.0)
        
        self.viewEmail.isHidden = false
        self.viewPasswordSignUp.isHidden = true
        self.viewOTP.isHidden = true
        
        self.btnAgreement.layer.cornerRadius = 4
        self.btnAgreement.clipsToBounds = true
        
        if isSignInVC {
            choosePasswordLabelBottomConstraint.constant = 26
        } else {
            choosePasswordLabelBottomConstraint.constant = 8
        }
        
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textField == self.txtEmail {
            
            if let emailTxt = textField.text {
                
                self.viewHintEmail(hintText:"", buttonTittle: "", isHidden: true)
                if emailTxt.isValidEmail() {
                    
                    self.txtEmail.textColor = Constant.appColor.purple
                    self.lblNextBtnText.text = NSLocalizedString("NEXT", comment: "")
//                    self.ConstraintNextBtnLeading.constant = 6
//                    self.imgNextArrow.isHidden = true
                }
                else {
                    
                    self.txtEmail.textColor = UIColor.white
                }
            }
        }
        else {
            
            if isSignInVC && self.isForgotPwd == "false" {
                
                self.viewPasswordHint.isHidden = true
                self.btnForgotPassword.isHidden = false
            }
            else {
                
                self.viewHintPassword(hintText: NSLocalizedString("Password must be at least 8 characters.", comment: ""), textColor: UIColor(displayP3Red: 120/255.0, green: 120/255.0, blue: 120/255.0, alpha: 1), alertImgWidth: -6.0, isHidden: true)
                self.constraintPasswordAlertLeading.constant = 24
            }
            
            if let passwordTxt = textField.text {
                
                if passwordTxt.count > 1 {
                    
                    // self.txtPassword.textColor = Constant.appColor.purple
                    
                    if !(isSignInVC){
                        
                        self.lblPasswordStrength.isHidden = false
                    }
                    if (passwordTxt.isValidStrongPassword()) {
                        
                        self.lblPasswordStrength.text = NSLocalizedString("Strong", comment: "")
                        self.lblPasswordStrength.textColor = UIColor(displayP3Red: 104/255.0, green: 197/255.0, blue: 121/255.0, alpha: 1)
                    }
                    else if passwordTxt.count >= 8 {
                        
                        self.lblPasswordStrength.text = NSLocalizedString("Medium", comment: "")
                        self.lblPasswordStrength.textColor = UIColor(displayP3Red: 246/255.0, green: 116/255.0, blue: 65/255.0, alpha: 1)
                    }
                    else{
                        
                        self.lblPasswordStrength.text = NSLocalizedString("Weak", comment: "")
                        self.lblPasswordStrength.textColor = UIColor(displayP3Red: 255/255.0, green: 196/255.0, blue: 66/255.0, alpha: 1)
                    }
                }
                else {
                    
                    self.lblPasswordStrength.text = ""
                }
            }
            
        }
    }
    
    func validateCapitalLetter(password: String) -> Bool {
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        guard texttest.evaluate(with: password) else { return false }
        
        return true
    }
    
    @IBAction func didTapForgetPassword(_ sender: UIButton) {
        
        let vc = ForgotPasswordVC.instantiate(fromAppStoryboard: .registration)
        vc.user_Name = self.txtEmail.text ?? ""
        vc.isFromSignVC = true
        vc.delegateVC = self
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    //To Adjust view according to keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            print(keyboardHeight)
            
            // if self.backButtonCurrentStage == .emailStage {
            
            self.constraintViewEmailBottom.constant = keyboardHeight
            //   }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
        
        self.isHelpVCPresented = true
        let vc = helpCenterVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
        
        //self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapShowHidePwdAction(_ sender: UIButton) {
        
        if txtPassword.isSecureTextEntry {
            imgPwd.image = UIImage(named: "icn_show_pwd")!
            txtPassword.isSecureTextEntry = false
        }
        else {
            imgPwd.image = UIImage(named: "icn_hide_pwd")!
            txtPassword.isSecureTextEntry = true
        }
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        
        if self.backButtonCurrentStage == .emailStage {
            
            user_Name = self.txtEmail.text ?? ""
            if self.user_Name.isEmpty {
                
                SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: NSLocalizedString("Enter email.", comment: ""))
            }
            else {
                
                if lblNextBtnText.text == NSLocalizedString("CREATE A NEW ACCOUNT", comment: "") {
                    
                    isSignInVC = false
                    self.txtEmail.textContentType = .username
                    self.txtEmail.keyboardType = .emailAddress
                    if #available(iOS 12.0, *) {
                        self.txtPassword.textContentType = .newPassword
                    } else {
                        // Fallback on earlier versions
                    }
                }
                else if lblNextBtnText.text == NSLocalizedString("SIGN IN WITH EXISTING ACCOUNT", comment: "") {
                    
                    isSignInVC = true
                    self.txtEmail.textContentType = .username
                    self.txtEmail.keyboardType = .emailAddress
                    self.txtPassword.textContentType = .password
                }
                
                self.isForgotPwd = "false"
                self.performWSToCheckEmail()
                
            }
        }
        else if self.backButtonCurrentStage == .otp {
            
            if !hasEnteredOTP {
                
                lblOtpError.isHidden = false
                lblOtpError.text = NSLocalizedString("Please enter a valid OTP.", comment: "")
                lblOtpError.textColor = "#E01335".hexStringToUIColor()
                return
            }
            
            lblOtpError.isHidden = true
            self.otpTextFieldView.resignFirstResponder()
            self.performWSToValidOTP()
        }
        else {
            
            if isFromProfileVC {
                self.user_Name = UserDefaults.standard.string(forKey: Constant.UD_userEmail) ?? ""
            }
            else {
                self.user_Name = self.txtEmail.text ?? ""
            }
            self.user_Pass = self.txtPassword.text ?? ""
            
            if self.user_Pass.isEmpty {
            
                self.viewHintPassword(hintText: NSLocalizedString("Please enter a password.", comment: ""), textColor: UIColor(displayP3Red: 217.0/255.0, green: 77.0/255.0, blue: 69.0/255.0, alpha: 1), alertImgWidth: 20.0, isHidden: false)
            }
            else {
                
                if isSignInVC && self.isForgotPwd == "false" {
                    
                    self .doOAuthRegistration()
                }
                else {
                    
                    if self.user_Pass.isEmpty {
                        
                        self.viewHintPassword(hintText: NSLocalizedString("Password must be at least 8 characters.", comment: ""), textColor: UIColor(displayP3Red: 217.0/255.0, green: 77.0/255.0, blue: 69.0/255.0, alpha: 1), alertImgWidth: 20.0, isHidden: false)
                        return
                    }
                    
                    if self.isForgotPwd == "false" {
                        
                        if isAgreementAccepted == "false" {
                            
                            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("You must agree to the Terms of Services to continue", comment: ""))
                            
                            return
                        }
                    }
                    self .performWSToRegistorUser()
                }
            }
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        if self.isFromProfileVC {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.backButtonnStages()
    }
    
    @IBAction func didTapResendOTP(_ sender: Any) {
        
        self.otpTextFieldView.resignFirstResponder()
        self.performWSToResendOTP()
    }
    
    func backButtonnStages() {
        
        if backButtonCurrentStage == .emailStage {
            
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.popViewController(animated: true)
        }
        else if backButtonCurrentStage == .otp {
            
            //Animation to hide Password view
            pageControl.currentPage = 0
            
            self.txtPassword.text = ""
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                
                self.viewOTP.alpha = 0.1
                self.lblNextBtnText.text = NSLocalizedString("NEXT", comment: "")
                self.btnBack.alpha = 0.1
                self.btnForgotPassword.alpha = 0.1
                
            }, completion: {(isCompleted) in
                
                self.backButtonCurrentStage = backButtonTapped.emailStage
                self.txtEmail.becomeFirstResponder()
                self.viewEmail.alpha = 0.1
            })
            
            //Animation to show Email View
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                
                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                    
                    self.viewAgreement.isHidden = true
                    self.viewOTP.isHidden = true
                    self.btnForgotPassword.isHidden = true
                    self.viewEmail.isHidden = false
                    self.viewEmail.alpha = 1.0
                    self.btnBack.alpha = 1.0
                    self.btnForgotPassword.alpha = 1.0
                    
                }, completion: {(isCompleted) in
                    
                })
            }
        }
        else if backButtonCurrentStage == .passwordStage {
            
            //Animation to hide Password view
            pageControl.currentPage = 0
            self.txtPassword.resignFirstResponder()
            self.txtPassword.text = ""
            
            if self.isForgotPwd == "true" {

                self.lblOtpEmail.text = user_Name
                self.lblOtpError.isHidden = true
                self.lblOtpEmail.isHidden = false
                self.setupOtpView()
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                
                self.viewPasswordSignUp.alpha = 0.1
                self.lblNextBtnText.text = NSLocalizedString("NEXT", comment: "")
                self.btnBack.alpha = 0.1
                self.btnForgotPassword.alpha = 0.1
                
            }, completion: {(isCompleted) in
                
                if self.isSignInVC && self.isForgotPwd == "false" {
                    
                    self.backButtonCurrentStage = backButtonTapped.emailStage
                    self.viewEmail.alpha = 0.1
                }
                else {
                    self.backButtonCurrentStage = backButtonTapped.otp
                    self.viewOTP.alpha = 0.1
                }
            })
            
            //Animation to show Email View
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                
                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                    
                    self.viewAgreement.isHidden = true
                    self.viewPasswordSignUp.isHidden = true
                    self.btnForgotPassword.isHidden = true
                    
                    if self.isSignInVC && self.isForgotPwd == "false" {
                        self.viewEmail.isHidden = false
                        self.viewEmail.alpha = 1.0
                    }
                    else {
                        self.viewOTP.isHidden = false
                        self.viewOTP.alpha = 1.0
                    }
                    self.btnBack.alpha = 1.0
                    self.btnForgotPassword.alpha = 1.0
                    
                }, completion: {(isCompleted) in
                    
                    if self.isSignInVC && self.isForgotPwd == "false" {
                        self.txtEmail.becomeFirstResponder()
                    }
                    else {
                        self.otpTextFieldView.becomeFirstResponder()
                    }
                })
            }
        }
    }
        
    func animateShowHidePasseordView() {
        
        //Animation to hide Email view
        pageControl.currentPage = 1
        self.backButtonCurrentStage = backButtonTapped.passwordStage
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            
            if self.isSignInVC && self.isForgotPwd == "false" {
                
                self.viewEmail.alpha = 0.1
            }
            else {
                self.viewOTP.alpha = 0.1
            }
            self.btnBack.alpha = 0.1

            
        }, completion: {(isCompleted) in
            
            self.viewPasswordSignUp.alpha = 0.1
        })
        
        //Animation to show Password view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                
                if self.isSignInVC && self.isForgotPwd == "false" {
                    
                    self.viewEmail.isHidden = true
                }
                else {
                    self.viewOTP.isHidden = true
                }
                self.viewPasswordSignUp.isHidden = false
                self.viewPasswordSignUp.alpha = 1.0
                self.btnBack.alpha = 1.0
                
                if #available(iOS 12.0, *) {
                    
                    if self.isSignInVC == true && self.isForgotPwd == "false" {
                        
                        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.signinClick, eventDescription: "")
                        self.txtPassword.becomeFirstResponder()
                        self.lblNextBtnText.text = NSLocalizedString("SIGN IN", comment: "")
                        self.viewAgreement.isHidden = true
                        self.btnForgotPassword.isHidden = false
                        self.lblEmailForUser.text = "For \(self.txtEmail.text ?? "")"
                        self.lblEmailForUser.isHidden = false
                        
                        self.lblPaswordTitle.text = NSLocalizedString("What's your password?", comment: "")

                        self.viewPasswordHint.isHidden = true
                        self.btnForgotPassword.isHidden = false
                        self.viewShowHidePassword.isHidden = false
                        self.lblPasswordStrength.isHidden = true
                        self.txtPassword.isSecureTextEntry = true
                        self.constraintPasswordAlert.constant = 35
                        self.constraintPasswordAlertLeading.constant = 30
                        
                        self.txtEmail.textContentType = .username
                        self.txtEmail.keyboardType = .emailAddress
                        self.txtPassword.textContentType = .password
                        
                    }
                    else {
                        
                        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.signUpClick, eventDescription: "")
                        self.viewShowHidePassword.isHidden = true
                        self.lblPasswordStrength.isHidden = false
                        self.txtPassword.isSecureTextEntry = true
                        self.lblPasswordStrength.text = ""
                        
                        if self.isSignInVC == true && self.isForgotPwd == "true" {
                            
                            if self.isFromProfileVC {
                                self.lblNextBtnText.text = NSLocalizedString("SAVE", comment: "")
                            }
                            else {
                                self.lblNextBtnText.text = NSLocalizedString("SIGN IN", comment: "")
                            }
                            self.viewAgreement.isHidden = true
                        }
                        else {
                            self.lblNextBtnText.text = NSLocalizedString("SIGN UP", comment: "")
                            self.viewAgreement.isHidden = false
                        }

                        self.btnForgotPassword.isHidden = true
                        self.lblEmailForUser.isHidden = true
                        
                        self.lblPaswordTitle.text = NSLocalizedString("Choose your password?", comment: "")
                        self.viewPasswordHint.isHidden = false
                        self.constraintPasswordAlert.constant = 8
                        self.constraintPasswordAlertLeading.constant = 24
                        
                        self.viewHintPassword(hintText: NSLocalizedString("Password must be at least 8 characters.", comment: ""), textColor: UIColor(displayP3Red: 120/255.0, green: 120/255.0, blue: 120/255.0, alpha: 1), alertImgWidth: -6.0, isHidden: true)
                        
                        
                        self.testEmailField.isHidden = false
                        self.txtPassword.isHidden = false
                        self.testEmailField.text = self.txtEmail.text
                        
                        self.testEmailField.textContentType = .username
                        self.testEmailField.keyboardType = .emailAddress
                        self.txtPassword.textContentType = .newPassword
                    }
                }
                
            }, completion: {(isCompleted) in
                
                self.txtPassword.becomeFirstResponder()
            })
        }
    }
    
    func animateShowHideOTPView() {
        
        //Animation to hide Email view
        self.setupOtpView()
        pageControl.currentPage = 0
        self.backButtonCurrentStage = backButtonTapped.otp
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            
            self.viewEmail.alpha = 0.1
            self.btnBack.alpha = 0.1
            
        }, completion: {(isCompleted) in
            
            self.txtEmail.resignFirstResponder()
            self.viewOTP.alpha = 0.1
        })
        
        //Animation to show Password view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                
                self.lblOtpEmail.text = self.txtEmail.text ?? ""
                self.lblOtpEmail.isHidden = false
                
                self.viewEmail.isHidden = true
                self.viewOTP.isHidden = false
                self.viewOTP.alpha = 1.0
                self.btnBack.alpha = 1.0

            }, completion: {(isCompleted) in
                
                self.viewOTP.alpha = 1.0
                self.otpTextFieldView.becomeFirstResponder()
            })
        }
    }
    
    @IBAction func didTapAgreement(_ sender: UIButton) {
        
        if isAgreementAccepted == "true" {
            
            isAgreementAccepted = "false"
            self.btnAgreement.setImage(UIImage(named: "check_box"), for: .normal)
        }
        else {
            
            isAgreementAccepted = "true"
            self.btnAgreement.setImage(UIImage(named: "checked"), for: .normal)
        }
    }
}

//MARK:-
extension RegistrationVC {
    
    func doOAuthRegistration() {
        
        ANLoader.showLoading(disableUI: true)
                
        let tokenURL = URL(string: WebserviceManager.shared.AUTH_TOKEN_URL)!
        let useCredentials = OAuthClientCredentials(id: WebserviceManager.shared.APP_CLIENT_ID, secret: WebserviceManager.shared.APP_CLIENT_SECRET)
        let heimdall = Heimdallr(tokenURL: tokenURL, credentials: useCredentials)

        var parameters = [String : String]()
        parameters["username"] = self.user_Name
        parameters["password"] = self.user_Pass
        parameters["language"] = SharedManager.shared.languageId

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
                                    UserDefaults.standard.set(self.user_Name, forKey: Constant.UD_userEmail)
                                    //UserDefaults.standard.set(userPass, forKey: Constant.UD_userPassword)
                                    
                                    self.view.endEditing(true)
                                    ANLoader.hide()
                                    
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
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        
                                        if self.isSignInVC {
                                            self.performWSToUserConfig()
                                        }
                                        else {
                                            
                                            let vc = UsernameVC.instantiate(fromAppStoryboard: .registration)
                                            vc.newAccessToken = self.linkToken
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                    }
                                    
                                }
                                print("Access Token", accessToken)

                            }
                        }
                        
                        if let refreshToken = heimdall.accessToken?.refreshToken {
                            
                            ANLoader.hide()
                            UserDefaults.standard.set(refreshToken, forKey: Constant.UD_refreshToken)
                            
                            if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                                
                                userDefaults.set(refreshToken as AnyObject, forKey: "WRefreshToken")
                                userDefaults.synchronize()
                            }
                        }
                    }
                }
                
            case .failure(let error):
                
                ANLoader.hide()
                let errorAlert = error.localizedDescription
                print("failure: \(errorAlert)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    
                    self.viewHintPassword(hintText: errorAlert, textColor: UIColor(displayP3Red: 217.0/255.0, green: 77.0/255.0, blue: 69.0/255.0, alpha: 1), alertImgWidth: 20.0, isHidden: false)
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
}

//====================================================================================================
// MARK:- resigter user webservice Respones
//====================================================================================================
extension RegistrationVC {
    
    func performWSToRegistorUser() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let params = ["email":user_Name,
                      "password": user_Pass,
                      "code": self.OTPString,
                      "forgot": isForgotPwd,
                      "termsandcondition": isAgreementAccepted] as [String : Any]
        
        WebService.URLResponseAuth("auth/account-setpassword", method: .patch, parameters: params, headers: nil, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.success == true {
                    
                    print("user_id: ",FULLResponse.user_id ?? "")
                    
                    if self.isFromProfileVC {
                        
                        SharedManager.shared.showAlertLoader(message: NSLocalizedString("Password updated successfully", comment: ""), type: .alert)

                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                        
                        self.doOAuthRegistration()
                    }
                }
                else {
                    
                    self.viewHintPassword(hintText: FULLResponse.message ?? NSLocalizedString("Something went wrong", comment: ""), textColor: UIColor(displayP3Red: 217.0/255.0, green: 77.0/255.0, blue: 69.0/255.0, alpha: 1), alertImgWidth: 20.0, isHidden: false)
                    self.constraintPasswordAlertLeading.constant = 30
                }
                
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "auth/account-setpassword", error: jsonerror.localizedDescription, code: "")
            }
            
        }){ (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func viewHintPassword(hintText: String, textColor: UIColor, alertImgWidth: CGFloat, isHidden: Bool) {
        
        if isHidden {
            
            self.imgPwdAlert.isHidden = true
            self.constraintimgPwdAlertWidth.constant = alertImgWidth
            self.lblPaswordHintText.text = hintText
            self.lblPaswordHintText.textColor = textColor
        }
        else {
            
            self.viewPasswordHint.isHidden = false
            //  self.btnForgotPassword.isHidden = true
            self.imgPwdAlert.isHidden = false
            self.constraintimgPwdAlertWidth.constant = alertImgWidth
            self.lblPaswordHintText.text = hintText
            self.lblPaswordHintText.textColor = textColor
        }
    }
}

//====================================================================================================
// MARK:- Check email webservice Respones
//====================================================================================================
extension RegistrationVC {
    
    func performWSToCheckEmail() {
        
        let emailTxt = self.txtEmail.text ?? ""
        if !emailTxt.isValidEmail() {
 
            self.viewHintEmail(hintText: NSLocalizedString("Invalid email format", comment: ""), buttonTittle: NSLocalizedString("NEXT", comment: ""), isHidden: false)
            return
        }
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let params = ["email": user_Name.removeWhitespace()]
        ANLoader.showLoading(disableUI: true)
        
        WebService.URLResponseAuth("auth/register", method: .post, parameters: params, headers: nil, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.exist == true {
                    
                    self.isSignInVC = true
                    self .animateShowHidePasseordView()
                    self.viewHintEmail(hintText:"", buttonTittle: "", isHidden: true)
                }
                else {
                    
                    self.isSignInVC = false
                    self.txtEmail.resignFirstResponder()
                    self.viewHintEmail(hintText:"", buttonTittle: "", isHidden: true)
                    self.animateShowHideOTPView()
                }
                
            } catch let jsonerror {
                
                do{
                    let FULLResponse = try
                        JSONDecoder().decode(checkEmailErrors.self, from: response)
                    self.viewHintEmail(hintText: FULLResponse.errors?.email ?? "", buttonTittle: NSLocalizedString("NEXT", comment: ""), isHidden: false)
                    print("error parsing json objects",jsonerror)
                    
                }
                catch let jsonerror {
                    
                    do{
                        
                        print("error parsing json objects",jsonerror)
                        SharedManager.shared.logAPIError(url: "auth/register", error: jsonerror.localizedDescription, code: "")
                    }
                }
            }
            
            ANLoader.hide()
            
        }){ (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func viewHintEmail(hintText:String, buttonTittle:String, isHidden: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            if buttonTittle == NSLocalizedString("SIGN IN WITH EXISTING ACCOUNT", comment: "") || buttonTittle == NSLocalizedString("CREATE A NEW ACCOUNT", comment: "") {
                
                self.viewNextButtonBG.borderWidth = 0
                self.viewNextButtonBG.borderColor = UIColor.clear
                
                self.viewNextButtonBG.topColor = "0072FF".hexStringToUIColor()
                self.viewNextButtonBG.bottomColor = "3AD9D2".hexStringToUIColor()
                
            }
            else {
                
                self.viewNextButtonBG.borderWidth = 2.5
                self.viewNextButtonBG.borderColor = Constant.appColor.purple
                
                self.viewNextButtonBG.topColor = UIColor.clear
                self.viewNextButtonBG.bottomColor = UIColor.clear
            }
            
            if isHidden {
                
                self.viewEmailHint.isHidden = true
                self.lblEmailHintText.text = ""
                //     self.lblNextBtnText.text = ""
                self.lblNextBtnText.sizeToFit()
            }
            else {
                
                self.viewEmailHint.isHidden = false
                self.lblEmailHintText.text = hintText
                self.lblNextBtnText.text = buttonTittle
                self.lblNextBtnText.sizeToFit()
                
            }
        }
    }
    
    func performWSToValidOTP() {
        
//        if !self.isFromProfileVC {
//
//            let emailTxt = self.txtEmail.text ?? ""
//            if !emailTxt.isValidEmail() {
//
//                self.viewHintEmail(hintText:NSLocalizedString("Invalid email", comment: ""), buttonTittle: "NEXT", isHidden: false)
//                return
//            }
//        }
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
                
        let params = ["email": user_Name.removeWhitespace(),
                      "code": self.OTPString,
                      "forgot": isForgotPwd] as [String : Any]
        
        ANLoader.showLoading(disableUI: true)
        
        WebService.URLResponseAuth("auth/code/valid", method: .post, parameters: params, headers: nil, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                if FULLResponse.valid == true {

                    self .animateShowHidePasseordView()
                }
                else {

                    self.lblOtpError.isHidden = false
                    self.lblOtpError.text = NSLocalizedString("Invalid code", comment: "")
                    self.setupOtpView()
                }
                
//                self .animateShowHidePasseordView()
//                self.lblOtpError.isHidden = false
//                self.lblOtpError.text = FULLResponse.message ?? ""


            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "auth/code/valid", error: jsonerror.localizedDescription, code: "")
            }
            
            ANLoader.hide()
            
        }){ (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToResendOTP() {
        
//        let emailTxt = self.txtEmail.text ?? ""
//        if !emailTxt.isValidEmail() {
//
//            self.viewHintEmail(hintText:NSLocalizedString("Invalid email", comment: ""), buttonTittle: "NEXT", isHidden: false)
//            return
//        }
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let query = isForgotPwd == "true" ? "auth/resend-account-setpassword" : "auth/resend-account-verification"
        
        let params = ["email": user_Name.removeWhitespace()]
        ANLoader.showLoading(disableUI: true)
        
        WebService.URLResponseAuth(query, method: .post, parameters: params, headers: nil, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                self.lblOtpError.isHidden = false
                self.lblOtpError.text = FULLResponse.message ?? ""
                SharedManager.shared.showAlertLoader(message: FULLResponse.message ?? "", type: .alert)
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//
//                    self.otpTextFieldView.becomeFirstResponder()
//                }

            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
            }
            
            ANLoader.hide()
            
        }){ (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}


//====================================================================================================
// MARK:- resigter user webservice Respones
//====================================================================================================
extension RegistrationVC {
    
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
                    
//                    if self.isSignInVC {
//
//                        self.appDelegate?.setHomeVC()
//                    }
//                    else {
//
//                        //                       self.appDelegate?.setUserTopicVC()
//                        DispatchQueue.main.async {
//                            let userEmail = self.txtEmail.text ?? ""
//                            UserDefaults.standard.set(userEmail, forKey: Constant.UD_userEmail)
//
//                            let vc = EditionVC.instantiate(fromAppStoryboard: .registration)
//                            vc.isFromRegistration = true
//                            self.navigationController?.pushViewController(vc, animated: true)
//                        }
//                    }
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
                            
                            self.appDelegate?.setHomeVC()
                        }
                    })
                }
                else {
                    
                    self.appDelegate?.setHomeVC()
                }

                
            } catch let jsonerror {
            
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
//    func performWSToUpdateLanguage(id:String) {
//
//        let params = ["language": id]
//        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
//
//        ANLoader.showLoading()
//        WebService.URLResponseAuth("auth/update-profile/language", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
//
//            do{
//                let FULLResponse = try
//                    JSONDecoder().decode(messageDC.self, from: response)
//
//                if FULLResponse.message?.uppercased() == Constant.STATUS_SUCCESS {
//
//                    print("Success...")
//                }
//
////                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
////
////                    WebService.checkValidToken { _ in }
////                })
//
//                ANLoader.hide()
//
//            } catch let jsonerror {
//
//                print("error parsing json objects",jsonerror)
//                SharedManager.shared.logAPIError(url: "auth/update-profile/language", error: jsonerror.localizedDescription, code: "")
//            }
//
//        }) { (error) in
//
//            print("error parsing json objects",error)
//        }
//    }
}

//MARK:- OTP Delegate
extension RegistrationVC: OTPFieldViewDelegate {
    
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        self.hasEnteredOTP = hasEntered
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        print("otpTextFieldIndex \(index)")
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        print("OTPString: \(otpString)")
        self.OTPString = otpString
    }
}

//MARK:- ForgotPasswordVC Delegate
extension RegistrationVC: ForgotPasswordVCDelegate {
    
    func onDismissForgotPwdView() {
        
        self.isForgotPwd = "true"
        self.backButtonnStages()
    }
    
}
