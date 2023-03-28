//
//  DiscoverCustomListVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 13/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKShareKit
import Photos


protocol DiscoverCustomListVCDelegate: AnyObject {
    
    func backButtonPressedDiscover()
    func collectionViewOffsetUpdate(model: Discover, offset: CGFloat)
    
}

class DiscoverCustomListVC: UIViewController, SharingDelegate, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var tbDiscoverList: UITableView!
    //  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var article: Discover?
    var contextId: String?
    private var nextPaginate = ""
    private var prefetchState: PrefetchState = .idle
    var articles: [articlesData] = []
    
    //sharing variables
    var type = ""
    var urlOfImageToShare: URL?
    var shareTitle = ""
    var sourceBlock = false
    var sourceFollow = false
    var article_archived = false
    var share_message = ""
    var topicsArray = [TopicData]()
    var sourcesArray = [ChannelInfo]()
    var locationArray = [Location]()
    var isLikeApiRunning = false
    var delegate: DiscoverCustomListVCDelegate?
    
    var mediaWatermark = MediaWatermark()
    var DocController: UIDocumentInteractionController = UIDocumentInteractionController()
    @IBOutlet weak var indicator: InstagramActivityIndicator!
    @IBOutlet weak var viewIndicator: UIView!
    
    @IBOutlet weak var header: UIView!
    var cardHeroId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.hero.isEnabled = true
//        header.hero.id = cardHeroId
//        header.hero.modifiers = [.useNoSnapshot, .spring(stiffness: 250, damping: 25)]
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColorHomeCell
//        self.tbDiscoverList.theme_backgroundColor = GlobalPicker.backgroundDiscoverMainColor
//        self.lblTitle.theme_textColor = GlobalPicker.textSubColorDiscover
//        self.lblSubTitle.theme_textColor = GlobalPicker.textBWColorDiscover
        
        self.lblTitle.theme_textColor = GlobalPicker.textSubColor
        self.lblSubTitle.theme_textColor = GlobalPicker.textColor
        
        self.lblTitle.text = article?.subtitle ?? ""
        self.lblSubTitle.text = article?.title ?? ""
        let url = article?.data?.image ?? ""
        self.imgNews?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        self.btnClose.theme_setImage(GlobalPicker.imgCloseDiscoverList, forState: .normal)
        
        self.registerCells()
        
        indicator.animationDuration = 1.0
        indicator.rotationDuration = 3
        indicator.numSegments = 15
        indicator.strokeColor = "#E01335".hexStringToUIColor()
        indicator.lineWidth = 3
    }
    
    
    override func viewWillLayoutSubviews() {
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                self.lblSubTitle.semanticContentAttribute = .forceRightToLeft
                self.lblSubTitle.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                self.lblSubTitle.semanticContentAttribute = .forceLeftToRight
                self.lblSubTitle.textAlignment = .left
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if type == "IMAGE_ARTICLES" {
            
            self.performWSToGetNews(isReloadView: false)
        }
        else if type == "IMAGE_TOPICS" {
            
            self.performWSToGetAllTopics(searchText: "")
        }
        else if type == "IMAGE_CHANNELS" {
            
            self.sourcesArray.removeAll()
            nextPaginate = ""
            self.performWSToGetUserSources(searchText: "")
        }
        else {
            
            self.locationArray.removeAll()
            nextPaginate = ""
            self.performWSToGetUserLocation(searchText: "")
        }
    }
    
    func registerCells() {
        
        self.tbDiscoverList.register(UINib(nibName: "GenericListCell", bundle: nil), forCellReuseIdentifier: "GenericListCell")
        self.tbDiscoverList.register(UINib(nibName: "CustomTopicChannelCC", bundle: nil), forCellReuseIdentifier: "CustomTopicChannelCC")
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        if self.indicator.isAnimating {
            
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.viewIndicator.isHidden = true
        }
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        
        SharedManager.shared.isOnDiscover = true
        self.dismiss(animated: true, completion: nil)
        
        self.delegate?.backButtonPressedDiscover()
    }
}

