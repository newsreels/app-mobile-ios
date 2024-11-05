//
//  HomeSkeltonTabCell.swift
//  Bullet
//
//  Created by Faris Muhammed on 23/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Skeleton

class HomeSkeltonTabCell: UICollectionViewCell {

//    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewTitle: GradientContainerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupUIForSkelton()
    }

    
    func setupUIForSkelton() {
        
//        lblTitle.linesCornerRadius = 5
        
    }
    
    override func layoutSubviews() {
//
        self.viewTitle.layer.cornerRadius = 5
        self.viewTitle.clipsToBounds = true
//        self.layoutSkeletonIfNeeded()
        
    }
    
}


extension HomeSkeltonTabCell: GradientsOwner {
  var gradientLayers: [CAGradientLayer] {
    return [viewTitle.gradientLayer]
  }
}

