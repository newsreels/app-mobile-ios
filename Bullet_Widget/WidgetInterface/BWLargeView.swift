//
//  BWLargeViewt.swift
//  BWLargeView
//
//  Created by Khadim Hussain on 21/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.

import SwiftUI
import UIKit
import WidgetKit

@available(iOS 14.0, *)

struct BWLargeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    private var eachArticle: [ArticlesData]
    var userName = "Your briefing"
    init(_eachArticle: [ArticlesData], _name:String) {
        self.eachArticle = _eachArticle
        self.userName = _name
    }
    var body: some View {
        
        GeometryReader { geometry in
  
            VStack(alignment: .leading) {
                
                HStack() {
                    
                    VStack() {
                    Text(userName)
                        .frame(width: 200, height: 20, alignment: .leading)
                        .font(.custom(Constant.FONT_Mulli_EXTRABOLD, size: 18))
                     //   .foregroundColor(Color(hex: MyThemes.current == .dark ? "#7F7F82" : "#656565"))
                    }
                    Spacer()
             
                    
                    Image(uiImage: UIImage(named: "Untitled")!)
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 24.0, height: 24.0, alignment: .topLeading)
                        .clipped()
    
                }.frame(height: 20 , alignment: .center)
                
                VStack {
                    ForEach(0..<4){ index in
                        
                        if eachArticle.count > 1 {
                            
                            let item = eachArticle[index]
                            Link(destination: URL(string: "BW\(item.id ?? "")")!) {
                                
                                HStack {
                              
                                    VStack(alignment: .leading) {
                                        
 //                                       HStack(alignment: .top) {
                                            
//                                            NetworkImage(url: URL(string: item.source_image ?? ""))
//                                                .aspectRatio(contentMode: .fill)
//                                                .frame(width: 14.0, height: 14.0, alignment: .top)
//                                                .cornerRadius(2.0, antialiased: true)
//                                                .clipped()
                                            
//                                            Text(item.source_name ?? "")
//                                                .frame(width: 200, height: 12, alignment: .leading)
//                                                .font(.custom(Constant.FONT_Mulli_EXTRABOLD, size: 14))
//                                                //   let gray0 = Color(hex: "#909090")
//                                                .foregroundColor(Color(hex: "#595959"))
                                            
//                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4){
                                            Text(item.title ?? "")
                                                // .frame(width: geometry.size.width - 40 ,height: max(<#T##x: Comparable##Comparable#>, <#T##y: Comparable##Comparable#>) ,alignment: .leading)
                                                .font(.custom(Constant.FONT_Mulli_EXTRABOLD, size: 14))
                                                .lineLimit(2)
                                            
                                            Text("\(item.source_name ?? "") - \(item.time ?? "")")
                                                .font(.custom(Constant.FONT_Mulli_REGULAR, size: 12))
                                                .lineLimit(1)
                                                .foregroundColor(Color(hex: MyThemes.current == .dark ? "#7F7F82" : "#656565"))
                                        }
                                    }
                                    Spacer()
                                    
                                    NetworkImage(url: URL(string: item.image ?? ""))
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 56.0, height: 56.0, alignment: .center)
                                        .cornerRadius(10.0, antialiased: true)
                                        .clipped()
                                }
                                .frame(height:(geometry.size.height - 84) / 4 , alignment: .center)
                            }
                        }
                    }
                }
            }
            .padding()
            // .background(colorScheme == .dark ? Color.red : Color.green)
            
        }
    }
}

struct NetworkImage: View {
    
    let url: URL?
    
    var body: some View {
        
        Group {
            if let url = url, let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            else {
                Image("icn_placeholder")
            }
        }
    }
}


struct ArticlesList_Previews: PreviewProvider {
    @available(iOS 13.0, *)
    static var previews: some View {
    
        BWLargeView(_eachArticle: [ArticlesData](), _name: "Your briefing")
//        BWLargeView(_eachArticle: [ArticlesData(id: "4a9cbebd-3027-4615-a10f-6aa544b0c129", title: "ORANGEBURG MILLING - Ad from 2021-01-03 Details for ORANGEBURG MILLING - Ad from 2021-01-03 Welcome to the discussion.", source_name: "Times and Democrat", source_image: "https://cdn.newsinbullets.app/news/images/v7/sources/6a96823d-3294-4c97-b88c-8369ec0d84bb.png", image: "https://cdn.newsinbullets.app/news/images/v7/article/fa7c65a9-093b-4ca9-959f-ef33f3373aa4"), ArticlesData(id: "4a9cbebd-3027-4615-a10f-6aa544b0c129", title: "ORANGEBURG MILLING - Ad from 2021-01-03 Details for ORANGEBURG MILLING - Ad from 2021-01-03 Welcome to the discussion.", source_name: "Times and Democrat", source_image: "https://cdn.newsinbullets.app/news/images/v7/sources/6a96823d-3294-4c97-b88c-8369ec0d84bb.png", image: "https://cdn.newsinbullets.app/news/images/v7/article/fa7c65a9-093b-4ca9-959f-ef33f3373aa4"), ArticlesData(id: "4a9cbebd-3027-4615-a10f-6aa544b0c129", title: "ORANGEBURG MILLING - Ad from 2021-01-03 Details for ORANGEBURG MILLING - Ad from 2021-01-03 Welcome to the discussion.", source_name: "Times and Democrat", source_image: "https://cdn.newsinbullets.app/news/images/v7/sources/6a96823d-3294-4c97-b88c-8369ec0d84bb.png", image: "https://cdn.newsinbullets.app/news/images/v7/article/fa7c65a9-093b-4ca9-959f-ef33f3373aa4"), ArticlesData(id: "4a9cbebd-3027-4615-a10f-6aa544b0c129", title: "ORANGEBURG MILLING - Ad from 2021-01-03 Details for ORANGEBURG MILLING - Ad from 2021-01-03 Welcome to the discussion.", source_name: "Times and Democrat", source_image: "https://cdn.newsinbullets.app/news/images/v7/sources/6a96823d-3294-4c97-b88c-8369ec0d84bb.png", image: "https://cdn.newsinbullets.app/news/images/v7/article/fa7c65a9-093b-4ca9-959f-ef33f3373aa4")], _name: "Your briefing")
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

extension Color {
    init(hex string: String) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }

        // Double the last value if incomplete hex
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }

        // Fix invalid values
        if string.count > 8 {
            string = String(string.prefix(8))
        }

        // Scanner creation
        let scanner = Scanner(string: string)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        if string.count == 2 {
            let mask = 0xFF

            let g = Int(color) & mask

            let gray = Double(g) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)

        } else if string.count == 4 {
            let mask = 0x00FF

            let g = Int(color >> 8) & mask
            let a = Int(color) & mask

            let gray = Double(g) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)

        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)

        } else if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)

        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }
}
