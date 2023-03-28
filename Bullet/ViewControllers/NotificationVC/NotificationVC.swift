//
//  NotificationVC.swift
//  Bullet
//
//  Created by Mahesh on 06/07/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController {

    @IBOutlet var viewCollectionColorBG: [UIView]!
    
    @IBOutlet weak var lblNews: UILabel!
    @IBOutlet weak var lblPersonalized: UILabel!
    @IBOutlet weak var btnOnNews: UIButton!
    @IBOutlet weak var btnOffNews: UIButton!
    @IBOutlet weak var btnOnPersonalized: UIButton!
    @IBOutlet weak var btnOffPersonalized: UIButton!
    @IBOutlet var btnCollection: [UIButton]!
    @IBOutlet weak var lblTitle: UILabel!
//    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var btn30m: UIButton!
    @IBOutlet weak var btn1h: UIButton!
    @IBOutlet weak var btn3h: UIButton!
    @IBOutlet weak var btn6h: UIButton!
    @IBOutlet weak var btn12h: UIButton!
    @IBOutlet weak var btn24h: UIButton!
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblContentTitle: UILabel!
    @IBOutlet weak var lblIntervalInfo: UILabel!
    
    @IBOutlet weak var navView: UIView!
    var switchNewsState = false
    var switchPersonalizedState = false
    var frequency = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()
        
        //Design View
        self.view.backgroundColor = .white
        //theme_backgroundColor = GlobalPicker.backgroundColor
        viewCollectionColorBG.forEach {
            $0.theme_backgroundColor = GlobalPicker.switchBGColor
        }

        lblNews.theme_textColor = GlobalPicker.textColor
        lblNews.addTextSpacing(spacing: 2.25)
        lblNews.setLineSpacing(lineSpacing: 5)

        lblPersonalized.theme_textColor = GlobalPicker.textColor
        lblPersonalized.addTextSpacing(spacing: 2.25)
        lblPersonalized.setLineSpacing(lineSpacing: 5)
        
        lblTime.theme_textColor = GlobalPicker.textColor
        lblTime.addTextSpacing(spacing: 2.25)
        
        lblTitle.theme_textColor = GlobalPicker.textColor
//        imgBack.theme_image = GlobalPicker.imgBack

        for btn in btnCollection {
            btn.layer.cornerRadius = btn.frame.height / 2
        }

        callNotificationStatus()
