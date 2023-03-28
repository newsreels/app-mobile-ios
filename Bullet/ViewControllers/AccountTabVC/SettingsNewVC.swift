//
//  SettingsNewVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 30/11/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SwiftTheme
import Toast_Swift

protocol SettingsNewVCDelegate: AnyObject {
    
    func didTapRefreshOnBackButton()
}

class SettingsNewVC: UIViewController, EditionVCDelegate {

    @IBOutlet var viewCollectionSwitch: [UIView]!
    
    @IBOutlet weak var lblAppVersion: UILabel!
    @IBOutlet weak var lblTheme: UILabel!
    @IBOutlet weak var lblHaptic: UILabel!
   // @IBOutlet weak var lblSignOut: UILabel!
    
    @IBOutlet weak var btnDark: UIButton!
    @IBOutlet weak var btnLight: UIButton!
    @IBOutlet weak var btnAuto: UIButton!
    @IBOutlet weak var btnOnHaptic: UIButton!
    @IBOutlet weak var btnOffHaptic: UIButton!
    
    @IBOutlet weak var viewBorderLine1: UIView!
    @IBOutlet weak var viewBorderLine2: UIView!
    @IBOutlet weak var viewAuto: UIView!
    @IBOutlet weak var viewAccont: UIView!
    
    @IBOutlet weak var constraintThemeButtonWidth: NSLayoutConstraint!
    
  //  @IBOutlet weak var btnSignOut: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var imgLanguage: UIImageView!
    
    @IBOutlet var lblCollection: [UILabel]!
    @IBOutlet var lblHeadingsCollection: [UILabel]!
    
    @IBOutlet weak var lblEdtions: UILabel!
    @IBOutlet weak var imgEditionFlag1: UIImageView!
    @IBOutlet weak var imgEditionFlag2: UIImageView!
    @IBOutlet weak var imgEditionFlag3: UIImageView!
    @IBOutlet weak var lblAccountHeading: UILabel!
    @IBOutlet weak var lblMyAccount: UILabel!
    @IBOutlet weak var lblPostArticle: UILabel!
    @IBOutlet weak var lblBlockList: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var lblNotificationHeadet: UILabel!
    @IBOutlet weak var lblPush: UILabel!
    @IBOutlet weak var lblPersonalization: UILabel!
    @IBOutlet weak var lblAudioSettings: UILabel!
    @IBOutlet weak var lblOthers: UILabel!
    @IBOutlet weak var lblFeedback: UILabel!
    @IBOutlet weak var lblHelp: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblLegal: UILabel!
    @IBOutlet weak var lblLogOut: UILabel!
    
    @IBOutlet var imageArrowRightGroup: [UIImageView]!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    weak var delegate: SettingsNewVCDelegate?
 
    var settingsArray: [String]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupLocalization()
        viewCollectionSwitch.forEach {
            $0.theme_backgroundColor = GlobalPicker.switchBGColor
        }

        setSettingsArrowImage()
        
        let hasPassword = UserDefaults.standard.bool(forKey: Constant.UD_isSocialLinked)
        if hasPassword {
            
            self.viewAccont.isHidden = false
        }
        else {
        
            self.viewAccont.isHidden = true
        }
        
       // cell.lblItem.addTextSpacing(spacing: 1.45)
        setHapticUI()
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        imgBack.theme_image = GlobalPicker.imgBack

        //SignOut
        lblTitle.theme_textColor = GlobalPicker.textColor
     
        //version label
        lblAppVersion.theme_textColor = GlobalPicker.textSubColor
        lblAppVersion.text = "\(NSLocalizedString("App version", comment: "")) \(Bundle.main.releaseVersionNumber ?? "1.0").\(Bundle.main.buildVersionNumber ?? "1.0")"

        //theme button
        lblTheme.theme_textColor = GlobalPicker.textColor
        lblTheme.addTextSpacing(spacing: 1.45)
        lblHaptic.theme_textColor = GlobalPicker.textColor
        lblHaptic.addTextSpacing(spacing: 1.45)
        
