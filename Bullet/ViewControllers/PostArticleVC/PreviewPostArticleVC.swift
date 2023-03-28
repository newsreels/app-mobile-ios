//
//  PreviewPostArticleVC.swift
//  Bullet
//
//  Created by Mahesh on 10/05/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import LinkPresentation
import TagListView
import Photos
import FBSDKShareKit


class PreviewPostArticleVC: UIViewController {

    //PROPERTIES
    @IBOutlet weak var viewNav: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var viewLine: UIView!
    @IBOutlet weak var viewPost: UIView!
    @IBOutlet weak var tblExtendedView: UITableView!
    
    @IBOutlet weak var viewUserBG: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var viewTagBG: UIView!
    @IBOutlet weak var lblAddTag: UILabel!
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var lblPreview: UILabel!
    @IBOutlet weak var imgAddTag: UIImageView!
    
    
    @IBOutlet var viewCollection: [UIView]!
    @IBOutlet weak var viewSelectedTagBG: UIView!
    @IBOutlet weak var viewTagList: TagListView!
    @IBOutlet weak var lblTags: UILabel!
    @IBOutlet weak var imgTag: UIImageView!
    
    @IBOutlet var imgRightArrowColl: [UIImageView]!
    
    //place
    @IBOutlet weak var viewPlace: UIView!
    @IBOutlet weak var lblAddPlace: UILabel!
    @IBOutlet weak var imgAddPlace: UIImageView!
    
    //selected places
    @IBOutlet weak var viewSelectedPlaceBG: UIView!
    @IBOutlet weak var viewPlaceList: TagListView!
    @IBOutlet weak var lblPlace: UILabel!
    @IBOutlet weak var imgPlace: UIImageView!

    //location
    @IBOutlet weak var viewLanguage: UIView!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var imgLanguage: UIImageView!

    //VARIABLES
    var articles: [articlesData] = []
    var postArticleType = PostArticleType.media
//    var selectedMediaType: mediaType!
    var fName = ""
    var lName = ""
    var scheduleDate = ""
    var thumbnailImage: UIImage?

    //sharing variables
    var urlOfImageToShare: URL?
    var shareTitle = ""
    var sourceBlock = false
    var sourceFollow = false
    var article_archived = false

    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var pageIndex = 0
    var isDirectionFindingNeeded = false
    var isLikeApiRunning = false
    
    weak var delegateBulletDetails: BulletDetailsVCLikeDelegate?

    var paramsFromPostArticle = [String: Any]()
    var queryFromPostArticle = ""
    var articleIDFromPostArticle = ""
    var selectedChannelFromPost: ChannelInfo?
    
    var uploadingFileTaskID = ""
    
    var mediaWatermark = MediaWatermark()
    var DocController: UIDocumentInteractionController = UIDocumentInteractionController()
    @IBOutlet weak var indicator: InstagramActivityIndicator!
    @IBOutlet weak var viewIndicator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SET LOCALIZABLE
        setLocalizableString()
        setDesignView()

