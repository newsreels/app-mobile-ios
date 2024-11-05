//
//  SettingsSectionView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/4/22.
//

import SwiftUI

struct SettingsSectionView <Content: View> : View {
    var title: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack (alignment: .leading, spacing: 8){
            if let title = title {
                AppText(title, weight: .nunitoSemiBold, size: 13, color: .AppPinkPrimary)
                    .padding(.leading, 24)

            }
            content()
                .padding(.horizontal, 24)
                .background(background)

        }
    }
    
    var background: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .shadow(color: .AppShadow.opacity(0.07), radius: 0, x: 0, y: 0)
            .shadow(color: .AppShadow.opacity(0.07), radius: 1, x: 0, y: 0)
            .shadow(color: .AppShadow.opacity(0.06), radius: 1, x: 0, y: 1)
            .shadow(color: .AppShadow.opacity(0.04), radius: 2, x: 1, y: 2)
            .shadow(color: .AppShadow.opacity(0.04), radius: 2, x: 1, y: 4)
            .shadow(color: .AppShadow.opacity(0.00), radius: 2, x: 2, y: 7)
            .shadow(color: .AppShadow.opacity(0.06), radius: 1, x:02, y: -1)
    }
}

struct SettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSectionView(title: "Settings", content: {
            VStack (spacing: 0) {
                SettingsRowView(settings: .normal(iconName: "language_ic", title: "Primary Language"))
                SettingsRowView(settings: .normal(iconName: "language_ic", title: "Secondary Language"))
            }
           
        })
    }
}
