
//
//  userTopicVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 22/06/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire

protocol userTopicVCDelegate: AnyObject {
    
    func setTopicsForAppContent(Topics: [TopicData], TopicsName: [String])
}


class userTopicVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnClearSerach: UIButton!
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var clvTopics: UICollectionView!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var viewContinue: UIView!
    @IBOutlet weak var viewNoSearch: UIView!
    
    @IBOutlet weak var viewBottomShadow: GradientShadowView!
    
    @IBOutlet weak var constraintContinueViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomSpaceOfContinueView: NSLayoutConstraint!
 //   @IBOutlet weak var lblDescr: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //Variables
    var topicsIDsArray =  [String]()
    var mainTopicsIDsArray =  [String]()
    var followtopicsIDsArray =  [String]()
    var unFollowtopicsIDsArray =  [String]()
    
    var topicsArray = [TopicData]()
    var selectedTopicsArr = [String]()
    var updatedTopicsArr = [TopicData]()
    
    //PAGINATION VARIABLES
    private var nextPaginate = ""

    var isSearchCall = false
    var isTopicFromTab = false
    var isFromOnboarding = false
    weak var delegate: userTopicVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupLocalization()
        lblContinue.text = NSLocalizedString("CONTINUE", comment: "")
        viewContinue.backgroundColor = Constant.appColor.purple
        lblContinue.textColor = UIColor.white
        self.btnBack.isUserInteractionEnabled = true
        
        if isTopicFromTab {
            
            self.view.theme_backgroundColor = GlobalPicker.backgroundColor
            btnHelp.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
            lblTitle.theme_textColor = GlobalPicker.textColor
            imgBack.theme_image = GlobalPicker.imgBack
            
            viewBottomShadow.topColor = UIColor.clear
            viewBottomShadow.bottomColor = MyThemes.current == .dark ? UIColor.black : UIColor.clear
            viewBottomShadow.shadowColor = MyThemes.current == .dark ? UIColor.black : UIColor.clear
        }
        
        txtSearch.theme_tintColor = GlobalPicker.searchTintColor
        txtSearch.theme_textColor = GlobalPicker.textColor
        //txtSearch.theme_placeholderAttributes = GlobalPicker.textPlaceHolder
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        self .performWSToGetAllTopics(searchText: "")
        self .txtSearch.delegate = self
        self .txtSearch.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        btnHelp.addTextSpacing(spacing: 2.0)
        lblContinue.addTextSpacing(spacing: 2.0)
        
        lblTitle.setLineSpacing(lineSpacing: 5.0)
        lblTitle.sizeToFit()
        
        clvTopics.register(UINib(nibName: "OnboardingTopicsCC", bundle: nil), forCellWithReuseIdentifier: "OnboardingTopicsCC")
        
        if self.isFromOnboarding {
            
            txtSearch.tintColor = .white
            txtSearch.textColor = .white
            txtSearch.placeholderColor = "4D4D4D".hexStringToUIColor()
          //  view.backgroundColor = .black
        }
 
    }
    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.txtSearch.semanticContentAttribute = .forceRightToLeft
                self.txtSearch.textAlignment = .right
                self.btnHelp.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
            }
            
        } else {
            DispatchQueue.main.async {
                self.txtSearch.semanticContentAttribute = .forceLeftToRight
                self.txtSearch.textAlignment = .left
                self.btnHelp.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
            }
        }
    }
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Topics", comment: "")
      //  lblDescr.text = NSLocalizedString("Pick topics to start reading\nand saving articles", comment: "")
        txtSearch.placeholder = NSLocalizedString("Search", comment: "")
        btnHelp.setTitle(NSLocalizedString("HELP", comment: ""), for: .normal)
        
    }
    
    
    override func viewDidLayoutSubviews() {
    
        viewContinue.layer.cornerRadius = viewContinue.frame.size.height / 2
        viewContinue.clipsToBounds = true
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        if self.isFromOnboarding {
            
            self.delegate?.setTopicsForAppContent(Topics: self.updatedTopicsArr, TopicsName: self.selectedTopicsArr)
            self.didTapBack(self)
            
        }
        else {
            
            if isTopicFromTab {
                performWSToUpdateUserTopics()
            }
            else {
                
                self.performWSToUpdateUserTopics()
            }
        }
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
        
        let vc = helpCenterVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     
        self.view.endEditing(true)
        return true
    }
    
    func updateButtonTitle() {
        
        if isTopicFromTab { return }
        
        if topicsIDsArray.count >= 3 {
            
            lblContinue.text = NSLocalizedString("CONTINUE", comment: "")
            viewContinue.backgroundColor = Constant.appColor.purple
            lblContinue.textColor = UIColor.white
        }
        else {
            
            lblContinue.text = NSLocalizedString("FOLLOW 3 TO CONTINUE", comment: "")
            viewContinue.backgroundColor = Constant.appColor.btnCustomGrey
            lblContinue.textColor = Constant.appColor.customGrey
        }
    }
    
    func isSelectedTopics(_ topic: TopicData) -> Bool {
        
        if self.topicsIDsArray.contains(topic.id ?? "") {
            
            return true
        }
        else {
            
            return false
        }
    }
}

