
import Foundation

//MARK: - Root Class - user_news_home

public struct newsHomeDC: Codable {
    
    var topics: [TopicData]?
    var channels: [ChannelInfo]?
    var top_news: [newsHomeHeadlinesData]?
    var local: [newsHomeLocalData]?
}

public struct newsHomeHeadlinesData: Codable {
    
    var id: String?
    var name: String?

}

public struct newsHomeLocalData: Codable {
    
    var id: String?
    var city: String?
    var country: String?
}




