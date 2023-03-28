//
//  SwitchView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/4/22.
//

import SwiftUI

struct SwitchView: View {
    
    @Binding var selected: Bool
    let valueChanged: (Bool) -> Void

    var body: some View {
        ZStack {
            Capsule().foregroundColor(selected ? .AppPinkPrimary : .gray.opacity(0.5))
            
            Circle()
                .frame(width: 12, height: 12, alignment: .center)
                .foregroundColor(Color.white)
                .shadow(color: Color.black.opacity(selected ? 0 : 0.1), radius: 6, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 2)
                .offset(x: selected ? 7.5 : -7.5 , y: -0.3)
        }
        .padding(1.6)
        .frame(width: 33, height: 18, alignment: .center)
        .onTapGesture(count: 1, perform: {
            withAnimation { selected.toggle() }
            self.valueChanged(selected)
        })
    }
}
