//
//  ForgotPasswordVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 30/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//


import UIKit
import IQKeyboardManagerSwift

protocol ForgotPasswordVCDelegate: class {
    
    func onDismissForgotPwdView()
}


class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var viewResetPassord: UIView!
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var viewForSettingsForgot: UIView!
    @IBOutlet weak var btnNext: UIButton!
   // @IBOutlet weak var btnResetLink: UIButton!
    @IBOutlet var viewCollection: [UIView]!
    
    @IBOutlet weak var lblResetEmail: UILabel!
    @IBOutlet weak var lblForgotResetEmail: UILabel!
    @IBOutlet weak var lblResetTitle: UILabel!
    @IBOutlet weak var lblReset: UILabel!
    @IBOutlet weak var btnLink: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblForgotPassword: UILabel!
    @IBOutlet weak var btnSendReset: UIButton!
    @IBOutlet weak var btnCancelReset: UIButton!
    
    weak var delegateVC: ForgotPasswordVCDelegate?
    
    var user_Name = ""
    var isFromSignVC = false
    var isSentLink = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()
        //DesignView
        self.viewResetPassord.isHidden = false
        self.viewAlert.isHidden = true
        
        self.viewCollection.forEach {
            $0.theme_backgroundColor = GlobalPicker.themeCommonColor
        }
        
        if isFromSignVC {
            
            self.viewForSettingsForgot.isHidden = true
            self.viewResetPassord.isHidden = false
        }
        else {
            
            self.viewForSettingsForgot.isHidden = false
            self.viewResetPassord.isHidden = true
            self.lblForgotResetEmail.text = "\(NSLocalizedString("we will send email to", comment: "")) \(self.user_Name) \(NSLocalizedString("with a link to reset your password.", comment: ""))"
        }
    }
    
    func setupLocalization() {
        lblForgotPassword.text = NSLocalizedString("Forgot Password?", comment: "")
        btnSendReset.setTitle(NSLocalizedString("Send Password Reset Link", comment: ""), for: .normal)
        btnCancelReset.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        lblResetEmail.text = NSLocalizedString("---", comment: "")
        btnNext.setTitle(NSLocalizedString("Ok", comment: ""), for: .normal)
        lblResetTitle.text = NSLocalizedString("Reset Password", comment: "")
        lblReset.text = NSLocalizedString("Reset Password", comment: "")
        btnLink.setTitle(NSLocalizedString("Send reset link", comment: ""), for: .normal)
        btnCancel.setTitle(NSLocalizedString("Ok", comment: ""), for: .normal)
    }
    
    @IBAction func didSendResetLink(_ sender: Any) {
        
        self .performWSForForgotPassword()
        self .btnLink.isUserInteractionEnabled = false
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            
            if self.isSentLink {

                self.delegateVC?.onDismissForgotPwdView()
            }
        }
    }
}

//====================================================================================================
// MARK:- forgot password webservice Respones
//====================================================================================================
extension ForgotPasswordVC {
    
    func performWSForForgotPassword() {
    
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["email": user_Name]
        
        WebService.URLResponseAuth("auth/forgot-password", method: .post, parameters: params, headers: token, withSuccess: { (response) in

            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.success == true {
                    
                    if self.isFromSignVC {
                        
                        self.lblResetEmail.text = "\(NSLocalizedString("A reset password link has been sent to", comment: "")) \(self.user_Name)"
                        self.viewResetPassord.isHidden = true
                        self.viewAlert.isHidden = false
                        self.isSentLink = true
                    }
                    else {
                        self.viewForSettingsForgot.isHidden = true
                        self.viewResetPassord.isHidden = false
                        self.lblResetEmail.text = "\(NSLocalizedString("A reset password link has been sent to", comment: "")) \(self.user_Name)"
                        self.viewResetPassord.isHidden = true
                        self.viewAlert.isHidden = false
                        self.isSentLink = true
//                        self.dismiss(animated: true) {
//
//                            self.delegateVC?.onDismissForgotPwdView()
//                        }
                    }
                    self .btnLink.isUserInteractionEnabled = true
                }
                else {
                    
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                   
                    self .btnLink.isUserInteractionEnabled = true
                })
                
            } catch let jsonerror {
                
                self .btnLink.isUserInteractionEnabled = true
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "auth/forgot-password", error: jsonerror.localizedDescription, code: "")
            }
            
        }){ (error) in
            
            ANLoader.hide()
            
            self .btnLink.isUserInteractionEnabled = true
            print("error parsing json objects",error)
        }
    }
}
