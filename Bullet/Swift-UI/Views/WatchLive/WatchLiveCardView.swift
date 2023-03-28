//
//  WatchLiveCardView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/6/22.
//

import SwiftUI

struct WatchLiveCardView: View {
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            HStack (alignment: .top){
                Image("teampayaman")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
                Spacer()
                
                HStack (spacing: 5){
                    AppText("LIVE", weight: .semiBold, size: 10, color: .white)
                    Circle().fill(Color.white).frame(width: 5, height: 5)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.red.cornerRadius(20))
                    
            }
          
            AppText("Team Payaman", weight: .semiBold, size: 18)
            AppText("Lorem ipsum is simply dummy text of printing. Lorem ipsum is simply dummy text of printing. Lorem ipsum is simply dummy text of printing. Lorem ipsum is simply dummy text of printing", size: 14, color: .gray)
        }
        .padding()
        .background(Color.white)
        .frame(width: 250, height: 200)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 0)
    }
}

struct WatchLiveCardView_Previews: PreviewProvider {
    static var previews: some View {
        WatchLiveCardView()
            .previewLayout(.sizeThatFits)
    }
}
