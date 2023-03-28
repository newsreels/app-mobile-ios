//
//  Utilities.swift
//  Bullet
//
//  Created by Yeshua Lagac on 6/20/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation
import SwiftUI
import AVKit

struct Utilities {
    
    static func showLoader() {
        DispatchQueue.main.async {
            SwiftLoader.show(animated: true)
        }
    }
    
    static func hideLoader() {
        DispatchQueue.main.async {
            SwiftLoader.hide()
        }
    }
    
    static func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
