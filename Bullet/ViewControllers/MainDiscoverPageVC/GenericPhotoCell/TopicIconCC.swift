//
//  TopicIconCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 27/07/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class TopicIconCC: UICollectionViewCell {

    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        imgIcon.backgroundColor = .green
    }

}
