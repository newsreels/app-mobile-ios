//
//  WebService.swift
//  Bullet
//
//  Created by Mahesh on 13/04/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Alamofire
import Heimdallr

//let API_VERSION                                 = "youtube"

typealias apiSuccess = (_ data: Data) -> ()
typealias apiFailure = (_ errorString: String) -> ()
typealias HTTPfailure = (_ errorString: String) -> ()
typealias CompletionHandler = () -> ()


class WebService {
    
    // MARK: - API Calling Methods
    class func URLResponse(_ url:String, method: HTTPMethod ,parameters: [String: Any]?, headers: String?, withSuccess success: @escaping apiSuccess, withAPIFailure failure: @escaping apiFailure) {
        
        let completeUrl : String = WebserviceManager.shared.API_BASE + url
        //print(completeUrl)
        
        var headersToken = HTTPHeaders()
        if let token = headers {
             
            headersToken = [
                "Authorization": "Bearer \(token)"
            ]
            
            #if DEBUG
            print("Header token is : ",headersToken)
            #endif
        }
        
      //  headersToken["x-forwarded-for"] = "2.18.48.5"
        headersToken["x-app-platform"] = "ios"
        headersToken["x-app-version"] = Bundle.main.releaseVersionNumberPretty
        headersToken["api-version"] = WebserviceManager.shared.API_VERSION
        headersToken["x-user-language"] = Locale.current.languageCode ?? "en"

//        Alamofire.Session.default.session.getAllTasks { tasks in
//            tasks.forEach { $0.cancel() }
//        }

