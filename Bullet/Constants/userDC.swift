//
//  userDC.swift
//  Bullet
//
//  Created by Khadim Hussain on 31/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import Foundation

public struct userDC: Codable {
    
    let message: String?
  //  let errors : Errors?
    let user_id: String?
    let exist: Bool?
}

struct Errors : Codable {
    
    let email : [String]?
    let password : [String]?
}
