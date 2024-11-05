//
//  ProfileSelectionCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 20/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ProfileSelectionCC: UITableViewCell {

    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var viewUnderline: UIView!
    @IBOutlet weak var viewBackground: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        viewBackground.theme_backgroundColor = GlobalPicker.backgroundColorWhiteBlack
        
        lblName.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblFollowers.theme_textColor = GlobalPicker.createChannelColor
        
        self.viewUnderline.theme_backgroundColor = GlobalPicker.channelUnderlineColor
        
        
    }

    
    override func layoutSubviews() {
        imgProfilePic.layer.cornerRadius = imgProfilePic.frame.size.height/2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupCell(channel: ChannelInfo?) {
        
        lblName.text = channel?.name ?? ""
        lblFollowers.text = "\(channel?.follower_count ?? 0) \(NSLocalizedString("followers", comment: ""))"
        imgProfilePic?.sd_setImage(with: URL(string: channel?.icon ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))

    }
    
    
}
