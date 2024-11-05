//
//  BulletResource.swift
//  Bullet_WidgetExtension
//
//  Created by Khadim Hussain on 22/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import Foundation

protocol BulletResourceProtocol {
    func getBulletList(completionHandler: @escaping(_ result: newsArticlesDC?)-> Void)
}


struct BulletResource: BulletResourceProtocol {

    func getBulletList(completionHandler: @escaping (newsArticlesDC?) -> Void) {
        
        var token = ""
        var url = ""
        if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {

            token = userDefaults.string(forKey: "accessToken") ?? ""
            print(token)

        }
        
        if token.isEmpty {
            
            url = "news/public/articles"
        }
        else {
            
            url = "news/articles/widget"
        }
        
        NetworkManager.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(newsArticlesDC.self, from: response)
   
                completionHandler(FULLResponse)
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
 
}
