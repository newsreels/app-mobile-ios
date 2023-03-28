//
//  DiscoverData.swift
//  Bullet
//
//  Created by Yeshua Lagac on 6/20/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation

enum DiscoverContext: String {
    case topics = "TOPICS:TRENDING"
    case channels = "CHANNELS:TRENDING"
    case youtube = "YOUTUBE_LIVE"
    case article = "ARTICLE:ALL"
    case weather = "WEATHER:LOCAL"
    case reels = "REELS:NEW"
}

//struct NewDiscoverData: Decodable {
//    let articleContext: String
//    let articlePage: ArticlePage
//    let articles: [articlesData]?
//    let topics: [TopicData]?
//    let sources: [ChannelInfo]?
//    let authors: [Author]?
//    let reels: [Reel]?
//    let search: SearchHistory
//}
//

struct ArticlePage: Decodable {
    let next: String
}


protocol HomeFeedPostData: Decodable { }

struct NewDiscoverData: Decodable {
    let discover: [NewDiscoverSingleData]
}

struct NewSearchData: Decodable {
    let search: SearchHistory
    let data: [NewDiscoverSingleData]
}

struct NewDiscoverSingleData: Decodable {

    enum SubClassType: String, Decodable {
        case reels = "REELS"
        case articles = "ARTICLE"
        case channels = "CHANNELS"
        case topics = "TOPICS"
        case places = "PLACES"
        case finance = "FINANCE"
        case weather = "WEATHER"
        case sports = "SPORTS"
        case youtube = "YOUTUBE_LIVE"
        case stocks = "STOCK"
        case currency = "CURRENCY"
    }

    let title: String
    let type: SubClassType
    let country: String?
    let articles: [articlesData]?
    let topics: [TopicData]?
    let sources: [ChannelInfo]?
    let authors: [Author]?
    let reels: [Reel]?
    

}

//extension HomeFeedPost {
//    enum CodingKeys: String, CodingKey {
//        case title, type, content = "extraData"
//        // Unused keys: expires_on, created_at, updated_at, church, added_by
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        type = try container.decode(SubClassType.self, forKey: .type)
//
//        switch type {
//        case .reels:
//            content = try container.decode([Reel].self, forKey: .title)
//        case .articles:
//            content = try container.decode([articlesData].self, forKey: .title)
//        case .topics:
//            content = try container.decode(TopicData.self, forKey: .title)
//        case .channels:
//            content = try container.decode(ChannelInfo.self, forKey: .title)
//        }
//
//    }
//}
