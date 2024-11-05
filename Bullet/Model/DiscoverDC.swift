

import Foundation

struct DiscoverDC : Codable {
    
	let discover : [Discover]?
    var meta: MetaData?
    
}

struct Discover : Codable {
    
    let title : String?
    let subtitle : String?
    let type : String?
    var data : DataDiscover?
}

struct DataDiscover : Codable {
    
    let video : articlesData?
    var articles: [articlesData]?
    let reel: articlesData?
    let context: String?
    let image: String?
    var article: articlesData?
    var icons: [icons]?
    
}

struct icons: Codable {
    var icon: String?
    var name: String?
}

struct subData : Codable {
    
    let id : String?
    let title : String?
    let image : String?
    let link : String?
    let publish_time : String?
    let source : ChannelInfo?
    let bullets : [Bullets]?
  //  let topics : [String]?
    let mute : Bool?
    let type : String?
  //  let info : Info?
    
    let description: String?
    let media: String?
}


