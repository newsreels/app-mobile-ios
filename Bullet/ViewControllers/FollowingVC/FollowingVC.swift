//
//  FollowingVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 08/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol FollowingVCDelegate: AnyObject {
    
    func didTapBack()
    
}

class FollowingVC: UIViewController {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNotFollowing: UILabel!
    @IBOutlet weak var viewChannels: UIView!
    @IBOutlet weak var viewTopics: UIView!
    @IBOutlet weak var viewAuthors: UIView!
    @IBOutlet weak var viewPlaces: UIView!
    
    @IBOutlet weak var viewChannelsViewAll: UIView!
    @IBOutlet weak var viewTopicsViewAll: UIView!
    @IBOutlet weak var viewAuthorsViewAll: UIView!
    @IBOutlet weak var viewPlacesViewAll: UIView!
    @IBOutlet weak var constraintChannelsViewAllHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintTopicsViewAllHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintAuthorsViewAllHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintPlacesViewAllHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewChannelsHight: NSLayoutConstraint!
    @IBOutlet weak var viewTopicsHight: NSLayoutConstraint!
    @IBOutlet weak var viewAuthorsHight: NSLayoutConstraint!
    @IBOutlet weak var viewPlacesHight: NSLayoutConstraint!
    
    @IBOutlet weak var lblChannels: UILabel!
    @IBOutlet weak var lblTopics: UILabel!
    @IBOutlet weak var lblAuthors: UILabel!
    @IBOutlet weak var lblPlaces: UILabel!
    @IBOutlet var lblViewAndManageCollection: [UILabel]!
    @IBOutlet var underLineViews: [UIView]!
    
    @IBOutlet weak var constraintNotFollowingViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewChannels: UICollectionView!
    @IBOutlet weak var collectionViewTopics: UICollectionView!
    @IBOutlet weak var collectionViewAuthors: UICollectionView!
    @IBOutlet weak var collectionViewPlaces: UICollectionView!
   
    var arrChannels: [ChannelInfo]?
    var arrLocations: [Location]?
    var arrTopics: [TopicData]?
    var arrAuthors: [Author]?
    
    var isFollowing = true
    var followingCount = 0

    
    enum searchType: String {
        case topics
        case sources
        case locations
        case authors
    }
    typealias CompletionHandler = (_ success:Bool) -> Void

    //PAGINATION VARIABLES
    var nextPaginate = ""
    weak var delegate: FollowingVCDelegate?
    
    var isOpenFromReels = false
    var isOpenFromFeed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        viewBG.theme_backgroundColor = GlobalPicker.backgroundColor
        lblTitle.textColor = .white
        
        viewChannels.addBottomShadow()
        viewTopics.addBottomShadow()
        viewAuthors.addBottomShadow()
        viewPlaces.addBottomShadow()
     //   viewChannels.theme_backgroundColor = GlobalPicker.followingCardColor
     //   viewTopics.theme_backgroundColor = GlobalPicker.followingCardColor
     //   viewAuthors.theme_backgroundColor = GlobalPicker.followingCardColor
    //    viewPlaces.theme_backgroundColor = GlobalPicker.followingCardColor
        
        lblChannels.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblTopics.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblAuthors.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        lblPlaces.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        
        lblViewAndManageCollection.forEach { lbl in
            lbl.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        }
        underLineViews.forEach {
            $0.theme_backgroundColor = GlobalPicker.viewLineBGColor
        }
        
