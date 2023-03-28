//
//  PaginationControl.swift
//  NewsReels
//
//  Created by Yeshua Lagac on 10/21/21.
//

import Foundation

class PaginationControl<T: Decodable> {
    
    private var service: ServiceProtocol
    var nextPageLink: String?
    
    init(service: ServiceProtocol) {
        self.service = service
    }
    
    func getNextPage(completion: @escaping (Result<T, APIServiceError>) -> ()) {
        var serviceParams: AppParameters? = nil
        if case let .requestParameters(params) = service.task {
            serviceParams = params
        }
        
        if let nextPageLink = nextPageLink, let url = URL(string: nextPageLink),
           let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            var linkParams = urlComponents.queryItems
            
            serviceParams?.forEach{ linkParams?.append(.init(name: $0.key, value: "\($0.value)")) }
            
            var requestParams: AppParameters = [:]
            linkParams?.forEach{ requestParams[$0.name] = $0.value }
            let newServiceTask: AppTask = .requestParameters(requestParams)
            
            self.nextPageLink = nil
            let nextPageService = CustomService(path: service.path,
                                                method: service.method,
                                                task: newServiceTask,
                                                needsAuthentication: service.needsAuthentication,
                                                usesContainer: service.usesContainer,
                                                parametersEncoding: .url)
            
            URLSessionProvider.shared.request(T.self, service: nextPageService, paginationControl: self, completion: completion)
        } else {
            print("ERROR || Next page link is empty or invalid")
            completion(.failure(.noData))
        }
    }
}
