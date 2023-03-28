//
//  AddPasswordVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 08/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class AddPasswordVC: UIViewController {

    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var infoLabel1: UILabel!
    @IBOutlet weak var infoLabel2: UILabel!
    @IBOutlet weak var infoLabel3: UILabel!
    
    @IBOutlet weak var infoImageView1: UIImageView!
    @IBOutlet weak var infoImageView2: UIImageView!
    @IBOutlet weak var infoImageView3: UIImageView!
    
    @IBOutlet weak var passwordImageView: UIImageView!
    
    let errorColor = UIColor(displayP3Red: 0.42, green: 0.393, blue: 0.463, alpha: 1)
    let successColor = UIColor(displayP3Red: 0.153, green: 0.682, blue: 0.376, alpha: 1)
    let errorImage = UIImage(named: "checkbox")
    let successImage = UIImage(named: "checkboxSelected")
    
    var iconClick = true
    var email = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setLocalization()
        setupUI()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        infoLabel1.text = NSLocalizedString("At least 8 characters", comment: "")
        infoLabel2.text = NSLocalizedString("Include a number", comment: "")
        infoLabel1.text = NSLocalizedString("Uppercase letter", comment: "")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    
    
    
    // MARK: - Methods
    func setupUI() {
        
        passwordContainerView.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)

        passwordContainerView.layer.cornerRadius = 8

        passwordContainerView.layer.borderWidth = 1

        passwordContainerView.layer.borderColor = UIColor(displayP3Red: 0.871, green: 0.908, blue: 0.95, alpha: 1).cgColor
        
        passwordTextField.textColor = .black
        passwordTextField.placeholderColor = UIColor(displayP3Red: 0.744, green: 0.793, blue: 0.846, alpha: 1)
        
        
        saveButton.backgroundColor = Constant.appColor.lightGray

        saveButton.layer.cornerRadius = 15
        
        saveButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)
        
        
        passwordTextField.isSecureTextEntry = true
        passwordImageView.image = UIImage(named: "icn_hide_pwd")
        
    }
    
    
    func setLocalization() {
        
        titleLabel.text = NSLocalizedString("Add a password", comment: "")
        passwordLabel.text = NSLocalizedString("Password", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        saveButton.setTitle(NSLocalizedString("Save password", comment: ""), for: .normal)
        
    }
    
    
    func isValid() -> Bool {
        
        if let passwordTxt = passwordTextField.text {
            
            var valid = true
            // Check All conditions
            // 1. Atleast 8 characters
            if passwordTxt.count >= 8 {
                infoLabel1.textColor = successColor
                infoImageView1.image = successImage
            }
            else {
                infoLabel1.textColor = errorColor
                infoImageView1.image = errorImage
                valid = false
            }
            
            
            // 2. include number
            if passwordTxt.stringHasNumber() {
                
                infoLabel2.textColor = successColor
                infoImageView2.image = successImage
            }
            else {
                infoLabel2.textColor = errorColor
                infoImageView2.image = errorImage
                
                valid = false
            }
            
            
            // 3. check uppercase letter
            if passwordTxt.stringHasUppercase() {
                
                infoLabel3.textColor = successColor
                infoImageView3.image = successImage
            }
            else {
                infoLabel3.textColor = errorColor
                infoImageView3.image = errorImage
                
                valid = false
            }
            
            
            return valid
        }
        
        return false
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textField == self.passwordTextField {
            
            if isValid() {
                saveButton.setTitleColor(.white, for: .normal)
                saveButton.backgroundColor = Constant.appColor.lightRed
            }
            else {
                saveButton.setTitleColor(Constant.appColor.buttonLightGaryText, for: .normal)
                saveButton.backgroundColor = Constant.appColor.lightGray
            }
            
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func didTapSave(_ sender: Any) {
        

        
        let vc = TermsVC.instantiate(fromAppStoryboard: .RegistrationSB)
        vc.webURL = "https://www.newsinbullets.app/terms/?header=false"
        vc.email = self.email
        vc.password = self.passwordTextField.text ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    
        
    }
    
    @IBAction func didTapShowPassword(_ sender: Any) {
        
        
        if(iconClick == true) {
            passwordTextField.isSecureTextEntry = false
            passwordImageView.image = UIImage(named: "icn_show_pwd")
        } else {
            passwordTextField.isSecureTextEntry = true
            passwordImageView.image = UIImage(named: "icn_hide_pwd")
        }
        
        iconClick = !iconClick
        
    }
    
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
