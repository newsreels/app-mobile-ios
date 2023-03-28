//
//  SearchViewModel.swift
//  Bullet
//
//  Created by Yeshua Lagac on 7/31/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation

class SearchViewModel: ObservableObject {
    
    @Published var isSearching: Bool = false
    @Published var searchData: NewSearchData?
    @Published var discoverData: NewDiscoverData?

    @Published var histories: [SearchHistory] = []
    
    func search(_ text: String) {
        isSearching = true
        reset()
        URLSessionProvider.shared.request(NewSearchData.self, service: SearchService.search(string: text)) { result in
            DispatchQueue.main.async {
                self.isSearching = false
                switch result {
                case .success(let data):
                    self.searchData = data
                    if !self.histories.contains(where: {$0.searchText == data.search.searchText}) {
                        self.histories.append(data.search)
                    }
                case .failure(let error):
                    print("ERROR || Failed to search \(error.localizedDescription)")
                    self.searchData = nil
                }
            }
        }
    }
    
    func getDiscover() {
        DispatchQueue.main.async {
            self.isSearching = true
        }
        reset()

        URLSessionProvider.shared.request(NewDiscoverData.self, service: SearchService.getDiscover) { result in
            DispatchQueue.main.async {
                self.isSearching = false
                switch result {
                case .success(let data):
                    self.discoverData = data
                case .failure:
                    self.discoverData = nil
                }
            }
          
        }
    }
    
    func getSearchHistory() {
        URLSessionProvider.shared.request(HistoryData.self, service: SearchService.getHistory) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.histories = data.histories
                case .failure:
                    self.histories = []
                }
            }
        }

    }
    
    func deleteHistory(_ id: String) {
        URLSessionProvider.shared.request(service: SearchService.delete(id: id)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.histories.removeAll(where: {$0.id == id})
                case .failure:
                    break
                }
            }
        }

    }
    
    private func reset() {
        DispatchQueue.main.async {
            self.discoverData = nil
            self.searchData = nil
        }
    }
}
