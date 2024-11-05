//
//  HomeVCViewModel.swift
//  Bullet
//
//  Created by Faris Muhammed on 12/12/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation
import UIKit
import DataCache
import SwiftUI

class HomeViewModel: NSObject {
    
    // API Callbacks
    var callbackGetFeedBackgroundTask: ((_ FULLResponse: feedInfoDC, _ lastModified: String, _ cacheId: String) -> ())?
    var callbackOpenTopics: ((_ response: Data, _ id: String, _ title: String, _ favorite: Bool, _ url: String) -> ())?
    var callbackSuggestMoreOrLess: ((_ response: Data?, _ query: String?, _ isMoreOrLess: Bool?, _ error: ApiErrorType?) -> ())?
    var callbackBlockSource: ((_ response: Data?, _ sourceName: String?, _ error: ApiErrorType?) -> ())?
    var callbackBlockUnblockAuthor: ((_ response: Data?, _ name: String?, _ query :String?,  _ error: ApiErrorType?) -> ())?
    var callbackUpdateUserTopicStatus: ((_ response: Data?, _ url: String?,  _ error: ApiErrorType?) -> ())?
    var callbackUpdateUserChannelStatus: ((_ response: Data?, _ error: ApiErrorType?) -> ())?
    var callbackFollowSource: ((_ response: Data?, _ name: String?,  _ error: ApiErrorType?) -> ())?
    var callbackUnFollowUserSource: ((_ response: Data?, _ name: String?,  _ error: ApiErrorType?) -> ())?
    var callbackUnblockSource: ((_ response: Data?, _ name: String?,  _ error: ApiErrorType?) -> ())?
    var callbackGoToSource: ((_ response: Data?, _ name: String?,  _ error: ApiErrorType?) -> ())?
    var callbackArticleArchive: ((_ response: Data?, _ isArchived: Bool?, _ id: String?, _ error: ApiErrorType?) -> ())?
    var callbackShare: ((_ response: Data?, _ article: articlesData?, _ error: ApiErrorType?, _ isOpenForNativeShare: Bool) -> ())?
    var callbackLikePost: ((_ response: Data?, _ article_id: String?, _ error: ApiErrorType?) -> ())?
    var callbackAuthorFollowUnfollow: ((_ response: Data?, _ url: String?, _ error: ApiErrorType?) -> ())?
    var callbackGetFeed: ((_ response: Data?, _ isReloadView: Bool?, _ newPost: Bool?, _ id: String?, _ error: ApiErrorType?) -> ())?
    
    //MARK: Get News feeds in background, update cache
    func performWSToGetFeedBackgroundTask(_ arrCache: [articlesData], lastModified: String, cacheId: String) {
        
        //let cacheId = SharedManager.shared.headlinesList[self.pageIndex].sub?[self.currentIndexSub].id ?? ""
        
        let params = ["context": cacheId,
                      "reader_mode": SharedManager.shared.readerMode,
                      "page": ""] as [String : Any]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/feeds", method: .get, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            
            
            do {
                
                let FULLResponse = try
                JSONDecoder().decode(feedInfoDC.self, from: response)
                self?.callbackGetFeedBackgroundTask?(FULLResponse, lastModified, cacheId)
                
            }
            catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
            
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToOpenTopics(id: String, title: String, favorite: Bool) {
        
        ANLoader.showLoading(disableUI: false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        let url = "news/topics/related/\(id)"
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { [weak self] (response) in
            
            ANLoader.hide()
            
            self?.callbackOpenTopics?(response, id, title, favorite, url)
            
        }) { (error) in
            
            //SharedManager.shared.showAPIFailureAlert()
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
   
    
    func performWSuggestMoreOrLess(_ id: String, isMoreOrLess: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            self.callbackSuggestMoreOrLess?(nil,nil,nil,ApiErrorType.internetError)
            return
        }
        
        let query = isMoreOrLess ? "news/articles/\(id)/suggest/more" : "news/articles/\(id)/suggest/less"
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(query, method: .post, parameters: nil, headers: token, withSuccess: { [weak self] (response) in
            
            self?.callbackSuggestMoreOrLess?(response, query, isMoreOrLess, nil)
            
        }) { (error) in
            print("error parsing json objects",error)
            self.callbackSuggestMoreOrLess?(nil,nil,nil,ApiErrorType.jsonError)
        }
    }
    
    
    
    func performBlockSource(_ id: String, sourceName: String) {
        
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockSource, eventDescription: "", source_id: id)
        
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            self.callbackBlockSource?(nil,nil,ApiErrorType.internetError)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        WebService.URLResponse("news/sources/block", method: .post, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            
            self?.callbackBlockSource?(response,sourceName,nil)
            
        }) { (error) in
            
            print("error parsing json objects",error)
            self.callbackBlockSource?(nil,nil,ApiErrorType.jsonError)
        }
    }
    
