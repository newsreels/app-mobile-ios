//
//  FollowingChannelsVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 13/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class FollowingChannelsVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewBG: UIView!
    
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewChannels: UIView!
    @IBOutlet weak var viewSuggestions: UIView!
    @IBOutlet var underLineViews: [UIView]!
    
    @IBOutlet weak var lblChannels: UILabel!
    @IBOutlet weak var lblSuggestions: UILabel!
    
    @IBOutlet weak var clvFollowingChannels: UICollectionView!
    @IBOutlet weak var clvSuggestedChannels: UICollectionView!
    
    @IBOutlet weak var constraintSuggestedClvHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintFollowingsClvHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintFollowingsViewTop: NSLayoutConstraint!
    
    
    var arrFollowingChannels: [ChannelInfo]?
    var arrSuggestedChannels: [ChannelInfo]?

    var followingViewHeight: CGFloat = 300
    var searching: Bool = false
    var nextPaginate = ""
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        view.backgroundColor = .black
        viewBG.theme_backgroundColor = GlobalPicker.backgroundColor
        
        lblTitle.textColor = .white
        lblChannels.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblSuggestions.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        underLineViews.forEach {
            $0.theme_backgroundColor = GlobalPicker.viewLineBGColor
        }
        
        viewChannels.theme_backgroundColor = GlobalPicker.followingCardColor
        viewSuggestions.theme_backgroundColor = GlobalPicker.followingCardColor

        
        //SearchView
        viewSearch.theme_backgroundColor = GlobalPicker.followingSearchBGColor
        txtSearch.delegate = self
        txtSearch.theme_placeholderAttributes = GlobalPicker.textPlaceHolderDiscover
        txtSearch.theme_tintColor = GlobalPicker.searchTintColor
        txtSearch.theme_textColor = GlobalPicker.textColor
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        registerCell()
        arrFollowingChannels = [ChannelInfo]()
        performWSToGetFollowedChannels()
        performWSToGetSuggestedChannels()
        
        lblTitle.text = NSLocalizedString("Channels", comment: "")
        lblChannels.text = NSLocalizedString("Following", comment: "")
        lblSuggestions.text = NSLocalizedString("Suggestions", comment: "")
        
        txtSearch.placeholder = NSLocalizedString("Search", comment: "")
        
        SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true
    }
    
    func registerCell() {
        
//        clvFollowingChannels.register(UINib(nibName: "FollowingChannelCC", bundle: nil), forCellWithReuseIdentifier: "FollowingChannelCC")
//        clvSuggestedChannels.register(UINib(nibName: "FollowingChannelCC", bundle: nil), forCellWithReuseIdentifier: "FollowingChannelCC")
        clvFollowingChannels.register(UINib(nibName: "sugChannelCC", bundle: nil), forCellWithReuseIdentifier: "sugChannelCC")
        clvSuggestedChannels.register(UINib(nibName: "sugChannelCC", bundle: nil), forCellWithReuseIdentifier: "sugChannelCC")

    }
    
    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                
                self.lblChannels.semanticContentAttribute = .forceRightToLeft
                self.lblChannels.textAlignment = .right
                
                self.lblSuggestions.semanticContentAttribute = .forceRightToLeft
                self.lblSuggestions.textAlignment = .right
                
                self.txtSearch.semanticContentAttribute = .forceRightToLeft
                self.txtSearch.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                
                self.lblChannels.semanticContentAttribute = .forceLeftToRight
                self.lblChannels.textAlignment = .left
                
                self.lblSuggestions.semanticContentAttribute = .forceLeftToRight
                self.lblSuggestions.textAlignment = .left
                
                self.txtSearch.semanticContentAttribute = .forceLeftToRight
                self.txtSearch.textAlignment = .left
            }
        }
    }
    
    
    //Buttons action
    @IBAction func didTapBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - TextField and Search
extension FollowingChannelsVC: UITextFieldDelegate {
    
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
           // arrFollowingChannels?.removeAll()
            performWSToGetFollowedChannels()
            performWSToGetSuggestedChannels()
        }
    }
    
    @objc func getTextOnStopTyping(_ textField: UITextField) {
        
        performWSToSearchChannels(textField.text ?? "")
    }
    
    func updateView(isSearching: Bool) {
        
        UIView.animate(withDuration: 3.0, delay: 0, options: .curveEaseIn, animations: { [self] in
            
            if isSearching {
    
                lblSuggestions.text = "Search results"
                self.constraintFollowingsClvHeight.constant = 0
                self.constraintFollowingsViewTop.constant = 0
            } else{
                
                lblSuggestions.text = "Suggestions"
                self.viewChannels.isHidden = false
                self.constraintFollowingsClvHeight.constant = followingViewHeight
                self.constraintFollowingsViewTop.constant = 30
            }
            self.clvFollowingChannels.layoutIfNeeded()
        }) { _ in
            
            if isSearching {
    
                self.viewChannels.isHidden = true
                
            } else{
            }
        }
    }
}

