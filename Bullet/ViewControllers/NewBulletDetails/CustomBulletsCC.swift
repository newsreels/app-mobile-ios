//
//  CustomBulletsCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 12/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit


protocol CustomBulletsCCDelegate: class {
    func didTapViewFullArticle(cell: CustomBulletsCC)
}

class CustomBulletsCC: UITableViewCell {

    @IBOutlet weak var lblBullets: UILabel!
    @IBOutlet weak var constraintViewFullArticle: NSLayoutConstraint!
    @IBOutlet weak var viewFull: UIView!
    @IBOutlet weak var viewDot: UIView!
    @IBOutlet weak var lblFullArticle: UILabel!
    @IBOutlet weak var labelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblHeader: UILabel!
    var langCode = ""
    weak var delegate: CustomBulletsCCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblBullets.textColor = UIColor.black//Constant.appColor.mediumGray
//        lblBullets.theme_textColor = GlobalPicker.textBWColor
        viewFull.backgroundColor = Constant.appColor.lightRed
        viewDot.backgroundColor = UIColor.black
        //theme_backgroundColor = GlobalPicker.themeCommonColor
        
        lblBullets.font = SharedManager.shared.getBulletFont()
        lblHeader.theme_textColor = GlobalPicker.textBWColor
//        lblFullArticle.text = NSLocalizedString("View Full Article", comment: "")
        headerHeightConstraint.constant = 0
        
        lblHeader.font = SharedManager.shared.getTitleFont()
    }
    
    override func layoutSubviews() {
        
//        SharedManager.shared.getBulletFont()
        viewDot.layer.cornerRadius = viewDot.frame.size.width/2
        if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: langCode) {
            DispatchQueue.main.async {
                self.lblBullets.semanticContentAttribute = .forceRightToLeft
                self.lblBullets.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblBullets.semanticContentAttribute = .forceLeftToRight
                self.lblBullets.textAlignment = .left
            }
        }
    }
    
    override func prepareForReuse() {
        lblBullets.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func didTapViewFullArticle(_ sender: Any) {
        
        self.delegate?.didTapViewFullArticle(cell: self)
    }
    
    
    func setupCell(bullet: Bullets?, isShowFullArticle: Bool, isViewFullArticleNeeded: Bool, isNewsTextNeeded: Bool, articleData: articlesData?, index: Int, isTitleSameBullet: Bool) {
        
        
        if isShowFullArticle {
            constraintViewFullArticle.constant = 80
        } else {
            constraintViewFullArticle.constant = 0
        }
        
        if isNewsTextNeeded {
            labelTopConstraint.constant = 10
            lblBullets.text = bullet?.data ?? ""
            viewDot.isHidden = false
        }
        else {
            labelTopConstraint.constant = 0
            viewDot.isHidden = true
            lblBullets.text = ""
        }
        
        
        if isViewFullArticleNeeded {
            viewFull.isHidden = false
        } else {
            viewFull.isHidden = true
        }
            
            
        if articleData?.type == Constant.newsArticle.ARTICLE_TYPE_REEL || articleData?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
            
            lblFullArticle.text = NSLocalizedString("View Video Source", comment: "")
            
            headerHeightConstraint.constant = 0
            lblHeader.text = ""
            
            
        }
        else {
            lblFullArticle.text = NSLocalizedString("View Full Article", comment: "")
            
            if isTitleSameBullet == false {
                if index ==  1 && bullet != nil {
                    headerHeightConstraint.constant = 62
                    lblHeader.text = NSLocalizedString("Article summary", comment: "")
                }
                else {
                    headerHeightConstraint.constant = 0
                    lblHeader.text = ""
                }
            }
            else {
                if index ==  2 && bullet != nil {
                    headerHeightConstraint.constant = 62
                    lblHeader.text = NSLocalizedString("Article summary", comment: "")
                }
                else {
                    headerHeightConstraint.constant = 0
                    lblHeader.text = ""
                }
            }
            
        }
        
        self.layoutIfNeeded()
        self.updateConstraintsIfNeeded()
        
    }
    
}
