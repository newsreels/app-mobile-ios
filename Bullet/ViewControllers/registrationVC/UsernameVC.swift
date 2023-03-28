//
//  UsernameVC.swift
//  Bullet
//
//  Created by Mahesh on 09/06/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

let TEXT_FIELD_LIMIT = 25

class UsernameVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTitle1: UILabel!

    @IBOutlet weak var lblUname: UILabel!
    @IBOutlet weak var lblFname: UILabel!
    @IBOutlet weak var lblLname: UILabel!

    @IBOutlet weak var txtUname: UITextField!
    @IBOutlet weak var txtFname: UITextField!
    @IBOutlet weak var txtLname: UITextField!

    @IBOutlet weak var lblUcount: UILabel!
    @IBOutlet weak var lblFcount: UILabel!
    @IBOutlet weak var lblLcount: UILabel!
    
    @IBOutlet weak var viewNextButtonBG: GradientShadowView!
    @IBOutlet weak var lblNext: UILabel!
    @IBOutlet weak var imgError: UIImageView!
    @IBOutlet weak var activityController: UIActivityIndicatorView!
    
    @IBOutlet weak var constraintViewBgMainBottom: NSLayoutConstraint!
    
    var newAccessToken = ""
    var valid = false

    override func viewDidLoad() {
        super.viewDidLoad()

        activityController.stopAnimating()
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        IQKeyboardManager.shared.keyboardAppearance = .dark
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
     
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        
//        self.txtFname.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
//        self.txtLname.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        self.txtUname.delegate = self
        self.txtFname.delegate = self
        self.txtLname.delegate = self
        self.txtUname.becomeFirstResponder()
        
        self.setLocalizable()
        self.setDesignView()

    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.txtUname.semanticContentAttribute = .forceRightToLeft
                self.txtUname.textAlignment = .right
                self.txtFname.semanticContentAttribute = .forceRightToLeft
                self.txtFname.textAlignment = .right
                self.txtLname.semanticContentAttribute = .forceRightToLeft
                self.txtLname.textAlignment = .right
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                self.lblFname.semanticContentAttribute = .forceRightToLeft
                self.lblFname.textAlignment = .right
                self.lblLname.semanticContentAttribute = .forceRightToLeft
                self.lblLname.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.txtUname.semanticContentAttribute = .forceLeftToRight
                self.txtUname.textAlignment = .left
                self.txtFname.semanticContentAttribute = .forceLeftToRight
                self.txtFname.textAlignment = .left
                self.txtLname.semanticContentAttribute = .forceLeftToRight
                self.txtLname.textAlignment = .left
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                self.lblFname.semanticContentAttribute = .forceLeftToRight
                self.lblFname.textAlignment = .left
                self.lblLname.semanticContentAttribute = .forceLeftToRight
                self.lblLname.textAlignment = .left
            }
        }
        
    }
    //MARK: - user interface setup on loading
    func setDesignView() {
        
        self.view.backgroundColor = .black
        viewNextButtonBG.borderWidth = 2.5
        viewNextButtonBG.borderColor = Constant.appColor.purple
        viewNextButtonBG.topColor = UIColor.clear
        viewNextButtonBG.bottomColor = UIColor.clear
        viewNextButtonBG.cornerRadius  = viewNextButtonBG.frame.size.height / 2
          
        self.txtUname.textColor = .white
        self.txtUname.tintColor = .white
        
        self.txtFname.textColor = .white
        self.txtFname.tintColor = .white
        
        self.txtLname.textColor = .white
        self.txtLname.tintColor = .white

        lblUcount.text = "\(TEXT_FIELD_LIMIT)"
        lblFcount.text = "\(TEXT_FIELD_LIMIT)"
        lblLcount.text = "\(TEXT_FIELD_LIMIT)"
    }
    
    func setLocalizable() {
       
        self.lblTitle.text = NSLocalizedString("Enter profile name", comment: "")
        self.lblTitle1.text = NSLocalizedString("Enter username", comment: "")
        self.lblUname.text = NSLocalizedString("Username", comment: "")
        self.lblFname.text = NSLocalizedString("First Name", comment: "")
        self.lblLname.text = NSLocalizedString("Last Name", comment: "")

        self.txtFname.placeholder = NSLocalizedString("First Name", comment: "")
        self.txtLname.placeholder = NSLocalizedString("Last Name", comment: "")
        
        
        self.lblNext.text = NSLocalizedString("NEXT", comment: "")
        self.lblNext.addTextSpacing(spacing: 2.0)
    }
    
    //To Adjust view according to keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            print(keyboardHeight)
            
            // if self.backButtonCurrentStage == .emailStage {
            
    //        self.constraintViewBgMainBottom.constant = keyboardHeight
            //   }
        }
    }
    
