//
//  suggestedReelsCC.swift
//  Bullet
//
//  Created by Mahesh on 07/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit


class suggestedReelsCC: UICollectionViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgReels: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgProfile.cornerRadius = imgProfile.frame.height / 2
//        imgProfile.borderWidth = 2
//        imgProfile.borderColor = UIColor.white

        viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        viewBG.addRoundedShadowCell()
    }
    
    func setupCell(model: Reel) {
        
        imgReels.sd_setImage(with: URL(string: model.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        
        //Check source and author
        if let source = model.source {
            /* If reel source */
            imgProfile.sd_setImage(with: URL(string: source.icon ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" : "icn_placeholder_light"))
            lblName.text = "@\(source.name ?? "")"
        }
        else {
            //If reel author
            imgProfile.sd_setImage(with: URL(string: model.authors?.first?.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" : "icn_profile_placeholder_light"))
            lblName.text = "@\(model.authors?.first?.username ?? "")"
        }
    }
    
}

