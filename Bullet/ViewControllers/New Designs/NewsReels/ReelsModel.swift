//
//  ReelsModel.swift
//  Bullet
//
//  Created by Faris Muhammed on 29/03/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation

// MARK: - ReelsModel
struct ReelsModel: Codable {
    let meta: ReelsModelMeta?
    var reels: [Reel]?
}

// MARK: - ReelsModelMeta
struct ReelsModelMeta: Codable {
    let next: String?
}

// MARK: - Reel
struct Reel: Codable {
    let id, context, reelDescription: String?
    var media: String?
    let media_landscape: String?
    let mediaMeta: MediaMeta?
    let publishTime: String?
    var source: ChannelInfo?
    var info: Info?
    var authors: [Authors]?
    var captions: [Captions]? = nil
    var image: String?
    var status: String? = nil
    var iosType: String? = nil
    var link: String?
    var language: String?
    var captionAPILoaded: Bool? = true
    var nativeTitle: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, context
        case reelDescription = "description"
        case media,media_landscape
        case publishTime = "publish_time"
        case source, authors
        case info
        case mediaMeta = "media_meta"
        case image
        case link, language
        case nativeTitle = "native_title"
    }
}

struct MediaMeta: Codable {
    
    let duration: Double?
    let height: Double?
    let width: Double?
    let type: String?
}


//// MARK: - ReelMeta
//struct ReelMeta: Codable {
//    let viewCount: String?
//
//    enum CodingKeys: String, CodingKey {
//        case viewCount = "view_count"
//    }
//}

// MARK: - Source
//struct VideoSource: Codable {
//    let id, context, name: String?
//    let link: String?
//    let image, icon: String?
//    let backgroundImage, color: String?
//    let location: Location?
//    let language, category: String?
//    let favorite: Bool?
//
//    enum CodingKeys: String, CodingKey {
//        case id, context, name, link, image, icon
//        case backgroundImage = "background_image"
//        case color, location, language, category, favorite
//    }
//}

// MARK: - Location
struct Location: Codable {
    
    var id, name, context: String?
    var image: String?
    let city, county, state, country: String?
    var favorite: Bool?
    let global: Bool?
    let point: Point?
    var flag: String?
    var isShowingLoader: Bool?
}

// MARK: - Point
struct Point: Codable {
    let latitude, longitude: Int?
}
