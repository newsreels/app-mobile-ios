//
//  SearchResultView.swift
//  Bullet
//
//  Created by Yeshua Lagac on 8/2/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import SwiftUI

struct SearchResultView: View {
    
    @Binding var isSearching: Bool
    @EnvironmentObject var searchViewModel : SearchViewModel
    
    var body: some View {
        VStack {
            if !isSearching {
                notSearchingView
            } else {
                if !isSearching {
                    notSearchingView
                } else {
                    SearchHistoryListView(histories: searchViewModel.histories, didSelect: { history in
                        searchViewModel.search(history.searchText)
                    }, didDelete: { deletedID in
                        searchViewModel.deleteHistory(deletedID)
                    })
                }
                
            }
        }
        
    }
    
    var notSearchingView: some View {
        VStack (spacing: 20) {
            if let searchData = searchViewModel.searchData?.data {
                ForEach(searchData, id: \.title) { data in
                    switch data.type {
                    case .reels:
                        if let reels = data.reels {
                            //                                    TrendingReelsListView(reels: reels, title: data.title)
                            Text("REELS")
                        }
                        Text("REELS")
                    case .articles:
                        if let articles = data.articles {
                            ArticleListView(articles: articles, title: data.title)
                        }
                        Text("ARTICLES")
                    default:
                        Text(data.type.rawValue)
                    }
                    
                }
            }
        }
        .padding(.vertical, 15)
    }
}
