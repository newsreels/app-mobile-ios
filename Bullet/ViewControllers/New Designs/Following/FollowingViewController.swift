//
//  FollowingViewController.swift
//  Bullet
//
//  Created by Faris Muhammed on 25/05/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class FollowingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var channelsArray = [ChannelInfo]()
    var topicsArray = [TopicData]()
    var locationsArray = [Location]()
    
    var topicSelected = true
    var locationSelecteed = true
    var channelSelected = true
    
    var topicLoading = false
    var locationLoading = false
    var channelLoading = false
    
    var firstTimeLoaded = false
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        registerCell()
        tableView.delegate = self
        tableView.dataSource = self
        
        getAllData()
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        setStatusBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setStatusBar()
        if firstTimeLoaded {
            //Reload data when come from otherScreen
            DispatchQueue.main.async { [self] in
                getAllData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setStatusBar()
        
        if firstTimeLoaded {
            //            getAllData()
            /*
             if topicsArray.count == 0 {
             performWSToGetTopics()
             }
             if channelsArray.count == 0 {
             performWSToGetChannels()
             }
             if locationsArray.count == 0 {
             performWSToGetUserFollowedLocation()
             }*/
        }
        firstTimeLoaded = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versions
            return .default
        }
    }
    
    
    func registerCell() {
        
        tableView.register(UINib(nibName: "NotFollowingAnythingTableViewCell", bundle: nil), forCellReuseIdentifier: "NotFollowingAnythingTableViewCell")
        
        tableView.register(UINib(nibName: "FollowingTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowingTableViewCell")
    }
    
    func getAllData() {
        
        performWSToGetTopics()
        performWSToGetUserFollowedLocation()
        performWSToGetChannels()
    }
    
    func setStatusBar() {
        var navVC = self.navigationController?.navigationController as? CustomNavigationController
        if navVC == nil {
            navVC = (self.navigationController as? CustomNavigationController)
        }
        navVC?.setNeedsStatusBarAppearanceUpdate()
    }
    
}