        AF.requestWithoutCache(completeUrl, method: method, parameters: parameters, encoding: URLEncoding.default, headers:headersToken).validate(statusCode: 200..<600).responseData(completionHandler: { response in
                    
            if let modifiedTime = response.response?.allHeaderFields["Last-Modified"] as? String {
                
                if url == "news/discover" {
                    SharedManager.shared.lastModifiedTimeDiscover = modifiedTime
                }
                else if url.contains("news/feeds") {
                    SharedManager.shared.lastModifiedTimeFeeds = modifiedTime
                }
            }
            
            switch response.result {
                
            case .success(let value):
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                #if DEBUG
                print("API status code...",completeUrl, response.response?.statusCode ?? 0)
                #endif
                
                if response.response?.statusCode == 401 {
                    
                    checkValidToken { (status) in
                        
                        if status {
                            DispatchQueue.main.async {
                                
                            //    print("token updated successfully....call again")
                                var httpHeader: HTTPHeaders = [:]
                                if ((UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "") as? String ?? "").isEmpty {
                                    httpHeader = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                                                               "x-app-platform": "ios",
                                                               "x-app-version": Bundle.main.releaseVersionNumberPretty,
                                                                   "x-user-language" : Locale.current.languageCode ?? "en",
                                                               "api-version": WebserviceManager.shared.API_VERSION]
                                } else {
                                    httpHeader = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                                                               "x-app-platform": "ios",
                                                               "x-app-version": Bundle.main.releaseVersionNumberPretty,
                                                               "api-version": WebserviceManager.shared.API_VERSION]
                                }

                            //    print("new token is : ",headersToken)
                                
                                //print(completeUrl)
                                AF.request(completeUrl, method: method, parameters: parameters, encoding: URLEncoding.default, headers: httpHeader).validate(statusCode: 200..<600).responseData(completionHandler: { response in
                                                
                                    switch response.result {
                                        
                                    case .success(let value):
                                        
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        if (response.response?.statusCode ?? 0) > 299 {
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                print("Logout")
                                                appDelegate.logout()
                                            }
                                        }
                                        else {
                                            success(value)
                                        }
                                        
                                    case .failure(let error):
                                        SharedManager.shared.logAPIError(url: url, error: error.localizedDescription, code: "\(response.response?.statusCode ?? 0)")
                                        failure(error.localizedDescription)
                                    }
                                })
                            }
                        }
                        else {
                            failure("")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("Logout")
                                appDelegate.logout()
                            }
                        }
                    }
                    
                } else if response.response?.statusCode == 423 {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("Logout")
                        appDelegate.logout()
                    }

                }
                
                else if response.response?.statusCode == 412 {
                    
                    let vc = forceUpdateVC.instantiate(fromAppStoryboard: .registration)
                    (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }
                
                else if response.response?.statusCode == 500 || response.response?.statusCode == 503 {
                    
                    print("Service Unavailable || Internal Server Error  : ", completeUrl)
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Oops! Something went wrong. Please try again.", comment: ""), type: .alert)
                    //SharedManager.shared.logAPIError(url: url, error: "", code: "\(response.response?.statusCode ?? 0)")
                    success(value)
                }
                else {
                    SharedManager.shared.logAPIError(url: url, error: "", code: "\(response.response?.statusCode ?? 0)")
                    
                    success(value)
                }
                
            case .failure(let error):
                SharedManager.shared.logAPIError(url: url, error: "", code: "\(response.response?.statusCode ?? 0)")
                failure(error.localizedDescription)
            }
        })
    }
    
    class func URLResponseAuth(_ url:String, method: HTTPMethod ,parameters: [String: Any]?, headers: String?, withSuccess success: @escaping apiSuccess, withAPIFailure failure: @escaping apiFailure) {

        let completeUrl : String = WebserviceManager.shared.AUTH_BASE_URL + url
        //print(completeUrl)

        var headersToken = HTTPHeaders()
        if let token = headers {

            headersToken = [
                "Authorization": "Bearer \(token)"
            ]
            
            #if DEBUG
            print("Header token is : ",headersToken)
            #endif
        }

      //  headersToken["x-forwarded-for"] = "2.18.48.5"
        headersToken["x-app-platform"] = "ios"
        headersToken["x-app-version"] = Bundle.main.releaseVersionNumberPretty
        headersToken["api-version"] = WebserviceManager.shared.API_VERSION
        if ((UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "") as? String ?? "").isEmpty {
            headersToken["x-user-language"] = Locale.current.languageCode ?? "en"
        }


        AF.request(completeUrl, method: method, parameters: parameters, encoding: URLEncoding.default, headers:headersToken).validate(statusCode: 200..<600).responseData(completionHandler: { response in

            switch response.result {

            case .success(let value):

                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if response.response?.statusCode == 401 {

                    //print("status code...", response.response?.statusCode ?? 0)
                    checkValidToken { (status) in

                        if status {
                            DispatchQueue.main.async {

                            //    print("token updated successfully....call again")

                                var httpHeader : HTTPHeaders = [:]
                                if ((UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "") as? String ?? "").isEmpty {
                                    httpHeader = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                                                               "x-app-platform": "ios",
                                                               "x-app-version": Bundle.main.releaseVersionNumberPretty,
                                                                   "x-user-language" : Locale.current.languageCode ?? "en",
                                                               "api-version": WebserviceManager.shared.API_VERSION]
                                } else {
                                    httpHeader = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                                                               "x-app-platform": "ios",
                                                               "x-app-version": Bundle.main.releaseVersionNumberPretty,
                                                               "api-version": WebserviceManager.shared.API_VERSION]
                                }

                            //    print("new token is : ",headersToken)

                                //print(completeUrl)
                                AF.request(completeUrl, method: method, parameters: parameters, encoding: URLEncoding.default, headers: httpHeader).validate(statusCode: 200..<600).responseData(completionHandler: { response in

                                    switch response.result {

                                    case .success(let value):

                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        if response.response?.statusCode == 423 {

                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                print("Logout")
                                                appDelegate.logout()
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
                        }
                        else {
                            failure("")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("Logout")
//                                appDelegate.logout()
                            }
                        }
                    }

                } else if response.response?.statusCode == 423 {

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("Logout")
                        appDelegate.logout()
                    }

                }

                else if response.response?.statusCode == 412 {

                    let vc = forceUpdateVC.instantiate(fromAppStoryboard: .registration)
                    (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }

                else if response.response?.statusCode == 503 {

                    print("Service Unavailable: ", completeUrl)
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Oops! Something went wrong. Please try again.", comment: ""), type: .alert)
                    //SharedManager.shared.logAPIError(url: url, error: "", code: "\(response.response?.statusCode ?? 0)")
                    success(value)
                }
                else if (response.response?.statusCode ?? 0) >= 400 && (response.response?.statusCode ?? 0) < 500 {

                    success(value)
                }
                else if (response.response?.statusCode ?? 0) < 300 {
                    
                    SharedManager.shared.logAPIError(url: url, error: "", code: "\(response.response?.statusCode ?? 0)")
                    
                    success(value)
                }
                else {
                    success(value)
                }

            case .failure(let error):
                SharedManager.shared.logAPIError(url: url, error: "", code: "\(response.response?.statusCode ?? 0)")
                failure(error.localizedDescription)
            }
        })
    }
    
    class func cancelAPIRequest() {
        
        Alamofire.Session.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
    
    class func checkValidToken(_ callBack: @escaping (Bool) -> ()) {
        
//        let tokenURL = URL(string: Constant.APP_TOKEN_URL)!
//        let useCredentials = OAuthClientCredentials(id: Constant.APP_CLIENT_ID)
//
//        let heimdall = Heimdallr(tokenURL: tokenURL, credentials: useCredentials)
//        var oauthparams = OAuthAuthorizationGrant.refreshToken(refreshToken as! String).parameters
//        oauthparams["scope"] = "offline_access"

        let refreshToken = UserDefaults.standard.value(forKey: Constant.UD_refreshToken) ?? ""
        
        let tokenURL = URL(string: WebserviceManager.shared.AUTH_TOKEN_URL)!
        let useCredentials = OAuthClientCredentials(id: WebserviceManager.shared.APP_CLIENT_ID, secret: WebserviceManager.shared.APP_CLIENT_SECRET)
        let heimdall = Heimdallr(tokenURL: tokenURL, credentials: useCredentials)

        let parameters: [String : String] = ["refresh_token" : refreshToken as! String]
        print("access token before", UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "")
        heimdall.requestAccessToken(grantType: "refresh_token", parameters: parameters) { result in

            switch result {
            case .success:
           //     print("success")
                
                if let refreshToken = heimdall.accessToken?.refreshToken {
                    UserDefaults.standard.set(refreshToken, forKey: Constant.UD_refreshToken)
                }
                
                if heimdall.hasAccessToken {
                    if let accessToken = heimdall.accessToken?.accessToken {
                        print("checkValidToken Token", accessToken)
                        UserDefaults.standard.set(accessToken, forKey: Constant.UD_userToken)
                        UserDefaults.standard.synchronize()
                        
                        //access token for today extension
                        if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {
                            userDefaults.set(accessToken as AnyObject, forKey: "accessToken")
                            userDefaults.synchronize()
                        }
                        print("access token after", UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "")
                        callBack(true)
                    }
                }
                
            case .failure(let error):
                SharedManager.shared.logAPIError(url: "requestAccessToken", error: error.localizedDescription, code: "")
                print("failure: \(error.localizedDescription)")
                print("access token failed", UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "")
                callBack(false)
            }
        }
    }
    
    //MARK:- Webservice with JSON BODY version
    // you can pass api version in params at the time of reques
    class func URLResponseJSONRequest(_ url: String, method: HTTPMethod, parameters: [String: Any]?, headers: String?, withSuccess success: @escaping apiSuccess, withAPIFailure failure: @escaping apiFailure) {
        
        let completeUrl : String = WebserviceManager.shared.API_BASE + url
        //print(completeUrl)
        
        var headersToken = HTTPHeaders()
        if let token = headers {
            
            headersToken = [
                "Authorization": "Bearer \(token)"
            ]
         //   print("Header token is : ",headersToken)
        }
    
        headersToken["x-app-platform"] = "ios"
        headersToken["x-app-version"] = Bundle.main.releaseVersionNumberPretty
        headersToken["api-version"] = WebserviceManager.shared.API_VERSION

        if ((UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "") as? String ?? "").isEmpty {
            headersToken["x-user-language"] = Locale.current.languageCode ?? "en"
        }


        AF.request(completeUrl, method: method, parameters: parameters, encoding: JSONEncoding.default, headers:headersToken).validate(statusCode: 200..<600).responseData(completionHandler: { response in
                        
            switch response.result {
                
            case .success(let value):
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if response.response?.statusCode == 401 {
                    
                 //   print("status code...", response.response?.statusCode ?? 0)
                    checkValidToken { (status) in
                        
                        if status {
                            DispatchQueue.main.async {
                                var httpHeader: HTTPHeaders = [:]
                                if ((UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "") as? String ?? "").isEmpty {
                                    httpHeader = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                                                               "x-app-platform": "ios",
                                                               "x-app-version": Bundle.main.releaseVersionNumberPretty,
                                                                   "x-user-language" : Locale.current.languageCode ?? "en",
                                                               "api-version": WebserviceManager.shared.API_VERSION]
                                } else {
                                    httpHeader = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                                                               "x-app-platform": "ios",
                                                               "x-app-version": Bundle.main.releaseVersionNumberPretty,
                                                               "api-version": WebserviceManager.shared.API_VERSION]
                                }
                                
                                print("token updated successfully....call again")

                                
                         //       print("new token is : ",headersToken)
                                
                                //print(completeUrl)
                                AF.request(completeUrl, method: method, parameters: parameters, encoding: URLEncoding.default, headers: httpHeader).validate(statusCode: 200..<600).responseData(completionHandler: { response in
                                                
                                    switch response.result {
                                        
                                    case .success(let value):
                                        
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        if response.response?.statusCode == 423 {
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                print("Logout")
                                                appDelegate.logout()
                                            }
                                        }
                                        else {
                                            success(value)
                                        }
                                        
                                    case .failure(let error):
                                        SharedManager.shared.logAPIError(url: url, error: error.localizedDescription, code: "\(response.response?.statusCode ?? 0)")
                                        failure(error.localizedDescription)
                                    }
                                })
                            }
                        }
                        else {
                            failure("")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("Logout")
                                appDelegate.logout()
                            }
                        }
                    }
                    
                } else if response.response?.statusCode == 423 {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("Logout")
                        appDelegate.logout()
                    }

                }
//                else if response.response?.statusCode == 422 || response.response?.statusCode == 400 {
//
//                    failure(value)
//                }
                else if response.response?.statusCode == 412 {
                    
                    ANLoader.hide()
                    let vc = forceUpdateVC.instantiate(fromAppStoryboard: .registration)
                    (UIApplication.shared.delegate as? AppDelegate)?.navigationController.present(vc, animated: true, completion: nil)
                }
                else {
                    SharedManager.shared.logAPIError(url: url, error: "", code: "\(response.response?.statusCode ?? 0)")
                    success(value)
                }
                
            case .failure(let error):
                SharedManager.shared.logAPIError(url: url, error: error.localizedDescription, code: "\(response.response?.statusCode ?? 0)")
                failure(error.localizedDescription)
            }
        })
    }
    
    class func multiParamsULResponseMultipleImages(_ url:String, method: HTTPMethod ,parameters: [String: Any]?, headers: String?, ImageDic: [String:UIImage]?, withSuccess success: @escaping apiSuccess, withAPIFailure failure: @escaping apiFailure) {
        
        let completeUrl : String = WebserviceManager.shared.AUTH_BASE_URL + url
        //print(completeUrl)
        
        var headersToken = HTTPHeaders()
        if let token = headers {
            
            headersToken = [
                "Authorization": "Bearer \(token)"
            ]
            //print("Header token is : ",headersToken)
        }
    
        headersToken["x-app-platform"] = "ios"
        headersToken["x-app-version"] = Bundle.main.releaseVersionNumberPretty
        headersToken["api-version"] = WebserviceManager.shared.API_VERSION

        if ((UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "") as? String ?? "").isEmpty {
            headersToken["x-user-language"] = Locale.current.languageCode ?? "en"
        }

        AF.upload(multipartFormData: { (multipartFormData) in
          
            if let params = parameters {
                
                for (key, value) in params {
                    if let arrayItems = value as? [String] {
                        for item in arrayItems {
                            multipartFormData.append((item as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                        }
                    } else {
                        multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
                }
            }
            
            if let ImageDic = ImageDic {
                    
                for item in ImageDic {
                    
                    let imageData = (item.value).jpegData(compressionQuality: 0.5)
                    multipartFormData.append(imageData ?? Data(), withName: item.key, fileName: "\(item.key).jpg", mimeType: "image/jpeg")
                    
                }
            }
        }, to: URL.init(string: completeUrl)!, method: method, headers: headersToken).response { response in
            switch response.result {
            
            case .success(let value):
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if response.response?.statusCode == 401 {
                    
                    print("status code...", response.response?.statusCode ?? 0)
                    checkValidToken { (status) in
                        
                        if status {
                            DispatchQueue.main.async {
                                
                                print("token updated successfully....call again")
                                var httpHeader: HTTPHeaders = [:]
                                if ((UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "") as? String ?? "").isEmpty {
                                    httpHeader = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                                                               "x-app-platform": "ios",
                                                               "x-app-version": Bundle.main.releaseVersionNumberPretty,
                                                                   "x-user-language" : Locale.current.languageCode ?? "en",
                                                               "api-version": WebserviceManager.shared.API_VERSION]
                                } else {
                                    httpHeader = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                                                               "x-app-platform": "ios",
                                                               "x-app-version": Bundle.main.releaseVersionNumberPretty,
                                                               "api-version": WebserviceManager.shared.API_VERSION]
                                }

                                print("new token is : ",headersToken)
                                
                                //print(completeUrl)
                                AF.request(completeUrl, method: method, parameters: parameters, encoding: URLEncoding.default, headers: httpHeader).validate(statusCode: 200..<600).responseData(completionHandler: { response in
                                    
                                    switch response.result {
                                    
                                    case .success(let value):
                                        
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        if response.response?.statusCode == 423 {
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                print("Logout")
                                                appDelegate.logout()
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
                        }
                        else {
                            failure("")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("Logout")
                                appDelegate.logout()
                            }
                        }
                    }
                    
                } else if response.response?.statusCode == 423 {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("Logout")
                        appDelegate.logout()
                    }
                    
                }
                else if response.response?.statusCode == 412 {
                    
                    let vc = forceUpdateVC.instantiate(fromAppStoryboard: .registration)
                    (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }
                else if (response.response?.statusCode ?? 0) < 300 {
                    SharedManager.shared.logAPIError(url: url, error: "", code: "\(response.response?.statusCode ?? 0)")
                    success(value ?? Data())
                }
                
            case .failure(let error):
                SharedManager.shared.logAPIError(url: url, error: error.localizedDescription, code: "\(response.response?.statusCode ?? 0)")
                failure(error.localizedDescription)
            }
        }
    }
    
    class func URLRequestBodyParams(_ url:String, method: HTTPMethod ,parameters: [String: Any]?, headers: String?, ImageDic: [String:UIImage], withSuccess success: @escaping apiSuccess, withAPIFailure failure: @escaping apiFailure) {
        
        let completeUrl : String = WebserviceManager.shared.API_BASE + url
        //print(completeUrl)
        
        var headersToken = HTTPHeaders()
        if let token = headers {
            
            headersToken = [
                "Authorization": "Bearer \(token)"
            ]
            //print("Header token is : ",headersToken)
        }
    
        headersToken["x-app-platform"] = "ios"
        headersToken["x-app-version"] = Bundle.main.releaseVersionNumberPretty
        headersToken["api-version"] = WebserviceManager.shared.API_VERSION
        if ((UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "") as? String ?? "").isEmpty {
            headersToken["x-user-language"] = Locale.current.languageCode ?? "en"
        }

        AF.upload(multipartFormData: { (multipartFormData) in
          
            if let params = parameters{
                
                for (key, value) in params {
                    if let arrayItems = value as? [String] {
                        for item in arrayItems {
                            multipartFormData.append((item as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                        }
                    } else {
                        multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
                }
            }
            
            for item in ImageDic {
                
                let imageData = (item.value).jpegData(compressionQuality: 0.5)
                multipartFormData.append(imageData ?? Data(), withName: item.key, fileName: "\(item.key).jpg", mimeType: "image/jpeg")
            }
            
        }, to: URL.init(string: completeUrl)!, method: method, headers: headersToken).response { response in
            switch response.result {
            
            case .success(let value):
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if response.response?.statusCode == 401 {
                    
                    print("status code...", response.response?.statusCode ?? 0)
                    checkValidToken { (status) in
                        
                        if status {
                            DispatchQueue.main.async {
                                
                                print("token updated successfully....call again")
                                var httpHeader: HTTPHeaders = [:]
                                if ((UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "") as? String ?? "").isEmpty {
                                    httpHeader = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                                                               "x-app-platform": "ios",
                                                               "x-app-version": Bundle.main.releaseVersionNumberPretty,
                                                                   "x-user-language" : Locale.current.languageCode ?? "en",
                                                               "api-version": WebserviceManager.shared.API_VERSION]
                                } else {
                                    httpHeader = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                                                               "x-app-platform": "ios",
                                                               "x-app-version": Bundle.main.releaseVersionNumberPretty,
                                                               "api-version": WebserviceManager.shared.API_VERSION]
                                }

                                print("new token is : ",headersToken)
                                
                                //print(completeUrl)
                                AF.request(completeUrl, method: method, parameters: parameters, encoding: URLEncoding.default, headers: httpHeader).validate(statusCode: 200..<600).responseData(completionHandler: { response in
                                    
                                    switch response.result {
                                    
                                    case .success(let value):
                                        
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        if response.response?.statusCode == 423 {
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                print("Logout")
                                                appDelegate.logout()
                                            }
                                        }
                                        else {
                                            success(value)
                                        }
                                        
                                    case .failure(let error):
                                        SharedManager.shared.logAPIError(url: url, error: error.localizedDescription, code: "\(response.response?.statusCode ?? 0)")
                                        failure(error.localizedDescription)
                                    }
                                })
                            }
                        }
                        else {
                            failure("")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("Logout")
                                appDelegate.logout()
                            }
                        }
                    }
                    
                } else if response.response?.statusCode == 423 {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("Logout")
                        appDelegate.logout()
                    }
                    
                }
                else if response.response?.statusCode == 412 {
                    
                    let vc = forceUpdateVC.instantiate(fromAppStoryboard: .registration)
                    (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }
                else {
                    SharedManager.shared.logAPIError(url: url, error: "", code: "\(response.response?.statusCode ?? 0)")
                    success(value ?? Data())
                }
                
            case .failure(let error):
                SharedManager.shared.logAPIError(url: url, error: error.localizedDescription, code: "\(response.response?.statusCode ?? 0)")
                failure(error.localizedDescription)
            }
        }
    }
    
    //Upload VIdeo Article
    class func requestedURLUploadVideo(_ url:String, method: HTTPMethod, parameters: [String: Any]?, headers: String?, withSuccess success: @escaping apiSuccess, withAPIFailure failure: @escaping apiFailure) {
        
        let completeUrl : String = WebserviceManager.shared.API_BASE + url
        //print(completeUrl)
        
        var headersToken = HTTPHeaders()
        if let token = headers {
            
            headersToken = [
                "Authorization": "Bearer \(token)"
            ]
            //print("Header token is : ",headersToken)
        }
    
        headersToken["x-app-platform"] = "ios"
        headersToken["x-app-version"] = Bundle.main.releaseVersionNumberPretty
        headersToken["api-version"] = WebserviceManager.shared.API_VERSION

        if ((UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "") as? String ?? "").isEmpty {
            headersToken["x-user-language"] = Locale.current.languageCode ?? "en"
        }

        DispatchQueue.main.async {
            
            AF.upload(multipartFormData: { (multipartFormData) in
                
                if let params = parameters {
                    
                    for item in params {
                        
                        if let url = URL(string:item.value as! String) {
                            
                            do {
                                let videoData = try Data(contentsOf: url)
                                multipartFormData.append(videoData, withName: item.key, fileName: "video.mp4", mimeType: "video/mp4")
                            } catch {
                                debugPrint("Couldn't get Data from URL: \(url): \(error)")
                            }
                        }
                    }
                }
                
            }, to: URL(string: completeUrl)!, usingThreshold: UInt64.init(), method: method, headers: headersToken, fileManager: FileManager.default)
            
            .uploadProgress { progress in // main queue by default
                print("Upload Progress: \(progress.fractionCompleted)")
                print("Upload Estimated Time Remaining: \(String(describing: progress.estimatedTimeRemaining))")
                print("Upload Total Unit count: \(progress.totalUnitCount)")
                print("Upload Completed Unit Count: \(progress.completedUnitCount)")
            }
            
            .responseJSON { (response) in
                
                //print("Parameters: \(self.parameters.description)")   // original url request
                //print("Response: \(String(describing: response.response))") // http url response
                //print("Result: \(response.result)")                         // response serialization result
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("String Data: \(utf8Text)") // original server data as UTF8 string
                    success(data)
                }
                else {
                    SharedManager.shared.logAPIError(url: url, error: response.error?.localizedDescription ?? "", code: "\(response.response?.statusCode ?? 0)")
                    failure(response.error?.localizedDescription ?? "")
                }

            }
        }
    }
    
    class func multiParamsULResponseMultipleImages(_ url:String, method: HTTPMethod ,parameters: [String: Any]?, headers: String?, ImageArray: [UIImage], withSuccess success: @escaping apiSuccess, withAPIFailure failure: @escaping apiFailure) {
        
        let completeUrl : String = WebserviceManager.shared.API_BASE + url
        //print(completeUrl)
        
        var headersToken = HTTPHeaders()
        if let token = headers {
            
            headersToken = [
                "Authorization": "Bearer \(token)"
            ]
         //   print("Header token is : ",headersToken)
        }
    
        headersToken["x-app-platform"] = "ios"
        headersToken["x-app-version"] = Bundle.main.releaseVersionNumberPretty
        headersToken["api-version"] = WebserviceManager.shared.API_VERSION

        if ((UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "") as? String ?? "").isEmpty {
            headersToken["x-user-language"] = Locale.current.languageCode ?? "en"
        }

        AF.upload(multipartFormData: { (multipartFormData) in
          
            if let params = parameters {
                
                for (key, value) in params {
                    if let arrayItems = value as? [String] {
                        for item in arrayItems {
                            multipartFormData.append((item as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                        }
                    } else {
                        multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
                }
            }
            for item in ImageArray {
                
                let imageData = item.jpegData(compressionQuality: 0.5)
                multipartFormData.append(imageData ?? Data(), withName: "file", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
            }
            
            print(multipartFormData)
        }, to: URL.init(string: completeUrl)!, method: method, headers: headersToken).response { response in
            switch response.result {
            
            case .success(let value):
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if response.response?.statusCode == 401 {
                    
                    print("status code...", response.response?.statusCode ?? 0)
                    checkValidToken { (status) in
                        
                        if status {
                            DispatchQueue.main.async {
                                
                                print("token updated successfully....call again")
                                var httpHeader: HTTPHeaders = [:]
                                if ((UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "") as? String ?? "").isEmpty {
                                    httpHeader = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                                                               "x-app-platform": "ios",
                                                               "x-app-version": Bundle.main.releaseVersionNumberPretty,
                                                                   "x-user-language" : Locale.current.languageCode ?? "en",
                                                               "api-version": WebserviceManager.shared.API_VERSION]
                                } else {
                                    httpHeader = ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? "")",
                                                               "x-app-platform": "ios",
                                                               "x-app-version": Bundle.main.releaseVersionNumberPretty,
                                                               "api-version": WebserviceManager.shared.API_VERSION]
                                }

                                print("new token is : ",headersToken)
                                
                                //print(completeUrl)
                                AF.request(completeUrl, method: method, parameters: parameters, encoding: URLEncoding.default, headers: httpHeader).validate(statusCode: 200..<600).responseData(completionHandler: { response in
                                    
                                    switch response.result {
                                    
                                    case .success(let value):
                                        
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        if response.response?.statusCode == 423 {
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                print("Logout")
                                                appDelegate.logout()
                                            }
                                        }
                                        else {
                                            success(value)
                                        }
                                        
                                    case .failure(let error):
                                        SharedManager.shared.logAPIError(url: url, error: error.localizedDescription, code: "\(response.response?.statusCode ?? 0)")
                                        failure(error.localizedDescription)
                                    }
                                })
                            }
                        }
                        else {
                            failure("")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("Logout")
                                appDelegate.logout()
                            }
                        }
                    }
                    
                } else if response.response?.statusCode == 423 {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("Logout")
                        appDelegate.logout()
                    }
                    
                }
                else if response.response?.statusCode == 412 {
                    
                    let vc = forceUpdateVC.instantiate(fromAppStoryboard: .registration)
                    (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }
                else {
                    SharedManager.shared.logAPIError(url: url, error: response.error?.localizedDescription ?? "", code: "\(response.response?.statusCode ?? 0)")
                    success(value ?? Data())
                }
                
            case .failure(let error):
                SharedManager.shared.logAPIError(url: url, error: error.localizedDescription, code: "\(response.response?.statusCode ?? 0)")
                failure(error.localizedDescription)
            }
        }
    }
}


extension Alamofire.Session {
    @discardableResult
    open func requestWithoutCache(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)// also you can add URLRequest.CachePolicy here as parameter
        -> DataRequest {
        
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            urlRequest.cachePolicy = .reloadIgnoringCacheData // <<== Cache disabled
            let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
            return request(encodedURLRequest)
        } catch {
            // TODO: find a better way to handle error
            print(error)
            return request(url)
        }
    }
}
