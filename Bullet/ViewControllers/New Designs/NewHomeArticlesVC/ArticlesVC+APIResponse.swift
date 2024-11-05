//
//  ArticlesVC+APIResponse.swift
//  Bullet
//
//  Created by Faris Muhammed on 17/05/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import Foundation
import UIKit
import DataCache

extension ArticlesVC {
    
    
    func callToGetNewsFeed(isReloadView: Bool = false, newPost: Bool = false) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            DispatchQueue.main.async {
                SharedManager.shared.isTabReload = true
                self.tblExtendedView.es.stopPullToRefresh()
                SharedManager.shared.hideLaoderFromWindow()
                SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
                return
            }
        }
        
        //Reload View when user comes from App Background
        if isReloadView {
            
            focussedIndexPath = 0
            nextPaginate = ""
            prefetchState = .fetching
        }
        
        let id = self.getCategoryId(isReloadView: isReloadView)
        
        if !isPullToRefresh && self.nextPaginate.isEmpty {
            
            DispatchQueue.main.async {
                if self.articles.count == 0 {
                    self.showLoader()
                }
            }
        } else {
            DispatchQueue.main.async {
                if self.showSkeletonLoader {
                    self.hideCircularLoader()
                    self.showSkeletonLoader = false
                    self.tblExtendedView.reloadData()
                    self.delegate?.loaderShowing(status: false)
                }
            }
        }
        
