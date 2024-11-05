
import Foundation

struct NotificationConfigDC : Codable {
    
    let push : Push?
}

struct Push : Codable {
    
    let breaking : Bool?
    let personalized : Bool?
    let frequency : String?
    let start_time: String?
    let end_time: String?
    
}

public struct UpdateNotificationConfig: Codable {
    
    var message: String?
}


//MARK: - Root Class - user_config_view

public struct userConfigViewDC: Codable {
    
    var message: String?
}

//MARK: - Root Class - user_config

public struct userConfigDC: Codable {
    
    let home_preference: HomePreferenceData?
    //let registration: RegistrationData?
    let editions : [EditionsData]?
    let alert: Alert?
    let ads : Ads?
//    let `static`: Static?
    let rating: Rating?
    let terms: Terms?
    let user: UserProfile?
    let wallet: String?
    let onboarded: Bool?
}

struct Terms: Codable {
    let community: Bool?
}

struct Rating: Codable {
    
    let interval: Int?
    let next_interval: Int?
}

struct Static: Codable {
    
    var home_image: HomeImage?
}

struct HomeImage: Codable {
    
    let left: String?
    var opacity: Double?
    let right: String?
}

struct Ads: Codable {
    
    let enabled: Bool?
    let ad_unit_key: String?
    let interval: Int?
    let type: String?
    let facebook: AdPlacement?
    let admob: AdPlacement?
}

struct AdPlacement: Codable {
    var feed: String?
    var reel: String?
}

struct Alert: Codable {
    
    let id: String?
    let title: String?
    let message: String?
    let image: String?
}

struct EditionsData: Codable {

    let id: String?
    let name: String?
    let language: String?
    let image: String?
}

//MARK: - HomePreference
public struct HomePreferenceData: Codable {
    
    let view_mode: String?
    let auto_scroll: Bool?
    let narration: NarrationData?
    let mode: String?
    let tutorial_done: Bool?
    let bullets_autoplay: Bool?
    let videos_autoplay: Bool?
    let reels_autoplay: Bool?
    let reader_mode: Bool?
}

// MARK: - Narration
struct NarrationData: Codable {
    
    let muted: Bool?
    //let reading_speed: Double?
    let mode: String?
    let speed: String?
    let speed_rate: [String: Double]?
}

//// MARK: - Registration
struct RegistrationData: Codable {
    let source, topic, edition: Source?
}

// MARK: - Source
struct Source: Codable {

    let done: Bool?
    let minimum: Int?
}
