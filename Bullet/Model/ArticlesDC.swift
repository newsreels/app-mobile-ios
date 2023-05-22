//
//  NewsCategoryDC.swift
//  Bullet
//
//  Created by Mahesh on 13/04/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import Foundation
import UIKit

//MARK: - RootClass
public struct articlesDC: Codable {
    
    var reels: [Reel]?
    var articles: [articlesData]?
    var group_articles: [articlesData]?
    var meta: MetaData?
    var title: String?
}

//MARK: - RootClass
public struct communityArticlesDC: Codable {
    
    var articles: [articlesData]?
    var meta: MetaData?
    var authors: [Author]?
    var reels: [Reel]?
    var suggested_authors: Int?
    var suggested_reels: Int?
}

//MARK: - Related Reels
public struct relatedReelsDC: Codable {
    
    var articles: [articlesData]?
    var meta: MetaData?
    var reels: [Reel]?
}

//MARK: - For You
public struct forYouDC: Codable {
    
    var data: [forYouData]?
    var meta: MetaData?
}

public struct forYouData: Codable {
    
    var id: String?
    var title: String?
    var image: String?
    var header: String?
    var footer: String?
    var icon: String?
    var articles: [articlesData]?
}


//MARK:- View Article
public struct viewArticleDC: Codable {
    
    var article: articlesData?
    var message: String?
}


//MARK: - articles
public struct articlesData: Codable {
    
    var id : String?
    var title : String?
    var subheader : String?
    var media : String?
    var image : String?
    var link : String?
    var original_link : String?
    var color: String?
    var publish_time : String?
    var publishTime : String? // For new network layer purposes
    var source: ChannelInfo?
    var bullets: [Bullets]?
    var topics: [TopicData]?
    var status : String?
    var mute: Bool?
    var type: String?
    var meta: MetaData?
    var info: Info?
    var authors: [Authors]?
    var media_meta: MediaMeta?
    var language: String?
    var icon: String?
    var suggestedAuthors: [Author]?
    var suggestedReels: [Reel]?
    var suggestedChannels: [ChannelInfo]?
    var suggestedFeeds: [articlesData]?
    var suggestedTopics: [TopicData]?
    var subType: String?
    var followed: Bool?
    var footer: footer?
}

public struct socialData: Codable {
    
    var info : Info?
}


public struct Info: Codable {
    var viewCount: String?
    var views: Int? = nil
    var likeCount: Int?
    var commentCount: Int?
    var isLiked: Bool?
    var socialLike: Int?

    init(viewCount: String?, likeCount: Int?, commentCount: Int?, isLiked: Bool?, socialLike: Int?) {
        self.viewCount = viewCount
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isLiked = isLiked
        self.socialLike = socialLike
    }
    
    enum CodingKeys: String, CodingKey {
        case viewCount = "view_count"
         case views
         case likeCount = "like_count"
         case commentCount = "comment_count"
         case isLiked = "is_liked"
         case socialLike = "social_like"
    }
}

public struct Bullets : Codable, Equatable {
    
    var data : String?
    var audio : String?
    var duration : Double?
    var image : String?
    var index : Int?
    var iosBulletType: String?

    public static func == (lhs: Bullets, rhs: Bullets) -> Bool {
         return lhs.image == rhs.image
     }
}

//MARK: - source
//struct sourceData : Codable {
//
//    var id : String?
//    var created_at : String?
//    var updated_at : String?
//    var name : String?
//    var link : String?
//    var image : String?
//}

//MARK: - Bullet
public struct bulletsData: Codable {
    
    var id: String?
//    var created_at: String?
//    var updated_at: String?
    var data: String?
}


//MARK: - Bullet Error
public struct errorDC: Codable {
    
    var error: messageData?
}

public struct messageData: Codable {
    var success: Bool?
    var message: String?
}


struct articleReportListDC : Codable {
    
    let concerns : [String]?
}


//MARK:- Home Feed page Model
public struct feedInfoDC: Codable {
    
    let sections: [sectionsData]?
    let meta: MetaData?
}

struct sectionsData: Codable {
    
    let type: String?
    let data: dataInfo?
}

struct dataInfo: Codable {
    
    let banner_header: String?
    let header: String?
    var subheader : String?
    let footer: footer?
    let context: String?
    
    let article: articlesData?
    let articles: [articlesData]?
    let reels: [Reel]?
    let topics: [TopicData]?
    let channels: [ChannelInfo]?
    let followed: Bool?
    let topic: topicHorizontal?
}

struct topicHorizontal: Codable {
    
    let followed: Bool?
    let followed_text: String?
    let id: String?
    let image: String?
    let unfollowed_text: String?
}

struct footer: Codable {

    var prefix: String?
    var title: String?
}
