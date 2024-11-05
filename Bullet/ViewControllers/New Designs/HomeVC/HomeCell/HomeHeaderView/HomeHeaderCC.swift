//
//  HomeHeaderCC.swift
//  Bullet
//
//  Created by Mahesh on 14/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

let HEADER_HOME_CC                = "HomeHeaderCC"

import UIKit

class HomeHeaderCC: UITableViewCell {

  //  @IBOutlet weak var viewTitleBG: UIView!
  //  @IBOutlet weak var imgEdge: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubheader: UILabel!
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var backgrView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        lblTitle.theme_textColor = GlobalPicker.textColor
//        lblSubheader.theme_textColor = GlobalPicker.textSubColor
        
        
//        lblTitle.theme_textColor = GlobalPicker.textBWColor
//        lblSubheader.theme_textColor = GlobalPicker.textBWColor
        
        lblTitle.textColor = Constant.appColor.lightRed
        lblSubheader.textColor = Constant.appColor.lightRed
        
        
        //.theme_textColor = GlobalPicker.textSubColor
        
      //  viewTitleBG.theme_backgroundColor = GlobalPicker.themeCommonColor
        
      //  imgEdge.image = UIImage(named: "icn_home_edge")?.withRenderingMode(.alwaysTemplate)
      //  imgEdge.theme_tintColor = GlobalPicker.themeCommonColor
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        DispatchQueue.main.async {
//            if SharedManager.shared.isSelectedLanguageRTL() {
//                self.imgEdge.transform = CGAffineTransform(scaleX: -1, y: 1)
//            } else {
//                self.imgEdge.transform = CGAffineTransform(scaleX: 1, y: 1)
//            }
//            self.imgEdge.layoutIfNeeded()
//        }

        DispatchQueue.main.async {
            self.lblTitle.font =  SharedManager.shared.getHeaderTitleFont()
        }
    }
    
}
