//
//  UserInfoVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 28/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift


class UserInfoVC: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    
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
    
    var currentName = ""
    var currentUsername = ""
    
    var validUsername = false
    var validName = false
    var imageSelected: UIImage?
    let imagePicker = ImagePicker()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    // MARK: - Methods
    func setupUI() {
        
        profileImageView.layer.borderColor = Constant.appColor.lightGray.cgColor
        profileImageView.layer.borderWidth = 0.5
        profileImageView.backgroundColor = Constant.appColor.lightRed
        
        nameContainerViewUI(isLoadingError: false)
        usernameContainerViewUI(isLoadingError: false)
        loaderButton.setImage(nil, for: .normal)
        
        if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {

            let profile = user.profile_image ?? ""
//            let cover = user.cover_image ?? ""

            if profile.isEmpty {
                profileImageView.theme_image = GlobalPicker.imgUserPlaceholder
            }
            else {
                profileImageView.sd_setImage(with: URL(string: profile), placeholderImage: nil)
            }
            
            currentName = user.first_name ?? ""
            currentUsername = user.username ?? ""
            
            nameTextField.text = user.first_name ?? ""
            usernameTextField.text = user.username ?? ""
            
            validName = true
            validUsername = true
            
            showSaveButtonUI(selected: false)
        }
        
        
    }
    
    override func viewWillLayoutSubviews() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textField == self.usernameTextField {
            
            UsernameErrorLabel.text = ""
            usernameContainerViewUI(isLoadingError: false)
            if textField.text == currentUsername {
                validUsername = true
            }
            else if textField.text?.count ?? 0 > 1 {
                validUsername = false
                performWSCheckUsername(textField.text ?? "")
            }
            else {
                validUsername = false
                self.loaderButton.setImage(nil, for: .normal)
            }
        }
        else if textField == self.nameTextField {
            
            if textField.text == currentName {
                validName = true
            }
            else if (textField.text?.count ?? 0) >= 3 {
                nameErrorLabel.text = ""
                self.nameContainerViewUI(isLoadingError: false)
                validName = true
            }
            else {
                validName = false
            }
            
        }
        
        if nameTextField.text == currentName {
            validName = true
        }
        if usernameTextField.text == currentUsername {
            validUsername = true
        }
        
        if validName && validUsername {
            
            self.usernameContainerViewUI(isLoadingError: false)
            self.nameContainerViewUI(isLoadingError: false)
            
            if currentName == self.nameTextField.text ?? "" && currentUsername == self.usernameTextField.text && imageSelected == nil {
                
                showSaveButtonUI(selected: false)
            }
            else {
                showSaveButtonUI(selected: true)
            }
            
        }
        
    }
    
    func showSaveButtonUI(selected: Bool) {
        
        if selected {
            self.continueButton.backgroundColor = Constant.appColor.lightRed
            self.continueButton.layer.cornerRadius = 15
            self.continueButton.setTitleColor(.white, for: .normal)
        }
        else {
            continueButton.backgroundColor = Constant.appColor.lightGray
            continueButton.layer.cornerRadius = 15
            continueButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)
        }
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
            
            showSaveButtonUI(selected: false)
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
            
            showSaveButtonUI(selected: false)
            
            loaderButton.setImage(nil, for: .normal)
        }
    }
    
    @IBAction func didTapSetImage(_ sender: Any) {
        
        imagePicker.viewController = self
        imagePicker.editingEnabled = true
        
        imagePicker.onPick = { [weak self] image in
            self?.profileImageView.image = image
            self?.imageSelected = image
            self?.showSaveButtonUI(selected: true)
        }
        //imagePicker.viewController?.modalPresentationStyle = .overFullScreen
        imagePicker.show()
    }
  
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        if validUsername && validName {
            // add name and username
            if currentName != self.nameTextField.text ?? "" || currentUsername != self.usernameTextField.text ?? "" || imageSelected != nil {
                performWebUpdateProfile()
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            // show error
            
        }
        
    }

    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension UserInfoVC {
    
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
                        self.showSaveButtonUI(selected: true)
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
        
        var dicSelectedImages = [String: UIImage]()
        
        if imageSelected != nil {
            dicSelectedImages["profile_image"] = imageSelected
        }
        
        let params = ["name": nameTextField.text?.trim() ?? "",
                      "username": usernameTextField.text?.trim() ?? ""] as [String : Any]
        
        WebService.multiParamsULResponseMultipleImages("auth/update-profile", method: .patch, parameters: params, headers: token, ImageDic: dicSelectedImages) { (response) in
            
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
                    
                    
                    self.navigationController?.popViewController(animated: true)
                    
                    
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
