//
//  FollowingAuthorsCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 11/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class FollowingAuthorsCC: UICollectionViewCell {

    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var lblAuthorName: UILabel!
    @IBOutlet weak var imgFav: UIImageView!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblAuthorName.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        viewContainer.theme_backgroundColor = GlobalPicker.followingCardColor
        viewBG.theme_backgroundColor = GlobalPicker.followingCardColor
        viewBG.addRoundedShadow()
    }
    
    func setupAuthorCell(author: Author?) {
 
        self.imgAuthor.sd_setImage(with: URL(string: author?.profile_image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        self.lblAuthorName.text = "\(author?.first_name ?? "") \(author?.last_name ?? "")"
        self.imgFav.image = author?.favorite ?? false ? UIImage(named: "favFollowing") : UIImage(named: "unfavFollowing")
    }
}