    func performWSToBlockUnblockAuthor(_ id: String, name: String, authorBlock: Bool) {
        
        
        if authorBlock == false {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockauthor, eventDescription: "", author_id: id)
        }
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            self.callbackBlockUnblockAuthor?(nil,nil,nil,ApiErrorType.internetError)
            return
        }
        ANLoader.showLoading(disableUI: false)
        
        let param = ["authors": id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let query = authorBlock ? "news/authors/unblock" : "news/authors/block"
        
        WebService.URLResponse(query, method: .post, parameters: param, headers: token, withSuccess: { [weak self] (response) in
            
            self?.callbackBlockUnblockAuthor?(response, name, query, nil)
            
        }) { (error) in
            
            ANLoader.hide()
            self.callbackBlockUnblockAuthor?(nil,nil,nil,ApiErrorType.jsonError)
            print("error parsing json objects",error)
        }
        
    }
    
    
    
    func performWSToUpdateUserTopicStatus(id: String, isFav: Bool) {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["topics":id]
        let url = isFav ? "news/topics/follow" : "news/topics/unfollow"
        
        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            
            self?.callbackUpdateUserTopicStatus?(response, url, nil)
            
        }) { (error) in
            self.callbackUpdateUserTopicStatus?(nil, nil, .jsonError)
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToUpdateUserChannelStatus(id: String, isFav: Bool) {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["sources":id]
        let url = isFav ? "news/sources/follow" : "news/sources/unfollow"
        
        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            
            self?.callbackUpdateUserChannelStatus?(response, nil)

        }) { (error) in
            
            self.callbackUpdateUserChannelStatus?(nil, .jsonError)
            print("error parsing json objects",error)
        }
    }
    
    func performWSToFollowSource(_ id: String, name:String) {
        
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.followSource, channel_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            self.callbackFollowSource?(nil, nil, .internetError)
            return
        }
        
        ANLoader.showLoading(disableUI: false)
        
        let params = ["sources": id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse("news/sources/follow", method: .post, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            
            ANLoader.hide()
            
            self?.callbackFollowSource?(response, name, nil)

        }) { (error) in
            
            ANLoader.hide()
            self.callbackFollowSource?(nil, nil, .jsonError)
            print("error parsing json objects",error)
        }
    }
    
    
    func performUnFollowUserSource(_ id: String, name:String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedSource, channel_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            self.callbackUnFollowUserSource?(nil, nil, .internetError)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        
        ANLoader.showLoading(disableUI: false)
        WebService.URLResponse("news/sources/unfollow", method: .post, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            ANLoader.hide()
            
            self?.callbackUnFollowUserSource?(response, name, nil)
            
        }) { (error) in
            ANLoader.hide()
            self.callbackUnFollowUserSource?(nil, nil, .jsonError)
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToUnblockSource(_ id: String, name:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            self.callbackUnblockSource?(nil, nil, .internetError)
            return
        }
        ANLoader.showLoading(disableUI: false)
        
        let param = ["sources":id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/unblock", method: .post, parameters:param , headers: token, withSuccess: { [weak self] (response) in
            
            self?.callbackUnblockSource?(response, name, nil)
            
        }) { (error) in
            
            ANLoader.hide()
            self.callbackUnblockSource?(nil, nil, .jsonError)
            print("error parsing json objects",error)
        }
        
    }
    
    
    func performGoToSource(_ id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            self.callbackGoToSource?(nil, nil, .internetError)
            return
        }
        
        //let id = article.source?.id ?? ""
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/data/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { [weak self] (response) in
            
            
            self?.callbackGoToSource?(response, id, nil)
                        
        }) { (error) in
            
            self.callbackGoToSource?(nil, nil, .jsonError)
            print("error parsing json objects",error)
        }
    }
    
    
    func performArticleArchive(_ id: String, isArchived: Bool) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.archiveClick, eventDescription: "", article_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            self.callbackArticleArchive?(nil, nil, nil, .internetError)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["archive": isArchived]
        WebService.URLResponse("news/articles/\(id)/archive", method: .post, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            
            self?.callbackArticleArchive?(response, isArchived, id, nil)            
        }) { (error) in
            
            self.callbackArticleArchive?(nil, nil, nil, .jsonError)
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToShare(article: articlesData, isOpenForNativeShare: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            self.callbackShare?(nil, nil, .internetError, false)
            return
        }
        
        ANLoader.showLoading(disableUI: false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/articles/\(article.id ?? "")/share/info", method: .get, parameters: nil, headers: token, withSuccess: { [weak self] (response) in
            
            ANLoader.hide()
            
            self?.callbackShare?(response, article, nil, isOpenForNativeShare)
            
        }) { (error) in
            ANLoader.hide()
            self.callbackShare?(nil, nil, .jsonError, false)
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToLikePost(article_id: String, isLike: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            self.callbackLikePost?(nil, nil, .internetError)
            return
        }
        
        let params = ["like": isLike]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        WebService.URLResponseJSONRequest("social/likes/article/\(article_id)", method: .post, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            
            self?.callbackLikePost?(response, article_id, nil)

        }) { (error) in
            self.callbackLikePost?(nil, nil, .jsonError)
            print("error parsing json objects",error)
        }

    }
    
    
    func performWSToAuthorFollowUnfollow(id: String, isFav: Bool) {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["authors":id]
        let url = isFav ? "news/authors/follow" : "news/authors/unfollow"

        if !(SharedManager.shared.isConnectedToNetwork()){
            self.callbackAuthorFollowUnfollow?(nil, nil, .internetError)
            return
        }
        
        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { [weak self] (response) in
            
            self?.callbackAuthorFollowUnfollow?(response, url, nil)

        }) { (error) in
            
            self.callbackAuthorFollowUnfollow?(nil, nil, .jsonError)
            print("error parsing json objects",error)
        }
    }
    
    
    
    func performWSToGetFeed(isReloadView: Bool = false, newPost: Bool = false, id: String, nextPaginate: String) {
        
        let params = ["context": id,
                      "reader_mode": SharedManager.shared.readerMode,
                      "page": nextPaginate] as [String : Any]
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            self.callbackGetFeed?(nil, nil, nil, nil, .internetError)
            return
        }
        
        
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/feeds", method: .get, parameters: params, headers: token, withSuccess: { (response) in
            
            self.callbackGetFeed?(response, isReloadView, newPost, id, nil)
            
        }) { (error) in
            
            self.callbackGetFeed?(nil, nil, nil, nil, .jsonError)
        }
    }
    
    
    
}
