
import Foundation

struct RelevantDC : Codable {
    
	let exact_match : String?
	let articles : [articlesData]?
	let topics : [TopicData]?
	let sources : [ChannelInfo]?
	let locations : [Location]?
    let authors : [Author]?
    let article_context: String?
    let article_page: Relevant_Meta?
    let reels: [Reel]?
    
}

struct Relevant {
    var type: RelevantVC.searchType!
    var articles : [articlesData]?
    var topics : [TopicData]?
    var sources : [ChannelInfo]?
    var locations : [Location]?
    var authors : [Author]?
    var reels : [Reel]?
    var isTopOne: Bool?
    
    init(type: RelevantVC.searchType, articles: [articlesData]?, topics: [TopicData]?, sources: [ChannelInfo]?, locations: [Location]?, authors : [Author]?, reels : [Reel]?, isTopOne: Bool?) {
        self.type = type
        self.articles = articles
        self.topics = topics
        self.sources = sources
        self.locations = locations
        self.authors = authors
        self.reels = reels
        self.isTopOne = isTopOne
    }
    
}


struct Relevant_Meta : Codable {
    
    let next: String?
}

