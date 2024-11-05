//
//  Bullet_Widget.swift
//  Bullet_Widget
//
//  Created by Khadim Hussain on 21/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Bullet_WidgetEntryView : View {
   
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    
    var entry: Provider.Entry

    @ViewBuilder
    var body: some View {
        
        switch family {

        case .systemLarge:
                        
            BWLargeView(_eachArticle: entry.article, _name: entry.userName )
                .background(colorScheme == .dark ? Color(red: 44.0/255.0, green: 44.0/255.0, blue: 46.0/255.0) : Color.white)
            
        case .systemMedium:
            
            BWMediumView(_eachArticle: entry.article)
                .background(colorScheme == .dark ? Color(red: 44.0/255.0, green: 44.0/255.0, blue: 46.0/255.0) : Color.white)

        case .systemSmall:
            
            BWSmallView(_eachArticle: entry.article)
               // .background(colorScheme == .dark ? Color.red : Color.green)

        default:
            
            fatalError()
          //  BWLargeView(_eachArticle: entry.article)
          //      .background(colorScheme == .dark ? Color(red: 44.0/255.0, green: 44.0/255.0, blue: 46.0/255.0) : Color.white)
        }
    }
    
}

@main
struct Bullet_Widget: Widget {
    let kind: String = "Bullet_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Bullet_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Newsreels")
        .description("Get today's news, including top stories.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct Bullet_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Bullet_WidgetEntryView(entry: BulletEntry.mockBulletEntry())
            
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
