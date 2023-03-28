//
//  CustomTopicChannelCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 18/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class CustomTopicChannelCC: UITableViewCell {

    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblSubHeading: UILabel!
    @IBOutlet weak var lblFollow: UILabel!
    
    @IBOutlet weak var btnFollow: UIButton!
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewFollow: UIView!
    
    @IBOutlet weak var imgFollowIcon: UIImageView!
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var constraintFollowViewWidth: NSLayoutConstraint!
    
    var langCode = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.lblHeading.theme_textColor = GlobalPicker.textSourceColor
        self.lblSubHeading.theme_textColor = GlobalPicker.textSourceColor
        self.lblFollow.theme_textColor = GlobalPicker.textBWColor
        self.viewContainer.theme_backgroundColor = GlobalPicker.backgroundDiscoverHeader
        self.theme_backgroundColor = GlobalPicker.backgroundDiscoverMainColor
        self.viewFollow.theme_backgroundColor = GlobalPicker.bgSelectedColorHeaderTab
        self.selectionStyle = .none
        
        lblFollow.text = NSLocalizedString("Follow", comment: "")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
       
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblHeading.semanticContentAttribute = .forceRightToLeft
                self.lblHeading.textAlignment = .right
                self.lblSubHeading.semanticContentAttribute = .forceRightToLeft
                self.lblSubHeading.textAlignment = .right
                self.lblFollow.semanticContentAttribute = .forceRightToLeft
                self.lblFollow.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblHeading.semanticContentAttribute = .forceLeftToRight
                self.lblHeading.textAlignment = .left
                self.lblSubHeading.semanticContentAttribute = .forceLeftToRight
                self.lblSubHeading.textAlignment = .left
                self.lblFollow.semanticContentAttribute = .forceLeftToRight
                self.lblFollow.textAlignment = .left
            }
        }
        
    }
    
    
    func setupTopicCell(model: TopicData?) {
     
        self.lblHeading.text = model?.name ?? ""
     //   self.lblHeading.text = model?.source?.name ?? ""
        if model?.favorite == true {
         
            self.imgFollowIcon.theme_image = GlobalPicker.imgBookmarkSelected
            self.lblFollow.isHidden = true
            self.constraintFollowViewWidth.constant = 44
        }
        else {
            
            self.imgFollowIcon.image = UIImage(named: "unselected")
            self.lblFollow.isHidden = false
            self.constraintFollowViewWidth.constant = 108
        }
        
        let url = model?.image ?? ""
        self.imgSource?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))

    }
    
    func setupSourceCell(model: ChannelInfo?) {
     
        self.lblHeading.text = model?.name ?? ""
     //   self.lblHeading.text = model?.source?.name ?? ""
        if model?.favorite == true {
            
            self.imgFollowIcon.theme_image = GlobalPicker.imgBookmarkSelected
            self.lblFollow.isHidden = true
            self.constraintFollowViewWidth.constant = 44
        }
        else {
            
            self.imgFollowIcon.image = UIImage(named: "unselected")
            self.lblFollow.isHidden = false
            self.constraintFollowViewWidth.constant = 108
        }
        
        let url = model?.image ?? ""
        self.imgSource?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))

    }
    
    func setupLocationCell(model: Location?) {
     
        self.lblHeading.text = model?.city ?? ""
     //   self.lblHeading.text = model?.source?.name ?? ""
        if model?.favorite == true {
            
            self.imgFollowIcon.theme_image = GlobalPicker.imgBookmarkSelected
            self.lblFollow.isHidden = true
            self.constraintFollowViewWidth.constant = 44
        }
        else {
            
            self.imgFollowIcon.image = UIImage(named: "unselected")
            self.lblFollow.isHidden = false
            self.constraintFollowViewWidth.constant = 108
        }
        
        let url = model?.image ?? ""
        self.imgSource?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))

    }
}
