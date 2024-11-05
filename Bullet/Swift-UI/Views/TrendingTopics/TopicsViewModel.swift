//
//  TopicsViewModel.swift
//  Bullet
//
//  Created by Abdullah Tariq on 13/12/2022.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation


struct TrendingTopicsResponse: Decodable {
    let discover: TrendingDiscoverData
}

struct TrendingDiscoverData: Decodable {
    let topics: [TopicData]?
}

class TopicsViewModel: ObservableObject {
    
    @Published var isFinishLoading = false
    @Published var topicsData: [[TopicData]]?

    
    func getTopicsData() {
        isFinishLoading = false
        URLSessionProvider.shared.request(TrendingTopicsResponse.self, service: SearchService.getDiscoverDetails(.topics)) { result in
            
            DispatchQueue.main.async {
                self.isFinishLoading = true
                switch result {
                case .success(let topics):
                    print("SUCCESS || TOPICS = \(topics)")
                    if let topics = topics.discover.topics {
                        self.topicsData = topics.unflattening(dim: 2)
                    }
                case .failure(let error):
                    print("ERROR || Failed to get the trending topics")
                }
            }
        }
    }
}
