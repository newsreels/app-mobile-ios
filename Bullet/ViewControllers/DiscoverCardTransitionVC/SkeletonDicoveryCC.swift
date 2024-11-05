//
//  SkeletonDicoveryCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 07/07/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class SkeletonDicoveryCC: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTitle2: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        setupUIForSkelton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupUIForSkelton() {
        
//        lblTitle.linesCornerRadius = 5
        
        
    }
    
    
}
