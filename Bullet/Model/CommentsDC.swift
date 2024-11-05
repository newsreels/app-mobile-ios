//
//  CommentsDC.swift
//  Bullet
//
//  Created by Faris Muhammed on 11/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation

// MARK: - CommentsModel
struct CommentsModel: Codable {
    let parent: Comment?
    let comments: [Comment]?
    let meta: CommentsMetaData?
}

// MARK: - Comment
struct Comment: Codable {
    let id: String?
    let createdAt: String?
    let comment: String?
    let user: User?
    var moreComment: Int?
    var replies: [Comment]?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case comment, user
        case moreComment = "more_comment"
        case replies
    }
}

// MARK: - User
struct User: Codable {
    let name: String?
    let image: String?
}


struct CommentsMetaData: Codable {
    let next: String?
}
