//
//  SearchBar.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import Foundation
import SwiftUI
import Combine

extension View {
    func navigationBarSearch(text: Binding<String>, isSearching: Binding<Bool>, didSearch: ((String)->())? = nil, didClear: (()->())? = nil) -> some View {
        return overlay(SearchBar(text: text, isSearching: isSearching, didSearch: didSearch, didClear: didClear)
                        .frame(width: 0, height: 0))
    }
}

fileprivate struct SearchBar: UIViewControllerRepresentable {
    @Binding var text: String
    @Binding var isSearching: Bool
    private var didSearch: ((String)->())?
    private var didClear: (()->())?

    init(text: Binding<String>, isSearching: Binding<Bool>, didSearch: ((String)->())? = nil, didClear: (()->())? = nil) {
        self._text = text
        self._isSearching = isSearching
        self.didSearch = didSearch
        self.didClear = didClear
    }
    
    func makeUIViewController(context: Context) -> SearchBarWrapperController {
        return SearchBarWrapperController()
    }
    
    func updateUIViewController(_ controller: SearchBarWrapperController, context: Context) {
        controller.searchController = context.coordinator.searchController
        controller.searchController?.searchBar.text = text
        controller.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isSearching: $isSearching, didSearch: didSearch, didClear: didClear)
    }
    
    class Coordinator: NSObject, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, UISearchTextFieldDelegate {
        @Binding var text: String
        let searchController: UISearchController
        @Binding var isSearching: Bool
        private var didSearch: ((String)->())?
        private var didClear: (()->())?

        private var subscription: AnyCancellable?
        
        init(text: Binding<String>, isSearching: Binding<Bool>, didSearch: ((String)->())? = nil, didClear: (()->())? = nil) {
            self.searchController = UISearchController(searchResultsController: nil)
            self._text = text
            self._isSearching = isSearching
            self.didSearch = didSearch
            self.didClear = didClear
            super.init()
            
            searchController.navigationItem.hidesSearchBarWhenScrolling = false
            searchController.searchBar.placeholder = "Channels, Topics & Stories"
            searchController.searchBar.searchTextField.font = UIFont.systemFont(ofSize: 8)
            searchController.searchBar.delegate = self
            searchController.searchBar.searchTextField.delegate = self
            searchController.isActive = true
            
            UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor.black

            searchController.searchResultsUpdater = self
            searchController.hidesNavigationBarDuringPresentation = true
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.delegate = self
            
            self.searchController.searchBar.text = self.text
            self.subscription = self.text.publisher.sink { _ in
                self.searchController.searchBar.text = self.text
            }
            
        }
        
        deinit {
            self.subscription?.cancel()
        }
        
        func updateSearchResults(for searchController: UISearchController) {
            guard let text = searchController.searchBar.text else { return }
            self.text = text
        }
        
        func willDismissSearchController(_ searchController: UISearchController) {
            isSearching = false
        }
        
        func willPresentSearchController(_ searchController: UISearchController) {
            isSearching = true
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            // TODO: - Create a new search history
            if let searchedText = searchBar.text, let didSearch = didSearch {
                didSearch(searchedText)
            }
        }
        
        func textFieldShouldClear(_ textField: UITextField) -> Bool {
            if let didClear = didClear {
                didClear()
            }
            return true
        }

   
    }
    
    class SearchBarWrapperController: UIViewController {
        var searchController: UISearchController? {
            didSet {
                self.parent?.navigationItem.hidesSearchBarWhenScrolling = false
                self.parent?.navigationItem.searchController = searchController
            }
        }
        
        override func viewWillAppear(_ animated: Bool) {
            self.parent?.navigationItem.hidesSearchBarWhenScrolling = false
            self.parent?.navigationItem.searchController = searchController
        }
        override func viewDidAppear(_ animated: Bool) {
            self.parent?.navigationItem.hidesSearchBarWhenScrolling = false
            self.parent?.navigationItem.searchController = searchController
        }
    }
}
