//
//  ConditionalExtensions.swift
//  Bullet
//
//  Created by Yeshua Lagac on 6/28/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}

extension Bool {
    static var iOS15: Bool {
        if #available(iOS 15, *) {
            return true
        }
        return false
    }
    
    static var iOS14: Bool {
        if #available(iOS 14, *) {
            return true
        }
        return false
    }
}
