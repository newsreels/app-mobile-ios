//
//  UserChannelsDC.swift
//  Bullet
//
//  Created by Faris Muhammed on 20/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation

// MARK: - UserChannelsDC
struct UserChannelsDC: Codable {
    var data: [DataChannels]?
    var profile: UserProfile?
}

// MARK: - Data
struct DataChannels: Codable {
    var channels: [ChannelInfo]?
    var title: String?
    
}

