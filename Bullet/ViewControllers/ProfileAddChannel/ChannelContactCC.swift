//
//  ChannelContactCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 16/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol ChannelContactCCDelegate: AnyObject {
    func didTapContactUs()
}

class ChannelContactCC: UITableViewCell {

    @IBOutlet weak var lblNeedMore: UILabel!
    @IBOutlet weak var lblContact: UILabel!
    weak var delegate: ChannelContactCCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setLocalization()
        lblNeedMore.theme_textColor = GlobalPicker.createChannelColor
        lblContact.theme_textColor = GlobalPicker.themeCommonColor
        contentView.theme_backgroundColor = GlobalPicker.followingViewBGColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setLocalization() {
        
        self.lblContact.text = "\(NSLocalizedString("CONTACT US", comment: "").capitalized)!"
        self.lblNeedMore.text = "\(NSLocalizedString("Need more channels?", comment: ""))"
        
    }
    
    
    
    @IBAction func didTapContactUs(_ sender: Any) {
        
        delegate?.didTapContactUs()
    }
    
    
}
