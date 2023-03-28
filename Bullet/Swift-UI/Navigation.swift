//
//  Navigation.swift
//  Bullet
//
//  Created by Yeshua Lagac on 6/28/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SwiftUI

struct Navigation {
    static var swipeNavBar: BaseNavigationController? {
        let rootVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
        if let presented = rootVC?.presentedViewController {
            return presented as? BaseNavigationController
        }
        return BaseNavigationController(rootViewController: BaseHostingController(rootView: DiscoverMain()))
    }
    
    private static var destination: Destination? = nil
    
    static func set(destination: Destination) {
        self.destination = destination
        NotificationCenter.default.post(name: .naviDestinationChanged, object: nil)
    }
    
    /// Returning `true` to `completion` block completes the consummation  and deletes the stored destination
    static func consumeTarget(completion: @escaping (Destination?)->Bool) {
        let result = completion(destination)
        if result {
            destination = nil
        }
    }
    
    struct Destination {
        let target: Target?
        var shouldPresent = false
        var animated = false
        var completion: (()->())? = nil
        
        enum Target {
            case view(AnyView)
        }
        
        /// NOTE: waitForTabBarLoad automatically set as true
        init(completion: (()->())? = nil) {
            target = .view(AnyView(DiscoverMain()))
        }
        
        init<Content: View>(animated: Bool = false, shouldPresent: Bool = false, view: Content, completion: (()->())? = nil) {
            target = .view(AnyView(view))
            self.animated = animated
            self.completion = completion
            self.shouldPresent = shouldPresent
        }
    }
}
