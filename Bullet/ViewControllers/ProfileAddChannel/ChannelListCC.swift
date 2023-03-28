//
//  ChannelListCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 15/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ChannelListCC: UITableViewCell {

    @IBOutlet weak var viewChannelListContainer: UIView!
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblViewChannel: UILabel!
    @IBOutlet weak var viewUnderline: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblUserName.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblViewChannel.theme_textColor = GlobalPicker.createChannelColor
        contentView.theme_backgroundColor = GlobalPicker.followingViewBGColor
        
        self.viewUnderline.theme_backgroundColor = GlobalPicker.backgroundColorHomeCell
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                
                self.lblUserName.semanticContentAttribute = .forceRightToLeft
                self.lblUserName.textAlignment = .right
                self.lblViewChannel.semanticContentAttribute = .forceRightToLeft
                self.lblViewChannel.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                
                self.lblUserName.semanticContentAttribute = .forceLeftToRight
                self.lblUserName.textAlignment = .left
                self.lblViewChannel.semanticContentAttribute = .forceLeftToRight
                self.lblViewChannel.textAlignment = .left
            }
            
        }
    }
    
    
    func setupCell(channel: ChannelInfo?) {
        
        lblUserName.text = channel?.name ?? ""
        lblViewChannel.text = NSLocalizedString("View channel", comment: "")
        imgUserProfile.sd_setImage(with: URL(string: channel?.icon ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        
        
    }
    
}
