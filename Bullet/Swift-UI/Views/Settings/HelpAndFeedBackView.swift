//
//  HelpAndFeedBackView.swift
//  Bullet
//
//  Created by Yeshua Lagac on 8/15/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import SwiftUI

struct HelpAndFeedBackView: View {
    
    @StateObject var settings = PushManager.shared

    var body: some View {
        VStack {
            SettingsSectionView {
                VStack {
                    SettingsRowView(settings: .normal(iconName: "helpCenterIC", title: "Help Center"), showDivider: true) {
                        EmailHelper.shared.sendEmail(subject: "Help Center", body: "", to: "contact@newsreels.app")
                    }
                    
                    SettingsRowView(settings: .normal(iconName: "bugIC", title: "Report A Problem"), showDivider: true) {
                        EmailHelper.shared.sendEmail(subject: "Report A Problem", body: "", to: "contact@newsreels.app")
                    }

                    SettingsRowView(settings: .normal(iconName: "supportRequestIC", title: "Support Request")) {
                        EmailHelper.shared.sendEmail(subject: "Report A Problem", body: "", to: "contact@newsreels.app")
                    }
                    
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.AppBG)
        .navigationBar(title: "Help & Feedback")

    }
}

struct HelpAndFeedBackView_Previews: PreviewProvider {
    static var previews: some View {
        HelpAndFeedBackView()
    }
}
