//
//  CryptoPricesViewModel.swift
//  Bullet
//
//  Created by Yeshua Lagac on 8/1/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation

class CryptoViewModel: ObservableObject {
    
    @Published var isFinishLoading = false
    @Published var crypto: [[Crypto]]?
    
    //https://api.polygon.io/v2/aggs/grouped/locale/global/market/crypto/2020-10-14?adjusted=true&apiKey=Kr5GueO4SPSROeGrSsZOugfd7PzY8_kZ

//    func getGlobalMarkets() {
//
////        let date = Date().toString(format: .custom("yyyy-mm-dd"))
//        let date = "2020-10-14"
//        let key = "IZm7ZaTdCOkEBpeGx0IPKjp3nfL6CjV9"
//        let customService =  CustomService(customBaseURL: URL(string: "https://api.polygon.io/v2"), path: "aggs/grouped/locale/global/market/crypto/\(date)", method: .get, task: .requestParameters(["adjusted" : true, "apiKey" : key]), parametersEncoding: .url, customHeaders: ["Authorization" : "Bearer \(key)"])
//
//        URLSessionProvider.shared.request(CyrptoResponse.self, service: customService) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .failure(let error):
//                    print("ERROR || Failed to get crypto response \(error.localizedDescription)")
//                case .success(let response):
//                    self.crypto = response
//                }
//            }
//        }
//    }
    
    func getGlobalMarkets() {

//        let date = Date().toString(format: .custom("yyyy-mm-dd"))
        let customService = CustomService(customBaseURL: URL(string: "https://api.coinranking.com/v2"), path: "coins", method: .get, task: .requestPlain, usesContainer: true,showLogs: true, customHeaders: ["x-access-token" : "coinranking8f95c45a6e7bd7d95b1bc46c8008d86e82298bd38024ce90"])
        isFinishLoading = false
        URLSessionProvider.shared.request(CryptoResponse.self, service: customService) { result in
            DispatchQueue.main.async {
                self.isFinishLoading = true
                switch result {
                case .failure(let error):
                    print("ERROR || Failed to get crypto response \(error.localizedDescription)")
                case .success(let response):
                    let coins = response.coins
                    self.crypto = coins.unflattening(dim: 2)
                }
            }
        }
    }
    
}

extension Array {
    func unflattening(dim: Int) -> [[Element]] {
        let hasRemainder = !count.isMultiple(of: dim)
        
        var result = [[Element]]()
        let size = count / dim
        result.reserveCapacity(size + (hasRemainder ? 1 : 0))
        for i in 0..<size {
            result.append(Array(self[i*dim..<(i + 1) * dim]))
        }
        if hasRemainder {
            result.append(Array(self[(size * dim)...]))
        }
        return result
    }
}
