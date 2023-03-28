//
//  BWSmallView.swift
//  Bullet_WidgetExtension
//
//  Created by Khadim Hussain on 29/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import SwiftUI
import UIKit
import WidgetKit

struct BWSmallView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let activity: NSUserActivity = NSUserActivity.init(activityType: "ViewEventIntent")
    private var eachArticle: [ArticlesData]

    
    init(_eachArticle: [ArticlesData]) {
        self.eachArticle = _eachArticle
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ForEach(0..<1){ index in
                
                if eachArticle.count > 1 {
                    
                    let item = eachArticle[index]
               //     Link(destination: URL(string: "BW\(item.id ?? "")")!) {
                        
                        VStack(alignment: .center) {
                            
                            Spacer().frame(maxWidth: .infinity)
                            
                            Text(item.source_name ?? "")
                                .font(.custom(Constant.FONT_Mulli_EXTRABOLD, size: 14))
                                .foregroundColor(.white)
                                .frame(width: geometry.size.width - 20, height: .none, alignment: .leading)
                                .lineLimit(1)
                            
                            Text(item.title ?? "")
                                //   .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                                .font(.custom(Constant.FONT_Mulli_EXTRABOLD, size: 14))
                                .lineLimit(3)
                                .frame(width: geometry.size.width - 20, height: .none, alignment: .center)
                                .fixedSize()
                                .foregroundColor(.white)
                                .padding(.bottom)
                                .multilineTextAlignment(.leading)
                                
                                .frame(maxHeight: .infinity)
                                
                        }.background(
                            
                            LinearGradient(gradient: Gradient(colors: [Color.black, .clear]), startPoint: .bottom, endPoint: .top)
                                .mask(Image("blackBG")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                )
                                .frame(width: geometry.size.width, height: geometry.size.height - 40),
                            alignment: .bottom
                        )
                        
                     //   .widgetURL("BW\(item.id ?? "")")
                        .widgetURL(URL(string: "BW\(item.id ?? "")"))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                        .background(
                            
                            NetworkImage(url: URL(string: item.image ?? ""))
                                
                                .frame(width: geometry.size.width, height: geometry.size.height),
                            alignment: .top
                        )
             //       }
                }
            }
        }
    }
}

struct BWSmallView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        BWSmallView(_eachArticle: [ArticlesData]())
    //    BWSmallView(_eachArticle: [ArticlesData(id: "4a9cbebd-3027-4615-a10f-6aa544b0c129", title: "ORANGEBURG MILLING - Ad from 2021-01-03 Details for ORANGEBURG MILLING - Ad from 2021-01-03 Welcome to the discussion.", source_name: "Times and Democrat", source_image: "https://cdn.newsinbullets.app/news/images/v7/sources/6a96823d-3294-4c97-b88c-8369ec0d84bb.png", image: "https://cdn.newsinbullets.app/news/images/v7/article/fa7c65a9-093b-4ca9-959f-ef33f3373aa4", category: "")])
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension UIImage {
    /// Average color of the image, nil if it cannot be found
    var averageColor: UIColor? {
        // convert our image to a Core Image Image
        guard let inputImage = CIImage(image: self) else { return nil }
        
        // Create an extent vector (a frame with width and height of our current input image)
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)
        
        // create a CIAreaAverage filter, this will allow us to pull the average color from the image later on
        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        // A bitmap consisting of (r, g, b, a) value
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        
        // Render our output image into a 1 by 1 image supplying it our bitmap to update the values of (i.e the rgba of the 1 by 1 image will fill out bitmap array
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        // Convert our bitmap images of r, g, b, a to a UIColor
        return UIColor(displayP3Red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
}
