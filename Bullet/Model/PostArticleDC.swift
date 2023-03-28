//
//  PostArticleDC.swift
//  Bullet
//
//  Created by Mahesh on 10/05/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation


// MARK: - User
struct UploadSuccessDC: Codable {
    
    let success: Bool?
    let results: String?
    let key: String?
}

public struct postArticlesDC: Codable {
    
    var article: articlesData?
    var message: String?
    var errors: errors?
}

// MARK: - Error Model
struct errors: Codable {
    
    let source: String?
    let link: String?
    let title: String?
    let name: String?
}

// MARK: - Reels
struct reelDC: Codable {
    
    let reel: reelData?
    var message: String?
    var errors: errors?
}

public struct reelData: Codable {
    
    var id : String?
    var context: String?
    var description : String?
    var image : String?
    var media : String?
    var media_meta: MediaMeta?
    var publish_time : String?
    var source: ChannelInfo?
    var info: Info?
    var authors: [Authors]?
    var status: String?
    var language: String?

}

// MARK: - Reels
struct suggestedReelDC: Codable {
    
    let reels: [Reel]?
}


//"reel": {
//  "id": "e5354dc9-944b-4cdc-a460-ebc52cc3bd72",
//  "description": "adsa",
//  "image": "https://cdn.newsinbullets.app/static/placeholder.png",
//  "media": "",
//  "media_meta": {
//    "duration": 0,
//    "height": 0,
//    "width": 0
//  },
//  "publish_time": "2021-08-07T10:13:44.235383469Z",
//  "source": null,
//  "info": {
//    "view_count": "",
//    "views": 0,
//    "like_count": 0,
//    "comment_count": 0,
//    "is_liked": false
//  },
//  "authors": [
//    {
//      "id": "d368a987-8c53-46a5-bd1e-0a177e139055",
//      "context": "QVVUSE9SKioqKipkMzY4YTk4Ny04YzUzLTQ2YTUtYmQxZS0wYTE3N2UxMzkwNTU=",
//      "name": "Mahesh Mk",
//      "username": "",
//      "image": "https://cdn.staging.newsinbullets.app/account/user/e042e2c4-3b0a-4df5-afb9-a480ed635a22/profile_image.jpg"
//    }
//  ],
//  "status": "DRAFT",
//  "language": "en"
//}
