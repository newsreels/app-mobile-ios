//
//  TrendingChannelsView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/6/22.
//

import SwiftUI

struct TrendingChannelsView: View {
    
    struct TrendingChannelsResponse: Decodable {
        let discover: TrendingChannelDiscoverData
    }
    
    struct TrendingChannelDiscoverData: Decodable {
        let sources: [ChannelInfo]?
    }
    
    @State var sources: [ChannelInfo]

    var title: String = ""
    var isSearch: Bool = false
    @State var isError: Bool = false

    var body: some View {
        
        if isSearch == false {
            
            if !sources.isEmpty {
                VStack {
                    //
                    SectionTitleView(title: "Trending Channels") { }
                        .padding(.vertical)
                    VStack {
                        ForEach($sources, id: \.id) { channel in
                            TrendingChannelsRow(channelData: channel, didFollow: { channel in
                                followChannel(channel)
                            })
                            if channel.id.wrappedValue != sources.last?.id {
                                Divider()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.07), radius: 7, x: 0, y: 0)
                    
                }
                .padding(.horizontal)
                

            } else {
                if !isError {
                    loadingView
                        .onAppear {
                            URLSessionProvider.shared.request(TrendingChannelsResponse.self, service: SearchService.getDiscoverDetails(.channels), jsonDecoder: JSONDecoder()) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .failure(let error):
                                        print("ERROR || Failed to get crypto response \(error.localizedDescription)")
                                    case .success(let response):
                                        if let sources = response.discover.sources {
                                            self.sources = sources
                                        }
                                    }
                                }
                            }
                        }
                }
            }
            
            
        } else {
            VStack {
                //
                SectionTitleView(title: "Channels") { }
                    .padding(.vertical)
                VStack {
                    if let sources = sources {
                        ForEach($sources, id: \.id) { channel in
                            TrendingChannelsRow(channelData: channel, didFollow: { channel in
                                followChannel(channel)
                            })
                            if channel.id.wrappedValue != sources.last?.id {
                                Divider()
                            }
                        }
                        .padding(.horizontal)

                    }
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.07), radius: 7, x: 0, y: 0)
                
            }
            .padding()
        }
        
    }
    
    private func followChannel(_ channel: ChannelInfo) {
        let isFav = !(channel.favorite ?? false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        var params = ["sources":[channel.id]]
        var url = !isFav ? "news/sources/unfollow" : "news/sources/follow"

        WebService.URLResponseJSONRequest(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateTopicDC.self, from: response)
                print("FULL RESPONSE FOLLOW CHANNEL = \(FULLResponse), PARAMSSS = \(params)")
                
                if FULLResponse.message == "Success" {
//                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true
                    
                    if let index = sources.firstIndex(where: {$0.id == channel.id}) {
                        sources[index].favorite = isFav
                        
                    }

                } else {

                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")

                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            

            print("error parsing json objects",error)
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

struct TrendingChannelsView_Preview: PreviewProvider {
    static var previews: some View {
        TrendingChannelsView(sources: [ChannelInfo]())
    }
}
