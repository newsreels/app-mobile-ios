//
//  CricketCard.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import SwiftUI

struct BasketballCard: View {
    let basketball : BasketballStage
    
    
    var firstEvent: BasketballSportEvent {
        return basketball.events.first!
    }
    
    var isFirstTeamWin: Bool {
        if let team1Score = basketball.events.first?.team1Score, let team2Score = basketball.events.first?.team2Score{
            return team1Score > team2Score
        }
        return false
    }
    
    var body: some View {
        VStack (alignment: .leading){
            HStack {
                AppText(basketball.eventName, weight: .semiBold, size: 15)
                AppText("●", weight: .extraLightItalic, size: 10)
                AppText(basketball.league, weight: .medium, size: 15)
            }
            .padding(.bottom, 20)
            
            HStack {
                AppURLImage(firstEvent.team1.first?.logoURL)
                    .scaledToFit()
                    .frame(width: 25)
                AppText(firstEvent.team1.first!.name, weight: .semiBold, size: 14)
                Spacer()
                if let t1Score = basketball.events.first?.team1Score {
                    AppText(t1Score, weight: .semiBold, size: 14)
                } else {
                    AppText("-", weight: .semiBold, size: 14)
                }
            }
            
            HStack {
                AppURLImage(firstEvent.team2.first?.logoURL)
                    .scaledToFit()
                    .frame(width: 25)
                    
                AppText(firstEvent.team2.first!.name, weight: .semiBold, size: 14)
                Spacer()
                if let t2Score = basketball.events.first?.team2Score {
                    AppText(t2Score, weight: .semiBold, size: 14)
                } else {
                    AppText("-", weight: .semiBold, size: 14)
                }
                
            }
            
            if let seriesInfo = basketball.events.first?.seriesInfo {
                AppText("Game \(seriesInfo.currentLeg) of \(seriesInfo.totalLegs) - \(isFirstTeamWin ? firstEvent.team1.first!.name : firstEvent.team2.first!.name) Wins", weight: .thin, size: 13)
                    .padding(.top, 10)
            } else {
                AppText("No info", weight: .thin, size: 13)
                    .padding(.top, 10)
            }
            


        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
    }
}