//MARK:- CARD VIEW TABLE DELEGATE
extension DiscoverCustomListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if type == "IMAGE_ARTICLES" {
            
            return self.articles.count
        }
        else if type == "IMAGE_TOPICS" {
            
            return self.topicsArray.count
        }
        else if type == "IMAGE_CHANNELS" {
            
            return self.sourcesArray.count
        }
        else {
            
            return self.locationArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if type == "IMAGE_ARTICLES" {
            
            let content = self.articles[indexPath.row]
            let articelListCell = tableView.dequeueReusableCell(withIdentifier: "GenericListCell", for: indexPath) as! GenericListCell
            articelListCell.delegateLikeComment = self
            
            articelListCell.btnShare.tag = indexPath.row
            articelListCell.btnSource.tag = indexPath.row
            articelListCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
            articelListCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            
            articelListCell.contentView.backgroundColor = .clear
            articelListCell.backgroundColor = .clear
            articelListCell.setupCell(model: content, isOpenFromTopNews: true)
//            articelListCell.viewSeperatorLine.isHidden = false
//            if self.articles.count == indexPath.row + 1 {
//
//                articelListCell.viewSeperatorLine.isHidden = true
//            }
            return articelListCell
        }
        else if type == "IMAGE_TOPICS"  {
            
            let content = self.topicsArray[indexPath.row]
            let articelListCell = tableView.dequeueReusableCell(withIdentifier: "CustomTopicChannelCC", for: indexPath) as! CustomTopicChannelCC
            
            articelListCell.btnFollow.tag = indexPath.row
            articelListCell.btnFollow.addTarget(self, action: #selector(didTapFollow(button:)), for: .touchUpInside)
            
            articelListCell.contentView.backgroundColor = .clear
            articelListCell.backgroundColor = .clear
            
            articelListCell.setupTopicCell(model: content)
            
            return articelListCell
        }
        else if type == "IMAGE_CHANNELS"  {
            
            let content = self.sourcesArray[indexPath.row]
            let articelListCell = tableView.dequeueReusableCell(withIdentifier: "CustomTopicChannelCC", for: indexPath) as! CustomTopicChannelCC
            
            articelListCell.btnFollow.tag = indexPath.row
            articelListCell.btnFollow.addTarget(self, action: #selector(didTapFollow(button:)), for: .touchUpInside)
            
            articelListCell.contentView.backgroundColor = .clear
            articelListCell.backgroundColor = .clear
            
            articelListCell.setupSourceCell(model: content)
            return articelListCell
        }
        else {
            
            let content = self.locationArray[indexPath.row]
            let articelListCell = tableView.dequeueReusableCell(withIdentifier: "CustomTopicChannelCC", for: indexPath) as! CustomTopicChannelCC
            
            articelListCell.btnFollow.tag = indexPath.row
            articelListCell.btnFollow.addTarget(self, action: #selector(didTapFollow(button:)), for: .touchUpInside)
            
            articelListCell.contentView.backgroundColor = .clear
            articelListCell.backgroundColor = .clear
            
            articelListCell.setupLocationCell(model: content)
            return articelListCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if type == "IMAGE_ARTICLES" {
            
            let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
            let content = self.articles[indexPath.row]
            vc.selectedArticleData = content
            let navVC = UINavigationController(rootViewController: vc)
            navVC.navigationBar.isHidden = true
            navVC.modalPresentationStyle = .overFullScreen
            navVC.modalTransitionStyle = .crossDissolve
            self.present(navVC, animated: true, completion: nil)
        }
        else if type == "IMAGE_TOPICS"{
            
            let content = self.topicsArray[indexPath.row]
            self.performWSToGetSubTopics(topicId: content.id ?? "", isFav: content.favorite ?? false, name: content.name ?? "")
//            let vc = DiscoverCustomListVC.instantiate(fromAppStoryboard: .Home)
//            vc.article = article
//            vc.contextId = content.context ?? ""
//            vc.type = "IMAGE_ARTICLES"
//            vc.modalPresentationStyle = .fullScreen
//            let navVC = UINavigationController(rootViewController: vc)
//            navVC.modalPresentationStyle = .overFullScreen
//            navVC.navigationBar.isHidden = true
//            self.present(navVC, animated: true, completion: nil)
            
        }
        else if type == "IMAGE_PLACES" {
            
            let content = self.locationArray[indexPath.row]
            SharedManager.shared.subLocationList = [Location]()
//            SharedManager.shared.articleSearchModeType = ""
            
            let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
            vc.showArticleType = .places
            vc.selectedID = content.id ?? ""
            vc.isFav = content.favorite ?? false
            vc.placeContextId = content.context ?? ""
            vc.subTopicTitle = content.city ?? ""
                    
            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            navVC.navigationBar.isHidden = true
            self.present(navVC, animated: true, completion: nil)
            
          //  self.performWSToGetSubTopics(topicId: content.id ?? "", isFav: content.favorite ?? false, name: content.city ?? "")
            
        }
        else if type == "IMAGE_CHANNELS" {
            
            let content = self.sourcesArray[indexPath.row]
            self.performWSToGetSubSource(sourceId: content.id ?? "", isFav: content.favorite ?? false, name:content.name ?? "")
//            let vc = DiscoverCustomListVC.instantiate(fromAppStoryboard: .Home)
//            vc.article = article
//            vc.contextId = content.context ?? ""
//            vc.type = "IMAGE_ARTICLES"
//            vc.modalPresentationStyle = .fullScreen
//            let navVC = UINavigationController(rootViewController: vc)
//            navVC.modalPresentationStyle = .overFullScreen
//            navVC.navigationBar.isHidden = true
//            self.present(navVC, animated: true, completion: nil)
        }
        else {
            
            let content = self.locationArray[indexPath.row]
            let vc = DiscoverCustomListVC.instantiate(fromAppStoryboard: .Home)
            vc.article = article
            vc.contextId = content.context ?? ""
            vc.type = "IMAGE_ARTICLES"
            vc.modalPresentationStyle = .fullScreen
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .overFullScreen
            navVC.navigationBar.isHidden = true
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if type == "IMAGE_ARTICLES" {
            
            return UITableView.automaticDimension
            
        }
        
        return 110
    }
    
    @objc func didTapShare(button: UIButton) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.shareClick, eventDescription: "")
        
        let index = button.tag
        
        self.performWSToShare(article: self.articles[index])
    }
    
    @objc func didTapSource(button: UIButton) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
        
        button.isUserInteractionEnabled = false
        let index = button.tag
        
        self.performGoToSource(self.articles[index])
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            button.isUserInteractionEnabled = true
        }
    }
    
    @objc func didTapFollow(button: UIButton) {
        
        let index = button.tag
        if type == "IMAGE_TOPICS" {
            
            let model = self.topicsArray[index]
            self.performWSToUpdateUserTopics(id: model.id ?? "",isFav: model.favorite ?? false, indexPath: index)
        }
        else if type == "IMAGE_CHANNELS" {
            
            let model = self.sourcesArray[index]
            self.performWSToUpdateUserSources(id: model.id ?? "",isFav: model.favorite ?? false, indexPath: index)
        }
        else {
            
            let model = self.locationArray[index]
            self.performWSToUpdateUserLocation(id: model.id ?? "",isFav: model.favorite ?? false, indexPath: index)
        }
    }
}

