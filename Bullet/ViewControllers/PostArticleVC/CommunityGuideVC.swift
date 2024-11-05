//
//  CommunityGuideVC.swift
//  Bullet
//
//  Created by Mahesh on 06/05/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

@objc protocol CommunityGuideVCDelegate: class {
    
    @objc optional func dimissCommunityGuideApprovedDelegate()
}

class CommunityGuideVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var viewNextButton: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblSubMsg: UILabel!
    
    weak var delegate: CommunityGuideVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()

        self.viewContainer.theme_backgroundColor = GlobalPicker.successPopupBGColor
        lblTitle.theme_textColor = GlobalPicker.textColor
        
        lblContinue.addTextSpacing(spacing: 2)
        viewNextButton.theme_backgroundColor = GlobalPicker.themeCommonColor
        self.viewNextButton.cornerRadius = self.viewNextButton.frame.size.height / 2
        
    }
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Before you post,", comment: "")
//        lblMessage.text = NSLocalizedString("Please remember that you are joining a global community of readers and writers. In order to protect everybody from any form of misinformation and abuse, please review our Community Guidelines.", comment: "")
                
        let yourAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: "#84838B".hexStringToUIColor(), .font: UIFont(name: Constant.FONT_Mulli_REGULAR, size: 14)!]
        let yourOtherAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: "#E01335".hexStringToUIColor(), .font: UIFont(name: Constant.FONT_Mulli_REGULAR, size: 14)!]

        let partOne = NSMutableAttributedString(string: NSLocalizedString("Please remember that you are joining a global community of readers and writers. In order to protect everybody from any form of misinformation and abuse, please review our ", comment: ""), attributes: yourAttributes)
        let partTwo = NSMutableAttributedString(string: NSLocalizedString("Community Guidelines.", comment: ""), attributes: yourOtherAttributes)
        partOne.append(partTwo)
        
        lblMessage.attributedText = partOne

        lblSubMsg.text = NSLocalizedString("By tapping Continue, you are agreeing to uphold the guidelines.", comment: "")
        lblContinue.text = NSLocalizedString("CONTINUE", comment: "")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(tap:)))
        self.lblMessage.addGestureRecognizer(tap)
        self.lblMessage.isUserInteractionEnabled = true

    }
    
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        guard let range = self.lblMessage.text?.range(of: NSLocalizedString("Community Guidelines.", comment: ""))?.nsRange else {
            return
        }
        
        if tap.didTapAttributedTextInLabel(label: self.lblMessage, inRange: range) {
            
            // Substring tapped
            let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
            vc.webURL = "https://www.newsinbullets.app/community-guidelines?header=false"
            vc.titleWeb = NSLocalizedString("Community Guidelines", comment: "")
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }

    
    @IBAction func didTapClose(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapContinue(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {
            
            self.delegate?.dimissCommunityGuideApprovedDelegate?()
        })
    }
    
}
