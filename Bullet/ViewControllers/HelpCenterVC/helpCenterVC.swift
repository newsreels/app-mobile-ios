//
//  helpCenterVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 19/08/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SwiftTheme

class helpCenterVC: UIViewController {

    @IBOutlet weak var btnContactUs: UIButton!
    
//    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var imgHelpGIF: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        btnContactUs.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        btnContactUs.layer.borderWidth = 2.5
        btnContactUs.layer.borderColor = Constant.appColor.lightRed.cgColor
        btnContactUs.addTextSpacing(spacing: 2)
        
        lblDescription.setLineSpacing(lineSpacing: 7)
        lblDescription.textAlignment = .center
        lblDescription.theme_textColor = GlobalPicker.textColor
        lblTitle.theme_textColor = GlobalPicker.textColor
        lblHeading.theme_textColor = GlobalPicker.textColor
//        imgBack.theme_image = GlobalPicker.imgBack

    }
    
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Help Center", comment: "")
        lblHeading.text = NSLocalizedString("How can we help you?", comment: "")
        lblDescription.text = NSLocalizedString("It looks like you are experiencing problems with our app. We are here to help so please get in touch with us", comment: "")
        
        btnContactUs.setTitle(NSLocalizedString("CONTACT US", comment: ""), for: .normal)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
     //   self.imgHelpGIF.loadGif(name: "Help-Illustration")
    }

    @IBAction func didTapContactUs(_ sender: UIButton) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.helpCenter, eventDescription: "")
        let vc = contactUsVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        
      //  self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.imgHelpGIF.stopAnimating()
        self.imgHelpGIF.loadGif(name: "")
    }
}