extension FollowingViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if topicsArray.count == 0 {
                topicSelected = false
            }
            return topicsArray.count
        }
        else if section == 1 {
            if locationsArray.count == 0 {
                locationSelecteed = false
            }
            return locationsArray.count
        }
        else if section == 2 {
            if channelsArray.count == 0 {
                channelSelected = false
            }
            return channelsArray.count
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingTableViewCell", for: indexPath) as! FollowingTableViewCell
        
        if indexPath.section == 0 {
            cell.setupCell(title: topicsArray.isEmpty ? "" : topicsArray[indexPath.row].name ?? "", image: topicsArray[indexPath.row].image ?? "", isFollow: topicsArray[indexPath.row].favorite ?? false, isShowingLoader: topicsArray[indexPath.row].isShowingLoader ?? false)
        }
        else if indexPath.section == 1 {
            cell.setupCell(title: locationsArray.isEmpty ? "" : locationsArray[indexPath.row].name ?? "", image: locationsArray[indexPath.row].image ?? "", isFollow: locationsArray[indexPath.row].favorite ?? false, isShowingLoader: locationsArray[indexPath.row].isShowingLoader ?? false)
        }
        else if indexPath.section == 2 {
            cell.setupCell(title: channelsArray.isEmpty ? "" : channelsArray[indexPath.row].name ?? "", image: channelsArray[indexPath.row].image ?? "", isFollow: channelsArray[indexPath.row].favorite ?? false, isShowingLoader: channelsArray[indexPath.row].isShowingLoader ?? false)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            performTabSubTopic(topicsArray[indexPath.row])
        }
        else if indexPath.section == 1{
            //Locations Details
        }
        else if indexPath.section == 2{
            //Channels Details
            self.performWSGoToChannelDetailsScreen(channelsArray[indexPath.row].id ?? "")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if topicSelected {
                return 50
            }
        }
        else if indexPath.section == 1 {
            if locationSelecteed {
                return 50
            }
        }
        else if indexPath.section == 2 {
            if channelSelected {
                return 50
            }
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 0:
            return topicsArray.isEmpty ? 0 : 40
        case 1:
            return locationsArray.isEmpty ?  0 : 40
        case 2:
            return channelsArray.isEmpty ?  0 : 40
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = FollowingHeaderView()
        if section == 0 {
            headerView.setupTitle(title: topicsArray.isEmpty ? "" : "Topics", isSelected: topicSelected, isLoadedShowing: topicLoading)
        }
        else if section == 1 {
            headerView.setupTitle(title: locationsArray.isEmpty ? "" : "Locations", isSelected: locationSelecteed, isLoadedShowing: locationLoading)
        }
        else if section == 2 {
            headerView.setupTitle(title: channelsArray.isEmpty ? "" : "Channels", isSelected: channelSelected, isLoadedShowing: channelLoading)
        }
        
        headerView.delegate = self
        headerView.tag = section
        //        headerView.backgroundColor = .red
        return headerView
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            if indexPath.section == 0 {
                
                followUnfollowTopics(indexPath: indexPath, isFollow: false, isBackground: true)
            }
            else if indexPath.section == 1 {
                followUnfollowLocations(indexPath: indexPath, isFollow: false, isBackground: true)
            }
            else if indexPath.section == 2 {
                followUnfollowChannels(indexPath: indexPath, isFollow: false, isBackground: true)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unfollow"
    }
    
}

extension FollowingViewController: FollowingTableViewCellDelegate {
    
    func didTapFollow(cell: FollowingTableViewCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        if indexPath.section == 0 {
            
            followUnfollowTopics(indexPath: indexPath, isFollow: !(self.topicsArray[indexPath.row].favorite ?? false),  isBackground: false)
        }
        else if indexPath.section == 1 {
            followUnfollowLocations(indexPath: indexPath, isFollow: !(self.locationsArray[indexPath.row].favorite ?? false),  isBackground: false)
        }
        else if indexPath.section == 2 {
            followUnfollowChannels(indexPath: indexPath, isFollow: !(self.channelsArray[indexPath.row].favorite ?? false), isBackground: false)
        }
        
        
    }
    
    
    func followUnfollowTopics(indexPath: IndexPath, isFollow: Bool, isBackground: Bool) {
        
        if isBackground {
            SharedManager.shared.performWSToUpdateUserFollow(id: [topicsArray[indexPath.row].id ?? ""], isFav: isFollow, type: .topics) { status in
            }
            self.topicsArray.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .middle)
            tableView.endUpdates()
            
            if self.topicsArray.count == 0 {
                self.performWSToGetTopics()
            }
            
            return
        }
        
        self.topicsArray[indexPath.row].isShowingLoader = true
        tableView.reloadRows(at: [indexPath], with: .none)
        SharedManager.shared.performWSToUpdateUserFollow(id: [topicsArray[indexPath.row].id ?? ""], isFav: isFollow, type: .topics) { status in
            self.topicsArray[indexPath.row].isShowingLoader = false
            if status {
                self.topicsArray[indexPath.row].favorite = isFollow
            }
            
            /*
             if self.topicsArray[indexPath.row].favorite == false {
             self.topicsArray.remove(at: indexPath.row)
             self.tableView.reloadData()
             }
             else {
             self.tableView.reloadRows(at: [indexPath], with: .none)
             }
             
             if self.topicsArray.count == 0 {
             self.performWSToGetTopics()
             }
             */
            
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
    }
    
    func followUnfollowLocations(indexPath: IndexPath, isFollow: Bool, isBackground: Bool) {
        
        if isBackground {
            SharedManager.shared.performWSToUpdateUserFollow(id: [locationsArray[indexPath.row].id ?? ""], isFav: isFollow, type: .locations) { status in
            }
            self.locationsArray.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .middle)
            tableView.endUpdates()
            
            if self.locationsArray.count == 0 {
                self.performWSToGetUserFollowedLocation()
            }
            
            return
        }
        
        self.locationsArray[indexPath.row].isShowingLoader = true
        tableView.reloadRows(at: [indexPath], with: .none)
        SharedManager.shared.performWSToUpdateUserFollow(id: [locationsArray[indexPath.row].id ?? ""], isFav: isFollow, type: .locations) { status in
            self.locationsArray[indexPath.row].isShowingLoader = false
            if status {
                self.locationsArray[indexPath.row].favorite = isFollow
            }
            
            /*
             if self.locationsArray[indexPath.row].favorite == false {
             self.locationsArray.remove(at: indexPath.row)
             self.tableView.reloadData()
             }
             else {
             self.tableView.reloadRows(at: [indexPath], with: .none)
             }
             
             if self.locationsArray.count == 0 {
             self.performWSToGetUserFollowedLocation()
             }
             */
            
            self.tableView.reloadRows(at: [indexPath], with: .none)
            
        }
    }
    
    func followUnfollowChannels(indexPath: IndexPath, isFollow: Bool, isBackground: Bool) {
        
        if isBackground {
            SharedManager.shared.performWSToUpdateUserFollow(id: [channelsArray[indexPath.row].id ?? ""], isFav: isFollow, type: .sources) { status in
            }
            self.channelsArray.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .middle)
            tableView.endUpdates()
            
            if self.channelsArray.count == 0 {
                self.performWSToGetChannels()
            }
            
            return
        }
        
        self.channelsArray[indexPath.row].isShowingLoader = true
        tableView.reloadRows(at: [indexPath], with: .none)
        SharedManager.shared.performWSToUpdateUserFollow(id: [channelsArray[indexPath.row].id ?? ""], isFav: isFollow, type: .sources) { status in
            self.channelsArray[indexPath.row].isShowingLoader = false
            if status {
                self.channelsArray[indexPath.row].favorite = isFollow
            }
            
            /*
             if self.channelsArray[indexPath.row].favorite == false {
             self.channelsArray.remove(at: indexPath.row)
             self.tableView.reloadData()
             }
             else {
             self.tableView.reloadRows(at: [indexPath], with: .none)
             }
             
             if self.channelsArray.count == 0 {
             self.performWSToGetChannels()
             }*/
            self.tableView.reloadRows(at: [indexPath], with: .none)
            
        }
    }
}

