//
//  HeadlinesDiscoverCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 31/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class HeadlinesDiscoverCC: UICollectionViewCell {

    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var lblNews: UILabel!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var viewFooter: UIView!
    @IBOutlet weak var lblNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    func setupCell(model: articlesData, indexForNews: Int) {
        
        lblNews.text = model.title
        imgThumbnail.sd_setImage(with: URL(string: model.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))

        viewFooter.isHidden = false
        
        
        if model.source == nil {
            lblSource.text = model.source?.name ?? ""
            imgSource.sd_setImage(with: URL(string: model.authors?.first?.image ?? "") , placeholderImage: nil)
        } else {
            lblSource.text = model.source?.name ?? ""
            imgSource.sd_setImage(with: URL(string: model.source?.icon ?? "") , placeholderImage: nil)
        }
        
        lblTime.text = ""
        if let pubDate = model.publish_time {
            lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
        }
        
        lblNumber.text = ""
        lblNumber.text = "\(indexForNews + 1)"
    }

}
