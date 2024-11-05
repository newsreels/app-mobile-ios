//
//  CustomTableFooterView.swift
//  Bullet
//
//  Created by Mahesh on 12/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class CustomTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.theme_textColor = GlobalPicker.textColor
    }
}
