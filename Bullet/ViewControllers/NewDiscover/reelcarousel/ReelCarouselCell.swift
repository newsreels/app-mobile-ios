//
//  ReelCarouselCell.swift
//  Bullet
//
//  Created by Faris Muhammed on 02/09/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ReelCarouselCell: UICollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewReel: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutIfNeeded()
//        self.layoutSkeletonIfNeeded()
//        lblTitle.skeletonCornerRadius = 5
//        viewReel.skeletonCornerRadius = 5
    }
    
    
    override func layoutSubviews() {
        self.layoutIfNeeded()
//        self.layoutSkeletonIfNeeded()
//        lblTitle.skeletonCornerRadius = 5
//        viewReel.skeletonCornerRadius = 5
    }

}
