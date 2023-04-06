//
//  WebserviceManager.swift
//  Bullet
//
//  Created by Faris Muhammed on 26/05/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation


enum UrlType: String {
    
    case production
    case staging
}

enum ApiErrorType: String {
    
    case jsonError
    case internetError
    case other
}

// WebserviceManager Class sharing with extensions
class WebserviceManager {
    
    static let shared = WebserviceManager()
    
    let APP_BUILD_TYPE = UrlType.production //For Live
//    let APP_BUILD_TYPE = UrlType.staging // For Testing/
    let API_VERSION = "v5"
    
    
    var API_BASE = ""
    var APP_CLIENT_ID = ""
    var APP_CLIENT_SECRET = ""
    var GOOGLE_CLIENT_ID = ""
    var AUTH_BASE_URL = ""
    var AUTH_TOKEN_URL = ""
    
}
