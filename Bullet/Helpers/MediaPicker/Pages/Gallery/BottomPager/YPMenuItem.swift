//
//  YPMenuItem.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 24/01/2018.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import Stevia

final class YPMenuItem: UIView {
    
    var textLabel = UILabel()
//    var selectedLine = UIView()
    var button = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    func setup() {
        backgroundColor = YPImagePickerConfiguration.shared.colors.bottomMenuItemBackgroundColor
        
//        sv(
//            textLabel,
//            selectedLine,
//            button
//        )
        sv(
            textLabel,
            button
        )
        
        textLabel.centerInContainer()
        |-(10)-textLabel-(10)-|
        button.fillContainer()
        
//        selectedLine.Bottom == Bottom
//        selectedLine.Left == Left + 0
//        selectedLine.Right == Right - 0
//        selectedLine.Height == 2
        
        textLabel.style { l in
            l.textAlignment = .center
            l.font = YPConfig.fonts.menuItemFont
            l.textColor = YPImagePickerConfiguration.shared.colors.bottomMenuItemUnselectedTextColor
            l.adjustsFontSizeToFitWidth = true
            l.numberOfLines = 2
        }
        
//        selectedLine.theme_backgroundColor = GlobalPicker.themeCommonColor
        
    }

    func select() {
        textLabel.theme_textColor = GlobalPicker.pickerTitleSelect//YPImagePickerConfiguration.shared.colors.bottomMenuItemSelectedTextColor
//        selectedLine.isHidden = false
    }
    
    func deselect() {
        textLabel.theme_textColor = GlobalPicker.pickerTitleNotSelect
//        selectedLine.isHidden = true
    }
}
