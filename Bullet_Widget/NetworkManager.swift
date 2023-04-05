//
//  NetworkManager.swift
//  Bullet
//
//  Created by Mahesh on 05/08/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Alamofire
import Heimdallr

typealias apiSuccess = (_ data: Data) -> ()
typealias apiFailure = (_ errorString: String) -> ()
typealias HTTPfailure = (_ errorString: String) -> ()


class NetworkManager {
    
    static let apiVersion = "v6"
    
    // MARK: - API Calling Methods
    class func URLResponse(_ url:String, method: HTTPMethod ,parameters: [String: Any]?, headers: String?, withSuccess success: @escaping apiSuccess, withAPIFailure failure: @escaping apiFailure) {
        
        //Staging
//        let completeUrl : String = Constant.Staging.apiBase + url
        
        ///Production
        let completeUrl : String = Constant.Production.apiBase + url
      
   //     print("completeUrl",completeUrl)
        var headersToken = HTTPHeaders()
        if let token = headers {

            headersToken = [
                "Authorization": "Bearer \(token)"
            ]
     //       print("Header token is : ",headersToken)
        }
        
        headersToken["x-app-platform"] = "ios"
        headersToken["x-app-version"] = "1.0.0"
        headersToken["api-version"] = apiVersion
        
        AF.request(completeUrl, method: method, parameters: parameters, encoding: URLEncoding.default, headers:headersToken).validate(statusCode: 200..<600).responseData(completionHandler: { response in
                        
            switch response.result {
                
            case .success(let value):
                
                if response.response?.statusCode == 401 {
                    
                    print("status code...", response.response?.statusCode ?? 0)
                    checkValidToken { (status) in
                        
                        if status {
                            DispatchQueue.main.async {
                                
//                                var token = ""
//                                if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
//
//                                    token = userDefaults.string(forKey: "accessToken") ?? ""
//                                }
                                
                               // print("token updated successfully....call again")
                                let httpHeader: HTTPHeaders = ["x-app-platform": "ios",
                                                           "x-app-version": "1.0.0",
                                                           "api-version": apiVersion]
                                
                               // print("new token is : ",headersToken)
                                
                             //   print(completeUrl)
                                AF.request(completeUrl, method: method, parameters: parameters, encoding: URLEncoding.default, headers: httpHeader).validate(statusCode: 200..<600).responseData(completionHandler: { response in
                                                
                                    switch response.result {
                                        
                                    case .success(let value):
                                        
                                            success(value)

                                    case .failure(let error):
                                        failure(error.localizedDescription)
                                    }
                                })
                            }
                        }
                    }
                    
                }
                else {
                    
                    success(value)
                }
                
            case .failure(let error):
                failure(error.localizedDescription)
            }
        })
    }
    
    class func checkValidToken(_ callBack: @escaping (Bool) -> ()) {
        
        //We need to changed before uploading app from statig to production
        ///Staging
//        let url = Constant.Staging.authTokenURL
//        let clientID = Constant.Staging.appClientID
//        let clientSecret = Constant.Staging.appClientSecret
  
        ///Production
        let url = Constant.Production.authTokenURL
        let clientID = Constant.Production.appClientID
        let clientSecret = Constant.Production.appClientSecret
  
                
        let tokenURL = URL(string: url)!
        let useCredentials = OAuthClientCredentials(id: clientID, secret: clientSecret)
        let heimdall = Heimdallr(tokenURL: tokenURL, credentials: useCredentials)

        var refreshToken = ""
        if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {

            refreshToken = userDefaults.string(forKey: "WRefreshToken") ?? ""
        }
        
       // let refreshToken = UserDefaults.standard.value(forKey: Constant.UD_refreshToken) ?? ""
        var oauthparams = OAuthAuthorizationGrant.refreshToken(refreshToken).parameters
        oauthparams["scope"] = "offline_access"

        heimdall.requestAccessToken(grantType: "refresh_token", parameters: oauthparams) { result in
            
            switch result {
            case .success:
             //   print("success")
                
                if heimdall.hasAccessToken {
                    if let accessToken = heimdall.accessToken?.accessToken {
                    //    print("checkValidToken Token", accessToken)
                        UserDefaults.standard.set(accessToken, forKey: Constant.UD_userToken)
                        
                        //access token for today extension
                        if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                            userDefaults.set(accessToken as AnyObject, forKey: "accessToken")
                            userDefaults.synchronize()
                        }
                        
                        callBack(true)
                    }
                }
            case .failure(let error):
               // print("failure: \(error.localizedDescription)")
                callBack(false)
            }
        }
    }
    
    class func resizeImageByHeight(_ image: UIImage, height: CGFloat) -> UIImage {
            let imageWidth: CGFloat = image.size.width;
            let imageHeight: CGFloat = image.size.height;
            let newWidth: CGFloat = (imageWidth / imageHeight) * height;
            return self.imageByScalingToSize(image, targetSize: CGSize(width: newWidth, height: height))
        }

        class func imageByScalingToSize(_ sourceImage: UIImage, targetSize: CGSize) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 2.0);
            sourceImage.draw(in: CGRect(x: 0, y: 0,width: targetSize.width,height: targetSize.height))
            let generatedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            return generatedImage;
        }
}
