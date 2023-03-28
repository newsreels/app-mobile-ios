
import Foundation
struct loginDC : Codable {
    
    let methodName : String?
    let version : String?
    let release : String?
    let datetime : String?
    let status : String?
    let statusCode : Int?
    let message : String?
    let result : [LoginResult]?
}

struct LoginResult : Codable {
    
    let userId : Int?
    let user : String?
    let customerId : Int?
    let customer : String?
    let accessToken : String?
    let accountNo : Int?
    let roleId : Int?
    let isAutorefreshOn : Bool?
    let autorefreshMin : Int?
}
