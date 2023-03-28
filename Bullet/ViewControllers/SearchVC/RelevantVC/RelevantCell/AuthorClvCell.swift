//
//  AuthorClvCell.swift
//  Bullet
//
//  Created by Faris Muhammed on 25/05/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class AuthorClvCell: UICollectionViewCell {

    @IBOutlet weak var viewAuthor: UIView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblFollowersCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblUsername.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblFollowersCount.theme_textColor = GlobalPicker.followersCountRelevant
        viewAuthor.theme_backgroundColor = GlobalPicker.backgroundColorHomeCell
        
    }

    
    override func layoutSubviews() {
        viewAuthor.layer.cornerRadius = 10
        viewAuthor.clipsToBounds = true
        imgProfile.layer.cornerRadius =  imgProfile.frame.width/2
        imgProfile.layer.theme_borderColor = GlobalPicker.backgroundColorBlackWhiteCG
        imgProfile.layer.borderWidth = 2
    }
    
    
    func setupCell(author: Author?) {
        
        let name = "\(author?.first_name ?? "")" + " " +   "\(author?.last_name ?? "")"
        lblUsername.text = name
        lblFollowersCount.text = "\(author?.follower_count ?? 0) followers"
        self.imgProfile.sd_setImage(with: URL(string: author?.profile_image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        self.imgCover.sd_setImage(with: URL(string: author?.cover_image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        
    }
    
    
}
