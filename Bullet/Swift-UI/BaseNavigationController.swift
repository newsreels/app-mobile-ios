//
//  BaseNavigationController.swift
//  Bullet
//
//  Created by Yeshua Lagac on 6/28/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation

import UIKit
import SwiftUI

final class BaseNavigationController: UINavigationController {

    // MARK: - Lifecycle

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // This needs to be in here, not in init
        interactivePopGestureRecognizer?.delegate = self
    }

    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }

    // MARK: - Overrides

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        duringPushAnimation = true
        super.pushViewController(viewController, animated: animated)
    }

    var duringPushAnimation = false

    // MARK: - Custom Functions

    func pushSwipeBackView<Content>(animated: Bool = true, shouldHideHomeIndicator: Bool = false, _ content: Content, removeSourceViewFromStack: Bool = false, completion: (()->())? = nil, onAppear: (()->())? = nil) where Content: View {
        let hostingController = BaseHostingController(
            rootView: content.if(onAppear != nil) {
                $0.onAppear {
                    onAppear?()
                }
            }
        )
        self.delegate = hostingController
        hostingController.shouldHideHomeIndicator = shouldHideHomeIndicator
        self.pushViewController(viewController: hostingController, animated: animated, completion: {
            if removeSourceViewFromStack, let conCount = Navigation.swipeNavBar?.viewControllers.count {
                Navigation.swipeNavBar?.viewControllers.remove(at: conCount - 2)
            }
            completion?()
        })
    }
}

// MARK: - UINavigationControllerDelegate

extension BaseNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let BaseNavigationController = navigationController as? BaseNavigationController else { return }

        BaseNavigationController.duringPushAnimation = false
    }

}

extension UINavigationController {
    
    public func pushViewController(viewController: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BaseNavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return true // default value
        }

        // Disable pop gesture in two situations:
        // 1) when the pop animation is in progress
        // 2) when user swipes quickly a couple of times and animations don't have time to be performed
        let result = viewControllers.count > 1 && duringPushAnimation == false
        
        return viewControllers.count > 1
    }
}
