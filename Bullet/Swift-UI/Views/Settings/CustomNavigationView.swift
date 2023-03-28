//
//  CustomNavigationView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/4/22.
//

import SwiftUI

struct CustomNavigationView: View {
    @StateObject var settings = PushManager.shared

    let title: String
    var body: some View {
        ZStack {
            HStack {
                AppText(title, weight: .robotoBold, size: 16)
            }
            HStack {
                Button {
                    settings.isActive = false
                } label: {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .foregroundColor(.black)
                        .scaledToFit()
                        .frame(width: 17, height: 17, alignment: .leading)
                }
                .padding(.leading, 16)

                Spacer()
            }
        }
        .padding(.vertical, 16)
    }
}

struct CustomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationView(title: "Settings")
    }
}
