//
//  FollowersListCC.swift
//  Bullet
//
//  Created by Mahesh on 25/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class FollowersListCC: UITableViewCell {
    
    var didTapRemoveBlock: (() -> Void)?

    @IBOutlet weak var imgTag: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    @IBOutlet weak var viewRemove: UIView!
    @IBOutlet weak var lblRemove: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgTag.cornerRadius = imgTag.frame.height / 2
        
        lblTitle.theme_textColor = GlobalPicker.textColor
        
        lblRemove.text = NSLocalizedString("REMOVE", comment: "")
        lblRemove.addTextSpacing(spacing: 2.0)
        viewRemove.isHidden = true
    }
    
    override func layoutSubviews() {
        imgTag.cornerRadius = imgTag.frame.height / 2
    }
    
//    func setupCell(isSameAuthor: Bool) {
//        
//        if isSameAuthor {
//            viewRemove.isHidden = true
//        }
//        else {
//            lblRemove.text = NSLocalizedString("REMOVE", comment: "")
//            lblRemove.addTextSpacing(spacing: 2.0)
//            viewRemove.isHidden = true
//        }
//    }
    
    @IBAction func didTapRemove(_ sender: UIButton) {
        didTapRemoveBlock?()
    }
}
