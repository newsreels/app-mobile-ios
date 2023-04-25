//
//  ServiceProtocol.swift
//  MaxiHealthNew
//
//  Created by Yeshua Lagac on 6/13/21.
//

import Foundation

typealias Headers = [String: String]
protocol ServiceProtocol {
    
    var path: String { get }
    var method: AppHTTPMethod { get }
    var task: AppTask { get }
    /// Setting this to `true` will add bearer token to url request header
    var needsAuthentication: Bool { get }
    /// Setting this to `true` will expect Data received will be enclosed with ServerResponse
    ///    - ServerResponse<T>
    ///    - =  { data: T , errors: [...] }
    var usesContainer: Bool { get }
    var parametersEncoding: ParametersEncoding { get }
    var customHeaders: Headers? { get }
}

extension ServiceProtocol {
    
    var baseURL: URL {
        return URL(string: "https://api.newsreels.app/")!
    }
    
    var headers: Headers {
        return ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                "x-app-platform": "ios",
                "x-app-version": Bundle.main.releaseVersionNumberPretty,
                "api-version": WebserviceManager.shared.API_VERSION,
                "Content-Type": "application/json"]
    }
    
    
}
