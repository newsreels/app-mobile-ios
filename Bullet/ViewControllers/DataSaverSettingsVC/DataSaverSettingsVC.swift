//
//  DataSaverSettingsVCViewController.swift
//  Bullet
//
//  Created by Khadim Hussain on 07/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import DataCache

class DataSaverSettingsVC: UIViewController {

    @IBOutlet weak var lblAutoPlay: UILabel!
    @IBOutlet weak var lblReaderMode: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnAutoplayOn: UIButton!
    @IBOutlet weak var btnAutoplayOff: UIButton!
    @IBOutlet weak var btnReaderModeOn: UIButton!
    @IBOutlet weak var btnReaderModeOff: UIButton!
    
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet var btnCollection: [UIButton]!
    @IBOutlet var viewCollectionColorBG: [UIView]!
    
    var lastStatusReaderMode = false
    var switchAutoPlayState = false
    var switchReaderModeState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblAutoPlay.theme_textColor = GlobalPicker.textColor
        lblTitle.theme_textColor = GlobalPicker.textColor
        self.lblAutoPlay.addTextSpacing(spacing: 2.25)
        self.lblAutoPlay.setLineSpacing(lineSpacing: 5)
        imgBack.theme_image = GlobalPicker.imgBack
        self.lblReaderMode.theme_textColor = GlobalPicker.textColor
        self.lblReaderMode.addTextSpacing(spacing: 2.25)
        self.lblReaderMode.setLineSpacing(lineSpacing: 5)

        self.btnAutoplayOn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnAutoplayOff.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnReaderModeOff.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnReaderModeOn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        for btn in btnCollection {
            btn.layer.cornerRadius = btn.frame.height / 2
        }
        
        viewCollectionColorBG.forEach {
            $0.theme_backgroundColor = GlobalPicker.switchBGColor
        }
        
