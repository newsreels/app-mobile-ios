//
//  HeadlineCC.swift
//  Bullet
//
//  Created by Mahesh on 18/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

public protocol HeadlineCCDelegate: AnyObject {
    
    func didTapSourceHorizontal(_ cell: UICollectionViewCell)
}

class HeadlineCC: UICollectionViewCell {

    //PROPERTIES
    @IBOutlet weak var viewImgBG: UIView!
    @IBOutlet weak var imgBG: UIImageView!
    @IBOutlet weak var lblHeadline: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblReaderHeadline: UILabel!

    //Footer View
    @IBOutlet weak var viewFooter: UIView!
//    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var imgSource: UIImageView!

    @IBOutlet weak var viewFooter1: UIView!
//    @IBOutlet weak var lblTime1: UILabel!
    @IBOutlet weak var imgSource1: UIImageView!
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    weak var delegateCell: HeadlineCCDelegate?
    
    var langCode = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgSource.cornerRadius = imgSource.frame.height / 2
        lblHeadline.theme_textColor = GlobalPicker.textColor
        lblReaderHeadline.theme_textColor = GlobalPicker.textColor

//        lblTime.theme_textColor = GlobalPicker.textForYouSubTextSubColor
//        lblTime.theme_textColor = GlobalPicker.textSourceColor
        lblSource.theme_textColor = GlobalPicker.textBWColor
        
//        if SharedManager.shared.readerMode {
//            viewContainer.theme_backgroundColor = GlobalPicker.viewHeadlineBgColor
//        }
//        else {
//            viewContainer.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
//        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            lblHeadline.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 19)
            lblReaderHeadline.font = UIFont(name: Constant.FONT_Mulli_Semibold, size: 19)
        }
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: self.langCode) {
                self.lblSource.semanticContentAttribute = .forceRightToLeft
                self.lblSource.textAlignment = .right
                self.lblHeadline.semanticContentAttribute = .forceRightToLeft
                self.lblHeadline.textAlignment = .right
//                self.lblTime.semanticContentAttribute = .forceRightToLeft
//                self.lblTime.textAlignment = .right
            } else {
                self.lblSource.semanticContentAttribute = .forceLeftToRight
                self.lblSource.textAlignment = .left
                self.lblHeadline.semanticContentAttribute = .forceLeftToRight
                self.lblHeadline.textAlignment = .left
//                self.lblTime.semanticContentAttribute = .forceLeftToRight
//                self.lblTime.textAlignment = .left
            }
        }
        
        
    }
    
    
    func setForceDarkUI() {
        
        lblHeadline.textColor = .white
//        lblTime.textColor = "#84838B".hexStringToUIColor()
        lblSource.textColor = .white
        
        viewContainer.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
    }
    
    func setupCell(model: articlesData, alwaysDark: Bool) {
        
        if SharedManager.shared.readerMode && !alwaysDark {
            
            viewImgBG.isHidden = true
            lblHeadline.isHidden = true
            lblReaderHeadline.isHidden = false
            lblReaderHeadline.text = model.title
            
            viewContainer.theme_backgroundColor = GlobalPicker.viewHeadlineBgColor
            
            if imageHeightConstraint != nil {
                imageHeightConstraint.isActive = false
            }
        }
        else {
            
            lblReaderHeadline.isHidden = true
            lblHeadline.isHidden = false
            viewImgBG.isHidden = false
            lblHeadline.text = model.title
            viewContainer.backgroundColor = .clear
            
            imgBG.sd_setImage(with: URL(string: model.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            
            imageHeightConstraint.isActive = true
        }

        //Check source image or text
        if let imgUrl = model.source?.name_image, !imgUrl.isEmpty {
            
            viewFooter.isHidden = true
            viewFooter1.isHidden = false
            
            imgSource1.sd_setImage(with: URL(string: imgUrl), placeholderImage: nil)
//            lblTime1.text = SharedManager.shared.generateDatTimeOfNews(model.publish_time ?? "").lowercased()
//            lblTime1.addTextSpacing(spacing: 0.5)
        }
        else {
            
            viewFooter.isHidden = false
            viewFooter1.isHidden = true
            
            imgSource.sd_setImage(with: URL(string: model.source?.icon ?? ""), placeholderImage: nil)

            lblSource.text = model.source?.name
            lblSource.addTextSpacing(spacing: 2.0)
            
//            lblTime.text = SharedManager.shared.generateDatTimeOfNews(model.publish_time ?? "").lowercased()
//            lblTime.addTextSpacing(spacing: 0.5)
        }
        
        if alwaysDark {
            setForceDarkUI()
        }
    }
    
    
    @IBAction func didTapSource(_ sender: UIButton) {
        
        self.delegateCell?.didTapSourceHorizontal(self)
    }
}