//        setOnOffNews(sender: btnOffNews)
//        setOnOffPersonalized(sender: btnOffPersonalized)
        
        self.btnOffNews.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
        self.btnOnNews.layer.backgroundColor = UIColor.clear.cgColor
        
        self.btnOffNews.tintColor = UIColor.white
        self.btnOnNews.tintColor = Constant.appColor.customGrey
        
        self.btnOffPersonalized.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
        self.btnOnPersonalized.layer.backgroundColor = UIColor.clear.cgColor
        
        self.btnOffPersonalized.tintColor = UIColor.white
        self.btnOnPersonalized.tintColor = Constant.appColor.customGrey
        
        btn30m.layer.cornerRadius = btn30m.frame.height / 2
        btn3h.layer.cornerRadius = btn3h.frame.height / 2
        btn1h.layer.cornerRadius = btn1h.frame.height / 2
        btn6h.layer.cornerRadius = btn6h.frame.height / 2
        btn12h.layer.cornerRadius = btn12h.frame.height / 2
        btn24h.layer.cornerRadius = btn24h.frame.height / 2
        
        self.btn30m.tintColor = Constant.appColor.customGrey
        self.btn30m.layer.backgroundColor = UIColor.clear.cgColor
        self.btn1h.tintColor = Constant.appColor.customGrey
        self.btn1h.layer.backgroundColor = UIColor.clear.cgColor
        self.btn3h.tintColor = Constant.appColor.customGrey
        self.btn3h.layer.backgroundColor = UIColor.clear.cgColor
        self.btn6h.tintColor = Constant.appColor.customGrey
        self.btn6h.layer.backgroundColor = UIColor.clear.cgColor
        self.btn12h.tintColor = Constant.appColor.customGrey
        self.btn12h.layer.backgroundColor = UIColor.clear.cgColor
        self.btn24h.tintColor = Constant.appColor.customGrey
        self.btn24h.layer.backgroundColor = UIColor.clear.cgColor
        
        self.btnOffPersonalized.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnOnPersonalized.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnOffNews.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnOnNews.titleLabel?.adjustsFontSizeToFitWidth = true
      
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func setupLocalization() {
        
        lblTitle.text = NSLocalizedString("Notification settings", comment: "")//.capitalized
        lblContentTitle.text = NSLocalizedString("Push Notifications", comment: "")
        lblNews.text = NSLocalizedString("Breaking News", comment: "")
        
        lblPersonalized.text = NSLocalizedString("Personalized Recommendations", comment: "")
        lblTime.text = NSLocalizedString("Timed Notifications", comment: "")
        lblIntervalInfo.text = NSLocalizedString("Set an interval in which you want to receive your news notifications.", comment: "")
        btn30m.setTitle(NSLocalizedString("30m", comment: ""), for: .normal)
        btn1h.setTitle(NSLocalizedString("1h", comment: ""), for: .normal)
        btn3h.setTitle(NSLocalizedString("3h", comment: ""), for: .normal)
        btn6h.setTitle(NSLocalizedString("6h", comment: ""), for: .normal)
        btn12h.setTitle(NSLocalizedString("12h", comment: ""), for: .normal)
        btn24h.setTitle(NSLocalizedString("24h", comment: ""), for: .normal)
        
        
        btnOffNews.setTitle(NSLocalizedString("Off", comment: ""), for: .normal)
        btnOnNews.setTitle(NSLocalizedString("On", comment: ""), for: .normal)
        
        btnOffPersonalized.setTitle(NSLocalizedString("Off", comment: ""), for: .normal)
        btnOnPersonalized.setTitle(NSLocalizedString("On", comment: ""), for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblNews.semanticContentAttribute = .forceRightToLeft
                self.lblNews.textAlignment = .right
                self.lblPersonalized.semanticContentAttribute = .forceRightToLeft
                self.lblPersonalized.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblNews.semanticContentAttribute = .forceLeftToRight
                self.lblNews.textAlignment = .left
                self.lblPersonalized.semanticContentAttribute = .forceLeftToRight
                self.lblPersonalized.textAlignment = .left
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func applicationDidBecomeActive() {
        print("applicationDidBecomeActive")
        callNotificationStatus()
    }
    
    func callNotificationStatus() {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //print("Notification settings: \(settings)")
            switch settings.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    self.performWSToGetNotificationConfig()
                }
                break

            case .denied, .notDetermined:
                DispatchQueue.main.async {
                    self.setOnOffNotification(breaking: false, personalized: false)
                }
                break
            default:
                break
            }

        }
    }
    
    //MARK:- Button Action
    @IBAction func didTapOnOffNews(_ sender: UIButton) {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //print("Notification settings: \(settings)")
            switch settings.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    if sender.tag == 0 {
                        self.setOnOffNews(sender: self.btnOffNews)
                    }
                    else {
                        self.setOnOffNews(sender: self.btnOnNews)
                    }
                }
                
            case .denied:
                DispatchQueue.main.async {
                    self.showNotificationPermissionDialog()
                }
                break
                
            case .notDetermined: break
                
            default:
                break
            }
        }
    }
    
    @IBAction func didTapOnOffPersonalized(_ sender: UIButton) {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //print("Notification settings: \(settings)")
            switch settings.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    if sender.tag == 0 {
                        self.setOnOffPersonalized(sender: self.btnOffPersonalized)
                    }
                    else {
                        self.setOnOffPersonalized(sender: self.btnOnPersonalized)
                    }
                }
                
            case .denied:
                DispatchQueue.main.async {
                    self.showNotificationPermissionDialog()
                }
                break
                
            case .notDetermined: break
                
            default:
                break
            }
        }
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func setOnOffNews(sender: UIButton) {
        
        if sender.tag == 0 {
            
            //Off news
            self.btnOffNews.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btnOnNews.layer.backgroundColor = UIColor.clear.cgColor
            
            self.btnOffNews.tintColor = UIColor.white
            self.btnOnNews.tintColor = Constant.appColor.customGrey
            
            self.switchNewsState = false
            
        }
        else {
            
            //On News
            self.btnOffNews.layer.backgroundColor = UIColor.clear.cgColor
            self.btnOnNews.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG

            self.btnOffNews.tintColor = Constant.appColor.customGrey
            self.btnOnNews.tintColor = UIColor.white
            
            self.switchNewsState = true
            
        }
        
        self .performWSToUpdateNotificationConfig()
    }
    
    func setOnOffPersonalized(sender: UIButton) {
        
        if sender.tag == 0 {
            
            //Off Personalized
            self.btnOffPersonalized.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btnOnPersonalized.layer.backgroundColor = UIColor.clear.cgColor
            
            self.btnOffPersonalized.tintColor = UIColor.white
            self.btnOnPersonalized.tintColor = Constant.appColor.customGrey
            
             self.switchPersonalizedState = false
        }
        else {
            
            //On Personalized
            self.btnOffPersonalized.layer.backgroundColor = UIColor.clear.cgColor
            self.btnOnPersonalized.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG

            self.btnOffPersonalized.tintColor = Constant.appColor.customGrey
            self.btnOnPersonalized.tintColor = UIColor.white
            
             self.switchPersonalizedState = true
        }
        
        self .performWSToUpdateNotificationConfig()
    }
}

