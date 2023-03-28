//
//  HeadlineCC.swift
//  Bullet
//
//  Created by Mahesh on 18/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit


class HeadlineFooterCC: UICollectionViewCell {

    //PROPERTIES
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgBG: UIImageView!
    @IBOutlet weak var lblHeadline: UILabel!
    @IBOutlet weak var imgMark: UIImageView!
    
    @IBOutlet weak var btnAddTopic: UIButton!

    weak var delegateCell: HeadlineCCDelegate?

    var langCode = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblHeadline.textColor = .white
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: self.langCode) {
                self.lblHeadline.semanticContentAttribute = .forceRightToLeft
                self.lblHeadline.textAlignment = .right
            } else {
                self.lblHeadline.semanticContentAttribute = .forceLeftToRight
                self.lblHeadline.textAlignment = .left
            }
        }
        
        
    }
    
    
    
    
    func setupCell(model: articlesData) {
        
        lblHeadline.text = model.title
        let isFollow = model.followed ?? false

        if SharedManager.shared.readerMode {
            viewBG.theme_backgroundColor = GlobalPicker.viewHeadlineBgColor
            imgBG.isHidden = true
            lblHeadline.theme_textColor = GlobalPicker.textBWColor
            imgMark.theme_image = GlobalPicker.unSelectedTickMarkImage
        }
        else {

            imgBG.isHidden = false
            imgBG.sd_setImage(with: URL(string: model.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            imgMark.image = UIImage(named: isFollow ? "tickUnselected" : "plus")
        }
        
    }
    

//    @IBAction func didTapAddTopic(_ sender: UIButton) {
//
//        self.delegateCell?.didTapSourceHorizontal(self)
//    }
}

