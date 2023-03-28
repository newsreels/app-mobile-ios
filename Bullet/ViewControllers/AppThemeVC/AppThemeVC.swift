//
//  AppThemeVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 21/02/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class AppThemeVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnDark: UIButton!
    @IBOutlet weak var btnLight: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnHelp: UIButton!

    @IBOutlet weak var viewDarkMode: UIView!
    @IBOutlet weak var viewThemeBtnsBG: UIView!
    @IBOutlet weak var viewAnimate: UIView!
    @IBOutlet weak var viewBG: UIView!
    
    @IBOutlet weak var imgTheme: UIImageView!
    @IBOutlet weak var animateViewTralingConstraint: NSLayoutConstraint!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //LOCALIZABLE STRING
        btnHelp.setTitle(NSLocalizedString("HELP", comment: ""), for: .normal)
        btnDark.setTitle(NSLocalizedString("Dark", comment: ""), for: .normal)
        btnLight.setTitle(NSLocalizedString("Light", comment: ""), for: .normal)
        btnContinue.setTitle(NSLocalizedString("CONTINUE", comment: ""), for: .normal)
        lblTitle.text = NSLocalizedString("Choose a style", comment: "")
        lblSubTitle.text = NSLocalizedString("Pop or subtle. Day or night. Customize your interface.", comment: "")

        //default we will set datk mode
        self.didTapTheme(self.btnDark)
        
        
        lblTitle.theme_textColor = GlobalPicker.textColor
        lblSubTitle.theme_textColor = GlobalPicker.textSubColor
        viewThemeBtnsBG.theme_backgroundColor = GlobalPicker.subCategoryHeaderBGColor
   //     self.imgTheme.theme_image = GlobalPicker.themeImage
        btnHelp.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
        
        let vc = helpCenterVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        self.appDelegate.setHomeVC()
    }
    
    //MARK:- Theme Selection
    @IBAction func didTapTheme(_ sender: UIButton) {
        
        self.btnDark.isUserInteractionEnabled = false
        self.btnLight.isUserInteractionEnabled = false
        if sender.tag == 0 {
            
            setThemeTypes(sender: btnDark)
        }
        else {
            
            setThemeTypes(sender: btnLight)
        }
    }
    
    func setThemeTypes(sender: UIButton) {
        
        SharedManager.shared.bulletPlayer?.pause()
        SharedManager.shared.bulletPlayer?.stop()
        SharedManager.shared.isSubSourceView = false

        if sender.tag == 0 {
            
            //Dark
            self.view.layoutIfNeeded()
            let width = self.view.frame.size.width
            UIView.animate(withDuration: 0.3) {
                
                self.view.layoutIfNeeded()
                self.animateViewTralingConstraint.constant = -width
                self.view.layoutIfNeeded()
                
            } completion: { (_) in
            
                self.viewAnimate.backgroundColor = .black
                self.btnDark.isUserInteractionEnabled = true
                self.btnLight.isUserInteractionEnabled = true
            }
            
            self.viewBG.backgroundColor = .black
            self.btnDark.backgroundColor = "#3AD9D2".hexStringToUIColor()
            self.btnLight.backgroundColor = .clear
            self.btnDark.setTitleColor(.white, for: .normal)
            self.btnLight.setTitleColor("#909090".hexStringToUIColor(), for: .normal)
            self.viewThemeBtnsBG.backgroundColor = "#0E0E0E".hexStringToUIColor()
            self.btnContinue.backgroundColor = "#3AD9D2".hexStringToUIColor()
            
            MyThemes.switchTo(theme: .dark)
            UserDefaults.standard.set(true, forKey: Constant.UD_isLocalTheme)
            UserDefaults.standard.set(true, forKey: "dark")

        }
        else {
            
            //Light
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3) {
                
                self.view.layoutIfNeeded()
                self.animateViewTralingConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            } completion: { (_) in
        
                self.viewBG.backgroundColor = .white
                self.btnDark.isUserInteractionEnabled = true
                self.btnLight.isUserInteractionEnabled = true
            }
            
            self.viewAnimate.backgroundColor = .white
            self.btnDark.backgroundColor = .clear
            self.btnLight.backgroundColor = "#FA0815".hexStringToUIColor()
            self.btnLight.setTitleColor(.white, for: .normal)
            self.btnDark.setTitleColor("#909090".hexStringToUIColor(), for: .normal)
            self.viewThemeBtnsBG.backgroundColor = "#F3F3F3".hexStringToUIColor()
            self.btnContinue.backgroundColor = "#FA0815".hexStringToUIColor()
        
            MyThemes.switchTo(theme: .light)
            UserDefaults.standard.set(true, forKey: Constant.UD_isLocalTheme)
            UserDefaults.standard.set(false, forKey: "dark")
        
        }
    }
}
