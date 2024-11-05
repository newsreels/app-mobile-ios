//
//  CustomTableFooterView.swift
//  Bullet
//
//  Created by Mahesh on 12/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

internal let FOOTER_HOME_VIEW           = "HomeFooterView"

import UIKit

class HomeFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.text = NSLocalizedString("Suggested", comment: "")
        lblTitle.theme_textColor = GlobalPicker.textColor
    }
}
