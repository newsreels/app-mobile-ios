//
//  AddPlacesVC.swift
//  Bullet
//
//  Created by Mahesh on 04/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import TagListView
import IQKeyboardManagerSwift

class AddPlacesVC: UIViewController {

    @IBOutlet weak var viewNav: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewTableBG: UIView!
    
    @IBOutlet weak var tbTags: UITableView!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var btnTag: UIButton!
    
    @IBOutlet weak var lblTagTitle: UILabel!
    @IBOutlet weak var lblTagDesc: UILabel!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var lblSave: UILabel!
    @IBOutlet weak var lblMax: UILabel!
    
    var arrTags: [Location]?
    var arrSuggestedTags: [Location]?
    var article: articlesData?
    var articleID = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true

        articleID = article?.id ?? ""
        
        tagListView.delegate = self
        tagListView.textColor = MyThemes.current == .dark ? "#FFFFFF".hexStringToUIColor() : "#3D485F".hexStringToUIColor()
        tagListView.textFont = UIFont(name: Constant.FONT_Mulli_Semibold, size: 14) ?? UIFont.systemFont(ofSize: 14)
        tagListView.tagBackgroundColor = MyThemes.current == .dark ? "#404040".hexStringToUIColor() : "#F1F1F1".hexStringToUIColor()
        tagListView.selectedTextColor = MyThemes.current == .dark ? "#FFFFFF".hexStringToUIColor() : "#3D485F".hexStringToUIColor()
        
        btnTag.theme_setImage(GlobalPicker.imgTag, forState: .normal)
        self.setLocalizable()
        self.viewDesign()
        self.refresTagList()
    }
     
    //Design View
    func viewDesign() {
       
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        imgBack.theme_image = GlobalPicker.imgBack
        viewNav.theme_backgroundColor = GlobalPicker.viewHeaderTabColor
        viewSearch.theme_backgroundColor = GlobalPicker.viewHeaderTabColor
        viewTableBG.theme_backgroundColor = GlobalPicker.viewHeaderTabColor
        
        lblTitle.theme_textColor = GlobalPicker.textColor
        lblTagTitle.theme_textColor = GlobalPicker.textColor
    }
    
    func setLocalizable() {
        
        lblTitle.text = NSLocalizedString("Add Place", comment: "")
        lblTagTitle.text = NSLocalizedString("Add places tags", comment: "")
        lblTagDesc.text = NSLocalizedString("Be discovered by people following the places you are posting about.", comment: "")
        txtSearch.theme_textColor = GlobalPicker.textColor
        txtSearch.theme_tintColor = GlobalPicker.textColor
        
        lblMax.text = NSLocalizedString("Max 5", comment: "")
        lblSave.text = NSLocalizedString("SAVE", comment: "")
        lblSave.addTextSpacing(spacing: 2.0)
        lblResult.text = NSLocalizedString("RECOMMENDED", comment: "")

        txtSearch.placeholder = NSLocalizedString("comma, separated, tags", comment: "")
    }
    
    func refresTagList() {
        
        self .performWSToGetTagsList(articleId: articleID)
        self .performWSToGetSuggestedTagsList(articleId: articleID, searchText: "")
    }
    
    //First time on api call
    func updateTags(name: String) {
        
        tagListView.addTag(name)
    }
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapBackButton(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        
        //self .refresTagList()
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: TagListViewDelegate
extension AddPlacesVC: TagListViewDelegate {

    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        print("Tag Remove pressed: \(title), \(sender)")
        tagListView.removeTagView(tagView)
        
        if let index = self.arrTags?.firstIndex(where: { $0.name == title }), let tag = self.arrTags?[index] {
            
            self.selectedTagAddOrRemove(isAdd: false, tag: tag)
        }
        
    }
}

// MARK: UITextFieldDelegate
extension AddPlacesVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let text = textField.text ?? ""
        let _ = NSString(string: text).replacingCharacters(in: range, with: string)
//        if !(text.isEmpty) && string == "," {
//
//            if let firstSuchElement = self.arrTags?.first(where: { $0.name == text }) {
//                print(firstSuchElement)
//                self.view.endEditing(true)
//                SharedManager.shared.showAlertLoader(message: NSLocalizedString("Place Already Added.", comment: ""), duration: 3.0, position: .bottom)
//            }
//            else {
//                tagListView.addTag(text)
//                self.arrTags?.append(Location(id: nil, name: text, context: nil, image: nil, city: nil, country: nil, favorite: nil))
//                textField.text = ""
//            }
//            return false
//        }
        
        self.perform(#selector(getTextOnStopTyping), with: textField, afterDelay: 0.5)
        return true
    }

    @objc func getTextOnStopTyping(_ textField: UITextField) {
        
        let searchText = textField.text ?? ""
        self.performWSToGetSuggestedTagsList(articleId: self.articleID, searchText: searchText)
    }
}

