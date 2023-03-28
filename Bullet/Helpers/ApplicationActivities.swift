//
//  ApplicationActivities.swift
//  Bullet
//
//  Created by Mahesh on 01/07/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class CustomUISlider: UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        
        //keeps original origin and width, changes height, you get the idea
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width - 8, height: 2.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }

    //while we are here, why not change the image here as well? (bonus material)
    override func awakeFromNib() {
        
        self.setThumbImage(UIImage(named: (MyThemes.current == .dark ? "point" : "point_light")), for: .normal)
        super.awakeFromNib()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds = self.bounds
        bounds = bounds.insetBy(dx: -10, dy: -15)
        return bounds.contains(point)
    }
}

class ApplicationActivities: UIActivity {

    var _activityTitle: String
    var _activityImage: UIImage?
    var activityItems = [Any]()
    var action: ([Any]) -> Void
    
    init(title: String, image: UIImage?, performAction: @escaping ([Any]) -> Void) {
        
        _activityTitle = title
        _activityImage = image
        action = performAction
        super.init()
    }

    override var activityTitle: String? {
        return _activityTitle
    }

    override var activityImage: UIImage? {
        return _activityImage
    }

    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: Bundle.main.bundleIdentifier ?? "" + (".\(NSStringFromClass(type(of: self).self))"))
    }

    override class var activityCategory: UIActivity.Category {
        return .action
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        self.activityItems = activityItems
    }

    override func perform() {
        action(activityItems)
        activityDidFinish(true)
    }
    
    
    

}
