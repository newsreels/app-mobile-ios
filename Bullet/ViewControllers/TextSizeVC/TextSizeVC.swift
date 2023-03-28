//
//  TextSizeVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 21/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class TextSizeVC: UIViewController {

//    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lblSmall: UILabel!
    @IBOutlet weak var lblDefault: UILabel!
    @IBOutlet weak var lblMedium: UILabel!
    @IBOutlet weak var lblLarge: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var viewSmall: UIView!
    @IBOutlet weak var viewDefault: UIView!
    @IBOutlet weak var viewMedium: UIView!
    @IBOutlet weak var viewLarge: UIView!
    @IBOutlet weak var constraintSliderLeading: NSLayoutConstraint!
    
    @IBOutlet weak var constraintSliderTrailing: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSampleText: UILabel!
    @IBOutlet weak var lblNewsTitle: UILabel!
    @IBOutlet weak var lblBulllet1: UILabel!
    @IBOutlet weak var lblBulllet2: UILabel!
    
    @IBOutlet weak var viewBottom: UIView!
    
    // 4 type of slider values
    let value1: Float = 0
    let value2: Float = 0.36
    let value3: Float = 0.65
    let value4: Float = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupLocalization()
        setupUI()
    }
    
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Article Text Size", comment: "")
        lblSmall.text = NSLocalizedString("Small", comment: "")
        lblDefault.text = NSLocalizedString("Default", comment: "")
        lblMedium.text = NSLocalizedString("Medium", comment: "")
        lblLarge.text = NSLocalizedString("Large", comment: "")
        
    }
    
    func setupUI() {
//        imgBack.theme_image = GlobalPicker.imgBack

        constraintSliderLeading.constant = viewSmall.frame.size.width/2 - 5
        constraintSliderTrailing.constant = viewSmall.frame.size.width/2 - 5
        slider.isContinuous = false
        
        var sliderImage = UIImage(named: MyThemes.current == .dark ? "textSizeSlider" : "textSizeSliderLight")
        let size = CGSize(width: 25, height: 25)
//        self.setThumbImage( , forState: UIControl.State.Normal
        sliderImage = SharedManager.shared.imageWithImage(image: sliderImage ?? UIImage(), scaledToSize: size)
        
        
        slider.setThumbImage(sliderImage, for: .normal)
        slider.setThumbImage(sliderImage, for: .highlighted)
        slider.theme_tintColor = GlobalPicker.sliderTintColor
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        self.viewBottom.theme_backgroundColor = GlobalPicker.backgroundColor
        
//        lblTitle.theme_textColor = GlobalPicker.fontSizeTextColor
//        lblSampleText.theme_textColor = GlobalPicker.fontSizeTextColor
//        lblNewsTitle.theme_textColor = GlobalPicker.fontSizeTextColor
//        lblBulllet1.theme_textColor = GlobalPicker.fontSizeTextColor
//        lblBulllet2.theme_textColor = GlobalPicker.fontSizeTextColor
//        lblBulllet3.theme_textColor = GlobalPicker.fontSizeTextColor
//        lblBulllet4.theme_textColor = GlobalPicker.fontSizeTextColor
//
//        lblSmall.theme_textColor = GlobalPicker.fontSizeUnselectedColor
//        lblDefault.theme_textColor = GlobalPicker.fontSizeUnselectedColor
//        lblMedium.theme_textColor = GlobalPicker.fontSizeUnselectedColor
//        lblLarge.theme_textColor = GlobalPicker.fontSizeUnselectedColor
        
        
//        for family in UIFont.familyNames {
//
//            let sName: String = family as String
//            print("family: \(sName)")
//
//            for name in UIFont.fontNames(forFamilyName: sName) {
//                print("name: \(name as String)")
//            }
//        }
        
        setArticleFontSize()
        lblSmall.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)
        lblDefault.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)
        lblMedium.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)
        lblLarge.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)
        
        switch SharedManager.shared.selectedFontType {
        case .defaultSize:
            slider.value = value2
            lblDefault.textColor = #colorLiteral(red: 0.9689999819, green: 0.2039999962, blue: 0.3449999988, alpha: 1)
            lblDefault.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 18)
        case .smallSize:
            slider.value = value1
            lblSmall.textColor = #colorLiteral(red: 0.9689999819, green: 0.2039999962, blue: 0.3449999988, alpha: 1)
            lblSmall.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 18)
        case .mediumSize:
            slider.value = value3
            lblMedium.textColor = #colorLiteral(red: 0.9689999819, green: 0.2039999962, blue: 0.3449999988, alpha: 1)
            lblMedium.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 18)
        case .largeSize:
            slider.value = value4
            lblLarge.textColor = #colorLiteral(red: 0.9689999819, green: 0.2039999962, blue: 0.3449999988, alpha: 1)
            lblLarge.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 18)
        default:
            slider.value = value2
            lblDefault.textColor =  #colorLiteral(red: 0.9689999819, green: 0.2039999962, blue: 0.3449999988, alpha: 1)
            lblDefault.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 18)
        }
        
        setArticleFontSize()
    }
    
        
    func setArticleFontSize() {
        
        UIView.animate(withDuration: 0.25) {
            self.lblNewsTitle.font = SharedManager.shared.getTitleFont()
            self.lblBulllet1.font = SharedManager.shared.getBulletFont()
            self.lblBulllet2.font = SharedManager.shared.getBulletFont()

            self.view.layoutIfNeeded()
        }
        
    }
    
    
    // MARK: - Actions
    @IBAction func sliderValueChanged(_ sender: Any) {
        
        SharedManager.shared.textSizeChanged = true
        
        UIView.animate(withDuration: 0.25) {
            if self.slider.value < self.value2 - (0.33/2) {
                self.slider.value = self.value1
            }
            else if self.slider.value < self.value3 - (0.33/2) {
                self.slider.value = self.value2
            }
            else if self.slider.value < self.value4 - (0.33/2) {
                self.slider.value = self.value3
            }
            else {
                self.slider.value = self.value4
            }
            self.view.layoutIfNeeded()
        }
        
        lblSmall.theme_textColor = GlobalPicker.fontSizeUnselectedColor
        lblDefault.theme_textColor = GlobalPicker.fontSizeUnselectedColor
        lblMedium.theme_textColor = GlobalPicker.fontSizeUnselectedColor
        lblLarge.theme_textColor = GlobalPicker.fontSizeUnselectedColor
        
        lblSmall.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)
        lblDefault.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)
        lblMedium.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)
        lblLarge.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)
//        lblSmall.font = UIFont(name: "", size: <#T##CGFloat#>)
        if slider.value == value1 {
            SharedManager.shared.selectedFontType = .smallSize
            lblSmall.textColor = #colorLiteral(red: 0.9689999819, green: 0.2039999962, blue: 0.3449999988, alpha: 1)
            lblSmall.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)
        } else if slider.value == value2 {
            SharedManager.shared.selectedFontType = .defaultSize
            lblDefault.textColor = #colorLiteral(red: 0.9689999819, green: 0.2039999962, blue: 0.3449999988, alpha: 1)
            lblDefault.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)
        } else if slider.value == value3 {
            SharedManager.shared.selectedFontType = .mediumSize
            lblMedium.textColor = #colorLiteral(red: 0.9689999819, green: 0.2039999962, blue: 0.3449999988, alpha: 1)
            lblMedium.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)
        } else if slider.value == value4 {
            SharedManager.shared.selectedFontType = .largeSize
            lblLarge.textColor = #colorLiteral(red: 0.9689999819, green: 0.2039999962, blue: 0.3449999988, alpha: 1)
            lblLarge.font = UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)
        }
        
        setArticleFontSize()
        
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
}
