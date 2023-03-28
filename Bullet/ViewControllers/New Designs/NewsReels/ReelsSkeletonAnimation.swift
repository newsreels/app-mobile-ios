//
//  ReelsSkeletonAnimation.swift
//  Bullet
//
//  Created by Faris Muhammed on 19/09/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import ActiveLabel
import Skeleton


class ReelsSkeletonAnimation: UICollectionViewCell {
    
    
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var circularView: GMView!
//    var viewAnimation: AppLoaderView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        showLoader()
    }

    override func prepareForReuse() {
        hideLaoder()
    }
    
    
    override func layoutSubviews() {
        
    }
    
    func showLoader() {
        
        DispatchQueue.main.async {
            self.circularView.startLoading()
        }
        
    }
    
    func hideLaoder() {
        
        DispatchQueue.main.async {
            self.circularView.stopAnimations()
        }
        
    }
    
    
}


