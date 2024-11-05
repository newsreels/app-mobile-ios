//
//  LanguageVC.swift
//  Bullet
//
//  Created by MK on 13/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class CommonHelpFeedOthersVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var viewHelpFeedback: UIView!
    @IBOutlet weak var viewOthers: UIView!

    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblFeedback: UILabel!
    @IBOutlet weak var lblHelp: UILabel!

    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var lblCommunity: UILabel!
    
    @IBOutlet var lblCollection: [UILabel]!
    
    var isFromHelpFeedback: Bool = true
    
    var languagesArrMain: [languagesData]?
    var languagesArr: [languagesData]?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //LOCALIZABLE STRING
        setupLocalization()
        
        //DESIGN VIEW
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        lblTitle.theme_textColor = GlobalPicker.textColor
        imgBack.theme_image = GlobalPicker.imgBack

        self.lblCollection.forEach {
            $0.theme_textColor = GlobalPicker.textColor
        }
        
        if isFromHelpFeedback {
            self.viewHelpFeedback.isHidden = false
            self.viewOthers.isHidden = true
        }
        else {
            self.viewHelpFeedback.isHidden = true
            self.viewOthers.isHidden = false
        }
        
    }
    
    func setupLocalization() {
        
        lblTitle.text = isFromHelpFeedback ? NSLocalizedString("Help and Feedback", comment: "") : NSLocalizedString("Others", comment: "")
        
        lblFeedback.text = NSLocalizedString("Feedback & Suggestions", comment: "")
        lblHelp.text = NSLocalizedString("Help / Contact Us", comment: "")
        
        
        lblAbout.text = NSLocalizedString("About", comment: "")
        lblTerms.text = NSLocalizedString("Terms and Conditions", comment: "")
        lblPrivacy.text = NSLocalizedString("Privacy Policy", comment: "")
        lblCommunity.text = NSLocalizedString("Community Guidelines", comment: "")

    }

    
    
    @IBAction func didTapBackButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapFeedback(_ sender: Any) {
                
        let vc = SuggestionVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
      //  self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
        
//        let vc = contactUsVC.instantiate(fromAppStoryboard: .registration)
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true, completion: nil)
        let vc = helpCenterVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapAbout(_ sender: Any) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.aboutClick, eventDescription: "")
        let vc = AboutVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapTerms(_ sender: Any) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.termsClick, eventDescription: "")
        let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
        vc.webURL = "https://www.newsinbullets.app/terms/?header=false"
        vc.titleWeb = NSLocalizedString("Terms & Conditions", comment: "")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapPolicy(_ sender: Any) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.policyClick, eventDescription: "")
        let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
        vc.webURL = "https://www.newsinbullets.app/privacy/?header=false"
        vc.titleWeb = NSLocalizedString("Privacy Policy", comment: "")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapCommunity(_ sender: Any) {
        
        let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
        vc.webURL = "https://www.newsinbullets.app/community-guidelines?header=false"
        vc.titleWeb = NSLocalizedString("Community Guidelines", comment: "")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
