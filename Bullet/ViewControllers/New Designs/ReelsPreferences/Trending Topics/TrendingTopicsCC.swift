//
//  TrendingTopicsCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 22/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol TrendingTopicsCCDelegate: AnyObject {
    func didTapFollow(cell: TrendingTopicsCC)
}


class TrendingTopicsCC: UICollectionViewCell {

    @IBOutlet weak var tagimageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    weak var delegate: TrendingTopicsCCDelegate?
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var btnFollow: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        pinView.layer.cornerRadius =  pinView.frame.size.width/2
        pinView.backgroundColor = Constant.appColor.lightGray
    }

    
    
    
    func setupCellTopics(model: TopicData) {
        
        let fav = model.favorite ?? false
        tagimageView.image = nil
        if fav {
            tagimageView.image = UIImage(named: "TagIcon")
            pinView.backgroundColor = Constant.appColor.lightRed
        }
        else {
            tagimageView.image = UIImage(named: "TagIcon")
            pinView.backgroundColor = Constant.appColor.lightGray
        }
        
        if model.isShowingLoader ?? false {
            self.isUserInteractionEnabled = false
            btnFollow.showLoader()
        }
        else {
            self.isUserInteractionEnabled = true
            btnFollow.hideLoaderView()
        }
        
        
        titleLabel.text = model.name ?? ""
    }
    
    func setupCellLocations(model: Location) {
        
        let fav = model.favorite ?? false
        tagimageView.image = nil
        if fav {
            tagimageView.image = UIImage(named: "LocationPin")
            pinView.backgroundColor = Constant.appColor.lightRed
        }
        else {
            tagimageView.image = UIImage(named: "LocationPin")//LocationPinned
            pinView.backgroundColor = Constant.appColor.lightGray
        }
        
        if model.isShowingLoader ?? false {
            self.isUserInteractionEnabled = false
            btnFollow.showLoader()
        }
        else {
            self.isUserInteractionEnabled = true
            btnFollow.hideLoaderView()
        }
        
        
        titleLabel.text = model.name ?? ""
    }
    
    
    @IBAction func didTapFollow(_ sender: Any) {
        
        self.delegate?.didTapFollow(cell: self)
    }
    
}
