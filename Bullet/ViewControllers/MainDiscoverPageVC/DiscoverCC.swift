//
//  DiscoverCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 07/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class DiscoverCC: UICollectionViewCell {
    
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var viewTopicShadow: UIView!
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var imgSourceStatus: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSelectSource: UIButton!
    
    
    @IBOutlet weak var lblTopic: UILabel!
    @IBOutlet weak var imgTopic: UIImageView!
    @IBOutlet weak var imgTopicState: UIImageView!
    @IBOutlet weak var btnSelectTopic: UIButton!

    @IBOutlet weak var imgDot: UIImageView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!

         
    var isFav = false
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
       
        if self.viewShadow != nil {

            viewShadow.clipsToBounds = true
            viewShadow.layer.cornerRadius = 8
            viewShadow.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

            viewShadow.layer.shadowColor = UIColor.black.cgColor
            viewShadow.layer.shadowOffset = CGSize(width: 1, height: 1)
            viewShadow.layer.shadowOpacity = 0.7
            viewShadow.layer.shadowRadius = 8

        }
//        
//        if self.viewTopicShadow != nil {
//
//            self.viewTopicShadow.addRoundedShadowWithColor(color: MyThemes.current == .dark ? UIColor.clear : UIColor(displayP3Red: 58.0/255.0, green: 217.0/255.0, blue: 210.0/255.0, alpha: 0.50))
//        }
    }
}
