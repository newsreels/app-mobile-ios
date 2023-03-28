//
//  ChannelIconCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 27/07/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ChannelIconCC: UICollectionViewCell {

    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setCornerRadius()
        
        imgIcon.backgroundColor = .red
        
        lblName.theme_textColor = GlobalPicker.textBWColorDiscover
    }

    override func layoutSubviews() {
        
        setCornerRadius()
    }
    
    func setCornerRadius() {
        imgIcon.layer.cornerRadius = imgIcon.frame.size.width/2
    }
    
    
    
}
