//
//  ViewControllerWrapper.swift
//  Bullet
//
//  Created by Yeshua Lagac on 7/8/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct ViewControllerWrapper: UIViewControllerRepresentable{
    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewControllerWrapper>) -> UIViewController {
        guard let controller=controller else {
            return UIViewController()
        }
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ViewControllerWrapper>) {
    }
    let controller:UIViewController?
    typealias UIViewControllerType = UIViewController
}
