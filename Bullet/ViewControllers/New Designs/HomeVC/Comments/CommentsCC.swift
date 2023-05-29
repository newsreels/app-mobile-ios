//
//  CommentsCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 07/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit


protocol CommentsCCDelegate: class {
    
    func didTapTypeReply(cell: CommentsCC)
    func didTapOpenReply(cell: CommentsCC)
    
}

class CommentsCC: UITableViewCell {

    @IBOutlet weak var viewComment: UIView!
    @IBOutlet weak var viewMore: UIView!
    @IBOutlet weak var viewLine1: UIView!
    @IBOutlet weak var viewLine2: UIView!
    @IBOutlet weak var imgCurve1: UIImageView!
    @IBOutlet weak var imgCurve2: UIImageView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblReply: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserReply: UILabel!
    @IBOutlet weak var lblReplyUser: UILabel!
    @IBOutlet weak var lblMoreReply: UILabel!
    @IBOutlet weak var imgReplyUser: UIImageView!
    
    weak var delegate: CommentsCCDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.viewBackground.theme_backgroundColor = GlobalPicker.commentCellBGColor
//        self.lblUserName.theme_textColor = GlobalPicker.commentVCTitleColor
//        self.lblComment.theme_textColor = GlobalPicker.commentTextViewTextColor
//        self.lblReplyUser.theme_textColor = GlobalPicker.commentVCTitleColor
//        self.lblUserReply.theme_textColor = GlobalPicker.commentTextViewTextColor
//        self.viewLine1.theme_backgroundColor = GlobalPicker.commentNestedLineColor
//        self.viewLine2.theme_backgroundColor = GlobalPicker.commentNestedLineColor
//        self.imgCurve1.theme_image = GlobalPicker.commentCurvedImage
//        self.imgCurve2.theme_image = GlobalPicker.commentCurvedImage
    }
    

    override func prepareForReuse() {
        lblUserName.text = ""
        imgUser.image = nil
        
    }
    
    override func layoutSubviews() {
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblUserName.semanticContentAttribute = .forceRightToLeft
                self.lblUserName.textAlignment = .right
                self.lblComment.semanticContentAttribute = .forceRightToLeft
                self.lblComment.textAlignment = .right
                self.lblReply.semanticContentAttribute = .forceRightToLeft
                self.lblReply.textAlignment = .right
                self.lblMoreReply.semanticContentAttribute = .forceRightToLeft
                self.lblMoreReply.textAlignment = .right
                self.lblUserReply.semanticContentAttribute = .forceRightToLeft
                self.lblUserReply.textAlignment = .right
                self.imgCurve1.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.imgCurve2.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblUserName.semanticContentAttribute = .forceLeftToRight
                self.lblUserName.textAlignment = .left
                self.lblComment.semanticContentAttribute = .forceLeftToRight
                self.lblComment.textAlignment = .left
                self.lblReply.semanticContentAttribute = .forceLeftToRight
                self.lblReply.textAlignment = .left
                self.lblMoreReply.semanticContentAttribute = .forceLeftToRight
                self.lblMoreReply.textAlignment = .left
                self.lblUserReply.semanticContentAttribute = .forceLeftToRight
                self.lblUserReply.textAlignment = .left
                self.imgCurve1.transform = CGAffineTransform.identity
                self.imgCurve2.transform = CGAffineTransform.identity
            }
        }
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func setupCell(model: Comment) {
        
        
        lblUserName.text = model.user?.name?.capitalized ?? ""
        lblUserReply.text = model.replies?.first?.comment ?? ""
        
        if model.user?.image?.isEmpty ?? false {
            imgUser.theme_image = GlobalPicker.imgUserPlaceholder
        }
        else {
            imgUser.sd_setImage(with: URL(string: model.user?.image ?? "") , placeholderImage: nil)
        }
        
        
        
        lblComment.text = model.comment ?? ""
//        if let moreComment = model.moreComment {
//            if moreComment > 0 {
//                viewMore.isHidden = false
//
//                viewLine2.isHidden = false
//                imgCurve2.isHidden = false
//                if moreComment == 1 {
//                    lblMoreReply.text = "View all replies\(replies.cote) \(NSLocalizedString("more reply", comment: ""))"
//                } else {
//                    lblMoreReply.text = "View \(moreComment) \(NSLocalizedString("more replies", comment: ""))"
//                }
//
//            }
//            else {
//                viewMore.isHidden = true
//                viewLine2.isHidden = true
//                imgCurve2.isHidden = true
//            }
//        }
        
        if let replies = model.replies, replies.count > 0 {
            var count = replies.count
            replies.forEach({
                count += $0.replies?.count ?? 0
            })
            lblMoreReply.text = "View all replies (\(count))"

//            viewLine1.isHidden = false
//            imgCurve1.isHidden = false
//            viewComment.isHidden = false
//            lblReplyUser.text = replies.first?.user?.name?.capitalized ?? ""
//            if replies.first?.user?.image?.isEmpty ?? false {
//                imgReplyUser.theme_image = GlobalPicker.imgUserPlaceholder
//            }
//            else {
//                imgReplyUser.sd_setImage(with: URL(string: replies.first?.user?.image ?? "") , placeholderImage: nil)
//            }
            viewMore.isHidden = false
            
        } else {
            viewMore.isHidden = true
        }

        if let publishDate = model.createdAt {
            lblTime.text = SharedManager.shared.generateDatTimeOfNewsShortType(publishDate)
        }
        
        
//        if viewComment.isHidden && viewMore.isHidden {
//            viewLine1.isHidden = true
//            viewLine2.isHidden = true
//            imgCurve1.isHidden = true
//            imgCurve2.isHidden = true
//        }
    }
    
    
    
    @IBAction func didTapTypeReply(_ sender: Any) {
        
        self.delegate?.didTapTypeReply(cell: self)
    }
    
    
    @IBAction func didTapReply(_ sender: Any) {
        
        self.delegate?.didTapOpenReply(cell: self)
    }
}
