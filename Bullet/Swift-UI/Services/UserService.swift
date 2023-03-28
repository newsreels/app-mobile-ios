//
//  UserService.swift
//  Bullet
//
//  Created by Yeshua Lagac on 8/21/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation

enum UserService: ServiceProtocol {

    case deleteAccount
    
    var customHeaders: Headers? {
        return nil
    }
        
    var path: String {
        switch self {
        case .deleteAccount:
            return "auth/user"
        }
   }
    
    var method: AppHTTPMethod {
        switch self {
        case .deleteAccount:
            return .delete
        default:
            return .get
        }
    }
    
    var task: AppTask {
        switch self {
        case .deleteAccount:
            return .requestPlain
        }
    }
    
    var needsAuthentication: Bool {
        switch self {
        default:
            return true
        }
    }
    
    var usesContainer: Bool {
        switch self {
        default :
            return false
        }
    }
    
    var parametersEncoding: ParametersEncoding {
        switch self {
        default:
            return .json
        }
    }
}
