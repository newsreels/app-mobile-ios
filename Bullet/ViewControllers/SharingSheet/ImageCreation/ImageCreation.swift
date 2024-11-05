//
//  ImageCreation.swift
//  Bullet
//
//  Created by Khadim Hussain on 06/09/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ImageCreation: UIView {
    
    @IBOutlet weak var viewChannel: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblHeadline: UILabel!
    
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var imgLogo: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func createImage(article: articlesData) -> UIImage {
        
        if let source = article.source?.name {
            
            self.lblSource.text = source
        }
        else {
            
            self.lblSource.text = article.authors?.first?.name ?? ""
        }
        self.lblHeadline.text = article.title ?? ""
    
        imgNews.sd_setImage(with: URL(string: article.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        self.lblSource.sizeToFit()
        self.layoutIfNeeded()
        return viewContainer.getImage()
        
    }
}
