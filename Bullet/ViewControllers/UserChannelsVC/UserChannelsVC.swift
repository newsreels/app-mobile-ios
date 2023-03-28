//
//  UserChannelsVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 24/10/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire

class UserChannelsVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnClearSerach: UIButton!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var viewContinue: UIView!
    @IBOutlet weak var viewBottomShadow: GradientShadowView!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var constraintContinueViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewCollectionViewBackground: UIView!
    @IBOutlet weak var lblDescr: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    var sourcesArray = [ChannelInfo]()
    var categorizeSourcesArray = [Categories]()
    
    var isSourceFromTab = false


    //PAGINATION VARIABLES
    private var nextPaginate = ""

    var isSearchCall = false
    var isCategories = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupLocalization()
        if isSourceFromTab {
            
            self.view.theme_backgroundColor = GlobalPicker.backgroundColor
            btnHelp.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
            lblTitle.theme_textColor = GlobalPicker.textColor
        
            viewBottomShadow.shadowColor = MyThemes.current == .dark ? UIColor.black : UIColor.clear
            viewBottomShadow.bottomColor = MyThemes.current == .dark ? UIColor.black : UIColor.clear
            imgBack.theme_image = GlobalPicker.imgBack
        }
        
        viewCollectionViewBackground.backgroundColor = MyThemes.current == .dark ? UIColor.black : UIColor.clear
        
        lblContinue.text = NSLocalizedString("CONTINUE", comment: "")
        viewContinue.backgroundColor = Constant.appColor.purple
        lblContinue.textColor = UIColor.white
        
        txtSearch.theme_tintColor = GlobalPicker.searchTintColor
        txtSearch.theme_textColor = GlobalPicker.textColor
        //txtSearch.theme_placeholderAttributes = GlobalPicker.textPlaceHolder
        /*        switch UIDevice().type {
            
        case .iPhone5, .iPhone5C, .iPhone5S:
            
            //self.constraintContinueViewHeight.constant = 42
            self.constraintContinueViewHeight.constant = 20
            self.lblContinue.font = UIFont(name: Constant.FONT_Mulli_EXTRABOLD, size: 10)!
            self.lblTitle.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 22)!
            break
            
        case .iPhone6, .iPhone7, .iPhone8, .iPhone6S:
            
          //  self.constraintContinueViewHeight.constant = 42
            self.constraintContinueViewHeight.constant = 20
            self.lblContinue.font = UIFont(name: Constant.FONT_Mulli_EXTRABOLD, size: 10)!
            self.lblTitle.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 22)!
            break
            
        case .iPhone6Plus, .iPhone6SPlus, .iPhone7Plus, .iPhone8Plus:
            
         //   self.constraintContinueViewHeight.constant = 46
            self.constraintContinueViewHeight.constant = 20
            self.lblContinue.font = UIFont(name: Constant.FONT_Mulli_EXTRABOLD, size: 12)!
            break
            
        case .iPhone11Pro, .iPhoneX, .iPhoneXS:
            
         //   self.constraintContinueViewHeight.constant = 50
            self.constraintContinueViewHeight.constant = 30
            self.lblContinue.font = UIFont(name: Constant.FONT_Mulli_EXTRABOLD, size: 12)!
            self.lblTitle.font = UIFont(name: Constant.FONT_Mulli_BOLD, size: 23.6)!
            break
            
        default:
            
            //self.constraintContinueViewHeight.constant = 54
            self.constraintContinueViewHeight.constant = 30
            self.lblContinue.font = UIFont(name: Constant.FONT_Mulli_EXTRABOLD, size: 13)!
            break
        }
        */
        SharedManager.shared.sourcesIDsArray.removeAll()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        self .txtSearch.delegate = self
        self .txtSearch.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        btnHelp.addTextSpacing(spacing: 2.0)
        lblContinue.addTextSpacing(spacing: 2.0)
        lblTitle.setLineSpacing(lineSpacing: 6.0)
        lblTitle.sizeToFit()
        btnContinue.addTextSpacing(spacing: 2.0)
        
        self .performWSToGetUserSources(searchText: "")
    }
    
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Channels", comment: "")
        lblDescr.text = NSLocalizedString("Choose from hundreds \nof news publications", comment: "")
        txtSearch.placeholder = NSLocalizedString("Search", comment: "")
        lblContinue.text = NSLocalizedString("CONTINUE", comment: "")
        btnHelp.setTitle(NSLocalizedString("HELP", comment: ""), for: .normal)
        
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
    
    
    override func viewDidLayoutSubviews() {
    
        viewContinue.layer.cornerRadius = viewContinue.frame.size.height / 2
        viewContinue.clipsToBounds = true
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapContinue(_ sender: Any) {
        
        if isSourceFromTab {
            performWSToUpdateUserSources()
        }
        else {
         //   if SharedManager.shared.sourcesIDsArray.count >= 3 {
                
                self .performWSToUpdateUserSources()
        //    }
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
    
    func updateButtonTitle(sourcesIDsArray: [String]) {
        
        if isSourceFromTab { return }
        
        if sourcesIDsArray.count >= 3 {
            
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
    
    func isSelectedSources(_ topic: ChannelInfo) -> Bool {
        
        if SharedManager.shared.sourcesIDsArray.contains(topic.id ?? "") {
            
            return true
        }
        else {
            
            return false
        }
    }
    
    func selectedSourcesIDs(sources: [String]) {
        
     // self.updateButtonTitle(sourcesIDsArray: sources)
      SharedManager.shared.sourcesIDsArray.removeAll()
      SharedManager.shared.sourcesIDsArray = sources
      print("selected Sources IDs",sources)
    }
}

//MARK: - Search List
extension UserChannelsVC: UITextFieldDelegate {

    @objc func textFieldDidChange(textField: UITextField){
        
        if let searchText = textField.text, !(searchText.isEmpty) {
            
            self.btnClearSerach.isHidden = false
            self.isSearchCall = true
            if searchText.count == 1 {
            
                self.sourcesArray.removeAll()
                self.collectionView.reloadData()
            }
            
            self.nextPaginate = ""
            self.performWSToGetUserSources(searchText: searchText)
        }
        else {
            
            
            self.view.endEditing(true)
            self.btnClearSerach.isHidden = true
            self.sourcesArray.removeAll()
            self.nextPaginate = ""
            self.performWSToGetUserSources(searchText: "")
        }
    }
    
    @IBAction func didTapClearSearch(_ sender: Any) {
        
        self.view.endEditing(true)
        self.btnClearSerach.isHidden = true
        self.sourcesArray.removeAll()
        self.nextPaginate = ""
        self.txtSearch.text = ""
        self.performWSToGetUserSources(searchText: "")
    }
}

extension UserChannelsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
        
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.sourcesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userSourcesCC", for: indexPath) as? userSourcesCC else { return UICollectionViewCell() }
    
        let sources = self.sourcesArray[indexPath.row]
        cell.imgSource.sd_setImage(with: URL(string: sources.image ?? "") , placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        //cell.imgSource.layer.cornerRadius = cell.imgSource.frame.size.width / 2
        cell.lblTitle.text = sources.name ?? ""
//        cell.viewShadow.addRoundedShadowWithColor(color: UIColor(displayP3Red: 58.0/255.0, green: 217.0/255.0, blue: 210.0/255.0, alpha: 0.25))
        cell.viewShadow.theme_backgroundColor = GlobalPicker.cellChannelBGColor

        if let lang = sources.language {
            cell.lblLanguage.text = lang.isEmpty ? "N/A" : lang
        }
        else  {
            cell.lblLanguage.text = "N/A"
        }
        
        if let global = sources.category {
            
            cell.lblLocation.text = global.isEmpty ? "N/A" : global
        }
        else {
            cell.lblLocation.text = "N/A"
        }
        
        if isSourceFromTab {
            
            cell.imgSingleDot.theme_image = GlobalPicker.imgSingleDot
            cell.lblLocation.theme_textColor = GlobalPicker.textColor
            cell.lblLanguage.theme_textColor = GlobalPicker.textColor
            
            if self.isSelectedSources(sources) {

                cell.imgSourceStatus.theme_image = GlobalPicker.imgBookmarkSelected//UIImage(named: "bookmarkSelected")
            }
            else {

                cell.imgSourceStatus.theme_image = GlobalPicker.imgBookmark //UIImage(named: "bookmark")
            }
            
            cell.lblTitle.theme_textColor = GlobalPicker.textColor
                
        }
        else {
            
            cell.lblLocation.textColor = .white
            cell.lblLanguage.textColor = .white
            
            if self.isSelectedSources(sources) {

                cell.imgSourceStatus.theme_image = GlobalPicker.imgBookmarkSelected
            }
            else {

                cell.imgSourceStatus.image = UIImage(named: "bookmark")
            }
        }

        cell.btnSelectSource.tag = indexPath.row
        cell.btnSelectSource.addTarget(self, action: #selector(didTapAddRemoveTopic), for: .touchUpInside)
        
        self.viewBottomShadow.isHidden = false
        if indexPath.row == self.sourcesArray.count - 1 {
            print("Start Index: \(self.nextPaginate)")
            
            if !(nextPaginate.isEmpty) {
                self.performWSToGetUserSources(searchText: "")
            }
            else {
                self.viewBottomShadow.isHidden = true
            }
            print("Load More Data")
        }
        
        return cell
    }
    
    @objc func didTapAddRemoveTopic(sender: UIButton) {
        
        let row = sender.tag
        let indexPath = IndexPath(item: row, section: 0)
        let source = sourcesArray[row]

        let isExist = self.isSelectedSources(source)
        if isExist {
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.unfollowedSource, channel_id: source.id ?? "")
            
            if !(SharedManager.shared.unFollowSourcesIDsArray.contains(source.id ?? "")) {
                
                if SharedManager.shared.followSourcesIDsArray.contains(source.id ?? "") {
                    
                    SharedManager.shared.followSourcesIDsArray.remove(object: source.id ?? "")
                }
                if (SharedManager.shared.mainSourcesIDsArray.contains(source.id ?? "") ){
                    
                    SharedManager.shared.unFollowSourcesIDsArray.append(source.id ?? "")
                }
            }
            
            SharedManager.shared.sourcesIDsArray.remove(object: source.id ?? "")
            self.collectionView.reloadItems(at: [indexPath])
            self.selectedSourcesIDs(sources: SharedManager.shared.sourcesIDsArray)
        }
        else {
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.followSource, channel_id: source.id ?? "")
            
            if !(SharedManager.shared.followSourcesIDsArray.contains(source.id ?? "")) {
                
                if SharedManager.shared.unFollowSourcesIDsArray.contains(source.id ?? "") {
                    
                    SharedManager.shared.unFollowSourcesIDsArray.remove(object: source.id ?? "")
                }
                
                if !(SharedManager.shared.mainSourcesIDsArray.contains(source.id ?? "") ){
                    
                    SharedManager.shared.followSourcesIDsArray.append(source.id ?? "")
                }
            }
            
            SharedManager.shared.sourcesIDsArray.append(source.id ?? "")
            self.collectionView.reloadItems(at: [indexPath])
            self.selectedSourcesIDs(sources: SharedManager.shared.sourcesIDsArray)
        }
    }
    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.frame.size.width / 2) , height: (collectionView.frame.size.width / 2) + 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? userSourcesCC {
            self.didTapAddRemoveTopic(sender: cell.btnSelectSource)
        }
    }
            
    //VERTICAL
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return 0 }
    
    //HORIZONTAL
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return 0 }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}

