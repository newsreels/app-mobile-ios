//
//  PersonalizationVC.swift
//  Bullet
//
//  Created by Mahesh on 07/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Toast_Swift
import SwiftTheme

class PersonalizationVC: UIViewController {
    
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var lblCollection: [UILabel]!
    @IBOutlet var viewCollectionSwitch: [UIView]!
    @IBOutlet weak var lblTheme: UILabel!
    @IBOutlet weak var lblHaptic: UILabel!
    @IBOutlet weak var lblAudioSettings: UILabel!

    @IBOutlet weak var btnDark: UIButton!
    @IBOutlet weak var btnLight: UIButton!
    @IBOutlet weak var btnAuto: UIButton!
    @IBOutlet weak var btnOnHaptic: UIButton!
    @IBOutlet weak var btnOffHaptic: UIButton!

    @IBOutlet weak var viewBorderLine1: UIView!
    @IBOutlet weak var viewBorderLine2: UIView!
    @IBOutlet weak var viewAuto: UIView!

    @IBOutlet var imageArrowRightGroup: [UIImageView]!
    @IBOutlet weak var constraintThemeButtonWidth: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()
        viewCollectionSwitch.forEach {
            $0.theme_backgroundColor = GlobalPicker.switchBGColor
        }

        setSettingsArrowImage()
        setHapticUI()
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        //SignOut
        lblTitle.theme_textColor = GlobalPicker.textColor
        imgBack.theme_image = GlobalPicker.imgBack
        
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
    }
    
    func setupLocalization() {
        
        lblTitle.text = NSLocalizedString("Personalization", comment: "")
        lblTheme.text = NSLocalizedString("Color Theme", comment: "")
        lblHaptic.text = NSLocalizedString("Haptics", comment: "")
        lblAudioSettings.text = NSLocalizedString("Audio Settings", comment: "")
        btnAuto.setTitle(NSLocalizedString("Auto", comment: ""), for: .normal)
        btnLight.setTitle(NSLocalizedString("Light", comment: ""), for: .normal)
        btnDark.setTitle(NSLocalizedString("Dark", comment: ""), for: .normal)
        btnOffHaptic.setTitle(NSLocalizedString("Off", comment: ""), for: .normal)
        btnOnHaptic.setTitle(NSLocalizedString("On", comment: ""), for: .normal)

    }
    
    func setSettingsArrowImage() {
        imageArrowRightGroup.forEach { (imageView) in
            imageView.image = UIImage(named: MyThemes.current == .dark ? "tbFroword" : "tbFrowordLight")
        }
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

    //MARK:- BUTTON ACTION
    @IBAction func didTapBackButton(_ sender: Any) {
    
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapAudioSettings(_ sender: UIButton) {
        
        let vc = AudioSettingsVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
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
    
}
