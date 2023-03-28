//
//  ChannelDescriptionVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 17/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ChannelDescriptionVC: UIViewController {

    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var lblTitle1: UILabel!
    @IBOutlet weak var lblTitle2: UILabel!
    @IBOutlet weak var lblTitle3: UILabel!
//    @IBOutlet weak var txtChannel: UITextField!
    @IBOutlet weak var viewUnderline: UIView!
    @IBOutlet weak var lblMaxCount: UILabel!
    @IBOutlet weak var lblNext: UILabel!
    @IBOutlet weak var viewNext: UIView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var txtChannel: AutoExpandingTextView!
    
    let txtMaxLength = 500
    var channelId = ""
    var channelName = ""
    var channelDescription = ""
    var isFromMode = false
    
    let lblPlaceHolder = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        txtChannel.inputAccessoryView = nil
        addTextViewPlaceHolderLabel()
        txtChannel.delegate = self
        
        setupLocalization()
        setupUI()
        setDisableSaveButtonState()
        
        IQKeyboardManager.shared.enable = false
        txtChannel.inputAccessoryView = nil
        txtChannel.autocapitalizationType = .sentences
        txtChannel.autocorrectionType = .no
        txtChannel.spellCheckingType = .no
        txtChannel.delegate = self
//        txtChannel.addTarget(self, action: #selector(updateCharacterCount), for: UIControl.Event.allEditingEvents)
        
        //Update channel description
        txtChannel.text = channelDescription
        txtChannel.adjustSize()
        if channelDescription != "" {
            
            lblTitle1.isHidden = true
            lblTitle2.isHidden = true
            lblTitle3.isHidden = true
            self.updateCharacterCount()
            
        }
