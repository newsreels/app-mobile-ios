//
//  CreatePostCC.swift
//  Bullet
//
//  Created by Mahesh on 05/09/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class CreatePostCC: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}




class SubTabCategoryCell: UICollectionViewCell {

    var tabItemButtonPressedBlock: (() -> Void)?

//    @IBOutlet weak var currentBarView: UIView!
    var item: String = "" {
        didSet {
            itemLabel.text = item.uppercased()
//            itemLabel.invalidateIntrinsicContentSize()
//            invalidateIntrinsicContentSize()
        }
    }
    var isCurrent: Bool = false {
        didSet {
//            currentBarView.isHidden = !isCurrent
            if isCurrent {
                highlightTitle()

//                currentBarView.theme_backgroundColor = GlobalPicker.textMainTabSelectedLineColor
            } else {
                unHighlightTitle()

//                currentBarView.theme_backgroundColor = GlobalPicker.textMainTabUnselectedColor
            }
//            layoutIfNeeded()
        }
    }

    @IBOutlet fileprivate weak var itemLabel: UILabel!
//    @IBOutlet weak var currentBarView: UIView!
//    @IBOutlet fileprivate weak var currentBarViewHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

//        currentBarView.isHidden = true
    }

//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        if item.count == 0 {
//            return CGSize.zero
//        }
//
//        return intrinsicContentSize
//    }
//
    class func cellIdentifier() -> String {
        return "SubTabCategoryCell"
    }
}


extension SubTabCategoryCell {

    func hideCurrentBarView() {
//        currentBarView.isHidden = true
    }

    func showCurrentBarView() {
//        currentBarView.isHidden = false
    }

    func highlightTitle() {
        itemLabel.textColor = .white
        //itemLabel.theme_textColor = GlobalPicker.textMainTabSelectedColor
        //itemLabel.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 15)!
    }

    func unHighlightTitle() {
        itemLabel.textColor = "#7F7F82".hexStringToUIColor()
        //itemLabel.theme_textColor = GlobalPicker.textMainTabUnselectedColor
        //itemLabel.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 15)!//UIFont.systemFont(ofSize: option.fontSize)
    }
}

// MARK: - IBAction

extension SubTabCategoryCell {
    
    @IBAction fileprivate func tabItemTouchUpInside(_ button: UIButton) {
        tabItemButtonPressedBlock?()
    }
}