//MARK:- UICollectionView Delegate and DataSource

extension userTopicVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return topicsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingTopicsCC", for: indexPath) as! OnboardingTopicsCC
        cell.layoutIfNeeded()
        
        if topicsArray.count > 0 && topicsArray.count > indexPath.row {
            
            cell.btnFav.isHidden = isFromOnboarding ? true : false
            let topics = self.topicsArray[indexPath.row]
            if self.isFromOnboarding {
                
                let isFav = self.selectedTopicsArr.contains(topics.id ?? "")
                cell.setupTopicCell(topic: topics, isFavorite: isFav ? true : false)
            }
            else {
                
                cell.setupTopicCell(topic: topics, isFavorite: self.isSelectedTopics(topics))
            }

            self.viewBottomShadow.isHidden = false
            if indexPath.row == self.topicsArray.count - 1 {
                print("Start Index: \(self.nextPaginate)")
                if !(nextPaginate.isEmpty) {
                    performWSToGetAllTopics(searchText: "")
                }
                else {
                    self.viewBottomShadow.isHidden = true
                }
                print("Load More Data")
            }
            
            return cell
        }

        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
   //     let cell = clvTopics.cellForItem(at: indexPath) as? OnboardingTopicsCC
        self.didTapAddRemoveDiscover(indexPath: indexPath)
    }
    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 245 , height: 106)
    }
            
    //VERTICAL
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return 0 }
    
    //HORIZONTAL
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return 0 }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    @objc func didTapAddRemoveDiscover(indexPath: IndexPath) {
                
     //   let row = sender.tag
      //  let indexPath = IndexPath(item: row, section: 0)

        let cell = clvTopics.cellForItem(at: indexPath) as? OnboardingTopicsCC
        if self.isFromOnboarding {
            
            let topic = self.topicsArray[indexPath.row]
            
            if self.selectedTopicsArr.contains(topic.id ?? "") {
                
                
                selectedTopicsArr.remove(object: topic.id ?? "")
                cell?.imgFav.image = UIImage(named: "plus")
            }
            else {
                
                if self.updatedTopicsArr.contains(where: {$0.name == topic.name ?? ""}) {
                    
                    if let index = self.updatedTopicsArr.firstIndex(where: { $0.name == topic.name ?? "" }) {
                        
                        self.updatedTopicsArr.remove(at: index)
                    }
                    self.updatedTopicsArr.insert(topic, at: 0)
                    
                }
                else {
                    
                    self.updatedTopicsArr.insert(topic, at: 0)
                }
                
                selectedTopicsArr.append(topic.id ?? "")
                cell?.imgFav.image = UIImage(named: "tickUnselected")
            }
        }
        else {
            
            let topic = topicsArray[indexPath.row]
            
            let isExist = self.isSelectedTopics(topic)
            if isExist {
                
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedTopic, eventDescription: "")
                
                if !(self.unFollowtopicsIDsArray.contains(topic.id ?? "")) {
                    
                    if self.followtopicsIDsArray.contains(topic.id ?? "") {
                        
                        self.followtopicsIDsArray.remove(object: topic.id ?? "")
                    }
                    if (self.mainTopicsIDsArray.contains(topic.id ?? "") ){
                        
                        self.unFollowtopicsIDsArray.append(topic.id ?? "")
                    }
                }
                
                self.topicsIDsArray.remove(object: topic.id ?? "")
                self.clvTopics.reloadItems(at: [IndexPath(item: indexPath.row, section: 0)])
                //    self.updateButtonTitle()
            }
            else {
                
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.followTopic, eventDescription: "")
                
                if !(self.followtopicsIDsArray.contains(topic.id ?? "")) {
                    
                    if self.unFollowtopicsIDsArray.contains(topic.id ?? "") {
                        
                        self.unFollowtopicsIDsArray.remove(object: topic.id ?? "")
                    }
                    
                    if !(self.mainTopicsIDsArray.contains(topic.id ?? "") ){
                        
                        self.followtopicsIDsArray.append(topic.id ?? "")
                    }
                }
                
                self.topicsIDsArray.append(topic.id ?? "")
                self.clvTopics.reloadItems(at: [indexPath])
            }
        }
    }
}


//MARK:- Webservices
extension userTopicVC {
    