        //register cardcell for storyboard use
        self.tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_SCHEDULE_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_SCHEDULE_CARD)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_SCHEDULE_REEL, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_SCHEDULE_REEL)
        self.tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_SCHEDULE_YOUTUBE, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_SCHEDULE_YOUTUBE)
        self.tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_SCHEDULE_VIDEO, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_SCHEDULE_VIDEO)
        self.tblExtendedView.rowHeight = UITableView.automaticDimension
        self.tblExtendedView.estimatedRowHeight = 700
        self.tblExtendedView.reloadData()
        
        indicator.animationDuration = 1.0
        indicator.rotationDuration = 3
        indicator.numSegments = 15
        indicator.strokeColor = "#E01335".hexStringToUIColor()
        indicator.lineWidth = 3
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.performWSToGetTagsList(articleId: self.articles.first?.id ?? "")
        self.performWSToGetPlacesList(articleId: self.articles.first?.id ?? "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.viewIndicator.isHidden = true
        }
        
    }
    
    func setDesignView() {
        
        //Design View
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        viewNav.theme_backgroundColor = GlobalPicker.viewHeaderTabColor
        viewUserBG.theme_backgroundColor = GlobalPicker.viewHeaderTabColor
        viewTagBG.theme_backgroundColor = GlobalPicker.viewHeaderTabColor
        imgTag.theme_image = GlobalPicker.imgPostTopic
        viewLine.backgroundColor = MyThemes.current == .dark ? "#2B2A2F".hexStringToUIColor() : "#E7E9EC".hexStringToUIColor()
        viewCollection.forEach { view in
            view.theme_backgroundColor = GlobalPicker.viewBGPostArticleColor
            //view.backgroundColor = MyThemes.current == .dark ? "#090909".hexStringToUIColor() : UIColor.white
        }

        imgBack.theme_image = GlobalPicker.imgBack
        lblTitle.theme_textColor = GlobalPicker.textColor
        lblPreview.theme_textColor = GlobalPicker.textColor
        lblName.theme_textColor = GlobalPicker.textColor
        viewPost.theme_backgroundColor = GlobalPicker.themeCommonColor
        imgAddTag.theme_image = GlobalPicker.imgPostTopic

        [viewTagList, viewPlaceList].forEach { view in
            view?.textColor = MyThemes.current == .dark ? "#FFFFFF".hexStringToUIColor() : "#3D485F".hexStringToUIColor()
            view?.tagBackgroundColor = MyThemes.current == .dark ? "#404040".hexStringToUIColor() : "#F1F1F1".hexStringToUIColor()
            view?.textFont = UIFont(name: Constant.FONT_Mulli_Semibold, size: 14) ?? UIFont.systemFont(ofSize: 14)
        }

        viewTagBG.isHidden = false
        viewSelectedTagBG.isHidden = true
        viewSelectedPlaceBG.isHidden = true

        imgUser.cornerRadius = imgUser.frame.height / 2
        imgUser.contentMode = .scaleAspectFill

        //place
        viewPlace.theme_backgroundColor = GlobalPicker.viewHeaderTabColor
        imgPlace.theme_image = GlobalPicker.imgPostPlace
        imgAddPlace.theme_image = GlobalPicker.imgPostPlace

        //language
        viewLanguage.theme_backgroundColor = GlobalPicker.viewHeaderTabColor
        imgLanguage.theme_image = GlobalPicker.imgPostLanguage
        
        
        if selectedChannelFromPost != nil {
            fName = selectedChannelFromPost?.name ?? ""
            lName = ""
            
            imgUser.sd_setImage(with: URL(string: selectedChannelFromPost?.icon ?? ""), placeholderImage: nil)
        } else {
            if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {
                
                let profile = user.profile_image ?? ""
                fName = (user.first_name ?? "")
                lName = (user.last_name ?? "")

                if profile.isEmpty {
                    imgUser.theme_image = GlobalPicker.imgUserPlaceholder
                }
                else {
                    imgUser.sd_setImage(with: URL(string: profile), placeholderImage: nil)
                }
            }
            else {
                
                imgUser.theme_image = GlobalPicker.imgUserPlaceholder
            }
        }
    }
    
    //Set String for Language Translation and Put it in String Files
    func setLocalizableString() {
        
        //LOCALIZABLE STRING
        if postArticleType == .reel {
            
            //newsreels
            lblTitle.text = NSLocalizedString("Newsreels", comment: "")
        }
        else {
            
            //media
            lblTitle.text = NSLocalizedString("Post article", comment: "")
        }

        lblTags.text = NSLocalizedString("Topics", comment: "") + ":"
        lblAddTag.text = NSLocalizedString("Topics", comment: "")
        lblPreview.text = NSLocalizedString("Preview", comment: "")
        lblPost.text = NSLocalizedString("POST", comment: "")
        lblPost.addTextSpacing(spacing: 2.0)
        
        lblAddPlace.text = NSLocalizedString("Places", comment: "")
        lblLanguage.text = NSLocalizedString("Language", comment: "")

        //get language
        if let languages = SharedManager.shared.loadJsonLanguages(filename: "languages") {
                
            if let lang = languages.first(where: { $0.code == UserDefaults.standard.string(forKey: Constant.UD_languageSelected) }) {
                lblLanguage.text = "\(NSLocalizedString("Language", comment: "")): \(lang.name ?? "")"
            }
        }
        
        if selectedChannelFromPost != nil {
            lblName.text = "\(NSLocalizedString("Post to", comment: "")) \(selectedChannelFromPost?.name ?? "")"
        } else {
            lblName.text = NSLocalizedString("Post to My Profile", comment: "")
        }
        
        //places
        lblPlace.text = NSLocalizedString("Places", comment: "") + ":"
    }
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapBackButton(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapPostAction(_ sender: UIButton) {
        
        if self.postArticleType == .reel {
            
            UploadManager.shared.updatePostUploadStatus(articleID: self.articleIDFromPostArticle, updateUserStatus: .posted)
            UploadManager.shared.checkCroppingItemsAndUpload()
            
//            SharedManager.shared.showAlertLoader(message: NSLocalizedString(self.scheduleDate.isEmpty ? "Article published successfully" : "Article scheduled successfully", comment: ""), type: .alert)
            self.navigationController?.popToRootViewController(animated: true)
            
        } else if postArticleType == .media {
            
            if self.articles.first?.type  == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                
                UploadManager.shared.updatePostUploadStatus(articleID: self.articleIDFromPostArticle, updateUserStatus: .posted)
                UploadManager.shared.checkCroppingItemsAndUpload()
                
//                SharedManager.shared.showAlertLoader(message: NSLocalizedString(self.scheduleDate.isEmpty ? "Article published successfully" : "Article scheduled successfully", comment: ""), type: .alert)
                self.navigationController?.popToRootViewController(animated: true)
                
            }
            else if self.articles.first?.type  == Constant.newsArticle.ARTICLE_TYPE_IMAGE {
                
                self.performWSToArticlePublished()
                
            }
        } else if postArticleType == .youtube {
            
            self.performWSToArticlePublished()
        }
    }

    @IBAction func didTapAddTag(_ sender: Any) {
        
        let vc = AddTagVC.instantiate(fromAppStoryboard: .Schedule)
        vc.article = articles.first
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapPostToProfile(_ sender: Any) {
        
        let vc = ProfileSelectionVC.instantiate(fromAppStoryboard: .Schedule)
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapAddPlaces(_ sender: Any) {
        
        let vc = AddPlacesVC.instantiate(fromAppStoryboard: .Schedule)
        vc.article = articles.first
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapAddLanguage(_ sender: Any) {
        
        let vc = AppLanguageVC.instantiate(fromAppStoryboard: .Onboarding)
        vc.delegateVC = self
        vc.isFromPostArticle = true
        vc.article = articles.first
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PreviewPostArticleVC: AppLanguageVCDelegate {
    
    func setLanguageForArticle(langName: String) {
        
        lblLanguage.text = "\(NSLocalizedString("Language", comment: "")): \(langName)"
    }
}

//MARK:- Webservices -  Private func
extension PreviewPostArticleVC {
    
    func performWSToGetTagsList(articleId: String) {

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let apiUrl : String = "studio/\(articleId)/tags"
        WebService.URLResponse(apiUrl, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(TagsDC.self, from: response)
                
                if let tagsList = FULLResponse.tags {
                              
                    self.viewTagList.removeAllTags()
                    if tagsList.count > 0 {
                        for tag in tagsList {
                           
                            self.viewTagList.addTag(tag.name ?? "")
                        }
                        
                        self.viewTagBG.isHidden = true
                        self.viewSelectedTagBG.isHidden = false
                    }
                    else {
                        
                        self.viewTagBG.isHidden = false
                        self.viewSelectedTagBG.isHidden = true
                    }
                }
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: apiUrl, error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetPlacesList(articleId: String) {

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let apiUrl : String = "studio/\(articleId)/locations"
        WebService.URLResponse(apiUrl, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                if let list = FULLResponse.locations {
                              
                    self.viewPlaceList.removeAllTags()
                    if list.count > 0 {
                        for ls in list {
                           
                            self.viewPlaceList.addTag(ls.name ?? "")
                        }
                        
                        self.viewPlace.isHidden = true
                        self.viewSelectedPlaceBG.isHidden = false
                    }
                    else {
                        
                        self.viewPlace.isHidden = false
                        self.viewSelectedPlaceBG.isHidden = true
                    }
                }
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: apiUrl, error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUpdateArticle(channelID: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
//        ANLoader.showLoading()
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        paramsFromPostArticle["source"] = channelID
        paramsFromPostArticle["id"] = articleIDFromPostArticle
        
        WebService.URLResponseJSONRequest(queryFromPostArticle, method: .post, parameters: paramsFromPostArticle, headers: token) { (response) in
            
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(postArticlesDC.self, from: response)
                
                ANLoader.hide()
                
                if let msg = FULLResponse.message {
                    
//                    SharedManager.shared.showAlertLoader(message: msg, duration: 3.0, position: .bottom)
                }
                else {
//                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Article updated successfully.", comment: ""), duration: 3.0, position: .bottom)
                }
                

            } catch let jsonerror {
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: self.queryFromPostArticle, error: jsonerror.localizedDescription, code: "")
            }
            
        } withAPIFailure: { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToArticlePublished() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading()
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let id = self.articles.first?.id ?? ""
        let params = ["status": "PUBLISHED"]
        
        WebService.URLResponse("studio/articles/\(id)/status", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                
                UploadManager.shared.updatePostUploadStatus(articleID: self.articleIDFromPostArticle, updateUserStatus: .posted)
                UploadManager.shared.checkCroppingItemsAndUpload()
                
                SharedManager.shared.showAlertLoader(message: NSLocalizedString(self.scheduleDate.isEmpty ? "Article published successfully" : "Article scheduled successfully", comment: ""), type: .alert)
                self.navigationController?.popToRootViewController(animated: true)
                                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "studio/articles/id/status", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSuggestMoreOrLess(_ id: String, isMoreOrLess: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let query = isMoreOrLess ? "news/articles/\(id)/suggest/more" : "news/articles/\(id)/suggest/less"
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(query, method: .post, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
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
        }) { (error) in
            print("error parsing json objects",error)
        }
    }
    
    func performBlockSource(_ id: String, sourceName: String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockSource, eventDescription: "", source_id: id)

        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        WebService.URLResponse("news/sources/block", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(BlockTopicDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    if status == Constant.STATUS_SUCCESS {
                        
                        SharedManager.shared.isTabReload = true
                        SharedManager.shared.isDiscoverTabReload = true
                        SharedManager.shared.showAlertLoader(message: "Blocked \(sourceName)")
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/block", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToBlockUnblockAuthor(_ id: String, name: String) {
        
        
        if self.sourceBlock == false {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockauthor, eventDescription: "", author_id: id)
        }
        
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        ANLoader.showLoading(disableUI: true)
        
        let param = ["authors": id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let query = sourceBlock ? "news/authors/unblock" : "news/authors/block"
        
        WebService.URLResponse(query, method: .post, parameters: param, headers: token, withSuccess: { (response) in
            
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                //self.updateProgressbarStatus(isPause: false)
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
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToFollowSource(_ id: String, name:String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.followSource, channel_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: false)
        
        let params = ["sources": id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse("news/sources/follow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateSourceDC.self, from: response)
                
                
                SharedManager.shared.isFav = true
                NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
                if FULLResponse.message == "Success" {
                    
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    SharedManager.shared.showAlertLoader(message: "Followed \(name)", type: .alert)
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/follow", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performUnFollowUserSource(_ id: String, name:String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedSource, channel_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        
        ANLoader.showLoading(disableUI: true)
        WebService.URLResponse("news/sources/unfollow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
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
            
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUnblockSource(_ id: String, name:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        ANLoader.showLoading(disableUI: true)
        
        let param = ["sources":id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/unblock", method: .post, parameters:param , headers: token, withSuccess: { (response) in
            
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
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
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performGoToSource(_ article: articlesData) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let id = article.source?.id ?? ""
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/data/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let Info = FULLResponse.channel {
                                                
                        let detailsVC = ProfilePageViewController.instantiate(fromAppStoryboard: .Schedule)
                        //detailsVC.channelInfo = Info
                        //detailsVC.delegateVC = self
                        //detailsVC.isOpenFromDiscoverCustomListVC = true
                        detailsVC.modalPresentationStyle = .fullScreen
                        self.navigationController?.pushViewController(detailsVC, animated: true)
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: "Related Sources not available")
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToShare(article: articlesData) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/articles/\(article.id ?? "")/share/info", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ShareSheetDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    SharedManager.shared.instaMediaUrl = ""
                    self.sourceBlock = FULLResponse.source_blocked ?? false
                    self.sourceFollow = FULLResponse.source_followed ?? false
                    self.article_archived = FULLResponse.article_archived ?? false
                    
                    self.urlOfImageToShare = URL(string: article.link ?? "")
                    self.shareTitle = FULLResponse.share_message ?? ""
                    if let media = FULLResponse.download_link {
                        
                        SharedManager.shared.instaMediaUrl = media
                    }
                                        
                    let vc = BottomSheetVC.instantiate(fromAppStoryboard: .registration)
                    
                    vc.isMainScreen = true
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
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/articles/\(article.id ?? "")/share/info", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    
    public func presentationControllerDidDismiss( _ presentationController: UIPresentationController) {
        
        //print("dismiss")
    }
    
}

//MARK:- BottomSheetVC Delegate methods
extension PreviewPostArticleVC: BottomSheetVCDelegate, SharingDelegate, UIDocumentInteractionControllerDelegate  {
    
    func didTapUpdateAudioAndProgressStatus() {
        
        
    }
    
    func didTapDissmisReportContent() {
        
        SharedManager.shared.showAlertLoader(message: "Report concern sent successfully.")
    }
    
    func didTapBottomShareSheetAction(sender: UIButton, article: articlesData) {
        
        if sender.tag == 1 {
            
            //Save article
            
        }
        else if sender.tag == 2 {
            
         //   self.updateProgressbarStatus(isPause: true)
            let vc = CustomShareVC.instantiate(fromAppStoryboard: .Reels)
            vc.modalPresentationStyle = .overFullScreen
            vc.shareText = shareTitle
            vc.isForArticles = true
            vc.shareArticle = article
            
            vc.dismissShareSheet = { [weak self] (resume) in
                if resume {
                    if SharedManager.shared.videoAutoPlay {
                        
                      //  self?.updateProgressbarStatus(isPause: false)
                    }
                }
            }
            
            vc.didTapSendVideoOnWhatsapp = { [weak self] (shareSheetType, sourceName, media) in
                
                if article.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                    
                    if !(SharedManager.shared.instaMediaUrl.isEmpty) || SharedManager.shared.instaMediaUrl != "" {
                        
                        self?.viewIndicator.isHidden = false
                        self?.indicator.isHidden = false
                        self?.indicator.startAnimating()
                        
                        self?.mediaWatermark.downloadVideo(video: SharedManager.shared.instaMediaUrl, saveToLibrary: true) { status in
                            
                            if status {
                                
                                let urlWhats = "whatsapp://app"
                                if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {

                                    DispatchQueue.main.async {

                                        self?.stopIndicatorLoading()

                                        if let whatsappURL = URL(string: urlString) {
                                            if UIApplication.shared.canOpenURL(whatsappURL) {

                                                self?.DocController = UIDocumentInteractionController(url: SharedManager.shared.videoUrlTesting!)
                                                self?.DocController.uti = "net.whatsapp.movie"
                                                self?.DocController.delegate = self
                                                self?.DocController.presentOpenInMenu(from: CGRect.zero, in: (self?.view)!, animated: true)

                                            } else {

                                                //     self?.playCurrentCellVideo()
                                                self?.stopIndicatorLoading()
                                            }
                                        }
                                    }
                                }
                            }
                            else {
                                
                                self?.stopIndicatorLoading()
                            }
                        }
                    }
                }
                else {
                    
                    let myView = Bundle.loadView(fromNib: "ImageCreation", withType: ImageCreation.self)
                    let image = myView.createImage(article: article)
                    
                    let urlWhats = "whatsapp://app"
                    if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                        if let whatsappURL = URL(string: urlString) {
                            if UIApplication.shared.canOpenURL(whatsappURL) {
                                
                                if let imageData = image.jpegData(compressionQuality: 1.0) {
                                    let tempFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                                    do {
                                        try imageData.write(to: tempFile, options: .atomic)
                                        
                                        DispatchQueue.main.async {
                                            
                                            self?.DocController = UIDocumentInteractionController(url: tempFile)
                                            self?.DocController.uti = "net.whatsapp.image"
                                            self?.DocController.delegate = self
                                            self?.DocController.presentOpenInMenu(from: CGRect.zero, in: (self?.view)!, animated: true)
                                            
                                        }
                                        
                                    } catch {
                                        print(error)
                                    }
                                }
                                
                            } else {
                            }
                        }
                    }
                }
            }
            
            vc.openFacebookForVideo = { [weak self] in
                
                
                if article.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                    
                    if !(SharedManager.shared.instaMediaUrl.isEmpty) || SharedManager.shared.instaMediaUrl != "" {
                        
                        self?.viewIndicator.isHidden = false
                        self?.indicator.isHidden = false
                        self?.indicator.startAnimating()
                        
                        
                        self?.mediaWatermark.downloadVideo(video: SharedManager.shared.instaMediaUrl, saveToLibrary: true) { status in
                            
                            if status {
                                
                                guard let schemaUrl = URL(string: "fb://") else {
                                    
                                    //   self?.playCurrentCellVideo()
                                    self?.stopIndicatorLoading()
                                    return //be safe
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    if UIApplication.shared.canOpenURL(schemaUrl) {
                                        
                                        let content: ShareVideoContent = ShareVideoContent()
                                        self?.createAssetURL(url: SharedManager.shared.videoUrlTesting!) { url in
                                            let video = ShareVideo()
                                            video.videoURL = URL(string: url)
                                            content.video = video
                                            
                                            let shareDialog = ShareDialog()
                                            shareDialog.shareContent = content
                                            shareDialog.mode = .native
                                            shareDialog.delegate = self
                                            shareDialog.show()
                                        }
                                        self?.stopIndicatorLoading()
                                    }else {
                                        
                                        //     self?.playCurrentCellVideo()
                                        self?.stopIndicatorLoading()
                                        print("app not installed")
                                    }
                                }
                            }
                            else {
                                
                                self?.stopIndicatorLoading()
                            }
                        }
                    }
                }
                else {
                    
                    guard let schemaUrl = URL(string: "fb://") else {
                        return //be safe
                    }
                    
                    DispatchQueue.main.async {
                        
                        if UIApplication.shared.canOpenURL(schemaUrl) {
                            
                            let myView = Bundle.loadView(fromNib: "ImageCreation", withType: ImageCreation.self)
                            let image = myView.createImage(article: article)
                            
                            let shareImage = SharePhoto()
                            shareImage.image = image
                            shareImage.isUserGenerated = true
                            
                            let content = SharePhotoContent()
                            content.photos = [shareImage]
                            
                            let sharedDialoge = ShareDialog()
                            sharedDialoge.shareContent = content
                            
                            sharedDialoge.fromViewController = self
                            sharedDialoge.mode = .automatic
                            
                            
                            if(sharedDialoge.canShow)
                            {
                                sharedDialoge.show()
                            }
                            else
                            {
                                print("Install Facebook client app to share image")
                            }
                            
                        }else {
                            
                            print("app not installed")
                        }
                    }
                }
            }
            
            vc.didTapShareOnInstaFeeds = { [weak self] in
                
                if article.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                    
                    if !(SharedManager.shared.instaMediaUrl.isEmpty) || SharedManager.shared.instaMediaUrl != "" {
                        
                        self?.viewIndicator.isHidden = false
                        self?.indicator.isHidden = false
                        self?.indicator.startAnimating()
                        
                        self?.mediaWatermark.downloadVideo(video: SharedManager.shared.instaMediaUrl, saveToLibrary: true) { status in
                            
                            if status {
                                
                                DispatchQueue.main.async {
                                    
                                    let url = URL(string: ("instagram://library?LocalIdentifier=" + SharedManager.shared.instaVideoLocalPath))
                                    
                                    if UIApplication.shared.canOpenURL(url!) {
                                        UIApplication.shared.open(url!, options: [:], completionHandler:nil)
                                    }
                                    self?.stopIndicatorLoading()
                                }
                            }
                            else {
                                
                                //      self?.playCurrentCellVideo()
                                self?.stopIndicatorLoading()
                            }
                        }
                    }
                }
                else {
                    
                    let myView = Bundle.loadView(fromNib: "ImageCreation", withType: ImageCreation.self)
                    let image = myView.createImage(article: article)
                    
                    self?.writeToPhotoAlbum(image: image)
                }
            }
            
            vc.didTapShareInInstaStories = { [weak self] in
                
                if article.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
                    
                    if !(SharedManager.shared.instaMediaUrl.isEmpty) || SharedManager.shared.instaMediaUrl != "" {
                        
                        self?.viewIndicator.isHidden = false
                        self?.indicator.isHidden = false
                        self?.indicator.startAnimating()
                        
                        
                        self?.mediaWatermark.downloadVideo(video: SharedManager.shared.instaMediaUrl, saveToLibrary: true) { status in
                        
                            if status {
                                
                                let url = URL(string: ("instagram://library?LocalIdentifier=" + SharedManager.shared.instaVideoLocalPath))
                                
                                DispatchQueue.main.async {
                                    
                                    if UIApplication.shared.canOpenURL(url!) {
                                        UIApplication.shared.open(url!, options: [:], completionHandler:nil)
                                    }
                                }
                                self?.stopIndicatorLoading()
                            }
                            else {
                                
                                //      self?.playCurrentCellVideo()
                                self?.stopIndicatorLoading()
                            }
                        }
                    }
                    
                }
                else {
                    
                    guard let instagramUrl = URL(string: "instagram-stories://share") else {
                        return
                    }
                    
                    let myView = Bundle.loadView(fromNib: "ImageCreation", withType: ImageCreation.self)
                    let image = myView.createImage(article: article)
                    
                    DispatchQueue.main.async {
                        
                        if UIApplication.shared.canOpenURL(instagramUrl) {
                            
                            let pasterboardItems = [["com.instagram.sharedSticker.backgroundImage": image as Any]]
                            UIPasteboard.general.setItems(pasterboardItems)
                            UIApplication.shared.open(instagramUrl)
                        } else {
                            // Instagram app is not installed or can't be opened, pop up an alert
                        }
                    }
                }
            }
            
            self.present(vc, animated: true, completion: nil)
        }
        else if sender.tag == 3 {
            
            //Go to Source
            self.performGoToSource(article)
            
        }
        else if sender.tag == 4 {
            
            //Follow Source
            if self.sourceFollow {
                
                self.performUnFollowUserSource(article.source?.id ?? "", name: article.source?.name ?? "")
            }
            else {
                
                self.performWSToFollowSource(article.source?.id ?? "", name: article.source?.name ?? "")
                
            }
        }
        else if sender.tag == 5 {
            
            //Block articles
            if let _ = article.source {
                /* If article source */
                if self.sourceBlock {
                    self.performWSToUnblockSource(article.source?.id ?? "", name: article.source?.name ?? "")
                }
                else {
                    self.performBlockSource(article.source?.id ?? "", sourceName: article.source?.name ?? "")
                }
            }
            else {
                //If article author data
                self.performWSToBlockUnblockAuthor(article.authors?.first?.id ?? "", name: article.authors?.first?.name ?? "")
            }
        }
        else if sender.tag == 6 {
            
            //Report content
            
        }
        else if sender.tag == 7 {
            
            //More like this
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.moreLikeThisClick, eventDescription: "")
            self.performWSuggestMoreOrLess(article.id ?? "", isMoreOrLess: true)
            
        }
        else if sender.tag == 8 {
            
            //I don't like this
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.lessLikeThisClick, eventDescription: "", article_id: article.id ?? "")
            self.performWSuggestMoreOrLess(article.id ?? "", isMoreOrLess: false)
        }
        
        else if sender.tag == 10 {
           
            // Copy
            // write to clipboard
            UIPasteboard.general.string = shareTitle
            SharedManager.shared.showAlertLoader(message: "Copied to clipboard successfully", type: .alert)
        }
        
    }
    
    func createAssetURL(url: URL, completion: @escaping (String) -> Void) {
        let photoLibrary = PHPhotoLibrary.shared()
        var videoAssetPlaceholder:PHObjectPlaceholder!
        photoLibrary.performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            videoAssetPlaceholder = request!.placeholderForCreatedAsset
        },
        completionHandler: { success, error in
            if success {
                let localID = NSString(string: videoAssetPlaceholder.localIdentifier)
                let assetID = localID.replacingOccurrences(of: "/.*", with: "", options: NSString.CompareOptions.regularExpression, range: NSRange())
                let ext = "mp4"
                let assetURLStr =
                    "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                
                completion(assetURLStr)
            }
        })
    }
    
    func stopIndicatorLoading() {
        
        if self.indicator.isAnimating {
            
            DispatchQueue.main.async {
                
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                self.viewIndicator.isHidden = true
            }
        }
    }
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("shared")
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("didFailWithError")

    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        print("sharerDidCancel")
    }
    
    func writeToPhotoAlbum(image: UIImage){
     
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if (error != nil) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgUnableToLoadImage)
            
        }
        else {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            if let lastAsset = fetchResult.firstObject {
                let localIdentifier = lastAsset.localIdentifier
                let u = "instagram://library?LocalIdentifier=" + localIdentifier
                let url = NSURL(string: u)!
                
                DispatchQueue.main.async {
                
                    if UIApplication.shared.canOpenURL(url as URL) {
                        UIApplication.shared.open(URL(string: u)!, options: [:], completionHandler: nil)
                    } else {
                        
                        let urlStr = "https://itunes.apple.com/in/app/instagram/id389801252?mt=8"
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                            
                        } else {
                            UIApplication.shared.openURL(URL(string: urlStr)!)
                        }
                    }
                }
            }
        }
    }
}

//MARK:- Cell Delegate methods
extension PreviewPostArticleVC: ScheduleCardCCDelegate, ScheduleYoutubeCCDelegate, ScheduleVideoCCDelegates {
    
    func didSelectCell(cell: ScheduleVideoCC) {
        
//        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
//            return
//        }
//
        
    }
    
    func resetSelectedArticle() {
        
    }
    
    func focusedIndex(index: Int) {
        
    }
    
    func autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: Bool) {
        
    }
    
    func seteMaxHeightForIndexPathHomeList(cell: UITableViewCell, maxHeight: CGFloat) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
//        SharedManager.shared.maxHeightForIndexPath[indexPath] = maxHeight
    }

    //ARTICLES SWIPE
    func layoutUpdate() {
        
        self.tblExtendedView.beginUpdates()
        self.tblExtendedView.endUpdates()
    }
    
    //<---
    // Public delegate methods for all cells are here
    func handleLongPressHold(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
    }
    //--->
}



//MARK:- TABLE VIEW DELEGATE
extension PreviewPostArticleVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let content = self.articles[indexPath.row]
        
        if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_VIDEO {

            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            let videoPlayer = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_SCHEDULE_VIDEO, for: indexPath) as! ScheduleVideoCC
         //   videoPlayer.delegateVideoView = self
            
            // Set like comment
            videoPlayer.setLikeComment(model: content.info)
            videoPlayer.delegate = self
//            videoPlayer.delegateLikeComment = self
            
            videoPlayer.selectionStyle = .none
            
            // videoPlayer.btnShare.tag = indexPath.row
            videoPlayer.btnSource.tag = indexPath.row
            videoPlayer.playButton.tag = indexPath.row
            
//            videoPlayer.btnShare.addTarget(self, action: #selector((button:)), for: .touchUpInside)
//            videoPlayer.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            
            let status = content.status ?? ""
            if status == Constant.newsArticle.ARTICLE_STATUS_SCHEDULED {
                
                if let pubDate = content.publish_time {
                    //videoPlayer.pubDate = pubDate
                    videoPlayer.lblAuthor.text = NSLocalizedString("Scheduled on:", comment: "") + "\n" + SharedManager.shared.utcToLocal(dateStr: pubDate)
                }
            }
            else {
                if let pubDate = content.publish_time {
                    //videoPlayer.pubDate = pubDate
                    videoPlayer.lblAuthor.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                }
            }

            videoPlayer.lblSource.text = (fName + " " + lName).trim()
            videoPlayer.imgWifi?.image = self.imgUser.image
            
            if let bullets = content.bullets {
                
                videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: false)
            }
            
            let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            let source = content.source?.name ?? ""
            
            if author == source || author == "" {
                videoPlayer.lblAuthor.isHidden = true
                videoPlayer.lblSource.text = source
            }
            else {
                
                videoPlayer.lblSource.text = source
                videoPlayer.lblAuthor.text = author
                
                if source == "" {
                    videoPlayer.lblAuthor.isHidden = true
                    videoPlayer.lblSource.text = author
                }
            }
            
            videoPlayer.viewHeaderTimer.isHidden = true
            videoPlayer.ctViewHeaderTimerHeight.constant = 0
            
            videoPlayer.viewOptionPost.isHidden = true
            videoPlayer.ctViewOptionPostHeight.constant = 0

            videoPlayer.imgPlaceHolder.image = thumbnailImage
            videoPlayer.imgPlaceHolder.isHidden = false
            videoPlayer.playButton.isHidden = true
            
            return videoPlayer
        }
        else if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_REEL {

            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            let reelCC = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_SCHEDULE_REEL, for: indexPath) as! ScheduleReelCC
//            reelCC.delegate = self
            reelCC.selectionStyle = .none
            
//            reelCC.btnShare.tag = indexPath.row
//            reelCC.btnSource.tag = indexPath.row
//            reelCC.playButton.tag = indexPath.row
            
//            reelCC.btnShare.addTarget(self, action: #selector((button:)), for: .touchUpInside)
//            reelCC.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            
            //LEFT - RIGHT ACTION

            reelCC.lblAuthor.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            if let source = content.source?.name?.capitalized {
                reelCC.lblSource.text = source
            }
            else {
                reelCC.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            }

            if let source = content.source {
                reelCC.imgWifi?.sd_setImage(with: URL(string: source.icon ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            }
            else {
                reelCC.imgWifi?.sd_setImage(with: URL(string: content.authors?.first?.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            }
                        
            let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            let source = content.source?.name ?? ""
            
            if author == source || author == "" {
                reelCC.lblAuthor.isHidden = true
                reelCC.lblSource.text = source
            }
            else {
                
                reelCC.lblSource.text = source
                reelCC.lblAuthor.text = author
                
                if source == "" {
                    reelCC.lblAuthor.isHidden = true
                    reelCC.lblSource.text = author
                }
            }

            reelCC.viewHeaderTimer.isHidden = true
            reelCC.ctViewHeaderTimerHeight.constant = 0
            
            reelCC.viewOptionPost.isHidden = true
            reelCC.ctViewOptionPostHeight.constant = 0

            if let bullets = content.bullets {
                
                reelCC.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: false)
            }
            
            reelCC.imgPlaceHolder.image = thumbnailImage
            reelCC.playButton.isHidden = true

            return reelCC
        }
        else if content.type?.uppercased() == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            
            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            //print("Volume 37")
            
            let youtubeCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_SCHEDULE_YOUTUBE, for: indexPath) as! ScheduleYoutubeCC
            
            //BUTTON ACTIONs
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
//            tapGesture.view?.tag = indexPath.row
//            youtubeCell.tag = indexPath.row
//            print("cardCell.viewGestures: ", indexPath.row)
//            youtubeCell.addGestureRecognizer(tapGesture)
            
            // Set like comment
            youtubeCell.setLikeComment(model: content.info)
            
            youtubeCell.langCode = content.language ?? ""
            youtubeCell.delegateYoutubeCardCell = self
//            youtubeCell.delegateLikeComment = self
            youtubeCell.selectionStyle = .none
            
            youtubeCell.url = content.link ?? ""
            youtubeCell.urlThumbnail = content.image ?? ""
            //youtubeCell.articleID = content.id ?? ""
            
            youtubeCell.btnShare.tag = indexPath.row
            youtubeCell.btnSource.tag = indexPath.row
            youtubeCell.btnPlayYoutube.tag = indexPath.row

//            youtubeCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
//            youtubeCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            youtubeCell.btnPlayYoutube.addTarget(self, action: #selector(didTapPlayYoutube(_:)), for: .touchUpInside)

            //LEFT - RIGHT ACTION
            youtubeCell.imgWifi.image = self.imgUser.image
            youtubeCell.lblSource.text = (fName + " " + lName).trim()
            
//            youtubeCell.lblSource.addTextSpacing(spacing: 2.5)
            let status = content.status ?? ""
            if status == Constant.newsArticle.ARTICLE_STATUS_SCHEDULED {
                
                if let pubDate = content.publish_time {
                    youtubeCell.lblAuthor.text = NSLocalizedString("Scheduled on:", comment: "") + "\n" + SharedManager.shared.utcToLocal(dateStr: pubDate)
                }
            }
            else {
                if let pubDate = content.publish_time {
                    youtubeCell.lblAuthor.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                }
//                youtubeCell.lblTime.addTextSpacing(spacing: 1.25)
            }
            
            //setup cell
            if let bullets = content.bullets {
                
                youtubeCell.setupSlideScrollView(bullets: bullets, row: indexPath.row, isAutoPlay: false)
            }
            
            let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            let source = content.source?.name ?? ""
            
            if author == source || author == "" {
                youtubeCell.lblAuthor.isHidden = true
                youtubeCell.lblSource.text = source
            }
            else {
                
                youtubeCell.lblSource.text = source
                youtubeCell.lblAuthor.text = author
                
                if source == "" {
                    youtubeCell.lblAuthor.isHidden = true
                    youtubeCell.lblSource.text = author
                }
            }
            
            youtubeCell.viewHeaderTimer.isHidden = true
            youtubeCell.ctViewHeaderTimerHeight.constant = 0
            
            youtubeCell.viewOptionPost.isHidden = true
            youtubeCell.ctViewOptionPostHeight.constant = 0

            return youtubeCell
        }
        else {
            
            //CARD VIEW DESIGN CELL- LARGE CELL
            guard let cardCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_SCHEDULE_CARD, for: indexPath) as? ScheduleCardCC else { return UITableViewCell() }
            
            // Set like comment
            cardCell.setLikeComment(model: content.info)
            
            cardCell.backgroundColor = UIColor.clear
            cardCell.setNeedsLayout()
            cardCell.layoutIfNeeded()
            cardCell.selectionStyle = .none
            cardCell.delegateScheduleCard = self
//            cardCell.delegateLikeComment = self
            cardCell.langCode = content.language ?? ""
            
            //LEFT - RIGHT ACTION
            cardCell.btnLeft.theme_tintColor = GlobalPicker.btnCellTintColor
            cardCell.btnRight.theme_tintColor = GlobalPicker.btnCellTintColor
            cardCell.constraintArcHeight.constant = cardCell.viewGestures.frame.size.height - 20
            
            cardCell.btnLeft.accessibilityIdentifier = String(indexPath.row)
            cardCell.btnRight.accessibilityIdentifier = String(indexPath.row)
            cardCell.btnLeft.addTarget(self, action: #selector(didTapScrollLeftRightCard(_:)), for: .touchUpInside)
            cardCell.btnRight.addTarget(self, action: #selector(didTapScrollLeftRightCard(_:)), for: .touchUpInside)
            
            //Image Pre-loading logic
            if articles.count > indexPath.row + 1 {
                
                let preContent = articles[indexPath.row + 1]
                cardCell.imgPreLoaded?.sd_setImage(with: URL(string: preContent.image ?? ""))
            }
            if articles.count > indexPath.row + 2 {
                
                let preContent = articles[indexPath.row + 2]
                cardCell.imgPreLoaded?.sd_setImage(with: URL(string: preContent.image ?? ""))
            }
            
            let url = content.image ?? ""
            cardCell.imgBlurBG?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            
            cardCell.imgBG.contentMode = .scaleAspectFill
            cardCell.imgBG.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"), completed: { (image, error, cacheType, imageURL) in
                
                if image == nil {
                    
                    cardCell.imgBG.accessibilityIdentifier = "image_placeholder"
                }
                else {
                    
                    cardCell.imgBG.accessibilityIdentifier = ""
                    cardCell.imgBG.contentMode = .scaleAspectFill
                    cardCell.imgBG.image = image
                }
            })
            
            //BUTTON ACTIONs
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
//            tapGesture.view?.tag = indexPath.row
//            cardCell.tag = indexPath.row
//            cardCell.viewGestures.addGestureRecognizer(tapGesture)
            
            cardCell.btnShare.tag = indexPath.row
            cardCell.btnSource.tag = indexPath.row
//            cardCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
//            cardCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            
            cardCell.lblSource.text = fName + " " + lName
            cardCell.imgWifi?.image = self.imgUser.image
            
            let status = content.status ?? ""
            if status == Constant.newsArticle.ARTICLE_STATUS_SCHEDULED {
                
                if let pubDate = content.publish_time {
                    cardCell.lblAuthor.text = NSLocalizedString("Scheduled on:", comment: "") + "\n" + SharedManager.shared.utcToLocal(dateStr: pubDate)
                }
            }
            else {
                if let pubDate = content.publish_time {
                    cardCell.lblAuthor.text = SharedManager.shared.generateDatTimeOfNews(pubDate).lowercased()
                }
                //cardCell.lblAuthor.text = content.authors?.first?.name?.capitalized
            }
            
            //<---Pan Gestures
            let panLeft = PanDirectionGestureRecognizer(direction: .horizontal(.left), target: self, action: #selector(handlePanGesture(_:)))
            panLeft.view?.tag = indexPath.row
            panLeft.cancelsTouchesInView = false
            cardCell.viewGestures.addGestureRecognizer(panLeft)
            
            let panRight = PanDirectionGestureRecognizer(direction: .horizontal(.right), target: self, action: #selector(handlePanGesture(_:)))
            panRight.view?.tag = indexPath.row
            panRight.cancelsTouchesInView = false
            cardCell.viewGestures.addGestureRecognizer(panRight)
            
            //add UISwipeGestureRecognizer when selected cell is active
            let direction: [UISwipeGestureRecognizer.Direction] = [ .left, .right]
            for dir in direction {
                let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeViewCard(_:)))
                cardCell.viewGestures.addGestureRecognizer(swipeGesture)
                swipeGesture.direction = dir
                swipeGesture.view?.tag = indexPath.row
                cardCell.viewGestures.isUserInteractionEnabled = true
                cardCell.viewGestures.isMultipleTouchEnabled = false
                
                panLeft.require(toFail: swipeGesture)
                panRight.require(toFail: swipeGesture)
            }
            
            //--->
            cardCell.setupSlideScrollView(article: content, isAudioPlay: true, row: indexPath.row, isMute: true)
            
            let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            let source = content.source?.name ?? ""
            
            if author == source || author == "" {
                cardCell.lblAuthor.isHidden = true
                cardCell.lblSource.text = source
            }
            else {
                
                cardCell.lblSource.text = source
                cardCell.lblAuthor.text = author
                
                if source == "" {
                    cardCell.lblAuthor.isHidden = true
                    cardCell.lblSource.text = author
                }
            }

            cardCell.viewHeaderTimer.isHidden = true
            cardCell.ctViewHeaderTimerHeight.constant = 0
            
            cardCell.viewOptionPost.isHidden = true
            cardCell.ctViewOptionPostHeight.constant = 0
            
            return cardCell
        }
    }
    
    
    @objc func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        
        if let gesture = pan as? PanDirectionGestureRecognizer {
            
            switch gesture.state {
            case .began:
                break
            case .changed:
                break
            case .ended,
                 .cancelled:
                break
            default:
                break
            }
        }
    }
    
    @objc func didTapPlayYoutube(_ button: UIButton) {
        
        let index = button.tag
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? YoutubeCardCell {
            
//            self.curVisibleYoutubeCardCell = cell
            if cell.videoPlayer.ready {
                
                cell.videoPlayer.play()
                //cell.imgPlay.isHidden = true
                cell.activityLoader.startAnimating()
            }
        }
    }
    
    @objc func swipeViewCard(_ sender: UISwipeGestureRecognizer) {
        
//        if UserDefaults.standard.bool(forKey: Constant.UD_isHapticOn) {
//
//            if #available(iOS 13.0, *) {
//                generator = UIImpactFeedbackGenerator(style: .soft)
//            } else {
//
//                generator = UIImpactFeedbackGenerator(style: .heavy)
//            }
//            generator.impactOccurred()
//        }
        
        let row = sender.view?.tag ?? 0
        
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: row, section: 0)) as? ScheduleCardCC {
            
            let content = self.articles[row]
            if let bullets = content.bullets {
                
                SharedManager.shared.isUserinteractWithHeadlinesOnly = true
                cell.isAutoScrolling = false
                print("print 4...")
                SharedManager.shared.bulletPlayer?.pause()
                SharedManager.shared.bulletPlayer?.stop()
                
                if SharedManager.shared.isSelectedLanguageRTL() {
                    // Arabic
                    if sender.direction == .right {
                        cell.swipeLeftFocusedCell(bullets: bullets)
                    }
                    else if sender.direction == .left {
                        cell.swipeRightFocusedCell(bullets: bullets, tag: 0)
                    }
                } else {
                    if sender.direction == .right {
                        cell.swipeRightFocusedCell(bullets: bullets, tag: 0)
                    }
                    else if sender.direction == .left {
                        cell.swipeLeftFocusedCell(bullets: bullets)
                    }
                }
            }
        }
    }
    
    //MARK:- UISwipeGesture Recognizer for left/right
    @objc func didTapScrollLeftRightCard(_ sender: UIButton) {
        
//        if UserDefaults.standard.bool(forKey: Constant.UD_isHapticOn) {
//
//            if #available(iOS 13.0, *) {
//                generator = UIImpactFeedbackGenerator(style: .soft)
//            } else {
//
//                generator = UIImpactFeedbackGenerator(style: .heavy)
//            }
//            generator.impactOccurred()
//        }
        
        let index = Int(sender.accessibilityIdentifier ?? "0") ?? 0

        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? ScheduleCardCC {
            
            cell.constraintArcHeight.constant = cell.viewGestures.frame.size.height - 20

            //let content = self.articles[index]
            if cell.bullets?.count ?? 0 <= 0 { return }
            
            SharedManager.shared.isManualScrolling = true
                        
            //focus cell
            SharedManager.shared.isUserinteractWithHeadlinesOnly = true
            cell.isAutoScrolling = false
            print("print 6...")
            SharedManager.shared.bulletPlayer?.pause()
            SharedManager.shared.bulletPlayer?.stop()
         
            if sender.tag == 0 {
                
                //LEFT
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articles[index].id ?? "")
                cell.btnLeft.pulsate()
                cell.btnLeft.setImage(UIImage(named: "leftArc"), for: .normal)
                cell.imgPrevious.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    
                    cell.btnLeft.setImage(UIImage(named: ""), for: .normal)
                    cell.imgPrevious.isHidden = true
                }
                
                if cell.currPage > 0 {
                    
                    if cell.currPage < cell.bullets?.count ?? 0 {
                        
                        cell.currPage -= 1
                        SharedManager.shared.segementIndex = cell.currPage
                        cell.scrollToItemBullet(at: cell.currPage, animated: true)
                        cell.playAudio()
                        //SharedManager.shared.spbCardView?.rewind()
                    }
                    else {
                        
                        cell.restartProgressbar()
                    }
                }
                else {
                    
                    cell.restartProgressbar()
                }
            }
            else {
                
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articles[index].id ?? "")
                cell.btnRight.setImage(UIImage(named: "rightArc"), for: .normal)
                cell.btnRight.pulsate()
                cell.imgNext.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    
                    cell.btnRight.setImage(UIImage(named: ""), for: .normal)
                    cell.imgNext.isHidden = true
                }
                
                if cell.currPage < (cell.bullets?.count ?? 0) - 1 {
                    
                    cell.currPage += 1
                    SharedManager.shared.segementIndex = cell.currPage
                    cell.scrollToItemBullet(at: cell.currPage, animated: true)
                    cell.playAudio()
                    //SharedManager.shared.spbCardView?.skip()
                }
                else {
                    
                    //self.restartProgressbar()
                    
                    cell.delegateScheduleCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
                }
            }

        }
    }
    
}


