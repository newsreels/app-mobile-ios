//
//  FollowingAuthorsVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 13/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol FollowingAuthorsVCDelegate: AnyObject {
    func followingListUpdated()
}


class FollowingAuthorsVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
//    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewBG: UIView!
    
//    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewAuthors: UIView!
    @IBOutlet weak var viewSuggestions: UIView!
//    @IBOutlet var underLineViews: [UIView]!
    
    @IBOutlet weak var lblFollowings: UILabel!
    @IBOutlet weak var lblSuggestions: UILabel!
    
    @IBOutlet weak var clvFollowingAuthors: UICollectionView!
    @IBOutlet weak var clvSuggestedAuthors: UICollectionView!
    
    @IBOutlet weak var constraintSuggestedClvHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintFollowingsClvHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintFollowingsViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var lblSubTitleFollowing: UILabel!
    @IBOutlet weak var lblSubTitleSuggested: UILabel!
    
    @IBOutlet weak var moreButton: UIButton!
    
    
    var arrFollowingChannels: [ChannelInfo]?
    var arrSuggestedChannels: [ChannelInfo]?
    
    var followStatusChangedArray = [ChannelInfo]()
    var followingViewHeight: CGFloat = 200
    var followingTitleHeight: CGFloat = 124
    //PAGINATION VARIABLES
    var nextPaginate = ""
    
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    weak var delegate: FollowingAuthorsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        view.backgroundColor = .black
//        viewBG.theme_backgroundColor = GlobalPicker.backgroundColor
        lblTitle.textColor = .white
        
//        self.lblFollowings.theme_textColor = GlobalPicker.backgroundColorBlackWhite
//        self.lblSuggestions.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        
//        viewAuthors.addBottomShadow()
//        viewSuggestions.addBottomShadow()
        viewAuthors.theme_backgroundColor = GlobalPicker.followingCardColor
        viewSuggestions.theme_backgroundColor = GlobalPicker.followingCardColor
        
//        underLineViews.forEach {
//            $0.theme_backgroundColor = GlobalPicker.viewLineBGColor
//        }
        
        //SearchView
//        viewSearch.theme_backgroundColor = GlobalPicker.followingSearchBGColor
//        txtSearch.delegate = self
//        txtSearch.theme_placeholderAttributes = GlobalPicker.textPlaceHolderDiscover
//        txtSearch.theme_tintColor = GlobalPicker.searchTintColor
//        txtSearch.theme_textColor = GlobalPicker.textColor
//        txtSearch.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        registerCell()
        
        moreButton.setTitle("Find more", for: .normal)
        lblTitle.text = NSLocalizedString("Authors", comment: "")
        lblFollowings.text = NSLocalizedString("Following", comment: "")
        lblSuggestions.text = NSLocalizedString("Suggestions", comment: "")
        
        closeButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        
        lblSubTitleFollowing.text = "We’ll present more stories from your channels."
        lblSubTitleSuggested.text = "We’ll present more stories from your channels."
