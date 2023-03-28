//
//  CategoryCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 05/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class CategoryCC: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var menuImageView: UIImageView!
    
    var shadowLayer: CAShapeLayer?
    
    var cellCornerRadius: CGFloat = 10
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    
    override func layoutSubviews() {
        
        backView.layer.cornerRadius = backView.frame.size.height/4
        
        containerView.layer.cornerRadius = containerView.frame.size.height/4
        
        shadowView.layer.cornerRadius =  shadowView.frame.size.height/4
//        containerView.addRoundedShadowPref()
        
        menuImageView.layer.cornerRadius = menuImageView.frame.size.height/2
        
        
        setupShadow()
    }
    
    public func setupShadow() {
        
        let radius = shadowView.frame.size.height/2
        
        // border radius
//        shadowView.layer.cornerRadius = radius
        
        // border
//        shadowView.layer.borderColor = UIColor.lightGray.cgColor
//        shadowView.layer.borderWidth = 2
        
        // drop shadow
//        shadowView.layer.shadowColor = UIColor.black.cgColor
//        shadowView.layer.shadowOpacity = 0.5
//        shadowView.layer.shadowRadius = 2.0
//        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
//
//        self.shadowView.layer.cornerRadius = radius
//        self.shadowView.layer.shadowColor = UIColor.black.cgColor
//        self.shadowView.layer.shadowOpacity = 0.8
//        self.shadowView.layer.shadowOffset = CGSize(width: 3, height: 3)
//        self.shadowView.layer.shadowRadius = 5
//        self.shadowView.layer.masksToBounds = false
        
        self.shadowView.layer.masksToBounds = false
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.shadowView.layer.shadowColor =  UIColor.lightGray.cgColor
        self.shadowView.layer.shadowRadius = 2
        self.shadowView.layer.shadowOpacity = 0.25

//        let backgroundCGColor = UIColor.black.cgColor
        self.shadowView.layer.backgroundColor =  UIColor.white.cgColor
    
        
    }
    
    
    
    func setupCell(title: String?, image: String,userSelected: Bool) {
        
        menuImageView.image = nil
        menuImageView.sd_setImage(with: URL(string: image), placeholderImage: nil)

        
        titleLabel.text = title ?? ""
        
        menuImageView.backgroundColor = Constant.appColor.lightGray
        
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        if userSelected {
            titleLabel.textColor = Constant.appColor.lightRed//.black
            //UIFont(name: Constant.FONT_ROBOTO_MEDIUM, size: 16)
//            containerView.layer.borderColor = Constant.appColor.lightRed.cgColor//UIColor.black.cgColor
//
//            containerView.layer.borderWidth = 0.5
        }
        else {
            
//            titleLabel.font = UIFont(name: Constant.FONT_ROBOTO_MEDIUM, size: 16)
            titleLabel.textColor = UIColor.black//UIColor.lightGray
//            containerView.layer.borderColor = UIColor.black.cgColor//UIColor.lightGray.cgColor
//
//            containerView.layer.borderWidth = 0.3
        }
    }
    
    func setupCellForTopics(title: String?, image: String,userSelected: Bool) {
        
        menuImageView.image = nil
        menuImageView.sd_setImage(with: URL(string: image), placeholderImage: nil)

        
        titleLabel.text = title ?? ""
        
        menuImageView.backgroundColor = Constant.appColor.lightGray
        
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        if userSelected {
            titleLabel.textColor = .white
            backView.backgroundColor = Constant.appColor.lightRed
        }
        else {
            
            titleLabel.textColor = UIColor.black
            backView.backgroundColor = .white
        }
    }
    
}