extension PreviewPostArticleVC: ProfileSelectionVCDelegate {
    
    func didSelectChannel(channel: ChannelInfo?) {
        
        if channel?.id != "" && channel?.id != SharedManager.shared.userId {
            
            lblName.text = "\(NSLocalizedString("Post to", comment: "")) \(channel?.name ?? "")"
            performWSToUpdateArticle(channelID: channel?.id ?? "")
            
            fName = channel?.name ?? ""
            lName = ""
                        
        } else {
            
            lblName.text = NSLocalizedString("Post to My Profile", comment: "")
            performWSToUpdateArticle(channelID: "")
            
            if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {
                
                fName = (user.first_name ?? "")
                lName = (user.last_name ?? "")
            }
        }
        
        if let cell = tblExtendedView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ScheduleVideoCC {
            cell.lblSource.text = (fName + " " + lName).trim()
        }
        else if let cell = tblExtendedView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ScheduleYoutubeCC {
            cell.lblSource.text = (fName + " " + lName).trim()
        }
        else if let cell = tblExtendedView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ScheduleCardCC {
            cell.lblSource.text = (fName + " " + lName).trim()
        }
        
        imgUser.sd_setImage(with: URL(string: channel?.icon ?? ""), placeholderImage: nil)
        
    }
    
}

