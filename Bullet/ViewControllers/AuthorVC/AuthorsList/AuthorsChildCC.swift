//
//  AuthorsChildCC.swift
//  Bullet
//
//  Created by Mahesh on 13/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class AuthorsChildCC: UITableViewCell {

    @IBOutlet weak var imgTag: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    @IBOutlet weak var imgRadio: UIImageView!
    @IBOutlet weak var btnAddTag: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imgTag.cornerRadius = self.imgTag.frame.height / 2
    }
    
    override func layoutSubviews() {
        self.imgTag.cornerRadius = self.imgTag.frame.height / 2
    }
}