        registerCell()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if #available(iOS 13.0, *) {
            return MyThemes.current == .dark ? .lightContent : .darkContent
        }
        else{
            return .default
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        
        isFollowing = true
        followingCount = 0
        if isOpenFromReels {
            
            performWSToGetFollowedChannels()
            performWSToGetFollowedAuthor(search: "")
            
            viewTopicsViewAll.isHidden = true
            viewPlacesViewAll.isHidden = true
            constraintTopicsViewAllHeight.constant = 0
            constraintPlacesViewAllHeight.constant = 0
            
        }
        else if isOpenFromFeed {
            
            performWSToGetFollowedChannels()
            performWSToGetFollowedAuthor(search: "")
            performWSToGetUserFollowedTopics()

            viewPlacesViewAll.isHidden = true
            constraintPlacesViewAllHeight.constant = 0
        }
        else {
            
            performWSToGetFollowedChannels()
            performWSToGetFollowedAuthor(search: "")
            performWSToGetUserFollowedTopics()
            performWSToGetUserFollowedLocation()
            
        }
        
        
        SharedManager.shared.isReelsFollowingNeedRefresh = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL() {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
            } else {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
            }
        }
    }
    
    func registerCell() {
        
        collectionViewChannels.register(UINib(nibName: "sugChannelCC", bundle: nil), forCellWithReuseIdentifier: "sugChannelCC")
        collectionViewTopics.register(UINib(nibName: "OnboardingTopicsCC", bundle: nil), forCellWithReuseIdentifier: "OnboardingTopicsCC")
        collectionViewAuthors.register(UINib(nibName: "AuthorsFollowingCell", bundle: nil), forCellWithReuseIdentifier: "AuthorsFollowingCell")
        collectionViewPlaces.register(UINib(nibName: "RegionsCC", bundle: nil), forCellWithReuseIdentifier: "RegionsCC")
        
    }
    
    //Update Not Following View
    func updateNotFollowingView() {
        
        if self.followingCount != 4 {
            return
        }
        if self.isFollowing {
            
            self.lblNotFollowing.isHidden = true
            self.constraintNotFollowingViewHeight.constant = 0
        } else{
            
            UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                
                self.constraintNotFollowingViewHeight.constant = 150
                self.lblNotFollowing.isHidden = false
            }, completion: nil)
        }
    }

    //Buttons action
    @IBAction func didTapBack(_ sender: Any) {
        
        self.delegate?.didTapBack()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapViewChannels(_ sender: Any) {
      
        let vc = FollowingChannelsVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func didTapViewPlaces(_ sender: Any) {
      
        let vc = FollowingPlacesVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func didTapViewAuthors(_ sender: Any) {
      
        let vc = FollowingAuthorsVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func didTapViewTopics(_ sender: Any) {
      
        let vc = FollowingTopicsVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
}

//MARK: - CollectionView Delegates and dataSources
extension FollowingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == collectionViewChannels {
            
            //Channels CollectionView
            return arrChannels?.count ?? 0
        }
        else if collectionView == collectionViewAuthors {
            
            //Authors CollectionView
            return arrAuthors?.count ?? 0
        }
        else if collectionView == collectionViewTopics {
            
            //Topics CollectionView
            return arrTopics?.count ?? 0
        }
        
        else if collectionView == collectionViewPlaces {
            
            //Places CollectionView
            return arrLocations?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionViewChannels {
           
            //Channels CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sugChannelCC", for: indexPath) as! sugChannelCC

            if let channel = arrChannels?[indexPath.row] {
                cell.setupCellSourceModel(model: channel)
            }
            cell.channelButtonPressedBlock = { [self] in
                
                if let channel = arrChannels?[indexPath.row] {
                 
                    let fav = channel.favorite ?? false
                    self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav, type: .sources) { [weak self] status in
                        
                        DispatchQueue.main.async {
                            cell.isUserInteractionEnabled = true
                            if status {
                                
                                //We are updating array locally
                                self?.arrChannels?[indexPath.row].favorite = fav ? false : true
                                self?.collectionViewChannels.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
                            }
                        }
                        
                    }
                }
            }
            return cell
        }
        else if collectionView == collectionViewTopics {
            
            //Topics CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingTopicsCC", for: indexPath) as! OnboardingTopicsCC
            
            cell.btnFav.tag = indexPath.row
            cell.btnFav.addTarget(self, action: #selector(didTapTopicsFavButton), for: .touchUpInside)
            if let Topic = arrTopics?[indexPath.row] {
                
                cell.setUpReelsTopicsCells(topic: Topic)
           //     cell.viewBG.backgroundColor = cellColors[indexPath.row % cellColors.count].hexStringToUIColor()
                cell.restorationIdentifier = "topics"
            }
            return cell
        }
        else if collectionView == collectionViewAuthors {
            
            //Authors CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AuthorsFollowingCell", for: indexPath) as! AuthorsFollowingCell
            cell.btnFollow.tag = indexPath.row
            cell.btnFollow.addTarget(self, action: #selector(didTapAuthorsFavButton), for: .touchUpInside)
            if let Author = arrAuthors?[indexPath.row] {
                
                cell.setupCell(model: Author)
            }
            cell.layoutIfNeeded()
            return cell
        }
        else if collectionView == collectionViewPlaces {
            
            //Places CollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RegionsCC", for: indexPath) as! RegionsCC
            if let Location = arrLocations?[indexPath.row] {
                
                let isFav = Location.favorite ?? false
                if isFav {
                    cell.imgFav.theme_image = GlobalPicker.selectedTickMarkImage
                }
                else {
                    cell.imgFav.theme_image = GlobalPicker.unSelectedTickMarkImage
                }
                cell.lblRegion.text = Location.name?.capitalized ?? ""
                cell.viewBG.cornerRadius = 24
                cell.viewBG.borderWidth = 1.0
                cell.viewBG.borderColor = .customViewGreyColor
            }
           
            cell.lblRegion.theme_textColor = GlobalPicker.textColor
            cell.btnFav.isHidden = false
            cell.btnFav.tag = indexPath.row
            cell.btnFav.addTarget(self, action: #selector(didTapPlacesFavButton), for: .touchUpInside)
            return cell
        }
        
        return UICollectionViewCell()
    }

    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView == collectionViewChannels {
            
            if arrChannels?.isEmpty ?? false {
                return CGSize(width: 0, height: 0)
            }
            
            //Channels CollectionView
            return CGSize(width: collectionView.frame.size.width / 2.5, height: (collectionView.frame.size.height))
        }
        else if collectionView == collectionViewTopics {
            
            if arrTopics?.isEmpty ?? false {
                return CGSize(width: 0, height: 0)
            }

            //Topics CollectionView
            return CGSize(width: 245 , height: collectionView.frame.size.height)
          //  return CGSize(width: 160, height: (collectionView.frame.size.height))
        }
        else if collectionView == collectionViewAuthors {
            
            if arrAuthors?.isEmpty ?? false {
                return CGSize(width: 0, height: 0)
            }


            //Authors CollectionView
            return CGSize(width: collectionView.frame.size.height - 38, height: (collectionView.frame.size.height))
        }
        else {
            
            if arrLocations?.isEmpty ?? false {
                return CGSize(width: 0, height: 0)
            }

            
            //Default is for Places collectionView
            if let locationName = self.arrLocations?[indexPath.row].name {
                
                let itemSize = locationName.size(withAttributes: [
                    
                    NSAttributedString.Key.font : UIFont(name: Constant.FONT_Mulli_BOLD, size: 12) ?? "CALIFORNIA"
                ])
                return CGSize(width: itemSize.width + 80, height: 60)
            }
            
           // return CGSize(width: 95, height: (collectionView.frame.size.height))
        }
        return CGSize(width: 180, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        

        if collectionView == collectionViewChannels {

            //Channels CollectionView
            if let channel = arrChannels?[indexPath.row] {
                
                self.performWSGoToChannelDetailsScreen(channel.id ?? "")
            }
        }
        else if collectionView == collectionViewTopics {
            
            //Topics CollectionView
            if let topic = arrTopics?[indexPath.row] {
                
                performTabSubTopic(topic)
                
            }
        }
        else if collectionView == collectionViewAuthors {
            
            //Authors CollectionView
            if let author = arrAuthors?[indexPath.row] {
                
                let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                vc.authors = [Authors(id: author.id, name: author.first_name, username: author.username, image: author.profile_image, favorite: author.favorite)]
                let navVC = AppNavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true, completion: nil)
                
            }
        }
        else if collectionView == collectionViewPlaces {
            
            //Authors CollectionView
            if let location = arrLocations?[indexPath.row] {
                openLocation(location: location)
            }
        }
    }
    
    
    func openLocation(location: Location) {
        
        //followed
        if let locArray = self.arrLocations, locArray.count > 0 {
            
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
    
    //Channel favourite button Action
    @objc func didTapChannelsFavButton(sender: UIButton) {
        
        if let cell = collectionViewChannels.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? FollowingChannelCC {
            
            cell.isUserInteractionEnabled = false
            if let channel = arrChannels?[sender.tag] {
             
                let fav = channel.favorite ?? false
                self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav, type: .sources) { [weak self] status in
                    cell.isUserInteractionEnabled = true
                    if status {
                        
                        //We are updating array locally
                        self?.arrChannels?[sender.tag].favorite = fav ? false : true
                        self?.collectionViewChannels.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                    }
                }
            }
        }
    }
    //Topics favourite button Action
    @objc func didTapTopicsFavButton(sender: UIButton) {
        
        if let cell = collectionViewTopics.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? OnboardingTopicsCC {
            
            cell.isUserInteractionEnabled = false
            if let topic = arrTopics?[sender.tag] {
             
                let fav = topic.favorite ?? false
                self.performWSToUpdateUserFollow(id: topic.id ?? "", isFav: fav, type: .topics) { [weak self] status in
                    cell.isUserInteractionEnabled = true
                    if status {
                        
                        //We are updating array locally
                        self?.arrTopics?[sender.tag].favorite = fav ? false : true
                        self?.collectionViewTopics.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                    }
                }
            }
        }
    }
    //Authors favourite button Action
    @objc func didTapAuthorsFavButton(sender: UIButton) {
        
        if let cell = collectionViewAuthors.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? AuthorsFollowingCell {
            
            cell.isUserInteractionEnabled = false
            if let author = arrAuthors?[sender.tag] {
             
                let fav = author.favorite ?? false
                self.performWSToUpdateUserFollow(id: author.id ?? "", isFav: fav, type: .authors) { [weak self] status in
                    cell.isUserInteractionEnabled = true
                    if status {
                        
                        //We are updating array locally
                        self?.arrAuthors?[sender.tag].favorite = fav ? false : true
                        self?.collectionViewAuthors.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                    }
                }
            }
        }
    }
    //Places favourite button Action
    @objc func didTapPlacesFavButton(sender: UIButton) {
        
        if let cell = collectionViewPlaces.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? FollowingChannelCC {
            
            cell.isUserInteractionEnabled = false
            if let location = arrLocations?[sender.tag] {
             
                let fav = location.favorite ?? false
                self.performWSToUpdateUserFollow(id: location.id ?? "", isFav: fav, type: .locations) { [weak self] status in
                    cell.isUserInteractionEnabled = true
                    if status {
                        
                        //We are updating array locally
                        self?.arrLocations?[sender.tag].favorite = fav ? false : true
                        self?.collectionViewPlaces.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                    }
                }
            }
        }
    }
}

//MARK: - Channels Webservices
extension FollowingVC {
    
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
        WebService.URLResponse("news/sources/followed?page=\(nextPaginate)&has_reels=\(isOpenFromReels)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let source = FULLResponse.sources, source.count > 0 {
                        
                        self.viewChannelsViewAll.isHidden = false
                        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                            self.constraintChannelsViewAllHeight.constant = 270
                            self.viewChannelsHight.constant = 30
                        }, completion: nil)
            
                        self.lblChannels.text = "Channels"
                        if self.nextPaginate.isEmpty {
                            
                            self.arrChannels = source
                        }
                        else {
                            
                            self.arrChannels! += source
                        }
                     
                        self.view.layoutIfNeeded()
                        self.collectionViewChannels.layoutIfNeeded()
                        self.collectionViewChannels.reloadData()
                        
                        if let meta = FULLResponse.meta {
                            
                            self.nextPaginate = meta.next ?? ""
                        }
                        self.isFollowing = true
                        ANLoader.hide()
                    } else{
                        
                        self.lblChannels.text = "Suggested Channels"
                        self.performWSToGetSuggestedChannels()
                        self.isFollowing = false
                        
                        self.viewChannelsViewAll.isHidden = true
                        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                            self.constraintChannelsViewAllHeight.constant = 300 - 30
                            self.viewChannelsHight.constant = 0
                        }, completion:{ _ in
                            
                            self.viewChannelsViewAll.isHidden = true
                        })
                        
                    }
                    self.followingCount = self.followingCount + 1
                    self.updateNotFollowingView()
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/followed?page=\(self.nextPaginate)", error: jsonerror.localizedDescription, code: "")

                //SharedManager.shared.showAPIFailureAlert()

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
        
        
        WebService.URLResponse("news/sources/suggested?has_reels=\(isOpenFromReels)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                if let suggested = FULLResponse.sources, suggested.count > 0 {
                    
                    self.arrChannels = suggested
                    self.collectionViewChannels.reloadData()
                }
                else {
                    self.viewChannelsViewAll.isHidden = true
                    self.constraintChannelsViewAllHeight.constant = 0
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
}

//MARK: - Topics Webservices
extension FollowingVC {
    
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
                
                if let topics = FULLResponse.topics, topics.count > 0 {
                    
                    self.viewTopicsViewAll.isHidden = false
                    UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        self.constraintTopicsViewAllHeight.constant = 188
                        self.viewTopicsHight.constant = 30
                    }, completion:{ _ in
                    })
                    
                    self.lblTopics.text = "Topics"
                    if self.nextPaginate.isEmpty {
                        
                        self.arrTopics = topics
                    }
                    else {
                        
                        self.arrTopics! += topics
                    }
                    self.collectionViewTopics.reloadData()
                    
                    if let meta = FULLResponse.meta {
                        self.nextPaginate = meta.next ?? ""
                    }
                    self.isFollowing = true
                    ANLoader.hide()
                } else{
                    
                    self.lblTopics.text = NSLocalizedString("Suggested Topics", comment: "")
                    self.performWSToGetSuggestedTopics()
                    self.isFollowing = false
                   
                    UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        self.constraintTopicsViewAllHeight.constant = 188 - 30
                        self.viewTopicsHight.constant = 0
                    }, completion:{ _ in
                        self.viewTopicsViewAll.isHidden = true
                    })
                    
                }
                self.followingCount = self.followingCount + 1
                self.updateNotFollowingView()
                
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
                
                if let suggested = FULLResponse.topics, suggested.count > 0 {
                    
                    self.arrTopics = suggested
                    self.collectionViewTopics.reloadData()
                }
                else {
                    self.viewTopicsViewAll.isHidden = true
                    self.constraintTopicsViewAllHeight.constant = 0
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
}

