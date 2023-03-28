//
//  NotificationCommentsCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 26/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class NotificationCommentsCC: UITableViewCell {

    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgType: UIImageView!
    @IBOutlet weak var imgUser1: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var constraintImgUserLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintImgUserTopSpace: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblComment.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblTime.theme_textColor = GlobalPicker.textSubColorDiscover
        contentView.theme_backgroundColor = GlobalPicker.followingCardColor
        imgUser.cornerRadius = imgUser.frame.size.width / 2
        imgUser.clipsToBounds = true
        imgUser1.cornerRadius = imgUser.frame.size.width / 2
        imgUser1.clipsToBounds = true
    }
    
    func setupCell(notifications: NotificationsDetail) {
        
        let time = SharedManager.shared.generateDatTimeOfNews(notifications.created_at ?? "")
        SharedManager.shared.formatLabel(label: lblComment, with: (notifications.details ?? ""))
  
        lblTime.text = time
        
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
        }
        
        
        if notifications.type == "COMMENT" {
            
            imgType.image = UIImage(named: "Comments")
        }
        else if notifications.type == "FOLLOW" {
            
            imgType.image = UIImage(named: "Add")
        }
    }
}
