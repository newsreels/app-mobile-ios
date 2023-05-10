//
//  UserFollowingVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 23/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class UserFollowingVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var appLoaderView: UIView!
    @IBOutlet weak var loaderView: GMView!
    @IBOutlet weak var loaderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var seachNoDataView: UIView!
    
    var dismissKeyboard : (()-> Void)?
    var nextPaginate = ""
    var isApiRunning = false
    var channelsArray = [ChannelInfo]()
    var locationsArray = [Location]()
    var topicArray = [TopicData]()
    
    var isOnSearch = false
    var searchText = ""
    
    enum selectionType {
        case channel, place,topic
    }
    var currentSelection = selectionType.channel
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerCells()
        setupUI()
        performWSToGetUserFollowedAuthors()
        seachNoDataView.isHidden = true
    }
    
    // MARK: - Methods
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        if isOnSearch {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        }
        else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "UserFollowCC", bundle: nil), forCellReuseIdentifier: "UserFollowCC")
    }
    
    
    func openChannelDetails(index: Int) {
        
        var context = ""
        var topicTitle = ""
        
        if currentSelection == .channel {
            context = self.channelsArray[index].context ?? ""
            topicTitle = self.channelsArray[index].name ?? ""
        }
        else if currentSelection == .place {
            context = self.locationsArray[index].context ?? ""
            topicTitle = self.locationsArray[index].name ?? ""
        }
        else {
            context = self.topicArray[index].context ?? ""
            topicTitle = self.topicArray[index].name ?? ""
        }
        
        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
        detailsVC.isOpenFromReel = false
        detailsVC.delegate = self
        detailsVC.isOpenForTopics = true
        detailsVC.context = context
        detailsVC.topicTitle = topicTitle
        detailsVC.modalPresentationStyle = .fullScreen
        
        let nav = AppNavigationController(rootViewController: detailsVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    
    
}

//MARK:- AquamanChild ViewController
extension UserFollowingVC: AquamanChildViewController {
    
    func aquamanChildScrollView() -> UIScrollView {
        return tableView
    }
}


extension UserFollowingVC: UITableViewDataSource, UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentSelection == .channel {
            return channelsArray.count
        }
        else if currentSelection == .place {
            return locationsArray.count
        }
        else {
            return topicArray.count
        }
    }
    
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserFollowCC", for: indexPath) as! UserFollowCC
        
        if currentSelection == .channel {
            cell.setupCell(model: channelsArray[indexPath.row])
        }
        else if currentSelection == .place {
            cell.setupCell(model: locationsArray[indexPath.row])
        }
        else {
            cell.setupCell(model: topicArray[indexPath.row])
        }
        
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if nextPaginate.isEmpty == false, channelsArray.count > 0, isApiRunning == false, channelsArray.count - 5 >= indexPath.row {
            performWSToGetUserFollowedAuthors()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openChannelDetails(index: indexPath.row)
    }
    
}

extension UserFollowingVC: UserFollowCCDelegate {
    
    func didTapFollowing(cell: UserFollowCC) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        
        if currentSelection == .channel {
            channelsArray[indexPath.row].isShowingLoader = true
            self.tableView.reloadData()
            SharedManager.shared.performWSToUpdateUserFollow(id: [channelsArray[indexPath.row].id ?? ""], isFav: !(channelsArray[indexPath.row].favorite ?? false), type: .sources) { success in
                
                if success {
                    self.channelsArray[indexPath.row].favorite = !(self.channelsArray[indexPath.row].favorite ?? false)
                }
                else {
                    // failed
                    // don't update
                }
                self.channelsArray[indexPath.row].isShowingLoader = false
                self.tableView.reloadData()
            }
        }
        else if currentSelection == .place {
            locationsArray[indexPath.row].isShowingLoader = true
            self.tableView.reloadData()
            SharedManager.shared.performWSToUpdateUserFollow(id: [locationsArray[indexPath.row].id ?? ""], isFav: !(locationsArray[indexPath.row].favorite ?? false), type: .locations) { success in
                
                if success {
                    self.locationsArray[indexPath.row].favorite = !(self.locationsArray[indexPath.row].favorite ?? false)
                }
                else {
                    // failed
                    // don't update
                }
                self.locationsArray[indexPath.row].isShowingLoader = false
                self.tableView.reloadData()
            }
        }
        else {
            topicArray[indexPath.row].isShowingLoader = true
            self.tableView.reloadData()
            SharedManager.shared.performWSToUpdateUserFollow(id: [topicArray[indexPath.row].id ?? ""], isFav: !(topicArray[indexPath.row].favorite ?? false), type: .topics) { success in
                
                if success {
                    self.topicArray[indexPath.row].favorite = !(self.topicArray[indexPath.row].favorite ?? false)
                }
                else {
                    // failed
                    // don't update
                }
                self.topicArray[indexPath.row].isShowingLoader = false
                self.tableView.reloadData()
            }
        }
        
        
        
        
    }
}

