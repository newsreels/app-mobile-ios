//
//  RepliesCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 08/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol RepliesCCDelegate: class {
    
    func didTapViewMoreReplies(cell: RepliesCC)
    func didTapReplyButton(cell: RepliesCC)
    func didTapReplyTextView(cell: RepliesCC)
    
}

class RepliesCC: UITableViewCell {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var imgReplyUser: UIImageView!
    @IBOutlet weak var lblReplyUser: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblReply: UILabel!
    @IBOutlet weak var imgReplyNested: UIImageView!
    @IBOutlet weak var viewMoreReplies: UIView!
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var viewReplyTextView: UIView!
    @IBOutlet weak var lblMore: UILabel!
    @IBOutlet weak var viewTextViewContainer: UIView!
    @IBOutlet weak var txtViewComment: AutoExpandingTextView!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var viewLine: UIView!
    @IBOutlet weak var viewLine2: UIView!
    @IBOutlet weak var viewLine3: UIView!
    @IBOutlet weak var imgCurve1: UIImageView!
    @IBOutlet weak var imgCurve2: UIImageView!
    @IBOutlet weak var imgCurve3: UIImageView!
    @IBOutlet weak var viewLineMoreReply: UIView!
    @IBOutlet weak var viewLine4: UIView!
    
    var replyCount = 0
    var isSelectedData = false
    weak var delegate: RepliesCCDelegate?
    var parentID = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.lblReplyUser.theme_textColor = GlobalPicker.commentVCTitleColor
//        self.lblReply.theme_textColor = GlobalPicker.commentTextViewTextColor
        lblMore.theme_textColor = GlobalPicker.commentVCTitleColor
        
        self.viewTextViewContainer.backgroundColor = .clear
        self.viewTextViewContainer.layer.borderWidth = 1
        self.viewTextViewContainer.layer.theme_borderColor = GlobalPicker.commentTxtBorderColor
        //theme_backgroundColor = GlobalPicker.commentTextViewBGColor
        self.txtViewComment.theme_textColor = GlobalPicker.commentTextViewTextColor
        lblPlaceHolder.theme_textColor = GlobalPicker.commentTextViewTextColor
        
        viewMoreReplies.isHidden = true
        viewLoader.isHidden = true
        viewReplyTextView.isHidden = true
        
        
        self.viewLine.theme_backgroundColor = GlobalPicker.commentNestedLineColor
        self.viewLine2.theme_backgroundColor = GlobalPicker.commentNestedLineColor
        self.viewLine3.theme_backgroundColor = GlobalPicker.commentNestedLineColor
        self.viewLineMoreReply.theme_backgroundColor = GlobalPicker.commentNestedLineColor
        self.viewLine4.theme_backgroundColor = GlobalPicker.commentNestedLineColor
        
        self.imgCurve1.theme_image = GlobalPicker.commentCurvedImage
        self.imgCurve2.theme_image = GlobalPicker.commentCurvedImage
        self.imgCurve3.theme_image = GlobalPicker.commentCurvedImage
        
        
        lblPlaceHolder.text = NSLocalizedString("Write a reply...", comment: "")
        
    }

    override func prepareForReuse() {
        replyCount = 0
        imgReplyUser.image = nil
        lblReplyUser.text = ""
        lblReply.text = ""
        lblTime.text = ""
    }
    
    override func layoutSubviews() {
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblReplyUser.semanticContentAttribute = .forceRightToLeft
                self.lblReplyUser.textAlignment = .right
                self.lblReply.semanticContentAttribute = .forceRightToLeft
                self.lblReply.textAlignment = .right
                self.lblMore.semanticContentAttribute = .forceRightToLeft
                self.lblMore.textAlignment = .right
                
                self.imgCurve1.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.imgCurve2.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.imgCurve3.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblReplyUser.semanticContentAttribute = .forceLeftToRight
                self.lblReplyUser.textAlignment = .left
                self.lblReply.semanticContentAttribute = .forceLeftToRight
                self.lblReply.textAlignment = .left
                self.lblMore.semanticContentAttribute = .forceLeftToRight
                self.lblMore.textAlignment = .left
                
                self.imgCurve1.transform = CGAffineTransform.identity
                self.imgCurve2.transform = CGAffineTransform.identity
                self.imgCurve3.transform = CGAffineTransform.identity
            }
        }
        
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTapViewMoreReply(_ sender: Any) {
        self.delegate?.didTapViewMoreReplies(cell: self)
    }
    
    @IBAction func didTapReplyButton(_ sender: Any) {
        self.delegate?.didTapReplyButton(cell: self)
    }
    
    @IBAction func didTapReplyTextView(_ sender: Any) {
        self.delegate?.didTapReplyTextView(cell: self)
    }
    
    
    func setupCell(replyModel: Comment, commentModel: Comment, indexpath: IndexPath, isLastTopComment: Bool) {
        
        parentID = commentModel.id ?? ""
        viewLine3.isHidden = true
        if (commentModel.replies?.count ?? 0) - 1 == indexpath.row {
            
            if let moreComment = commentModel.moreComment {

                if moreComment > 0 {
                    
                    // Last index with more comments
                    viewMoreReplies.isHidden = false
                    viewReplyTextView.isHidden = false
                    
                    viewLine2.isHidden = false
                    imgCurve2.isHidden = false
                    if moreComment == 1 {
                        lblMore.text = "View \(moreComment) \(NSLocalizedString("more reply", comment: ""))"
                    } else {
                        lblMore.text = "View \(moreComment) \(NSLocalizedString("more replies", comment: ""))"
                    }
                }
                else {
                    viewMoreReplies.isHidden = true
                    viewReplyTextView.isHidden = false
                }
            }
            
            
            
        } else {
            viewMoreReplies.isHidden = true
            viewReplyTextView.isHidden = true
            if (commentModel.replies?.count ?? 0) - 1 != indexpath.row {
                viewLine3.isHidden = false
            }
        }
        
        if replyModel.user?.image?.isEmpty ?? false {
            imgReplyUser.theme_image = GlobalPicker.imgUserPlaceholder
        }
        else {
            imgReplyUser.sd_setImage(with: URL(string: replyModel.user?.image ?? "") , placeholderImage: nil)

        }
        lblReplyUser.text = replyModel.user?.name?.capitalized ?? ""
        if let publishDate = replyModel.createdAt {
            lblTime.text = SharedManager.shared.generateDatTimeOfNewsShortType(publishDate)
        }
        lblReply.text = replyModel.comment
        
        if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {
            
            let profile = user.profile_image ?? ""

            if profile.isEmpty {
                imgReplyNested.theme_image = GlobalPicker.imgUserPlaceholder
            }
            else {
                imgReplyNested.sd_setImage(with: URL(string: profile), placeholderImage: nil)
            }

        }
        
        if isLastTopComment {
            viewLine4.isHidden = true
        } else {
            viewLine4.isHidden = false
        }
        
        
        
        self.layoutIfNeeded()
    }
    
}

