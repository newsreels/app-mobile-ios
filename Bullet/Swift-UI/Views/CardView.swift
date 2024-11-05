//
//  CardView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import SwiftUI

struct CardView <Content: View> : View {
    let cardIcon: CardIcon
    @ViewBuilder let content: () -> Content

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.white)
            .frame(width: 200, height: 57)
            .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 0)
            .overlay(
                HStack (spacing: 15){
                        cardIcon
                        content()
                    Spacer()
                }
                .padding(.leading, 12)
            )
   
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(cardIcon: .init(icon: .local(Image(systemName: "globe.americas.fill")), backgroundColor: .CardRed), content: {
            VStack {
                AppText("Russia Ukraine", size: 14)
            }
        })
    }
}