//        txtSearch.placeholder = NSLocalizedString("Search", comment: "")
        
        SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true
        
        constraintFollowingsViewTop.constant = 0
        constraintFollowingsClvHeight.constant = 0
        constraintSuggestedClvHeight.constant = 0
        
        moreButton.setTitleColor(Constant.appColor.lightRed, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        performWSToGetFollowedAuthor()
        performWSToGetSuggestedAuthors()
    }
    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            
            DispatchQueue.main.async {
//                self.lblTitle.semanticContentAttribute = .forceRightToLeft
//                self.lblTitle.textAlignment = .right
                
//                self.lblFollowings.semanticContentAttribute = .forceRightToLeft
//                self.lblFollowings.textAlignment = .right
//
//                self.lblSuggestions.semanticContentAttribute = .forceRightToLeft
//                self.lblSuggestions.textAlignment = .right
                
//                self.txtSearch.semanticContentAttribute = .forceRightToLeft
//                self.txtSearch.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
//                self.lblTitle.semanticContentAttribute = .forceLeftToRight
//                self.lblTitle.textAlignment = .left
//
//                self.lblFollowings.semanticContentAttribute = .forceLeftToRight
//                self.lblFollowings.textAlignment = .left
//
//                self.lblSuggestions.semanticContentAttribute = .forceLeftToRight
//                self.lblSuggestions.textAlignment = .left
                
//                self.txtSearch.semanticContentAttribute = .forceLeftToRight
//                self.txtSearch.textAlignment = .left
            }
        }
    }
    
    func registerCell() {
    
        clvFollowingAuthors.register(UINib(nibName: "AuthorsFollowingCell", bundle: nil), forCellWithReuseIdentifier: "AuthorsFollowingCell")
        clvSuggestedAuthors.register(UINib(nibName: "AuthorsFollowingCell", bundle: nil), forCellWithReuseIdentifier: "AuthorsFollowingCell")
    }
    
    // MARK: - Actions
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    
    @IBAction func didTapSave(_ sender: Any) {
        
//        self.dismiss(animated: true)
        performWSToUpdateFollowing()
    }
    
    @IBAction func didTapSearch(_ sender: Any) {
        
        let vc = SearchAllVC.instantiate(fromAppStoryboard: .Main)
        vc.currentSearchSelection = .channels
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    
}

//MARK: - TextField and Search
extension FollowingAuthorsVC: UITextFieldDelegate {
    
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
            arrSuggestedChannels?.removeAll()
            performWSToGetFollowedAuthor()
            performWSToGetSuggestedAuthors()
        }
    }
    
    @objc func getTextOnStopTyping(_ textField: UITextField) {
        
        performWSToSearchAuthor(textField.text ?? "")
    }
    
    func updateView(isSearching: Bool) {
        
        UIView.animate(withDuration: 3.0, delay: 0, options: .curveEaseIn, animations: { [self] in
            
            if isSearching {
    
                lblSuggestions.text = "Search results"
                
                UIView.animate(withDuration: 0.5) {
                    self.constraintFollowingsClvHeight.constant = 0
                    self.constraintFollowingsViewTop.constant = 0
                    self.view.layoutIfNeeded()
                } completion: { status in
                    self.clvSuggestedAuthors.reloadData()
                }
                
                
                
            } else{
                
                lblSuggestions.text = "Suggestions"
                self.viewAuthors.isHidden = false
                
                UIView.animate(withDuration: 0.5) {
                    self.constraintFollowingsClvHeight.constant = self.followingViewHeight + self.followingTitleHeight
                    self.constraintFollowingsViewTop.constant = 30
                    self.view.layoutIfNeeded()
                } completion: { status in
                    self.clvSuggestedAuthors.reloadData()
                }
                
                
            }
        }) { _ in
            
            if isSearching {
    
                self.viewAuthors.isHidden = true
                
            } else{
            }
        }
    }
}

//MARK: - CollectionView Delegates and dataSources
extension FollowingAuthorsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == clvFollowingAuthors {
            
