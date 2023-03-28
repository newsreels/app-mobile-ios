//
//  TodaySportsView.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import SwiftUI

struct TodaySportsView: View {
    
    @ObservedObject var viewModel = TodaySportsViewModel()
    private let headerTitles : [SportsType] = [.cricket]
    @State private var selectedIndex: Int = 0
    @State var isError: Bool = false

    
    var body: some View {
        if let cricketData = viewModel.cricketData {
            
            
            VStack {
                SectionTitleView(title: NSLocalizedString("Todays Sports Schedule", comment: ""), onTapSeeAll: { })
                    .padding(.bottom)
                    .padding(.horizontal)
                VStack {
                    header
                        .padding(.top)
                        .padding(.bottom, 10)
                    
                    VStack {
                        if let cricketData = viewModel.cricketData {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack (spacing: 10){
                                    if !cricketData.stages.isEmpty {
                                        ForEach(0...cricketData.stages.count - 1, id: \.self) { index in
                                            CricketCard(cricket: cricketData.stages[index])
                                                .frame(width: UIScreen.main.bounds.size.width - 80, height: 150)
                                        }
                                    }
                                    
                                    
                                }
                                .padding(.horizontal)
                            }
                        } else if let basketballData = viewModel.basketballData {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack (spacing: 10){
                                    if !basketballData.stages.isEmpty {
                                        ForEach(0...basketballData.stages.count - 1, id: \.self) { index in
                                            BasketballCard(basketball: basketballData.stages[index])
                                                .frame(width: UIScreen.main.bounds.size.width - 80, height: 150)
                                        }
                                    }
                                    
                                    
                                }
                                .padding(.horizontal)
                            }
                        }
                        //                    else {
                        //                        ScrollView(.horizontal, showsIndicators: false) {
                        //                            HStack (spacing: 10){
                        //                                ForEach (0...7, id: \.self) { _ in
                        //                                    SportsLoadingCard()
                        //                                        .frame(width: UIScreen.main.bounds.size.width - 80, height: 150)
                        //                                }
                        //                            }
                        //                            .padding(.horizontal)
                        //                        }
                        //
                        //                    }
                    }
                    .padding(.bottom)
                    
                    
                    
                    
                }
                .background(Color.init(hex: "F8506E"))
            }
        }

        
    }
    
    var header: some View {
        ScrollView (.horizontal, showsIndicators: false){
            HStack {
                ForEach(headerTitles, id: \.self) { type in
                    VStack {
                        AppText(type.displayName, weight: isSelected(type: type) ? .semiBold : .regular, size: 13, color: .white)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 20)
                        .overlay(Rectangle().fill(isSelected(type: type) ? Color.white : Color.clear).frame(height: 2).offset(y : 10))
                    
                    }
                    .onTapGesture {
//                        if let index = headerTitles.firstIndex(of: type) {
//                            withAnimation {
//                                selectedIndex = index
//                                viewModel.fetchSchedules(type: type, date: Date())
//                            }
//                        }
                    }
                }
            }
            .padding(.horizontal)

        }
       
    }
    
    private func isSelected(type: SportsType) -> Bool {
        if let index = headerTitles.firstIndex(of: type) {
            if index == selectedIndex {
                return true
            }
        }
        return false
    }
}

struct TodaySportsView_Previews: PreviewProvider {
    static var previews: some View {
        TodaySportsView()
    }
}
