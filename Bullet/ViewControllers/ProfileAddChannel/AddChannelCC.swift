//
//  AddChannelCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 15/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SwiftTheme

protocol AddChannelCCDelegate: class {
    func userPressedAddChannel()
}

class AddChannelCC: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgAdd: UIImageView!
    @IBOutlet weak var viewBG: UIView!
    weak var delegate: AddChannelCCDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblTitle.theme_textColor = GlobalPicker.createChannelColor
        contentView.theme_backgroundColor = GlobalPicker.followingViewBGColor
        imgAdd.theme_image = GlobalPicker.imgAddChannel
        
        lblTitle.text = NSLocalizedString("Create a channel", comment: "")
        viewBG.theme_backgroundColor = GlobalPicker.backgroundColorWhiteBlack
        viewBG.addRoundedShadow(0.4)
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func didTapCreateChannel(_ sender: Any) {
        
        self.delegate?.userPressedAddChannel()
        
    }
    
}
