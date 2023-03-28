
import Foundation
struct CategorizeSourceDC : Codable {
    
    let categories : [Categories]?
}

struct sourceCategoryDC : Codable {
    
    let category : CategoryData?
}
struct CategoryData : Codable {
    
    let name : String?
    let sources : [Sources]?
    let meta : Meta?
}

struct Categories : Codable {
    
    let name : String?
    let sources : [Sources]?
    let meta : Meta?
}

struct Meta : Codable {
    
    let total_record : Int?
    let total_page : Int?
    let offset : Int?
    let limit : Int?
    let page : Int?
    let prev_page : Int?
    let next: String?
}

struct Sources : Codable {
    
    let id : String?
    let name : String?
    let link : String?
    let image : String?
    let icon : String?
    let color : String?
    let text_color : String?
    var favorite : Bool?
}