//MARK: - Webservices
extension UserChannelsVC {
    
    func performWSToGetUserSources(searchText:String) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        var url = ""
        if searchText.isEmpty || searchText == " " {
            
            if self.nextPaginate.isEmpty { ANLoader.showLoading(disableUI: true) }
            url = "news/sources?page=\(nextPaginate)"
        }
        else{
            
            let searchText = searchText.encodeUrl()
            url = "news/sources?query=\(searchText)&page=\(nextPaginate)"
        }

        SharedManager.shared.cancelAllCurrentAlamofireRequests()
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                if let sources = FULLResponse.sources {

                    if self.isSearchCall {
                        
                        if self.nextPaginate.isEmpty {
        
                            self.sourcesArray.removeAll()
                            self.sourcesArray = sources
                        }
                        else {
                            
                            self.sourcesArray += sources
                        }
                    }
                    else {

                        self.sourcesArray += sources
                    }
                    
                    if self.nextPaginate == "" && self.isSearchCall == false {
                        
                        self.performWSToGetUserSources()
                    }
                    else{
                        
                        self.collectionView.reloadData()
                        if self.sourcesArray.count > 0 {
                   
                            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                        }
                    }
                    
                    if searchText == "" {

                        self.isSearchCall = false
                    }
                    
                    if let meta = FULLResponse.meta {
                    
                        self.nextPaginate = meta.next ?? ""
                    }
                }
                ANLoader.hide()

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
    
