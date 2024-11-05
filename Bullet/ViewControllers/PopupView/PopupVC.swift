//
//  PopupVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 13/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol PopupVCDelegate: class {
    func popupVCDismissed()
}
class PopupVC: UIViewController {

    @IBOutlet weak var viewPopUpBackground: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnUpdate: UIButton!
    weak var delegate: PopupVCDelegate?
    @IBOutlet weak var imgPopup: UIImageView!
    
    var isFromProfileView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutIfNeeded()
        self.viewPopUpBackground.layer.cornerRadius = 12
        
        
    }
    
    
    func setupUI() {
        
        lblTitle.text = NSLocalizedString("Update profile", comment: "")
        if isFromProfileView {
            lblDesc.text = NSLocalizedString("Before you can post article, you need to update your profile", comment: "")
        }
        else {
            lblDesc.text = NSLocalizedString("Before you can comment, you need to update your profile", comment: "")
        }
        btnUpdate.setTitle(NSLocalizedString("UPDATE", comment: ""), for: .normal)

        
        viewPopUpBackground.theme_backgroundColor = GlobalPicker.commentTextViewBGColor
        lblTitle.theme_textColor = GlobalPicker.commentVCTitleColor
        lblDesc.theme_textColor = GlobalPicker.commentTextViewTextColor
        btnUpdate.theme_backgroundColor = GlobalPicker.themeCommonColor
        btnUpdate.setTitleColor(.white, for: .normal)
        btnUpdate.addTextSpacing(spacing: 2.0)
        imgPopup.theme_image = GlobalPicker.commentPopupImage
        //theme_setTitleColor(GlobalPicker.commentVCTitleColor, forState: .normal)
        
    }

    @IBAction func didTapBtnUpdate(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.popupVCDismissed()
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
