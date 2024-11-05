//
//  SettingsCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 30/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class SettingsCC: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblItem: UILabel!
    @IBOutlet weak var imgArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
     //   imgView.theme_image = GlobalPicker.arrowImage
        lblItem.theme_textColor = GlobalPicker.textColor
    }


    override func layoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblItem.semanticContentAttribute = .forceRightToLeft
                self.lblItem.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblItem.semanticContentAttribute = .forceLeftToRight
                self.lblItem.textAlignment = .left
            }
        }
    }
}