//MARK: - Authors Webservices
extension FollowingVC {
    
    //Followed Authors
    func performWSToGetFollowedAuthor(search: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        var query = ""
        if search.isEmpty {
 
            lblTitle.text = NSLocalizedString("Following", comment: "")

            ANLoader.showLoading(disableUI: false)
            query = "news/authors/followed?has_reels=\(isOpenFromReels)"
        }
        else {
            
            lblTitle.text = NSLocalizedString("RESULT", comment: "")

            if self.nextPaginate.isEmpty {
                ANLoader.showLoading(disableUI: false)
            }
            
            let search = search.encodeUrl()
            query = "news/authors/?query=\(search)&page=\(self.nextPaginate)"
        }
                
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(query, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(AuthorSearchDC.self, from: response)
                
                if let author = FULLResponse.authors, author.count > 0 {
                    
                    self.viewAuthorsViewAll.isHidden = false
                    UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        self.constraintAuthorsViewAllHeight.constant = 310
                        self.viewAuthorsHight.constant = 30
                    }, completion:{ _ in
                    })
                    
                    self.lblAuthors.text = "Authors"
                    if self.nextPaginate.isEmpty {
                        
                        self.arrAuthors = author
                    }
                    else {
                        
                        self.arrAuthors! += author
                    }
                    
                    self.view.layoutIfNeeded()
                    self.collectionViewAuthors.layoutIfNeeded()
                    self.collectionViewAuthors.reloadData()
                    
                    if let meta = FULLResponse.meta {
                        self.nextPaginate = meta.next ?? ""
                    }
                    self.isFollowing = true
                    ANLoader.hide()
                    
                } else{
                    self.lblAuthors.text = "Suggested Authors"
                    self.performWSToGetSuggestedAuthors()
                    self.isFollowing = false
                
                    self.viewAuthorsViewAll.isHidden = true
                    UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        self.constraintAuthorsViewAllHeight.constant = 280 - 30
                        self.viewAuthorsHight.constant = 0
                    }, completion:{ _ in
                        self.viewAuthorsViewAll.isHidden = true
                    })
                    
                }
                self.followingCount = self.followingCount + 1
                self.updateNotFollowingView()
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetSuggestedAuthors() {

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/authors/suggested", method: .get, parameters: nil, headers: token, withSuccess: { (response) in

            do{
                let FULLResponse = try
                    JSONDecoder().decode(suggestedAuthorsDC.self, from: response)

                if let authors = FULLResponse.authors {
                    
                    self.arrAuthors = authors
                    self.collectionViewAuthors.reloadData()
                }

            } catch let jsonerror {

                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/reels/suggested", error: jsonerror.localizedDescription, code: "")
            }

        }) { (error) in

            print("error parsing json objects",error)
        }
    }
}

