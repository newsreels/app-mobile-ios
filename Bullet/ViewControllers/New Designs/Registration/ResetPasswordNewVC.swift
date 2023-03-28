//
//  ResetPasswordNewVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 09/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ResetPasswordNewVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setLocalization()
        setupUI()
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    // MARK: - Methods
    func setupUI() {
        
        emailContainerViewUI(isLoadingError: false)
        saveButton.backgroundColor = Constant.appColor.lightGray

        saveButton.layer.cornerRadius = 15
        
        saveButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)

    }
    
    func setLocalization() {
        
        titleLabel.text = NSLocalizedString("Reset your password!", comment: "")
        descLabel.text = NSLocalizedString("Please enter the email associated to your account. We will send you a link to reset your password.", comment: "")
        emailLabel.text = NSLocalizedString("Email", comment: "")
        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        saveButton.setTitle(NSLocalizedString("Send link", comment: ""), for: .normal)
        closeButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        
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
    

    // MARK: - Actions
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textField == self.emailTextField {
            
            errorLabel.text = ""
            emailContainerViewUI(isLoadingError: false)
            if let emailTxt = textField.text {
                if emailTxt.isValidEmail() {
                    
                    self.saveButton.backgroundColor = Constant.appColor.lightRed
                    self.saveButton.setTitleColor(.white, for: .normal)
                }
                else {
                    
                    self.saveButton.backgroundColor = Constant.appColor.lightGray
                    saveButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)
                    
                }
            }
        }
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        let user_Name = self.emailTextField.text ?? ""
        if user_Name.isEmpty {
            
//            SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: NSLocalizedString("Enter email.", comment: ""))
        }
        else {
            errorLabel.text = ""
            emailContainerViewUI(isLoadingError: false)
            performWSForForgotPassword()
            
        }
    }
}

extension ResetPasswordNewVC {
    
    func performWSForForgotPassword() {
    
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        saveButton.showLoader()
        
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["email": emailTextField.text ?? ""]
        
        WebService.URLResponseAuth("auth/forgot-password", method: .post, parameters: params, headers: token, withSuccess: { (response) in

            self.saveButton.hideLoaderView()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.success == true {
                    
//                    if self.isFromSignVC {
//
//                        self.lblResetEmail.text = "\(NSLocalizedString("A reset password link has been sent to", comment: "")) \(self.user_Name)"
//                        self.viewResetPassord.isHidden = true
//                        self.viewAlert.isHidden = false
//                        self.isSentLink = true
//                    }
//                    else {
//
//                        self.dismiss(animated: true) {
//
//                            self.delegateVC?.onDismissForgotPwdView()
//                        }
//                    }
                    SharedManager.shared.showAlertLoader(message: "\(NSLocalizedString("A reset password link has been sent to", comment: "")) \(self.emailTextField.text ?? "")", type: .alert)
                    
                    self.saveButton.hideLoaderView()
                }
                else {
                    self.saveButton.hideLoaderView()
//                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                    self.errorLabel.text = FULLResponse.message ?? ""
                    self.emailContainerViewUI(isLoadingError: true)
                }

                
            } catch let jsonerror {
                
                self.saveButton.hideLoaderView()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "auth/forgot-password", error: jsonerror.localizedDescription, code: "")
            }
            
        }){ (error) in
            
            self.saveButton.hideLoaderView()
            print("error parsing json objects",error)
        }
    }
}