            //Followed CollectionView
            return arrFollowingChannels?.count ?? 0
        }
        else if collectionView == clvSuggestedAuthors {
            
            //Suggestions CollectionView
            return arrSuggestedChannels?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == clvFollowingAuthors {
            
            //Followed CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AuthorsFollowingCell", for: indexPath) as! AuthorsFollowingCell
            
            if let channel = arrFollowingChannels?[indexPath.row] {
                cell.setupCell(model: channel)
                cell.btnFollow.tag = indexPath.row
                cell.btnFollow.addTarget(self, action: #selector(didTapAuthor(sender:)), for: .touchUpInside)
            }
            
            cell.layoutIfNeeded()
            return cell
        }
        else if collectionView == clvSuggestedAuthors {
            
            //Suggestions CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AuthorsFollowingCell", for: indexPath) as! AuthorsFollowingCell
            if let channel = arrSuggestedChannels?[indexPath.row] {
                cell.setupCell(model: channel)
                cell.btnFollow.tag = indexPath.row
                cell.btnFollow.addTarget(self, action: #selector(didTapSuggestedAuthorsFavButton(sender:)), for: .touchUpInside)
            }
            
            cell.layoutIfNeeded()
            return cell
        }
        
        return UICollectionViewCell()
    }

    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        
        if collectionView == clvFollowingAuthors {
            
            //Followed CollectionView
            if self.arrFollowingChannels!.count > 4 {
                
                return CGSize(width: 135 , height: followingViewHeight)
            }
            else {
                
                return CGSize(width: 135, height: followingViewHeight)
            }
        }
        else {
            
            return CGSize(width: 135, height: followingViewHeight)
        }
    }

    func openChannelDetails(channel: ChannelInfo) {
        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
        detailsVC.isOpenFromReel = false
        detailsVC.delegate = self
        detailsVC.isOpenForTopics = false
        detailsVC.channelInfo = channel
//        detailsVC.context = channel.context ?? ""
//                    detailsVC.topicTitle = "#\(articles[indexPath.row].suggestedTopics?[row].name ?? "")"
        detailsVC.modalPresentationStyle = .fullScreen
        
        let nav = AppNavigationController(rootViewController: detailsVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        
        if collectionView == clvFollowingAuthors {

            //Followed CollectionView
            if let channel = arrFollowingChannels?[indexPath.row] {
                
                if (channel.id ?? "") == SharedManager.shared.userId {
                    
                    let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen
                    //vc.delegate = self
                    self.present(navVC, animated: true, completion: nil)
                }
                else {
//
//                    let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
//                    vc.authors = [Authors(id: channel.id ?? "", name: channel.first_name ?? "", username: channel.username, image: channel.profile_image ?? "", favorite: channel.favorite)]
//                    let navVC = AppNavigationController(rootViewController: vc)
//                    navVC.modalPresentationStyle = .fullScreen
//                    self.present(navVC, animated: true, completion: nil)
                    
                    
                    openChannelDetails(channel: channel)
                    
                }
            }
        }
        else if collectionView == clvSuggestedAuthors {
            
            //Suggestions CollectionView
            if let channel = arrSuggestedChannels?[indexPath.row] {
                
                if (channel.id ?? "") == SharedManager.shared.userId {
                    
                    let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen
                    //vc.delegate = self
                    self.present(navVC, animated: true, completion: nil)
                }
                else {
                    
//                    let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
//                    vc.authors = [Authors(id: channel.id, name: channel.first_name, username: channel.username, image: channel.profile_image, favorite: channel.favorite)]
//                    let navVC = AppNavigationController(rootViewController: vc)
//                    navVC.modalPresentationStyle = .fullScreen
//                    self.present(navVC, animated: true, completion: nil)
                    openChannelDetails(channel: channel)
                }

//                let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
//                vc.authors = [Authors(id: channel.id, name: channel.first_name, username: channel.username, image: channel.profile_image, favorite: channel.favorite)]
//                let navVC = AppNavigationController(rootViewController: vc)
//                navVC.modalPresentationStyle = .fullScreen
//                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    //Following Channels favourite button Action
    @objc func didTapAuthor(sender: UIButton) {
        
        if let cell = clvFollowingAuthors.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? AuthorsFollowingCell {
            
            cell.isUserInteractionEnabled = false
            if let channel = arrFollowingChannels?[sender.tag] {
             
//                cell.activityLoader.startAnimating()
//                cell.imgMark.isHidden = true
                cell.btnFollow.showLoader()
                let fav = channel.favorite ?? false
                
                self.arrFollowingChannels?[sender.tag].favorite = fav ? false : true
                self.clvFollowingAuthors.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                cell.btnFollow.hideLoaderView()
                
                if let index = followStatusChangedArray.firstIndex(where: {$0.id == channel.id ?? ""}) {
                    if let chanl = self.arrFollowingChannels?[sender.tag] {
                        followStatusChangedArray[index] = chanl
                    }
                }
                else {
                    if let chanl = self.arrFollowingChannels?[sender.tag] {
                        followStatusChangedArray.append(chanl)
                    }
                }
                
                /*
                SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [channel.id ?? ""], isFav: !fav, type: .sources) { success in
                    
                    if success {
                        
                        //We are updating array locally
                        self.arrFollowingChannels?[sender.tag].favorite = fav ? false : true
                        self.clvFollowingAuthors.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                        cell.btnFollow.hideLoaderView()
                        self.view.isUserInteractionEnabled = true
                    }
                    else {
                        
                        cell.btnFollow.hideLoaderView()
                        self.view.isUserInteractionEnabled = true
                    }
                    
                }*/
            }
        }
    }
    
    //Suggested Channels favourite button Action
    @objc func didTapSuggestedAuthorsFavButton(sender: UIButton) {

        if let cell = clvSuggestedAuthors.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? AuthorsFollowingCell {

            cell.isUserInteractionEnabled = false
            if let channel = arrSuggestedChannels?[sender.tag] {

                cell.btnFollow.showLoader()
//                self.view.isUserInteractionEnabled = false
                let fav = channel.favorite ?? false
                
                self.arrSuggestedChannels?[sender.tag].favorite = fav ? false : true
                self.clvSuggestedAuthors.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                cell.btnFollow.hideLoaderView()
//                self?.view.isUserInteractionEnabled = true
                
                
                if let index = followStatusChangedArray.firstIndex(where: {$0.id == channel.id ?? ""}) {
                    if let chanl = self.arrSuggestedChannels?[sender.tag] {
                        followStatusChangedArray[index] = chanl
                    }
                }
                else {
                    if let chanl = self.arrSuggestedChannels?[sender.tag] {
                        followStatusChangedArray.append(chanl)
                    }
                }
                /*
                self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav) { [weak self] status in
                    cell.isUserInteractionEnabled = true
                    if status {

                        //We are updating array locally
                        self?.arrSuggestedChannels?[sender.tag].favorite = fav ? false : true
                        self?.clvSuggestedAuthors.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                        cell.btnFollow.hideLoaderView()
                        self?.view.isUserInteractionEnabled = true
                    }
                    else {
                        
                        cell.btnFollow.hideLoaderView()
                        self?.view.isUserInteractionEnabled = true
                    }
                }
                */
            }
        }
    }
}

//MARK: - Authors Webservices
extension FollowingAuthorsVC {
    
    //Followed Authors
    func performWSToGetFollowedAuthor() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.showLoaderInVC()
        let url = "news/sources/followed"
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.hideLoaderVC()
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                if let channel = FULLResponse.sources, channel.count > 0 {
             
                    self.arrFollowingChannels?.removeAll()
                    if self.nextPaginate.isEmpty {
                        
                        self.arrFollowingChannels = channel
                    }
                    else {
                        
                        self.arrFollowingChannels! += channel
                    }

                    if self.arrFollowingChannels!.count > 4 {
                        
                        //self.setSize()
                        UIView.animate(withDuration: 0.5) {
                            self.constraintFollowingsClvHeight.constant = self.followingViewHeight + self.followingTitleHeight
                            self.view.layoutIfNeeded()
                        } completion: { status in
                            self.clvFollowingAuthors.reloadData()
                        }
                        
                         //((self.followingViewHeight) * 2)
                    }
                    else {
                        
                        UIView.animate(withDuration: 0.5) {
                            self.constraintFollowingsClvHeight.constant = self.followingViewHeight + self.followingTitleHeight
                            self.view.layoutIfNeeded()
                        } completion: { status in
                            self.clvFollowingAuthors.reloadData()
                        }
                        
                        
                    }

                    if let meta = FULLResponse.meta {
                        self.nextPaginate = meta.next ?? ""
                    }
                }
                else {
                    
                    UIView.animate(withDuration: 0.5) {
                        self.constraintFollowingsClvHeight.constant = 0
                        self.constraintFollowingsViewTop.constant = 0
                        self.viewAuthors.isHidden = true
                    } completion: { status in
                        self.clvFollowingAuthors.reloadData()
                    }
                    
                    
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                self.hideLoaderVC()
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetSuggestedAuthors() {

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/suggested", method: .get, parameters: nil, headers: token, withSuccess: { (response) in

            do{
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)

                if let suggested = FULLResponse.sources {
                    
                    self.arrSuggestedChannels = suggested
                    let arrCount = Double(self.arrSuggestedChannels!.count) / 3
                    let ceilCount = ceil(arrCount)
                    
                    UIView.animate(withDuration: 0.5) {
                        self.constraintSuggestedClvHeight.constant = (self.followingViewHeight) * CGFloat(ceilCount > 3 ? 3 : ceilCount) + self.followingTitleHeight + 20
                    } completion: { status in
                        self.clvSuggestedAuthors.reloadData()
                    }

                    
                }

            } catch let jsonerror {

                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/reels/suggested", error: jsonerror.localizedDescription, code: "")
            }

        }) { (error) in

            print("error parsing json objects",error)
        }
    }
    
    //Search Authors
    func performWSToSearchAuthor(_ search: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
    
        if self.nextPaginate.isEmpty {
            self.showLoaderInVC()
        }
        
        let search = search.encodeUrl()
        let query = "news/sources/?query=\(search)&page=\(self.nextPaginate)"
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(query, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                if let channel = FULLResponse.sources, channel.count > 0 {
             
                    self.constraintFollowingsViewTop.constant = 30
                    self.viewAuthors.isHidden = false
                    self.arrSuggestedChannels?.removeAll()
                    if self.nextPaginate.isEmpty {
                        
                        self.arrSuggestedChannels = channel
                    }
                    else {
                        
                        self.arrSuggestedChannels! += channel
                    }
                    
                    let arrCount = Double(self.arrSuggestedChannels!.count) / 4
                    let ceilCount = ceil(arrCount)
                    
                    
                    UIView.animate(withDuration: 0.5) {
                        self.constraintSuggestedClvHeight.constant = (self.followingViewHeight) * CGFloat(ceilCount > 3 ? 3 : ceilCount) + self.followingTitleHeight + 20
                            //(((self.clvSuggestedAuthors.frame.size.width / 3) + 15) * CGFloat(ceilCount)) + 80
                    } completion: { status in
                        self.clvSuggestedAuthors.reloadData()
                    }
                    
                    if let meta = FULLResponse.meta {
                        self.nextPaginate = meta.next ?? ""
                    }
                    self.hideLoaderVC()
                }
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
                self.hideLoaderVC()
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToUpdateFollowing() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let followedArray = (followStatusChangedArray).filter( {$0.favorite == true} )
        let unfollowedArray = (followStatusChangedArray).filter( {$0.favorite == false} )
        
        var followedChannels = [String]()
        for chn in followedArray {
            followedChannels.append(chn.id ?? "")
        }
        
      
//        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
    
        self.showLoaderInVC()
        
        SharedManager.shared.performWSToUpdateUserFollow(id: followedChannels, isFav: true, type: .sources) { status in
            self.hideLoaderVC()
//            self.hideLoaderVC()
//            self.delegate?.topicsListUpdated()
            
            var unfollowedChannels = [String]()
            for chn in unfollowedArray {
                unfollowedChannels.append(chn.id ?? "")
            }
            
//            self.showLoaderInVC()
            SharedManager.shared.performWSToUpdateUserFollow(id: unfollowedChannels, isFav: false, type: .sources) { status in
                self.hideLoaderVC()
                self.delegate?.followingListUpdated()
                self.dismiss(animated: true)
                
            }
            
            
        }
        

    }
    
    
}



extension FollowingAuthorsVC: ChannelDetailsVCDelegate {
    
    func backButtonPressedChannelDetailsVC(_ channel: ChannelInfo?) {
    }
    
    func backButtonPressedWhenFromReels(_ channel: ChannelInfo?) {
    }
    
    
}

extension FollowingAuthorsVC: SearchAllVCDelegate{
    
    func didTapCloseSearch() {
        
//        self.topicsArray.removeAll()
//        self.locationsArray.removeAll()
//        self.collectionView.reloadData()
//        self.performWSToGetOnboarding()
        
    }
}

