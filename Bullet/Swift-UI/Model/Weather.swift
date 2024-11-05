//
//  Weather.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/7/22.
//

import Foundation

struct Weather: Decodable {
    let location: WeatherLocation
    let current: WeatherCurrent
}

struct WeatherLocation: Decodable {
    let name: String
    let region: String
    let country: String
}

struct WeatherCurrent: Decodable {
    let tempC: Double
    let tempF: Double
    let windMph: Double
    let windKph: Double
    let windDir: String
    let humidity: Double
    let condition: WeatherCondition
    let visKm: Double
}

struct WeatherCondition: Decodable {
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case description = "text"
    }
}
