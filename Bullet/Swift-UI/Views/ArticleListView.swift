//
//  ArticleListView.swift
//  Bullet
//
//  Created by Yeshua Lagac on 7/31/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import SwiftUI

struct ArticleListView: View {
    
    struct ArticleResponse: Decodable {
        let discover: ArticleDiscoverResponse
    }
    
    struct ArticleDiscoverResponse: Decodable {
        let articles: [articlesData]?
    }
    
    @State var articles: [articlesData]? = nil
    var title: String? = nil
    var fromSearch: Bool = false
    @State var isError: Bool = false

    var body: some View {
        
        if let articles = articles {
            VStack (alignment: .leading, spacing: 15){
                
                if fromSearch {
                    VStack (alignment: .leading, spacing: 15){
                        
                        SectionTitleView(title: title ?? "Articles", onTapSeeAll:  {
                            
                        }, textColor: fromSearch ? .black : .white)

                        ForEach(articles, id: \.id) { article in
                            HStack (spacing: 10){
                                AppURLImage(article.image)
                                    .cornerRadius(5)
                                    .scaledToFill()
                                    .frame(width: 99, height: 99)
                                    .clipped()

                                VStack (alignment: .leading, spacing: 10){
                                    AppText(article.title ?? "No title", weight: .medium, size: 16)
                                    HStack {
                                        if let publishTime = article.publishTime {
                                            AppText(SharedManager.shared.generateDatTimeOfNews(publishTime).lowercased(), weight: .medium, size: 12, color: .gray)
                                        }
//                                        AppText("-", weight: .medium, size: 12, color: .gray)
//                                        if let authors = article.authors {
//                                            AppText("-", weight: .medium, size: 12, color: .gray)
//                                            AppText(authors.first?.name ?? "", weight: .medium, size: 12, color: .gray)
//                                        }
                                    }
                                }
                            }
                            .onTapGesture {
                                SwiftUIManager.shared.setObserver(name: .SwiftUIGoToArticles, object: article)
                            }
                            Rectangle().fill(Color.gray.opacity(0.5)).frame(height: 1)
                        
                        }
                    }
                    .padding(.horizontal)
                } else {
                    
                    VStack {
                        SectionTitleView(title: NSLocalizedString("Top News", comment: ""), onTapSeeAll:  {
                            
                        }, textColor: fromSearch ? .black : .white)
                        .padding()
                        
                        VStack (alignment: .leading, spacing: 15){
                            
                            ForEach(articles, id: \.id) { article in
                                HStack (spacing: 10){
                                    AppURLImage(article.image)
                                        .cornerRadius(5)
                                        .scaledToFill()
                                        .frame(width: 99, height: 99)
                                        .clipped()

                                    VStack (alignment: .leading, spacing: 10){
                                        AppText(article.title ?? "No title", weight: .medium, size: 16)
                                        HStack {
                                            if let publishTime = article.publishTime {
                                                AppText(SharedManager.shared.generateDatTimeOfNews(publishTime).lowercased(), weight: .medium, size: 12, color: .gray)
                                            }
//                                            if let authors = article.authors {
//                                                AppText("-", weight: .medium, size: 12, color: .gray)
//                                                AppText(authors.first?.name ?? "", weight: .medium, size: 12, color: .gray)
//                                            }
                                        }
                                    }
                                }
                                .onTapGesture {
                                    SwiftUIManager.shared.setObserver(name: .SwiftUIGoToArticles, object: article)
                                }
                                Rectangle().fill(Color.gray.opacity(0.5)).frame(height: 1)
                               
                            }
                            
                        }
                        .padding()
                        .background(Color.white.cornerRadius(8))
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(Color.init(hex: "1885D1"))

                }
            }
            .padding(.vertical)
        } else {
            if !isError {
                loadingView
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
        .onAppear {
            URLSessionProvider.shared.request(ArticleResponse.self, service: SearchService.getDiscoverDetails(.article)) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        print("ERROR || Failed to get articles")
                    case .success(let response):
                        if let articles = response.discover.articles {
                            self.articles = articles
                        }
                    }
                }
            }
        }
    }

}

//struct ArticleListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArticleListView(title: "Stories")
//    }
//}
