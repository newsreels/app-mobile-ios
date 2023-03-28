//
//  EditionVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 13/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire

protocol EditionVCDelegate: class {
    
    func didTapRefressSettings()
}

class EditionVC: UIViewController {
    
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewNoSearch: UIView!
    @IBOutlet weak var viewTbEditions: UIView!
    @IBOutlet var lblCollectionNoSearch: [UILabel]!
    @IBOutlet weak var constraintViewNoResultBottomHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var tbEdition: UITableView!
    @IBOutlet weak var constraintViewContinueHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewBottomShadow: GradientView!
    @IBOutlet weak var viewTableBackgroundColor: UIView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var btnContinue: UIButton!
    
    var dismissKeyboard : (()-> Void)?
    private var nextPaginate = ""
    var isSearchCall = false
    //var editionsArray = [Editions]()
    var editionsArray : [TreeNode] = []
    var editionsIDsArray =  [String]()
    var maineditionsIDsArray =  [String]()
    var searchText = ""
    var isFromRegistration = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var editionsID = ""
    var urlString = ""
    weak var delegate: EditionVCDelegate?
    
   // var editionsIDsArray =  [String]()
  //  var mainEditionsIDsArray =  [String]()
    var followEditionsIDsArray =  [String]()
    var unFollowEditionsIDsArray =  [String]()
    
    var followEditionsIDsArrayTemp =  [String]()
    var unFollowEditionsIDsArrayTemp =  [String]()

    var isForceDarkTheme = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()
        if self.isFromRegistration || isForceDarkTheme {
            
            self.view.backgroundColor = .black
            self.constraintViewContinueHeight.constant = 74
            self.viewBottom.isHidden = false
            tbEdition.backgroundColor = .black
            btnHelp.isHidden = false
            viewBottom.backgroundColor = .black
            
//            viewBottomShadow.topColor = UIColor.clear
//            viewBottomShadow.bottomColor = UIColor.black
//            viewBottomShadow.shadowColor = UIColor.black
            
            txtSearch.tintColor = .white
            txtSearch.textColor = .white
            viewSearch.backgroundColor = .black
            
            lblCollectionNoSearch.forEach {
                $0.textColor = "#3D485F".hexStringToUIColor()
            }
            
//            imgBack.image = UIImage(named: "icn_back2_light")

            viewTableBackgroundColor.backgroundColor = UIColor.black
            lblTitle.textColor = .white
            
            viewBottomShadow.isHidden = true
        }
        else {
            
            self.view.theme_backgroundColor = GlobalPicker.backgroundColorEdition
            lblDescription.theme_textColor = GlobalPicker.textColor
            btnHelp.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
            btnHelp.isHidden = true
//            txtSearch.theme_textColor = GlobalPicker.textColor
//            txtSearch.theme_placeholderAttributes = GlobalPicker.textPlaceHolder
            
            viewBottom.backgroundColor = MyThemes.current == .dark ? UIColor.black : UIColor.white

//            viewBottomShadow.topColor = UIColor.clear
//            viewBottomShadow.bottomColor = MyThemes.current == .dark ? UIColor.black : UIColor.white
//            viewBottomShadow.shadowColor = MyThemes.current == .dark ? UIColor.black : UIColor.white

//            self.constraintViewContinueHeight.constant = 0
//            self.viewBottom.isHidden = true
            
            txtSearch.theme_tintColor = GlobalPicker.searchTintColor
            txtSearch.theme_textColor = GlobalPicker.searchTintColor
            viewSearch.theme_backgroundColor = GlobalPicker.viewSearchBGColor
            
            self.lblCollectionNoSearch.forEach {
                $0.theme_textColor = GlobalPicker.textColor
            }
            
            imgBack.theme_image = GlobalPicker.imgBack

            viewTableBackgroundColor.backgroundColor = MyThemes.current == .dark ?  UIColor.black : UIColor.clear
            lblTitle.theme_textColor = GlobalPicker.textColor
        }
        
        //    txtSearch.theme_tintColor = GlobalPicker.searchTintColor
        btnContinue.theme_backgroundColor = GlobalPicker.themeCommonColor
        btnContinue.addTextSpacing(spacing: 2.0)

        btnHelp.addTextSpacing(spacing: 2.0)
        