//        self.delegate?.loaderShowing(status: true)
        
        if fromDiscover || isOpenFromAricleTopic {
            //get the TopicsDetails with reels
            let contextID = isOpenFromAricleTopic ? id : self.contextID ?? ""
            self.homeViewModel.performWSToGetTopicDetailsWithReels(id: contextID, nextPaginate: nextPaginate)
        }
        else{
            self.homeViewModel.performWSToGetFeed(id: id, nextPaginate: nextPaginate)
        }
    }
    
    func getAPIResponseCallbacks() {
        
        self.homeViewModel = ArticlesViewModel()
        
        self.homeViewModel.callbackGetFeedBackgroundTask = { [weak self] (FULLResponse, lastModified, cacheId) in
            self?.feedBackgroundTaskResponseRecieved(FULLResponse: FULLResponse, lastModified: lastModified, cacheId: cacheId)
        }
        
        self.homeViewModel.callbackOpenTopics = { [weak self] (response, id, title, favorite, url) in
            self?.performWSToOpenTopicsResponseRecieved(response: response, id: id, title: title, favorite: favorite, url: url)
        }
        
        
        self.homeViewModel.callbackSuggestMoreOrLess = { [weak self] (response, query, isMoreOrLess, error) in
            
            guard let self = self else { return }
            
            if checkAPIErrorStatus(error: error) { return }
            
            if response != nil {
                self.performWSuggestMoreOrLessResponseRecieved(response: response!, query: query ?? "", isMoreOrLess: isMoreOrLess ?? false)
            }
        }
        
        
        self.homeViewModel.callbackBlockSource = { [weak self] (response, sourceName, error) in
            
            guard let self = self else { return }
            if checkAPIErrorStatus(error: error) { return }
            
            if response != nil {
                self.performBlockSourceResponseRecieved(response: response!, sourceName: sourceName ?? "")
            }
            
        }
        
        self.homeViewModel.callbackBlockUnblockAuthor = { [weak self] (response, name, query, error) in
            
            guard let self = self else { return }
            if checkAPIErrorStatus(error: error) { return }
         
            if response != nil {
                self.performWSToBlockUnblockAuthorResponseRecieved(response: response!, name: name ?? "", query: query ?? "")
            }
            
        }
        
        
        self.homeViewModel.callbackUpdateUserTopicStatus = { [weak self] (response, url, error) in
            
            guard let self = self else { return }
            if checkAPIErrorStatus(error: error) { return }
            
            if response != nil {
                self.performWSToUpdateUserTopicStatusResponseRecieved(response: response!, url: url ?? "")
            }
            
        }
        
        
        self.homeViewModel.callbackUpdateUserChannelStatus = { [weak self] (response, error) in
            
            guard let self = self else { return }
            if checkAPIErrorStatus(error: error) { return }
            
            if response != nil {
                self.performWSToUpdateUserChannelStatusResponseRecieved(response: response!)
            }
            
        }
        
        
        self.homeViewModel.callbackFollowSource = { [weak self] (response, name, error) in
            
            guard let self = self else { return }
            if checkAPIErrorStatus(error: error) { return }
            
            if response != nil {
                self.performWSToFollowSourceResponseRecieved(response: response!, name: name ?? "")
            }
            
        }
        
     
        self.homeViewModel.callbackUnFollowUserSource = { [weak self] (response, name, error) in
           
            guard let self = self else { return }
            if checkAPIErrorStatus(error: error) { return }
            
            if response != nil {
                
                self.performUnFollowUserSourceResponseRecieved(response: response!, name: name ?? "")
                
            }

        }
        
        
        self.homeViewModel.callbackUnblockSource = { [weak self] (response, name, error) in
            
            guard let self = self else { return }
            if checkAPIErrorStatus(error: error) { return }
            
            if response != nil {
                
                self.performWSToUnblockSourceResponseRecieved(response: response!, name: name ?? "")
                
            }
            
        }
        
        
        self.homeViewModel.callbackGoToSource = { [weak self] (response, id, error) in
            
            guard let self = self else { return }
            if checkAPIErrorStatus(error: error) { return }
            
            if response != nil {
                
                self.performGoToSourceResponseRecieved(response: response!, id: id ?? "")
                
            }
            
        }
        
       
        self.homeViewModel.callbackArticleArchive = { [weak self] (response, isArchived, id, error) in
            
            guard let self = self else { return }
            if checkAPIErrorStatus(error: error) { return }
            
            if response != nil {
                
                self.performArticleArchiveResponseRecieved(response: response!, isArchived: isArchived ?? false, id: id ?? "")
                
            }
            
        }
        
        
        self.homeViewModel.callbackShare = { [weak self] (response, article, error,isOpenForNativeShare) in
            
            guard let self = self else { return }
            if checkAPIErrorStatus(error: error) { return }
            
            if response != nil {
                
                self.performWSToShareResponseRecieved(response: response!, article: article!, isOpenForNativeShare: isOpenForNativeShare)
                
            }
            
        }
        
        self.homeViewModel.callbackLikePost = { [weak self] (response, article_id, error) in
            
            guard let self = self else { return }
            
            self.isLikeApiRunning = false
            
            if checkAPIErrorStatus(error: error) { return }
            
            if response != nil {
                
                self.performWSToLikePostResponseRecieved(response: response!, article_id: article_id ?? "")

            }
            
        }
        
        self.homeViewModel.callbackAuthorFollowUnfollow = { [weak self] (response, url, error) in
            
            
            guard let self = self else { return }
            if checkAPIErrorStatus(error: error) { return }
            
            if response != nil {
                
                self.performWSToAuthorFollowUnfollowResponseRecieved(response: response!, url: url ?? "")
                
            }
            
        }
        
        self.homeViewModel.callbackGetFeed = { [weak self] (response, isReloadView, newPost, id, error) in
            
//            self?.delegate?.loaderShowing(status: false)
            guard let self = self else { return }
            
            self.isLikeApiRunning = false
            
            if checkAPIErrorStatus(error: error, isErrorPopUpNeeded: false) {
                return
            }
            
            if response != nil {
                
                self.performWSToGetFeedResponseRecieved(response: response!, isReloadView: isReloadView ?? false, newPost: newPost ?? false, id: id ?? "")
                
            }
            
            
        }
        
        self.homeViewModel.callbackGetCategories = { [weak self] (response, error) in
            
//            self?.delegate?.loaderShowing(status: false)
            guard let self = self else { return }
            
            self.isLikeApiRunning = false
            
            if checkAPIErrorStatus(error: error, isErrorPopUpNeeded: false) {
                return
            }
            
            if response != nil {
                
                self.performWSToGetCategoriesResponseRecieved(response: response!, url: "")
                
            }
            
            
        }
        
        self.homeViewModel.callbackRefreshCategories = { [weak self] (response, error) in
            
//            self?.delegate?.loaderShowing(status: false)
            guard let self = self else { return }
            
            self.isLikeApiRunning = false
            
            if checkAPIErrorStatus(error: error, isErrorPopUpNeeded: false) {
                return
            }
            
            if response != nil {
                
                self.refreshCategoriesResponseRecieved(response: response!, url: "")
                
            }
            
            
        }
        
        
        
        func checkAPIErrorStatus(error: ApiErrorType?, isErrorPopUpNeeded: Bool = true) -> Bool {
            
            if error != nil {
                if error == .internetError {
                    if isErrorPopUpNeeded {
                        SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
                    }
                }
                
                
                if error == .jsonError {
                    
                }
                
                return true
            }
            return false
            
        }
        
    }
    
    
}
    
    
    
    
extension ArticlesVC {
    
