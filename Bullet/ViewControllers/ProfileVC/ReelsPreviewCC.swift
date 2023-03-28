//
//  ReelsPreviewCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 18/05/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ReelsPreviewCC: UICollectionViewCell {

    @IBOutlet weak var imgReels: UIImageView!
    @IBOutlet weak var lblViews: UILabel!
//    @IBOutlet weak var viewProcessing: UIView!
//    @IBOutlet weak var viewLoader: NVActivityIndicatorView!
    
    //View Processing Upload Article by User
    @IBOutlet weak var viewProcessingBG: UIView!
    @IBOutlet weak var viewLoader: NVActivityIndicatorView!
    @IBOutlet weak var lblProcessing: UILabel!
    
    //View Schedule Upload Article by User
    @IBOutlet weak var viewScheduleBG: UIView!
    @IBOutlet weak var lblScheduleTime: UILabel!
    @IBOutlet weak var lblScheduleTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //View Processing Article
        viewLoader.type = .ballSpinFadeLoader
        viewLoader.startAnimating()
        lblProcessing.theme_textColor = GlobalPicker.textBWColor
        lblProcessing.text = NSLocalizedString("Processing...", comment: "")

        //Schedule Article
        lblScheduleTitle.text = NSLocalizedString("Scheduled on:", comment: "")
        lblScheduleTime.textColor = .white

        viewLoader.type = .ballSpinFadeLoader
        viewLoader.startAnimating()
    }
    
    override func layoutSubviews() {
        
        self.cornerRadius = 10
    }
    
    func setupCell(model: Reel) {
        
        imgReels.sd_setImage(with: URL(string: model.image ?? "") , placeholderImage: nil)
        
        lblViews.minimumScaleFactor = 0.5
        lblViews.text = "\(SharedManager.shared.formatPoints(num: Double((model.info?.viewCount ?? "0")) ?? 0))"
        //(NSLocalizedString("Views", comment: ""))
        
    }
    
}

