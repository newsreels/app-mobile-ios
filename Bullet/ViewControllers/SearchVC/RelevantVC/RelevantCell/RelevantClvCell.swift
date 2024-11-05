//
//  RelevantClvCell.swift
//  Bullet
//
//  Created by Khadim Hussain on 18/05/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class RelevantClvCell: UICollectionViewCell {

    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewBackground.backgroundColor = .clear
        viewContainer.theme_backgroundColor = GlobalPicker.backgroundColorHomeCell
        lblTitle.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        
    }
    
    override func layoutSubviews() {
        
        viewContainer.layer.cornerRadius = viewContainer.frame.size.height / 2
    }

    func setupCell(image: String, title: String) {
        
        lblTitle.text = title
        self.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        
    }
    
    
    
    
    
    
}