//MARK: - CollectionView Delegates and dataSources
extension FollowingChannelsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == clvFollowingChannels {
            
            //Followed CollectionView
            return arrFollowingChannels?.count ?? 0
        }
        else if collectionView == clvSuggestedChannels {
            
            //Suggestions CollectionView
            return arrSuggestedChannels?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == clvFollowingChannels {
            
            //Followed CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sugChannelCC", for: indexPath) as! sugChannelCC
            
            //Check Upload Processing/scheduled on Article by User
            if let channel = arrFollowingChannels?[indexPath.row] {
                cell.setupCellSourceModel(model: channel)
            }
            
            cell.channelButtonPressedBlock = {
                
                if let channel = self.arrFollowingChannels?[indexPath.row] {
                 
                    cell.activityLoader.startAnimating()
                    cell.imgPlusMark.isHidden = true
                    self.view.isUserInteractionEnabled = false
                    let fav = channel.favorite ?? false
                   
                    self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav) { [weak self] status in
                        DispatchQueue.main.async {
                            
                            if status {
                                
                                //We are updating array locally
                                cell.imgPlusMark.isHidden = false
                                cell.activityLoader.stopAnimating()
                                self?.view.isUserInteractionEnabled = true
                                self?.arrFollowingChannels?[indexPath.row].favorite = fav ? false : true
                                self?.clvFollowingChannels.reloadItems(at: [indexPath])
                            }
                            else {
                                
                                cell.imgPlusMark.isHidden = false
                                cell.activityLoader.stopAnimating()
                                self?.view.isUserInteractionEnabled = true
                            }
                        }
                    }
                }
            }
            
            cell.layoutIfNeeded()
            return cell
        }
        
        else if collectionView == clvSuggestedChannels {
            
            //Suggestions CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sugChannelCC", for: indexPath) as! sugChannelCC
            
            //Check Upload Processing/scheduled on Article by User
            if let channel = arrSuggestedChannels?[indexPath.row] {
                cell.setupCellSourceModel(model: channel)
            }
            
            cell.channelButtonPressedBlock = { [self] in
                
                if let channel = self.arrSuggestedChannels?[indexPath.row] {
                 
                    cell.activityLoader.startAnimating()
                    cell.imgPlusMark.isHidden = true
                    self.view.isUserInteractionEnabled = false
                    let fav = channel.favorite ?? false
                 
                    self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav) { [weak self] status in
                        DispatchQueue.main.async {
                            cell.isUserInteractionEnabled = true
                            if status {
                                
                                //We are updating array locally
                                self?.arrSuggestedChannels?[indexPath.row].favorite = fav ? false : true
                                self?.clvSuggestedChannels.reloadItems(at: [indexPath])
                                cell.imgPlusMark.isHidden = false
                                cell.activityLoader.stopAnimating()
                                self?.view.isUserInteractionEnabled = true
                            }
                            else {
                                
                                cell.imgPlusMark.isHidden = false
                                cell.activityLoader.stopAnimating()
                                self?.view.isUserInteractionEnabled = true
                            }

                        }
                    }
                }
            }
            
            cell.layoutIfNeeded()
            return cell
        }
        
        return UICollectionViewCell()
    }

    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.size.width / 2.5, height: 180)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 8
//    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        

        if collectionView == clvFollowingChannels {

            //Followed CollectionView
            if let channel = arrFollowingChannels?[indexPath.row] {
                
                self.performWSGoToChannelDetailsScreen(channel.id ?? "")
            }
        }
        else if collectionView == clvSuggestedChannels {
            
            //Suggestions CollectionView
            if let channel = arrSuggestedChannels?[indexPath.row] {
                
                self.performWSGoToChannelDetailsScreen(channel.id ?? "")
            }
        }
    }
}

//MARK: - Channels Webservices
extension FollowingChannelsVC {
    