        btnAuto.layer.cornerRadius = btnAuto.frame.height / 2
        btnLight.layer.cornerRadius = btnDark.frame.height / 2
        btnDark.layer.cornerRadius = btnDark.frame.height / 2
        btnOnHaptic.layer.cornerRadius = btnDark.frame.height / 2
        btnOffHaptic.layer.cornerRadius = btnDark.frame.height / 2
        imgLanguage.layer.cornerRadius = imgLanguage.frame.height / 2
        imgEditionFlag1.cornerRadius = self.imgEditionFlag1.frame.size.width / 2
        imgEditionFlag2.cornerRadius = self.imgEditionFlag2.frame.size.width / 2
        imgEditionFlag3.cornerRadius = self.imgEditionFlag3.frame.size.width / 2
        
        btnOnHaptic.titleLabel?.adjustsFontSizeToFitWidth = true
        btnOffHaptic.titleLabel?.adjustsFontSizeToFitWidth = true
        
        if #available(iOS 13.0, *) {
            constraintThemeButtonWidth.constant = 165
            
            let selectedThemeType = UserDefaults.standard.bool(forKey: Constant.UD_isLocalTheme)
            if selectedThemeType == false {
                
                self.btnAuto.layer.backgroundColor = MyThemes.current == .dark ? Constant.appColor.purple.cgColor : Constant.appColor.blue.cgColor
                self.btnDark.layer.backgroundColor = UIColor.clear.cgColor
                self.btnLight.layer.backgroundColor = UIColor.clear.cgColor
                self.btnAuto.tintColor = UIColor.white
                self.btnDark.tintColor = Constant.appColor.customGrey
                self.btnLight.tintColor = Constant.appColor.customGrey
                
                viewBorderLine1.isHidden = true
                viewBorderLine2.isHidden = false
            }
            else {
                
                //didTapThemeColour(MyThemes.current == .dark ? btnDark : btnLight)
                setThemeSelection(sender: MyThemes.current == .dark ? btnDark : btnLight)
            }
        }
        else {
            constraintThemeButtonWidth.constant = 110
            self.viewAuto.isHidden = true
            //didTapThemeColour(MyThemes.current == .dark ? btnDark : btnLight)
            setThemeSelection(sender: MyThemes.current == .dark ? btnDark : btnLight)
        }
        
        self.lblCollection.forEach {
            $0.theme_textColor = GlobalPicker.textColor
            $0.addTextSpacing(spacing: 1.45)
        }
        
        if let code = UserDefaults.standard.string(forKey: Constant.UD_languageFlag) {
        
            self.imgLanguage.sd_setImage(with: URL(string:code)) { (image, error, type, url) in
                if error != nil {
                    print("image loading error")
                } else {
                    print("image loaded")
                }
            }
            //sd_setImage(with: URL(string:code), completed: nil)
        }
        
        self.performWSToGetSelectedEdition()
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapNotifyProfileVC(_:)), name: Notification.Name.notifyProfileVC, object: nil)

    }
    
    
    func setHapticUI() {
        let isHapticOn = UserDefaults.standard.bool(forKey: Constant.UD_isHapticOn)
        if isHapticOn {
            
            self.setOnOffHaptic(sender: self.btnOnHaptic)
        }
        else {
        
            self.setOnOffHaptic(sender: self.btnOffHaptic)
        }
    }
    
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Account Settings", comment: "")
        lblAccountHeading.text = NSLocalizedString("ACCOUNT", comment: "")
        lblMyAccount.text  = NSLocalizedString("MY ACCOUNT", comment: "")
        lblPostArticle.text = NSLocalizedString("POST ARTICLE", comment: "")
        lblBlockList.text = NSLocalizedString("BLOCK LIST", comment: "")
        lblLanguage.text = NSLocalizedString("LANGUAGE", comment: "")
        lblEdtions.text = NSLocalizedString("EDITION / REGION", comment: "")
        lblNotificationHeadet.text = NSLocalizedString("NOTIFICATIONS", comment: "")
        lblPush.text = NSLocalizedString("PUSH NOTIFICATIONS", comment: "")
        lblPersonalization.text = NSLocalizedString("PERSONALIZATION", comment: "")
        lblTheme.text = NSLocalizedString("COLOR THEME", comment: "")
        btnAuto.setTitle(NSLocalizedString("Auto", comment: ""), for: .normal)
        btnLight.setTitle(NSLocalizedString("Light", comment: ""), for: .normal)
        btnDark.setTitle(NSLocalizedString("Dark", comment: ""), for: .normal)
        lblHaptic.text = NSLocalizedString("HAPTICS", comment: "")
        btnOffHaptic.setTitle(NSLocalizedString("Off", comment: ""), for: .normal)
        btnOnHaptic.setTitle(NSLocalizedString("On", comment: ""), for: .normal)
        lblAudioSettings.text = NSLocalizedString("AUDIO SETTINGS", comment: "")
        lblOthers.text = NSLocalizedString("OTHERS", comment: "")
        lblFeedback.text = NSLocalizedString("FEEDBACK", comment: "")
        lblHelp.text = NSLocalizedString("HELP / CONTACT US", comment: "")
        lblAbout.text = NSLocalizedString("ABOUT", comment: "")
        lblLegal.text = NSLocalizedString("LEGAL", comment: "")
        lblLogOut.text = NSLocalizedString("LOG OUT", comment: "")
    }
    
    func setSettingsArrowImage() {
        imageArrowRightGroup.forEach { (imageView) in
            imageView.image = UIImage(named: MyThemes.current == .dark ? "tbFroword" : "tbFrowordLight")
        }
    }
    
    @objc func didTapNotifyProfileVC(_ notification: NSNotification) {
        
        self.didTapBackButton(self)
      
    }
    
    func didTapRefressSettings() {
        
        self.performWSToGetSelectedEdition()
    }
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapSignOut(_ sender: Any) {
   
        self .performWSTologoutUser()
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
    
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyProfileVC, object: nil)
        self.delegate?.didTapRefreshOnBackButton()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapThemeColour(_ sender: UIButton) {
     
        setThemeSelection(sender: sender)
    }
    
    @IBAction func didTapOnOffHaptic(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            setOnOffHaptic(sender: btnOffHaptic)
        }
        else {
            
            setOnOffHaptic(sender: btnOnHaptic)
        }
    }
    
    func setOnOffHaptic(sender: UIButton) {
        
        if sender.tag == 0 {
            
            //Off Haptic
            self.btnOffHaptic.layer.backgroundColor = MyThemes.current == .dark ? Constant.appColor.purple.cgColor : Constant.appColor.blue.cgColor
            self.btnOnHaptic.layer.backgroundColor = UIColor.clear.cgColor
            
            self.btnOffHaptic.tintColor = UIColor.white
            self.btnOnHaptic.tintColor = Constant.appColor.customGrey
            
            UserDefaults.standard.set(false, forKey: Constant.UD_isHapticOn)
        }
        else {
            
            //On Haptic
            self.btnOffHaptic.layer.backgroundColor = UIColor.clear.cgColor
            self.btnOnHaptic.layer.backgroundColor = MyThemes.current == .dark ? Constant.appColor.purple.cgColor : Constant.appColor.blue.cgColor

            self.btnOffHaptic.tintColor = Constant.appColor.customGrey
            self.btnOnHaptic.tintColor = UIColor.white
            
            UserDefaults.standard.set(true, forKey: Constant.UD_isHapticOn)
        }
    }
    
    func setThemeSelection(sender: UIButton) {
        
        if sender.tag == 0 {
            
            //Auto
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.autoMode, eventDescription: "")
            self.btnDark.layer.backgroundColor = UIColor.clear.cgColor
            self.btnLight.layer.backgroundColor = UIColor.clear.cgColor
            self.btnAuto.tintColor = UIColor.white
            self.btnDark.tintColor = Constant.appColor.customGrey
            self.btnLight.tintColor = Constant.appColor.customGrey
            
            viewBorderLine1.isHidden = true
            viewBorderLine2.isHidden = false
            
            SharedManager.shared.setThemeAutomatic()
            
            self.btnAuto.layer.backgroundColor = MyThemes.current == .dark ? Constant.appColor.purple.cgColor : Constant.appColor.blue.cgColor
            
        }
        else if sender.tag == 1 {
            
            //Light
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.lightMode, eventDescription: "")
            self.btnAuto.layer.backgroundColor = UIColor.clear.cgColor
            self.btnDark.layer.backgroundColor = UIColor.clear.cgColor
            self.btnAuto.tintColor = Constant.appColor.customGrey
            self.btnDark.tintColor = Constant.appColor.customGrey
            self.btnLight.tintColor = UIColor.white
            
            viewBorderLine1.isHidden = true
            viewBorderLine2.isHidden = true
            
            MyThemes.switchTo(theme: .light)
            UserDefaults.standard.set(true, forKey: Constant.UD_isLocalTheme)
            UserDefaults.standard.set(false, forKey: "dark")
            
            self.btnLight.layer.backgroundColor = MyThemes.current == .dark ? Constant.appColor.purple.cgColor : Constant.appColor.blue.cgColor
        }
        else {
            
            //Dark
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.darkMode, eventDescription: "")
            self.btnAuto.layer.backgroundColor = UIColor.clear.cgColor
            self.btnLight.layer.backgroundColor = UIColor.clear.cgColor
            self.btnAuto.tintColor = Constant.appColor.customGrey
            self.btnDark.tintColor = UIColor.white
            self.btnLight.tintColor = Constant.appColor.customGrey
            
            viewBorderLine1.isHidden = false
            viewBorderLine2.isHidden = true
            
            MyThemes.switchTo(theme: .dark)
            UserDefaults.standard.set(true, forKey: Constant.UD_isLocalTheme)
            UserDefaults.standard.set(true, forKey: "dark")
            
            self.btnDark.layer.backgroundColor = MyThemes.current == .dark ? Constant.appColor.purple.cgColor : Constant.appColor.blue.cgColor
        }
        MyThemes.saveLastTheme()
        
        var style = ToastStyle()
        style.backgroundColor = MyThemes.current == .dark ? UIColor.white.withAlphaComponent(0.8) : UIColor.black.withAlphaComponent(0.8)
        style.messageColor = MyThemes.current == .dark ? "#3D485F".hexStringToUIColor(): "#FFFFFF".hexStringToUIColor()
        ToastManager.shared.style = style
        
        setSettingsArrowImage()
        setHapticUI()
    }
    
    
    @IBAction func didTapSettings(_ sender: UIButton) {
        
        if sender.tag == 1 {
            
            let vc = MyAccountVC.instantiate(fromAppStoryboard: .Main)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
           // self.navigationController?.present(vc, animated: true, completion: nil)
        }
        else if sender.tag == 2 {
            
//            SharedManager.shared.isSavedArticle = true
//            SharedManager.shared.isShowTopic = true
            let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
            vc.showArticleType = .savedArticle
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
        else if sender.tag == 3 {
            
            let vc = blockListVC.instantiate(fromAppStoryboard: .registration)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
          //  self.navigationController?.present(vc, animated: true, completion: nil)
        }
        else if sender.tag == 4 {
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.pushClicks, eventDescription: "")
            let vc = NotificationVC.instantiate(fromAppStoryboard: .Main)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            //self.navigationController?.present(vc, animated: true, completion: nil)
        }
        else if sender.tag == 5 {
            
            let vc = contactUsVC.instantiate(fromAppStoryboard: .registration)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        //    self.navigationController?.present(vc, animated: true, completion: nil)
            
        }
        else if sender.tag == 6 {
          
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.aboutClick, eventDescription: "")
            let vc = AboutVC.instantiate(fromAppStoryboard: .registration)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
          //  self.navigationController?.present(vc, animated: true, completion: nil)
            
        }
        else if sender.tag == 7 {
            
            let vc = legalVC.instantiate(fromAppStoryboard: .registration)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
           // self.navigationController?.present(vc, animated: true, completion: nil)
        }
