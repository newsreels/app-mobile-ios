//
//  CustomSectionHeader.swift
//  CustomSectionHeader
//
//  Created by Onur Tuna on 12.02.2019.
//  Copyright © 2019 onurtuna. All rights reserved.
//

import UIKit


protocol ReplyViewHeaderDelegate: class {
    func didTapHeaderReplyButton(header: ReplyViewHeader)
}

class ReplyViewHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblReply: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewUnderLine: UIView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblReplyText: UILabel!
    @IBOutlet weak var viewLine1: UIView!
    @IBOutlet weak var viewLine2: UIView!
    @IBOutlet weak var imgCurve: UIImageView!
    
    
    
    weak var delegate: ReplyViewHeaderDelegate?
    var section: Int = 0
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
//        self.viewBackground.theme_backgroundColor = GlobalPicker.commentCellBGColor
//        self.lblName.theme_textColor = GlobalPicker.commentVCTitleColor
//        self.lblReply.theme_textColor = GlobalPicker.commentTextViewTextColor
//        self.lblTime.theme_textColor = GlobalPicker.commentTextViewTextColor
//        self.lblReplyText.theme_textColor = GlobalPicker.commentTextViewTextColor
        
        self.viewLine1.theme_backgroundColor = GlobalPicker.commentNestedLineColor
        self.viewLine2.theme_backgroundColor = GlobalPicker.commentNestedLineColor
        self.viewUnderLine.theme_backgroundColor = GlobalPicker.commentNestedLineColor
        self.imgCurve.theme_image = GlobalPicker.commentCurvedImage
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblName.semanticContentAttribute = .forceRightToLeft
                self.lblName.textAlignment = .right
                self.lblReply.semanticContentAttribute = .forceRightToLeft
                self.lblReply.textAlignment = .right
                
                self.imgCurve.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblName.semanticContentAttribute = .forceLeftToRight
                self.lblName.textAlignment = .left
                self.lblReply.semanticContentAttribute = .forceLeftToRight
                self.lblReply.textAlignment = .left
                
                self.imgCurve.transform = CGAffineTransform.identity
            }
        }
    }
    
    
    
    func setupHeader(model: Comment, section: Int, isLastComment: Bool) {
        
        self.section = section
        lblName.text = model.user?.name?.capitalized ?? ""
        
        lblReply.text = model.comment ?? ""
        
        if model.user?.image?.isEmpty ?? false {
            imgUser.theme_image = GlobalPicker.imgUserPlaceholder
        }
        else {
            imgUser.sd_setImage(with: URL(string: model.user?.image ?? "") , placeholderImage: nil)
        }
        
        
        if let publishDate = model.createdAt {
            lblTime.text = SharedManager.shared.generateDatTimeOfNewsShortType(publishDate)
        }
        
        if isLastComment {
            viewLine2.isHidden = true
            viewUnderLine.isHidden = true
        } else {
            viewLine2.isHidden = false
            
        }
        
        if (model.replies?.count ?? 0) > 0 {
            viewUnderLine.isHidden = false
        } else {
            viewUnderLine.isHidden = true
        }
    }
    
//    @IBAction func didTapReplyButton(_ sender: Any) {
//        self.delegate?.didTapHeaderReplyButton(header: self)
//    }
    
    @IBAction func didTapReplyButton(_ sender: Any) {
        self.delegate?.didTapHeaderReplyButton(header: self)
    }
    
}