//MARK: - Scrollview delegates and related control methods.
extension DiscoverCustomListVC: UIScrollViewDelegate {
    
    // top searchview height on the base of scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let prefetchThreshold: CGFloat = Constant.newsArticle.BOTTOM_INSET + 30
        if scrollView.contentOffset.y > scrollView.contentSize.height - tbDiscoverList.frame.height - prefetchThreshold {
            if prefetchState == .idle {
                //print("mahesh nextPaginate", nextPaginate)
                guard prefetchState == .idle && !(self.nextPaginate.isEmpty) else { return }
                prefetchState = .fetching
                
                if type == "IMAGE_ARTICLES" {
                    
                    self.performWSToGetNews(isReloadView: false)
                }
                else if type == "IMAGE_TOPICS" {
                    
                    self.performWSToGetAllTopics(searchText: "")
                }
                else if type == "IMAGE_CHANNELS" {
                    
                    self.performWSToGetUserSources(searchText: "")
                }
                else {
                    
                    self.performWSToGetUserLocation(searchText: "")
                }
            }
        }
    }
}

extension DiscoverCustomListVC {
    
    func performWSToGetSubSource(sourceId: String, isFav: Bool, name:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let id = sourceId
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/data/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            

            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                DispatchQueue.main.async {
                                        
                    if let Info = FULLResponse.channel {
                        
//                        SharedManager.shared.articleSearchModeType = ""
//                        
//            //                        SharedManager.shared.spbCardView?.removeFromSuperview()
//                        SharedManager.shared.spbListView?.cancel()
//                        
//                        
                        
//                        if let sources = Info.categories {
//
//                            SharedManager.shared.subSourcesList = sources
//                        }
                        
                        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
                        detailsVC.channelInfo = Info
                        
                        let navVC = AppNavigationController(rootViewController: detailsVC)
                        navVC.modalPresentationStyle = .fullScreen
                        self.present(navVC, animated: true, completion: nil)
                     //   self.navigationController?.pushViewController(detailsVC, animated: true)

                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Related Sources not available", comment: ""))
                    }
                }
                
            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetSubTopics(topicId: String, isFav: Bool, name:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let id = topicId
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/topics/related/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do {
                let FULLResponse = try
                    JSONDecoder().decode(SubTopicDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let topics = FULLResponse.topics {
                        
                     //   topics.insert(topic, at: 0)
                        SharedManager.shared.subTopicsList = topics
//                        SharedManager.shared.articleSearchModeType = ""
                        
                        let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
                        vc.showArticleType = .topic
                        vc.selectedID = topicId
                        vc.isFav = isFav
                        vc.subTopicTitle = name
                        let navVC = AppNavigationController(rootViewController: vc)
                        navVC.modalPresentationStyle = .fullScreen
                        self.present(navVC, animated: true, completion: nil)
                       // self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/topics/related/\(id)", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            //SharedManager.shared.showAPIFailureAlert()
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    // MARK: - Like API
    func performWSToLikePost(article_id: String, isLike: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let params = ["like": isLike]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        isLikeApiRunning = true
        WebService.URLResponseJSONRequest("social/likes/article/\(article_id)", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            self.isLikeApiRunning = false
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
                
                SharedManager.shared.logAPIError(url: "social/likes/article/\(article_id)", error: jsonerror.localizedDescription, code: "")
                self.isLikeApiRunning = false
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            self.isLikeApiRunning = false
            print("error parsing json objects",error)
        }

    }
}

//MARK:- locations APIs
extension DiscoverCustomListVC {
    
    func performWSToGetUserLocation(searchText:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        var url = ""
        if searchText.isEmpty || searchText == " " {
            
            if self.nextPaginate.isEmpty {
            
            }
            
            url = "news/locations?page=\(nextPaginate)"
        }
        else{
            
            let searchText = searchText.encodeUrl()
            url = "news/locations?query=\(searchText)&page=\(nextPaginate)"
        }
        
        SharedManager.shared.cancelAllCurrentAlamofireRequests()
        
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.prefetchState = .idle
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                if let locations = FULLResponse.locations {
                    
                    self.locationArray += locations
                    self.tbDiscoverList.reloadData()
                }
                
                if let meta = FULLResponse.meta {
                    
                    self.nextPaginate = meta.next ?? ""
                }
                
            } catch let jsonerror {
                self.prefetchState = .idle
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            self.prefetchState = .idle
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUpdateUserLocation(id:String, isFav: Bool, indexPath: Int) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let params = ["locations":id]
        let url = isFav ? "news/locations/unfollow" : "news/locations/follow"
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateSourceDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    
                    let element = self.locationArray[indexPath]
                    self.locationArray[indexPath].favorite = !isFav
                    
                    self.tbDiscoverList.reloadData()
                }
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
}


//MARK:- sources APIs
extension DiscoverCustomListVC {
    
    func performWSToGetUserSources(searchText:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        var url = ""
        if searchText.isEmpty || searchText == " " {
            
            if self.nextPaginate.isEmpty {
            }
            url = "news/sources?page=\(nextPaginate)"
        }
        else{
            
            let searchText = searchText.encodeUrl()
            url = "news/sources?query=\(searchText)&page=\(nextPaginate)"
        }
        
        SharedManager.shared.cancelAllCurrentAlamofireRequests()
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.prefetchState = .idle
            do{
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                if let sources = FULLResponse.sources {
                    
                    self.sourcesArray += sources
                    self.tbDiscoverList.reloadData()
                }
                
                if let meta = FULLResponse.meta {
                    
                    self.nextPaginate = meta.next ?? ""
                }
                
            } catch let jsonerror {
                self.prefetchState = .idle
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            self.prefetchState = .idle
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUpdateUserSources(id:String, isFav: Bool, indexPath: Int) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        let params = ["sources":id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        let url = isFav ? "news/sources/unfollow" : "news/sources/follow"
        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateSourceDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    self.sourcesArray[indexPath].favorite = isFav ? false : true
                    self.tbDiscoverList.reloadData()
                }
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
}

//MARK:- Topics APIs
extension DiscoverCustomListVC {
    
    func performWSToGetNews(isReloadView: Bool = false) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        //Reload View when user comes from App Background
        if isReloadView {

            nextPaginate = ""
            prefetchState = .fetching
        }
        
        //encode pagination value
        nextPaginate = nextPaginate.encode()
        var querySt = ""
        querySt = "news/articles?context=\(contextId ?? "")&page=\(nextPaginate)&reader_mode=\(SharedManager.shared.readerMode)"
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(querySt, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do {
                
                let FULLResponse = try
                    JSONDecoder().decode(articlesDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    self.prefetchState = .idle
                    if self.nextPaginate == "" {
                        
                        self.articles.removeAll()
                    }
                    
                    //Reload View when user comes from App Background
                    if isReloadView {
                        
                        if let arr = FULLResponse.articles, arr.count > 0 {
                            
                            
                            self.articles += arr
                            
                            self.tbDiscoverList.setContentOffset(.zero, animated: false)
                            self.tbDiscoverList.isHidden = false
                            self.tbDiscoverList.reloadData()
                            
                            if let meta = FULLResponse.meta {
                                self.nextPaginate = meta.next ?? ""
                            }
                            
                        }
                        else {
                            
                            //        self.viewNoData.isHidden = false
                            self.tbDiscoverList.isHidden = true
                        }
                        
                        //      self.activityIndicator.stopAnimating()
                    }
                    else {
                        
                        if let arr = FULLResponse.articles, arr.count > 0 {
                            
                            self.articles += arr
                            
                            self.tbDiscoverList.isHidden = false
                            self.tbDiscoverList.reloadData()
                            
                            
                            if let meta = FULLResponse.meta {
                                self.nextPaginate = meta.next ?? ""
                            }
                        }
                        //Get notification which is launched app
                        //                        if SharedManager.shared.isAppLaunchedThroughNotification {
                        //
                        //                            SharedManager.shared.isAppLaunchedThroughNotification = false
                        //                            NotificationCenter.default.post(name: Notification.Name.notifyGetPushNotificationArticleData, object: nil, userInfo: nil)
                        //                        }
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: querySt, error: jsonerror.localizedDescription, code: "")
                self.prefetchState = .idle
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            self.prefetchState = .idle
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetAllTopics(searchText: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        var url = ""
        if searchText == "" {
            
            if self.nextPaginate.isEmpty {
                
            }
            url = "news/topics?page=\(nextPaginate)"
        }
        else{
            
            let searchText = searchText.encodeUrl()
            url = "news/topics?query=\(searchText)&page=\(nextPaginate)"
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        SharedManager.shared.cancelAllCurrentAlamofireRequests()
        
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(TopicDC.self, from: response)
                
                
                self.prefetchState = .idle
                if self.nextPaginate == "" {
                    
                    self.topicsArray.removeAll()
                }
                
                if let arr = FULLResponse.topics, arr.count > 0 {
                    
                    self.topicsArray += arr
                    
                    self.tbDiscoverList.isHidden = false
                    self.tbDiscoverList.reloadData()
                    
                    
                    if let meta = FULLResponse.meta {
                        self.nextPaginate = meta.next ?? ""
                    }
                    self.tbDiscoverList.reloadData()
                    
                    
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                
                self.prefetchState = .idle
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            self.prefetchState = .idle
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUpdateUserTopics(id:String, isFav: Bool, indexPath: Int) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        let params = ["topics":id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        let url = isFav ? "news/topics/unfollow" : "news/topics/follow"
        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateTopicDC.self, from: response)
                

                if FULLResponse.message == "Success" {
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    
                    let element = self.topicsArray[indexPath]
                    self.topicsArray[indexPath] = TopicData(id: element.id, context: element.context, name: element.name, icon: element.icon, link: element.link, image: element.image, color: element.color, favorite: isFav ? false : true)
                    self.tbDiscoverList.reloadData()
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
}


//MARK:- Bottom Sheet
extension DiscoverCustomListVC: BottomSheetVCDelegate {
    
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
                                                
                        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
                        detailsVC.channelInfo = Info
                        //detailsVC.delegateVC = self
                        //detailsVC.isOpenFromDiscoverCustomListVC = true
                        detailsVC.modalPresentationStyle = .fullScreen
//                        self.navigationController?.pushViewController(detailsVC, animated: true)
                        let nav = AppNavigationController(rootViewController: detailsVC)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: "Related Sources not available")
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
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
                    vc.delegateBottomSheet = self
                    vc.article = article
                    vc.sourceBlock = FULLResponse.source_blocked ?? false
                    vc.sourceFollow = FULLResponse.source_followed ?? false
                    vc.article_archived = FULLResponse.article_archived ?? false
                    vc.share_message = FULLResponse.share_message ?? ""
                    vc.isMainScreen = true
                    self.shareTitle = FULLResponse.share_message ?? ""
                    let navVC = UINavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .overFullScreen
                    navVC.navigationBar.isHidden = true
                    self.present(navVC, animated: true, completion: nil)
                    //                    self.view.window..present(vc, animated: true, completion: nil)
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/articles/\(article.id ?? "")/share/info", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func didTapDissmisReportContent() {
        
        SharedManager.shared.showAlertLoader(message: "Report concern sent successfully.")
    }
    
    func didTapUpdateAudioAndProgressStatus() {
        
    }
    
    
    func didTapBottomShareSheetAction(sender: UIButton, article: articlesData) {
        
        if sender.tag == 1 {
            
            //Save article
            performArticleArchive(article.id ?? "", isArchived: !self.article_archived)
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
    
    func performArticleArchive(_ id: String, isArchived: Bool) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.archiveClick, eventDescription: "", article_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["archive": isArchived]
        WebService.URLResponse("news/articles/\(id)/archive", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    if status == Constant.STATUS_SUCCESS {
                        
                        SharedManager.shared.showAlertLoader(message: isArchived ? ApplicationAlertMessages.kMsgAddToFavorite : ApplicationAlertMessages.kMsRemoveFromFavorite)
                        
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/articles/\(id)/archive", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
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
                    
                    //   self.updateProgressbarStatus(isPause: false)
                    if status == Constant.STATUS_SUCCESS {
                        
                        SharedManager.shared.isDiscoverTabReload = true
                        SharedManager.shared.isTabReload = true
                        SharedManager.shared.isFav = false
                        NotificationCenter.default.post(name: Notification.Name.notifyUpdateFollowIcon, object: nil)
                        
                        SharedManager.shared.showAlertLoader(message: "Unfollowed \(name)", type: .alert)
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/unfollow", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
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
                //   self.updateProgressbarStatus(isPause: false)
                if FULLResponse.message == "Success" {
                    
                    SharedManager.shared.isDiscoverTabReload = true
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.showAlertLoader(message: "Followed \(name)", type: .alert)
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/follow", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
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
                
                //   self.updateProgressbarStatus(isPause: false)
                if FULLResponse.message == "Success" {
                    
                    SharedManager.shared.isDiscoverTabReload = true
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.showAlertLoader(message: "Unblocked \(name)", type: .alert)
                }
                else {
                    
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                ANLoader.hide()
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/unblock", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
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
                    
                    //   self.updateProgressbarStatus(isPause: false)
                    if status == Constant.STATUS_SUCCESS {
                        
                        SharedManager.shared.isDiscoverTabReload = true
                        SharedManager.shared.isTabReload = true
                        SharedManager.shared.showAlertLoader(message: "Blocked \(sourceName)", type: .alert)
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/block", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
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
                    
                    //    self.updateProgressbarStatus(isPause: false)
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
                
                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            print("error parsing json objects",error)
        }
    }
}

extension DiscoverCustomListVC: LikeCommentDelegate {
    
    func didTapCommentsButton(cell: UITableViewCell) {
        
        guard let indexPath = tbDiscoverList.indexPath(for: cell) else {return}
        let content = self.articles[indexPath.row]
        
//        self.updateProgressbarStatus(isPause: true)
        
        let vc = CommentsVC.instantiate(fromAppStoryboard: .Home)
        vc.delegate = self
        vc.articleID = content.id ?? ""
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isNavigationBarHidden = true
        navVC.modalPresentationStyle = .overFullScreen
        self.present(navVC, animated: true, completion: nil)
        
//        self.delegateBulletDetails?.commentUpdated(articleID: content.id ?? "", count: content.info?.commentCount ?? 0)
    }
    
    func didTapLikeButton(cell: UITableViewCell) {
        
        if isLikeApiRunning {
            return
        }
        guard let indexPath = tbDiscoverList.indexPath(for: cell) else {return}
        
        var likeCount = self.articles[indexPath.row].info?.likeCount
        if (self.articles[indexPath.row].info?.isLiked ?? false) {
            likeCount = (likeCount ?? 0) - 1
        } else {
            likeCount = (likeCount ?? 0) + 1
        }
        let info = Info(viewCount: self.articles[indexPath.row].info?.viewCount, likeCount: likeCount, commentCount: self.articles[indexPath.row].info?.commentCount, isLiked: !(self.articles[indexPath.row].info?.isLiked ?? false))
        self.articles[indexPath.row].info = info
        (cell as? GenericListCell)?.setLikeComment(model: self.articles[indexPath.row].info)

        performWSToLikePost(article_id: self.articles[indexPath.row].id ?? "", isLike: self.articles[indexPath.row].info?.isLiked ?? false)
        
        
//        self.delegateBulletDetails?.likeUpdated(articleID: self.articles[indexPath.row].id ?? "", isLiked: self.articles[indexPath.row].info?.isLiked ?? false, count: likeCount ?? 0)
        
    }
    
    func didTapCommentsButtonCollectionView(cell: UITableViewCell) {
    }
    
    func didTapLikeButtonCollectionView(cell: UITableViewCell) {
    }
    
    
}

extension DiscoverCustomListVC: CommentsVCDelegate {
    
    func commentsVCDismissed(articleID: String) {

        SharedManager.shared.performWSToGetCommentsCount(id: articleID) { info in
            if info != nil {
                
                if let selectedIndex = self.articles.firstIndex(where: { $0.id == articleID }) {
//                    self.articles[selectedIndex].info = info
                    self.articles[selectedIndex].info?.commentCount = info?.commentCount ?? 0
                    
                    if let cell = self.tbDiscoverList.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) {
                        (cell as? GenericListCell)?.setLikeComment(model: self.articles[selectedIndex].info)
                    }
                    
                }
            }
        }
        
    }
}
