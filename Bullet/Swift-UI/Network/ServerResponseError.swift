//
//  ServerResponseError.swift
//  NewsReels
//
//  Created by Yeshua Lagac on 9/8/21.
//

import Foundation

struct ServerResponseError: Decodable {
    var errors: [ErrorsResponse]?
    var errorStrings: [String]?
    var nonFieldErrors: [String]?
    
    var errorsList: String {return getErrorDescription()}
    
    enum CodingKeys: String, CodingKey {
        case data, errors, nonFieldErrors = "non_field_errors"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        var upcomingErrors: [ErrorsResponse] = []
        if let error = try? container.decode(ErrorMessageResponse.self, forKey: .errors) {
            upcomingErrors.append(ErrorsResponse(key: "message", value: error.message))
        }
        
        if let error = try? container.decode(ErrorDetailResponse.self, forKey: .errors) {
            upcomingErrors.append(ErrorsResponse(key: "message", value: error.detail))
        }
        
        if let errorsArr = try? container.decode([ErrorsResponse].self, forKey: .errors) {
            errorsArr.forEach {errors?.append($0)}
        }
        
        var upcomingErrorStrings: [String] = []
        if let errorStrings = try? container.decode([String].self, forKey: .errors) {
            errorStrings.forEach { upcomingErrorStrings.append($0) }
        } else if let errorStrings = try? container.decode([[String]].self, forKey: .errors) {
            errorStrings.joined().forEach { upcomingErrorStrings.append($0) }
        } else if let errorStrings = try? container.decode([[[String]]].self, forKey: .errors) {
            errorStrings.joined().joined().forEach { upcomingErrorStrings.append($0) }
        }
        
        nonFieldErrors = try? container.decode([String].self, forKey: .nonFieldErrors)
        
        if !upcomingErrors.isEmpty {
            errors = upcomingErrors
        } else if !upcomingErrorStrings.isEmpty {
            errorStrings = upcomingErrorStrings
        }
    }
    
    private func getErrorDescription() -> String {
        if let keyValueErrors = errors, keyValueErrors.count > 0 {
            return keyValueErrors.compactMap({$0.value}).joined(separator: "\n")
        } else if let errorStrings = errorStrings {
            return errorStrings.joined(separator: "\n")
        }
        return NSLocalizedString("no errors", comment: "")
    }
}



