//
//  AboutView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/7/22.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack (alignment: .leading){
                Image("blogging")
                    .scaledToFill()
                    .padding(.top, 32)
                AppText("Newsreels \(Bundle.main.releaseVersionNumber ?? "")", weight: .robotoSemiBold, size: 24, color: .black)
                    .padding(.top, 32)
                    .padding(.horizontal)
                AppText("Keeping updated about the news stories you love should not take too much of your time. Newsreels takes the regular 5-minute read and condense it into easily digestible bullets. Now, you can take in the same newsin just a fraction of the time - so you can read more in less time.", weight: .robotoRegular, size: 16, color: .AppSecondaryBlack)
                    .padding(.top, 16)
                    .padding(.horizontal)
                Spacer()
            }
        }
        
        
        .background(Color.AppBG)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBar(title: "About")
        
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

