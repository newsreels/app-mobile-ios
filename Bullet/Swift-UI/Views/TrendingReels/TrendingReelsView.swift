//
//  TrendingReelsView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/6/22.
//

import SwiftUI

struct TrendingReelsView: View {
    
    @State var reels: [Reel]? = nil
    var title: String? = nil
    var fromSearch: Bool = false
    @State var isError: Bool = false
    
    struct ReelsDiscoverResponse: Decodable {
        let discover: ReelsData
    }
    
    struct ReelsData: Decodable {
        let reels: [Reel]
    }
    
    var body: some View {
        VStack (alignment: .leading){
            
            if fromSearch {
                                
                if let reels = reels {
                    
                    SectionTitleView(title: title ?? "Reels") { }
                        .padding(.vertical)
                    
                    if let reelsFlattening = Array(reels.unflattening(dim: 3).prefix(2)) {
                        VStack (alignment: .leading, spacing: 12){
                            ForEach(0...reelsFlattening.count - 1, id: \.self) { index in
                                let thisReel = reelsFlattening[index]
                                HStack (spacing: 12){
                                    ForEach(thisReel, id: \.id) { reel in
                                        ReelsView(reel: reel) { reel in
                                            reelTapped(reel: reel)
                                        }
                                    }
                                }
                            }
                        }
                    } else if let reelsFlat = Array(reels.unflattening(dim: 3).prefix(1)) {
                        VStack (alignment: .leading, spacing: 12){
                            ForEach(0...reelsFlat.count - 1, id: \.self) { index in
                                let thisReel = reelsFlat[index]
                                HStack (spacing: 12 ){
                                    ForEach(thisReel, id: \.id) { reel in
                                        ReelsView(reel: reel) { reel in
                                            reelTapped(reel: reel)
                                        }
                                    }
                                }
                               
                            }
                        }
                    }
                }
                
              

                
            } else {
                if let reels = reels {
                    SectionTitleView(title: NSLocalizedString("Trending Reels", comment: "")) { }
                        .padding(.vertical)
                    
                    if let reelsFlattening = Array(reels.unflattening(dim: 3).prefix(2)), !reelsFlattening.isEmpty {
                        VStack (spacing: 12){
                            ForEach(0...reelsFlattening.count - 1, id: \.self) { index in
                                let thisReel = reelsFlattening[index]
                                HStack (spacing: 12){
                                    ForEach(thisReel, id: \.id) { reel in
                                        ReelsView(reel: reel) { reel in
                                            reelTapped(reel: reel)
                                        }
                                    }
                                }
                            }
                        }
                    } else if let reelsFlat = Array(reels.unflattening(dim: 3).prefix(1)), !reelsFlat.isEmpty {
                        VStack (spacing: 12){
                            ForEach(0...reelsFlat.count - 1, id: \.self) { index in
                                let thisReel = reelsFlat[index]
                                HStack (spacing: 12){
                                    ForEach(thisReel, id: \.id) { reel in
                                        ReelsView(reel: reel) { reel in
                                            reelTapped(reel: reel)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    
                  
                    
                    
                    
                    
//                    HStack (spacing: 15) {
//                        VStack (spacing: 20) {
//                            ReelsView()
//                            ReelsView()
//                        }
//                        VStack (spacing: 20) {
//                            ReelsView()
//                            ReelsView()
//                        }
//                        VStack (spacing: 20) {
//                            ReelsView()
//                            ReelsView()
//                        }
//                    }
                } else {
                    
                    if !isError {
                        loadingView
                            .onAppear {
                                URLSessionProvider.shared.request(ReelsDiscoverResponse.self, service: SearchService.getDiscoverDetails(.reels), jsonDecoder: JSONDecoder()) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success(let response):
                                            self.reels = response.discover.reels
                                        case .failure(let error):
                                            print("ERROR || Failed to get reels")
                                            self.isError = true
                                        }
                                    }
                                    
                                }
                            }
                    }
                    
                }
                
            }
            
        }
        .frame(width: UIScreen.main.bounds.size.width - 44)
        .padding(.horizontal)
        
    }
    
    var loadingView: some View {
        VStack (alignment: .leading) {
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 150, height: 35)
                .cornerRadius(10)
            
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(15)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(15)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(15)
                
            }
            
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(15)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(15)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(15)
                
            }
        }
    }
    
    func reelTapped(reel: Reel) {
        if let reels = reels, let index = reels.firstIndex(where: {$0.id == reel.id}) {
            SwiftUIManager.shared.setObserver(name: .SwiftUIGoToReelsDetails, object: ["reels" : reels, "index" : index])
        }
    }
}

//struct TrendingReelsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrendingReelsView()
//    }
//}
