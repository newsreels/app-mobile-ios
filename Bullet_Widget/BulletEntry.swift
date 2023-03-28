//
//  BulletEntry.swift
//  Bullet_WidgetExtension
//
//  Created by Khadim Hussain on 22/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import WidgetKit

struct BulletEntry: TimelineEntry {
    
    let date: Date
    var article: [ArticlesData]
    var userName: String
    
    static func mockBulletEntry() -> BulletEntry {
        
        return BulletEntry (date: Date(), article: [ArticlesData(id: "4a9cbebd-3027-4615-a10f-6aa544b0c129", title: "ORANGEBURG MILLING - Ad from 2021-01-03 Details for ORANGEBURG MILLING - Ad from 2021-01-03 Welcome to the discussion.", source_name: "Times and Democrat", source_image: "https://cdn.newsinbullets.app/news/images/v7/sources/6a96823d-3294-4c97-b88c-8369ec0d84bb.png", image: "https://cdn.newsinbullets.app/news/images/v7/article/fa7c65a9-093b-4ca9-959f-ef33f3373aa4",category: "",time: "")], userName: "Your briefing")
    }
}
