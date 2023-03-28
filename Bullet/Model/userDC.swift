//
//  userDC.swift
//  Bullet
//
//  Created by Khadim Hussain on 31/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import Foundation

public struct userDC: Codable {

    let success: Bool?
    let results : UserProfile?
    let message: String?
    let errors : Errors?
    let user_id: String?
    let exist: Bool?
}

struct Errors : Codable {
    
    let email : [String]?
    let password : String?
}

struct checkEmailErrors : Codable {
    
    let errors : emailError?
}

struct emailError: Codable {
    
    let email : String?
}

struct userInfoDC : Codable {
    
    let success: Bool?
    let error: String?
    let results : UserProfile?
}

struct userInfo : Codable {
    
    let id : String?
    let email : String?
    let hasPassword : Bool?
}

public struct deviceTokenDC: Codable {
    
    let message: String?
    let token: String?
}


public struct CommunityGuideDC: Codable {
        
    let user_id: String?
    let accept: Bool?

}
