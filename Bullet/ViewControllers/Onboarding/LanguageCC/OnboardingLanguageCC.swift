//
//  OnboardingLanguageCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 18/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class OnboardingLanguageCC: UICollectionViewCell {

    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var imgFav: UIImageView!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var lblLanguageTrans: UILabel!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var viewBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupLanguageCell(language:languagesData, isFave: Bool) {

        lblLanguage.text = language.name?.capitalized ?? ""
        lblLanguageTrans.text = language.sample ?? ""
        imgFav.image = isFave  ? UIImage(named: "tickUnselected") : UIImage(named: "plus")
        viewBG.roundUnSelectedViewWithBorder(view: viewBG)
        imgFlag.sd_setImage(with: URL(string: language.image ?? "") , placeholderImage: UIImage(named: "icn_profile_placeholder_dark"))
        imgFlag.layer.cornerRadius = imgFlag.layer.frame.size.width / 2
        imgFlag.clipsToBounds = true
    }
}
