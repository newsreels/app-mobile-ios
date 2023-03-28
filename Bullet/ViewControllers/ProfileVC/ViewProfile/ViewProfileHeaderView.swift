//
//  ViewProfileHeaderView.swift
//  Bullet
//
//  Created by Mahesh on 27/06/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ViewProfileHeaderView: UIView {
    
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var viewProfileBG: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgBack: UIImageView!
    //@IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var imgUserVerified: UIImageView!
    
    @IBOutlet weak var lblFullname: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var imgDot: UIImageView!
    
    @IBOutlet weak var viewEdit: UIView!
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var btnCover: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var btnFollowers: UIButton!
    @IBOutlet weak var btnPosts: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = .cyan
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
