//
//  sugChannelCC.swift
//  Bullet
//
//  Created by Mahesh on 07/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol sugChannelCCDelegate: AnyObject {
    
    func addChannelTapped(cell: sugChannelCC)
}

class sugChannelCC: UICollectionViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgChannel: UIImageView!
    
    @IBOutlet weak var imgPlusMark: UIImageView!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var imgEdge: UIImageView!
    @IBOutlet weak var viewSourceBG: UIView!
    @IBOutlet weak var btnChannelTap: UIButton!
    @IBOutlet weak var btnFollowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var channelButtonPressedBlock: (() -> Void)?
    weak var delegate: sugChannelCCDelegate?

    var langCode = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        imgProfile.layer.cornerRadius = imgProfile.frame.height / 2
//        imgProfile.borderWidth = 2
//        imgProfile.borderColor = UIColor.white

//        viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
//        viewBG.addRoundedShadowCell()
        
        imgEdge.image = UIImage(named: "icn_home_edge")?.withRenderingMode(.alwaysTemplate)
        imgEdge.tintColor = .white
        activityLoader.stopAnimating()
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

        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: self.langCode) {
                self.lblSource.semanticContentAttribute = .forceRightToLeft
                self.lblSource.textAlignment = .right
            } else {
                self.lblSource.semanticContentAttribute = .forceLeftToRight
                self.lblSource.textAlignment = .left
            }
        }
    }
    
    func setupCell(model: ChannelInfo) {
        
        let url = model.portrait_image ?? model.image ?? ""
        imgChannel.sd_setImage(with: URL(string: url) , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        
        let fav = model.favorite ?? false
        if fav {
            imgPlusMark.image = UIImage(named: "tick_dark")
        }
        else {
            imgPlusMark.image = UIImage(named: "plus_dark")
        }

        //Check source image or text
        if let imgUrl = model.name_image, !imgUrl.isEmpty {
            
            lblSource.isHidden = true
            viewSourceBG.isHidden = false
            imgSource.sd_setImage(with: URL(string: imgUrl), placeholderImage: nil)
        }
        else {
            
            lblSource.isHidden = false
            viewSourceBG.isHidden = true
            lblSource.text = model.name
            lblSource.textColor = .black
            //lblSource.theme_textColor = GlobalPicker.textBWColor
        }
        
        if (model.own ?? false) {
            btnChannelTap.isHidden = true
            imgPlusMark.isHidden = true
            btnFollowHeightConstraint.constant = 0
        } else {
            btnChannelTap.isHidden = false
            imgPlusMark.isHidden = false
            btnFollowHeightConstraint.constant = 15
        }
        
    }
    
    func setupCellSourceModel(model: ChannelInfo) {
        
        let url = model.portrait_image ?? model.image ?? ""
        imgChannel.sd_setImage(with: URL(string: url) , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        
        let fav = model.favorite ?? false
        if fav {
            imgPlusMark.image = UIImage(named: "tick_dark")
        }
        else {
            imgPlusMark.image = UIImage(named: "plus_dark")
        }

        //Check source image or text
        if let imgUrl = model.name_image, !imgUrl.isEmpty {
            
            lblSource.isHidden = true
            viewSourceBG.isHidden = false
            imgSource.sd_setImage(with: URL(string: imgUrl), placeholderImage: nil)
        }
        else {
            
            lblSource.isHidden = false
            viewSourceBG.isHidden = true
            lblSource.text = model.name
            lblSource.textColor = .black
            //lblSource.theme_textColor = GlobalPicker.textBWColor
        }
        
        if model.favorite ?? false {
            imgPlusMark.image = UIImage(named: "tick_dark")
        } else {
            imgPlusMark.image = UIImage(named: "plus_dark")
        }
    }
    
    @IBAction func didTapChannel(_ button: UIButton) {
        channelButtonPressedBlock?()
        self.delegate?.addChannelTapped(cell: self)
    }

    func setupCell() {
        
        lblSource.isHidden = false
        viewSourceBG.isHidden = true
        lblSource.text = "Test"
    }

}