//        else if sender.tag == 8 {
//
//            let vc = PostArticleVC.instantiate(fromAppStoryboard: .registration)
//            vc.modalPresentationStyle = .overFullScreen
//            self.present(vc, animated: true, completion: nil)
//          //  self.navigationController?.present(vc, animated: true, completion: nil)
//        }
        else if sender.tag == 9 {
            
            let vc = SuggestionVC.instantiate(fromAppStoryboard: .registration)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
          //  self.navigationController?.present(vc, animated: true, completion: nil)
        }
        else if sender.tag == 10 {
    
            self .performWSTologoutUser()
        }
        else if sender.tag == 11 {
        
            //Language
            let vc = LanguageVC.instantiate(fromAppStoryboard: .Main)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
         //   self.navigationController?.present(vc, animated: true, completion: nil)
        }
        else if sender.tag == 12 {
        
            //Editions
            let vc = EditionVC.instantiate(fromAppStoryboard: .registration)
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
          //  self.navigationController?.present(vc, animated: true, completion: nil)
        }
        
        else if sender.tag == 13 {
        
            let vc = AudioSettingsVC.instantiate(fromAppStoryboard: .registration)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
}

//====================================================================================================
// MARK:- logout user webservice Respones
//====================================================================================================
extension SettingsNewVC {
    
