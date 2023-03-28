//
//  userTopicCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 22/06/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class userTopicCC: UITableViewCell {

    @IBOutlet weak var lblTopic: UILabel!
    @IBOutlet weak var imgTopic: UIImageView!
    @IBOutlet weak var imgTopicState: UIImageView!
    
    @IBOutlet weak var btnSelectTopic: UIButton!
    
    @IBOutlet weak var constraintCategoryIconHeight: NSLayoutConstraint!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}


class searchTopicCell: UICollectionViewCell {
    
    @IBOutlet weak var imgTopic: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imgTopicStatus: UIImageView!
    @IBOutlet weak var btnSelectTopic: UIButton!
    
    @IBOutlet weak var imgMore: UIImageView!
    @IBOutlet weak var btnMore: UIButton!
    
    override func layoutSubviews() {

        super.layoutSubviews()
    }
}
