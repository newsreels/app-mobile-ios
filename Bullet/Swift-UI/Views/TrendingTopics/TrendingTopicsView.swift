//
//  TrendingTopicsView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import SwiftUI

struct TrendingTopicsView: View {
    
//    @State var data: [[TopicData]]?
    @ObservedObject var data = TopicsViewModel()
    @State var selectedTopic: TopicData? = nil
    @State var searchedData: [TopicData]? = nil
    var fromSearch: Bool = false
    @State var isError: Bool = false

    var body: some View {
        
        if fromSearch {
            VStack {
                //
                SectionTitleView(title: NSLocalizedString("Topics", comment: "")) { }
                    .padding(.vertical)
                VStack {
                    if let searchData = searchedData {
                        ForEach(searchData, id: \.id) { data in
                            HStack {
                                AppURLImage(data.image)
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(10)
                                AppText(data.name ?? "", weight: .semiBold, size: 15)
                                Spacer()
                                
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 25, height: 25)
                                    .overlay(checkmark(topic: data))
                                    .onTapGesture {
                                        followTopics(data)
                                    }
                            }
                            .background(Color.white)
                            .onTapGesture {
                                SwiftUIManager.shared.setObserver(name: .SwiftUIGoToArticleTopic, object: data)
                            }
                            
                            if data.id != searchData.last?.id {
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
            .padding(.horizontal)
            .padding(.vertical)

        } else {
            if let data = data.topicsData, !data.isEmpty {
                let _ = print("")
                VStack (spacing: 0){
                    SectionTitleView(title: NSLocalizedString("Trending Topics", comment: "")) { }
                        .padding(.horizontal)
                    ScrollView (.horizontal, showsIndicators: false){
                        
                        HStack (alignment: .top, spacing: 8){
                            
                            ForEach(0..<(data.count - 1)) { value in
                                VStack (alignment: .leading){
                                    ForEach(data[value], id: \.name) { topic in
                                        if let image = topic.image {
//                                            CardView(cardIcon: .init(icon: .url(image)), content: {
//                                                VStack { AppText(topic.name ?? "No Name", size: 14) }
//                                            })
//                                            .onTapGesture {
//                                                SwiftUIManager.shared.setObserver(name: .SwiftUIGoToArticleTopic, object: topic)
//                                            }
                                            
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.white)
                                                .frame(width: 200, height: 57)
                                                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 0)
                                                .onTapGesture {
                                                    SwiftUIManager.shared.setObserver(name: .SwiftUIGoToArticleTopic, object: topic)
                                                }
                                                .overlay(
                                                    HStack (spacing: 15){
                                                        CardIcon.init(icon: .url(image))
                                                        VStack { AppText(topic.name ?? "No Name", size: 14) }
                                                        Spacer()
                                                    }
                                                    .padding(.leading, 12)
                                                )
                                           
                                            
                                        } else {
//                                            CardView(cardIcon: .init(icon: .local(Image("")), backgroundColor: .CardRed), content: {
//                                                VStack { AppText(topic.name ?? "No Name", size: 14) }
//                                            })
//                                            onTapGesture {
//                                                SwiftUIManager.shared.setObserver(name: .SwiftUIGoToArticleTopic, object: topic)
//                                            }
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.white)
                                                .frame(width: 200, height: 57)
                                                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 0)
                                                .onTapGesture {
                                                    SwiftUIManager.shared.setObserver(name: .SwiftUIGoToArticleTopic, object: topic)
                                                }
                                                .overlay(
                                                    HStack (spacing: 15){
                                                        Circle()
                                                            .fill(Color.CardRed)
                                                            .frame(width: 36, height: 36)
                                                        VStack { AppText(topic.name ?? "No Name", size: 14) }
                                                        Spacer()
                                                    }
                                                    .padding(.leading, 12)
                                                )
                                                
                                        }

                                    }
                                }
                               
                            }
                        }
                        .padding(.vertical, 40)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, -24)
                }
                .padding(.vertical)

            } else {
                if !isError {
                    loadingView
                        .onAppear {
                            // This should be in a view model
//                            URLSessionProvider.shared.request(TrendingTopicsResponse.self, service: SearchService.getDiscoverDetails(.topics)) { result in
//                                switch result {
//                                case .success(let topics):
//                                    print("SUCCESS || TOPICS = \(topics)")
//                                    if let topics = topics.discover.topics {
//                                        data = topics.unflattening(dim: 2)
//                                    }
//                                case .failure(let error):
//                                    print("ERROR || Failed to get the trending topics")
//                                }
//                            }
                            
                            data.getTopicsData()
                        }
                }
            }

        }
        
    }
    
    @ViewBuilder
    func checkmark(topic: TopicData) -> some View{
        VStack {
            if topic.favorite ?? false {
                Image(systemName: "checkmark").font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.AppPinkPrimary)
            } else {
                Image(systemName: "plus").font(.system(size: 10, weight: .semibold))
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

                ScrollView (.horizontal) {
                    HStack (spacing: 8){
                        VStack (spacing: 8){
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                        }
                        
                        VStack (spacing: 8){
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                        }
                        
                        VStack (spacing: 8){
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                        }
                        
                        
                        VStack (spacing: 8){
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 57)
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.size.width - 20)
                 .disabled(true)
            }
        }
        .padding(.bottom)
        .padding(.leading)

    }
    
    private func followTopics(_ topic: TopicData) {
        selectedTopic = topic
        let isFav = !(topic.favorite ?? false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        var params = ["topics":[topic.id]]
        var url = !isFav ? "news/topics/unfollow" : "news/topics/follow"

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
                    
                    if let searchData = searchedData, let index = searchData.firstIndex(where: {$0.id == topic.id}) {
                        searchedData![index].favorite = isFav
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

}

struct TrendingTopicsView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingTopicsView()
    }
}
