//
//  SuccessAlertVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 21/10/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol successAlertDelegate: class {
    
    func didTapDismissController()
}

class SuccessAlertVC: UIViewController {

    @IBOutlet weak var lblSuccess: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var viewNextButton: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgMessageGIF: UIImageView!
    @IBOutlet weak var btnContinue: UIButton!
    
    weak var delegate: successAlertDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()

        self.viewContainer.theme_backgroundColor = GlobalPicker.successPopupBGColor
        lblSuccess.theme_textColor = GlobalPicker.textColor
        lblMessage.theme_textColor = GlobalPicker.textColor
        
        lblContinue.addTextSpacing(spacing: 2)
        viewNextButton.backgroundColor = Constant.appColor.lightRed
        //theme_backgroundColor = GlobalPicker.themeCommonColor
        self.viewNextButton.cornerRadius = self.viewNextButton.frame.size.height / 2
        self.imgMessageGIF.loadGif(name: "Message-Success-GIF")
        
    }
    
    func setupLocalization() {
        lblSuccess.text = NSLocalizedString("Success!", comment: "")
        lblMessage.text = NSLocalizedString("Your message has \nbeen sent.", comment: "")
        lblContinue.text = NSLocalizedString("CONTINUE", comment: "")
        
    }

    @IBAction func didTapContinue(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {
            
            self.delegate?.didTapDismissController()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.imgMessageGIF.stopAnimating()
        self.imgMessageGIF.loadGif(name: "")
    }
}