//MARK:- TableView DELEGATES and DATASOURCES
extension AddPlacesVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.arrSuggestedTags?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let tagCell = tableView.dequeueReusableCell(withIdentifier: "AddTagCC", for: indexPath) as! AddTagCC
        tagCell.theme_backgroundColor = GlobalPicker.backgroundColor
        
        let tag = self.arrSuggestedTags?[indexPath.row]
        tagCell.imgTag?.sd_setImage(with: URL(string: tag?.image ?? ""), placeholderImage: nil)
        tagCell.lblTitle.text = tag?.name ?? ""
        tagCell.lblTitle.theme_textColor = GlobalPicker.textColor
        
        if let tags = self.arrTags {
            
            if (tags.contains(where: {$0.id == tag?.id})) {
                
                tagCell.imgRadio.image = UIImage(named: "icn_radio_selected")
            }
            else {
                
                tagCell.imgRadio.image = UIImage(named: "icn_radio_unselected")
            }
        }
        
        
        tagCell.btnAddTag.tag = indexPath.row
        tagCell.btnAddTag.addTarget(self, action: #selector(didTapAddTag), for: .touchUpInside)
        return tagCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AddTagCC {
            self.didTapAddTag(sender: cell.btnAddTag)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 62
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    @objc func didTapAddTag(sender: UIButton) {
        
        if let tag = self.arrSuggestedTags?[sender.tag] {
            
            if let _ = self.arrTags?.firstIndex(where: { $0.id == tag.id }) {
                self.selectedTagAddOrRemove(isAdd: false, tag: tag)
            }
            else {
                
                if let arrCount = self.arrTags, arrCount.count >= 5 {
                    return
                }
                self.selectedTagAddOrRemove(isAdd: true, tag: tag)
            }
        }
    }
    
    func selectedTagAddOrRemove(isAdd: Bool, tag: Location) {
        
        self.btnBack.isUserInteractionEnabled = false
        if isAdd {
            
            let name = tag.name ?? ""
            self.tagListView.addTag(name)
            self.arrTags?.append(tag)
            
            self .performWSToAddTags(articleId: articleID, tagName: tag.id ?? "")
        }
        else {
            
            let name = tag.name ?? ""
            let id = tag.id ?? ""
            self.tagListView.removeTag(name)
            if let index = self.arrTags?.firstIndex(where: { $0.id == id }) {
                self.arrTags?.remove(at: index)
            }
            
            self .performWSToDeleteTags(articleId: articleID, tagId: id)
        }
        
        if let indexPaths = tbTags.indexPathsForVisibleRows {
            self.tbTags.reloadRows(at: indexPaths, with: .none)
        }
        else {
            self.tbTags.reloadData()
        }
    }
}

//MARK:- Webservices
extension AddPlacesVC {

    //Suggested List
    func performWSToGetSuggestedTagsList(articleId: String, searchText: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let apiUrl : String = "studio/\(articleId)/locations/suggestion?query=\(searchText)"
        WebService.URLResponse(apiUrl, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                if let tagsList = FULLResponse.locations {
                    
                    self.arrSuggestedTags = tagsList
                    self.tbTags.reloadData()
                }
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: apiUrl, error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    //user tags list
    func performWSToGetTagsList(articleId: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        //ANLoader.showLoading(disableUI: true)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let apiUrl : String = "studio/\(articleId)/locations"
        WebService.URLResponse(apiUrl, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                if let tagsList = FULLResponse.locations {
                    
                    self.arrTags = tagsList
                    //self.txtSearch.isHidden = false
                    
                    for tag in tagsList {
                       
                        //self.txtSearch.isHidden = true
                        self.updateTags(name: tag.name ?? "")
                    }
                    self.tbTags.reloadData()
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: apiUrl, error: jsonerror.localizedDescription, code: "")
            }
            ANLoader.hide()
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    //Add Tags
    func performWSToAddTags(articleId: String, tagName: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        //ANLoader.showLoading(disableUI: true)
        
        let params = ["location":tagName]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let apiUrl : String = "studio/\(articleId)/locations"
        WebService.URLResponse(apiUrl, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                self.btnBack.isUserInteractionEnabled = true
                if let arrTags = FULLResponse.locations {
                    
                    for tag in arrTags {
                        
                        if tagName == tag.name {
                            
                            //self.txtSearch.isHidden = true
//                            self.tagListView.addTag(tag.name ?? "")
//                            self.arrTags?.append(tag)
                            //self.performWSToGetSuggestedTagsList(articleId: articleId, searchText: "")
                        }
                    }
                }
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                self.btnBack.isUserInteractionEnabled = true
                SharedManager.shared.logAPIError(url: apiUrl, error: jsonerror.localizedDescription, code: "")
            }
            ANLoader.hide()
        }) { (error) in
            
            ANLoader.hide()
            self.btnBack.isUserInteractionEnabled = true
            print("error parsing json objects",error)
        }
    }
    
    // Remove tag
    func performWSToDeleteTags(articleId: String, tagId: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        //ANLoader.showLoading(disableUI: true)
        
        let params = ["id": tagId]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let apiUrl : String = "studio/\(articleId)/locations"
        WebService.URLRequestBodyParams(apiUrl, method: .delete, parameters: params, headers: token, ImageDic: [String : UIImage](), withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                self.btnBack.isUserInteractionEnabled = true
                if let arrTags = FULLResponse.locations {
//
//                    for (index, tag) in arrTags.enumerated() {
//
//                        if tagId == tag.id {
//
//                            self.tagListView.removeTag(tag.name ?? "")
//                            self.arrTags?.remove(at: index)
//                            self.tbTags.reloadData()
//                            //self.performWSToGetSuggestedTagsList(articleId: articleId, searchText: "")
//                        }
//                    }
                }
                
            } catch let jsonerror {
                
                self.btnBack.isUserInteractionEnabled = true
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: apiUrl, error: jsonerror.localizedDescription, code: "")
            }
            ANLoader.hide()
        }) { (error) in
            
            self.btnBack.isUserInteractionEnabled = true
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}
