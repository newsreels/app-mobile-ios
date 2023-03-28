//
//  FollowingPlacesVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 13/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class FollowingPlacesVC: UIViewController {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewPlaces: UIView!
    @IBOutlet weak var viewSuggestions: UIView!
    
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblSuggestions: UILabel!
    
    @IBOutlet weak var clvFollowingPlaces: UICollectionView!
    @IBOutlet weak var clvFollowingPlaces1: UICollectionView!
    @IBOutlet weak var clvSuggestedPlaces: UICollectionView!
    
    @IBOutlet weak var constraintSuggestedClvHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintFollowingsClvHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintFollowingsViewTop: NSLayoutConstraint!
    
    var arrMainFollowingLocations: [Location]?
    var arrFollowingLocations: [Location]?
    var arrFollowingLocations1: [Location]?
    var arrSuggestedLocations: [Location]?

    var nextPaginate = ""
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = .black
        viewBG.theme_backgroundColor = GlobalPicker.backgroundColor
        
        lblTitle.textColor = .white
        self.lblFollowing.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        self.lblSuggestions.theme_textColor = GlobalPicker.backgroundColorBlackWhite

        viewPlaces.theme_backgroundColor = GlobalPicker.followingCardColor
        viewSuggestions.theme_backgroundColor = GlobalPicker.followingCardColor
        
        //SearchView
        viewSearch.theme_backgroundColor = GlobalPicker.followingSearchBGColor
        txtSearch.delegate = self
        txtSearch.theme_placeholderAttributes = GlobalPicker.textPlaceHolderDiscover
        txtSearch.theme_tintColor = GlobalPicker.searchTintColor
        txtSearch.theme_textColor = GlobalPicker.textColor
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        registerCell()
        
        self.constraintFollowingsViewTop.constant = 30
        performWSToGetUserFollowedLocation()
        performWSToGetSuggestedLocations()
        
        
        lblTitle.text = NSLocalizedString("Places", comment: "")
        lblFollowing.text = NSLocalizedString("Following", comment: "")
        lblSuggestions.text = NSLocalizedString("Suggestions", comment: "")
        
        txtSearch.placeholder = NSLocalizedString("Search", comment: "")
        
        
        SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true
        
    }
    
    func registerCell() {

        self.clvSuggestedPlaces.delegate = self
        self.clvSuggestedPlaces.dataSource = self
        clvFollowingPlaces.register(UINib(nibName: "RegionsCC", bundle: nil), forCellWithReuseIdentifier: "RegionsCC")
        clvFollowingPlaces1.register(UINib(nibName: "RegionsCC", bundle: nil), forCellWithReuseIdentifier: "RegionsCC")
        clvSuggestedPlaces.register(UINib(nibName: "RegionsCC", bundle: nil), forCellWithReuseIdentifier: "RegionsCC")
    
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        alignedFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.clvSuggestedPlaces.collectionViewLayout = alignedFlowLayout
    }
    
    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                
                self.lblFollowing.semanticContentAttribute = .forceRightToLeft
                self.lblFollowing.textAlignment = .right
                
                self.lblSuggestions.semanticContentAttribute = .forceRightToLeft
                self.lblSuggestions.textAlignment = .right
                
                self.txtSearch.semanticContentAttribute = .forceRightToLeft
                self.txtSearch.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                
                self.lblFollowing.semanticContentAttribute = .forceLeftToRight
                self.lblFollowing.textAlignment = .left
                
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
extension FollowingPlacesVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getTextOnStopTyping), object: textField)
        WebService.cancelAPIRequest()
        if let searchText = textField.text, !(searchText.isEmpty) {
            
            nextPaginate = ""
            updateView(isSearching: true)
            self.perform(#selector(getTextOnStopTyping), with: textField, afterDelay: 0.5)
        }
        else {
            
            self.view.endEditing(true)
            nextPaginate = ""
            arrSuggestedLocations?.removeAll()
            
            self.performWSToGetUserFollowedLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                self.performWSToGetSuggestedLocations()
                self.updateView(isSearching: false)
            }
        }
    }
    
    @objc func getTextOnStopTyping(_ textField: UITextField) {
        
        performWSToSearchPlaces(textField.text ?? "")
    }
    
    func updateView(isSearching: Bool) {
        
        UIView.animate(withDuration: 3.0, delay: 0, options: .curveEaseIn, animations: { [self] in
            
            if isSearching {
    
                lblSuggestions.text = "Search results"
                self.constraintFollowingsClvHeight.constant = 0
                self.constraintFollowingsViewTop.constant = 0
            } else{
                
                lblSuggestions.text = "Suggestions"
                self.viewPlaces.isHidden = false
                self.constraintFollowingsViewTop.constant = 30
            }
//            self.clvFollowingPlaces.layoutIfNeeded()
//            self.clvFollowingPlaces1.layoutIfNeeded()
        }) { _ in
            
            if isSearching {
    
                self.viewPlaces.isHidden = true
                
            } else{
            }
        }
    }
}

