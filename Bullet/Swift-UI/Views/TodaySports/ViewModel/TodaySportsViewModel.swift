//
//  TodaySportsViewModel.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/7/22.
//

import Foundation
import SwiftUI

enum SportsType: String {
    case cricket, football, hockey, basketball, tennis
    
    var displayName : String {
        return self.rawValue.uppercased()
    }
    
}

class TodaySportsViewModel: ObservableObject {
    
    @Published var isFetching: Bool = true
    @Published var cricketData: CricketData? = nil
    @Published var basketballData: BasketballData? = nil

    let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        
        let standardDateFormatter = DateFormatter()
        standardDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        jsonDecoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            var date: Date? = nil
            if let _date = standardDateFormatter.date(from: dateString) {
                date = _date
            } else if let _date = fullDateFormatter.date(from: dateString) {
                date = _date
            }
            
            guard let date = date else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
            return date
        })
        return jsonDecoder
    }()
    
    init() {
        fetchSchedules(type: .cricket, date: Date())
    }
    
    func fetchSchedules(type: SportsType, date: Date) {
        
        cricketData = nil
        basketballData = nil
        isFetching = true
        
        let date = date.toString(format: .custom("yyyyMMdd"))
        
        let now = Date()
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = "ZZZZZ"
        let STR = dtFormatter.string(from: now)
        let localTimeZone = STR.replacingOccurrences(of: ":", with: ".").replacingOccurrences(of: "+", with: "")
        
        let sportService = CustomService(customBaseURL: URL(string: "https://livescore6.p.rapidapi.com/matches/v2/list-by-date?Category=\(type.rawValue)&Date=\(date)&Timezone=\(localTimeZone)"), method: .get, task: .requestPlain, parametersEncoding: .url, showLogs: true, customHeaders: ["X-RapidAPI-Key" : "6bf4026ecbmshc32c080f12c325dp1ca5f5jsn2ebfe99fd6b3", "X-RapidAPI-Host" : "livescore6.p.rapidapi.com"])
        
       
        
        // This will be improved later on as we're gonna use different API for each sports
        switch type {
        case .cricket:
            URLSessionProvider.shared.request(CricketData.self, service: sportService, jsonDecoder: self.jsonDecoder) { result in
                DispatchQueue.main.async {
                    self.isFetching = false
                    switch result {
                    case .failure(let error):
                        print("ERROR || Failed to get sports \(error.localizedDescription)")
                    case .success(let response):
                        self.cricketData = response
                    }
                }
              
            }
        case .football:
            break
        case .hockey:
            break
        case .basketball:
            URLSessionProvider.shared.request(BasketballData.self, service: sportService, jsonDecoder: self.jsonDecoder) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        print("ERROR || Failed to get sports \(error.localizedDescription)")
                    case .success(let response):
                        self.basketballData = response
                        
                    }
                }
                
            }

        case .tennis:
            break
        }
        
        
    }
    
}
