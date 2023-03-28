//
//  TopicDC.swift
//  Bullet
//
//  Created by Mahesh on 18/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import Foundation

//MARK: - RootClass
public struct SearchSuggestionDC: Codable {
    
    var result: [suggestionsData]?
    
}

public struct suggestionsData: Codable {
    
    var title: String?
    var type: String?
    var data: [searchData]?
}

public struct searchData: Codable {

    var id: String?
    var name: String?
    var icon: String?
    var image: String?
    var color: String?
    var favorite: Bool?
}


//MARK: - RootClass
public struct SearchResultDC: Codable {
    
    var result: [resultData]?
    
}

public struct resultData: Codable {
    
    var type: String?
    var data: [searchData]?
}


//MARK: - RootClass
public struct SearchTopicDC: Codable {
    
    var followed: [TopicData]?
    var new: [TopicData]?
    var limit: Int?
}

public struct SearchSourceDC: Codable {
    
    var followed: [ChannelInfo]?
    var new: [ChannelInfo]?
    var limit: Int?
}