    func performWSToUpdateUserSources() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        var followIdArr = [String]()
        for sources in SharedManager.shared.followSourcesIDsArray {
            
            followIdArr.append("follow=\(sources)")
        }
        let query1 = followIdArr.joined(separator: "&")
        
        var unFollowIdArr = [String]()
        for sources in SharedManager.shared.unFollowSourcesIDsArray {
            
            unFollowIdArr.append("unfollow=\(sources)")
        }
        let query2 = unFollowIdArr.joined(separator: "&")
        
        let final = query1 + "&" + query2
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse("news/sources/followed?\(final)", method: .patch, parameters: [String: Any](), headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateSourceDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    
                }
                
                if self.isSourceFromTab {
                    
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    
//                    let vc = AppThemeVC.instantiate(fromAppStoryboard: .Home)
//                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    // Load default theme settings
                    SharedManager.shared.setThemeAutomatic()
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.setHomeVC()
                }
                
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/followed?\(final)", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetUserSources() {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/followed", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
        
            do{
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)

                if let sources = FULLResponse.sources {
                     
                    SharedManager.shared.sourcesIDsArray.removeAll()
                    SharedManager.shared.mainSourcesIDsArray.removeAll()
                    for source in sources {

                        SharedManager.shared.sourcesIDsArray.append(source.id ?? "")
                        
                    }
                    SharedManager.shared.mainSourcesIDsArray = SharedManager.shared.sourcesIDsArray
                    self.collectionView.reloadData()
                 //   self.updateButtonTitle(sourcesIDsArray: SharedManager.shared.sourcesIDsArray)
                    
                }

            } catch let jsonerror {

                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/followed", error: jsonerror.localizedDescription, code: "")
            }

        }) { (error) in

            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

