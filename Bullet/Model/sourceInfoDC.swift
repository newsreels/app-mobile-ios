
import Foundation

//Old object
struct sourceInfoDC : Codable {
    
	let info : sourceInfo?
    let message: String?
}

struct sourceInfo : Codable {
    
    let categories : [ChannelInfo]?
    let name : String?
    let language : String?
    let category : String?
    let category_title : String?
    let favorite : Bool?
}


//"channel": {
//       "id": "9f90444a-df85-4f32-a0de-0cf319c84b97",
//       "name": "News18",
//       "description": "",
//       "link": "news18.com",
//       "icon": "https://cdn.newsinbullets.app/news/generated/sources/icon/9d720953-b138-4c07-8fea-b5b0b196e74b.png",
//       "image": "https://cdn.newsinbullets.app/news/generated/sources/image/9d720953-b138-4c07-8fea-b5b0b196e74b.png",
//       "update_count": 0,
//       "follower_count": 0,
//       "post_count": 0,
//       "own": false
//   }