//MARK: - Web APIs for Notification configurations
extension NotificationVC {

    private func showNotificationPermissionDialog() {
        
        let settingsButton = NSLocalizedString("Settings", comment: "")
        let cancelButton = NSLocalizedString("Cancel", comment: "")
        let message = NSLocalizedString("Your need to give a permission from notification settings.", comment: "")
        let goToSettingsAlert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)

        goToSettingsAlert.addAction(UIAlertAction(title: settingsButton, style: .destructive, handler: { (action: UIAlertAction) in
            DispatchQueue.main.async {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    } else {
                        UIApplication.shared.openURL(settingsUrl as URL)
                    }
                }
            }
        }))

        goToSettingsAlert.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: nil))
        self.present(goToSettingsAlert, animated: true)
    }
    
    
    func setOnOffNotification(breaking: Bool, personalized: Bool) {
        
        if breaking {
            
            //On News
            self.btnOffNews.layer.backgroundColor = UIColor.clear.cgColor
            self.btnOnNews.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG

            self.btnOffNews.tintColor = Constant.appColor.customGrey
            self.btnOnNews.tintColor = UIColor.white
            
            self.switchNewsState = true
        }
        else {
            
            //Off news
            self.btnOffNews.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btnOnNews.layer.backgroundColor = UIColor.clear.cgColor
            
            self.btnOffNews.tintColor = UIColor.white
            self.btnOnNews.tintColor = Constant.appColor.customGrey
            
            self.switchNewsState = false

        }
        
        if personalized {
            
            //On Personalized
            self.btnOffPersonalized.layer.backgroundColor = UIColor.clear.cgColor
            self.btnOnPersonalized.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG

            self.btnOffPersonalized.tintColor = Constant.appColor.customGrey
            self.btnOnPersonalized.tintColor = UIColor.white
            
            self.switchPersonalizedState = true
        }
        else {
            
            //Off Personalized
            self.btnOffPersonalized.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btnOnPersonalized.layer.backgroundColor = UIColor.clear.cgColor
            
            self.btnOffPersonalized.tintColor = UIColor.white
            self.btnOnPersonalized.tintColor = Constant.appColor.customGrey
            
             self.switchPersonalizedState = false
        }

    }

    
    func performWSToGetNotificationConfig() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
