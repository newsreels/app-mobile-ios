//
//  Cricket.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/9/22.
//

import Foundation


// MARK: - Cricket
struct CricketData: Decodable {
    var id = UUID()
    let stages: [CricketStage]

    enum CodingKeys: String, CodingKey {
        case stages = "Stages"
    }
}

struct CricketStage: Decodable {
    let eventName : String
    let league: String
//    let country: String
    let events: [CricketSportEvent]
    let quarter: String?
    
    enum CodingKeys: String, CodingKey {
        case eventName = "Snm"
        case league = "Cnm"
//        case country = "Ccdiso"
        case events = "Events"
        case quarter = "Eps"
    }
}

// MARK: - Event
struct CricketSportEvent: Decodable {
    let team1: [CricketSportTeam]
    let team2: [CricketSportTeam]
    let description: String
    let bottomDescription: String

    let team1ScoreAbove: Int?
    let team1ScoreBelow: Int?
    let team1ScoreParenthesis: Double?
    let team2ScoreAbove: Int?
    let team2ScoreBelow: Int?
    let team2ScoreParenthesis: Double?

    enum CodingKeys: String, CodingKey {
        case team1ScoreAbove = "Tr1C1"
        case team1ScoreBelow = "Tr1CW1"
        case team1ScoreParenthesis = "Tr1CO1"
        case team2ScoreAbove = "Tr2C1"
        case team2ScoreBelow = "Tr2CW1"
        case team2ScoreParenthesis = "Tr2CO1"
        case team1 = "T1"
        case team2 = "T2"
        case description = "EpsL"
        case bottomDescription = "ECo"
    }

}


// MARK: - Team
struct CricketSportTeam: Decodable {
    let name: String
    let logo: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "Nm" , logo = "Img"
    }
}
