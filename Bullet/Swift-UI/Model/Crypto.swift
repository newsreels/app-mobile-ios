//
//  Crypto.swift
//  Bullet
//
//  Created by Yeshua Lagac on 8/1/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation

//struct CyrptoResponse: Decodable {
//    let results: [Cyrpto]
//}
//
//struct Cyrpto: Decodable {
//    // o open
//    // h high
//    // l low
//    // c close
//    // v volume
//    // vw vwap
//    let name: String
//    let price: Double
//    let low: Double
//    let high: Double
//
//    var isHigh: Bool {
//        return price >= high
//    }
//
//    var percentage: Double {
//        if isHigh {
//            return high / price
//        } else {
//            return low / price
//        }
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case name = "T"
//        case price = "o"
//        case low = "l"
//        case high = "h"
//    }
//}

struct CryptoResponse: Decodable {
    let coins: [Crypto]
}

struct Crypto: Decodable {
    let name: String
    let iconUrl: String
    let price: String
    let change: String
    let symbol: String

}
