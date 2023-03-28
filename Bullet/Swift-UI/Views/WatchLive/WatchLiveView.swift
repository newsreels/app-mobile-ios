//
//  WatchLiveView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/6/22.
//

import SwiftUI

struct WatchLiveView: View {
    
    var isSearch: Bool = false
    
    struct WatchLiveResponse: Decodable {
        let discover: TrendingChannelDiscoverData
    }
    
    struct TrendingChannelDiscoverData: Decodable {
        let sources: [ChannelInfo]?
    }
    
    var body: some View {

        if !isSearch {
            VStack {
                SectionTitleView(title: "Watch Live") { }
                    .padding(.vertical)
                loadingView
                    .onAppear {
                        URLSessionProvider.shared.request(WatchLiveResponse.self, service: SearchService.getDiscoverDetails(.youtube)) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .failure(let error):
                                    print("ERROR || Failed to get crypto response \(error.localizedDescription)")
                                case .success(let response):
                                    if let sources = response.discover.sources {
//                                        self.sources = sources
                                    }
                                }
                            }
                        }
                    }

            }
            .padding(.horizontal)

        } else {
            VStack {
                SectionTitleView(title: "Watch Live") { }
                    .padding(.vertical)
                ScrollView (.horizontal, showsIndicators: false){
                    HStack {
                        WatchLiveCardView()
                        WatchLiveCardView()
                        WatchLiveCardView()
                    }
                    .padding(.vertical)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, -24)
                .padding(.vertical, -24)
            }
            .padding(.horizontal)
            .onAppear {
                
            }
        }
        
        
        
    }
    
    
    var loadingView: some View {
        VStack {
            VStack (alignment: .leading, spacing: 24){
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 35)
                    .cornerRadius(10)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 220)
                    .cornerRadius(10)
            }
        }
        .padding(.bottom)
        .padding(.horizontal)
        
    }
}

struct WatchLiveView_Previews: PreviewProvider {
    static var previews: some View {
        WatchLiveView()
    }
}
