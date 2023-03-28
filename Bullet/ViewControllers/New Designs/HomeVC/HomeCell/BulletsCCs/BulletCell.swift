//
//  BulletCell.swift
//  Bullet
//
//  Created by Mahesh on 16/09/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

internal let CELL_PADDING: CGFloat                  = 10
internal let CELL_IDENTIFIER_BULLET                 = "BulletCell"
internal let CELL_IDENTIFIER_LIST_BULLET            = "BulletListCell"
internal let CELL_IDENTIFIER_NO_IMG_LIST            = "BulletListCellWithoutImg"

//FOR LIST VIEW
class BulletListCell: UICollectionViewCell {
    
    @IBOutlet weak var lblBullet: UILabel!
    @IBOutlet weak var viewImgBG: UIView!
    @IBOutlet weak var imgBG: UIImageView!
    @IBOutlet weak var lblBulletTrailingConstraint: NSLayoutConstraint!
    
    var langCode = ""
    var item: String = "" {
        didSet {
            
            lblBullet.text = item
//            lblBullet.setLineSpacing(lineSpacing: 1)
//            lblBullet.invalidateIntrinsicContentSize()
//            invalidateIntrinsicContentSize()
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        layoutSubviews()
    }
    
    override func prepareForReuse() {
        lblBullet.text = ""
        imgBG.image = nil
    }
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.layoutIfNeeded()
        
        lblBullet.sizeToFit()
        
        
        if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: langCode) {
            DispatchQueue.main.async {
                self.lblBullet.semanticContentAttribute = .forceRightToLeft
                if self.viewImgBG != nil {
                    self.viewImgBG.semanticContentAttribute = .forceRightToLeft
                }
                self.lblBullet.textAlignment = .right
                
                
                // Check app language, and set leading
                if self.lblBulletTrailingConstraint != nil {
                    self.lblBulletTrailingConstraint.constant = SharedManager.shared.getBulletListLabelTrailing(selectedLanguage: self.langCode)
                }
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.lblBullet.semanticContentAttribute = .forceLeftToRight
                if self.viewImgBG != nil {
                    self.viewImgBG.semanticContentAttribute = .forceLeftToRight
                }
                self.lblBullet.textAlignment = .left
                
                // Check app language, and set leading
                // Check app language, and set leading
                if self.lblBulletTrailingConstraint != nil {
                    self.lblBulletTrailingConstraint.constant = SharedManager.shared.getBulletListLabelTrailing(selectedLanguage: nil)
                }
            }
        }
    }
    
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        if item.count == 0 {
//            return CGSize.zero
//        }
//
//        return intrinsicContentSize
//    }
}

//FOR LIST VIEW
class BulletListCellWithoutImg: UICollectionViewCell {
    
    @IBOutlet weak var lblBullet: UILabel!
    
    var langCode = ""
    var item: String = "" {
        didSet {
            
            lblBullet.text = item
//            lblBullet.invalidateIntrinsicContentSize()
//            invalidateIntrinsicContentSize()
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.layoutIfNeeded()
        
        lblBullet.sizeToFit()
        
        if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: langCode) {
            
            DispatchQueue.main.async {
                self.lblBullet.semanticContentAttribute = .forceRightToLeft
                self.lblBullet.textAlignment = .right
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.lblBullet.semanticContentAttribute = .forceLeftToRight
                self.lblBullet.textAlignment = .left
            }
        }
        
    }
    
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        if item.count == 0 {
//            return CGSize.zero
//        }
//
//        return intrinsicContentSize
//    }
}



//FOR EXTENDED VIEW
class BulletCell: UICollectionViewCell {
    
    @IBOutlet weak var lblBullet: UILabel!
    
    var langCode = ""
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.layoutIfNeeded()
        
        if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: langCode) {
            DispatchQueue.main.async {
                self.lblBullet.semanticContentAttribute = .forceRightToLeft
                self.lblBullet.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblBullet.semanticContentAttribute = .forceLeftToRight
                self.lblBullet.textAlignment = .left
            }
        }
    }
    
    func configCell(bullet: String, titleFont: UIFont) {
        
        lblBullet.text = bullet
        lblBullet.font = titleFont
        
        lblBullet.theme_textColor = GlobalPicker.textBWColor
        //            cell.lblBullet.setLineSpacing(lineSpacing: 5)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

}

