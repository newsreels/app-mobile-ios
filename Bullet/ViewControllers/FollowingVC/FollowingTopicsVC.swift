//
//  FollowingTopicsVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 13/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class FollowingTopicsVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewBG: UIView!

    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewTopics: UIView!
    @IBOutlet weak var viewSuggestions: UIView!
    @IBOutlet var underLineViews: [UIView]!
    
    @IBOutlet weak var lblFollowings: UILabel!
    @IBOutlet weak var lblSuggestions: UILabel!
    
    @IBOutlet weak var clvFollowingTopics: UICollectionView!
    @IBOutlet weak var clvSuggestedTopics: UICollectionView!
    
    @IBOutlet weak var constraintSuggestedClvHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintFollowingsClvHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintFollowingsViewTop: NSLayoutConstraint!
    
    var arrFollowingTopics: [TopicData]?
    var arrSuggestedTopics: [TopicData]?
    
    var followingViewHeight: CGFloat = 152
  //  var cellColors = ["E01335","5025E1","975D1B","E13300","641E58","83A52C","1E3264", "850000", "15B9C5"]

    //PAGINATION VARIABLES
    var nextPaginate = ""
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        viewBG.theme_backgroundColor = GlobalPicker.backgroundColor
        
        lblTitle.textColor = .white
        lblFollowings.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblSuggestions.theme_textColor = GlobalPicker.backgroundColorBlackWhite

        viewTopics.theme_backgroundColor = GlobalPicker.followingCardColor
        viewSuggestions.theme_backgroundColor = GlobalPicker.followingCardColor
        
        underLineViews.forEach {
            $0.theme_backgroundColor = GlobalPicker.viewLineBGColor
        }
        
        //SearchView
        viewSearch.theme_backgroundColor = GlobalPicker.followingSearchBGColor
        txtSearch.delegate = self
        txtSearch.theme_placeholderAttributes = GlobalPicker.textPlaceHolderDiscover
        txtSearch.theme_tintColor = GlobalPicker.searchTintColor
        txtSearch.theme_textColor = GlobalPicker.textColor
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        registerCell()

        lblTitle.text = NSLocalizedString("Topics", comment: "")
        lblFollowings.text = NSLocalizedString("Following", comment: "")
        lblSuggestions.text = NSLocalizedString("Suggestions", comment: "")
        
        txtSearch.placeholder = NSLocalizedString("Search", comment: "")
        
        SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let search = self.txtSearch.text, search.count > 0 {
            
            nextPaginate = ""
            performWSToSearchTopics(search)
        }
        else {
          
            performWSToGetUserFollowedTopics()
            performWSToGetSuggestedTopics()
            
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                
                self.lblFollowings.semanticContentAttribute = .forceRightToLeft
                self.lblFollowings.textAlignment = .right
                
                self.lblSuggestions.semanticContentAttribute = .forceRightToLeft
                self.lblSuggestions.textAlignment = .right
                
                self.txtSearch.semanticContentAttribute = .forceRightToLeft
                self.txtSearch.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                
                self.lblFollowings.semanticContentAttribute = .forceLeftToRight
                self.lblFollowings.textAlignment = .left
                
                self.lblSuggestions.semanticContentAttribute = .forceLeftToRight
                self.lblSuggestions.textAlignment = .left
                
                self.txtSearch.semanticContentAttribute = .forceLeftToRight
                self.txtSearch.textAlignment = .left
                
            }
        }
    }
    
    
    func registerCell() {
        
        clvFollowingTopics.register(UINib(nibName: "OnboardingTopicsCC", bundle: nil), forCellWithReuseIdentifier: "OnboardingTopicsCC")
        clvSuggestedTopics.register(UINib(nibName: "OnboardingTopicsCC", bundle: nil), forCellWithReuseIdentifier: "OnboardingTopicsCC")
    }
    
    //Buttons action
    @IBAction func didTapBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - TextField and Search
