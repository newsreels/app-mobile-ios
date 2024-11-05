//
//  CricketCard.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import SwiftUI

struct CricketCard: View {
    let cricket : CricketStage
    
    var firstEvent: CricketSportEvent {
        return cricket.events.first!
    }
    
    var isFirstTeamWin: Bool {
        if let team1ScoreAbove = firstEvent.team1ScoreAbove, let team2ScoreAbove = firstEvent.team2ScoreBelow{
            return team1ScoreAbove > team2ScoreAbove
        }
        return false
    }
    
    var body: some View {
        VStack (alignment: .leading){
            HStack {
                if firstEvent.description == "Not Started" {
                    AppText("RESULT", weight: .semiBold, size: 15)
                    AppText("●", weight: .extraLightItalic, size: 10)
                } else {
                    AppText(cricket.league, weight: .semiBold, size: 15)
//                    AppText("●", weight: .extraLightItalic, size: 10)
//                    AppText(cricket.country, weight: .medium, size: 15)
                    AppText("●", weight: .extraLightItalic, size: 10)
                }
                
                AppText(firstEvent.description, weight: .medium, size: 15)

            }
            .padding(.bottom, 20)
            
            HStack {
                AppText(firstEvent.team1.first!.name, weight: .semiBold, size: 14, color: isFirstTeamWin ? .black : .gray)
                Spacer()
                if let scoreAbove = firstEvent.team1ScoreAbove, let scoreBelow = firstEvent.team1ScoreBelow, let scroreParenthesis = firstEvent.team1ScoreParenthesis {
                    HStack {
                        AppText("\(scoreAbove)/\(scoreBelow)", weight: .semiBold, size: 14, color: isFirstTeamWin ? .black : .gray)
                        AppText("(\(scroreParenthesis))", weight: .regular, size: 12, color: .gray)
                    }
                } else {
                    AppText("-", weight: .semiBold, size: 14)
                }
            }
            
            HStack {
                AppText(firstEvent.team2.first!.name, weight: .semiBold, size: 14, color: isFirstTeamWin ? .gray : .black)
                Spacer()
                if let scoreAbove = firstEvent.team2ScoreAbove, let scoreBelow = firstEvent.team2ScoreBelow, let scroreParenthesis = firstEvent.team2ScoreParenthesis {
                    HStack {
                        AppText("\(scoreAbove)/\(scoreBelow)", weight: .semiBold, size: 14, color: isFirstTeamWin ? .gray : .black)
                        AppText("(\(scroreParenthesis))", weight: .regular, size: 12, color: .gray)
                    }
                } else {
                    AppText("-", weight: .semiBold, size: 14)
                }
//
//                AppText(firstEvent.team2.first!.name, weight: .semiBold, size: 14, color: .secondary)
//                Spacer()
//                AppText("20 ov. T:166", size: 11, color: .secondary)
//                AppText("165/7", weight: .semiBold, size: 14, color: .secondary)
            }
            
            AppText(firstEvent.bottomDescription, weight: .thin, size: 13)
                .padding(.top, 10)
            
//            Divider()
//                .padding(.vertical, 10)
//
//            HStack (spacing: 20){
//                AppText("Schedule", weight: .medium, size: 16)
//                AppText("Table", weight: .medium, size: 16)
//                AppText("Report", weight: .medium, size: 16)
//            }
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
    }
}
