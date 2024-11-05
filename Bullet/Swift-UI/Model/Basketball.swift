//
//  Basketball.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/9/22.
//

import Foundation


// MARK: - Basketball
struct BasketballData: Decodable {
    var id = UUID()
    let stages: [BasketballStage]

    enum CodingKeys: String, CodingKey {
        case stages = "Stages"
    }
}

struct BasketballStage: Decodable {
    let eventName : String
    let league: String
//    let country: String
    let events: [BasketballSportEvent]
    let quarter: String?
    
    
    enum CodingKeys: String, CodingKey {
        case eventName = "Snm", league = "Cnm",
//             country = "Ccdiso",
             events = "Events", quarter = "Eps"
    }
}


// MARK: - Event
struct BasketballSportEvent: Decodable {
    let team1: [BasketballSportTeam]
    let team2: [BasketballSportTeam]
    let team1Score: String?
    let team2Score: String?
    let seriesInfo: BasketballSeriesInfo?

    enum CodingKeys: String, CodingKey {
        case team1 = "T1", team2 = "T2", team1Score = "Tr1", team2Score = "Tr2", seriesInfo
    }
}

struct BasketballSeriesInfo: Decodable {
    let totalLegs: Int
    let currentLeg: Int
    let scoreTeam1: Int
    let scoreTeam2: Int
    
    enum CodingKeys: String, CodingKey {
        case totalLegs, currentLeg, scoreTeam1 = "aggScoreTeam1", scoreTeam2 = "aggScoreTeam2"
    }
    
}

// MARK: - Team
struct BasketballSportTeam: Decodable {
    let name: String
    let logo: String?
    
    var logoURL: String? {
        if let logo = logo {
            return "https://lsm-static-prod.livescore.com/high/\(logo)"
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "Nm" , logo = "Img"
    }
}
