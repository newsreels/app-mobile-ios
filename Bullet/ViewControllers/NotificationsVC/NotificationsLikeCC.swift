//
//  NotificationsLikeCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 26/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class NotificationsLikeCC: UITableViewCell {

    @IBOutlet weak var lblike: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgUser1: UIImageView!
    @IBOutlet weak var imgLike: UIImageView!
    
    @IBOutlet weak var constraintImgUserLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintImgUserTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintLableTrailingSpace: NSLayoutConstraint!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblike.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        contentView.theme_backgroundColor = GlobalPicker.followingCardColor
        imgUser.cornerRadius = imgUser.frame.size.width / 2
        imgUser.clipsToBounds = true
        imgUser1.cornerRadius = imgUser.frame.size.width / 2
        imgUser1.clipsToBounds = true
        lblTime.theme_textColor = GlobalPicker.textSubColorDiscover
        
    }
    
    func setupCell(notifications: NotificationsDetail) {
        
        let time = SharedManager.shared.generateDatTimeOfNews(notifications.created_at ?? "")
        lblTime.text = time
        SharedManager.shared.formatLabel(label: lblike, with: (notifications.details ?? ""))
        
        
        if let images = notifications.image, images.count <= 1 {
            
            self.imgUser1.isHidden = true
            self.constraintImgUserLeadingSpace.constant = 20
            self.constraintImgUserTopSpace.constant = 20
            
            imgUser.sd_setImage(with: URL(string: notifications.image?.first ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
        }
        else {
            
            self.imgUser1.isHidden = false
            self.constraintImgUserLeadingSpace.constant = 35
            self.constraintImgUserTopSpace.constant = 35
            imgUser.sd_setImage(with: URL(string: notifications.image?.first ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
            imgUser1.sd_setImage(with: URL(string: notifications.image?[1] ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
            
            imgUser.layer.borderWidth = 1.5
            imgUser.layer.theme_borderColor = GlobalPicker.imageBorderColor
            imgUser.layer.masksToBounds = true
        }
        
        if let detailImage = notifications.detail_image, detailImage != "" {
            
            imgLike.isHidden = false
            imgLike.sd_setImage(with: URL(string: notifications.detail_image ?? ""))
            constraintLableTrailingSpace.constant = 107
        }else{
            
            imgLike.isHidden = true
            constraintLableTrailingSpace.constant = 20
        }
        
    }
}
