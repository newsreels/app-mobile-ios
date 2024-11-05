//
//  SearchHistoryListView.swift
//  Bullet
//
//  Created by Yeshua Lagac on 8/1/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import SwiftUI

struct SearchHistoryListView: View {
    
    let histories: [SearchHistory]
    
    let didSelect : ((SearchHistory) ->())
    let didDelete : ((String) ->())
    
    var body: some View {
        VStack {
            ForEach(histories, id: \.id) { value in
                historyRow(value)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func historyRow(_ history: SearchHistory) -> some View {
        HStack (spacing: 25) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.black)
                .font(.system(size: 16))
            AppText(history.searchText, weight: .semiBold, size: 18, color: .black)
            Spacer()
            Button {
                didDelete(history.id)
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
            }

        }
        .background(Color.white)
        .onTapGesture {
            didSelect(history)
        }
        .frame(height: 40)
    }
}

struct SearchHistoryListView_Previews: PreviewProvider {
    static var previews: some View {
        SearchHistoryListView(histories: [], didSelect: { _ in
            
        }
                              , didDelete: { _ in
            
        }
        )
    }
}
