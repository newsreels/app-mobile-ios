//
//  HomeSkeltonListCell.swift
//  Bullet
//
//  Created by Faris Muhammed on 23/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Skeleton


class HomeSkeltonListCell: UITableViewCell {

    @IBOutlet weak var viewNews: GradientContainerView!
    
    @IBOutlet weak var viewTitle1: GradientContainerView!
    @IBOutlet weak var viewTitle2: GradientContainerView!
    @IBOutlet weak var viewTitle3: GradientContainerView!

    @IBOutlet weak var viewSubTitle1: GradientContainerView!
    @IBOutlet weak var viewSubTitle2: GradientContainerView!
    
    @IBOutlet weak var viewSub: GradientContainerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func layoutSubviews() {
        
        viewNews.layer.cornerRadius = 5
        viewTitle1.layer.cornerRadius = 5
        viewTitle2.layer.cornerRadius = 5
        viewTitle3.layer.cornerRadius = 5
        viewSubTitle1.layer.cornerRadius = 5
        viewSubTitle2.layer.cornerRadius = 5
        
        viewSub.layer.cornerRadius =  viewSub.frame.size.width/2
        
        viewNews.clipsToBounds = true
        viewTitle1.clipsToBounds = true
        viewTitle2.clipsToBounds = true
        viewTitle3.clipsToBounds = true
        viewSubTitle1.clipsToBounds = true
        viewSubTitle2.clipsToBounds = true
        viewSub.clipsToBounds = true
        
    }
    
}


extension HomeSkeltonListCell: GradientsOwner {
  var gradientLayers: [CAGradientLayer] {
    return [
        viewNews.gradientLayer,
        viewTitle1.gradientLayer,
        viewTitle2.gradientLayer,
        viewTitle3.gradientLayer,
        viewSubTitle1.gradientLayer,
        viewSubTitle2.gradientLayer,
        viewSub.gradientLayer
    ]
  }
}

