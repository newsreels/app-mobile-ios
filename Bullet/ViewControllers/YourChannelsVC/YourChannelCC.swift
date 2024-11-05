//
//  YourChannelCC.swift
//  Bullet
//
//  Created by Mahesh on 07/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class YourChannelCC: UICollectionViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgChannel: UIImageView!
    
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var imgEdge: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        imgEdge.image = UIImage(named: "icn_home_edge")?.withRenderingMode(.alwaysTemplate)
        imgEdge.tintColor = .white
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL() {
                self.imgEdge.transform = CGAffineTransform(scaleX: -1, y: 1)
            } else {
                self.imgEdge.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            self.imgEdge.layoutIfNeeded()
        }
    }    
    
    func setupCell(model: ChannelInfo) {
        
        let url = model.portrait_image ?? model.image ?? ""
        imgChannel.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        
        //Check source image or text
        if let imgUrl = model.name_image, !imgUrl.isEmpty {
            
            lblSource.isHidden = true
            imgSource.isHidden = false
            imgSource.sd_setImage(with: URL(string: imgUrl) , placeholderImage: nil)
        }
        else {
            
            lblSource.isHidden = false
            imgSource.isHidden = true
            lblSource.text = model.name
        }
    }
}

