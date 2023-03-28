//
//  ReelsCategoryVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 04/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SwiftTheme
//import Lottie

protocol ReelsCategoryVCDelegate: AnyObject {
    func reelsCategoryVCDismissed()
}
class ReelsCategoryVC: UIViewController {

    @IBOutlet weak var imgSelectionForYou: UIImageView!
    @IBOutlet weak var imgSelectionFollowing: UIImageView!
    @IBOutlet weak var imgSelectionCommunity: UIImageView!
    
    
    @IBOutlet weak var lblForYou: UILabel!
//    @IBOutlet weak var lblEdition: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblCommunity: UILabel!
//    @IBOutlet weak var lblViewAll: UILabel!
//    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var viewDivider: UIView!
    
    
//    @IBOutlet weak var constraintEditionViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var viewEditionContainer: UIView!
    @IBOutlet weak var viewFollowing: UIView!
    @IBOutlet weak var lblTopics: UILabel!
    @IBOutlet weak var lblSuggested: UILabel!
    @IBOutlet weak var collectionViewChannels: UICollectionView!
    @IBOutlet weak var collectionViewSuggested: UICollectionView!
    @IBOutlet weak var viewTopics: UIView!
    @IBOutlet weak var viewSuggested: UIView!
    
    weak var delegate: ReelsCategoryVCDelegate?
    var hasFollowing: Bool?
    var souceArray = [ChannelInfo]()
    var suggestedTopicsArray = [TopicData]()
//    var nextPaginateTopics = ""
//    var nextPaginateTopicsSuggested = ""
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setLocalization()
        
        viewDivider.backgroundColor = "#090909".hexStringToUIColor()
        viewTopics.isHidden = true
        viewSuggested.isHidden = true
        performWSToGetSuggestedTopics(paginate: "")
        
        self.view.layoutIfNeeded()
        setReelCategoryUI()
        
        
//        performWSToCheckFollowing(selectDefault: false)

        
        registerCell()
        collectionViewChannels.delegate = self
        collectionViewChannels.dataSource = self
        collectionViewSuggested.delegate = self
        collectionViewSuggested.dataSource = self
        
    }
    

    
    // MARK: - Methods
    func setLocalization() {
        
        lblForYou.text = NSLocalizedString("For You", comment: "").uppercased()
        lblCommunity.text = NSLocalizedString("Community", comment: "").uppercased()
        lblFollowing.text = NSLocalizedString("Following", comment: "").uppercased()
        
        lblTopics.text = NSLocalizedString("Suggested Channels", comment: "")
        lblSuggested.text = NSLocalizedString("Suggested Topics", comment: "")
        
        lblForYou.addTextSpacing(spacing: 1)
        lblCommunity.addTextSpacing(spacing: 1)
        lblFollowing.addTextSpacing(spacing: 1)
        
    }
    
    func registerCell() {
        
        collectionViewChannels.register(UINib(nibName: "sugChannelCC", bundle: nil), forCellWithReuseIdentifier: "sugChannelCC")
        collectionViewSuggested.register(UINib(nibName: "OnboardingTopicsCC", bundle: nil), forCellWithReuseIdentifier: "OnboardingTopicsCC")

    }
    
    
    
    
    // MARK: - Buttons
    @IBAction func didTapBackButton(_ sender: Any) {
        
        delegate?.reelsCategoryVCDismissed()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setReelCategoryUI() {
        
        let category = SharedManager.shared.getSelectedReelsCategory()
        
        imgSelectionForYou.image = UIImage(named: "icn_radio_unselected")
        imgSelectionFollowing.image = UIImage(named: "icn_radio_unselected")
        imgSelectionCommunity.image = UIImage(named: "icn_radio_unselected")
        
        if category == 0 {
            
            imgSelectionForYou.image = UIImage(named: "icn_radio_selected")
        } else if category == 1 {
            
            imgSelectionFollowing.image = UIImage(named: "icn_radio_selected")
        } else {
            
            imgSelectionCommunity.image = UIImage(named: "icn_radio_selected")
        }
        
    }
    
    @IBAction func didSelectForYou(_ sender: Any) {
        
        SharedManager.shared.setSelectedReelsCategory(category: .foryou)
        setReelCategoryUI()
        
        didTapBackButton(UIButton())
    }
    
    @IBAction func didSelectFollowing(_ sender: Any) {
        
        SharedManager.shared.setSelectedReelsCategory(category: .following)
        setReelCategoryUI()
        
        didTapBackButton(UIButton())
        
//        if self.hasFollowing != nil {
//
//            if (self.hasFollowing ?? false) {
//
//                SharedManager.shared.setSelectedReelsCategory(category: .following)
//                setReelCategoryUI()
//
//                didTapBackButton(UIButton())
//            } else {
//
//                //FollowingVC
//                let vc = FollowingVC.instantiate(fromAppStoryboard: .Channel)
//                vc.delegate = self
//                vc.isOpenFromReels = true
//                let nav = AppNavigationController(rootViewController: vc)
//                nav.modalPresentationStyle = .fullScreen
//                self.present(nav, animated: true, completion: nil)
//
//            }
//        }
        
    }
    
    @IBAction func didSelectCommuniy(_ sender: Any) {
        
        SharedManager.shared.setSelectedReelsCategory(category: .community)
        setReelCategoryUI()
        
        didTapBackButton(UIButton())
    }
    
//    @IBAction func didTapSettings(_ sender: UIButton) {
//
//        //Editions
//        let vc = EditionVC.instantiate(fromAppStoryboard: .registration)
//        vc.modalPresentationStyle = .overFullScreen
//        vc.delegate = self
//        vc.isForceDarkTheme = true
//        self.present(vc, animated: true, completion: nil)
//
//    }
    
    
}


