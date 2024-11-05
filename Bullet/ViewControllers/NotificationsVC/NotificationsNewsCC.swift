//
//  NotificationsNewsCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 26/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class NotificationsNewsCC: UITableViewCell {

    @IBOutlet weak var lblNews: UILabel!
    @IBOutlet weak var lblChannel: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var imgDot: UIImageView!
    
    @IBOutlet weak var viewDividerLine: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblNews.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblChannel.theme_textColor = GlobalPicker.textSubColorDiscover
        lblTime.theme_textColor = GlobalPicker.textSubColorDiscover
        contentView.theme_backgroundColor = GlobalPicker.searchBGViewColor
        viewDividerLine.theme_backgroundColor = GlobalPicker.viewLineBGColor
    }

    
    func setupCell(notifications: Notifications) {
        
        SharedManager.shared.formatLabel(label: lblNews, with: (notifications.headline ?? ""))
        lblChannel.text = notifications.source ?? ""
        lblTime.text = SharedManager.shared.generateDatTimeOfNews(notifications.created_at ?? "")
        imgNews.sd_setImage(with: URL(string: notifications.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        
    }
    
    func setupGeneralCell(notifications: NotificationsDetail) {
        
        contentView.theme_backgroundColor = GlobalPicker.followingCardColor
        viewDividerLine.isHidden = true
        SharedManager.shared.formatLabel(label: lblNews, with: (notifications.details ?? ""))
        lblChannel.text = notifications.type ?? ""
        lblTime.text = SharedManager.shared.generateDatTimeOfNews(notifications.created_at ?? "")
        imgNews.sd_setImage(with: URL(string: notifications.image?.first ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        
    }
    
}
