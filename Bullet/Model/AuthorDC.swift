

import Foundation

public struct AuthorDC : Codable {
    
    let author : Author?
}

struct Author: Codable {
    
    let id: String?
    let context: String?
    let first_name: String?
    let last_name: String?
    let profile_image: String?
    let cover_image: String?
    let profileImage: String? // for new network layer usage
    let language: String?
    let follower_count: Int?
    let post_count: Int?
    var favorite: Bool?
    var verified: Bool?
    var has_reel: Bool?
    var has_article: Bool?
    let username: String?
    var isShowingLoader: Bool?
}

//Get Authors Search List
public struct AuthorSearchDC : Codable {
    
    let authors: [Author]?
    let meta: MetaData?
}

//Get Followers Authors
public struct FollowerAuthorsDC : Codable {
    
    let users: [Authors]?
    let meta: MetaData?
}

//Get Followers Authors
public struct BlockedAuthorsDC : Codable {
    
    let authors: [Author]?
    let meta: MetaData?
}

public struct Authors: Codable {

    let id: String?
    var context: String?
    let name: String?
    let username: String?
    let image: String?
    var favorite: Bool?
    var isShowingLoader: Bool?
    
}

struct suggestedAuthorsDC: Codable {
    
    let authors: [Author]?
}





//{
//    "author": {
//        "id": "d368a987-8c53-46a5-bd1e-0a177e139055",
//        "first_name": "mkmk",
//        "last_name": "mk",
//        "profile_image": "https://cdn.staging.newsinbullets.app/account/user/1cb60d1f-494e-4924-8a1d-a48213275e13/profile_image.jpg",
//        "cover_image": "https://cdn.staging.newsinbullets.app/account/user/a397ccf4-9cc0-49bc-bfe0-1b18669433c0/cover_image.jpg",
//        "language": "",
//        "follower_count": 0,
//        "post_count": 1,
//        "favorite": false
//    }
//}
