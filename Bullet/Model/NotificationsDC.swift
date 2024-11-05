

struct NotificationsDC : Codable {
    
    let meta : MetaData?
    let notifications : [Notifications]?
}

struct Notifications : Codable {
    
    let id : String?
    let news_id : String?
    let headline : String?
    let source : String?
    let image : String?
    let type : String?
    let read : Bool?
    let created_at : String?
    let detail_id : String?
    let context: String?
}

struct generalNotificationsDC : Codable {
    
    let meta : MetaData?
    let notifications : [NotificationsDetail]?
    let new : [NotificationsDetail]?
}

struct NotificationsDetail : Codable {
    
    let id : String?
    let detail_id : String?
    let detail_image : String?
    let details : String?
    let image : [String]?
    let type : String?
    let read : Bool?
    let created_at : String?
    let context: String?
    let source : String?
}
