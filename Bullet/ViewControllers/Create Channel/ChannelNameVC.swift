//
//  ChannelNameVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 17/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ChannelNameVC: UIViewController {

    @IBOutlet weak var lblTitle1: UILabel!
    @IBOutlet weak var lblTitle2: UILabel!
    @IBOutlet weak var txtChannel: UITextField!
    @IBOutlet weak var viewUnderline: UIView!
    @IBOutlet weak var lblMaxCount: UILabel!
    @IBOutlet weak var lblNext: UILabel!
    @IBOutlet weak var viewNext: UIView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblValid: UILabel!
    
    let txtMaxLength = 50
    var dataValid = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        SharedManager.shared.selectedChannelDesc = ""
        SharedManager.shared.selectedChannelImageURL = ""
        
        setupLocalization()
        setupUI()
        setDisableSaveButtonState()
        
        IQKeyboardManager.shared.enable = false
        txtChannel.inputAccessoryView = nil
        txtChannel.autocapitalizationType = .sentences
        txtChannel.autocorrectionType = .no
        txtChannel.spellCheckingType = .no
        txtChannel.delegate = self
        txtChannel.addTarget(self, action: #selector(updateCharacterCount), for: UIControl.Event.allEditingEvents)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.txtChannel.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            
            DispatchQueue.main.async {
                self.lblTitle1.semanticContentAttribute = .forceRightToLeft
                self.lblTitle1.textAlignment = .right
                self.lblTitle2.semanticContentAttribute = .forceRightToLeft
                self.lblTitle2.textAlignment = .right
                self.txtChannel.semanticContentAttribute = .forceRightToLeft
                self.txtChannel.textAlignment = .right
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.lblTitle1.semanticContentAttribute = .forceLeftToRight
                self.lblTitle1.textAlignment = .left
                self.lblTitle2.semanticContentAttribute = .forceLeftToRight
                self.lblTitle2.textAlignment = .left
                self.txtChannel.semanticContentAttribute = .forceLeftToRight
                self.txtChannel.textAlignment = .left
            }
        }
    }
    
    // MARK: - Methods
    func setupUI() {
        
        view.theme_backgroundColor = GlobalPicker.backgroundColorWhiteBlack
        lblTitle1.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblTitle2.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        txtChannel.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        txtChannel.theme_placeholderAttributes = GlobalPicker.textPlaceHolderChannel
        lblMaxCount.theme_textColor = GlobalPicker.ChannelDescriptionColor
        lblMaxCount.text = "\(txtMaxLength)"
        txtChannel.theme_tintColor = GlobalPicker.backgroundColorBlackWhite

        lblValid.text = ""
    }
    
    func setupLocalization() {
        
        lblTitle1.text = NSLocalizedString("Start by creating your", comment: "")
        lblTitle2.text = NSLocalizedString("channel name", comment: "")
        txtChannel.placeholder = NSLocalizedString("Channel name", comment: "")
        lblNext.text = NSLocalizedString("NEXT", comment: "")
        lblNext.addTextSpacing(spacing: 2.0)
    }
    
    func setDisableSaveButtonState() {
        
        let channelText = (txtChannel.text ?? "").trim()
        
        if channelText.isEmpty {
            
            self.btnNext.isUserInteractionEnabled = false
            viewNext.theme_backgroundColor = GlobalPicker.newsHeaderBGColor

//            if MyThemes.current == .dark {
//                lblNext.textColor = "#393737".hexStringToUIColor()
//            }
//            else {
//                lblNext.textColor = "#84838B".hexStringToUIColor()
//            }
            
            lblNext.theme_textColor = GlobalPicker.ChannelDescriptionColor
        } else if dataValid == false {
            self.btnNext.isUserInteractionEnabled = false
            viewNext.theme_backgroundColor = GlobalPicker.newsHeaderBGColor
            lblNext.theme_textColor = GlobalPicker.ChannelDescriptionColor
        }
        else {
            
            self.btnNext.isUserInteractionEnabled = true
            viewNext.theme_backgroundColor = GlobalPicker.themeCommonColor
            lblNext.textColor = .white
        }
    }
    
    
    @objc func updateCharacterCount() {
        self.lblMaxCount.text = "\((txtMaxLength) - (self.txtChannel.text?.length ?? 0))"
        
        setDisableSaveButtonState()
        
        if (self.txtChannel.text?.length ?? 0) != 0 &&  (self.txtChannel.text?.isBlankOrEmpty() ?? false) == false {
            searchChannelName()
        } else {
            lblValid.text = ""
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        
        if (txtChannel.text?.isBlankOrEmpty() ?? true) {
            
            lblValid.text = NSLocalizedString("Please enter a valid channel name", comment: "")
        } else {
            
            
            performWSToValidateChannelName(name: txtChannel.text ?? "", isSearch: false) { [weak self] data in
                
                if data?.valid ?? false {
                    
                    let vc = ChannelDescriptionVC.instantiate(fromAppStoryboard: .Channel)
                    vc.channelName = self?.txtChannel.text ?? ""
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                } else {
                    self?.lblValid.text = NSLocalizedString("Already in use", comment: "")
                    self?.lblValid.textColor = UIColor.red
                }
            }
        }
    }
    
    
    func searchChannelName() {
        
        performWSToValidateChannelName(name: txtChannel.text ?? "", isSearch: true) { [weak self] data in
            
            if data?.valid ?? false {
                if (self?.txtChannel.text?.isEmpty ?? false) == false {
                    self?.lblValid.text = NSLocalizedString("Available", comment: "")
                    self?.lblValid.textColor = UIColor.green
                } else {
                    self?.lblValid.text = ""
                }
                self?.dataValid = true
            } else {
                self?.lblValid.text = (data?.message ?? "") == "" ? NSLocalizedString("Already in use", comment: "") : (data?.message ?? "")
                self?.lblValid.textColor = UIColor.red
                
                self?.dataValid = false
            }
            self?.setDisableSaveButtonState()
        }
    }
    
}

extension ChannelNameVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
        let updatedString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        let status = updatedString.length <= txtMaxLength
//        if status {
//            updateCharacterCount()
//        }
        
        return status
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return false
    }
    
}


// MARK: - Webservices
extension ChannelNameVC {
    
    func performWSToValidateChannelName(name: String, isSearch: Bool, completionHandler: @escaping (_ data: ChannelValidateDC?) -> Void) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        if isSearch == false {
            ANLoader.showLoading(disableUI: false)
        }
        
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let param = ["name": name]
        WebService.URLResponse("studio/channels/exists", method: .get, parameters: param, headers: token, withSuccess: { [weak self] (response) in
            ANLoader.hide()
            guard let self = self else {
                return
            }
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelValidateDC.self, from: response)
                
                
                completionHandler(FULLResponse)
                
            } catch let jsonerror {
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "studio/channels", error: jsonerror.localizedDescription, code: "")
                
                completionHandler(nil)
            }
        }) { (error) in
            ANLoader.hide()
            completionHandler(nil)
            print("error parsing json objects",error)
        }
    }
    
}

