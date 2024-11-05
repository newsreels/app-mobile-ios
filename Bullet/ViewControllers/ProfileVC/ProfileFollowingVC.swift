//
//  ProfileFollowingVC.swift
//  Bullet
//
//  Created by Mahesh on 13/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class Following: NSObject {
    
    var topic: [TopicData]?
    var source: [ChannelInfo]?
    
    init(topic: [TopicData]?, source: [ChannelInfo]?) {
        
        self.topic = topic
        self.source = source
    }
}


class ProfileFollowingVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var followedArray = [Following]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(MyHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MyHeader")
        collectionView.alwaysBounceVertical = true

        self.getRefreshAllData()
    }

    func getRefreshAllData() {
     
        followedArray = [Following]()
        performUserTopics()
    }

}

extension ProfileFollowingVC {
    
    func performUserTopics() {

        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/topics/followed", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do {
                let FULLResponse = try
                    JSONDecoder().decode(TopicDC.self, from: response)
                
                if let topics = FULLResponse.topics {
                    
                    if topics.count > 0 {
                        self.followedArray.append(Following(topic: topics, source: nil))
                    }
                    self.performUserSources()
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/topics/followed", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            //SharedManager.shared.showAPIFailureAlert()
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUserFollowTopics(_ id: String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.followTopic, topics_id: id)

        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["topics": "\(id)"]
        
        //ANLoader.showLoading(disableUI: true)
        WebService.URLResponse("news/topics/follow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            //ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateTopicDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    print("added topic SUCCESSFULLY...")

                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/topics/follow", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            //SharedManager.shared.showAPIFailureAlert()
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performTabUserTopicUnfollow(_ id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["topics": "\(id)"]
        
        //ANLoader.showLoading(disableUI: true)
        
        WebService.URLResponse("news/topics/unfollow", method: .post, parameters: params, headers: token, withSuccess: { (response) in

            //ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(DeleteTopicDC.self, from: response)
                
                if let status = FULLResponse.message {
                    
                    let message = status
                    if status.uppercased() == Constant.STATUS_SUCCESS {
                        
                        print("Deleted topic SUCCESSFULLY...")
                        
                        SharedManager.shared.isTabReload = true
                        SharedManager.shared.isDiscoverTabReload = true
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: message)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/topics/unfollow", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            //SharedManager.shared.showAPIFailureAlert()
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
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
                        
                     //   topics.insert(topic, at: 0)
                        SharedManager.shared.subTopicsList = topics
//                        SharedManager.shared.articleSearchModeType = ""
                        
                        let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
                        vc.isOpenFromCustomBulletDetails = true
                        vc.showArticleType = .topic
                        vc.selectedID = topic.id ?? ""
                        vc.isFav = topic.favorite ?? false
                        vc.subTopicTitle = topic.name ?? ""
                        vc.modalPresentationStyle = .overFullScreen
                        self.navigationController?.pushViewController(vc, animated: true)
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
    
    func performBlockTopic(_ id: String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockTopic, eventDescription: "", source_id: id)

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["topics": "\(id)"]
        
        WebService.URLResponse("news/topics/block", method: .post, parameters: params, headers: token, withSuccess: { (response) in

            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(BlockTopicDC.self, from: response)
                
                if let status = FULLResponse.message {
                    
                    let message = status
                    if status.uppercased() == Constant.STATUS_SUCCESS {
                        
                        self.getRefreshAllData()
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: message)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/topics/block", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in

            //SharedManager.shared.showAPIFailureAlert()
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    
    func performUserSources() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/followed", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let source = FULLResponse.sources {
                        
                        if source.count > 0 {
                            self.followedArray.append(Following(topic: nil, source: source))
                        }
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.collectionView.collectionViewLayout.invalidateLayout()
                        }
                        ANLoader.hide()
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/followed", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToFollowSources(_ id: String, indexPath: IndexPath = IndexPath(row: 0, section: 0)) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.followSource, channel_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        //ANLoader.showLoading(disableUI: true)
        let params = ["sources": "\(id)"]

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/follow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateSourceDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    
                    print("added source SUCCESSFULLY...")
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/follow", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performUnFollowUserSource(_ id: String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedSource, channel_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
                
        //ANLoader.showLoading(disableUI: true)
        WebService.URLResponse("news/sources/unfollow", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    if status == Constant.STATUS_SUCCESS {
                        
                        print("Deleted SOURCE SUCCESSFULLY...")
                        SharedManager.shared.isTabReload = true
                        SharedManager.shared.isDiscoverTabReload = true
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/unfollow", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performBlockSource(_ id: String) {
        
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockSource, eventDescription: "", source_id: id)

        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        
        ANLoader.showLoading(disableUI: true)
        WebService.URLResponse("news/sources/block", method: .post, parameters: params, headers: token, withSuccess: { (response) in

            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(BlockTopicDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    if status == Constant.STATUS_SUCCESS {
                        
                        SharedManager.shared.isTabReload = true
                        SharedManager.shared.isDiscoverTabReload = true
                        print("block SOURCE SUCCESSFULLY...")
                        self.getRefreshAllData()
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/block", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in

            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performTabSubSource(_ source: ChannelInfo) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let id = source.id ?? ""
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/data/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in

            ANLoader.hide()
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
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

extension ProfileFollowingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return followedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        if let topic = followedArray[section].topic {
            return topic.count
        }
        else if let source = followedArray[section].source {
            return source.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        //Followed topic
        if let topics = followedArray[indexPath.section].topic {

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchTopicCell", for: indexPath) as? searchTopicCell else { return UICollectionViewCell() }
            cell.layoutIfNeeded()
            
            let topic = topics[indexPath.row]
            cell.lblTitle.text = topic.name
            
            cell.imgTopic.sd_setImage(with: URL(string: topic.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            
            cell.btnMore.accessibilityIdentifier = String(indexPath.section)
            cell.btnMore.tag = indexPath.row
            cell.btnMore.addTarget(self, action: #selector(didTapMoreTopicAction), for: .touchUpInside)
            
            cell.btnSelectTopic.accessibilityIdentifier = String(indexPath.section)
            cell.btnSelectTopic.tag = indexPath.row
            cell.btnSelectTopic.addTarget(self, action: #selector(didTapAddOrRemoveTopic), for: .touchUpInside)
            
            if topic.favorite == true {
                
                cell.imgTopicStatus.theme_image = GlobalPicker.imgBookmarkSelected
                //cell.imgTopicStatus.theme_image = GlobalPicker.imgBookmarkSelected
                cell.btnMore.isHidden = false
                cell.imgMore.isHidden = false
            }
            else {
                
                cell.imgTopicStatus.image = UIImage(named: "bookmark")
                //cell.imgTopicStatus.theme_image = GlobalPicker.imgBookmark
                cell.btnMore.isHidden = true
                cell.imgMore.isHidden = true
            }
            
            return cell
        }

        if let sources = followedArray[indexPath.section].source {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchChannelCC", for: indexPath) as? searchChannelCC else { return UICollectionViewCell() }
            cell.layoutIfNeeded()

            let source = sources[indexPath.row]

            //followed sources
            cell.imgSource.sd_setImage(with: URL(string: source.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            //cell.imgSource.layer.cornerRadius = cell.imgSource.frame.size.width / 2
            cell.lblTitle.text = source.name ?? ""
            cell.imgSource.cornerRadius = cell.imgSource.frame.size.width / 2
            cell.viewBG.theme_backgroundColor = GlobalPicker.cellBGColor
            cell.viewBG.addRoundedShadow(0.4)
            cell.lblTitle.theme_textColor = GlobalPicker.textColor
            
//            if source.favorite == true {
//
//                cell.imgSourceStatus.theme_image = GlobalPicker.imgBookmarkSelected
//                //cell.imgSourceStatus.theme_image = GlobalPicker.imgBookmarkSelected
//                cell.imgMore.isHidden = false
//                cell.btnMore.isHidden = false
//            }
//            else {
//
//                cell.imgSourceStatus.image = UIImage(named: "bookmark")
//                //cell.imgSourceStatus.theme_image = GlobalPicker.imgBookmark
//                cell.imgMore.isHidden = true
//                cell.btnMore.isHidden = true
//            }
//
//            if let lang = source.language {
//                cell.lblLanguage.text = lang.isEmpty ? "N/A" : lang
//            }
//            else {
//                cell.lblLanguage.text = "N/A"
//            }
//
//            if let global = source.category {
//
//                cell.lblLocation.text = global.isEmpty ? "N/A" : global
//            }
//            else {
//
//                cell.lblLocation.text = "N/A"
//            }
            
            //cell.imgMore.theme_image = GlobalPicker.imgDot
//            cell.viewShadow.theme_backgroundColor = GlobalPicker.cellBGColor
//            cell.viewShadow.addRoundedShadowWithColor(color: UIColor(displayP3Red: 58.0/255.0, green: 217.0/255.0, blue: 210.0/255.0, alpha: 0.50))
            
         //   cell.lblTitle.theme_textColor = GlobalPicker.textColor
            
//            cell.btnSelectSource.accessibilityIdentifier = String(indexPath.section)
//            cell.btnSelectSource.tag = indexPath.row
//            cell.btnSelectSource.addTarget(self, action: #selector(didTapAddRemoveAction), for: .touchUpInside)
            
            cell.btnMore.accessibilityIdentifier = String(indexPath.section)
            cell.btnMore.tag = indexPath.row
            cell.btnMore.addTarget(self, action: #selector(didTapCellMoreAction), for: .touchUpInside)
            
            return cell
        }
        
        return UICollectionViewCell.init()
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//        if (kind == UICollectionView.elementKindSectionHeader) {
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sourceHeaderCollectionReusableView", for: indexPath) as! sourceHeaderCollectionReusableView
//            header.lblTitle.text = NSLocalizedString(indexPath.section == 0 ? "Your Topics" : "Your Channels", comment: "")
//            header.lblTitle.sizeToFit()
//            //header.lblTitle.layer.borderWidth = 1
//            //header.lblTitle.layer.borderColor = UIColor.red.cgColor
//            return header
//        }
//        else {
//            return UICollectionReusableView(frame: .zero)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//
//        return CGSize(width: collectionView.frame.size.width, height: 50.0)
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MyHeader", for: indexPath) as! MyHeader
        
        if let _ = self.followedArray[indexPath.section].topic {
            header.configure(NSLocalizedString("Topics", comment: ""))
        }
        else if let _ = self.followedArray[indexPath.section].source {
            header.configure(NSLocalizedString("Channels", comment: ""))
        }
        
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if self.followedArray.count == 0 {
            return CGSize(width: collectionView.frame.width, height: 0)
        }
        return CGSize(width: collectionView.frame.width, height: 50)
     }
    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let _ = followedArray[indexPath.section].topic {
            return CGSize(width: (collectionView.frame.size.width / 2), height: (collectionView.frame.size.width / 2) - 50 )
        }
        else {
            return CGSize(width: (collectionView.frame.size.width / 2), height: (collectionView.frame.size.width / 2) + 5)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.sourceOpen, eventDescription: "")

        if let topics = followedArray[indexPath.section].topic {
            performTabSubTopic(topics[indexPath.row])
        }
        else if let sources = followedArray[indexPath.section].source {
            performTabSubSource(sources[indexPath.row])
        }
    }
    

//    //VERTICAL
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return 0 }
//
//    //HORIZONTAL
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return 0 }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
    
    //MARK:- BUTTON CELL ACTION
    @objc func didTapAddOrRemoveTopic(_ buttton: UIButton) {
        
        let section = Int(buttton.accessibilityIdentifier ?? "0")!
        let row = buttton.tag
        var item = TopicData()
        
        if var top = self.followedArray[section].topic {
            
            item = top[row]
            top[row] = TopicData(id: item.id, name: item.name, icon: item.icon, link: item.link, image: item.image, color: item.color, favorite: !(item.favorite ?? false))
            self.followedArray[section].topic = top
            self.collectionView.reloadItems(at: [IndexPath(row: row, section: section)])
        }
        
        if let isExistFav = item.favorite {
            if isExistFav {

                //delete favorite topic from list API
                performTabUserTopicUnfollow(item.id ?? "")
            }
            else {

                //Add favorite topic from list API
                performWSToUserFollowTopics(item.id ?? "")
            }
        }
    }
    
    @objc func didTapMoreTopicAction(_ buttton: UIButton) {
        
        let section = Int(buttton.accessibilityIdentifier ?? "0")!
        let row = buttton.tag
        var topic = TopicData()
                
        if let top = self.followedArray[section].topic {

            topic = top[row]
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action2 = UIAlertAction(title: NSLocalizedString("Block Topic", comment: ""), style: .default) { (action) in
            //print("\(action.title)")
            let vc = BlockAlertVC.instantiate(fromAppStoryboard: .Main)
            vc.delegate = self
            vc.isFromBlock = "topic"
            vc.name = topic.name ?? ""
            vc.id = topic.id ?? ""
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive) { (action) in
            
            //print("\(action.title)")
        }
        cancel.setValue(MyThemes.current == .dark ? "#FFFFFF".hexStringToUIColor() : "#3D485F".hexStringToUIColor(), forKey: "titleTextColor")
        
        
        let image2 = UIImage(named: MyThemes.current == .dark ? "icn_block_light" : "icn_block_dark")
        action2.setValue(image2?.withRenderingMode(.alwaysOriginal), forKey: "image")
        alertController.addAction(action2)
        
        alertController.addAction(cancel)
        
        alertController.view.cornerRadius = 10
        //  alertController.view.tintColor = "#F07057".hexStringToUIColor()
        alertController.view.tintColor = MyThemes.current == .dark ? "#FFFFFF".hexStringToUIColor() : "#3D485F".hexStringToUIColor()
        alertController.view.theme_backgroundColor = GlobalPicker.backgroundColor
        
        self.present(alertController, animated: true) {
            
            //Outside Tap to hide AlertView
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
        
        if let visualEffectView = alertController.view.searchVisualEffectsSubview() {
            visualEffectView.theme_effect = GlobalPicker.visualAlertThemePicker
        }
    }
    
    @objc func alertControllerBackgroundTapped() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //source action
    @objc func didTapAddRemoveAction(_ buttton: UIButton) {

        let section = Int(buttton.accessibilityIdentifier ?? "0")!
        let row = buttton.tag
        var dictSource: ChannelInfo?

        if var sourcesArray = self.followedArray[section].source {

            dictSource = sourcesArray[row]
            sourcesArray[row].favorite = !(dictSource?.favorite ?? false)
            self.followedArray[section].source = sourcesArray
            self.collectionView.reloadItems(at: [IndexPath(row: row, section: section)])
        }
        
        if let isFav = dictSource?.favorite {
            if isFav {
                self.performUnFollowUserSource(dictSource?.id ?? "")
            }
            else {
                self.performWSToFollowSources(dictSource?.id ?? "")
            }
        }
    }
    
    @objc func didTapCellMoreAction(_ buttton: UIButton) {

        let section = Int(buttton.accessibilityIdentifier ?? "0")!
        let row = buttton.tag
        var dictSource: ChannelInfo?

        if let sources = self.followedArray[section].source {
            dictSource = sources[row]
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //to change font of title and message.
        _ = [NSAttributedString.Key.font: Constant.font.font_SemiBold]

        let action2 = UIAlertAction(title: NSLocalizedString("Block Source", comment: ""), style: .default) { (action) in
            //print("\(action.title)")
            let vc = BlockAlertVC.instantiate(fromAppStoryboard: .Main)
            vc.delegate = self
            vc.isFromBlock = "source"
            vc.name = dictSource?.name ?? ""
            vc.id = dictSource?.id ?? ""
            self.navigationController?.present(vc, animated: true, completion: nil)
        }

        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive) { (action) in

            //print("\(action.title)")
        }
        cancel.setValue(MyThemes.current == .dark ? "#FFFFFF".hexStringToUIColor() : "#3D485F".hexStringToUIColor(), forKey: "titleTextColor")


        let image2 = UIImage(named: MyThemes.current == .dark ? "icn_block_light" : "icn_block_dark")
        action2.setValue(image2?.withRenderingMode(.alwaysOriginal), forKey: "image")
        alertController.addAction(action2)

        alertController.addAction(cancel)

        alertController.view.cornerRadius = 10
      //  alertController.view.tintColor = "#F07057".hexStringToUIColor()
        alertController.view.tintColor = MyThemes.current == .dark ? "#FFFFFF".hexStringToUIColor() : "#3D485F".hexStringToUIColor()
        alertController.view.theme_backgroundColor = GlobalPicker.backgroundColor

        //present(alertController, animated: true, completion: nil)
        self.present(alertController, animated: true) {

            //Outside Tap to hide AlertView
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }

        if let visualEffectView = alertController.view.searchVisualEffectsSubview() {
            visualEffectView.theme_effect = GlobalPicker.visualAlertThemePicker
        }
    }
    
}

//MARK:- BlockAlertVC Delegate
extension ProfileFollowingVC: BlockAlertVCDelegate {
    
    func delegateBlockAlertVCBlockForId(_ id: String, isFrom: String) {
        
        //print("\(action.title)")
        if isFrom.lowercased() == "topic" {
            
            self.performBlockTopic(id)
        }
        else {
            
            self.performBlockSource(id)
        }
    }
}

//MARK:- AquamanChild ViewController
extension ProfileFollowingVC: AquamanChildViewController {
    
    func aquamanChildScrollView() -> UIScrollView {
        return collectionView
    }
}

