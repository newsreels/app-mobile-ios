//
//  NotificationCellHeaderCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 27/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class NotificationCellHeaderCC: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.theme_backgroundColor = GlobalPicker.searchBGViewColor
    }

    
    func setupCell(notifications: Notifications) {
     
        lblTitle.text = notifications.type ?? ""
    }
}
