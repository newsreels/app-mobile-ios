//
//  LanguageService.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/24/22.
//

import Foundation

enum LanguageService: ServiceProtocol {

    case getPublicRegions
    case getPublicLanguages(_ regionID: String)
    case getRegions
    case getLanguages(_ regionID: String)
    
    var customHeaders: Headers? {
        return nil
    }
        
    var path: String {
        switch self {
        case .getPublicRegions:
            return "news/public/regions"
        case .getPublicLanguages:
            return "news/public/languages"
        case .getRegions:
            return "news/regions"
        case .getLanguages:
            return "news/languages"
        }
   }
    
    var method: AppHTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var task: AppTask {
        switch self {
        case .getPublicLanguages(let regionID):
            return .requestParameters(["region": regionID])
        case .getLanguages(let regionID):
            return .requestParameters(["region": regionID])
        default:
            return .requestPlain
        }
    }
    
    var needsAuthentication: Bool {
        switch self {
        case .getPublicRegions, .getPublicLanguages:
            return false
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
        case .getPublicLanguages, .getLanguages:
            return .url
        default:
            return .json
        }
    }
}
