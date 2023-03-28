//
//  ImageData.swift
//  NewsReels
//
//  Created by Yeshua Lagac on 1/18/22.
//

import Foundation

// Container Decodable so we can still use decodables for straight image url string api response bodies
struct ImageData: Decodable {
    let data: Data
}