    func performWSToGetUserTopics() {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
      //  ANLoader.showLoading(disableUI: true)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/topics/followed", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(TopicDC.self, from: response)
                
                if let topics = FULLResponse.topics {
                     
                    self.topicsIDsArray.removeAll()
                    self.mainTopicsIDsArray.removeAll()
                    for topic in topics {

                        self.topicsIDsArray.append(topic.id ?? "")
                    }
                    self.mainTopicsIDsArray = self.topicsIDsArray
                    
                }
                self.clvTopics.reloadData()

            } catch let jsonerror {

                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/topics/followed", error: jsonerror.localizedDescription, code: "")
            }

        }) { (error) in

            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetAllTopics(searchText: String) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
    
        var url = ""
        if searchText == "" {
            
            if self.nextPaginate.isEmpty { ANLoader.showLoading(disableUI: true) }
            url = "news/topics?page=\(nextPaginate)"
        }
        else{
            
            let searchText = searchText.encodeUrl()
            url = "news/topics?query=\(searchText)&page=\(nextPaginate)"
        }

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(TopicDC.self, from: response)
               
                if let topics = FULLResponse.topics {
                    
                    self.clvTopics.isHidden = false
                    self.viewNoSearch.isHidden = true
                    if self.isSearchCall {
                        
                        if self.nextPaginate.isEmpty {
                    
                            self.topicsArray.removeAll()
                            self.topicsArray = topics
                        }
                        else {
                            
                            self.topicsArray += topics
                        }
                    }
                    else {
                        self.topicsArray += topics
                    }
                    
                    if self.nextPaginate == "" && self.isSearchCall == false {
                        
                        self.performWSToGetUserTopics()
                    }
                    else{
                        
                        self.clvTopics.reloadData()
                        if self.topicsArray.count > 0 {
                          
                            self.clvTopics.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                        }
                        else {
                            
                            self.viewNoSearch.isHidden = false
                            self.clvTopics.isHidden = true
                        }
                    }
                    
                    if searchText == "" {

                        self.isSearchCall = false
                    }
                    
                    if let meta = FULLResponse.meta {
                        
                        self.nextPaginate = meta.next ?? ""
                    }
                }
                else {
                    
                    self.viewNoSearch.isHidden = false
                    self.clvTopics.isHidden = true

                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
            }
            ANLoader.hide()
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUpdateUserTopics() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        var topicIdArr1 = [String]()
        for topic in followtopicsIDsArray {

            topicIdArr1.append("follow=\(topic)")
        }
        let query1 = topicIdArr1.joined(separator: "&")
        
       
        var topicIdArr2 = [String]()
        for topic in unFollowtopicsIDsArray {

            topicIdArr2.append("unfollow=\(topic)")
        }
        let query2 = topicIdArr2.joined(separator: "&")
        
        let finalQuery = query1 + "&" + query2

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse("news/topics/followed?\(finalQuery)", method: .patch, parameters: [String: Any](), headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateTopicDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    
                }
                
                if self.isTopicFromTab {
                    
                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    self.dismiss(animated: true, completion: nil)
                }
                else {
//                    let vc = UserChannelsVC.instantiate(fromAppStoryboard: .registration)
//                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    self.performWSToUserConfig()
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/topics/followed?\(finalQuery)", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}


//MARK: - Search List
extension userTopicVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        self.isSearchCall = true
        self.btnClearSerach.isHidden = false
        
        WebService.cancelAPIRequest()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getTextOnStopTyping), object: textField)
        if let searchText = textField.text, !(searchText.isEmpty) {
           
            if searchText.count == 1 {
                
                self.topicsArray.removeAll()
                self.clvTopics.reloadData()
            }
            
            print("Search Text --- \(searchText.count)")
            self.nextPaginate = ""
           // self.performWSToGetAllTopics(searchText: searchText)
            self.perform(#selector(getTextOnStopTyping), with: textField, afterDelay: 0.5)
            
        }
        else {
            
            self.view.endEditing(true)
            self.btnClearSerach.isHidden = true
            self.nextPaginate = ""
            self.topicsArray.removeAll()
            self.performWSToGetAllTopics(searchText: "")
        }
    }
    
    @IBAction func didTapClearSearch(_ sender: Any) {
        
        self.view.endEditing(true)
        self.btnClearSerach.isHidden = true
        self.txtSearch.text = ""
        self.nextPaginate = ""
        self.topicsArray.removeAll()
        self.performWSToGetAllTopics(searchText: "")
    }
    
    @objc func getTextOnStopTyping(_ textField: UITextField) {

        self.performWSToGetAllTopics(searchText: textField.text ?? "")
    }
}


extension userTopicVC {
    
    // Check channel or topic selection required
    func performWSToUserConfig() {
        
        ANLoader.showLoading(disableUI: true)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userConfigDC.self, from: response)
                
                // Load default theme settings
                SharedManager.shared.setThemeAutomatic()
                self.appDelegate.setHomeVC()
                
            } catch let jsonerror {
            
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
}
