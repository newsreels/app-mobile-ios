
//struct subCategoriesDC : Codable {
//
//	let for_you : [For_you]?
//	let top_news : [Top_news]?
//    let force : Bool?
//}

//struct For_you : Codable {
//
//    let header_text : String?
//    let data : [subCategoriesData]?
//}
//
//struct Top_news : Codable {
//
//    let header_text : String?
//    let data : [subCategoriesData]?
//}

struct subCategoriesDC : Codable {
    
    let data : [MainCategoriesData]?
    let topics : [TopicData]?
    let sources : [ChannelInfo]?
    let authors : [Author]?
}

struct homeData : Codable {
    
    let header_text : String?
    let image : String?
    let data : [MainCategoriesData]?
}

struct MainCategoriesData: Codable {
    
    let id : String?
    let title : String?
    //let greeting: String?
    let image : String?
    let pagination : String?
    var sub: [subFeedCategory]?
    var lastModified: String?
    var selectedItem: Bool?
}

struct subFeedCategory: Codable {
    
    let id : String?
    let title : String?
    let pagination : String?
}