extension FollowingViewController: FollowingHeaderViewDelegate {
    
    func didTapHeader(header: FollowingHeaderView) {
        
        let section = header.tag
        
        if section == 0 {
            topicSelected = !topicSelected
            header.animateHeader(isSelected: topicSelected)
        }
        else if section == 1 {
            locationSelecteed = !locationSelecteed
            header.animateHeader(isSelected: locationSelecteed)
        }
        else if section == 2 {
            channelSelected =  !channelSelected
            header.animateHeader(isSelected: channelSelected)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            self.tableView.reloadSections([section], with: .automatic)
            self.tableView.layoutIfNeeded()
        })
        
    }
}



// MARK: - Webservices
extension FollowingViewController {
    
    func displayEmptyFollowing() {

        if topicLoading == false && locationLoading == false && channelLoading == false {
            if self.channelsArray.isEmpty && self.locationsArray.isEmpty && self.topicsArray.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.tableView.isHidden = true
                }
            } else {
                self.tableView.isHidden = false
            }
        }
        
    }
    
    func performWSToGetTopics() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.topicLoading = true
        self.tableView.reloadData()
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/topics/followed", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.topicLoading = false
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            do {
                let FULLResponse = try
                JSONDecoder().decode(TopicDC.self, from: response)
                
                
                
                if let topics = FULLResponse.topics {
                    
                    self.topicsArray = topics.filter({$0.favorite == true})
                    //                    self.topicsArray.append(TopicData())
                    if topics.count > 0 {
                        self.topicSelected = true
                    }
                    else {
                        self.performWSToGetSuggestedTopics()
                    }
                    
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let jsonerror {
                self.topicLoading = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            self.displayEmptyFollowing()
        }) { (error) in
            
            self.topicLoading = false
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            print("error parsing json objects",error)
            self.displayEmptyFollowing()
            
        }
    }
    
    //Followed Locations
    func performWSToGetUserFollowedLocation() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.locationLoading = true
        self.tableView.reloadData()
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/locations/followed", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.locationLoading = false
            self.tableView.reloadData()
            
            do{
                let FULLResponse = try
                JSONDecoder().decode(locationsDC.self, from: response)
                
                // Get locations data for next page
                if let locations = FULLResponse.locations {
                    
                    self.locationsArray = locations.filter({$0.favorite == true})
                    
                    if self.locationsArray.count > 0 {
                        // Add other item
                        //                        self.locationsArray.append(Location())
                        self.locationSelecteed = true
                    }
                    else {
                        self.performWSToGetSuggestedLocations()
                    }
                }
                
                self.hideLoaderVC()
                self.tableView.reloadData()
                
            } catch let jsonerror {
                
                self.locationLoading = false
                self.tableView.reloadData()
                print("error parsing json objects",jsonerror)
                
            }
            self.displayEmptyFollowing()
            
            
        }) { (error) in
            
            self.locationLoading = false
            self.tableView.reloadData()
            print("error parsing json objects",error)
            
            self.displayEmptyFollowing()
            
        }
    }
    
    func performWSToGetSuggestedLocations() {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        self.locationLoading = true
        self.tableView.reloadData()
        
        WebService.URLResponse("news/locations/suggested", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            self.locationLoading = false
            self.tableView.reloadData()
            
            do{
                let FULLResponse = try
                JSONDecoder().decode(locationsDC.self, from: response)
                
                
                DispatchQueue.main.async {
                    
                    if let locations = FULLResponse.locations {
                        
                        self.locationsArray = locations.filter({$0.favorite == true})
                        
                        if self.locationsArray.count > 0 {
                            self.locationSelecteed = true
                        }
                        // Add other item
                        //                        self.locationsArray.append(Location())
                    }
                    
                    self.tableView.reloadData()
                    
                }
                self.displayEmptyFollowing()
                
            } catch let jsonerror {
                
                self.locationLoading = false
                self.tableView.reloadData()
//                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/topics/suggested", error: jsonerror.localizedDescription, code: "")
                self.displayEmptyFollowing()
                
            }
            
            
        }) { (error) in
            self.locationLoading = false
            self.tableView.reloadData()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetSuggestedTopics() {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        self.topicLoading = true
        self.tableView.reloadData()
        
        WebService.URLResponse("news/topics/suggested", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.topicLoading = false
            self.tableView.reloadData()
            
            do{
                let FULLResponse = try
                JSONDecoder().decode(TopicDC.self, from: response)
                
                
                DispatchQueue.main.async {
                    
                    if let topics = FULLResponse.topics, topics.count > 0 {
                        // Add other item
                        self.topicsArray = topics.filter({$0.favorite == true})
                        //                        self.topicsArray.append(TopicData())
                        self.topicSelected = true
                        
                    }
                    self.tableView.reloadData()
                    
                }
                
            } catch let jsonerror {
                
                self.topicLoading = false
                self.tableView.reloadData()
//                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/topics/suggested", error: jsonerror.localizedDescription, code: "")
                
                //                if self.channelsArray.isEmpty && self.locationsArray.isEmpty && self.topicsArray.isEmpty {
                //                    self.tableView.isHidden = true
                //                } else {
                //                    self.tableView.isHidden = false
                //                }
            }
            self.displayEmptyFollowing()
            
            
        }) { (error) in
            self.topicLoading = false
            self.tableView.reloadData()
            print("error parsing json objects",error)
            self.displayEmptyFollowing()
            
        }
    }
    
    func performWSToGetChannels() {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        //         self.showCustomLoader()
        
        self.channelLoading = true
        self.tableView.reloadData()
        
        WebService.URLResponse("news/sources/followed", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.channelLoading = false
            self.tableView.reloadData()
            
            do{
                let FULLResponse = try
                JSONDecoder().decode(sourcesDC.self, from: response)
                
                if let suggested = FULLResponse.sources {
                    
                    self.channelsArray = suggested.filter({$0.favorite == true})
                    
                    if self.channelsArray.count == 0 {
                        self.performWSToGetSuggestedChannels()
                    }
                    else {
                        self.channelSelected = true
                    }
                    self.tableView.reloadData()
                }
                
                
            } catch let jsonerror {
                
                self.channelLoading = false
                self.tableView.reloadData()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/reels/suggested", error: jsonerror.localizedDescription, code: "")
                
            }
            
            self.displayEmptyFollowing()
            
            
        }) { (error) in
            
            self.channelLoading = false
            self.tableView.reloadData()
            print("error parsing json objects",error)
            self.displayEmptyFollowing()
            
        }
    }
    
    func performWSToGetSuggestedChannels() {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        //         self.showCustomLoader()
        
        self.channelLoading = true
        self.tableView.reloadData()
        
        WebService.URLResponse("news/sources/suggested", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.channelLoading = false
            self.tableView.reloadData()
            
            do{
                let FULLResponse = try
                JSONDecoder().decode(sourcesDC.self, from: response)
                
                if let suggested = FULLResponse.sources {
                    
                    self.channelsArray = suggested.filter({$0.favorite == true})
                    if self.channelsArray.count > 0 {
                        self.channelSelected = true
                    }
                    self.tableView.reloadData()
                }
                
                
            } catch let jsonerror {
                
                self.channelLoading = false
                self.tableView.reloadData()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/reels/suggested", error: jsonerror.localizedDescription, code: "")
                
            }
            self.displayEmptyFollowing()
            
        }) { (error) in
            
            self.channelLoading = false
            self.tableView.reloadData()
            print("error parsing json objects",error)
            self.displayEmptyFollowing()
            
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
                        
                        SharedManager.shared.subTopicsList = topics
                        
                        let vc = ArticlesVC.instantiate(fromAppStoryboard: .Main)
                        vc.fromDiscover = true
                        vc.fromFollowing = true
                        vc.contextID = topic.context
                        vc.categoryTitleString = topic.name ?? ""
                        let navVC = AppNavigationController(rootViewController: vc)
                        navVC.modalPresentationStyle = .fullScreen
                        //                        self.navigationController?.pushViewController(vc, animated: true)
                        self.present(navVC, animated: true, completion: nil)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/topics/related/\(id)", error: jsonerror.localizedDescription, code: "")
//                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                self.displayEmptyFollowing()
            }
            
        }) { (error) in
            
            //SharedManager.shared.showAPIFailureAlert()
            ANLoader.hide()
            print("error parsing json objects",error)
            self.displayEmptyFollowing()
        }
    }
    
    func performWSGoToChannelDetailsScreen(_ id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading()
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
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}


