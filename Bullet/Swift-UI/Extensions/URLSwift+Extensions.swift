//
//  URL+Extensions.swift
//  Bullet
//
//  Created by Yeshua Lagac on 8/7/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation

extension URL {
    var fbProfPic : URL? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        guard let id = url.queryItems?.first(where: { $0.name == "asid" })?.value else { return nil }
        return URL(string: "https://graph.facebook.com/\(id)/picture?type=large&redirect=true&width=250&height=250")
    }
}