//MARK: - Places Webservices
extension FollowingVC {

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
                    
                    self.viewPlacesViewAll.isHidden = false
                    UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        self.constraintPlacesViewAllHeight.constant = 150
                        self.viewPlacesHight.constant = 30
                    }, completion:{ _ in
                    })
                    
                    self.lblPlaces.text = "Places"
                    if self.nextPaginate.isEmpty {
                        
                        self.arrLocations = locs
                    }
                    else {
                                                
                        self.arrLocations! += locs
                    }
               
                    self.collectionViewPlaces.reloadData()
                    
                    if let meta = FULLResponse.meta {
                        self.nextPaginate = meta.next ?? ""
                    }
                    self.isFollowing = true
                    ANLoader.hide()
                } else{
                    self.lblPlaces.text = "Suggested Places"
                    self.performWSToGetSuggestedLocations()
                    self.isFollowing = false
                    
                    UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                        self.constraintPlacesViewAllHeight.constant = 180 - 30
                        self.viewPlacesHight.constant = 0
                    }, completion:{ _ in
                        self.viewPlacesViewAll.isHidden = true
                    })
                    
                }
                self.followingCount = self.followingCount + 1
                self.updateNotFollowingView()

            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/locations/followed?page=\(self.nextPaginate)", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            self.updateNotFollowingView()

        }) { (error) in

            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetSuggestedLocations() {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/locations/suggested", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                if let suggested = FULLResponse.locations {
                    
                    self.arrLocations = suggested
                    self.collectionViewPlaces.reloadData()
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/locations/suggested", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
            ANLoader.hide()
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

//MARK: - Update User Follow Webservices
extension FollowingVC {
    
    func performWSToUpdateUserFollow(id:String, isFav: Bool, type: searchType, completionHandler: @escaping CompletionHandler) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        var params = ["topics":id]
        var url = isFav ? "news/topics/unfollow" : "news/topics/follow"
        if type == .topics {
            if isFav {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedTopic, topics_id: id)
            }
            else {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.followTopic, topics_id: id)

            }
        }
        if type == .sources {
            params = ["sources":id]
            url = isFav ? "news/sources/unfollow" : "news/sources/follow"
            if isFav {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedSource, topics_id: id)
            }
            else {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.followSource, topics_id: id)
            }
        }
        if type == .locations {
            params = ["locations":id]
            url = isFav ? "news/locations/unfollow" : "news/locations/follow"
            
            if isFav {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedLocation, topics_id: id)
            }
            else {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.followLocation, topics_id: id)
            }
            
        }
        if type == .authors {
            params = ["authors":id]
            url = isFav ? "news/authors/unfollow" : "news/authors/follow"
            
            if isFav {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedAuthor, author_id: id)
            }
            else {
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.followAuthor, author_id: id)
            }
            
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
}

extension FollowingVC {
    
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
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
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

