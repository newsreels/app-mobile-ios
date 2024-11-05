//
//  HistoryData.swift
//  Bullet
//
//  Created by Yeshua Lagac on 6/17/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation

struct HistoryData: Decodable {
    
    let histories: [SearchHistory]
    
    enum CodingKeys: String, CodingKey {
        case histories = "history"
    }
    
}

struct SearchHistory: Decodable {
    let id: String
    let searchText: String
    
    enum CodingKeys: String, CodingKey {
        case id, searchText = "search"
    }
    
}