    // MARK: Handle responses recived from API
    func feedBackgroundTaskResponseRecieved(FULLResponse: feedInfoDC, lastModified: String, cacheId: String) {
        
        if !self.isDataLoaded && self.isViewPresenting {
            
            self.isDataLoaded = true
//            if SharedManager.shared.curCategoryIndex == self.pageIndex {
//                self.isDataLoaded = true
//            }
        }
        
        
        DispatchQueue.main.async {
            
            if self.isViewPresenting == false {
                return
            }
            
            let paginationMeta = { () in
                
                //assign string for pagination
                if let meta = FULLResponse.meta {
                    
                    self.nextPaginate = meta.next ?? ""
                    
                    if self.isOnFollowing {
                        SharedManager.shared.lastModifiedTimeArticlesFollowing = SharedManager.shared.lastModifiedTimeFeeds
                    }
                    else {
                        SharedManager.shared.lastModifiedTimeArticlesForYou = SharedManager.shared.lastModifiedTimeFeeds
                    }
                    
                }
            }
            
            if let arrData = FULLResponse.sections {
                
                if SharedManager.shared.lastModifiedTimeFeeds != lastModified || SharedManager.shared.lastModifiedTimeFeeds == "" {
                    
                    UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                        
                        self.viewNewPosts.isHidden = false
                        
                    }, completion: {_ in
                        self.tempCategoryId = cacheId
                        self.tempArticlesArr = arrData
                    })
                }
            }
            
