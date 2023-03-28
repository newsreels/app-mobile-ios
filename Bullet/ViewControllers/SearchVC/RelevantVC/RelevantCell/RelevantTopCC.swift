//
//  RelevantTopCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 19/05/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit


protocol RelevantTopCCDelegate: class {
    
    func didTapFollow(cell: RelevantTopCC)
    func didTapCategory(cell: RelevantTopCC)
    
}
class RelevantTopCC: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var constraintFollowViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imgFollowIcon: UIImageView!
    @IBOutlet weak var lblFollow: UILabel!
    @IBOutlet weak var viewFollow: UIView!
    weak var delegate: RelevantTopCCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewContainer.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        lblTitle.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblFollow.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        viewFollow.theme_backgroundColor = GlobalPicker.followButtonBackground
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
            }
        }
    }
    
    func setupCell(image: String, title: String, isFavourite: Bool) {
        
        lblTitle.text = title
        if isFavourite {
            
            self.imgFollowIcon.theme_image = GlobalPicker.followButtonImageSelected
            self.lblFollow.isHidden = true
            self.constraintFollowViewWidth.constant = 44
            
        } else {
            
            self.imgFollowIcon.theme_image = GlobalPicker.followButtonImageNotSelected
            self.lblFollow.isHidden = false
            self.constraintFollowViewWidth.constant = 108
        }
        
        self.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        
        
    }
    
    
    
    @IBAction func didTapFollow(button: UIButton) {
        
        self.delegate?.didTapFollow(cell: self)
    }
    
    @IBAction func didTapCategory(_ sender: Any) {
        
        self.delegate?.didTapCategory(cell: self)
    }
    
    
}
