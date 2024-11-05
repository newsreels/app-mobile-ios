//
//  BaseHostingController.swift
//  Bullet
//
//  Created by Yeshua Lagac on 6/28/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SwiftUI

// rename??, BaseHostingController?
class BaseHostingController<Content: View>: UIHostingController<Content>, UINavigationControllerDelegate {
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return shouldHideHomeIndicator
    }
    
    var shouldHideHomeIndicator = false

    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let BaseNavigationController = navigationController as? BaseNavigationController else { return }
        BaseNavigationController.duringPushAnimation = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: .hideNavigationBar, object: nil, queue: .main) { [weak self] _ in
            self?.navigationController?.isNavigationBarHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let BaseNavigationController = navigationController as? BaseNavigationController else { return }
        BaseNavigationController.delegate = nil
    }
}