//MARK: - CollectionView Delegates and dataSources
extension FollowingPlacesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == clvFollowingPlaces {
            
            //Followed CollectionView
            return arrFollowingLocations?.count ?? 0
        }
        else if collectionView == clvFollowingPlaces1 {
            
            //Followed CollectionView
            return arrFollowingLocations1?.count ?? 0
        }
        else if collectionView == clvSuggestedPlaces {
            
            //Suggestions CollectionView
            return arrSuggestedLocations?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == clvFollowingPlaces {
            
            //Followed CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RegionsCC", for: indexPath) as! RegionsCC
            
        
            if let location = arrFollowingLocations?[indexPath.row] {
                
                let isFav = location.favorite ?? false
                if isFav {
                    cell.imgFav.theme_image = GlobalPicker.selectedTickMarkImage
                }
                else {
                    cell.imgFav.theme_image = GlobalPicker.unSelectedTickMarkImage
                }
                cell.lblRegion.text = location.name?.capitalized ?? ""
                cell.viewBG.cornerRadius = 24
                cell.viewBG.borderWidth = 1.0
                cell.viewBG.borderColor = .customViewGreyColor
            }
           
            cell.lblRegion.theme_textColor = GlobalPicker.textColor
            cell.btnFav.isHidden = false
            cell.btnFav.tag = indexPath.row
            cell.btnFav.addTarget(self, action: #selector(didTapFollowingChannelsFavButton), for: .touchUpInside)
            return cell
        }
        else if collectionView == clvFollowingPlaces1 {
            
            //Followed CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RegionsCC", for: indexPath) as! RegionsCC
            
            if let location = arrFollowingLocations1?[indexPath.row] {
        
                let isFav = location.favorite ?? false
                if isFav {
                    cell.imgFav.theme_image = GlobalPicker.selectedTickMarkImage
                }
                else {
                    cell.imgFav.theme_image = GlobalPicker.unSelectedTickMarkImage
                }
                cell.lblRegion.text = location.name?.capitalized ?? ""
                cell.viewBG.cornerRadius = 24
                cell.viewBG.borderWidth = 1.0
                cell.viewBG.borderColor = .customViewGreyColor
            }
            cell.lblRegion.theme_textColor = GlobalPicker.textColor
            cell.btnFav.isHidden = false
            cell.btnFav.tag = indexPath.row
            cell.btnFav.addTarget(self, action: #selector(didTapFollowingChannelsFavButton1), for: .touchUpInside)

            return cell
        }
        else if collectionView == clvSuggestedPlaces {
            
            //Suggestions CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RegionsCC", for: indexPath) as! RegionsCC
            if let location = arrSuggestedLocations?[indexPath.row] {
              
                let isFav = location.favorite ?? false
                if isFav {
                    cell.imgFav.theme_image = GlobalPicker.selectedTickMarkImage
                }
                else {
                    cell.imgFav.theme_image = GlobalPicker.unSelectedTickMarkImage
                }
                cell.lblRegion.text = location.name?.capitalized ?? ""
                cell.viewBG.cornerRadius = 24
                cell.viewBG.borderWidth = 1.0
                cell.viewBG.borderColor = .customViewGreyColor
            }
            cell.trailingSpace.constant = 6
            cell.lblRegion.theme_textColor = GlobalPicker.textColor
            cell.btnFav.isHidden = false
            cell.btnFav.tag = indexPath.row
            cell.btnFav.addTarget(self, action: #selector(didTapSuggestedChannelsFavButton), for: .touchUpInside)
            return cell
        }
        
        return UICollectionViewCell()
    }

    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Topics CollectionView
        if collectionView == clvFollowingPlaces {
            
            if let locationName = self.arrFollowingLocations?[indexPath.row].name {
                
                let itemSize = locationName.size(withAttributes: [
                    
                    NSAttributedString.Key.font : UIFont(name: Constant.FONT_Mulli_BOLD, size: 12) ?? "CALIFORNIA"
                ])
                return CGSize(width: itemSize.width + 80, height: 60)
            }
        }
        else if collectionView == clvFollowingPlaces1 {
            
            if let locationName = self.arrFollowingLocations1?[indexPath.row].name {
                
                let itemSize = locationName.size(withAttributes: [
                    
                    NSAttributedString.Key.font : UIFont(name: Constant.FONT_Mulli_BOLD, size: 12) ?? "CALIFORNIA"
                ])
                return CGSize(width: itemSize.width + 80, height: 60)
            }
        }
        else {

            if let locationName = self.arrSuggestedLocations?[indexPath.row].name {

                let itemSize = locationName.size(withAttributes: [

                    NSAttributedString.Key.font : UIFont(name: Constant.FONT_Mulli_BOLD, size: 12) ?? "CALIFORNIA"
                ])
                return CGSize(width: itemSize.width + 80, height: 60)
            }
        }
        
        return CGSize(width: 140, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        SharedManager.shared.isTabReload = true
        
        if collectionView == clvFollowingPlaces {
            if let location = arrFollowingLocations?[indexPath.row] {
                openLocation(location: location)
            }
        }
        else if collectionView == clvFollowingPlaces1 {
            if let location = arrFollowingLocations1?[indexPath.row] {
                openLocation(location: location)
            }
        }
        else {
            if let location = arrSuggestedLocations?[indexPath.row] {
                openLocation(location: location)
            }
        }
    }
    
    //Following Channels favourite button Action
    @objc func didTapFollowingChannelsFavButton(sender: UIButton) {
        
        if let cell = clvFollowingPlaces.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? RegionsCC {
            
            // Index out of bounds crash fix}
            if self.arrFollowingLocations?.count == 0  || self.arrFollowingLocations?.count ?? 0 <= sender.tag {
                return
            }
            
            cell.activityLoader.startAnimating()
            cell.imgFav.isHidden = true
            self.view.isUserInteractionEnabled = false
            cell.isUserInteractionEnabled = false
            
            if let channel = arrFollowingLocations?[sender.tag] {
             
                let fav = channel.favorite ?? false
                arrFollowingLocations?[sender.tag].favorite = fav ? false : true
                self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav) { [weak self] status in
                    cell.isUserInteractionEnabled = true
                    if status {
                        
                        //We are updating array locally
                        self?.clvFollowingPlaces.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                        cell.imgFav.isHidden = false
                        cell.activityLoader.stopAnimating()
                        self?.view.isUserInteractionEnabled = true
                    }
                    else {
                        
                        cell.imgFav.isHidden = false
                        cell.activityLoader.stopAnimating()
                        self?.view.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    @objc func didTapFollowingChannelsFavButton1(sender: UIButton) {
        
        if let cell = clvFollowingPlaces1.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? RegionsCC {
            
            // Index out of bounds crash fix}
            if self.arrFollowingLocations1?.count == 0  || self.arrFollowingLocations1?.count ?? 0 <= sender.tag {
                return
            }
            
            cell.isUserInteractionEnabled = false
            if let channel = arrFollowingLocations1?[sender.tag] {
             
                cell.activityLoader.startAnimating()
                cell.imgFav.isHidden = true
                self.view.isUserInteractionEnabled = false
                cell.isUserInteractionEnabled = false
                
                let fav = channel.favorite ?? false
                arrFollowingLocations1?[sender.tag].favorite = fav ? false : true
                self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav) { [weak self] status in
                    cell.isUserInteractionEnabled = true
                    if status {
                        
                        //We are updating array locally
                        self?.clvFollowingPlaces1.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                        cell.imgFav.isHidden = false
                        cell.activityLoader.stopAnimating()
                        self?.view.isUserInteractionEnabled = true
                    }
                    else {
                        
                        cell.imgFav.isHidden = false
                        cell.activityLoader.stopAnimating()
                        self?.view.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    //Suggested Channels favourite button Action
    @objc func didTapSuggestedChannelsFavButton(sender: UIButton) {
        
        if let cell = clvSuggestedPlaces.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? RegionsCC {
            
            // Index out of bounds crash fix}
            if self.arrSuggestedLocations?.count == 0  || self.arrSuggestedLocations?.count ?? 0 <= sender.tag {
                return
            }
            
            cell.isUserInteractionEnabled = false
            if let channel = arrSuggestedLocations?[sender.tag] {
             
                cell.activityLoader.startAnimating()
                cell.imgFav.isHidden = true
                self.view.isUserInteractionEnabled = false
                cell.isUserInteractionEnabled = false

                let fav = channel.favorite ?? false
                arrSuggestedLocations?[sender.tag].favorite = fav ? false : true
                self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav) { [weak self] status in
                    cell.isUserInteractionEnabled = true
                    if status {
                        
                        //We are updating array locally
                        self?.clvSuggestedPlaces.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                        cell.imgFav.isHidden = false
                        cell.activityLoader.stopAnimating()
                        self?.view.isUserInteractionEnabled = true
                    }
                    else {
                        
                        cell.imgFav.isHidden = false
                        cell.activityLoader.stopAnimating()
                        self?.view.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == clvFollowingPlaces {
            clvFollowingPlaces1.contentOffset = clvFollowingPlaces.contentOffset
        }
        else if scrollView == clvFollowingPlaces1 {
        
            clvFollowingPlaces.contentOffset = clvFollowingPlaces1.contentOffset
        }
    }
}

//MARK: - Places Webservices
extension FollowingPlacesVC {

    //Followed Locations
    func performWSToGetUserFollowedLocation() {

        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        ANLoader.showLoading()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/locations/followed?page=\(self.nextPaginate)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                if let locs = FULLResponse.locations, locs.count > 0 {
           
                    self.arrFollowingLocations?.removeAll()
                    self.arrFollowingLocations1?.removeAll()
                    self.arrMainFollowingLocations?.removeAll()
                    
                    if self.nextPaginate.isEmpty {
                        
                        self.arrMainFollowingLocations = locs
                    }
                    else {
                                                
                        self.arrMainFollowingLocations! += locs
                    }
                    
                    if let locations = self.arrMainFollowingLocations, locations.count > 2 {
                        
                        let Locations = self.arrMainFollowingLocations?.devided()
                        
                        self.arrFollowingLocations = Locations?.0
                        self.arrFollowingLocations1 = Locations?.1
                        self.constraintFollowingsClvHeight.constant = 191
                        self.clvFollowingPlaces.reloadData()
                        self.clvFollowingPlaces1.reloadData()
                    }
                    else {
                        
                        self.arrFollowingLocations = self.arrMainFollowingLocations
                        self.constraintFollowingsClvHeight.constant = 131
                    
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            
                            self.clvFollowingPlaces.reloadData()
                            self.clvFollowingPlaces.layoutIfNeeded()
                        }
                        
                    }
          
                    if let meta = FULLResponse.meta {
                        self.nextPaginate = meta.next ?? ""
                    }
                    self.viewPlaces.isHidden = false
                    ANLoader.hide()
                }
                else {
                    
                    self.constraintFollowingsClvHeight.constant = 0
                    self.constraintFollowingsViewTop.constant = 0
                    self.viewPlaces.isHidden = true
                }

            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/locations/followed?page=\(self.nextPaginate)", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }

        }) { (error) in

            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetSuggestedLocations() {
        
        self.clvSuggestedPlaces.isUserInteractionEnabled = false
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/locations/suggested", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                if let suggested = FULLResponse.locations, suggested.count > 0 {
    
                    self.arrSuggestedLocations = suggested
                    self.constraintSuggestedClvHeight.constant = CGFloat((suggested.count / 2 * 68)) + 42
                    
                    self.clvSuggestedPlaces.reloadData()
                }
                self.clvSuggestedPlaces.isUserInteractionEnabled = true
                
            } catch let jsonerror {
                
                self.clvSuggestedPlaces.isUserInteractionEnabled = true
                SharedManager.shared.logAPIError(url: "news/locations/suggested", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
            self.clvSuggestedPlaces.isUserInteractionEnabled = true
            ANLoader.hide()
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToSearchPlaces(_ searchText: String) {

        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let searchText = searchText.encodeUrl()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/locations?query=\(searchText)&page=\(nextPaginate)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                self.arrSuggestedLocations?.removeAll()
                if let locs = FULLResponse.locations {
                    
                    self.arrSuggestedLocations = locs
                }
       
                if let meta = FULLResponse.meta {
                    
                    self.nextPaginate = meta.next ?? ""
                }
                self.clvSuggestedPlaces.reloadData()

            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/locations?query=\(searchText)&page=\(self.nextPaginate)", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            print("error parsing json objects",error)
        }
    }
}

//MARK: - Update User Follow Webservices
extension FollowingPlacesVC {
    
    func performWSToUpdateUserFollow(id:String, isFav: Bool, completionHandler: @escaping CompletionHandler) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["locations":id]
        let url = isFav ? "news/locations/unfollow" : "news/locations/follow"
        
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
    
    func openLocation(location: Location) {
        
        //followed
        SharedManager.shared.subLocationList = [location]
        let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
        vc.showArticleType = .places
        vc.selectedID = location.id ?? ""
        vc.isFav = location.favorite ?? false
        vc.placeContextId = location.context ?? ""
        vc.subTopicTitle = location.city ?? ""
        
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
    }
}

