//
//  OnboardingContentVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 03/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class OnboardingContentVC: UIViewController {

//    @IBOutlet weak var onboardingImageView: UIImageView!
    @IBOutlet weak var maskedLabel: MaskedLabel!
//    @IBOutlet weak var gradientLabelView: GradientBorderedLabelView!
    
    var selectedPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
    }
    

    // MARK: - Methods
    
    func setupUI() {
        
//        gradientLabelView.fontSizeOfLabel = 50
//        gradientLabelView.customFontName = Constant.FONT_ROBOTO_BLACK
//        gradientLabelView.labelBackgroundColor = UIColor.clear
        
        maskedLabel.gradientColors = [Constant.appColor.lightRed, Constant.appColor.lightBlue]
        if !SharedManager.shared.isSelectedLanguageRTL() {
            maskedLabel.startPoint = CGPoint(x: 0.0, y: 0.0)
            maskedLabel.endPoint = CGPoint(x: maskedLabel.frame.width, y: maskedLabel.frame.height)
        }
        maskedLabel.fillOption = .text
        
        
        switch selectedPage {
        case 0:
//            onboardingImageView.image = UIImage(named: "OnboardingText1")
            maskedLabel.text = "The world\nat your\nfingerprint\nanytime,\nanywhere"
            break
        case 1:
//            onboardingImageView.image = UIImage(named: "OnboardingText2")
            
            maskedLabel.text = "Custom\n& interesting\nselected\ncontent only\nfor you"
            break
        case 2:
//            onboardingImageView.image = UIImage(named: "OnboardingText3")
            
            maskedLabel.text = "Subscribe,\nshare and\nfollow a\nunique\nexperience"
            break
        default:
            break
        }
        
    }
    
    
}
