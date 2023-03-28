//
//  MyAccountVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 30/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class MyAccountVC: UIViewController {

    @IBOutlet weak var lblEmailTitle: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPwdTitle: UILabel!
    @IBOutlet weak var lblSaveArticle: UILabel!
    @IBOutlet weak var lblBlockList: UILabel!

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPwd: UIView!
    
    @IBOutlet var lblCollection: [UILabel]!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
//    @IBOutlet var imgArrowCollection: [UIImageView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()
        
        //Design View
        lblEmailTitle.addTextSpacing(spacing: 1.45)
        lblPwdTitle.addTextSpacing(spacing: 1.45)
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        imgBack.theme_image = GlobalPicker.imgBack
//        lblEmailTitle.theme_textColor = GlobalPicker.textColor
//        lblEmail.theme_textColor = GlobalPicker.textSubColor
//        lblPwdTitle.theme_textColor = GlobalPicker.textColor
//        lblTitle.theme_textColor = GlobalPicker.textColor
        
        self.lblCollection.forEach {
            $0.theme_textColor = GlobalPicker.textColor
        }
        
        let hasPassword = UserDefaults.standard.bool(forKey: Constant.UD_isSocialLinked)
        if hasPassword {
            
            self.viewEmail.isHidden = false
            self.viewPwd.isHidden = false
        }
        else {
        
            self.viewEmail.isHidden = true
            self.viewPwd.isHidden = true
        }

//        imgArrowCollection.forEach { (imageView) in
//            imageView.image = UIImage(named: MyThemes.current == .dark ? "tbFroword" : "tbFrowordLight")
//        }
    
    }
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Account", comment: "")
        lblEmailTitle.text = NSLocalizedString("E-mail Address", comment: "")
        lblPwdTitle.text = NSLocalizedString("Change Password", comment: "")
        
        lblSaveArticle.text = NSLocalizedString("Favorites Articles", comment: "")
        lblBlockList.text = NSLocalizedString("Block List", comment: "")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.lblEmail.text = UserDefaults.standard.value(forKey: Constant.UD_userEmail) as? String
    }
    
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapAcc1(_ sender: Any) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.changeEmail, eventDescription: "")
        let vc = ChangeEmailVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapAcc2(_ sender: Any) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.changePassword, eventDescription: "")
        let vc = ChangePasswordVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
     
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSavedArticles(_ sender: Any) {
        
        //        let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
        //        vc.showArticleType = .savedArticle
        ////
        //        self.navigationController?.pushViewController(vc, animated: true)
        //     //   self.present(navVC, animated: true, completion: nil)
        
        
        let vc = DraftSavedArticlesVC.instantiate(fromAppStoryboard: .Schedule)
        vc.isFromSaveArticles = true
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        self.present(nav, animated: true, completion: nil)
        
        
    }
    
    @IBAction func didTapBlockList(_ sender: Any) {
        
        let vc = blockListVC.instantiate(fromAppStoryboard: .registration)
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .overFullScreen
        self.present(navVC, animated: true, completion: nil)
    }

}

extension MyAccountVC: ChangeEmailVCDelegate {
    
    func emailUpdated() {
        self.lblEmail.text = UserDefaults.standard.value(forKey: Constant.UD_userEmail) as? String
    }
}
