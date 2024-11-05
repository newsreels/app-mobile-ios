//
//  NetworkOperation.swift
//  NewsReels
//
//  Created by Yeshua Lagac on 3/1/22.
//

import Foundation
import Reachability

final class NetworkOperation: AsyncOperation {
    
    private let session: URLSession
    
    private let request: URLRequest
    private var task: URLSessionTask?
    private let completion: (Data?, HTTPURLResponse?, Error?)->()
    
    init(session: URLSession, request: URLRequest, completion: @escaping (Data?, HTTPURLResponse?, Error?)->()) {
        self.session = session
        self.request = request
        self.completion = completion
    }

    override func main() {
        attemptRequest()
    }
    
    private func attemptRequest() {
        task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            if (NetworkManager.shared.reachability).connection != .unavailable {
                guard let httpResponse = response as? HTTPURLResponse
                else { return } // balikan to, kung may need pang gawin pag fail
                self.completion(data, httpResponse, error)
                self.finish()
            } else {
                NotificationCenter.default.addObserver(self, selector: #selector(self.handleChangeInNetworkConnection), name: .NetworkConnectionChanged, object: nil)
            }
        })
        task?.resume()
    }
    
    @objc func handleChangeInNetworkConnection() {
         self.attemptRequest()
        NotificationCenter.default.removeObserver(self)
    }

    override func cancel() {
        task?.cancel()
        super.cancel()
    }
}
