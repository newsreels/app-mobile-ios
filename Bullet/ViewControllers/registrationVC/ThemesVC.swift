
//
//  ThemesVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 10/06/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ThemesVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLight: UILabel!
    @IBOutlet weak var lblDark: UILabel!
    @IBOutlet weak var lblNativeSettings: UILabel!
    
    @IBOutlet weak var imgLightCheck: UIImageView!
    @IBOutlet weak var imgDarkCheck: UIImageView!
    @IBOutlet weak var imgNativeSettingsCheck: UIImageView!
    
    @IBOutlet weak var btnLight: UIButton!
    @IBOutlet weak var btnDark: UIButton!
    @IBOutlet weak var btnNativeSettings: UIButton!
    
    @IBOutlet weak var viewSystemSettings: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        lblLight.theme_textColor = GlobalPicker.textColor
        lblDark.theme_textColor = GlobalPicker.textColor
        lblNativeSettings.theme_textColor = GlobalPicker.textColor
        self.lblTitle.theme_textColor = GlobalPicker.textColor
        
        if #available(iOS 13.0, *) {
        
            let selectedThemeType = UserDefaults.standard.bool(forKey: Constant.UD_isLocalTheme)
            if selectedThemeType == false {
                
                imgLightCheck.image = UIImage(named: "check_box")
                imgDarkCheck.image = UIImage(named: "check_box")
                imgNativeSettingsCheck.image = UIImage(named: "checked")
                
                //    UserDefaults.standard.set(false, forKey: Constant.UD_isLocalTheme)
                //   MyThemes.saveLastTheme()
                
            }
            else {
                
                didTapSelectTheme(MyThemes.current == .dark ? btnDark : btnLight)
            }
        }
        else {
            
            self.viewSystemSettings.isHidden = true
            didTapSelectTheme(MyThemes.current == .dark ? btnDark : btnLight)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func didTapSelectTheme(_ sender: UIButton) {
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        self.lblTitle.theme_textColor = GlobalPicker.textColor
        
        if sender.tag == 0 {
            
            // Light mode
            MyThemes.switchTo(theme: .light)
            
            imgLightCheck.image = UIImage(named: "checked")
            imgDarkCheck.image = UIImage(named: "check_box")
            imgNativeSettingsCheck.image = UIImage(named: "check_box")
            UserDefaults.standard.set(true, forKey: Constant.UD_isLocalTheme)
            UserDefaults.standard.set(false, forKey: "dark")
            
        }
        else if sender.tag == 1 {
            
            //Dark mode
            MyThemes.switchTo(theme: .dark)
            
            imgLightCheck.image = UIImage(named: "check_box")
            imgDarkCheck.image = UIImage(named: "checked")
            imgNativeSettingsCheck.image = UIImage(named: "check_box")
            UserDefaults.standard.set(true, forKey: Constant.UD_isLocalTheme)
            UserDefaults.standard.set(true, forKey: "dark")
        }
        else {
            
            imgLightCheck.image = UIImage(named: "check_box")
            imgDarkCheck.image = UIImage(named: "check_box")
            imgNativeSettingsCheck.image = UIImage(named: "checked")

            SharedManager.shared.setThemeAutomatic()
        }
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        MyThemes.saveLastTheme()
        /*
        if SharedManager.shared.isAppSignIn {
            self.appDelegate?.setHomeVC()
        }
        else {
           // self.appDelegate?.setTopicVC()
            let vc = UserChannelsVC.instantiate(fromAppStoryboard: .registration)
            self.navigationController?.pushViewController(vc, animated: true)
        }*/
        let vc = UserChannelsVC.instantiate(fromAppStoryboard: .registration)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
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
}
