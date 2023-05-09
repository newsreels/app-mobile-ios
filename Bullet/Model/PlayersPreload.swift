//
//  PlayersPreload.swift
//  Bullet
//
//  Created by Osman on 24/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import Foundation
import AVFoundation

class PlayerPreloadModel {
    var index: Int
    var timeCreated: Date
    var id: String
    var player: NRPlayer
    
    init(index: Int, timeCreated: Date, id: String, player: NRPlayer) {
        self.index = index
        self.timeCreated = timeCreated
        self.id = id
        self.player = player
    }
}
