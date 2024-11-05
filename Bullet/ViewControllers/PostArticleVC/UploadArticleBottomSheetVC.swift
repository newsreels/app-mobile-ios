//
//  UploadArticleBottomSheetVC.swift
//  Bullet
//
//  Created by Mahesh on 06/05/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

@objc protocol UploadArticleBottomSheetVCDelegate: class {
    
    @objc optional func UploadArticleSelectedTypeDelegate(type: Int)
}

class UploadArticleBottomSheetVC: UIViewController {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet var lblCollection: [UILabel]!
    @IBOutlet weak var lblMedia: UILabel!
    @IBOutlet weak var lblNewsreels: UILabel!
    @IBOutlet weak var lblYoutube: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imgMedia: UIImageView!
    @IBOutlet weak var imgNewsreels: UIImageView!
    @IBOutlet weak var imgYoutube: UIImageView!

    weak var delegate: UploadArticleBottomSheetVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBG.theme_backgroundColor = GlobalPicker.backgroundColor
        
        self.setDesignView()
        self.setupLocalization()
    }
    
    override func viewDidLayoutSubviews() {
        
        viewBG.roundCorners([.topLeft, .topRight], 12)
    }
    
    func setDesignView() {
                
        lblCollection.forEach { lbl in
            lbl.theme_textColor = GlobalPicker.textColor
        }
        
        imgMedia.theme_image = GlobalPicker.imgMedia
        imgNewsreels.theme_image = GlobalPicker.imgNewsreels
        imgYoutube.theme_image = GlobalPicker.imgYoutube

    }
    
    func setupLocalization() {
        
        lblTitle.text = NSLocalizedString("Post article", comment: "")
        lblMedia.text = NSLocalizedString("Upload media", comment: "")
        lblNewsreels.text = NSLocalizedString("Upload Newsreels", comment: "")
        lblYoutube.text = NSLocalizedString("Upload YouTube link", comment: "")
    }
    
    //MARK:- BUTTONN ACTION
    @IBAction func didTapUploadType(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            self.delegate?.UploadArticleSelectedTypeDelegate?(type: sender.tag)
        }
        
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
