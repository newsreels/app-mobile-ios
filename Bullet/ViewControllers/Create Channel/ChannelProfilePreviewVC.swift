//
//  ChannelProfilePreviewVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 17/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ChannelProfilePreviewVC: UIViewController {

    @IBOutlet weak var lblTitle1: UILabel!
    @IBOutlet weak var lblTitle2: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblChannelName: UILabel!
    @IBOutlet weak var lblChannelDescription: UILabel!
    
    @IBOutlet weak var viewCreate: UIView!
    @IBOutlet weak var lblCreate: UILabel!
    @IBOutlet weak var btnCreate: UIButton!
    
    var channelName = ""
    var channelDescription = ""
    var imageURL = ""
//    var isFromMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupLocalization()
        setupUI()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                
                self.lblTitle1.semanticContentAttribute = .forceRightToLeft
                self.lblTitle1.textAlignment = .right
                self.lblTitle2.semanticContentAttribute = .forceRightToLeft
                self.lblTitle2.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                
                self.lblTitle1.semanticContentAttribute = .forceLeftToRight
                self.lblTitle1.textAlignment = .left
                self.lblTitle2.semanticContentAttribute = .forceLeftToRight
                self.lblTitle2.textAlignment = .left
            }
        }
    }
    
    // MARK: - Methods
    
    func setupUI() {
        
        view.theme_backgroundColor = GlobalPicker.backgroundColorWhiteBlack
        lblTitle1.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblTitle2.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblChannelName.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblChannelDescription.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblCreate.textColor = .white
        viewCreate.theme_backgroundColor = GlobalPicker.themeCommonColor
        lblCreate.addTextSpacing(spacing: 1.0)
        
        self.view.layoutIfNeeded()
        viewCreate.layer.cornerRadius = viewCreate.frame.size.height/2
        imgProfile.layer.cornerRadius = imgProfile.frame.size.height/2
        imgProfile.layer.theme_borderColor = GlobalPicker.backgroundColorBlackWhiteCG
        imgProfile.layer.borderWidth = 2
        
        if imageURL != "" {
            imgProfile?.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
        }
        

    }
    
    
    func setupLocalization() {
        
        lblTitle1.text = channelName
        lblTitle2.text = NSLocalizedString("looks amazing!", comment: "")
        
//        if self.isFromMode {
//            lblCreate.text = NSLocalizedString("CONTINUE", comment: "")
//        }
//        else {
            lblCreate.text = NSLocalizedString("CREATE CHANNEL", comment: "")
            lblCreate.addTextSpacing(spacing: 2.0)
//        }
        lblChannelName.text = channelName
        lblChannelDescription.text = channelDescription
        
    }
  
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapCrateChannel(_ sender: Any) {
        
//        if isFromMode {
//            self.dismiss(animated: true, completion: nil)
//        }
//        else {
            performWSToCreateChannels()
//        }
    }
}


// MARK: - Webservices
extension ChannelProfilePreviewVC {
    
    func performWSToCreateChannels() {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        

        ANLoader.showLoading(disableUI: false)
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let params = [
            "name": channelName,
            "description": channelDescription,
            "icon": imageURL
        ]
        
        self.btnCreate.isUserInteractionEnabled = false
        WebService.URLResponse("studio/channels", method: .post, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            ANLoader.hide()
            guard let self = self else {
                return
            }
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                if FULLResponse.channel != nil {
                    
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Channel created succesfully", comment: ""))
                } else {
                    
                    SharedManager.shared.showAlertLoader(message: FULLResponse.message ?? "")
                }
                   
                self.dismiss(animated: true, completion: nil)
                
            } catch let jsonerror {
                self.btnCreate.isUserInteractionEnabled = true
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "studio/channels", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            self.btnCreate.isUserInteractionEnabled = true
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
}
