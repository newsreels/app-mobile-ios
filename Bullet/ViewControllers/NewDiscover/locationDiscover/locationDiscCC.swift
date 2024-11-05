//
//  locationDiscCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 01/09/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class locationDiscCC: UICollectionViewCell {

    @IBOutlet weak var imgPlace: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewGradient: UIView!
    let gradient = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

        gradient.frame = viewGradient.bounds
        gradient.colors = [UIColor.clear, UIColor.black.cgColor]

        viewGradient.layer.insertSublayer(gradient, at: 0)
        
    }

    
    override func layoutSubviews() {
        
        gradient.frame = viewGradient.bounds
    }
    
    func setupCell(model: Location?) {
        
        lblTitle.text = model?.name ?? ""
        imgPlace.sd_setImage(with: URL(string: model?.image ?? "") , placeholderImage: nil)
        
        
    }
    
    func setupChannelInfoCell(model: Location?) {
        
        lblTitle.text = model?.name ?? ""
        imgPlace.sd_setImage(with: URL(string: model?.image ?? "") , placeholderImage: nil)
        
    }
}