    func performWSTologoutUser() {
    
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
        let refreshToken = UserDefaults.standard.value(forKey: Constant.UD_refreshToken) ?? ""
        let params = ["token": refreshToken]
        
        WebService.URLResponseAuth("auth/logout", method: .post, parameters: params, headers: userToken as? String, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
        
                if FULLResponse.message?.lowercased() == "success" {
                    
                    self.appDelegate.logout()
                }
                else {
                    
                    ANLoader.hide()
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "auth/logout", error: jsonerror.localizedDescription, code: "")
            }
            
        }){ (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

extension SettingsNewVC {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let selectedThemeType = UserDefaults.standard.bool(forKey: Constant.UD_isLocalTheme)
        
        if selectedThemeType == false {
            
            if #available(iOS 13.0, *) {
                if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                    if traitCollection.userInterfaceStyle == .dark {
                        
                        //Dark
                        MyThemes.switchTo(theme: .dark)
                    }
                    else {
                        //Light
                        MyThemes.switchTo(theme: .light)
                    }
                    
                }
            }
            MyThemes.saveLastTheme()
        }
    }
    
    func performWSViewArticle(_ id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
                
        ANLoader.showLoading(disableUI: true)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/articles/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(viewArticleDC.self, from: response)
                
                if let article = FULLResponse.article {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {

//                        SharedManager.shared.isShowTopic = false
//                        SharedManager.shared.isShowSource = false
//                        SharedManager.shared.isViewArticleSourceNotification = false
//                        SharedManager.shared.isSavedArticle = false
                        SharedManager.shared.viewArticleArray = [article]
                        
                        if let source = article.source {
                            
                            SharedManager.shared.subSourcesTitle = source.name ?? ""
                            SharedManager.shared.subSourcesList = [source]
                            
                            DispatchQueue.main.async {
                                
                                let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
                                vc.showArticleType = .home
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    })
                }

            } catch let jsonerror {
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/articles/\(id)", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

extension SettingsNewVC {
    
    func performWSToGetSelectedEdition() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/editions/followed", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(EditionsSelectedDC.self, from: response)
                
                if let editions = FULLResponse.editions {
                    
                    if editions.count == 1 {
                        
                        self.imgEditionFlag1.sd_setImage(with: URL(string: editions[0].image ?? ""), completed: nil)
                        
                        self.imgEditionFlag1.isHidden = false
                        self.imgEditionFlag2.isHidden = true
                        self.imgEditionFlag3.isHidden = true
                    }
                    else if editions.count == 2 {
                        
                        self.imgEditionFlag1.sd_setImage(with: URL(string: editions[0].image ?? ""), completed: nil)
                        self.imgEditionFlag2.sd_setImage(with: URL(string: editions[1].image ?? ""), completed: nil)
                        self.imgEditionFlag1.isHidden = false
                        self.imgEditionFlag2.isHidden = false
                        self.imgEditionFlag3.isHidden = true
                    }
                    else if editions.count >= 3 {
                        
                        self.imgEditionFlag1.sd_setImage(with: URL(string: editions[0].image ?? ""), completed: nil)
                        self.imgEditionFlag2.sd_setImage(with: URL(string: editions[1].image ?? ""), completed: nil)
                        self.imgEditionFlag3.sd_setImage(with: URL(string: editions[2].image ?? ""), completed: nil)
                        self.imgEditionFlag1.isHidden = false
                        self.imgEditionFlag2.isHidden = false
                        self.imgEditionFlag3.isHidden = false
                    }

                    self.lblEdtions.text = NSLocalizedString("EDITION / REGION", comment: "")
                }
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/editions/followed", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
}
