//
//  contactUsVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 19/08/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class contactUsVC: UIViewController, UITextViewDelegate, UITextFieldDelegate, successAlertDelegate {

    @IBOutlet weak var btnSendEmail: UIButton!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var lblHello: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblMessageTitle: UILabel!
    
    var currEmail = ""
    var userEmail = ""
    var userName = ""
    var userMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        lblDescription.theme_textColor = GlobalPicker.textColor
        lblTitle.theme_textColor = GlobalPicker.textColor
        txtName.theme_textColor = GlobalPicker.textColor
        txtEmail.theme_textColor = GlobalPicker.textColor
        txtMessage.theme_textColor = GlobalPicker.textColor
        btnSendEmail.titleLabel?.textColor = .white
        //theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        imgBack.theme_image = GlobalPicker.imgBack

        lblName.textColor = Constant.appColor.lightRed
        lblEmail.textColor = Constant.appColor.lightRed
        lblMessageTitle.textColor = Constant.appColor.lightRed
        btnSendEmail.backgroundColor = Constant.appColor.lightRed
        //theme_backgroundColor = //GlobalPicker.themeCommonColor
        //txtMessage.theme_keyboardAppearance = GlobalPicker.textViewPlaceHolder
        
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true

        btnSendEmail.addTextSpacing(spacing: 2)
        
        txtMessage.text = NSLocalizedString("Write your message...", comment: "")
        txtMessage.textColor = Constant.appColor.customGrey
        txtMessage.delegate = self
        
        let main_string = NSLocalizedString("Drop us a message if you need help with something, we'd love to hear from you!", comment: "")
        let string_to_color = NSLocalizedString("Drop us a message", comment: "")

        let range = (main_string as NSString).range(of: string_to_color)
        let attribute = NSMutableAttributedString.init(string: main_string)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: Constant.appColor.lightRed , range: range)

        lblDescription.attributedText = attribute
        lblDescription.setLineSpacing(lineSpacing: 7)
        
        self.currEmail = UserDefaults.standard.string(forKey: Constant.UD_userEmail) ?? ""
        
        if !(self.currEmail.isEmpty) {
            
            self.txtEmail.text = self.currEmail
        }
        
        self.txtName.delegate = self
        self.txtEmail.delegate = self
        self.txtMessage.delegate = self
        
        if userMessage != "" {
            txtMessage.text = userMessage
            txtMessage.theme_textColor = GlobalPicker.textColor
        }
    }
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Contact Us", comment: "")
        lblHello.text = NSLocalizedString("Hello there!", comment: "")
        lblDescription.text = NSLocalizedString("Drop us a message if you need help with something, we'd love to hear from you!", comment: "")
        lblMessage.text = NSLocalizedString("Message us,", comment: "")
        lblName.text = NSLocalizedString("Name", comment: "")
        lblEmail.text = NSLocalizedString("E-mail", comment: "")
        lblMessageTitle.text = NSLocalizedString("Message", comment: "")
        
        btnSendEmail.setTitle(NSLocalizedString("SEND MESSAGE", comment: ""), for: .normal)
    }
    
    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblDescription.semanticContentAttribute = .forceRightToLeft
                self.lblDescription.textAlignment = .right
                self.txtName.semanticContentAttribute = .forceRightToLeft
                self.txtName.textAlignment = .right
                self.txtEmail.semanticContentAttribute = .forceRightToLeft
                self.txtEmail.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblDescription.semanticContentAttribute = .forceLeftToRight
                self.lblDescription.textAlignment = .left
                self.txtName.semanticContentAttribute = .forceLeftToRight
                self.txtName.textAlignment = .left
                self.txtEmail.semanticContentAttribute = .forceLeftToRight
                self.txtEmail.textAlignment = .left
            }
        }
    }
    override func viewDidLayoutSubviews() {
        
        txtName.theme_tintColor = GlobalPicker.searchTintColor
        txtEmail.theme_tintColor = GlobalPicker.searchTintColor
        txtMessage.theme_tintColor = GlobalPicker.searchTintColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == Constant.appColor.customGrey {
            textView.text = nil
            textView.theme_textColor = GlobalPicker.textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            
            textView.text = NSLocalizedString("Write your message...", comment: "")
            textView.textColor = Constant.appColor.customGrey
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     
        if textField == txtName {
            
            txtEmail.becomeFirstResponder()
        }
        else if textField == txtEmail {
            
            txtMessage.becomeFirstResponder()
        }
        else {
            
            self.view.endEditing(true)
            txtMessage.resignFirstResponder()
            return false
         
        }
        return true
    }
    
    @IBAction func didTapSendEmail(_ sender: UIButton) {
        
        self.userEmail = self.txtEmail.text ?? ""
        self.userName = self.txtName.text ?? ""
        self.userMessage = self.txtMessage.text ?? ""
        
        if self.userName.isEmpty {
            
            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter Name.", comment: ""))
        }
        else if self.userEmail.isEmpty {
            
            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter Email.", comment: ""))
        }
        else if self.userMessage.isEmpty || self.userMessage == NSLocalizedString("Write your message...", comment: "")  {
            
            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Write your message...", comment: ""))
        }
        else {
          
            self.performWSToContact()
        }
    }
    
    
    //delegate
    func didTapDismissController() {
        
        self.didTapBack(self)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

//====================================================================================================
// MARK:- Contact webservice Respones
//====================================================================================================
extension contactUsVC {
    
    func performWSToContact() {
    
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
    
        ANLoader.showLoading(disableUI: true)
    
        let params = ["email":userEmail.removeWhitespace(), "name":userName, "message":userMessage]
        
        WebService.URLResponse("contact/help/new", method: .post, parameters: params, headers: nil, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                if FULLResponse.message?.lowercased() == "success" {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                
                        let vc = SuccessAlertVC.instantiate(fromAppStoryboard: .registration)
                        vc.delegate = self
                        self.present(vc, animated: true, completion: nil)
//                        SharedManager.shared.showAlertView(source: self, title: "Thank you for getting in touch!", message:"We appreciate you contacting us. One of our colleagues will get back in touch with you soon!\n\nHave a great day!")
                        
                    })
                }
                else {
                    
                    let FULLResponse = try
                        JSONDecoder().decode(checkEmailErrors.self, from: response)
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.errors?.email ?? "")
                }
                ANLoader.hide()
                
            } catch let jsonerror {
                
                do{
                    let FULLResponse = try
                        JSONDecoder().decode(checkEmailErrors.self, from: response)
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.errors?.email ?? "")
                    print("error parsing json objects",jsonerror)
                    
                }
                catch let jsonerror {
                    
                    do{
                        
                        print("error parsing json objects",jsonerror)
                    }
                }
            }
            ANLoader.hide()
            
        }){ (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}
