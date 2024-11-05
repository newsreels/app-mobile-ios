//
//  Binding+onChangeExtension.swift
//  NewsReels
//
//  Created by Yeshua Lagac on 6/24/21.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}
