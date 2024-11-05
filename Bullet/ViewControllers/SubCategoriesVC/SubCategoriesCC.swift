//
//  SubCategoriesCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 10/02/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit


class categoryHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var imgTitle: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
}

class SubCategoriesCC: UICollectionViewCell {
    
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblSourceVerticalSpaceConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblSource.textDropShadow()
    }
}

class SubCategoriesClvCC: UICollectionViewCell {
    
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        lblCategory.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 12)
        lblCategory.theme_textColor = GlobalPicker.textColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            lblCategory.textAlignment = .right
        }
        else {
            lblCategory.textAlignment = .left
        }
    }
}



