//
//  channelsChildVC.swift
//  Bullet
//
//  Created by Mahesh on 07/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class channelsChildVC: UIViewController {
    
    @IBOutlet weak var viewNoSearch: UIView!
    @IBOutlet weak var viewChannels: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSuggestions: UILabel!
    @IBOutlet var lblCollectionNoSearch: [UILabel]!
    @IBOutlet weak var lblNoSearchTitle: UILabel!
    @IBOutlet weak var lblNoSearchDesc: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var constraintClvHeight: NSLayoutConstraint!
    
    var relevant: Relevant?
    var VcType = ""
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerCell()
        lblNoSearchTitle.text = NSLocalizedString("No results", comment: "")
        lblNoSearchDesc.text = NSLocalizedString("Try a different keyword", comment: "")
        
        viewNoSearch.isHidden = true
        self.lblCollectionNoSearch.forEach {
            $0.theme_textColor = GlobalPicker.textColor
        }
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        lblTitle.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        viewChannels.theme_backgroundColor = GlobalPicker.followingCardColor
        lblSuggestions.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        viewChannels.addBottomShadow()
        
        //We will set the height of collectionview view and header title for all types
        if VcType == "topics" {
            
            lblTitle.text = "Topics"
            
            if let arrTopics = self.relevant?.topics {
                
                let arrCount = Double(arrTopics.count) / 3
                let ceilCount = ceil(arrCount)
                self.constraintClvHeight.constant = (62 * CGFloat(ceilCount)) + 60
            }
        }
        else if VcType == "authors" {
            
            lblTitle.text = "Authors"
            
            if let arrAuthors = self.relevant?.authors {
           
                let arrCount = Double(arrAuthors.count) / 3
                let ceilCount = ceil(arrCount)
                self.constraintClvHeight.constant = (((self.collectionView.frame.size.width / 3) + 15) * CGFloat(ceilCount)) + 80
            }
        }
        else {
            
            lblTitle.text = VcType == "locations" ? "Places" : "Channels"
            
            let arrC = (VcType == "locations" ? self.relevant?.locations?.count : self.relevant?.sources?.count) ?? 0
            let arrCount = Double(arrC) / 4
            let ceilCount = ceil(arrCount)
            if self.view.frame.size.width > 375 {
                
                self.constraintClvHeight.constant = ((self.collectionView.frame.size.width / 3) * CGFloat(ceilCount)) + 80
            }
            else {
                
                self.constraintClvHeight.constant = ((self.collectionView.frame.size.width / 3) * CGFloat(ceilCount)) + 65
            }
        }
        self.collectionView.reloadData()
    }
    
    func registerCell() {
        
        collectionView.register(UINib(nibName: "FollowingChannelCC", bundle: nil), forCellWithReuseIdentifier: "FollowingChannelCC")
        collectionView.register(UINib(nibName: "FollowingTopicCC", bundle: nil), forCellWithReuseIdentifier: "FollowingTopicCC")
        collectionView.register(UINib(nibName: "FollowingAuthorsCC", bundle: nil), forCellWithReuseIdentifier: "FollowingAuthorsCC")
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: false)
    }
}

extension channelsChildVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if VcType == "locations" {
            
