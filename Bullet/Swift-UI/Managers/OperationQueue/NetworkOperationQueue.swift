//
//  NetworkOperationQueue.swift
//  NewsReels
//
//  Created by Yeshua Lagac on 3/1/22.
//

import Foundation

class NetworkOperationQueue {
    static let shared = {
        NetworkOperationQueue()
    }()
    
    private let queue: OperationQueue
    
    private init() {
        queue = OperationQueue()
    }
    
    func addOperation(completion: @escaping (()->())) {
        let operation = Operation()
        operation.completionBlock = {
            completion()
        }
        
        queue.addOperation(operation)
    }
    
    func addOperation(_ operation: AsyncOperation) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.queue.addOperations([operation], waitUntilFinished: false)
        }
    }
}
