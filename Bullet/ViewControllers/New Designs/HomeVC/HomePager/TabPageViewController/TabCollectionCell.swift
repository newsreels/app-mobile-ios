//
//  TabCollectionCell.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

class TabCollectionCell: UICollectionViewCell {

    var tabItemButtonPressedBlock: (() -> Void)?
    var option: TabPageOption = TabPageOption() {
        didSet {
            currentBarViewHeightConstraint.constant = option.currentBarHeight
        }
    }
    var istheme = false
    var item: String = "" {
        didSet {
            itemLabel.text = item.uppercased()
            itemLabel.invalidateIntrinsicContentSize()
            invalidateIntrinsicContentSize()
        }
    }
    var isCurrent: Bool = false {
        didSet {
            currentBarView.isHidden = !isCurrent
            if isCurrent {
                highlightTitle()
                
                currentBarView.theme_backgroundColor = GlobalPicker.textMainTabSelectedLineColor
            } else {
                unHighlightTitle()
                
                currentBarView.theme_backgroundColor = GlobalPicker.textMainTabUnselectedColor
            }
            layoutIfNeeded()
        }
    }

    @IBOutlet fileprivate weak var itemLabel: UILabel!
    @IBOutlet weak var currentBarView: UIView!
    @IBOutlet fileprivate weak var currentBarViewHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        currentBarView.isHidden = true
    }
    
    override func layoutSubviews() {
        
        currentBarView.roundCorners([.topLeft, .topRight], currentBarView.frame.height / 2)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if item.count == 0 {
            return CGSize.zero
        }

        return intrinsicContentSize
    }

    class func cellIdentifier() -> String {
        return "TabCollectionCell"
    }
}


// MARK: - View

extension TabCollectionCell {
    override var intrinsicContentSize : CGSize {
        let width: CGFloat
        if let tabWidth = option.tabWidth , tabWidth > 0.0 {
            width = tabWidth
        } else {
            width = itemLabel.intrinsicContentSize.width + option.tabMargin * 2
        }

        let size = CGSize(width: width, height: option.tabHeight)
        return size
    }

    func hideCurrentBarView() {
        currentBarView.isHidden = true
    }

    func showCurrentBarView() {
        currentBarView.isHidden = false
    }

    func highlightTitle() {
        
        if istheme {
            itemLabel.theme_textColor = GlobalPicker.textMainTabSelectedColor
        }
        else {
//            itemLabel.textColor = .white
            itemLabel.textColor = .black
        }
        //itemLabel.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 15)!
    }

    func unHighlightTitle() {
        
        if istheme {
            itemLabel.theme_textColor = GlobalPicker.textMainTabUnselectedColor
        }
        else {
            itemLabel.textColor = "#7F7F82".hexStringToUIColor()
        }
        //itemLabel.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 15)!//UIFont.systemFont(ofSize: option.fontSize)
    }
}


// MARK: - IBAction

extension TabCollectionCell {
    
    @IBAction fileprivate func tabItemTouchUpInside(_ button: UIButton) {
        tabItemButtonPressedBlock?()
    }
}
