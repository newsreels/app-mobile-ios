//
//  URLComponents+Extension.swift
//  NewsReels
//
//  Created by Yeshua Lagac on 6/13/21.
//

import Foundation

extension URLComponents {

    init(service: ServiceProtocol) {
        let url: URL
        if let customService = service as? CustomService,
           let customBaseURL = customService.customBaseURL {
            if !service.path.isEmpty {
                url = customBaseURL.appendingPathComponent(service.path)
            } else {
                url = customBaseURL
            }
        } else {
            url = service.baseURL.appendingPathComponent(service.path)
        }
        self.init(url: url, resolvingAgainstBaseURL: false)!
        guard case let .requestParameters(parameters) = service.task, service.parametersEncoding == .url else { return }
        queryItems = parameters.map { key, value in
            if let value = value as? Bool {
                // Backend doesnt accept `true` or `false` as query param value atm
                let boolValue = value ? "True": "False"
                return URLQueryItem(name: key, value: boolValue)
            } else {
                return URLQueryItem(name: key, value: String(describing: value))
            }
        }
    }
}
