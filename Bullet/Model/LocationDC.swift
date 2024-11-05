//
//  TopicDC.swift
//  Bullet
//
//  Created by Mahesh on 18/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Foundation

//MARK: - RootClass
public struct locationsDC: Codable {
    
    var meta: MetaData?
    var locations: [Location]?
}

struct locationsSection: Codable {
    
    var LIST_ID: String?
    var LIST_LIST: [Location]?
}

struct placesSize {
    
    var ROW: Int?
    var SIZE: [CGSize]?
}


//MARK: - RootClass- add topics
struct AddLocationDC: Codable {
    
    var locations: [Location]?
    
}