extension UserFollowingVC {
    
    //Followed Topics
    func performWSToGetUserFollowedAuthors() {

        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        if self.nextPaginate.isEmpty {
            if isOnSearch {
                self.showCustomLoader()
            }
            else {
                self.tableView.showLoader(size: CGSize(width: 50, height: 50), backgroundColorNeeded: true)
            }
        }
        
        self.isApiRunning = true
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        var url = ""
        
        if currentSelection == .channel {
            if isOnSearch {
                url = "news/sources?query=\(searchText)"
            }
            else {
                url = "news/sources/suggested"
            }
        }
        else if currentSelection == .place {
            if isOnSearch {
                url = "news/locations?query=\(searchText)"
            }
            else {
                url = "news/locations/suggested"
            }
        }
        else if currentSelection == .topic {
            if isOnSearch {
                url = "news/topics?query=\(searchText)"
            }
            else {
                url = "news/topics/suggested"
            }
        }
        
        
        let param = ["page": nextPaginate]
        
        WebService.URLResponse(url, method: .get, parameters: param, headers: token, withSuccess: { (response) in
            
            self.hideCustomLoader()
            self.tableView.hideLoaderView()
            self.isApiRunning = false
            
            do {
                let FULLResponse = try
                    JSONDecoder().decode(userFollowDC.self, from: response)
                
                if self.currentSelection == .channel {
                    if let sources = FULLResponse.sources {
                        
                        if sources.count >= 0 {
                            self.channelsArray += sources
                        }
                        else {
                            self.channelsArray = sources
                        }
                        
                    }
                    
                    if self.isOnSearch {
                        if self.searchText != "" && self.channelsArray.count == 0 {
                            self.seachNoDataView.isHidden = false
                        }
                    }
                }
                if let locations = FULLResponse.locations {
                    
                    if locations.count >= 0 {
                        self.locationsArray += locations
                    }
                    else {
                        self.locationsArray = locations
                    }
                    
                    if self.isOnSearch {
                        if self.searchText != "" && self.locationsArray.count == 0 {
                            self.seachNoDataView.isHidden = false
                        }
                    }
                    
                }
                
                
                if let topics = FULLResponse.topics {
                    
                    if topics.count >= 0 {
                        self.topicArray += topics
                    }
                    else {
                        self.topicArray = topics
                    }
                    
                    if self.isOnSearch {
                        if self.searchText != "" && self.topicArray.count == 0 {
                            self.seachNoDataView.isHidden = false
                        }
                    }
                    
                }
                
                
                
                
                self.tableView.reloadData()
                if let meta = FULLResponse.meta {
                    self.nextPaginate = meta.next ?? ""
                }
                
            } catch let jsonerror {
                self.hideCustomLoader()
                self.tableView.hideLoaderView()
                self.isApiRunning = false
                ANLoader.hide()
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            self.hideCustomLoader()
            self.tableView.hideLoaderView()
            self.isApiRunning = false
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    
}


extension UserFollowingVC: ChannelDetailsVCDelegate {
    
    func backButtonPressedChannelDetailsVC(_ channel: ChannelInfo?) {
    }
    
    func backButtonPressedWhenFromReels(_ channel: ChannelInfo?) {
    }
    
    
}


extension UserFollowingVC {
    
    
    // MARK : - Search Methods
    func refreshVC() {
        
        self.seachNoDataView.isHidden = true
        searchText = ""
        hideCustomLoader(isAnimated: false)
        self.tableView.hideLoaderView()
        self.nextPaginate = ""
        channelsArray.removeAll()
        topicArray.removeAll()
        locationsArray.removeAll()
        self.tableView.reloadData()

    }
    
    func getSearchContent(search: String) {
        
        refreshVC()
        searchText = search
        self.performWSToGetUserFollowedAuthors()

    }
    
    
    func appEnteredBackground() {
        
        //            relevantVC?.appEnteredBackground()

        
    }
    
    
    func appLoadedToForeground() {
        //            relevantVC?.appLoadedToForeground()
    }
    
    func stopAll() {
        
        //        self.relevantVC?.updateProgressbarStatus(isPause: true)

    }
    
    
    func showCustomLoader() {
        
        self.appLoaderView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.loaderViewHeightConstraint.constant = 100
            self.view.layoutIfNeeded()
        } completion: { status in
        }
    }
    
    func hideCustomLoader(isAnimated: Bool = true) {
        
        if isAnimated {
            UIView.animate(withDuration: 0.25) {
//                self.loaderViewHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            } completion: { status in
                self.appLoaderView.isHidden = true
            }
        }
        else {
//            self.loaderViewHeightConstraint.constant = 0
            self.appLoaderView.isHidden = true
        }
        
    }
    
}