            return relevant?.locations?.count ?? 0
        }
        else if VcType == "topics" {
            
            return relevant?.topics?.count ?? 0
        }
        else if VcType == "authors" {
            
            return relevant?.authors?.count ?? 0
        }
        else {
            
            return relevant?.sources?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if VcType == "locations" {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowingChannelCC", for: indexPath) as! FollowingChannelCC
            
            if let locationsArray = self.relevant?.locations, locationsArray.count > 0 {
                
                cell.btnFav.tag = indexPath.row
                cell.btnFav.addTarget(self, action: #selector(didTapFavouriteButton), for: .touchUpInside)
                
                let locations = locationsArray[indexPath.row]
                cell.setupLocationCell(location: locations)
            }
            return cell
        }
        else if VcType == "topics" {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowingTopicCC", for: indexPath) as! FollowingTopicCC
            
            if let topicsArray = self.relevant?.topics, topicsArray.count > 0 {
                
                cell.btnFav.tag = indexPath.row
                cell.btnFav.addTarget(self, action: #selector(didTapFavouriteButton), for: .touchUpInside)
                
                let Topic = topicsArray[indexPath.row]
                cell.setupTopicCell(topic: Topic)
            }
            return cell
        }
        else if VcType == "authors" {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowingAuthorsCC", for: indexPath) as! FollowingAuthorsCC
            
            cell.btnFav.tag = indexPath.row
            cell.btnFav.addTarget(self, action: #selector(didTapFavouriteButton), for: .touchUpInside)
            if let Author = relevant?.authors?[indexPath.row] {
                
                cell.setupAuthorCell(author: Author)
            }
            return cell
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowingChannelCC", for: indexPath) as! FollowingChannelCC
            if let sourcesArray = self.relevant?.sources, sourcesArray.count > 0 {
                
                cell.btnFav.tag = indexPath.row
                cell.btnFav.addTarget(self, action: #selector(didTapFavouriteButton), for: .touchUpInside)
                
                let sources = sourcesArray[indexPath.row]
                cell.setupChannelChildCell(channel: sources)
            }
            return cell
        }
    }
    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if VcType == "topics" {
            
            return CGSize(width: collectionView.frame.size.width / 3, height: 62)
        }
        else if VcType == "authors" {
            
            return CGSize(width: collectionView.frame.size.width / 3, height: (collectionView.frame.size.width / 3) + 15)
        }
        else {
            
            if self.view.frame.size.width > 375 {
                
                return CGSize(width: collectionView.frame.size.width / 4, height: (collectionView.frame.size.width / 3))
                
            }else {
                
                return CGSize(width: collectionView.frame.size.width / 3, height: (collectionView.frame.size.width / 3))
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if VcType == "authors" {
            
            if let author = relevant?.authors?[indexPath.row] {
                
                let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                vc.authors = [Authors(id: author.id, name: author.first_name, username: author.username, image: author.profile_image, favorite: author.favorite)]
                let navVC = AppNavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true, completion: nil)
            }
        }
        else if VcType == "topics" {
            
            if let topic = relevant?.topics?[indexPath.row] {
                
                performTabSubTopic(topic)
            }
        }
        else {
            
            if let sourcesArray = self.relevant?.sources, sourcesArray.count > 0 {
                
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")
                performTabSubSource(sourcesArray[indexPath.row].id ?? "")
            }
        }
    }
    
    //MARK:- favourite button Action
    @objc func didTapFavouriteButton(sender: UIButton) {
        
        if VcType == "locations" {
            
            if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? FollowingChannelCC {
                
                cell.isUserInteractionEnabled = false
                if let location = self.relevant?.locations?[sender.tag] {
                    
                    let fav = location.favorite ?? false
                    self.performWSToUpdateUserFollow(id: location.id ?? "", isFav: fav) { [weak self] status in
                        cell.isUserInteractionEnabled = true
                        if status {
                            
                            //We are updating array locally
                            self?.relevant?.locations?[sender.tag].favorite = fav ? false : true
                            self?.collectionView.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                        }
                    }
                }
            }
        }
        else if VcType == "topics" {
            
            if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? FollowingTopicCC {
                
                cell.isUserInteractionEnabled = false
                if let topic = relevant?.topics?[sender.tag] {
                    
                    let fav = topic.favorite ?? false
                    self.performWSToUpdateUserFollow(id: topic.id ?? "", isFav: fav) { [weak self] status in
                        cell.isUserInteractionEnabled = true
                        if status {
                            
                            //We are updating array locally
                            self?.relevant?.topics?[sender.tag].favorite = fav ? false : true
                            self?.collectionView.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                        }
                    }
                }
            }
        }
        else if VcType == "authors" {
            
            if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? FollowingAuthorsCC {
                
                cell.isUserInteractionEnabled = false
                if let author = relevant?.authors?[sender.tag] {
                    
                    let fav = author.favorite ?? false
                    self.performWSToUpdateUserFollow(id: author.id ?? "", isFav: fav) { [weak self] status in
                        cell.isUserInteractionEnabled = true
                        if status {
                            
                            //We are updating array locally
                            self?.relevant?.authors?[sender.tag].favorite = fav ? false : true
                            self?.collectionView.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                        }
                    }
                }
            }
        }
        else {
            
            if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? FollowingChannelCC {
                
                cell.isUserInteractionEnabled = false
                if let channel = self.relevant?.sources?[sender.tag] {
                    
                    let fav = channel.favorite ?? false
                    self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav) { [weak self] status in
                        cell.isUserInteractionEnabled = true
                        if status {
                            
                            //We are updating array locally
                            self?.relevant?.sources?[sender.tag].favorite = fav ? false : true
                            self?.collectionView.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                        }
                    }
                }
            }
        }
    }
}

//MARK: - Update User Follow Webservices
extension channelsChildVC {
    
    func performWSToUpdateUserFollow(id:String, isFav: Bool, completionHandler: @escaping CompletionHandler) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        var params = [String:String]()
        var url = ""
        if VcType == "locations" {
            
            params = ["locations":id]
            url = isFav ? "news/locations/unfollow" : "news/locations/follow"
        }
        else if VcType == "topics" {
            
            params = ["topics":id]
            url = isFav ? "news/topics/unfollow" : "news/topics/follow"
        }
        else if VcType == "authors" {
            
            params = ["authors":id]
            url = isFav ? "news/authors/unfollow" : "news/authors/follow"
        }
        else{
            
            params = ["sources":id]
            url = isFav ? "news/sources/unfollow" : "news/sources/follow"
        }
        
        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateTopicDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    //SharedManager.shared.isTabReload = true
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                completionHandler(false)
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            
            completionHandler(false)
            print("error parsing json objects",error)
        }
    }
    
    func performTabSubSource(_ id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/data/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let Info = FULLResponse.channel {
                        
//                        
//            //                        SharedManager.shared.spbCardView?.removeFromSuperview()
//                        SharedManager.shared.spbListView?.cancel()
//                        
//                        
                        
                        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
                        detailsVC.channelInfo = Info
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
                
                SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    //Sub Topics API when user click on a topic
    func performTabSubTopic(_ topic: TopicData) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let id = topic.id ?? ""
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/topics/related/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do {
                let FULLResponse = try
                    JSONDecoder().decode(SubTopicDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let topics = FULLResponse.topics {
                        
                        SharedManager.shared.subTopicsList = topics
                        let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
                        vc.showArticleType = .topic
                        vc.selectedID = topic.id ?? ""
                        vc.isFav = topic.favorite ?? false
                        vc.subTopicTitle = topic.name ?? ""
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/topics/related/\(id)", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

