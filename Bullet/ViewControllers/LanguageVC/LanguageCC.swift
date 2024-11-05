//
//  LanguageCC.swift
//  Bullet
//
//  Created by Mahesh on 13/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class LanguageCC: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    @IBOutlet weak var imgRadio: UIImageView!
    @IBOutlet weak var viewLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        lblTitle.textColor = UIColor.black
        lblSubTitle.textColor = Constant.appColor.mediumGray
        
    }
}
