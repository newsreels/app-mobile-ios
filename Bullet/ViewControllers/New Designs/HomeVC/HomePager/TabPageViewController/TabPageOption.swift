//
//  TabPageOption.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

public enum HidesTopContentsOnSwipeType {
    case none
    case tabBar
    case navigationBar
    case all
}

public struct TabPageOption {

    public init() {}

    public var fontSize = UIFont.systemFontSize
    public var defaultColor = "#67676B".hexStringToUIColor()
    public var tabHeight: CGFloat = 52.0
    public var tabTitleHeight: CGFloat = 30.0
    public var tabMargin: CGFloat = 5.0
    public var tabInteritemSpacing: CGFloat = 10.0
    public var tabWidth: CGFloat?
    public var currentBarHeight: CGFloat = 2.5
    public var tabBackgroundColor: UIColor = .white
    public var pageBackgoundColor: UIColor = UIColor.clear
    public var isTranslucent: Bool = true
    public var hidesTopViewOnSwipeType: HidesTopContentsOnSwipeType = .none
    public var title: String = ""

    internal var tabBarAlpha: CGFloat {
        return isTranslucent ? 0.95 : 1.0
    }
    internal var tabBackgroundImage: UIImage {
        return convertImage()
    }

    fileprivate func convertImage() -> UIImage {
        let rect : CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context : CGContext? = UIGraphicsGetCurrentContext()
        let backgroundColor = tabBackgroundColor.withAlphaComponent(tabBarAlpha).cgColor
        context?.setFillColor(backgroundColor)
        context?.fill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}


public struct subTabPageOption {

    public init() {}

    public var fontSize = UIFont.systemFontSize
    public var defaultColor = "#67676B".hexStringToUIColor()
    public var tabHeight: CGFloat = 32.0
    public var tabTitleHeight: CGFloat = 30.0
    public var tabMargin: CGFloat = 5.0
    public var tabInteritemSpacing: CGFloat = 10.0
    public var tabWidth: CGFloat?
    public var currentBarHeight: CGFloat = 2.0
    public var tabBackgroundColor: UIColor = .white
    public var pageBackgoundColor: UIColor = UIColor.clear
    public var isTranslucent: Bool = true
    public var hidesTopViewOnSwipeType: HidesTopContentsOnSwipeType = .none
    public var title: String = ""

    internal var tabBarAlpha: CGFloat {
        return isTranslucent ? 0.95 : 1.0
    }
    internal var tabBackgroundImage: UIImage {
        return convertImage()
    }

    fileprivate func convertImage() -> UIImage {
        let rect : CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context : CGContext? = UIGraphicsGetCurrentContext()
        let backgroundColor = tabBackgroundColor.withAlphaComponent(tabBarAlpha).cgColor
        context?.setFillColor(backgroundColor)
        context?.fill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
