//
//  ChangeEmailVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 30/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol ChangeEmailVCDelegate: class {
    func emailUpdated()
}
class ChangeEmailVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtNewEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var viewBottom: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
//    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var btnChanges: UIButton!
    @IBOutlet var viewUnderlineCollection: [UIView]!
    
    weak var delegate: ChangeEmailVCDelegate?
    
    var currEmail = ""
    var newEmail = ""
    var userPass = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()
        //Disgin View
        btnChanges.backgroundColor = Constant.appColor.lightRed
        
        btnChanges.addTextSpacing(spacing: 1.5)
        self.view.backgroundColor = .white
        //.theme_backgroundColor = GlobalPicker.backgroundColor
        txtNewEmail.theme_textColor = GlobalPicker.textColor
   //     txtNewEmail.theme_placeholderAttributes = GlobalPicker.textPlaceHolder
//        imgBack.theme_image = GlobalPicker.imgBack

        txtPassword.theme_textColor = GlobalPicker.textColor
   //     txtPassword.theme_placeholderAttributes = GlobalPicker.textPlaceHolder
        lblTitle.theme_textColor = GlobalPicker.textColor
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        txtNewEmail.delegate = self
        txtPassword.delegate = self
        
        for txt in [txtNewEmail, txtPassword] {
            txt?.theme_tintColor = GlobalPicker.searchTintColor
        }
        
        viewUnderlineCollection.forEach { (viewUnderline) in
            viewUnderline.theme_backgroundColor = GlobalPicker.themeCommonColor
        }

//        self.txtNewEmail.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
//        self.txtPassword.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
//        self.txtNewEmail.becomeFirstResponder()
    }
    
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Change Email", comment: "")
        txtNewEmail.placeholder = NSLocalizedString("New Email Address", comment: "")
        txtPassword.placeholder = NSLocalizedString("Current Password", comment: "")
        btnChanges.setTitle(NSLocalizedString("SAVE CHANGES", comment: ""), for: .normal)
    }
    
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      //  setNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        txtNewEmail.text = nil
        txtPassword.text = nil
    }
    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.txtNewEmail.semanticContentAttribute = .forceRightToLeft
                self.txtNewEmail.textAlignment = .right
                self.txtPassword.semanticContentAttribute = .forceRightToLeft
                self.txtPassword.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.txtNewEmail.semanticContentAttribute = .forceLeftToRight
                self.txtNewEmail.textAlignment = .left
                self.txtPassword.semanticContentAttribute = .forceLeftToRight
                self.txtPassword.textAlignment = .left
            }
        }
    }
    
    
    @IBAction func didTapSaveChanges(_ sender: Any) {
        
        self.currEmail = UserDefaults.standard.string(forKey: Constant.UD_userEmail) ?? ""
        self.newEmail = self.txtNewEmail?.text ?? ""
        self.userPass = self.txtPassword?.text ?? ""
        
        if self.newEmail.isEmpty {
            
//            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter new email.", comment: ""))
            
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Enter new email.", comment: ""), type: .error)
            
        }
        else if self.newEmail.isEmpty {
            
//            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter password.", comment: ""))
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Enter password.", comment: ""), type: .error)
            
        }
        else {
            
            self .performWSToChangeEmail()
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
      //  self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     
        if textField == txtNewEmail {
            
            txtPassword.becomeFirstResponder()
        }
        else {
            
            txtPassword.resignFirstResponder()
            self.view.endEditing(true)
        }
        return true
    }
}

//====================================================================================================
// MARK:- Change Email webservice Respones
//====================================================================================================
extension ChangeEmailVC {
    
    func performWSToChangeEmail() {
    
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.changeEmail, eventDescription: "")
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["email":newEmail, "password":userPass]
        
        WebService.URLResponseAuth("auth/change/email", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.message?.lowercased() == "success" {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        
                        let userEmail = self.txtNewEmail.text ?? ""
                        UserDefaults.standard.set(userEmail, forKey: Constant.UD_userEmail)
                        UserDefaults.standard.synchronize()
                        self.delegate?.emailUpdated()
                        
                        SharedManager.shared.showAlertLoader(message: NSLocalizedString("Email changed successfully.", comment: ""), type: .alert)
                        
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
                
                do{
                    let FULLResponse = try
                        JSONDecoder().decode(checkEmailErrors.self, from: response)
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.errors?.email ?? "")
                    print("error parsing json objects",jsonerror)
                    
                }
                catch let jsonerror {
                    
                    print("error parsing json objects",jsonerror)
                    SharedManager.shared.logAPIError(url: "auth/change/email", error: jsonerror.localizedDescription, code: "")
                }
            }
            ANLoader.hide()
            
        }){ (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}
