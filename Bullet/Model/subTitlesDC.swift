//
//  ReelsSubtitle+Extension.swift
//  Bullet
//
//  Created by Khadim Hussain on 29/09/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation

struct subTitlesDC : Codable {
    
    let captions : [Captions]?
}

struct Captions : Codable {

    let sentence : String?
    let is_clickable : Bool?
    let action : String?
    let y_direction : String?
    let wrapping : Bool?
    let landscape : Bool?
    let forced : Bool?
    let corner_radius: Double
    let text_background : String?
    let image_background : String?
    let rotation : Double?
    let animation : String?
    let animation_duration : Double?
    let alignment : String?
    let words : [Words]?
    let duration : Duration?
    let margin : Margin?
    let padding : Padding?
    let position : Position?
    
}

struct Words : Codable {
    
    let word : String?
    let delay : Double?
    //let animation_duration : Double?
    //let animation_repeat : Double?
    let highlight_color : String?
//    let shadow_color : String?
    let shadow: Shadow?
    let underline : Bool?
    let font : AppFont?
}

struct Shadow: Codable {
    let color: String?
    let radius: Double?
    let x: Double?
    let y: Double?
}

struct AppFont : Codable {
    
    let style : String?
    let family : String?
    let size : Double?
    let color : String?
}

struct Position : Codable {
    
    let x : Double?
    let y : Double?
}

struct Padding : Codable {
    
    let top : Double?
    let bottom : Double?
    let left : Double?
    let right : Double?
}

struct Margin : Codable {
    
    let top : Double?
    let bottom : Double?
    let left : Double?
    let right : Double?
}

struct Duration : Codable {
    
    let start : Double?
    let end : Double?
}
