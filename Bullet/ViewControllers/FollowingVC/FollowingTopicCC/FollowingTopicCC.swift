//
//  FollowingTopicCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 11/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class FollowingTopicCC: UICollectionViewCell {

    @IBOutlet weak var imgTopic: UIImageView!
    @IBOutlet weak var imgFav: UIImageView!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblTopic: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
 
        viewBG.addRoundedShadow()
        viewBG.theme_backgroundColor = GlobalPicker.followingCardColor
    }
    
    func setupTopicCell(topic: TopicData?) {
 
        self.imgTopic.sd_setImage(with: URL(string: topic?.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        self.lblTopic.text = topic?.name ?? ""
        self.imgFav.image = topic?.favorite ?? false ? UIImage(named: "favFollowing") : UIImage(named: "unfavFollowing")
    }
}
