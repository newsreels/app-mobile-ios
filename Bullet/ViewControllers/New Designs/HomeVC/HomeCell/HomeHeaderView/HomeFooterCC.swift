//
//  HomeFooterCC.swift
//  Bullet
//
//  Created by Mahesh on 14/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

let FOOTER_HOME_CC                = "HomeFooterCC"

import UIKit
import SwiftTheme

class HomeFooterCC: UITableViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var lblFooterName: UILabel!
    @IBOutlet weak var lblPrefix: UILabel!
    @IBOutlet weak var viewPadding: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        lblFooterName.textColor = Constant.appColor.purple
        //viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        
        let lightImage = UIImage(named: "tbFrowordArrow")?.sd_tintedImage(with: Constant.appColor.blue)
        let darkImage = UIImage(named: "tbFrowordArrow")?.sd_tintedImage(with: Constant.appColor.purple)
        let colorImage = ThemeImagePicker(images: lightImage!,darkImage!)
        
        imgArrow.theme_image = colorImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL() {
                self.imgArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
            } else {
                self.imgArrow.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            self.imgArrow.layoutIfNeeded()
        }
    }
    
    func setCell(_ content: articlesData?) {
        
        if content?.subType == Constant.newsArticle.ARTICLE_TYPE_CAROUSEL_VIDEOS || content?.subType == Constant.newsArticle.ARTICLE_TYPE_LARGE_REEL {
            self.backgroundColor = .black
            lblPrefix.textColor = .white
        }
        else {
            lblPrefix.theme_textColor = GlobalPicker.textColor
            self.backgroundColor = .clear
        }
    }
}
