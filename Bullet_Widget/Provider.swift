//
//  Provider.swift
//  Bullet_WidgetExtension
//
//  Created by Khadim Hussain on 22/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import WidgetKit

struct Provider: TimelineProvider {
   
    
    let loader: BulletResource = BulletResource()
    typealias Entry = BulletEntry
    
    
    func placeholder(in context: Context) -> BulletEntry {
        BulletEntry.mockBulletEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BulletEntry) -> ()) {
    
        loader.getBulletList { (response) in
            
            if let resultArray = response?.articles {
                let currentDate = Date()
                let entry = BulletEntry(date: currentDate, article: resultArray, userName: response?.userName ?? "Your briefing")
                completion(entry)
                
            }
        }
      //  let entry = BulletEntry.mockBulletEntry()
    //    completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        //make your APIs call and data base
        // set the reloaded policy for you widget
     //   var timer = Timer()
        loader.getBulletList { (response) in

            if var resultArray = response?.articles {
                
                var name = "Your briefing"
                if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {

                    name = userDefaults.string(forKey: "first_name") ?? ""
                    name = name.isEmpty || name.lowercased() == "guest" ? "Your briefing" : "\(name)'s briefing"
                }
           
                for (i, var result) in resultArray.enumerated() {
              
                    result.time = self.generateDatTimeOfNews(result.time ?? "")
                    resultArray[i] = result
                }
                
                let currentDate = Date()
                let entry = BulletEntry(date: currentDate, article: resultArray, userName: name)
                let refreshDate = Calendar.current.date(byAdding: .minute, value: 2, to: currentDate)!
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                
              //  WidgetCenter.shared.reloadAllTimelines()
    
//                timer.invalidate()
//                timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { (timer) in
//
//                    print("called after 1 mint")
//                    WidgetCenter.shared.reloadAllTimelines()
//                   // completion(timeline)
//                }
                completion(timeline)
                
            }
        }
    }
}

extension Provider {
    
    func generateDatTimeOfNews(_ pubDate: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        //Check pulbished date is nil with format
        var pDate = formatter.date(from: pubDate) //"2021-07-31T16:45:05Z"
        if pDate == nil {
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX" //was "yyyy-MM-dd'T'HH:mm:ss'Z'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            pDate = formatter.date(from: pubDate)
        }

        let curStr = formatter.string(from: Date())
        
        if let pDate = pDate, let currentDate = formatter.date(from: curStr) {
                        
            let calendar = Calendar.current
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
            let differenceOfDate = calendar.dateComponents(components, from: pDate, to: currentDate)
            //print("date", differenceOfDate)
            var day = differenceOfDate.day!
            let hours = differenceOfDate.hour!
            let min = differenceOfDate.minute!
            
            if day > 0 {
                
                let daysDiff = calendar.dateComponents([.day], from: calendar.startOfDay(for: pDate), to: currentDate)
                //print("date", differenceOfDate)
                day = daysDiff.day!
            }
            
            if abs(day) == 0 {
                
                if abs(hours) < 2 {
                    
                    if abs(hours) < 1 {
                        
                        if min < 1 {
                            return "\(NSLocalizedString("JUST NOW", comment: ""))"
                        } else {
                            return "\(min) \(NSLocalizedString("MINS AGO", comment: ""))"
                        }
                    }
                    else {
                        
                        return NSLocalizedString("AN HOUR AGO", comment: "")
                    }
                }
                else {
                    return "\(hours) \(NSLocalizedString("HOURS AGO", comment: ""))"
                }
            }
            else if abs(day) > 7 {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d"
                return "\(dateFormatter.string(from: pDate))".uppercased()
            }
            else if abs(day) == 7 {
                
                return NSLocalizedString("1 WEEK AGO", comment: "")
            }
            else if abs(day) < 2 {

                return NSLocalizedString("YESTERDAY", comment: "")
            }
            else if day > 1 {
                
                return "\(day) \(NSLocalizedString("DAYS AGO", comment: ""))"
            }
            else {
                
                return "\(-day) \(NSLocalizedString("DAYS AGO", comment: ""))"
            }
        }
        return ""
    }
}
