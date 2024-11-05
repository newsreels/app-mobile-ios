//
//  PTTabBarButtonItem.swift
//  PTR
//
//  Created by Hussein AlRyalat on 4/7/19.
//  Copyright © 2019 SketchMe. All rights reserved.
//

import UIKit
import SwiftTheme

// ImageButton
class PTBarButton: ImageButton {
    
    var selectedColor: UIColor! = .gray {
        didSet {
            reloadApperance()
        }
    }
    
    var unselectedColor: UIColor! = .gray {
        didSet {
            reloadApperance()
        }
    }
    
    init(forItem item: UITabBarItem, index: Int) {
        super.init(frame: .zero)
        
        self.buttonIndex = index
        setUpButton(index: index)
    }
    
    var buttonIndex = 0
    
    init(image: UIImage, index: Int){
        super.init(frame: .zero)
        setImage(image, for: .normal)
        
        self.buttonIndex = index
        setUpButton(index: index)
    }
    
    
    func setUpButton(index: Int) {
        
        let size = CGSize(width: 22, height: 22)
        titleEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        //        theme_setTitleColor(GlobalPicker.tabIconSelectedColor, forState: .selected)
        //        theme_setTitleColor(GlobalPicker.tabIconColor, forState: .normal)
        // lower the text and push it left so it appears centered
        //  below the image
        //        titleEdgeInsets = UIEdgeInsets(0.0, - size.width, - (size.height + spacing), 0.0);
        
        
        setTitle("", for: .normal)
        
        imageView?.contentMode = .scaleAspectFit
        //        imageView?.layer.transform = CATransform3DMakeScale(1, 1, 1)
        
        if index == 0 {
            setTitle(NSLocalizedString("Reels", comment: ""), for: .normal)
            var tabImage = UIImage(named: "ReelsIcon")
            var tabImageSelected = UIImage(named: "ReelsIconSelected")
            let tabImageSelectedBlack = UIImage(named: "ReelsIconSelectedBlack")
            
//            tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size).sd_tintedImage(with: Constant.appColor.customGrey)
            if SharedManager.shared.buttonTabSelected == 0 {
                tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size).sd_tintedImage(with: .white)
            }
            else {
                tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size)

            }

            tabImageSelected = SharedManager.shared.imageWithImage(image: tabImageSelectedBlack ?? UIImage(), scaledToSize: size)
            setImage(tabImage, for: .normal)
            setImage(tabImageSelected, for: .selected)
            
            //            let lightImage = tabImage?.sd_tintedImage(with: Constant.appColor.blue)
//            let darkImage = tabImage?.sd_tintedImage(with: Constant.appColor.purple)
//            let colorImage = ThemeImagePicker(images: darkImage!,darkImage!)
//            theme_setImage(colorImage, forState: .selected)
            //            theme_setTitleColor(GlobalPicker.tabIconSelectedColorReels, forState: .selected)
            
        }
        else if index == 1 {
            
            
            setTitle(NSLocalizedString("Articles", comment: ""), for: .normal)
            var tabImage = UIImage(named: "icn_home_gray")
            var tabImageSelected = UIImage(named: "icn_home_graySelected")
//            tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size).sd_tintedImage(with: Constant.appColor.customGrey)
            if SharedManager.shared.buttonTabSelected == 0 {
                tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size).sd_tintedImage(with: .white)
            }
            else {
                tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size)
            }
            tabImageSelected = SharedManager.shared.imageWithImage(image: tabImageSelected ?? UIImage(), scaledToSize: size)
            setImage(tabImage, for: .normal)
            setImage(tabImageSelected, for: .selected)
//            let lightImage = tabImage?.sd_tintedImage(with: Constant.appColor.blue)
//            let darkImage = tabImage?.sd_tintedImage(with: Constant.appColor.purple)
//            let colorImage = ThemeImagePicker(images: lightImage!,darkImage!)
//            theme_setImage(colorImage, forState: .selected)
            
        }
        else if index == 2 {
            
            setTitle(NSLocalizedString("Search", comment: ""), for: .normal)
            var tabImage = UIImage(named: "icn_search_gray")
            var tabImageSelected = UIImage(named: "icn_search_graySelected")
//            tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size).sd_tintedImage(with: Constant.appColor.customGrey)
            if SharedManager.shared.buttonTabSelected == 0 {
                tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size).sd_tintedImage(with: .white)
            }
            else {
                tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size)
            }
            tabImageSelected = SharedManager.shared.imageWithImage(image: tabImageSelected ?? UIImage(), scaledToSize: size)
            setImage(tabImage, for: .normal)
            setImage(tabImageSelected, for: .selected)