        btnClear.isHidden = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        self .txtSearch.delegate = self
        self .txtSearch.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
       
        
        self.btnBack.isUserInteractionEnabled = true
        self.performWSToGetAllEdition(searchText: "")
    }
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Edition", comment: "")
        lblDescription.text = NSLocalizedString("Pick editions to start reading\nand saving articles", comment: "")
        txtSearch.placeholder = NSLocalizedString("Search", comment: "")
        btnContinue.setTitle(NSLocalizedString("CONTINUE", comment: ""), for: .normal)
        btnHelp.setTitle(NSLocalizedString("HELP", comment: ""), for: .normal)

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    @IBAction func didTapHelp(_ sender: Any) {
        
        let vc = helpCenterVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.btnBack.isUserInteractionEnabled = false
        if self.isFromRegistration {
            
            self .performWSTologoutUser()
        }
        else {
            
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        SharedManager.shared.isTabReload = true
        SharedManager.shared.isDiscoverTabReload = true
        SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true
        
        self.performWSToUpdateUserEditions()
     //   self.performWSToUpdateEditions(id: self.editionsID, urlString: self.urlString)
       
    }
    
    @IBAction func didTapClearAction(_ sender: Any) {
        
        self.clearSearchData()
    }
}

//MARK: - Search List
extension EditionVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        self.isSearchCall = true
        self.searchText = textField.text ?? ""
        if let searchText = textField.text, !(searchText.isEmpty) {
            
            if searchText.count == 1 {
                self.editionsArray.removeAll()
                self.tbEdition.reloadData()
            }
            btnClear.isHidden = false
            self.nextPaginate = ""
            self.performWSToGetAllEdition(searchText: searchText)
            
        }
        else {
            self.view.endEditing(true)
            self.nextPaginate = ""
            self.editionsArray.removeAll()
            btnClear.isHidden = true
            self.performWSToGetAllEdition(searchText: "")
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {

            self.keyboardEvent(true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification?) {
        
            self.keyboardEvent(false)
    }
    
    func clearSearchData() {
        
        txtSearch.resignFirstResponder()
        btnClear.isHidden = true
        txtSearch.text = ""
        nextPaginate = ""
        self.view.endEditing(true)
   
        self.performWSToGetAllEdition(searchText: "")
    }

    func keyboardEvent(_ isKeyboardShow: Bool) {
        
        if isKeyboardShow {
            constraintViewNoResultBottomHeight.constant = self.view.bounds.height * 0.6
        }
        else {
            constraintViewNoResultBottomHeight.constant = self.view.bounds.height * 0.3
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return true
    }
}

//MARK:- UITableView Delegate and DataSource
extension EditionVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return editionsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch UIDevice().type {
        
        case .iPhoneXSMax, .iPhone11ProMax, .iPhoneXR, .iPhone11:
            
            return 66
            
        default:
            
            return 66
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditionCC") as! EditionCC
        cell.layoutIfNeeded()
        if self.isFromRegistration || isForceDarkTheme {
            cell.contentView.backgroundColor = .black
            cell.lblEdition.textColor = .white
        }
        else {
            cell.contentView.theme_backgroundColor = GlobalPicker.backgroundColor
            cell.lblEdition.theme_textColor = GlobalPicker.textColor
        }
        
        
        
        if editionsArray.count > 0 {
            
            let editions = self.editionsArray[indexPath.row]
                        
            if !editions.isLeaf {
                cell.imgArrow.image = (editions.isOpen ? #imageLiteral(resourceName: "icn_more_arrow_down") : #imageLiteral(resourceName: "icn_more_arrow"))
            }
            else {
                
                if editions.has_child && editions.subNodes.count > 0 {
                    cell.imgArrow.image = #imageLiteral(resourceName: "icn_more_arrow_down")
                }
                else if editions.has_child && editions.subNodes.count == 0 {
                    cell.imgArrow.image = #imageLiteral(resourceName: "icn_more_arrow")
                }
                else {
                    //cell.imgArrow.isHidden = true
                    cell.imgArrow.image = nil
                }
            }
            
            if !isSearchCall {
                
//                let flagText = !editions.isLeaf ? (editions.isOpen ? "-" : "+") : ""
//                let name = String(repeating: "    ", count: (editions.level > 1 ? editions.level : 0)) + "\(flagText)  " + editions.name
//                print("level string:...", editions.level, flagText, name)
                
                if (editions.level == 4 && !editions.selected) {
                    cell.constraintImageViewLeading.constant = 95
                    cell.constraintImageFlagWidth.constant = 0
                }
                else if (editions.level == 3 && !editions.selected) {
                    cell.constraintImageViewLeading.constant = 65
                    cell.constraintImageFlagWidth.constant = 0
                }
                else if (editions.level == 2 && !editions.selected) {
                    cell.constraintImageViewLeading.constant = 35
                    cell.constraintImageFlagWidth.constant = 0
                }
                else {
                    cell.constraintImageViewLeading.constant = 5
                    cell.constraintImageFlagWidth.constant = 26
                }
            }
            else {
                
                cell.constraintImageViewLeading.constant = 5
                cell.constraintImageFlagWidth.constant = 26
            }
            
            
            cell.lblEdition.text = editions.name.uppercased()
            cell.lblLocation.text = editions.language
            cell.lblEdition.addTextSpacing(spacing: 2)
            
            cell.imgEdition.sd_setImage(with: URL(string: editions.image), completed: nil)
            
            if self.isSelectedEditions(editions) {
                
                cell.imgStatus.image = UIImage(named: MyThemes.current == .dark ? "check" : "checkLight")
            }
            else {
                
                cell.imgStatus.image = UIImage(named: "checkmark")
            }
            
            cell.btnSelectTopic.tag = indexPath.row
            cell.btnSelectTopic.addTarget(self, action: #selector(didTapAddRemoveEdition), for: .touchUpInside)
            
            cell.imgEdition.cornerRadius = cell.imgEdition.frame.size.width / 2
            cell.imgEdition.clipsToBounds = true
            
            if indexPath.row == self.editionsArray.count - 1 {
                
                if !(nextPaginate.isEmpty) {
                    
                    performWSToGetAllEdition(searchText: self.searchText)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let node = self.editionsArray[indexPath.row]
        let nodes = node.needsDisplayNodes
        
        if !node.isOpen {
            if node.has_child {
                performWSToGetChildEdition(index: indexPath.row)
            }
        }
        else{
            
            node.isOpen = !node.isOpen
            for subNode in nodes {
                guard let index = self.editionsArray.firstIndex(of: subNode) else {
                    continue
                }
                self.editionsArray.remove(at: index)
                self.tbEdition.deleteRows(at: [IndexPath(row: index, section: 0)], with: .bottom)
            }
            
            //self.tbEdition.reloadRows(at: [indexPath], with: .none)
            if let indexPaths = self.tbEdition.indexPathsForVisibleRows {
                self.tbEdition.reloadRows(at: indexPaths, with: .fade)
            }
            else {
                self.tbEdition.reloadData()
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func isSelectedEditions(_ edition: TreeNode) -> Bool {
        
        return self.editionsIDsArray.contains(edition.id) ? true : false
    }
    
    @objc func didTapAddRemoveEdition(sender: UIButton) {
        
        let row = sender.tag
        let indexPath = IndexPath(item: row, section: 0)
        
        if self.editionsArray.count > 0 {
            
            let edition = self.editionsArray[indexPath.row]
            print("edition: \(edition.name)")
            
            let isExist = self.isSelectedEditions(edition)
            if isExist {
                
                if !(self.unFollowEditionsIDsArray.contains(edition.id)) {
                    
                    if self.followEditionsIDsArray.contains(edition.id ) {
                        
                        self.followEditionsIDsArray.remove(object: edition.id )
                    }
                    if (self.maineditionsIDsArray.contains(edition.id )){
                        
                        self.unFollowEditionsIDsArray.append(edition.id )
                    }
                }
                
                
                if self.followEditionsIDsArrayTemp.contains(edition.id) {
                    self.followEditionsIDsArrayTemp.remove(object: edition.id)
                }
                
                if !(self.unFollowEditionsIDsArrayTemp.contains(edition.id)) {
                    self.unFollowEditionsIDsArrayTemp.append(edition.id)
                }
                
                self.editionsIDsArray.remove(object: edition.id )
                self.tbEdition.reloadRows(at: [indexPath], with: .none)
            }
            else {
                
                if !(self.followEditionsIDsArray.contains(edition.id)) {
                    
                    if self.unFollowEditionsIDsArray.contains(edition.id) {
                        
                        self.unFollowEditionsIDsArray.remove(object: edition.id)
                    }
                    
                    if !(self.maineditionsIDsArray.contains(edition.id) ){
                        
                        self.followEditionsIDsArray.append(edition.id)
                    }
                }
                
                if !(self.followEditionsIDsArrayTemp.contains(edition.id)) {
                    self.followEditionsIDsArrayTemp.append(edition.id)
                }
                
                if self.unFollowEditionsIDsArrayTemp.contains(edition.id) {
                    self.unFollowEditionsIDsArrayTemp.remove(object: edition.id)
                }
                
                self.editionsIDsArray.append(edition.id)
                self.tbEdition.reloadRows(at: [indexPath], with: .none)
                //  self.updateButtonTitle()
            }
        }
    }
}

extension EditionVC {
    
    func performWSToGetAllEdition(searchText: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        var url = ""
        if searchText == "" {
            
            url = "news/editions?page=\(nextPaginate)"
        }
        else{
            
            let searchText = searchText.encodeUrl()
            url = "news/editions?query=\(searchText)&page=\(nextPaginate)"
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
      
        SharedManager.shared.cancelAllCurrentAlamofireRequests()
        
        if nextPaginate.isEmpty {
            
            ANLoader.showLoading()
        }
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(EditionDC.self, from: response)
                
                if let editions = FULLResponse.editions {
                    
                    if self.isSearchCall {
                        
                        if self.nextPaginate.isEmpty {
                     
                            self.editionsArray.removeAll()
                            
                            for (i, e) in editions.enumerated() {
                                
                                let tree = TreeNode.modelWithDictionary(e, levelString: i, parent: nil)
                                self.editionsArray.append(tree)
                                
                                //self.editionsArray.append(TreeNode(id: e.id ?? "", name: e.name ?? "", city: e.city ?? "", state: e.state ?? "", country: e.country ?? "", language: e.language ?? "", image: e.image ?? "", selected: e.selected ?? false, has_child: e.has_child ?? false))
                            }
                            //self.editionsArray = editions
                        }
                        else {
                            
                            //self.editionsArray += editions
                            for (i, e) in editions.enumerated() {
                                let tree = TreeNode.modelWithDictionary(e, levelString: i, parent: nil)
                                self.editionsArray.append(tree)

                                //self.editionsArray.append(TreeNode(id: e.id ?? "", name: e.name ?? "", city: e.city ?? "", state: e.state ?? "", country: e.country ?? "", language: e.language ?? "", image: e.image ?? "", selected: e.selected ?? false, has_child: e.has_child ?? false))
                            }
                        }
                    }
                    else {
                      
                        //self.editionsArray += editions
                        for (i, e) in editions.enumerated() {

                            let tree = TreeNode.modelWithDictionary(e, levelString: i, parent: nil)
                            self.editionsArray.append(tree)

                            //self.editionsArray.append(TreeNode(id: e.id ?? "", name: e.name ?? "", city: e.city ?? "", state: e.state ?? "", country: e.country ?? "", language: e.language ?? "", image: e.image ?? "", selected: e.selected ?? false, has_child: e.has_child ?? false))
                        }
                    }
                    
                    if self.nextPaginate == "" && self.isSearchCall == false {
                        
                        self.performWSToGetUserEditions()
                     //   self.editionsArray.removeAll()
                     //   self.editionsArray = editions
                     //   self.tbEdition.reloadData()
                    }
                    else {
                        
                        self.tbEdition.reloadData()
                        //self.tbEdition.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    }
                    
                    if searchText == "" {
                        
                        self.isSearchCall = false
                    }
                    
                    if let meta = FULLResponse.meta {
                        
                        self.nextPaginate = meta.next ?? ""
                    }
                    
                    if self.editionsArray.count > 0 {
                        
                        self.viewNoSearch.isHidden = true
                        self.viewTbEditions.isHidden = false
                    }
                    else {
                        
                        self.viewNoSearch.isHidden = false
                        self.viewTbEditions.isHidden = true
                    }
                }
                ANLoader.hide()
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
    
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetChildEdition(index: Int) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let edition = self.editionsArray[index]
        let url = "news/editions?parent=\(edition.id)"
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
      
        ANLoader.showLoading()
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(EditionDC.self, from: response)
                
                if let subEditions = FULLResponse.editions {

                    self.isSearchCall = false
                    edition.subNodes.removeAll()
                    for (i, e) in subEditions.enumerated() {

                        let tree = TreeNode.modelWithDictionary(e, levelString: i, parent: edition.levelString)
                        edition.subNodes.append(tree)

//                        let newItem = TreeNode(id: e.id ?? "", name: e.name ?? "", city: e.city ?? "", state: e.state ?? "", country: e.country ?? "", language: e.language ?? "", image: e.image ?? "", selected: e.selected ?? false, has_child: e.has_child ?? false)
//                        edition.subNodes.append(newItem)
                    }
                    self.editionsArray[index] = edition
                    
                    let node = self.editionsArray[index]
                    if node.isLeaf {
                        return
                    }
                    
                    node.isOpen = !node.isOpen
                    let nodes = node.needsDisplayNodes
                    let insertIndex = self.editionsArray.firstIndex(of: node)! + 1
                    if node.isOpen {
                        self.editionsArray.insert(contentsOf: nodes, at: insertIndex)
                        self.tbEdition.insertRows(at: nodes.map {
                            IndexPath(row: self.editionsArray.firstIndex(of: $0)!, section: 0)
                        }, with: .top)
                    }
                    else {
                        
                        for subNode in nodes {
                            guard let index = self.editionsArray.firstIndex(of: subNode) else {
                                continue
                            }
                            self.editionsArray.remove(at: index)
                            self.tbEdition.deleteRows(at: [IndexPath(row: index, section: 0)], with: .bottom)
                        }
                    }
                    
                    //self.tbEdition.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    if let indexPaths = self.tbEdition.indexPathsForVisibleRows {
                        self.tbEdition.reloadRows(at: indexPaths, with: .none)
                    }
                    else {
                        self.tbEdition.reloadData()
                    }
                }
                ANLoader.hide()
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
    
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetUserEditions() {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
      //  ANLoader.showLoading(disableUI: true)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/editions/followed", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(EditionDC.self, from: response)
                
                if let editions = FULLResponse.editions {
                     
                    self.editionsIDsArray.removeAll()
                    self.maineditionsIDsArray.removeAll()
                    for edition in editions {

                        self.editionsIDsArray.append(edition.id ?? "")

                        if !(self.followEditionsIDsArrayTemp.contains(edition.id ?? "")) {
                            self.followEditionsIDsArrayTemp.append(edition.id ?? "")
                        }
                    }
                    self.maineditionsIDsArray = self.editionsIDsArray
                    self.tbEdition.reloadData()
                    
                }

            } catch let jsonerror {

                SharedManager.shared.logAPIError(url: "news/editions/followed", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }

        }) { (error) in

            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUpdateUserEditions() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        var editionIdArr1 = [String]()
        for edition in followEditionsIDsArrayTemp {

            editionIdArr1.append("follow=\(edition)")
        }
        let query1 = editionIdArr1.joined(separator: "&")
        
        var editionIdArr2 = [String]()
        for edition in unFollowEditionsIDsArrayTemp {

            editionIdArr2.append("unfollow=\(edition)")
        }
        let query2 = editionIdArr2.joined(separator: "&")
        
        let finalQuery = query2.isEmpty ? query1 : query1 + "&" + query2

        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse("news/editions/followed?\(finalQuery)", method: .patch, parameters: [String: Any](), headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                if FULLResponse.message?.uppercased() == Constant.STATUS_SUCCESS {
                    
                    if self.isFromRegistration {
                        
                        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.regSelectEdition, eventDescription: "")
//                        let vc = userTopicVC.instantiate(fromAppStoryboard: .registration)
//                        self.navigationController?.pushViewController(vc, animated: true)
                        self.performWSToUserConfig()
                        
                    }
                    else {
                        
                        self.delegate?.didTapRefressSettings()
                        self.didTapBack(self)
                    }
                }
                else {
                    
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/editions/followed?\(finalQuery)", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

//====================================================================================================
// MARK:- logout user webservice Respones
//====================================================================================================
extension EditionVC {
    
    func performWSTologoutUser() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            self.btnBack.isUserInteractionEnabled = true
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
        let refreshToken = UserDefaults.standard.value(forKey: Constant.UD_refreshToken) ?? ""
        let params = ["token": refreshToken]
        
        WebService.URLResponseAuth("auth/logout", method: .post, parameters: params, headers: userToken as? String, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
                
                if FULLResponse.message?.lowercased() == "success" {
                    
                    self.appDelegate.logout()
                }
                else {
                    
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    
                    self.btnBack.isUserInteractionEnabled = true
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "auth/logout", error: jsonerror.localizedDescription, code: "")
                self.btnBack.isUserInteractionEnabled = true
                print("error parsing json objects",jsonerror)
            }
            
            ANLoader.hide()
            
        }){ (error) in
            
            ANLoader.hide()
            self.btnBack.isUserInteractionEnabled = true
            print("error parsing json objects",error)
        }
    }
}

extension EditionVC {
    
    // Check channel or topic selection required
    func performWSToUserConfig() {
        
        ANLoader.showLoading(disableUI: true)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userConfigDC.self, from: response)
                
                //Load default theme settings
                SharedManager.shared.setThemeAutomatic()
                self.appDelegate.setHomeVC()

                
            } catch let jsonerror {
            
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
}
