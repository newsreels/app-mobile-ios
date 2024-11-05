//
//  DiscoverModel.swift
//  Bullet
//
//  Created by Faris Muhammed on 31/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation

// MARK: - DiscoverModel
struct DiscoverModel: Codable {
    var discover: [DiscoverData]?
    var meta: Meta?
    var lastModified: String?
}

// MARK: - Discover
struct DiscoverData: Codable {
    var title, type: String?
    var data: DiscoverItem?
}

// MARK: - DataClass
struct DiscoverItem: Codable {
    
    var large: Bool?
    var reels: [Reel]?
    var topics: [TopicData]?
    var article: articlesData?
    var top: Bool?
    var articles: [articlesData]?
    var locations: [Location]?
    var sources: [ChannelInfo]?
    var authors: [Author]?
    
}

enum Language: String, Codable {
    case ar = "ar"
    case en = "en"
}


// MARK: - ArticleSource
struct ArticleSource: Codable {
    var id, context, name: String?
    var link: String?
    var icon: String?
}

enum TypeEnum: String, Codable {
    case extended = "EXTENDED"
    case image = "IMAGE"
    case simple = "SIMPLE"
    case video = "VIDEO"
    case youtube = "YOUTUBE"
}

enum Country: String, Codable {
    case iran = "Iran"
    case oman = "Oman"
    case unitedArabEmirates = "United Arab Emirates"
}


// MARK: - SourceElement
struct SourceElement: Codable {
    var id, context, name, sourceDescription: String?
    var link: String?
    var icon, image, backgroundImage: String?
    var language, category: String?
    var followerCount: Int?
    var favorite, verified: Bool?

    enum CodingKeys: String, CodingKey {
        case id, context, name
        case sourceDescription = "description"
        case link, icon, image
        case backgroundImage = "background_image"
        case language, category
        case followerCount = "follower_count"
        case favorite, verified
    }
}

