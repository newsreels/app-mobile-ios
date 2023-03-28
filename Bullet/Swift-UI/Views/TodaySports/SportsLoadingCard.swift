//
//  SportsLoadingCard.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/10/22.
//

import SwiftUI

struct SportsLoadingCard: View {
    var body: some View {
        VStack (alignment: .leading){
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: UIScreen.main.bounds.size.width - 130, height: 16)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 7, x: 0, y: 9)

            }
            .padding(.bottom, 20)
            
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 140, height: 15)
                    .cornerRadius(7)
                    .shadow(color: .black.opacity(0.1), radius: 7, x: 0, y: 9)
                Spacer()
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 70, height: 15)
                        .cornerRadius(7)
                        .shadow(color: .black.opacity(0.1), radius: 7, x: 0, y: 9)
                }
            }
            
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 105, height: 15)
                    .cornerRadius(7)
                    .shadow(color: .black.opacity(0.1), radius: 7, x: 0, y: 9)
                Spacer()
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 70, height: 15)
                        .cornerRadius(7)
                        .shadow(color: .black.opacity(0.1), radius: 7, x: 0, y: 9)
                }
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 190, height: 14)
                .cornerRadius(6)
                .shadow(color: .black.opacity(0.1), radius: 7, x: 0, y: 9)
                .padding(.top, 10)
            

        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
    }
}

struct SportsLoadingCard_Previews: PreviewProvider {
    static var previews: some View {
        SportsLoadingCard()
    }
}
