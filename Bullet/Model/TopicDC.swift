//
//  TopicDC.swift
//  Bullet
//
//  Created by Mahesh on 18/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import Foundation

//MARK: - RootClass
public struct TopicDC: Codable {
    
    var meta: MetaData?
    var topics: [TopicData]?
    
}

public struct MetaData: Codable {
    
    var next: String?
    var view_count: String?
    
}

public struct TopicData: Codable {
    
    var id: String?
    var context: String?
    var name: String?
    var icon: String?
    var link: String?
    var image: String?
    var color: String?
    var favorite: Bool?
    var pagination: String?
    var isShowingLoader: Bool?
    
}

//MARK: - RootClass

struct userFollowDC: Codable {
    
    var locations : [Location]?
    var sources: [ChannelInfo]?
    var topics: [TopicData]?
    
    var meta: MetaData?
}


public struct sourcesDC: Codable {
    
    var meta: MetaData?
    var sources: [ChannelInfo]?
}



public struct sourceLocationData: Codable {
    
    var city: String?
    var county: String?
    var state: String?
    var country: String?
    var global: Bool?
    var point: pointData?
}

public struct pointData: Codable {
    
    var latitude: Double?
    var longitude: Double?
}

//MARK: - RootClass- add topics
public struct AddTopicDC: Codable {
    
    var topics: [TopicData]?
    
}

//MARK: - RootClass- add source
public struct AddSourceDC: Codable {
    
    var sources: [sourcesData]?
}

//MARK: - RootClass- add topics
public struct DeleteTopicDC: Codable {
    
    var message: String?
}

public struct DeleteSourceDC: Codable {
    
    var message: String?
}

//MARK: - RootClass- Sub topics
public struct SubTopicDC: Codable {
    
    var topics: [TopicData]?

}

//MARK: - RootClass- block topics
public struct BlockTopicDC: Codable {
    
    var message: String?
    
}

public struct messageDC: Codable {
     
    var valid: Bool?
    var status: Bool?
    var message: String?
}


//MARK: - RootClass- Share Model
public struct ShareSheetDC: Codable {
    
    var share_message: String?
    var source_blocked: Bool?
    var source_followed: Bool?
    var article_archived: Bool?
    var author_blocked: Bool?
    var media:String?
    var download_link: String?
    
}

public struct updateSourceDC: Codable {
    
    var message: String?
    
}

public struct updateTopicDC: Codable {
    
    var message: String?
    
}


//MARK: - RootClass- Language
public struct LanguagesDC: Codable {
    
    var languages: [languagesData]?
    var meta: MetaData?
}


public struct languagesData: Codable {
    
    var id: String?
    var name: String?
    var code: String?
    var sample: String?
    var image: String?
    var favorite: Bool?
}


//MARK: - RootClass - Upload User Image
public struct updateProfileDC: Codable {
    
    var success: Bool?
    var message: String?
    var user: UserProfile?
    

}

//MARK: - User Profile Details
public struct UserProfile: Codable {
    
    var email: String?
    var isGuest: Bool {
        if let email = email {
            return email.isEmpty
        }
        return true
    }
    var hasPassword: Bool?
    var id: String?
    var setup: Bool?
    var language: String?
    var guestValid: Bool?
    var username: String?
    var first_name: String?
    var last_name: String?
    var profile_image: String?
    var cover_image: String?
    var follower_count: Int?
    var post_count: Int?
    var favorite: Bool?
    
}