        self.setupLocalization()
        self.setupView()
    }
    
    func setupView() {
        
        lastStatusReaderMode = SharedManager.shared.readerMode
        if SharedManager.shared.videoAutoPlay == true {
            
            //On News
            self.btnAutoplayOff.layer.backgroundColor = UIColor.clear.cgColor
            self.btnAutoplayOn.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG

            self.btnAutoplayOff.tintColor = Constant.appColor.customGrey
            self.btnAutoplayOn.tintColor = UIColor.white
            
            self.switchAutoPlayState = true
        }
        else {
            
            //Off news
            self.btnAutoplayOff.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btnAutoplayOn.layer.backgroundColor = UIColor.clear.cgColor
            
            self.btnAutoplayOff.tintColor = UIColor.white
            self.btnAutoplayOn.tintColor = Constant.appColor.customGrey
            
            self.switchAutoPlayState = false

        }
        
        if SharedManager.shared.readerMode == true {
            
            //On News
            self.btnReaderModeOff.layer.backgroundColor = UIColor.clear.cgColor
            self.btnReaderModeOn.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG

            self.btnReaderModeOff.tintColor = Constant.appColor.customGrey
            self.btnReaderModeOn.tintColor = UIColor.white
            
            self.switchReaderModeState = true
        }
        else {
            
            //Off news
            self.btnReaderModeOff.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btnReaderModeOn.layer.backgroundColor = UIColor.clear.cgColor
            
            self.btnReaderModeOff.tintColor = UIColor.white
            self.btnReaderModeOn.tintColor = Constant.appColor.customGrey
            
            self.switchReaderModeState = false

        }
    }
    
    override func viewWillLayoutSubviews() {

        if SharedManager.shared.isSelectedLanguageRTL() {

            DispatchQueue.main.async {

                self.lblAutoPlay.semanticContentAttribute = .forceRightToLeft
                self.lblAutoPlay.textAlignment = .right
                self.lblReaderMode.semanticContentAttribute = .forceRightToLeft
                self.lblReaderMode.textAlignment = .right
            }

        } else {

            DispatchQueue.main.async {

                self.lblAutoPlay.semanticContentAttribute = .forceLeftToRight
                self.lblAutoPlay.textAlignment = .left
                self.lblReaderMode.semanticContentAttribute = .forceLeftToRight
                self.lblReaderMode.textAlignment = .left
            }
        }
    }
    
    func setupLocalization() {
        
        lblTitle.text = NSLocalizedString("DATA SAVER", comment: "").capitalized
        lblAutoPlay.text = NSLocalizedString("Autoplay", comment: "")
        lblReaderMode.text = NSLocalizedString("Reader Mode", comment: "")

        btnAutoplayOff.setTitle(NSLocalizedString("Off", comment: ""), for: .normal)
        btnAutoplayOn.setTitle(NSLocalizedString("On", comment: ""), for: .normal)
        
        btnReaderModeOff.setTitle(NSLocalizedString("Off", comment: ""), for: .normal)
        btnReaderModeOn.setTitle(NSLocalizedString("On", comment: ""), for: .normal)
    }
    
    func setAutoPlay(sender: UIButton) {
        
        if sender.tag == 0 {
            
            //Off AutoPlay
            self.btnAutoplayOff.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btnAutoplayOn.layer.backgroundColor = UIColor.clear.cgColor
            
            self.btnAutoplayOff.tintColor = UIColor.white
            self.btnAutoplayOn.tintColor = Constant.appColor.customGrey
            
            SharedManager.shared.videoAutoPlay = false
            self.switchAutoPlayState = false
        }
        else {
            
            //On AutoPlay
            self.btnAutoplayOff.layer.backgroundColor = UIColor.clear.cgColor
            self.btnAutoplayOn.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG

            self.btnAutoplayOff.tintColor = Constant.appColor.customGrey
            self.btnAutoplayOn.tintColor = UIColor.white
            
            SharedManager.shared.videoAutoPlay = true
            self.switchAutoPlayState = true
        }
        self.performWSToUpdateConfigView()
    }
    
    func setRenderMode(sender: UIButton) {
        
        if sender.tag == 0 {
            
            //Off ReaderMode
            self.btnReaderModeOff.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btnReaderModeOn.layer.backgroundColor = UIColor.clear.cgColor
            
            self.btnReaderModeOff.tintColor = UIColor.white
            self.btnReaderModeOn.tintColor = Constant.appColor.customGrey
            
            SharedManager.shared.readerMode = false
            self.switchReaderModeState = false
        }
        else {
            
            //On ReaderMode
            self.btnReaderModeOff.layer.backgroundColor = UIColor.clear.cgColor
            self.btnReaderModeOn.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG

            self.btnReaderModeOff.tintColor = Constant.appColor.customGrey
            self.btnReaderModeOn.tintColor = UIColor.white
            
            SharedManager.shared.readerMode = true
            self.switchReaderModeState = true
        }
        self.performWSToUpdateConfigView()
    }
    
    //MARK:- Button Action
    @IBAction func didTapAutoPlay(_ sender: UIButton) {
        
        if sender.tag == 0 {
            setAutoPlay(sender: btnAutoplayOff)
        }
        else {
            setAutoPlay(sender: btnAutoplayOn)
        }
    }
    
    @IBAction func didTapReaderMode(_ sender: UIButton) {
        
        if sender.tag == 0 {
            setRenderMode(sender: btnReaderModeOff)
        }
        else {
            setRenderMode(sender: btnReaderModeOn)
        }
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
    
        if lastStatusReaderMode != SharedManager.shared.readerMode {
            SharedManager.shared.isTabReload = true
            SharedManager.shared.isDiscoverTabReload = true
            DataCache.instance.cleanAll()
        }
        self.dismiss(animated: true, completion: nil)
    }
        
    func performWSToUpdateConfigView() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        let params = [
            "reader_mode": SharedManager.shared.readerMode,
            "bullets_autoplay": SharedManager.shared.bulletsAutoPlay,
            "reels_autoplay": SharedManager.shared.reelsAutoPlay,
            "videos_autoplay": SharedManager.shared.videoAutoPlay
        ]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config/view", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userConfigViewDC.self, from: response)
                
                if let _ = FULLResponse.message {
                
                    print("Success")
                    
                }
                ANLoader.hide()
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "user/config/view", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            //SharedManager.shared.showAPIFailureAlert()
            print("error parsing json objects",error)
        }
    }
}
