

import Foundation
struct newsArticlesDC : Codable {
    
	let articles : [ArticlesData]?
    let userName: String?
}

struct ArticlesData : Codable {
    
    let id : String?
    let title : String?
    let source_name : String?
    let source_image : String?
    let image : String?
    let category : String?
    var time : String?
}
