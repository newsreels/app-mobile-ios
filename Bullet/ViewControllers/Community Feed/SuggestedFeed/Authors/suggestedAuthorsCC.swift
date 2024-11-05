//
//  suggestedAuthorsCC.swift
//  Bullet
//
//  Created by Mahesh on 07/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class suggestedAuthorsCC: UICollectionViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var lblAuthorName: UILabel!
    @IBOutlet weak var imgMark: UIImageView!
    @IBOutlet weak var btnFollow: UIButton!
    
    //@IBOutlet weak var viewCornerBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblAuthorName.theme_textColor = GlobalPicker.textColor
//        viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
//        viewCornerBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
//
//        viewBG.addRoundedShadowCell()
//
        
        //viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        //viewBG.addRoundedShadowCell()
        //viewBG.layer.cornerRadius = 12
    }
    
    override func layoutIfNeeded() {
        
        super.layoutIfNeeded()
        imgAuthor.cornerRadius = imgAuthor.frame.height / 2
    }
    
    func setupCell(model: Author) {
        
        imgAuthor.sd_setImage(with: URL(string: model.profile_image ?? "") , placeholderImage: nil)
        //imgAuthor.layer.cornerRadius = imgAuthor.frame.height / 2

        let name = "\(model.first_name ?? "")" + " " + "\(model.last_name ?? "")"
        lblAuthorName.text = name.trim()
        
        let fav = model.favorite ?? false
        if fav {
            imgMark.theme_image = GlobalPicker.selectedTickMarkImage
        }
        else {
            imgMark.theme_image = GlobalPicker.unSelectedTickMarkImage
        }
    }
    
}



//MARK:- Block Authors Cell
class blockedAuthorsCC: UICollectionViewCell {
    
    var didTapUnblockAuthorPressedBlock: (() -> Void)?

    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgBlock: UIImageView!
    @IBOutlet weak var lblAuthorName: UILabel!
    //@IBOutlet weak var viewCornerBG: UIView!
    @IBOutlet weak var imgAuthor: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblAuthorName.theme_textColor = GlobalPicker.textColor
//        viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
//        viewCornerBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
//
//        viewBG.addRoundedShadowCell()
//
        viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        viewBG.addRoundedShadowCell()
        viewBG.cornerRadius = 12
    }
    
    
    @IBAction func didTapBlocked(_ sender: UIButton) {
        didTapUnblockAuthorPressedBlock?()
    }
    
    
}
