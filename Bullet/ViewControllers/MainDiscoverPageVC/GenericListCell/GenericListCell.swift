//
//  GenericListCell.swift
//  Bullet
//
//  Created by Khadim Hussain on 12/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import IQKeyboardManagerSwift

class GenericListCell: UITableViewCell {
    
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSource: UIButton!
    
    @IBOutlet weak var imgDot: UIImageView!
    @IBOutlet weak var imgWifi: UIImageView!
    @IBOutlet weak var imgSource: UIImageView!
    
    @IBOutlet weak var lblBullet: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var viewDot: UIView!

    @IBOutlet weak var viewSeperatorLine: UIView!
    
    @IBOutlet weak var viewComment: UIView!
    @IBOutlet weak var viewLike: UIView!
    @IBOutlet weak var lblCommentsCount: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var imgComment: UIImageView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblTrailingConstant: NSLayoutConstraint!
    
    weak var delegateLikeComment: LikeCommentDelegate?
    var langCode = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.imgWifi.theme_image = GlobalPicker.imgWifi
        self.lblTime.theme_textColor = GlobalPicker.textSourceColor
        self.lblSource.theme_textColor = GlobalPicker.textSourceColor
        self.lblBullet.theme_textColor = GlobalPicker.textBWColor
        self.viewSeperatorLine.theme_backgroundColor = GlobalPicker.viewSeperatorListColor
        self.selectionStyle = .none
        self.lblAuthor.theme_textColor = GlobalPicker.textForYouSubTextSubColor
        
        imgWifi.cornerRadius = imgWifi.frame.height / 2

    }

    
    override func layoutSubviews() {
        
        imgDot.theme_image = GlobalPicker.imgSingleDot
        
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
    
    func setLikeComment(model: Info?) {
        
        if model?.isLiked ?? false {
            //viewLike.theme_backgroundColor = GlobalPicker.themeCommonColor
            imgLike.theme_image = GlobalPicker.likedImage
            lblLikeCount.theme_textColor = GlobalPicker.likeCountColor
        } else {
            //self.viewLike.theme_backgroundColor = GlobalPicker.viewCountColor
            imgLike.theme_image = GlobalPicker.likeDefaultImage
            lblLikeCount.textColor = .gray
        }
        //self.viewComment.theme_backgroundColor = GlobalPicker.viewCountColor
        imgComment.theme_image = GlobalPicker.commentDefaultImage
        lblCommentsCount.textColor = .gray
        lblLikeCount.minimumScaleFactor = 0.5
        lblCommentsCount.minimumScaleFactor = 0.5
        lblLikeCount.text = SharedManager.shared.formatPoints(num: Double((model?.likeCount ?? 0)))
        lblCommentsCount.text = SharedManager.shared.formatPoints(num: Double((model?.commentCount ?? 0)))
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            lblLikeCount.textAlignment = .right
            lblCommentsCount.textAlignment = .right
        } else {
            lblLikeCount.textAlignment = .left
            lblCommentsCount.textAlignment = .left
        }
        
    }
    
    func setupCell(model: articlesData?, isOpenFromTopNews: Bool) {
        
        if isOpenFromTopNews {
            self.viewBackground.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
            viewSeperatorLine.isHidden = true
        } else {
            self.viewBackground.backgroundColor = .clear
            viewSeperatorLine.isHidden = false
        }
        langCode = model?.language ?? ""
        
        lblTrailingConstant.constant = SharedManager.shared.getBulletListLabelTrailing(selectedLanguage: langCode)
        self.lblBullet.font = SharedManager.shared.getListViewTitleFont()
        self.lblBullet.text = model?.title ?? ""
        
        lblAuthor.text = model?.authors?.first?.username ?? model?.authors?.first?.name ?? ""
        imgWifi?.sd_setImage(with: URL(string: model?.source?.icon ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        if let source = model?.source {
            
            lblSource.text = source.name?.capitalized
        }
        else {
            
            lblSource.text = model?.authors?.first?.username ?? ""
        }
        
        let author = model?.authors?.first?.username ?? model?.authors?.first?.name ?? ""
        let source = model?.source?.name ?? ""
        
        viewDot.clipsToBounds = false
        if author == source || author == "" {
            lblAuthor.isHidden = true
            viewDot.isHidden = true
            viewDot.clipsToBounds = true
            lblSource.text = source
        }
        else {
            lblSource.text = source
            lblAuthor.text = author
            
            if source == "" {
                lblAuthor.isHidden = true
                viewDot.isHidden = true
                viewDot.clipsToBounds = true
                lblSource.text = author
            }
        }
        
        if let pubDate = model?.publish_time {
            lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
        }
//                youtubeCell.lblTime.addTextSpacing(spacing: 1.25)
        
        
//        self.lblSource.text = model?.source?.name ?? ""
//        if let pubDate = model?.publish_time {
//            self.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate)
//        }
//        let sourceURL = model?.source?.icon ?? ""
//        self.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
       
        let url = model?.image ?? ""
        self.imgSource?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))

        setLikeComment(model: model?.info)
        
    }
    
    @IBAction func didTapLikeButton(_ sender: Any) {
        self.delegateLikeComment?.didTapLikeButton(cell: self)
    }
    
    @IBAction func didTapCommentButton(_ sender: Any) {
        self.delegateLikeComment?.didTapCommentsButton(cell: self)
    }
    
}