//    @objc func textFieldDidChange(textField: UITextField) {
//
//        self.updateCharacterCount(textField)
//    }
    
    @IBAction func didTapNext(_ sender: Any) {
        
        if self.valid {
            
            self.performWebUpdateUsername()
            self.performWebUpdateProfile()
        }
        else {
            
            SharedManager.shared.showAlertView(source: self, title: "Alert", message: "Please enter correct Username")
        }
    }
    
    func performWebUpdateUsername() {
                
        let Uname = txtUname.text?.trim() ?? ""
        
        if Uname.isEmpty {
            
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Enter a username", comment: ""), type: .alert)
            return
        }
                
        self.view.endEditing(true)
        ANLoader.showLoading()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
                
        let params = ["username": Uname] as [String : Any]
        
        WebService.multiParamsULResponseMultipleImages("auth/update-profile", method: .patch, parameters: params, headers: token, ImageDic: nil) { (response) in
            do {
                
                let FULLResponse = try
                    JSONDecoder().decode(updateProfileDC.self, from: response)
                                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "auth/update-profile", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
        } withAPIFailure: { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWebUpdateProfile() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let Uname = txtUname.text?.trim() ?? ""
        let fname = txtFname.text?.trim() ?? ""
        let lname = txtLname.text?.trim() ?? ""
        
        if Uname.isEmpty {
            
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Enter a username", comment: ""), type: .alert)
            return
        }
        
        if fname.isEmpty {
            
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Enter a first name", comment: ""), type: .alert)
            return
        }
        
        if lname.isEmpty {
            
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Enter a last name", comment: ""), type: .alert)
            return
        }
        
        let token = newAccessToken.isEmpty ? UserDefaults.standard.string(forKey: Constant.UD_userToken) : newAccessToken
                
        let params = ["first_name": fname,
                      "last_name": lname,
                      "mobile_number": ""] as [String : Any]
        
        WebService.multiParamsULResponseMultipleImages("auth/update-profile", method: .patch, parameters: params, headers: token, ImageDic: nil) { (response) in
            do {
                
                let FULLResponse = try
                    JSONDecoder().decode(updateProfileDC.self, from: response)
                
                ANLoader.hide()
                
                if FULLResponse.success == true {
                    
                    if let user = FULLResponse.user {

                        SharedManager.shared.userId = user.id ?? ""
                        
                        if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                            userDefaults.set(fname as AnyObject, forKey: "first_name")
                            userDefaults.synchronize()
                        }

                        let encoder = JSONEncoder()
                        if let encoded = try? encoder.encode(user) {
                            SharedManager.shared.userDetails = encoded
                        }
                    }
                }
                else {
                    
                    SharedManager.shared.logAPIError(url: "auth/update-profile", error: FULLResponse.message ?? "", code: "")
                }
                
                let vc = registerProfileUploadVC.instantiate(fromAppStoryboard: .registration)
                self.navigationController?.pushViewController(vc, animated: true)

            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "auth/update-profile", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
        } withAPIFailure: { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSCheckUsername(_ text: String) {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        let param = ["username": text]
        
        imgError.isHidden = true
        activityController.startAnimating()
        WebService.URLResponseAuth("auth/username", method: .post, parameters: param, headers: token, withSuccess: { (response) in
            
            do {
                
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                self.activityController.stopAnimating()
                self.valid = FULLResponse.valid ?? false
                self.imgError.isHidden = false
                self.imgError.image = UIImage(named: self.valid ? "icn_valid_username" : "icn_invalid_username")
                
            } catch let jsonerror {
                
                print("error parsing json objects", jsonerror)
                SharedManager.shared.logAPIError(url: "auth/username", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
}

//MARK:- UITextView Delegate
extension UsernameVC: UITextFieldDelegate {
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        if count <= TEXT_FIELD_LIMIT {
            
            if textField == txtUname {
                
                lblUcount.text = "\(count == 0 ? TEXT_FIELD_LIMIT : count)"
                UIView.transition(with: self.lblUname, duration: 0.4, options: .transitionCrossDissolve, animations: { self.lblUname.isHidden = count == 0 ? true : false })
                
                self.perform(#selector(getTextOnStopTyping), with: textField, afterDelay: 0.5)
                
            }
            else if textField == txtFname {
                self.lblFcount.text = "\(count == 0 ? TEXT_FIELD_LIMIT : count)"
                UIView.transition(with: self.lblFname, duration: 0.4, options: .transitionCrossDissolve, animations: { self.lblFname.isHidden = count == 0 ? true : false })
            }
            else {
                self.lblLcount.text = "\(count == 0 ? TEXT_FIELD_LIMIT : count)"
                UIView.transition(with: self.lblLname, duration: 0.4, options: .transitionCrossDissolve, animations: { self.lblLname.isHidden = count == 0 ? true : false })
            }
            return true
        }
        return false

        //return (textField.text?.count ?? 0) + (string.count - range.length) <= TEXT_FIELD_LIMIT
    }
    
    @objc func getTextOnStopTyping(_ textField: UITextField) {
        
        performWSCheckUsername(textField.text ?? "")
    }
    
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//
//        self.updateCharacterCount(textField)
//    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//        if(textField == txtFname) {
//
//            self.lblFcount.text = "\(TEXT_FIELD_LIMIT)"
//        }
//        else {
//            self.lblLcount.text = "\(TEXT_FIELD_LIMIT)"
//        }
//    }

//    private func updateCharacterCount(_ txtField: UITextField) {
//
//        let descriptionCount = txtField.text?.count ?? 0
//
//        if txtField == txtFname {
//            if txtFname.text == "" {
//                self.lblFcount.text = "\(TEXT_FIELD_LIMIT)"
//            }
//            else {
//                self.lblFcount.text = "\((0) + descriptionCount)"
//            }
//        }
//        else {
//            if txtLname.text ==  "" {
//                self.lblLcount.text = "\(TEXT_FIELD_LIMIT)"
//            }
//            else {
//                self.lblLcount.text = "\((0) + descriptionCount)"
//            }
//        }
//    }
}
