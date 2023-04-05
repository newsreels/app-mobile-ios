//
//  ReelsVC+Networking.swift
//  Bullet
//
//  Created by Osman Ahmed on 05/04/2023.
//  Copyright © 2023 Ziro Ride LLC. All rights reserved.
//

import Foundation
import DataCache

extension ReelsVC {
    
     func getReelsCategories() {
        // This should be done in a View Model manner, but this will be refactored later on.
        // Quick fix only
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/home?type=reels", method: .get, parameters: nil, headers: token, withSuccess: { response in

            do {
                let FULLResponse = try
                    JSONDecoder().decode(subCategoriesDC.self, from: response)

                if let homeData = FULLResponse.data {
                    // write Cache Codable types object
                    do {
                        try DataCache.instance.write(codable: homeData, forKey: Constant.CACHE_HOME_TOPICS)
                    } catch {
                        print("Write error \(error.localizedDescription)")
                    }

                    SharedManager.shared.reelsCategories = homeData

                    if SharedManager.shared.curReelsCategoryId == "" {
                        SharedManager.shared.curReelsCategoryId = SharedManager.shared.reelsCategories.first?.id ?? ""
                    }
                }
            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/home?type=reels", error: jsonerror.localizedDescription, code: "")
            }

        }) { _ in

            print("Faeild to get reels categories")
        }
    }

  
}
