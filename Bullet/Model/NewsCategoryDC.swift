//
//  NewsCategoryDC.swift
//  Bullet
//
//  Created by Mahesh on 13/04/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import Foundation

//MARK: - RootClass
public struct NewsCategoryDC: Codable {
    
    public var category: Category?
    var next_page: Int?
    var prev_category: Int?
    var next_category: Int?
    var current_page: Int?
    var current_category: Int?
    var total_categories: Int?
}

//MARK: - Category
public struct Category: Codable {
    
    public var name: String?
    public var contents: [BulletContent]?
}

struct newsConentsDC : Codable {
    
    let contents : [BulletContent]?
    
}

//MARK: - Content
public struct BulletContent: Codable {
    
    var bullets : [Bullet]?
    var image : String?
    var source_link : String?
    var source_name : String?
    var title : String?
    var tint: Int?
    var color: String?
    var publish_time: String?
}

//MARK: - Bullet
public struct Bullet: Codable {
    
    public var data : String?
    var audio: String?
    var duration: Int?
    var image: String?
}

//MARK: - RootClass
public struct categoryMenuDC: Codable {
    
    var category: [categoryMenu]?
    var total_categories: Int?
}

struct categoryMenu: Codable {
    
    var name: String?
    var icon: String?
    
    init(name: String, icon: String) {
        
        self.name = name
        self.icon = icon
    }
}

//MARK: - RootClass -Play news API
public struct contentsPlayDC: Codable {
    
    var contents: [BulletContent]?
    var interval_seconds: Int?
}

