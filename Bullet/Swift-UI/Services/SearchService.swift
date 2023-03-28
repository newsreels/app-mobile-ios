//
//  SearchService.swift
//  Bullet
//
//  Created by Yeshua Lagac on 6/17/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation

enum SearchService: ServiceProtocol {

    case getHistory
    case search(string: String)
    case delete(id: String)
    case getDiscover
    case getDiscoverDetails(DiscoverContext)
    case getTopics
    case getArticleTopics
    
    var customHeaders: Headers? {
        return nil
    }
        
    var path: String {
        switch self {
        case .getHistory:
            return "news/search/history"
        case .search:
            return "news/search"
        case .delete(id: let id):
            return "news/search/history/\(id)"
        case .getDiscover:
            return "news/discover/list"
        case .getDiscoverDetails:
            return "news/discover/detail"
        case .getTopics:
            return "news/home?type=articles"
        case .getArticleTopics:
            let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
            return "news/topics/related/\(token)"
        }
   }
    
    var method: AppHTTPMethod {
        switch self {
        case .delete:
            return .delete
        default:
            return .get
        }
    }
    
    var task: AppTask {
        switch self {
        case let .search(string: searchString):
            return .requestParameters(["query" : searchString])
        case let .getDiscoverDetails(context):
            return .requestParameters(["context" : context.rawValue])
        default:
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
        case .getTopics:
            return true
        default :
            return false
        }
    }
    
    var parametersEncoding: ParametersEncoding {
        switch self {
        case .search, .getDiscoverDetails:
            return .url
        default:
            return .json
        }
    }
}