//        print("lblTitle2.text", lblTitle2.text)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if SharedManager.shared.selectedChannelDesc != "" {
            txtChannel.text = SharedManager.shared.selectedChannelDesc
            txtChannel.adjustSize()
            updateCharacterCount()
        }
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
                
                self.lblPlaceHolder.semanticContentAttribute = .forceRightToLeft
                self.lblPlaceHolder.textAlignment = .right
                self.txtChannel.semanticContentAttribute = .forceRightToLeft
                self.txtChannel.textAlignment = .right
                self.lblPlaceHolder.frame.origin = CGPoint(x: 0, y: (self.txtChannel.font?.pointSize)! / 2)
                self.lblPlaceHolder.frame.size.width  = self.txtChannel.frame.size.width - 5
            }
            
        } else {
            DispatchQueue.main.async {
                
                self.lblPlaceHolder.semanticContentAttribute = .forceLeftToRight
                self.lblPlaceHolder.textAlignment = .left
                self.txtChannel.semanticContentAttribute = .forceLeftToRight
                self.txtChannel.textAlignment = .left
                self.lblPlaceHolder.frame.origin = CGPoint(x: 5, y: (self.txtChannel.font?.pointSize)! / 2)
                self.lblPlaceHolder.frame.size.width  = self.txtChannel.frame.size.width
            }
        }
    }
    // MARK: - Methods
    func setupUI() {
        
        txtChannel.text = ""
        lblNavTitle.theme_textColor = GlobalPicker.textColor
        view.theme_backgroundColor = GlobalPicker.backgroundColorWhiteBlack
        lblTitle1.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblTitle2.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblTitle3.theme_textColor = GlobalPicker.ChannelDescriptionColor
        txtChannel.theme_textColor = GlobalPicker.backgroundColorBlackWhite
//        txtChannel.theme_placeholderAttributes = GlobalPicker.textPlaceHolderChannel
        lblMaxCount.theme_textColor = GlobalPicker.ChannelDescriptionColor
    }
    
    func setupLocalization() {
        
        lblNavTitle.text = NSLocalizedString(channelDescription != "" ? "Description" : "", comment: "")

        lblTitle1.text = NSLocalizedString("Let people know what", comment: "")
        lblTitle2.text = NSLocalizedString("your channel is about", comment: "")
        lblTitle3.text = NSLocalizedString("No pressure, you can change this later.", comment: "")
//        txtChannel.placeholder = NSLocalizedString("Describe your channel", comment: "")
        lblNext.text = NSLocalizedString(isFromMode ? "SAVE" : "SKIP", comment: "")
        lblNext.addTextSpacing(spacing: 2.0)
    }
    
    func setDisableSaveButtonState() {
        
        let channelText = (txtChannel.text ?? "").trim()
        
        if channelText.isEmpty {
            
//            self.btnNext.isUserInteractionEnabled = false
            viewNext.theme_backgroundColor = GlobalPicker.newsHeaderBGColor

//            if MyThemes.current == .dark {
//                lblNext.textColor = "#393737".hexStringToUIColor()
//            }
//            else {
//                lblNext.textColor = "#84838B".hexStringToUIColor()
//            }
            
            lblNext.theme_textColor = GlobalPicker.ChannelDescriptionColor
            
            lblNext.text = NSLocalizedString(isFromMode ? "SAVE" : "SKIP", comment: "")
        }
        else {
            
//            self.btnNext.isUserInteractionEnabled = true
            viewNext.theme_backgroundColor = GlobalPicker.themeCommonColor
            lblNext.textColor = .white
            
            lblNext.text = NSLocalizedString(isFromMode ? "SAVE" : "NEXT", comment: "")
        }
    }
    
    func addTextViewPlaceHolderLabel() {
        lblPlaceHolder.text = NSLocalizedString("Describe your channel", comment: "")
        lblPlaceHolder.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
        lblPlaceHolder.sizeToFit()
        txtChannel.addSubview(lblPlaceHolder)
        lblPlaceHolder.theme_textColor = GlobalPicker.commentTextViewTextColor
        lblPlaceHolder.isHidden = !txtChannel.text.isEmpty
    }
    
    @objc func updateCharacterCount() {
        self.lblMaxCount.text = "\((txtMaxLength) - (self.txtChannel.text?.length ?? 0))"
        txtChannel.adjustSize()
        setDisableSaveButtonState()
    }
        
    // MARK: - Actions
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        
//        if (txtChannel.text?.isBlankOrEmpty() ?? true) {
//
//            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Please enter your channel description", comment: ""), duration: 1.0, position: .bottom)
//
//        } else {
//
//
//        }
        
        if isFromMode {
            
            self.performWSToUpdateChannel()
        }
        else {
            
            let vc = registerProfileUploadVC.instantiate(fromAppStoryboard: .registration)
            vc.isOpenFromCreateChannel = true
            vc.channelName = channelName
            vc.channelDescription = txtChannel.text ?? ""
            SharedManager.shared.selectedChannelDesc = txtChannel.text ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func performWSToUpdateChannel() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading()
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let params = ["description": txtChannel.text?.trim() ?? ""] as [String : Any]
        
        WebService.URLResponse("studio/channels/\(channelId)", method: .patch, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            ANLoader.hide()
            guard let self = self else {
                return
            }
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                if let _ = FULLResponse.channel {
                }
                
                SharedManager.shared.showAlertLoader(message: NSLocalizedString("Channel updated succesfully", comment: ""), type: .alert)
                
                self.navigationController?.popToRootViewController(animated: true)

            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "studio/channels", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }

//        WebService.multiParamsULResponseMultipleImages("studio/channels/\(self.channelId)", method: .patch, parameters: params, headers: token, ImageDic: nil) { (response) in
//            do{
//
//                let FULLResponse = try
//                    JSONDecoder().decode(ChannelListDC.self, from: response)
//
//                if let _ = FULLResponse.channel {
//
//                }
//
//                SharedManager.shared.showAlertLoader(message: NSLocalizedString("Channel updated succesfully", comment: ""), type: .alert)
//
//                self.navigationController?.popToRootViewController(animated: true)
//
//                ANLoader.hide()
//            } catch let jsonerror {
//
//                SharedManager.shared.logAPIError(url: "auth/update-profile", error: jsonerror.localizedDescription, code: "")
//                ANLoader.hide()
//                print("error parsing json objects",jsonerror)
//            }
//        } withAPIFailure: { (error) in
//            ANLoader.hide()
//            print("error parsing json objects",error)
//        }
    }
}


extension ChannelDescriptionVC: UITextViewDelegate {
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
        let updatedString = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        
        let status = updatedString.length <= txtMaxLength
//        if status {
//            updateCharacterCount()
//        }
        txtChannel.adjustSize()
        return status
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        lblPlaceHolder.isHidden = !textView.text.isEmpty
        
        updateCharacterCount()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        lblPlaceHolder.isHidden = !textView.text.isEmpty
        
        updateCharacterCount()
    }
    
    
}
