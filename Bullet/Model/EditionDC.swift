

import Foundation

public struct EditionDC : Codable {
    
	let editions : [Editions]?
	let meta : MetaData?
}

public struct Editions: Codable {
    
    let id : String?
    let name : String?
    var city : String?
    var state : String?
    let country: String?
    let language : String?
    let image : String?
    let selected : Bool?
    let has_child: Bool?
}


public struct FOLLOWINGCHECKDC: Codable {

    let has_following: Bool?
}


//SELECTED EDITION MODEL
public struct EditionsSelectedDC: Codable {

    let editions : [EditionsSelectedData]?
}

public struct EditionsSelectedData: Codable {

    let id : String?
    let name : String?
    var city : String?
    var state : String?
    let country: String?
    let language : String?
    let image : String?
    let selected : Bool?
    let has_child: Bool?
}

 
//class CITreeViewData {
//
//    let id : String
//    let name : String
//    let country: String
//    let language : String
//    let image : String
//    let selected : Bool
//    let has_child: Bool
//    var children : [CITreeViewData]
//
//    init(id : String, name : String, country : String, language : String, image : String, selected : Bool, has_child : Bool, children: [CITreeViewData]) {
//
//        self.id = id
//        self.name = name
//        self.country = country
//        self.language = language
//        self.image = image
//        self.selected = selected
//        self.has_child = has_child
//        self.children = children
//    }
//
//    convenience init(id : String, name : String, country : String, language : String, image : String, selected : Bool, has_child : Bool) {
//        self.init(id : id, name : name, country : country, language : language, image : image, selected : selected, has_child : has_child, children: [CITreeViewData]())
//    }
//
//    func addChild(_ child : CITreeViewData) {
//        self.children.append(child)
//    }
//
//    func removeChild(_ child : CITreeViewData) {
//        self.children = self.children.filter( {$0 !== child})
//    }
//}
