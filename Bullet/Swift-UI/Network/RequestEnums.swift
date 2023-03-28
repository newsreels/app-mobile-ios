//
//  RequestEnums.swift
//  NewsReels
//
//  Created by Yeshua Lagac on 6/13/21.
//
import Foundation

enum AppHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

typealias AppParameters = [String: Any]

extension AppParameters {
    static let serviceArrayOfParamsKey = "__array_of_params__"
}
extension Array where Element == [String: Any] {
    // Workaround for Array of Dictionaries
    // Can only be used in JSON type ParametersEncoding
    // WARNING: if we're actually going to have a `__array_of_params__`, this would produce problems
    var asServiceParameter: AppParameters {
        return [AppParameters.serviceArrayOfParamsKey: self]
    }
}

enum AppTask {
    case requestPlain
    case requestParameters(AppParameters)
}


enum MultipartInput {
    case fileURL(URL)
    case data(Data, fileName: String)
    
    // TODO: refactor so that multipart inputs also accepts [String: Any] instead of [String: MultipartInput]
    case value(Any)
}

enum ParametersEncoding {
    case url
    case json
    case multipart
}
