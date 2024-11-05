//
//  SectionTitleView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import SwiftUI

struct SectionTitleView: View {
    let title: String
    let onTapSeeAll : (() -> ())
    var textColor: Color = .black
    var body: some View {
        HStack {
            AppText(title, weight: .semiBold, size: 20, color: textColor)
            Spacer()
//            AppButton(title: "See more", textColor: .AppBlue, fontSize: 14, font: .regular, padding: 0) {
//                onTapSeeAll()
//            }
        }
    }
}

struct SectionTitleView_Previews: PreviewProvider {
    static var previews: some View {
        SectionTitleView(title: "Trending Topics", onTapSeeAll: {
            
        })
        .previewLayout(.sizeThatFits)
    }
}
