//
//  GenericHeadlineView.swift
//  Bullet
//
//  Created by Khadim Hussain on 12/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class GenericHeadlineView: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewSeperatorLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblTitle.theme_textColor = GlobalPicker.textBWColorDiscover
        self.viewSeperatorLine.theme_backgroundColor = GlobalPicker.viewSeperatorListColor
        self.theme_backgroundColor = GlobalPicker.backgroundDiscoverMainColor
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
            }
        }
    }
    
}
