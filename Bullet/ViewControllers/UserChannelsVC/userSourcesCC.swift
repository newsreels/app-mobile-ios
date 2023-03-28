//
//  userSourcesCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 23/06/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class userSourcesCC: UICollectionViewCell {
    
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var imgSourceStatus: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSelectSource: UIButton!
    
    @IBOutlet weak var imgSingleDot: UIImageView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!
    
    @IBOutlet weak var imgMore: UIImageView!
    @IBOutlet weak var btnMore: UIButton!
    
    override func layoutSubviews() {

        super.layoutSubviews()
        
    }
}


//MARK:- HEADER VIEW FOR COLLECTION --- SEARCH TOPIC--CHANNELS

class sourceHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()

        lblTitle.theme_textColor = GlobalPicker.textColor
    }
    
}

//MARK:- FOOTER VIEW FOR COLLECTION --- SEARCH TOPIC--CHANNELS

class sourceFooterCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewLineSaperator: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()

        lblTitle.text = NSLocalizedString("Suggested", comment: "")
        lblTitle.theme_textColor = GlobalPicker.textColor
    }
}

//MARK:- CELL FOR COLLECTION --- CHANNELS

class searchChannelCC: UICollectionViewCell {
    
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var imgSourceStatus: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSelectSource: UIButton!
    
    @IBOutlet weak var imgMore: UIImageView!
    @IBOutlet weak var btnMore: UIButton!
    
    @IBOutlet weak var imgSingleDot: UIImageView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!

    override func layoutSubviews() {

        super.layoutSubviews()

    //    viewShadow.roundCorners([.bottomLeft, .bottomRight], 8)
//        imgSingleDot.theme_image = GlobalPicker.imgSingleDot
//        lblLocation.theme_textColor = GlobalPicker.textColor
//        lblLanguage.theme_textColor = GlobalPicker.textColor
    }
}


class MyHeader: UICollectionReusableView {
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 20)
        label.theme_textColor = GlobalPicker.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    public func configure(_ title: String) {
        backgroundColor = .clear
        addSubview(label)
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.text = title
    }
}
