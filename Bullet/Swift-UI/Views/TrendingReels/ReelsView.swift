//
//  ReelsView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import SwiftUI

struct ReelsView: View {
    
    var reel: Reel
    var didTap : ((Reel) -> ())
    private let columnCount: CGFloat = 3
    var body: some View {
        
        AppURLImage(reel.image)
            .frame(width: (UIScreen.main.bounds.size.width - 64) / columnCount, height: 200)
            .overlay(LinearGradient(colors: [.black.opacity(0.5), .clear, .clear], startPoint: .bottom, endPoint: .top))
            .layoutPriority(1)
            .clipped()
            .cornerRadius(15)
            .onTapGesture {
                didTap(reel)
            }
        
    }
}

