//
//  Collection+safeArrayExtension.swift
//  Bullet
//
//  Created by Yeshua Lagac on 6/22/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
