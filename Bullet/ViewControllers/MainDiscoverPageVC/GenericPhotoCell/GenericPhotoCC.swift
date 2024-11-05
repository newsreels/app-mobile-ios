//
//  GenericPhotoCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 04/05/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit


class GenericPhotoCC: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgLeftGradient: UIImageView!
    @IBOutlet weak var imgRightGradient: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.lblTitle.theme_textColor = GlobalPicker.textSubColorDiscover
        self.lblSubTitle.theme_textColor = GlobalPicker.textBWColorDiscover
        
        self.viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        self.theme_backgroundColor = GlobalPicker.backgroundDiscoverMainColor
        
        
        imgLeftGradient.theme_image = GlobalPicker.discoverRightGradient
        imgRightGradient.theme_image = GlobalPicker.discoverLeftGradient
        
        self.viewBG.addBottomShadowForDiscoverPage()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(model: Discover?) {
        
        self.lblTitle.text = model?.subtitle?.uppercased() ?? ""
        self.lblSubTitle.text = model?.title ?? ""
        let url = model?.data?.image ?? ""
        self.imgNews?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
    }
    
    
}
