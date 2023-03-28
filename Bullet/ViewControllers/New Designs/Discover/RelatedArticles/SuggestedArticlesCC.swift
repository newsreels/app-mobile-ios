//
//  SuggestedArticlesCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 04/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SDWebImage

class SuggestedArticlesCC: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var newsLabel: UILabel!
    @IBOutlet weak var timeSeparatorView: UIView!
    var langCode = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBAction func didTapSource(_ sender: Any) {
    }
    
    
    @IBAction func didTapViewMore(_ sender: Any) {
    }
    
    
    
    
    func setupCellBulletsView(article: articlesData) {
    
        
        newsLabel.text = article.bullets?.first?.data ?? ""
        newsLabel.font = SharedManager.shared.getListViewTitleFont()
        newsLabel.sizeToFit()

        let url = article.image ?? ""
        
//        lblSource.theme_textColor = GlobalPicker.textSourceColor
        
        
        let author = article.authors?.first?.username ?? article.authors?.first?.name ?? ""
        let source = article.source?.name ?? ""
        
        titleLabel.text = "\(author.isEmpty ? source :  author)"
        
//        if author == ""  && source == "" {
//            lblAuthor.text = ""
//            timeSeparatorView.isHidden = true
//        }
//        else {
//            timeSeparatorView.isHidden = false
//
//            lblAuthor.text = "by \(author.isEmpty ? source :  author)"
//        }
        
        lblAuthor.text = ""
        timeSeparatorView.isHidden = true
        
        langCode = article.language ?? ""
        if let pubDate = article.publish_time {
            lblTime.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
        }
                   
        newsImageView.sd_setImage(with: URL(string: article.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        
    }
    
    
}