    //Followrd Channels
    func performWSToGetFollowedChannels() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        if self.nextPaginate.isEmpty {
            ANLoader.showLoading(disableUI: true)
        }
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/followed?page=\(nextPaginate)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let source = FULLResponse.sources, source.count > 0 {
                
                        self.arrFollowingChannels?.removeAll()
                                                
                        self.constraintFollowingsViewTop.constant = 30
                        self.viewChannels.isHidden = false
                        
                        if self.nextPaginate.isEmpty {
                            
                            self.arrFollowingChannels = source
                        }
                        else {
                            
                            self.arrFollowingChannels! += source
                        }
                        self.clvFollowingChannels.layoutIfNeeded()
                        
                        if self.arrFollowingChannels!.count > 4 {

                            self.constraintFollowingsClvHeight.constant = (180 * 2) + 50
                            self.followingViewHeight = (180 * 2) + 50
                        }
                        else {

                            self.constraintFollowingsClvHeight.constant = 180  + 50
                            self.followingViewHeight = 180 + 50
                        }
                        
                        self.clvFollowingChannels.layoutIfNeeded()
                        self.clvFollowingChannels.reloadData()
                        if let meta = FULLResponse.meta {
                            
                            self.nextPaginate = meta.next ?? ""
                        }
                        ANLoader.hide()
                    }
                    else {
                        
                        self.constraintFollowingsClvHeight.constant = 0
                        self.constraintFollowingsViewTop.constant = 0
                        self.viewChannels.isHidden = true
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/followed?page=\(self.nextPaginate)", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetSuggestedChannels() {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/suggested", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do {
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                if let suggested = FULLResponse.sources {
                    
                    self.arrSuggestedChannels = suggested
                    let arrCount = Double(self.arrSuggestedChannels!.count) / 4
                    let ceilCount = ceil(arrCount)
                    self.constraintSuggestedClvHeight.constant = (180 * CGFloat(ceilCount)) + 60
                    self.clvSuggestedChannels.reloadData()
                }
                
                ANLoader.hide()

            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/suggested", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    //Channels Search APi
    func performWSToSearchChannels(_ searchText: String) {

        self.searching = true
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        ANLoader.showLoading()
        
        let searchText = searchText.encodeUrl()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources?query=\(searchText)&page=\(nextPaginate)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do {
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                if let sources = FULLResponse.sources, sources.count > 0 {
                    
                    self.arrSuggestedChannels?.removeAll()
                    if self.nextPaginate.isEmpty {
                        self.arrSuggestedChannels?.removeAll()
                        self.arrSuggestedChannels! = sources
                    }
                    else {
                        self.arrSuggestedChannels! += sources
                    }
                    
                    if self.arrSuggestedChannels!.count > 12 {

                        self.constraintSuggestedClvHeight.constant = (180 * 3) + 60
                    }
                    else if self.arrSuggestedChannels!.count > 4 {

                        self.constraintSuggestedClvHeight.constant = (180 * 2) + 60
                    }
                    else {

                        self.constraintSuggestedClvHeight.constant = 180  + 60
                    }
                
//                    let arrCount = Double(self.arrSuggestedChannels!.count) / 4
//                    let ceilCount = ceil(arrCount)
//                    
//                    self.constraintSuggestedClvHeight.constant = (self.clvSuggestedChannels.frame.size.width / 3.8) * CGFloat(ceilCount)
                }
                
                if let meta = FULLResponse.meta {
                    
                    self.nextPaginate = meta.next ?? ""
                }
                self.clvSuggestedChannels.reloadData()
                ANLoader.hide()
                
            } catch let jsonerror {
                
                ANLoader.hide()
                SharedManager.shared.logAPIError(url: "news/sources?query=\(searchText)&page=\(self.nextPaginate)", error: jsonerror.localizedDescription, code: "")
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
extension FollowingChannelsVC {
    
    func performWSToUpdateUserFollow(id:String, isFav: Bool, completionHandler: @escaping CompletionHandler) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["sources":id]
        let url = isFav ? "news/sources/unfollow" : "news/sources/follow"
        
        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateTopicDC.self, from: response)
                
                SharedManager.shared.isTabReload = true
                SharedManager.shared.isDiscoverTabReload = true
                if FULLResponse.message == "Success" {
                    
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
}

extension FollowingChannelsVC {
    
    func performWSGoToChannelDetailsScreen(_ id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/data/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let Info = FULLResponse.channel {
                        
                        if let ptcTBC = self.tabBarController as? PTCardTabBarController {
                            ptcTBC.showTabBar(false, animated: true)
                        }
                        
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
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
}
