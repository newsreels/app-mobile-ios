//
//  SocialNetworkView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/4/22.
//

import SwiftUI

struct SocialNetworkView: View {
    var body: some View {
        HStack (spacing: 46){
            Spacer()
            Image("social_ig_ic")
                .onTapGesture {
                    openLink(link: "https://www.instagram.com/newsreels.india/")
                }
            Image("social_fb_ic")
                .onTapGesture {
                    openLink(link: "https://www.facebook.com/newsreels.india")
                }
            Image("social_twitter_ic")
                .onTapGesture {
                    openLink(link: "https://twitter.com/newsreelsindia")
                }
            Image("social_youtube_ic")
                .onTapGesture {
                    openLink(link: "https://www.youtube.com/channel/UCqrv55WJ0UP7jSwBI8gt13w")
                }
            Image("social_tiktok_ic")
                .onTapGesture {
                    openLink(link: "https://www.tiktok.com/@newsreels.india")
                }
            Spacer()

        }
        .frame(height: 88)
        .background(Color.black)
    }
    
    private func openLink(link: String) {
        if let url = URL(string: link) {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}

struct SocialNetworkView_Previews: PreviewProvider {
    static var previews: some View {
        SocialNetworkView()
    }
}
