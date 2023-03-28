import Foundation

struct TagsDC : Codable {
    
	let tags : [Tags]?
}

struct Tags : Codable {
    
    let id : String?
    let name : String?
    let icon : String?
    let image : String?
}
