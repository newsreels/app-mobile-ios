//
//  AddUsernameVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 08/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol AddUsernameVCDelegate: AnyObject {
    func userDismissed(vc: AddUsernameVC)
}

class AddUsernameVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameContainerView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var UsernameErrorLabel: UILabel!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var loaderButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var validUsername = false
    var validName = false
    var isPresented = false
    weak var delegate: AddUsernameVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setLocalization()
        setupUI()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        self.navigationController?.presentationController?.delegate = self
        self.presentationController?.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Methods
    func setupUI() {
        
        nameContainerViewUI(isLoadingError: false)
        usernameContainerViewUI(isLoadingError: false)
        loaderButton.setImage(nil, for: .normal)
        
    }

    func setLocalization() {
        
        titleLabel.text = NSLocalizedString("Create new account", comment: "")
        usernameLabel.text = NSLocalizedString("Username", comment: "")
        usernameTextField.placeholder = NSLocalizedString("Username", comment: "")
        continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        
    }
    
    func nameContainerViewUI(isLoadingError:Bool) {
        if !isLoadingError {
            nameContainerView.layer.cornerRadius = 8
            nameContainerView.layer.borderWidth = 1
            nameContainerView.layer.borderColor = UIColor(displayP3Red: 0.871, green: 0.908, blue: 0.95, alpha: 1).cgColor
            nameTextField.textColor = .black
            nameTextField.placeholderColor = UIColor(displayP3Red: 0.744, green: 0.793, blue: 0.846, alpha: 1)
        }
        else {
            nameContainerView.layer.cornerRadius = 8
            nameContainerView.layer.borderWidth = 1
            nameContainerView.layer.borderColor = UIColor(displayP3Red: 0.447, green: 0.184, blue: 0.871, alpha: 1).cgColor
            nameTextField.textColor = UIColor(displayP3Red: 0.447, green: 0.184, blue: 0.871, alpha: 1)
            
            continueButton.backgroundColor = Constant.appColor.lightGray
            continueButton.layer.cornerRadius = 15
            continueButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)
        }
    }
    
    func usernameContainerViewUI(isLoadingError:Bool) {
        if !isLoadingError {
            usernameContainerView.layer.cornerRadius = 8
            usernameContainerView.layer.borderWidth = 1
            usernameContainerView.layer.borderColor = UIColor(displayP3Red: 0.871, green: 0.908, blue: 0.95, alpha: 1).cgColor
            usernameTextField.textColor = .black
            usernameTextField.placeholderColor = UIColor(displayP3Red: 0.744, green: 0.793, blue: 0.846, alpha: 1)
        }
        else {
            usernameContainerView.layer.cornerRadius = 8
            usernameContainerView.layer.borderWidth = 1
            usernameContainerView.layer.borderColor = UIColor(displayP3Red: 0.447, green: 0.184, blue: 0.871, alpha: 1).cgColor
            usernameTextField.textColor = UIColor(displayP3Red: 0.447, green: 0.184, blue: 0.871, alpha: 1)
            continueButton.backgroundColor = Constant.appColor.lightGray
            continueButton.layer.cornerRadius = 15
            continueButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)
            loaderButton.setImage(nil, for: .normal)
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textField == self.usernameTextField {
            
            UsernameErrorLabel.text = ""
            usernameContainerViewUI(isLoadingError: false)
            if textField.text?.count ?? 0 > 1 {
                validUsername = false
                performWSCheckUsername(textField.text ?? "")
            }
            else {
                validUsername = false
                self.loaderButton.setImage(nil, for: .normal)
            }
        }
        else if textField == self.nameTextField {
            
            if (textField.text?.count ?? 0) >= 3 {
                nameErrorLabel.text = ""
                self.nameContainerViewUI(isLoadingError: false)
                validName = true
            }
            else {
                validName = false
            }
            
        }
        
        if validName && validUsername {
            
            usernameContainerViewUI(isLoadingError: false)
            self.nameContainerViewUI(isLoadingError: false)
            self.continueButton.backgroundColor = Constant.appColor.lightRed
            self.continueButton.layer.cornerRadius = 15
            self.continueButton.setTitleColor(.white, for: .normal)
            
        }
        
    }
    
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        if validUsername && validName {
            // add name and username
            performWebUpdateProfile()
        }
        else {
            // show error
            
        }
        
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.delegate?.userDismissed(vc: self)
        if isPresented {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.delegate?.userDismissed(vc: self)
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension AddUsernameVC: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        self.delegate?.userDismissed(vc: self)
    }
}



