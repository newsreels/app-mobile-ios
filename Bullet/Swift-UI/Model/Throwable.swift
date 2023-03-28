//
//  Throwable.swift
//  NewsReels
//
//  Created by Yeshua Lagac on 11/15/21.
//

import Foundation

struct Throwable<T: Decodable>: Decodable {
    let result: Result<T, Error>

    init(from decoder: Decoder) throws {
        result = Result(catching: { try T(from: decoder) })
    }
}
