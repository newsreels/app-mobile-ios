//
//  SearchLoadingView.swift
//  Bullet
//
//  Created by Yeshua Lagac on 6/23/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import SwiftUI

struct SearchLoadingView: View {
    
    private var color : Color = Color.gray.opacity(0.2)
    private var reelsWidth = (UIScreen.main.bounds.size.width - 50) / 3

    var body: some View {
        VStack (alignment: .leading){
        
            Rectangle().fill(color).cornerRadius(10)
                .frame(width: 220, height: 30)
                .padding(.vertical, 27)

            ForEach(0...5, id: \.self) { value in
                articleRow
                if value != 5 {
                    Divider()
                }
            }
            
            VStack {
                reelsView
                reelsView
            }
            
            
        }

    }
    
    private var reelsView : some View {
        
        VStack {
            Rectangle().fill(color).cornerRadius(10)
                .frame(width: 170, height: 30)
                .padding(.vertical, 27)
            HStack {
                Rectangle().fill(color).frame(width: reelsWidth, height: 200)
                    .cornerRadius(15)
                Rectangle().fill(color).frame(width: reelsWidth, height: 200)
                    .cornerRadius(15)
                Rectangle().fill(color).frame(width: reelsWidth, height: 200)
                    .cornerRadius(15)

            }
        }
       
    }
    
    private var articleRow: some View {
        HStack {
            Rectangle().fill(color).frame(width: 99, height: 99)
                .cornerRadius(15)
            VStack (alignment: .leading){
                Rectangle().fill(color).frame(width: UIScreen.main.bounds.size.width - 150, height: 15)
                    .cornerRadius(15)
                Rectangle().fill(color).frame(width: UIScreen.main.bounds.size.width - 180, height: 15)
                    .cornerRadius(15)
                Rectangle().fill(color).frame(width: UIScreen.main.bounds.size.width - 240, height: 15)
                    .cornerRadius(15)
                
                HStack {
                    Rectangle().fill(color).frame(width: 70, height: 10)
                        .cornerRadius(15)
                    
                    Rectangle().fill(color).frame(width: 90, height: 10)
                        .cornerRadius(15)
                }
            }
          
        }
        .padding(.vertical, 10)
    }
    
}

struct SearchLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        SearchLoadingView()
    }
}