//            let lightImage = tabImage?.sd_tintedImage(with: Constant.appColor.blue)
//            let darkImage = tabImage?.sd_tintedImage(with: Constant.appColor.purple)
//            let colorImage = ThemeImagePicker(images: lightImage!,darkImage!)
//            theme_setImage(colorImage, forState: .selected)
            
        }
        
        
        else if index == 3 {
            setTitle(NSLocalizedString("Following", comment: ""), for: .normal)
            var tabImage = UIImage(named: "favBlack")
            var tabImageSelected = UIImage(named: "favSelected")
//            tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size).sd_tintedImage(with: Constant.appColor.customGrey)
            if SharedManager.shared.buttonTabSelected == 0 {
                tabImage = UIImage(named: "favWhite")
                tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size)
            }
            else {
                tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size)
            }
            tabImageSelected = SharedManager.shared.imageWithImage(image: tabImageSelected ?? UIImage(), scaledToSize: size)
            setImage(tabImage, for: .normal)
            setImage(tabImageSelected, for: .selected)
//            let lightImage = tabImage?.sd_tintedImage(with: Constant.appColor.blue)
//            let darkImage = tabImage?.sd_tintedImage(with: Constant.appColor.purple)
//            let colorImage = ThemeImagePicker(images: lightImage!,darkImage!)
//            theme_setImage(colorImage, forState: .selected)
        }
        
        
        else if index == 4 {
            setTitle(NSLocalizedString("Profile", comment: ""), for: .normal)
            var tabImage = UIImage(named: "icn_profile_gray")
            var tabImageSelected = UIImage(named: "icn_profile_graySelected")
//            tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size).sd_tintedImage(with: Constant.appColor.customGrey)
            if SharedManager.shared.buttonTabSelected == 0 {
                tabImage = UIImage(named: "icn_profile_grayBlack")
                tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size)
            }
            else {
                tabImage = SharedManager.shared.imageWithImage(image: tabImage ?? UIImage(), scaledToSize: size)
            }
            tabImageSelected = SharedManager.shared.imageWithImage(image: tabImageSelected ?? UIImage(), scaledToSize: size)
            setImage(tabImage, for: .normal)
            setImage(tabImageSelected, for: .selected)
//            let lightImage = tabImage?.sd_tintedImage(with: Constant.appColor.blue)
//            let darkImage = tabImage?.sd_tintedImage(with: Constant.appColor.purple)
//            let colorImage = ThemeImagePicker(images: lightImage!,darkImage!)
//            theme_setImage(colorImage, forState: .selected)
        }
        
        
        if SharedManager.shared.buttonTabSelected == 0 {
            setTitleColor(.white, for: .normal)
            setTitleColor(Constant.appColor.lightRed, for: .selected)
        }
        else {
            setTitleColor(Constant.appColor.darkGray, for: .normal)
            setTitleColor(Constant.appColor.lightRed, for: .selected)
        }
    }
    
    public override func layoutSubviews() {
//        self.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 8, right: 0)
//        self.imageView?.contentMode = .scaleAspectFit
//        self.contentHorizontalAlignment = .center
//        self.contentVerticalAlignment = .center
        super.layoutSubviews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override public var isSelected: Bool {
        didSet {
            reloadApperance()
        }
    }
    
    func reloadApperance(){
//        self.theme_tintColor = isSelected ? GlobalPicker.btnSelectedTabbarTintColor : GlobalPicker.btnUnselectedTabbarTintColor
//        self.tintColor = isSelected ? selectedColor : unselectedColor
        
       
        if isSelected {
            titleLabel?.font = UIFont(name: Constant.FONT_ROBOTO_BOLD, size: 11)
            
        } else {
            titleLabel?.font = UIFont(name: Constant.FONT_ROBOTO_REGULAR, size: 11)
        }
    
        
        
        
        setUpButton(index: buttonIndex)
        
    }
}