// MARK: - Webservices
extension ReelsCategoryVC {
    
    
    func performWSToCheckFollowing(selectDefault: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
//        self.viewFollowing.isUserInteractionEnabled = false
        WebService.URLResponse("news/reels/info", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(FOLLOWINGCHECKDC.self, from: response)
                
                if (FULLResponse.has_following ?? false) {
                    
                    if selectDefault {
                        SharedManager.shared.setSelectedReelsCategory(category: .following)
                        self.setReelCategoryUI()
                    }
                    
                    self.viewFollowing.isUserInteractionEnabled = true
                    
                    self.hasFollowing = true
                }
                else {
//                    self.viewFollowing.isUserInteractionEnabled = false
                    self.viewFollowing.isUserInteractionEnabled = true
                    self.hasFollowing = false
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/editions/followed", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    
    //Followed Topics
    func performWSToGetSuggestedChannels(paginate: String) {

        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
//        if self.nextPaginateTopics.isEmpty {
//            ANLoader.showLoading(disableUI: true)
//        }
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/suggested?has_reels=\(true)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do {
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                if paginate == "" {
                    self.souceArray.removeAll()
                }
                
                if let sources = FULLResponse.sources, sources.count > 0 {
                    
                    if self.souceArray.count > 0 {
                        self.souceArray += sources
                    } else {
                        self.souceArray = sources
                    }
                    
                }
                self.collectionViewChannels.reloadData()
                
            } catch let jsonerror {
                
                ANLoader.hide()
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/suggested?has_reels=\(true)", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetSuggestedTopics(paginate: String) {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/topics/suggested?has_reels=\(true)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(TopicDC.self, from: response)
                
                if paginate == "" {
                    self.suggestedTopicsArray.removeAll()
                    
                    self.performWSToGetSuggestedChannels(paginate: "")
                }
                
                if let suggested = FULLResponse.topics, suggested.count > 0 {
                    
                    if self.souceArray.count > 0 {
                        self.suggestedTopicsArray += suggested
                    } else {
                        self.suggestedTopicsArray = suggested
                    }
                    
                }
                self.collectionViewSuggested.reloadData()
                
            } catch let jsonerror {
                
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/topics/suggested?has_reels=\(true)", error: jsonerror.localizedDescription, code: "")
            }
            
            ANLoader.hide()
            
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
}


extension ReelsCategoryVC: FollowingVCDelegate {
    
    func didTapBack() {
        
        performWSToCheckFollowing(selectDefault: true)
    }
}



extension ReelsCategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if souceArray.count > 0 {
            viewTopics.isHidden = false
        } else {
            viewTopics.isHidden = true
        }
        if suggestedTopicsArray.count > 0 {
            viewSuggested.isHidden = false
        } else {
            viewSuggested.isHidden = true
        }
        
        if collectionView == collectionViewChannels {
            return souceArray.count
        } else {
            return suggestedTopicsArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == collectionViewChannels {
           
            //Channels
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sugChannelCC", for: indexPath) as! sugChannelCC
            
            let channel = souceArray[indexPath.row]
            cell.setupCell(model: channel)
            
            cell.delegate = self
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingTopicsCC", for: indexPath) as! OnboardingTopicsCC
            let topic = suggestedTopicsArray[indexPath.row]
            cell.setUpReelsTopicsCells(topic: topic)
            cell.viewBG.backgroundColor = Constant.cellColors[indexPath.row % Constant.cellColors.count].hexStringToUIColor()
            cell.restorationIdentifier = "suggested"
            cell.delegate = self
            return cell
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Topics CollectionView
        var topicName = ""
        if collectionView == collectionViewChannels {
            topicName = souceArray[indexPath.row].name ?? ""
            return CGSize(width:  collectionView.frame.size.height * 0.8, height: collectionView.frame.size.height)
        } else {
            topicName = suggestedTopicsArray[indexPath.row].name ?? ""
            return CGSize(width: 245, height: collectionView.frame.size.height / 2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if collectionView == collectionViewChannels {
            let channel = self.souceArray[indexPath.item]
            openChannels(channel: channel)
        } else {
            var topicName = ""
            topicName = suggestedTopicsArray[indexPath.row].name ?? ""
            openTopic(text: topicName)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func openTopic(text: String) {
        let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
        vc.titleText = "\(text)"
        vc.isBackButtonNeeded = true
        vc.modalPresentationStyle = .fullScreen
//        vc.delegate = self
        vc.isOpenFromTags = true
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func openChannels(channel: ChannelInfo?) {
        
        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
        detailsVC.channelInfo = channel
        //detailsVC.delegateVC = self
        //detailsVC.isOpenFromDiscoverCustomListVC = true
        detailsVC.modalPresentationStyle = .fullScreen
        let nav = AppNavigationController(rootViewController: detailsVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
    }
    
}


extension ReelsCategoryVC: OnboardingTopicsCCDelegate {
    
    func didTapAddButton(cell: OnboardingTopicsCC) {
        
        guard let indexPath = collectionViewSuggested.indexPath(for: cell) else { return }
        suggestedTopicsArray[indexPath.row].favorite = !(suggestedTopicsArray[indexPath.row].favorite ?? false)
        collectionViewSuggested.reloadItems(at: [indexPath])
        
        SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [suggestedTopicsArray[indexPath.row].id ?? ""], isFav: (suggestedTopicsArray[indexPath.row].favorite ?? false), type: .topics) { status in
            
            if status {
                print("status", status)
            } else {
                print("status", status)
            }
        }
        
        SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true
    }
}


extension ReelsCategoryVC: sugChannelCCDelegate {
    
    func addChannelTapped(cell: sugChannelCC) {
        
        guard let indexPath = collectionViewChannels.indexPath(for: cell) else { return }
        souceArray[indexPath.row].favorite = !(souceArray[indexPath.row].favorite ?? false)
        collectionViewChannels.reloadItems(at: [indexPath])
        
        SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [souceArray[indexPath.row].id ?? ""], isFav: (souceArray[indexPath.row].favorite ?? false), type: .sources) { status in
            
            if status {
                print("status", status)
            } else {
                print("status", status)
            }
        }
        
        SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true
    }
}