//        ANLoader.showLoading(disableUI: false)
        self.showLoaderInVC(userInteractionEnabled: true)
        DispatchQueue.main.async {
            self.view.bringSubviewToFront(self.navView)
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config/push", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.hideLoaderVC()
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(NotificationConfigDC.self, from: response)
                
                if let NotificationConfig = FULLResponse.push {
                    
                    let breaking = NotificationConfig.breaking ?? false
                    let personalized = NotificationConfig.personalized ?? false
                    self.setOnOffNotification(breaking: breaking, personalized: personalized)
                    
                    if NotificationConfig.frequency == "30m" {
                        
                        self.btn30m.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
                        self.btn30m.tintColor = UIColor.white
                    }
                    else if NotificationConfig.frequency == "1h" {
                        
                        self.btn1h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
                        self.btn1h.tintColor = UIColor.white
                    }
                    else if NotificationConfig.frequency == "3h" {
                        
                        self.btn3h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
                        self.btn3h.tintColor = UIColor.white
                    }
                    else if NotificationConfig.frequency == "6h" {
                        
                        self.btn6h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
                        self.btn6h.tintColor = UIColor.white
                    }
                    else if NotificationConfig.frequency == "12h" {
                        
                        self.btn12h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
                        self.btn12h.tintColor = UIColor.white
                    }
                    else if NotificationConfig.frequency == "24h" {
                        
                        self.btn24h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
                        self.btn24h.tintColor = UIColor.white
                    }
                    self.frequency = NotificationConfig.frequency ?? "1h"
                }
                
            } catch let jsonerror {
                self.hideLoaderVC()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config/push", error: jsonerror.localizedDescription, code: "")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                
                self.hideLoaderVC()
//                ANLoader.hide()
            }
            
        }) { (error) in
            
            self.hideLoaderVC()
//            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    // Webservice for update Notifiocation configuration
    func performWSToUpdateNotificationConfig() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
//        ANLoader.showLoading(disableUI: false)
        self.showLoaderInVC(userInteractionEnabled: true)
        DispatchQueue.main.async {
            self.view.bringSubviewToFront(self.navView)
        }
        let params = ["breaking": switchNewsState, "personalized":switchPersonalizedState, "frequency":self.frequency] as [String : Any]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config/push", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            self.hideLoaderVC()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(UpdateNotificationConfig.self, from: response)
                
                if let message = FULLResponse.message {
                    
                    if message.lowercased() == "success" {
                        
                        self.performWSToGetNotificationConfig()
                    }
                }
                else {
                    
//                    ANLoader.hide()
                }
                
            } catch let jsonerror {
                self.hideLoaderVC()
//                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config/push", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            self.hideLoaderVC()
//            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

extension NotificationVC {
    
    @IBAction func didTapNotificationFrequency(_ sender: UIButton) {
        
        self.setNotificationFrequency(sender: sender)
    }
    
    func setNotificationFrequency(sender: UIButton) {
        
        self.btn30m.tintColor = Constant.appColor.customGrey
        self.btn30m.layer.backgroundColor = UIColor.clear.cgColor
        self.btn1h.tintColor = Constant.appColor.customGrey
        self.btn1h.layer.backgroundColor = UIColor.clear.cgColor
        self.btn3h.tintColor = Constant.appColor.customGrey
        self.btn3h.layer.backgroundColor = UIColor.clear.cgColor
        self.btn6h.tintColor = Constant.appColor.customGrey
        self.btn6h.layer.backgroundColor = UIColor.clear.cgColor
        self.btn12h.tintColor = Constant.appColor.customGrey
        self.btn12h.layer.backgroundColor = UIColor.clear.cgColor
        self.btn24h.tintColor = Constant.appColor.customGrey
        self.btn24h.layer.backgroundColor = UIColor.clear.cgColor
        
        if sender.tag == 0 {
            
            //30m
            self.btn30m.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btn30m.tintColor = UIColor.white
            self.frequency = "30m"
        
        }
        else if sender.tag == 1 {
            
            //1h
            self.btn1h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btn1h.tintColor = UIColor.white
            self.frequency = "1h"
        }
        else if sender.tag == 2 {
            
            //3h
            self.btn3h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btn3h.tintColor = UIColor.white
            self.frequency = "3h"
        }
        else if sender.tag == 3 {
            
            //6h
            self.btn6h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btn6h.tintColor = UIColor.white
            self.frequency = "6h"
        }
        else if sender.tag == 4 {
            
            //12h
            self.btn12h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btn12h.tintColor = UIColor.white
            self.frequency = "12h"
        }
        else {
            
            //24h
            self.btn24h.layer.theme_backgroundColor = GlobalPicker.themeCommonColorCG
            self.btn24h.tintColor = UIColor.white
            self.frequency = "24h"
           
        }
        
        self.performWSToUpdateNotificationConfig()
    }
}