            //call pagination
            paginationMeta()
            
        }
        
    }
    
    func performWSToOpenTopicsResponseRecieved(response: Data, id: String, title: String, favorite: Bool, url: String) {
        
        do {
            let FULLResponse = try
            JSONDecoder().decode(SubTopicDC.self, from: response)
            
            DispatchQueue.main.async {
                
                if let topics = FULLResponse.topics {
                    
                    SharedManager.shared.subTopicsList = topics
                    //                        SharedManager.shared.articleSearchModeType = ""
                    
                    let vc = ArticlesVC.instantiate(fromAppStoryboard: .Main)
                    vc.showArticleType = .topic
                    vc.selectedID = id
                    vc.isFav = favorite
                    vc.subTopicTitle = title
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        } catch let jsonerror {
            
            SharedManager.shared.showAPIFailureAlert()
            print("error parsing json objects",jsonerror)
            SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
        }
        
        
    }
    
    
    func performWSuggestMoreOrLessResponseRecieved(response: Data, query: String, isMoreOrLess: Bool) {
        
        do{
            let FULLResponse = try
            JSONDecoder().decode(messageData.self, from: response)
            
            if let status = FULLResponse.message?.uppercased() {
                
                self.updateProgressbarStatus(isPause: false)
                if status == Constant.STATUS_SUCCESS {
                    
                    if isMoreOrLess {
                        
                        SharedManager.shared.showAlertLoader(message: "You'll see more stories like this", type: .alert)
                    }
                    else {
                        
                        SharedManager.shared.showAlertLoader(message: "You'll see less stories like this", type: .alert)
                    }
                }
                else {
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                }
            }
            
        } catch let jsonerror {
            print("error parsing json objects",jsonerror)
            SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
            
        }
        
    }
    
    
    func performBlockSourceResponseRecieved(response: Data, sourceName: String) {
        
        do{
            let FULLResponse = try
            JSONDecoder().decode(BlockTopicDC.self, from: response)
            
            if let status = FULLResponse.message?.uppercased() {
                
                self.updateProgressbarStatus(isPause: false)
                if status == Constant.STATUS_SUCCESS {
                    
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    SharedManager.shared.showAlertLoader(message: "Blocked \(sourceName)", type: .alert)
                }
                else {
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                }
            }
            
        } catch let jsonerror {
            
            print("error parsing json objects",jsonerror)
            SharedManager.shared.logAPIError(url: "news/sources/block", error: jsonerror.localizedDescription, code: "")
            
        }
        
    }
    
    
    func performWSToBlockUnblockAuthorResponseRecieved(response: Data, name: String, query :String) {
        
        do{
            
            let FULLResponse = try
            JSONDecoder().decode(DeleteSourceDC.self, from: response)
            
            self.updateProgressbarStatus(isPause: false)
            if FULLResponse.message == "Success" {
                
                if self.sourceBlock {
                    SharedManager.shared.showAlertLoader(message: "Unblocked \(name)", type: .alert)
                }
                else {
                    SharedManager.shared.showAlertLoader(message: "Blocked \(name)", type: .alert)
                }
                
            }
            else {
                
                SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
            }
            ANLoader.hide()
        } catch let jsonerror {
            
            ANLoader.hide()
            print("error parsing json objects",jsonerror)
            SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
        }
        
    }
    
    
    func performWSToUpdateUserTopicStatusResponseRecieved(response: Data, url: String) {
        
        do{
            let FULLResponse = try
            JSONDecoder().decode(updateTopicDC.self, from: response)
            
            if FULLResponse.message == "Success" {
                SharedManager.shared.isTabReload = true
                SharedManager.shared.isDiscoverTabReload = true
            } else {
            }
            
        } catch let jsonerror {
            
            SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
            print("error parsing json objects",jsonerror)
        }
        
    }
    
    
    func performWSToUpdateUserChannelStatusResponseRecieved(response: Data) {
        
    }
    
    
    func performWSToFollowSourceResponseRecieved(response: Data, name: String) {
        
        do{
            let FULLResponse = try
            JSONDecoder().decode(updateSourceDC.self, from: response)
            
            SharedManager.shared.isTabReload = true
            SharedManager.shared.isDiscoverTabReload = true
            SharedManager.shared.isFav = true
            NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
            self.updateProgressbarStatus(isPause: false)
            if FULLResponse.message == "Success" {
                
                SharedManager.shared.showAlertLoader(message: "Followed \(name)", type: .alert)
            }
            
        } catch let jsonerror {
            
            print("error parsing json objects",jsonerror)
            SharedManager.shared.logAPIError(url: "news/sources/follow", error: jsonerror.localizedDescription, code: "")
        }
        
    }
    
    func performUnFollowUserSourceResponseRecieved(response: Data, name: String) {
        
        do{
            let FULLResponse = try
            JSONDecoder().decode(DeleteSourceDC.self, from: response)
            
            if let status = FULLResponse.message?.uppercased() {
                
                self.updateProgressbarStatus(isPause: false)
                if status == Constant.STATUS_SUCCESS {
                    
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    SharedManager.shared.isFav = false
                    NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
                    SharedManager.shared.showAlertLoader(message: "Unfollowed \(name)", type: .alert)
                }
                else {
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                }
            }
            
        } catch let jsonerror {
            
            print("error parsing json objects",jsonerror)
            SharedManager.shared.logAPIError(url: "news/sources/unfollow", error: jsonerror.localizedDescription, code: "")
        }
        
    }
    
    
    func performWSToUnblockSourceResponseRecieved(response: Data, name: String) {
    
        do{
            
            let FULLResponse = try
            JSONDecoder().decode(DeleteSourceDC.self, from: response)
            
            self.updateProgressbarStatus(isPause: false)
            if FULLResponse.message == "Success" {
                
                SharedManager.shared.showAlertLoader(message: "Unblocked \(name)", type: .alert)
            }
            else {
                
                SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
            }
            ANLoader.hide()
        } catch let jsonerror {
            
            ANLoader.hide()
            print("error parsing json objects",jsonerror)
            SharedManager.shared.logAPIError(url: "news/sources/unblock", error: jsonerror.localizedDescription, code: "")
        }
        
    }
    
    
    func performGoToSourceResponseRecieved(response: Data, id: String) {
        
        do{
            let FULLResponse = try
            JSONDecoder().decode(ChannelListDC.self, from: response)
            
            DispatchQueue.main.async {
                
                if let Info = FULLResponse.channel {
                    
                    SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.feedSourceOpen, channel_id: id)
                    
                    
                    if let ptcTBC = self.tabBarController as? PTCardTabBarController {
                        ptcTBC.showTabBar(false, animated: true)
                    }
                    
                    let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
                    detailsVC.channelInfo = Info
                    //detailsVC.delegateVC = self
                    //detailsVC.isOpenFromDiscoverCustomListVC = true
                    detailsVC.modalPresentationStyle = .fullScreen
                    let nav = AppNavigationController(rootViewController: detailsVC)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                }
                else {
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: NSLocalizedString("Related Sources not available", comment: ""))
                }
            }
            
        } catch let jsonerror {
            
            print("error parsing json objects",jsonerror)
            SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
        }
    }
    
    
    func performArticleArchiveResponseRecieved(response: Data, isArchived: Bool, id: String) {
        
        do{
            let FULLResponse = try
            JSONDecoder().decode(messageDC.self, from: response)
            
            if let status = FULLResponse.message?.uppercased() {
                
                if status == Constant.STATUS_SUCCESS {
                    
                    self.updateProgressbarStatus(isPause: false)
                    SharedManager.shared.showAlertLoader(message: isArchived ? ApplicationAlertMessages.kMsgAddToFavorite : ApplicationAlertMessages.kMsRemoveFromFavorite, type: .alert)
                }
                else {
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                }
            }
            
        } catch let jsonerror {
            
            print("error parsing json objects",jsonerror)
            SharedManager.shared.logAPIError(url: "news/articles/\(id)/archive", error: jsonerror.localizedDescription, code: "")
        }
        
    }
    
    
    func performWSToShareResponseRecieved(response: Data, article: articlesData, isOpenForNativeShare: Bool) {
        
        do{
            let FULLResponse = try
            JSONDecoder().decode(ShareSheetDC.self, from: response)
            
            DispatchQueue.main.async {
                
                SharedManager.shared.instaMediaUrl = ""
                self.authorBlock = FULLResponse.author_blocked ?? false
                self.sourceBlock = FULLResponse.source_blocked ?? false
                self.sourceFollow = FULLResponse.source_followed ?? false
                self.article_archived = FULLResponse.article_archived ?? false
                
                self.urlOfImageToShare = URL(string: article.link ?? "")
                self.shareTitle = FULLResponse.share_message ?? ""
                if let media = FULLResponse.download_link {
                    
                    SharedManager.shared.instaMediaUrl = media
                }
                
                self.updateProgressbarStatus(isPause: true)
                
                if isOpenForNativeShare {
                    self.openDefaultShareSheet(shareTitle: self.shareTitle)
                }
                else {
                    let vc = BottomSheetVC.instantiate(fromAppStoryboard: .registration)
                    vc.isMainScreen = true
                    if let _ = article.source { /* If article source */ }
                    else {
                        //If article author data
                        vc.isMainScreen = false
                        vc.isOtherAuthorArticleMenu = true
                        if article.authors?.first?.id == SharedManager.shared.userId {
                            vc.isSameAuthor = true
                        }
                    }
                    
                    vc.showArticleType = .home
                    vc.delegateBottomSheet = self
                    vc.article = article
                    vc.sourceBlock = self.sourceBlock
                    vc.sourceFollow = self.sourceFollow
                    vc.article_archived = self.article_archived
                    vc.share_message = FULLResponse.share_message ?? ""
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true, completion: nil)
                }
                
                
                
            }
            
        } catch let jsonerror {
            
            print("error parsing json objects",jsonerror)
            SharedManager.shared.logAPIError(url: "news/articles/\(article.id ?? "")/share/info", error: jsonerror.localizedDescription, code: "")
        }
        
    }
    
    
    func performWSToLikePostResponseRecieved(response: Data, article_id: String) {
        
        do{
            let FULLResponse = try
                JSONDecoder().decode(messageData.self, from: response)
            
            if let status = FULLResponse.message?.uppercased() {
                
                print("like status", status)
//                    if status == Constant.STATUS_SUCCESS_LIKE {
//                        print("Successfull")
//                    }
//                    else {
////                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
//                    }
            }
            
        } catch let jsonerror {
            self.isLikeApiRunning = false
            print("error parsing json objects",jsonerror)
            SharedManager.shared.logAPIError(url: "social/likes/article/\(article_id)", error: jsonerror.localizedDescription, code: "")
        }
        
    }
    
    
    
    func performWSToAuthorFollowUnfollowResponseRecieved(response: Data, url: String) {
        
        do{
            let _ = try
                JSONDecoder().decode(messageDC.self, from: response)
            
            
        } catch let jsonerror {
            
            SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
            print("error parsing json objects",jsonerror)
        }
        
    }
    
    func refreshCategoriesResponseRecieved(response: Data, url: String) {
        
        do{
            let FULLResponse = try
                JSONDecoder().decode(subCategoriesDC.self, from: response)
            
            if let homeData = FULLResponse.data {
                
                var refeshNeeded = true
                for latestCat in homeData {
                    if SharedManager.shared.articlesCategories.contains(where: { $0.id == latestCat.id }) == false {
                        refeshNeeded = true
                        break
                    }
                }
                
                if refeshNeeded {
                    //write Cache Codable types object
                    do {
                        try DataCache.instance.write(codable: homeData, forKey: Constant.CACHE_ARTICLES_CATEGORIES)
                    } catch {
                        print("Write error \(error.localizedDescription)")
                    }

                    SharedManager.shared.articlesCategories = homeData
                    if SharedManager.shared.articlesCategories.contains(where: { $0.id == SharedManager.shared.curArticlesCategoryId }) == false {
                        loadNewData()
                    }
                    else if SharedManager.shared.curArticlesCategoryId == "" {
                        SharedManager.shared.curArticlesCategoryId = SharedManager.shared.articlesCategories.first?.id ?? ""
                    }
                    
                    self.setupNavView()
                    self.getRefreshArticlesData(startFromFirstPosition: true)
                }
                
                
            }
            
            
        }
        catch let jsonerror {
            
            self.hideCircularLoader()
            
            SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
            print("error parsing json objects",jsonerror)
        }
        
        
    }
    
    
    func performWSToGetCategoriesResponseRecieved(response: Data, url: String) {
        
        do{
            let FULLResponse = try
                JSONDecoder().decode(subCategoriesDC.self, from: response)
            
            //Don't remove this line...its on hold
           // SharedManager.shared.force = FULLResponse.force ?? false
            self.hideCircularLoader()
            
            if let homeData = FULLResponse.data {
                
                
                //write Cache Codable types object
                do {
                    try DataCache.instance.write(codable: homeData, forKey: Constant.CACHE_ARTICLES_CATEGORIES)
                } catch {
                    print("Write error \(error.localizedDescription)")
                }

                SharedManager.shared.articlesCategories = homeData
                if SharedManager.shared.curArticlesCategoryId == "" {
                    SharedManager.shared.curArticlesCategoryId = SharedManager.shared.articlesCategories.first?.id ?? ""
                }
                
                self.setupNavView()
                self.getRefreshArticlesData(startFromFirstPosition: true)
            }
            
            
        }
        catch let jsonerror {
            
            self.hideCircularLoader()
            
            SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
            print("error parsing json objects",jsonerror)
        }
        
        
    }
    
    
    func performWSToGetFeedResponseRecieved(response: Data, isReloadView: Bool, newPost: Bool, id: String) {
        
        //self.updateTableViewUserInteractionEnabled(true)
        SharedManager.shared.hideLaoderFromWindow()
        if !self.isDataLoaded && self.isViewPresenting {
            
//            if SharedManager.shared.curCategoryIndex == self.pageIndex {
//                self.isDataLoaded = true
//            }
            self.isDataLoaded = true
        }
        
        do {
            
            let FULLResponse = try
                JSONDecoder().decode(feedInfoDC.self, from: response)
            
            DispatchQueue.main.async {
                
                if self.isViewPresenting == false {
                    
                    
                    self.tblExtendedView.es.stopPullToRefresh()
                    if self.showArticleType == .topic {
                        
                        //                        if self.pageIndex < SharedManager.shared.subTopicsList.count {
                        //                            self.nextPaginate = SharedManager.shared.subTopicsList[self.pageIndex].pagination ?? ""
                        //                        }
                    }
                    
                    else if self.showArticleType == .places {
                        
                    }
                    else {
                        
                    }
                    return
                }
                
                
                self.prefetchState = .idle
                if self.nextPaginate == "" {
                    self.articles.removeAll()
                }
                
                let paginationMeta = { () in
                    
                    //assign string for pagination
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        
                        self.tblExtendedView.es.stopPullToRefresh()
                        
                        if let meta = FULLResponse.meta {
                            
                            self.nextPaginate = meta.next ?? ""
                            
                            if self.isOnFollowing {
                                SharedManager.shared.lastModifiedTimeArticlesFollowing = SharedManager.shared.lastModifiedTimeFeeds
                            }
                            else {
                                SharedManager.shared.lastModifiedTimeArticlesForYou = SharedManager.shared.lastModifiedTimeFeeds
                            }
                            
                            /*
                             if self.showArticleType == .topic {
                             
                             }
                             else if self.showArticleType == .places {
                             
                             }
                             else {
                             
                             }*/
                        }
                        
                    }
                }
                
                //Reload View when user comes from App Background
                if isReloadView {
                    
                    self.viewNoData.isHidden = true
                    
                }
                else {
                    
                    //Load Data
                    if let arrData = FULLResponse.sections, arrData.count > 0 {
                        print("first item API \(arrData.first?.type ?? "")")
                        self.loadDataInFeedList(arrData, id: id, isNewPost: newPost)
                    }
                    
                    //call pagination
                    paginationMeta()
                    
                    if self.nextPaginate == "" && !self.isPullToRefresh {
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                        
                        
                        if (self.articles.count > 0) {
                            
                            self.startArticleCaching()
                            
                            self.isOpenedFollowingPrefernce = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.isLoadingMoreData = false
                                if self.isLastCellVisible() {
                                    self.reloadNextPage()
                                }
                                
                            }
                            self.viewNoData.isHidden = true
                            self.viewEmptyMessage.isHidden = true
                            self.tblExtendedView.isHidden = false
                        } else {
                            //                        self.viewNoData.isHidden = false
                            //                        self.tblExtendedView.isHidden = true
                            
                            DispatchQueue.main.async {
                                if self.showSkeletonLoader {
                                    self.hideCircularLoader()
                                    self.showSkeletonLoader = false
                                    self.tblExtendedView.reloadData()
                                    self.delegate?.loaderShowing(status: false)
                                }
                                
                                self.updateProgressbarStatus(isPause: true)
                                
                                //Check whether 'Following' category is empty
                                /*
                                 if let type = FULLResponse.sections?.first?.type, type.uppercased() == "FOLLOWING" {
                                 self.viewEmptyMessage.isHidden = false
                                 }
                                 else {
                                 self.viewNoData.isHidden = false
                                 }
                                 */
                                if self.isOpenedFollowingPrefernce {
                                    self.delegate?.switchBackToForYou()
                                    self.isOpenedFollowingPrefernce = false
                                }
                                else {
                                    self.openFollowingPrefernce()
                                }
                                
                                self.tblExtendedView.reloadData()
                                
                                if self.articles.count == 0 {
                                    self.viewNoData.isHidden = false
                                    self.tblExtendedView.isHidden = true
                                }
                            }
                        }
                        
                        //Get notification which is launched app
                        //                        self.hideLoader()
                        if SharedManager.shared.isAppLaunchedThroughNotification {
                            
                            SharedManager.shared.isAppLaunchedThroughNotification = false
                            NotificationCenter.default.post(name:   Notification.Name.notifyGetPushNotificationArticleData, object: nil, userInfo: nil)
                        }
                    }
                }
                self.pagingLoader.stopAnimating()
                self.pagingLoader.hidesWhenStopped = true
            }
            
            
        } catch let jsonerror {
            
            self.handleFeedAPIError(error: jsonerror.localizedDescription)
        }
        
    }
    
    func handleFeedAPIError(error: String) {
        
        DispatchQueue.main.async {
            SharedManager.shared.hideLaoderFromWindow()
            if self.showSkeletonLoader {
                self.hideCircularLoader()
                self.showSkeletonLoader = false
                self.delegate?.loaderShowing(status: false)
            }
            self.tblExtendedView.reloadData()
            
            self.pagingLoader.stopAnimating()
            self.pagingLoader.hidesWhenStopped = true
        }
        self.isDataLoaded = false
        self.prefetchState = .idle
        self.isPullToRefresh = false
        SharedManager.shared.isTabReload = true
        SharedManager.shared.isDiscoverTabReload = true
//                self.refreshControlExtended.endRefreshing()
        SharedManager.shared.showAPIFailureAlert()
        print("error parsing json objects",error)
        SharedManager.shared.logAPIError(url: "news/feeds", error: error, code: "")
        
    }
    
}