extension FollowingTopicsVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {
       
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getTextOnStopTyping), object: textField)
        if let searchText = textField.text, !(searchText.isEmpty) {
            
            nextPaginate = ""
            updateView(isSearching: true)
            self.perform(#selector(getTextOnStopTyping), with: textField, afterDelay: 0.5)
        }
        else {
            
            nextPaginate = ""
            updateView(isSearching: false)
            arrSuggestedTopics?.removeAll()
            performWSToGetUserFollowedTopics()
            performWSToGetSuggestedTopics()
        }
    }
    
    @objc func getTextOnStopTyping(_ textField: UITextField) {
        
        performWSToSearchTopics(textField.text ?? "")
    }
    
    func updateView(isSearching: Bool) {
        
        UIView.animate(withDuration: 3.0, delay: 0, options: .curveEaseIn, animations: { [self] in
            
            if isSearching {
    
                lblSuggestions.text = "Search results"
                self.constraintFollowingsClvHeight.constant = 0
                self.constraintFollowingsViewTop.constant = 0
            } else{
                
                lblSuggestions.text = "Suggestions"
                self.viewTopics.isHidden = false
                self.constraintFollowingsClvHeight.constant = followingViewHeight
                self.constraintFollowingsViewTop.constant = 30
            }
            self.clvFollowingTopics.layoutIfNeeded()
        }) { _ in
            
            if isSearching {
    
                self.viewTopics.isHidden = true
                
            } else{
            }
        }
    }
}

//MARK: - CollectionView Delegates and dataSources
extension FollowingTopicsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == clvFollowingTopics {
            
            //Followed CollectionView
            return arrFollowingTopics?.count ?? 0
        }
        else if collectionView == clvSuggestedTopics {
            
            //Suggestions CollectionView
            return arrSuggestedTopics?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == clvFollowingTopics {
            
            //Followed CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingTopicsCC", for: indexPath) as! OnboardingTopicsCC
//
//            cell.btnFav.tag = indexPath.row
//            cell.btnFav.addTarget(self, action: #selector(didTapFollowingTopicsFavButton), for: .touchUpInside)
//            if let Topic = arrFollowingTopics?[indexPath.row] {
//
//                cell.setupTopicCell(topic: Topic)
//            }
//            return cell
            
            if let topic = arrFollowingTopics?[indexPath.row] {
                cell.setUpReelsTopicsCells(topic: topic)
           //     cell.viewBG.backgroundColor = cellColors[indexPath.row % cellColors.count].hexStringToUIColor()
                cell.restorationIdentifier = "topics"
                cell.delegate = self
            }
            cell.activityLoader.stopAnimating()
            return cell

        }
        else if collectionView == clvSuggestedTopics {
            
            //Suggestions CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingTopicsCC", for: indexPath) as! OnboardingTopicsCC
//            cell.btnFav.tag = indexPath.row
//            cell.btnFav.addTarget(self, action: #selector(didTapSuggestedTopicsFavButton), for: .touchUpInside)
//            if let Topic = arrSuggestedTopics?[indexPath.row] {
//
//                cell.setupTopicCell(topic: Topic)
//            }
            
            if let topic = arrSuggestedTopics?[indexPath.row] {
                cell.setUpReelsTopicsCells(topic: topic)
              //  cell.viewBG.backgroundColor = cellColors[indexPath.row % cellColors.count].hexStringToUIColor()
                cell.restorationIdentifier = "suggested"
                cell.delegate = self
            }
            cell.activityLoader.stopAnimating()

            return cell
        }
        
        return UICollectionViewCell()
    }

    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Topics CollectionView
        return CGSize(width: 245 , height: 116)
        
    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 8
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
//    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == clvFollowingTopics {

            //Followed CollectionView
            if let topic = arrFollowingTopics?[indexPath.row] {
                
                performTabSubTopic(topic)
            }
        }
        else if collectionView == clvSuggestedTopics {
            
            //Suggestions CollectionView
            if let topic = arrSuggestedTopics?[indexPath.row] {
                
                performTabSubTopic(topic)
            }
        }
    }
    
    //Following Channels favourite button Action
    @objc func didTapFollowingTopicsFavButton(_ indexPath: IndexPath) {
        
        if let channel = arrFollowingTopics?[indexPath.row] {
         
            let fav = channel.favorite ?? false
            self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav) { [weak self] status in
                if status {
                    
                    //We are updating array locally
                    self?.arrFollowingTopics?[indexPath.row].favorite = fav ? false : true
                    self?.clvFollowingTopics.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
    //Suggested Channels favourite button Action
    @objc func didTapSuggestedTopicsFavButton(_ indexPath: IndexPath) {
        
        if let channel = arrSuggestedTopics?[indexPath.row] {
         
            let fav = channel.favorite ?? false
            self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav) { [weak self] status in
                if status {
                    
                    //We are updating array locally
                    self?.arrSuggestedTopics?[indexPath.row].favorite = fav ? false : true
                    self?.clvSuggestedTopics.reloadItems(at: [indexPath])
                }
            }
        }
    }
}

extension FollowingTopicsVC: OnboardingTopicsCCDelegate {
    
    func didTapAddButton(cell: OnboardingTopicsCC) {
  
        if cell.restorationIdentifier == "topics" {
            guard let indexPath = clvFollowingTopics.indexPath(for: cell) else { return }
            cell.activityLoader.startAnimating()
            cell.imgFav.isHidden = true
            self.view.isUserInteractionEnabled = false
            
            if let channel = arrFollowingTopics?[indexPath.row] {
             
                let fav = channel.favorite ?? false
                self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav) { [weak self] status in
                    if status {
                        
                        //We are updating array locally
                        cell.imgFav.isHidden = false
                        cell.activityLoader.stopAnimating()
                        self?.arrFollowingTopics?[indexPath.row].favorite = fav ? false : true
                        self?.clvFollowingTopics.reloadItems(at: [indexPath])
                        self?.view.isUserInteractionEnabled = true
                        
                    }
                    else {
                    
                        cell.imgFav.isHidden = false
                        cell.activityLoader.stopAnimating()
                        self?.view.isUserInteractionEnabled = true
                    }
                }
            }
            
          //  didTapFollowingTopicsFavButton(indexPath)
        }
        else {
            guard let indexPath = clvSuggestedTopics.indexPath(for: cell) else { return }
            
            cell.activityLoader.startAnimating()
            cell.imgFav.isHidden = true
            if let channel = arrSuggestedTopics?[indexPath.row] {
             
                let fav = channel.favorite ?? false
                self.view.isUserInteractionEnabled = false
                self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav) { [weak self] status in
                    if status {
                        
                        //We are updating array locally
                        cell.imgFav.isHidden = false
                        cell.activityLoader.stopAnimating()
                        self?.view.isUserInteractionEnabled = true
                        self?.arrSuggestedTopics?[indexPath.row].favorite = fav ? false : true
                        self?.clvSuggestedTopics.reloadItems(at: [indexPath])
                    }
                    else {
                        
                        cell.imgFav.isHidden = false
                        cell.activityLoader.stopAnimating()
                        self?.view.isUserInteractionEnabled = true
                    }
                }
            }
            
            //didTapSuggestedTopicsFavButton(indexPath)
        }
//        guard let indexPath = collectionView.indexPath(for: cell) else { return }
//        sugTopicsArr?[indexPath.row].favorite = !(sugTopicsArr?[indexPath.row].favorite ?? false)
//        collectionView.reloadItems(at: [indexPath])
//        self.delegateSugTopics?.didTapOnTopicCell(cell: self, row: indexPath.row)
    }
}

