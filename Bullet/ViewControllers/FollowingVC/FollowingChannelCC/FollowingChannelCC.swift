//
//  FollowingChannelCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 11/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class FollowingChannelCC: UICollectionViewCell {

    @IBOutlet weak var imgChannel: UIImageView!
    @IBOutlet weak var lblChannelName: UILabel!
    @IBOutlet weak var imgFav: UIImageView!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var viewBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblChannelName.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        
        imgChannel.cornerRadius = imgChannel.frame.size.width / 2
        imgChannel.layer.masksToBounds = true
        
        viewBG.cornerRadius = viewBG.frame.size.width / 2
        viewBG.addRoundedShadow()
        
    }
    
    func setupChannelCell(channel: ChannelInfo?) {
 
        let url = channel?.portrait_image ?? channel?.image ?? ""
        self.imgChannel.sd_setImage(with: URL(string: url) , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        self.lblChannelName.text = channel?.name ?? ""
        self.imgFav.image = channel?.favorite ?? false ? UIImage(named: "favFollowing") : UIImage(named: "unfavFollowing")
        
    }
    
    func setupLocationCell(location: Location?) {
 
        self.imgChannel.sd_setImage(with: URL(string: location?.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        self.lblChannelName.text = location?.name ?? ""
        self.imgFav.image = location?.favorite ?? false ? UIImage(named: "favFollowing") : UIImage(named: "unfavFollowing")
        
    }
    
    func setupChannelChildCell(channel: ChannelInfo?) {
 
        let url = channel?.portrait_image ?? channel?.image ?? ""
        self.imgChannel.sd_setImage(with: URL(string: url) , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        self.lblChannelName.text = channel?.name ?? ""
        self.imgFav.image = channel?.favorite ?? false ? UIImage(named: "favFollowing") : UIImage(named: "unfavFollowing")
        
    }

}
