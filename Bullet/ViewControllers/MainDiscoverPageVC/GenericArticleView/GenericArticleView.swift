//
//  GenericArticleView.swift
//  Bullet
//
//  Created by Khadim Hussain on 12/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class GenericArticleView: UITableViewCell {

    @IBOutlet weak var lblHeadline: UILabel!
    @IBOutlet weak var lblBullet: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblSource: UILabel!
    
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSource: UIButton!
    
    @IBOutlet weak var viewBG: UIView!
    
    @IBOutlet weak var imgWifi: UIImageView!
    @IBOutlet weak var imgNews: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblHeadline.theme_textColor = GlobalPicker.textSubColorDiscover
        self.imgWifi.theme_image = GlobalPicker.imgWifi
        self.lblTime.theme_textColor = GlobalPicker.textSourceColor
        self.lblSource.theme_textColor = GlobalPicker.textSourceColor
        self.lblBullet.theme_textColor = GlobalPicker.textBWColor
        self.viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        self.theme_backgroundColor = GlobalPicker.backgroundDiscoverMainColor
        self.selectionStyle = .none
        self.viewBG.addBottomShadowForDiscoverPage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupCell(model: Discover?) {
        
        self.lblHeadline.text = model?.title ?? ""
        self.lblBullet.text = model?.data?.article?.title ?? ""
        self.lblSource.text = model?.data?.article?.source?.name ?? ""
        if let pubDate = model?.data?.article?.publish_time {
            self.lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate)
        }
        let sourceURL = model?.data?.article?.source?.icon ?? ""
        self.imgWifi?.sd_setImage(with: URL(string: sourceURL), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
       
        let url = model?.data?.article?.image ?? ""
        self.imgNews?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))

    }
    
    
    override func layoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblHeadline.semanticContentAttribute = .forceRightToLeft
                self.lblHeadline.textAlignment = .right
                self.lblBullet.semanticContentAttribute = .forceRightToLeft
                self.lblBullet.textAlignment = .right
                self.lblSource.semanticContentAttribute = .forceRightToLeft
                self.lblSource.textAlignment = .right
                self.lblTime.semanticContentAttribute = .forceRightToLeft
                self.lblTime.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblHeadline.semanticContentAttribute = .forceLeftToRight
                self.lblHeadline.textAlignment = .left
                self.lblBullet.semanticContentAttribute = .forceLeftToRight
                self.lblBullet.textAlignment = .left
                self.lblSource.semanticContentAttribute = .forceLeftToRight
                self.lblSource.textAlignment = .left
                self.lblTime.semanticContentAttribute = .forceLeftToRight
                self.lblTime.textAlignment = .left
            }
        }
    }
    
    
    @IBAction func didTapShare(_ sender: Any) {
        
        
    }
    @IBAction func didTapGoToSource(_ sender: UIButton) {
        
//        let content = self.articles[(sendertag]
//        self.performGoToSource(content)
   
    }
}
