//
//  RemoteVersion.swift
//  Bullet
//
//  Created by Osman on 19/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import Foundation

struct RemoteVersion: Codable {
    
    var android: AndroidVersion?
    var ios: IosVersion?
    
    
    struct AndroidVersion: Codable {
        var version: Int?
        var force_update: Bool
    }
    struct IosVersion: Codable {
        var version: String
        var force_update: Bool
    }
}
