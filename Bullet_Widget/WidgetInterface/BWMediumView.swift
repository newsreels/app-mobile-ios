//
//  BWMediumView.swift
//  Bullet_WidgetExtension
//
//  Created by Khadim Hussain on 29/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import SwiftUI
import UIKit
import WidgetKit

struct BWMediumView: View {
    
    @Environment(\.colorScheme) var colorScheme
    private var eachArticle: [ArticlesData]
    init(_eachArticle: [ArticlesData]) {
        self.eachArticle = _eachArticle
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading) {
                
                HStack() {
                    
                    VStack() {
                        
                        Text("Top Stories")
                            .frame(width: 200, height: 16, alignment: .leading)
                            .font(.custom(Constant.FONT_Mulli_EXTRABOLD, size: 16))
                        //    .foregroundColor(Color(hex: MyThemes.current == .dark ? "#7F7F82" : "#656565"))
                    }
                    Spacer()
                    Image(uiImage: UIImage(named: "Untitled")!)
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 24.0, height: 24.0, alignment: .topLeading)
                        .clipped()
                    
                    
                }.frame(height: 20 , alignment: .center)
                
                VStack {
                    
                    ForEach(0..<2){ index in
                        
                        if eachArticle.count > 1 {
                            
                            let item = eachArticle[index]
                            Link(destination: URL(string: "BW\(item.id ?? "")")!) {
                                
                                HStack {
                                    
                                    VStack(alignment: .leading) {
                                        
//                                        HStack(alignment: .top) {
//
//                                            NetworkImage(url: URL(string: item.source_image ?? ""))
//                                                .aspectRatio(contentMode: .fill)
//                                                .frame(width: 14.0, height: 14.0, alignment: .top)
//                                                .cornerRadius(2.0, antialiased: true)
//                                                .clipped()
//
//                                            Text(item.source_name ?? "")
//                                                .frame(width: 200, height: 12, alignment: .leading)
//                                                .font(.custom(Constant.FONT_Mulli_EXTRABOLD, size: 8))
//                                                .foregroundColor(Color(hex: "#595959"))
//
//                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4){
                                            Text(item.title ?? "")
                                                // .frame(width: geometry.size.width - 40 ,height: max(<#T##x: Comparable##Comparable#>, <#T##y: Comparable##Comparable#>) ,alignment: .leading)
                                                .font(.custom(Constant.FONT_Mulli_EXTRABOLD, size: 14))
                                                .lineLimit(2)
                                            
                                            Text("\(item.source_name ?? "") - \(item.time ?? "")")
                                                .font(.custom(Constant.FONT_Mulli_REGULAR, size: 11))
                                                .lineLimit(1)
                                                .foregroundColor(Color(hex: MyThemes.current == .dark ? "#7F7F82" : "#656565"))
                                        }
                                    
                                    }
                                    Spacer()
                                    
                                    NetworkImage(url: URL(string: item.image ?? ""))
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 48.0, height: 48, alignment: .center)
                                        .cornerRadius(10.0, antialiased: true)
                                        .clipped()
                                }
                                .frame(height: (geometry.size.height / 2) - 32 , alignment: .center)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct BWMediumView_Previews: PreviewProvider {
    @available(iOS 13.0, *)
    static var previews: some View {
        
        BWMediumView(_eachArticle: [ArticlesData]())
//        BWMediumView(_eachArticle: [ArticlesData(id: "4a9cbebd-3027-4615-a10f-6aa544b0c129", title: "ORANGEBURG MILLING - Ad from 2021-01-03 Details for ORANGEBURG MILLING - Ad from 2021-01-03 Welcome to the discussion.", source_name: "Times and Democrat", source_image: "https://cdn.newsinbullets.app/news/images/v7/sources/6a96823d-3294-4c97-b88c-8369ec0d84bb.png", image: "https://cdn.newsinbullets.app/news/images/v7/article/fa7c65a9-093b-4ca9-959f-ef33f3373aa4"), ArticlesData(id: "4a9cbebd-3027-4615-a10f-6aa544b0c129", title: "ORANGEBURG MILLING - Ad from 2021-01-03 Details for ORANGEBURG MILLING - Ad from 2021-01-03 Welcome to the discussion.", source_name: "Times and Democrat", source_image: "https://cdn.newsinbullets.app/news/images/v7/sources/6a96823d-3294-4c97-b88c-8369ec0d84bb.png", image: "https://cdn.newsinbullets.app/news/images/v7/article/fa7c65a9-093b-4ca9-959f-ef33f3373aa4")])
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
