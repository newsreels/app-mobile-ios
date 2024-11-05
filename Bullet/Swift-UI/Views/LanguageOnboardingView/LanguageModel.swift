//
//  LanguageModel.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/24/22.
//

import Foundation

struct NewRegionResponse: Codable {
    let regions: [NewRegion]
}

struct NewRegion: Codable {
    let id: String
    let context: String
    let name: String
    let image: String
    let flag: String
    let country: String
    let favorite: Bool
}

struct NewLanguageResponse: Codable {
    let languages: [NewLanguage]
}

struct NewLanguage: Codable {
    let id: String
    let name: String
    let sample: String
    let image: String
    let code: String
    let favorite: Bool
    let tag: String
}
