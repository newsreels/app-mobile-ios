//
//  HeadlineVerticalDiscoverCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 30/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class HeadlineVerticalDiscoverCC: UICollectionViewCell {
    
    //PROPERTIES
    @IBOutlet weak var viewImgBG: UIView!
    @IBOutlet weak var imgBG: UIImageView!
    
    @IBOutlet weak var lblHeadline: UILabel!
    @IBOutlet weak var constraintLblHeadlineHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewContainer: UIView!
    
    //Footer View
    @IBOutlet weak var viewFooter: UIView!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var btnSource: UIButton!
    @IBOutlet weak var imgWifi: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        lblSource.theme_textColor = GlobalPicker.textBWColor
        
        lblSource.textColor = .white

//        self.viewContainer.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor//GlobalPicker.backgroundColorHomeCell
    }
    
    func setupCell(model: articlesData) {
        
        lblHeadline.text = model.title
        imgBG.sd_setImage(with: URL(string: model.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))

        viewFooter.isHidden = false
        
        
        if model.source == nil {
            lblSource.text = model.source?.name ?? ""
            imgWifi.sd_setImage(with: URL(string: model.authors?.first?.image ?? "") , placeholderImage: nil)
        } else {
            lblSource.text = model.source?.name ?? ""
            imgWifi.sd_setImage(with: URL(string: model.source?.icon ?? "") , placeholderImage: nil)
        }
        
        
    }
    
    
    
}
