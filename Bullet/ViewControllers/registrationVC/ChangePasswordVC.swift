//
//  ChangePasswordVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 30/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ChangePasswordVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtCurrPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnForgot: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
//    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet var viewUnderlineCollection: [UIView]!
    
    var currPass = ""
    var newPass = ""
    var confirmPass = ""
    var userEmail = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupLocalization()
        let newString = NSMutableAttributedString()
        
        let boldAttribute = [
            NSAttributedString.Key.font: UIFont(name: Constant.FONT_Mulli_Semibold, size: 18.0)!, NSAttributedString.Key.foregroundColor : Constant.appColor.customGrey
        ]
        
        let regularAttribute = [
            NSAttributedString.Key.font: UIFont(name: Constant.FONT_Mulli_REGULAR, size: 14.0)!, NSAttributedString.Key.foregroundColor : Constant.appColor.customGrey
        ]
    
        let firstStr = NSAttributedString(string: NSLocalizedString("New Password ", comment: ""), attributes: boldAttribute)
        let secondStr = NSAttributedString(string: NSLocalizedString(" (8 characters min)", comment: ""), attributes: regularAttribute)

        newString.append(firstStr)
        newString.append(secondStr)
        txtNewPassword.attributedPlaceholder = newString
        
        //Design View
        btnSave.addTextSpacing(spacing: 1.5)
        btnSave.backgroundColor = Constant.appColor.lightRed
        
        self.view.backgroundColor = .white
        //        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        txtCurrPassword.theme_textColor = GlobalPicker.textColor
      //  txtCurrPassword.theme_placeholderAttributes = GlobalPicker.textPlaceHolder
        
        txtNewPassword.theme_textColor = GlobalPicker.textColor
      //  txtNewPassword.theme_placeholderAttributes = GlobalPicker.textPlaceHolder
        
        txtConfirmPassword.theme_textColor = GlobalPicker.textColor
      //  txtConfirmPassword.theme_placeholderAttributes = GlobalPicker.textPlaceHolder
        
        //  viewBottom.theme_backgroundColor = GlobalPicker.backgroundBottomView
        
        btnForgot.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        txtCurrPassword.delegate = self
        txtNewPassword.delegate = self
        txtConfirmPassword.delegate = self
        
        for txt in [txtCurrPassword, txtNewPassword, txtConfirmPassword] {
            txt?.theme_tintColor = GlobalPicker.searchTintColor
        }
        
        lblTitle.theme_textColor = GlobalPicker.textColor
        
        viewUnderlineCollection.forEach { (viewUnderline) in
            viewUnderline.theme_backgroundColor = GlobalPicker.themeCommonColor
        }
        
//       imgBack.theme_image = GlobalPicker.imgBack
    }
    
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Change Password", comment: "")
        txtCurrPassword.placeholder = NSLocalizedString("Current Password", comment: "")
        txtNewPassword.placeholder = NSLocalizedString("New Password (8 Characters Min)", comment: "")
        txtConfirmPassword.placeholder = NSLocalizedString("Confirm New Password", comment: "")
        btnSave.setTitle(NSLocalizedString("SAVE CHANGES", comment: ""), for: .normal)
        btnForgot.setTitle(NSLocalizedString("Forgot Password?", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
     //   setNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        txtCurrPassword.text = nil
        txtNewPassword.text = nil
        txtConfirmPassword.text = nil
    }
    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.txtCurrPassword.semanticContentAttribute = .forceRightToLeft
                self.txtCurrPassword.textAlignment = .right
                self.txtNewPassword.semanticContentAttribute = .forceRightToLeft
                self.txtNewPassword.textAlignment = .right
                self.txtConfirmPassword.semanticContentAttribute = .forceRightToLeft
                self.txtConfirmPassword.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.txtCurrPassword.semanticContentAttribute = .forceLeftToRight
                self.txtCurrPassword.textAlignment = .left
                self.txtNewPassword.semanticContentAttribute = .forceLeftToRight
                self.txtNewPassword.textAlignment = .left
                self.txtConfirmPassword.semanticContentAttribute = .forceLeftToRight
                self.txtConfirmPassword.textAlignment = .left
            }
        }
    }
    
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
      //  self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapSaveChanges(_ sender: Any) {
        
        self.currPass = self.txtCurrPassword?.text ?? ""
        self.newPass = self.txtNewPassword?.text ?? ""
        self.confirmPass = self.txtConfirmPassword?.text ?? ""
        
        if self.currPass.isEmpty {
            
//            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter current password.", comment: ""))
            
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Enter current password.", comment: ""), type: .error)
            
        }
        else if self.newPass.isEmpty {
            
//            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter new password.", comment: ""))
            
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Enter new password.", comment: ""), type: .error)
            
        }
        else if self.confirmPass.isEmpty {
            
//            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter confirm password.", comment: ""))
            
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Enter confirm password.", comment: ""), type: .error)
            
        }
        else if self.newPass != self.confirmPass {
            
//            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("password do not matched!", comment: ""))
            
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("password do not matched!", comment: ""), type: .error)
            
        }
            
        else {
            
            self .performWSToChangePassword()
        }
    }
    
    @IBAction func didTapChnagePassword(_ sender: Any) {
        
        let vc = ForgotPasswordVC.instantiate(fromAppStoryboard: .registration)
        vc.user_Name = UserDefaults.standard.string(forKey: Constant.UD_userEmail) ?? ""
        vc.isFromSignVC = false
        vc.delegateVC = self
        self.present(vc, animated: true, completion: nil)
      //  self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     
        if textField == txtCurrPassword {
            
            txtNewPassword.becomeFirstResponder()
        }
        else if textField == txtNewPassword {
            
            txtConfirmPassword.becomeFirstResponder()
        }
        else {
            
            txtConfirmPassword.resignFirstResponder()
            self.view.endEditing(true)
        }
        return true
    }
}

//MARK:- ForgotPasswordVC Delegate
extension ChangePasswordVC: ForgotPasswordVCDelegate {
    
    func onDismissForgotPwdView() {
        
//        let vc = RegistrationVC.instantiate(fromAppStoryboard: .registration)
//        vc.user_Name = UserDefaults.standard.string(forKey: Constant.UD_userEmail) ?? ""
//        vc.isSignInVC = true
//        vc.isFromProfileVC = true
//        self.present(vc, animated: true, completion: nil)
    }
    
}


//====================================================================================================
// MARK:- Change Password webservice Respones
//====================================================================================================
extension ChangePasswordVC {
    
    func performWSToChangePassword() {
    
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["old_password":currPass, "password":confirmPass]
        
        WebService.URLResponseAuth("auth/change/password", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.message?.lowercased() == "password changed" {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        
                        SharedManager.shared.showAlertLoader(message: NSLocalizedString("Password changed successfully.", comment: ""), type: .alert)
                        
                        self.didTapBack(self)
                        WebService.checkValidToken { (status) in
                            if status {
                                print("Token refreshed successfully")
                            } else {
                                print("Token refresh failed")
                            }
                        }
                        
                    })
                }
                else {
                    
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                
            } catch let jsonerror {
                ANLoader.hide()
                SharedManager.shared.logAPIError(url: "auth/change/password", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }){ (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}