extension AddUsernameVC {
    
    func performWSCheckUsername(_ text: String) {
        
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        let param = ["username": text]
        
        self.loaderButton.setImage(nil, for: .normal)
        loaderButton.showLoader(color: Constant.appColor.lightRed)
        WebService.URLResponseAuth("auth/username", method: .post, parameters: param, headers: token, withSuccess: { (response) in
            
            self.loaderButton.hideLoaderView()
            do {
                
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                let valid = FULLResponse.valid ?? false
                if valid {
                    self.UsernameErrorLabel.text = ""
                    self.usernameContainerViewUI(isLoadingError: false)
                    
                    self.validUsername = true
                    self.loaderButton.setImage(UIImage(named: "UsernameValid"), for: .normal)
                    if self.validName {
                        self.nameContainerViewUI(isLoadingError: false)
                        self.continueButton.backgroundColor = Constant.appColor.lightRed

                        self.continueButton.layer.cornerRadius = 15
                        
                        self.continueButton.setTitleColor(.white, for: .normal)
                    }
                    else {
                        self.nameErrorLabel.text = NSLocalizedString("Minimum 3 characters needed.", comment: "")
                        self.nameContainerViewUI(isLoadingError: true)
                    }
                    
                }
                else {
                    self.UsernameErrorLabel.text = NSLocalizedString("Username already taken. Enter a new one.", comment: "")
                    self.usernameContainerViewUI(isLoadingError: true)
                    
                    self.validUsername = false
                    self.loaderButton.setImage(UIImage(named: "UsernameInvalid"), for: .normal)
                    
                }
                
            } catch let jsonerror {
                self.loaderButton.hideLoaderView()
                print("error parsing json objects", jsonerror)
                SharedManager.shared.logAPIError(url: "auth/username", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            self.loaderButton.hideLoaderView()
            print("error parsing json objects",error)
        }
    }
    
    
    func performWebUpdateProfile() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
//        self.showLoaderInVC()
        self.continueButton.showLoader()
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let params = ["name": nameTextField.text?.trim() ?? "",
                      "username": usernameTextField.text?.trim() ?? ""] as [String : Any]
        
        WebService.multiParamsULResponseMultipleImages("auth/update-profile", method: .patch, parameters: params, headers: token, ImageDic: nil) { (response) in
            
//            self.hideLoaderVC()
            self.continueButton.hideLoaderView()
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(updateProfileDC.self, from: response)
                
                if FULLResponse.success == true {
                    
                    if let user = FULLResponse.user {
                        
                        SharedManager.shared.userId = user.id ?? ""

                        let encoder = JSONEncoder()
                        if let encoded = try? encoder.encode(user) {
                            SharedManager.shared.userDetails = encoded
                        }
                        
                        
                    }
                    
                    SharedManager.shared.isUserSetup = true
//                    self.appDelegate?.setHomeVC()
                    
                    let vc = SelectTopicsVC.instantiate(fromAppStoryboard: .RegistrationSB)
//                    let navVC = UINavigationController(rootViewController: vc)
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    
                    
//                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Profile updated successfully", comment: ""), duration: 1, position: .bottom)
                }
            } catch let jsonerror {
                
//                self.hideLoaderVC()
                self.continueButton.hideLoaderView()
                
                SharedManager.shared.logAPIError(url: "auth/update-profile", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
        } withAPIFailure: { (error) in
//            self.hideLoaderVC()
            self.continueButton.hideLoaderView()
            print("error parsing json objects",error)
        }
    }
    
}
