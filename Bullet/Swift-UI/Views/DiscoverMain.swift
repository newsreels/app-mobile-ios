//
//  DiscoverMain.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import SwiftUI

struct DiscoverMain: View {
    
    @State private var searchedString: String = ""
    @State private var isSearching: Bool = false
    @ObservedObject var searchViewModel = SearchViewModel()
    
    //
    var body: some View {
        NavigationView {
            ScrollView {
                
                if searchViewModel.isSearching {
                    // Skeleton loading here
                    SearchLoadingView()
                        .padding(.horizontal)
                } else {
                    
                    if isSearching {
//                        SearchResultView(isSearching: $isSearching).environmentObject(searchViewModel)
//
                        SearchHistoryListView(histories: searchViewModel.histories, didSelect: { history in
                            searchViewModel.search(history.searchText)
                            isSearching = false
                            Utilities.endEditing()
                        }, didDelete: { deletedID in
                            searchViewModel.deleteHistory(deletedID)
                        })

                    } else {
                        if let data = searchViewModel.searchData {
                            dataRows(discoverData: data.data)
//                            .padding(.vertical, 15)
////                            .padding(.horizontal)
                        }
                        else if let data = searchViewModel.discoverData {
                            dataRows(discoverData: data.discover)
                        }
//                        else {
//                            VStack {
//                                TrendingTopicsView()
//                                CryptoPricesView()
////                                TodaySportsView()
//                                WeatherView()
//                                TrendingChannelsView()
//
//                            }
//                            .padding(.vertical, 15)
//
//                        }

                    }
                    
                }
                            
            }
            .navigationTitle(NSLocalizedString("Search", comment: ""))
            .navigationBarTitleDisplayMode(.automatic)
            .navigationBarSearch(text: $searchedString, isSearching: $isSearching.onChange({ value in
                isSearching = value
                if value == false {
                    searchViewModel.searchData = nil
                    searchViewModel.getDiscover()
                }
            }), didSearch: { text in
                isSearching = false
                searchViewModel.search(text)
            }, didClear: {
                isSearching = true
                searchViewModel.searchData = nil
            })
            .onLoad {
                searchViewModel.getSearchHistory()
                searchViewModel.getDiscover()
            }

            
            
        }
        .background(Color.AppF7F7F7)
        .frame(width: UIScreen.main.bounds.size.width)
        .onNotification(.SwiftUIDidChangeLanguage) { notif in            
            LanguageHelper.shared.performWSToUpdateUserContentLanguages(isPrimary: notif.object as? Bool ?? true) {
                SharedManager.shared.performWSToUpdateLanguage(id: LanguageHelper.shared.getSavedLanguage()?.id ?? "", isRefreshedToken: true, completionHandler: { status in
                    if status {
                         searchViewModel.getDiscover()

                    } else {
                        print("language updated failed")
                    }
                })
            }

            
        }
    }
    
    @ViewBuilder
    func dataRows(discoverData: [NewDiscoverSingleData]) -> some View {
        VStack {
            ForEach(discoverData, id: \.title) { data in
                switch data.type {
                case .reels:
                    if let reels = data.reels {
                        TrendingReelsView(reels: reels, title: data.title, fromSearch: true)
                    } else {
                        TrendingReelsView()
                    }
                case .articles:
                    if let articles = data.articles {
                        ArticleListView(articles: articles, title: data.title, fromSearch: true)
                    } else {
                        ArticleListView()
                    }
                case .channels:
                    if let channels = data.sources {
                        TrendingChannelsView(sources: channels, isSearch: true)
                    } else {
                        TrendingChannelsView()
                    }
                case .topics:
                    if let topics = data.topics { // this is search
                        TrendingTopicsView(searchedData: topics, fromSearch: true)
                    } else {
                        TrendingTopicsView()
                    }
                case .weather:
                    WeatherView(country: data.country ?? "")
                case .finance:
//                    CryptoPricesView()
                    Rectangle().frame(height: 0)
                case .youtube:
                    Rectangle().frame(height: 0)
                case .sports:
                    TodaySportsView()
                  
                default:
//                    Text(data.type.rawValue)
                    Rectangle().frame(height: 0)

                }
                
                
            }
            Spacer()
        }
        .padding(.top)
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverMain()
    }
}

