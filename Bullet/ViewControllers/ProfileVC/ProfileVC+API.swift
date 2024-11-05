//
//  ProfileVC+Webservices.swift
//  Bullet
//
//  Created by Faris Muhammed on 24/11/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

//MARK:- WebServices
extension ProfileVC {
    
    func performWSToUpdateConfigView() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
//        ANLoader.showLoading(disableUI: true)
        let params = [
            "reader_mode": SharedManager.shared.readerMode,
            "bullets_autoplay": SharedManager.shared.bulletsAutoPlay,
            "reels_autoplay": SharedManager.shared.reelsAutoPlay,
            "videos_autoplay": SharedManager.shared.videoAutoPlay
        ]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config/view", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userConfigViewDC.self, from: response)
                
                if let _ = FULLResponse.message {
                
                    print("Success")
                    
                }
                ANLoader.hide()
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "user/config/view", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            //SharedManager.shared.showAPIFailureAlert()
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSTologoutUser() {
    
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.logoutClick)

        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: false)
        
        let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
        let refreshToken = UserDefaults.standard.value(forKey: Constant.UD_refreshToken) ?? ""
        let params = ["token": refreshToken]
        
        WebService.URLResponseAuth("auth/logout", method: .post, parameters: params, headers: userToken as? String, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
        
                if FULLResponse.message?.lowercased() == "success" {
                    
                    self.appDelegate.logout()
                }
                else {
                    
                    ANLoader.hide()
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "auth/logout", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            
        }){ (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    
}
