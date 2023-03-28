//
//  channelListDC.swift
//  Bullet
//
//  Created by Faris Muhammed on 15/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation

// MARK: - ChannelListDC
struct ChannelListDC: Codable {
    
    var channels: [ChannelInfo]?
    var channel: ChannelInfo?
    var message: String?
}

// MARK: - Channel
struct ChannelInfo: Codable {
    var id, context, name, channelDescription, link: String?
    var icon, name_image, portrait_image, image: String?
    var updateCount: Int?
    var channelModelType: String?
    var follower_count, post_count: Int?
    var own, hasReel, hasArticle, favorite, verified: Bool?
    var language: String?
    var category: String?
    var isShowingLoader: Bool?
    var isUserBlocked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, context, name, language, category
        case channelDescription = "description"
        case link, icon, image, name_image, portrait_image
        case updateCount = "update_count"
        case channelModelType
        case follower_count, post_count
        case hasReel = "has_reel"
        case hasArticle = "has_article"
        case own, favorite, verified
        case isShowingLoader
        case isUserBlocked
    }
}


public struct sourcesData: Codable {
    
    var id: String?
    var context: String?
    var name: String?
    var link: String?
    var image: String?
    var icon: String?
    var color: String?
    var location: sourceLocationData?
    var language: String?
    var category: String?
    var favorite: Bool?
    var pagination: String?
    let name_image: String?
}
