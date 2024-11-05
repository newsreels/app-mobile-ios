//
//  SettingsRowView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/4/22.
//

import SwiftUI

enum SettingsRow {
    case normal(iconName: String? = nil, title: String)
    case selection(iconName: String, title: String, description: String)
    case switchToggle(iconName: String? = nil, title: String, value: Binding<Bool>)
}

struct SettingsRowView: View {

    let settings : SettingsRow
    var showDivider: Bool = true
    var action: (() -> ())? = nil
    var body: some View {
        VStack (spacing: 0){
            HStack (spacing: 0){
                switch settings {
                case let .normal(iconName: iconName, title: title):
                    if let iconName = iconName {
                        iconView(iconName: iconName)
                    }
                    AppText(title, weight: .robotoRegular, size: 14)
                        .padding(.leading, 16)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .font(.app(size: 14))
                        .opacity(0.8)
                case let .selection(iconName: iconName, title: title, description: description):
                    iconView(iconName: iconName)
                    AppText(title, weight: .robotoRegular, size: 14)
                        .padding(.leading, 16)
                    Spacer()
                    AppText(description, weight: .robotoBold, size: 14)
                            .padding(.trailing, 11)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .font(.app(size: 14))
                        .opacity(0.8)
                case let .switchToggle(iconName: iconName, title: title, value: value):
                    if let iconName = iconName {
                        iconView(iconName: iconName)
                            .padding(.trailing, 13)
                    }
                    AppText(title, weight: .robotoRegular, size: 14)
                    Spacer()
                    SwitchView(selected: value) { value in
                        
                    }

                }
            }
            .background(Color.white)
            .onTapGesture {
                if let action = action {
                    action()
                }
            }
            .padding(.vertical, 16)
            if showDivider {
                dividerView
            }
        }
    }
    
    @ViewBuilder
    func iconView(iconName: String) -> some View {
        Image(iconName)
    }
        
        var dividerView: some View {
            Rectangle()
                .fill(Color.AppSecondaryGray)
                .frame(height: 0.5)
            
        }
}

struct SettingsRowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRowView(settings: .selection(iconName: "language_ic", title: "Primary Language", description: "English"))
    }
}