//MARK: - Topics Webservices
extension FollowingTopicsVC {
    
    //Followed Topics
    func performWSToGetUserFollowedTopics() {

        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        if self.nextPaginate.isEmpty {
            ANLoader.showLoading(disableUI: true)
        }
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/topics/followed?page=\(nextPaginate)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do {
                let FULLResponse = try
                    JSONDecoder().decode(TopicDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let topics = FULLResponse.topics, topics.count > 0 {
                        
                        self.constraintFollowingsViewTop.constant = 30
                        self.viewTopics.isHidden = false
                        self.arrFollowingTopics?.removeAll()
                        if self.nextPaginate.isEmpty {
                            
                            self.arrFollowingTopics = topics
                        }
                        else {
                            
                            self.arrFollowingTopics! += topics
                        }
                        
                        self.clvFollowingTopics.layoutIfNeeded()
                        
                        if self.arrFollowingTopics!.count >= 9 {
                            
                            self.constraintFollowingsClvHeight.constant = 390
                            self.followingViewHeight = 390
                        }
                        else if self.arrFollowingTopics!.count >= 6 {
                            
                            self.constraintFollowingsClvHeight.constant = 274
                            self.followingViewHeight = 274
                        }
                        else {
                            
                            self.constraintFollowingsClvHeight.constant = 158
                            self.followingViewHeight = 158
                        }
                        
                        self.clvFollowingTopics.layoutIfNeeded()
                        self.clvFollowingTopics.reloadData()
                        
                        if let meta = FULLResponse.meta {
                            self.nextPaginate = meta.next ?? ""
                        }
                        ANLoader.hide()
                    }
                    else {
                        
                        self.constraintFollowingsClvHeight.constant = 0
                        self.constraintFollowingsViewTop.constant = 0
                        self.viewTopics.isHidden = true
                    }
                }
                
            } catch let jsonerror {
                
                ANLoader.hide()
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/topics/followed?page=\(self.nextPaginate)", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetSuggestedTopics() {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/topics/suggested", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(TopicDC.self, from: response)

                
                DispatchQueue.main.async {
                    
                    if let topics = FULLResponse.topics, topics.count > 0 {
                        
                        
                        self.constraintSuggestedClvHeight.constant = 30
                        self.viewSuggestions.isHidden = false
                        self.arrSuggestedTopics = topics
                        
                        self.clvSuggestedTopics.layoutIfNeeded()
                        if topics.count >= 12 {
                            
                            self.constraintSuggestedClvHeight.constant = 506
                        }
                        else if topics.count >= 9 {
                            
                            self.constraintSuggestedClvHeight.constant = 390
                        }
                        else if topics.count >= 6 {
                            
                            self.constraintSuggestedClvHeight.constant = 274
                        }
                        else {
                            
                            self.constraintSuggestedClvHeight.constant = 158
                        }
                        
                        self.clvSuggestedTopics.layoutIfNeeded()
                        self.clvSuggestedTopics.reloadData()
                        
                    }
                    else {
                        
                        self.constraintSuggestedClvHeight.constant = 0
                        self.constraintFollowingsViewTop.constant = 0
                        self.viewSuggestions.isHidden = true
                    }
                    
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/topics/suggested", error: jsonerror.localizedDescription, code: "")
            }
            
            ANLoader.hide()
            
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    //Searcg Topics
    func performWSToSearchTopics(_ searchText: String) {

        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        ANLoader.showLoading()
        let searchText = searchText.trim().encodeUrl()

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/topics?query=\(searchText)&page=\(nextPaginate)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(TopicDC.self, from: response)
                
                if let topics = FULLResponse.topics {
                    
                    self.viewSuggestions.isHidden = false
                    self.arrSuggestedTopics?.removeAll()
                    if self.nextPaginate.isEmpty {
                        
                        self.arrSuggestedTopics = topics
                    }
                    else {
                        
                        if (self.arrSuggestedTopics?.count ?? 0) > 0 {
                            self.arrSuggestedTopics! += topics
                        }
                    }
                    
                    if topics.count >= 12 {
                        
                        self.constraintSuggestedClvHeight.constant = 506
                    }
                    else if topics.count >= 9 {
                        
                        self.constraintSuggestedClvHeight.constant = 390
                    }
                    else if topics.count >= 6 {
                        
                        self.constraintSuggestedClvHeight.constant = 274
                    }
                    else {
                        
                        self.constraintSuggestedClvHeight.constant = 158
                    }
                }
                self.clvSuggestedTopics.layoutIfNeeded()
                self.clvSuggestedTopics.reloadData()
                
                if let meta = FULLResponse.meta {
                    
                    self.nextPaginate = meta.next ?? ""
                }
  
                ANLoader.hide()
                
            } catch let jsonerror {
                
                ANLoader.hide()
           //     SharedManager.shared.logAPIError(url: "news/topics?query=\(searchText)&page=\(self.nextPaginate)", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

//MARK: - Update User Follow Webservices
extension FollowingTopicsVC {
    
    func performWSToUpdateUserFollow(id:String, isFav: Bool, completionHandler: @escaping CompletionHandler) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
    
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["topics":id]
        let url = isFav ? "news/topics/unfollow" : "news/topics/follow"
        
        if isFav {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedTopic, topics_id: id)
        }
        else {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.followTopic, topics_id: id)

        }
        
        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateTopicDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
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
                        vc.showArticleType = .topic
                        vc.selectedID = topic.id ?? ""
                        vc.isFav = topic.favorite ?? false
                        vc.subTopicTitle = topic.name ?? ""
                        
                        let nav = AppNavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                        
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
}


