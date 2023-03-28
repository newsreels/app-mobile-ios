//
//  Like.swift
//  Bullet
//
//  Created by Faris Muhammed on 12/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation

// MARK: - LikeModel
struct LikeModel: Codable {
    let like: Like?
}

// MARK: - Like
struct Like: Codable {
    let articleID, userID, createdAt: String?

    enum CodingKeys: String, CodingKey {
        case articleID = "article_id"
        case userID = "user_id"
        case createdAt = "created_at"
    }
}

