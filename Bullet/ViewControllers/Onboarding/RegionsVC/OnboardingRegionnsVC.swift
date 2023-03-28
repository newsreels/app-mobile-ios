//
//  OnboardingRegionnsVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 22/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Alamofire

protocol OnboardingRegionnsVCDelegate: AnyObject {
    
    func setLocationsForAppContent(locations: [Location], locationName: [String])
}

class OnboardingRegionnsVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var lblCollectionNoSearch: [UILabel]!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var viewNoSearch: UIView!
    @IBOutlet weak var viewTbRegions: UIView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewSearch: UIView!
    
    @IBOutlet weak var tbRegions: UITableView!
    @IBOutlet weak var viewGradient: GradientShadowView!
    
    @IBOutlet weak var constraintViewNoResultBottomHeight: NSLayoutConstraint!
    
    
    var searchText = ""
    var nextPaginate = ""
    var selectedRegionsArr = [String]()
    var locationsArr = [Location]()
    var updatedlocationsArr = [Location]()
    weak var delegate: OnboardingRegionnsVCDelegate?
  
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = "#090909".hexStringToUIColor()
        self.viewBottom.isHidden = false
        self.tbRegions.backgroundColor = .clear
        
        txtSearch.placeholderColor = "4D4D4D".hexStringToUIColor()
        txtSearch.tintColor = .white
        lblTitle.textColor = .white
        tbRegions.backgroundColor = .black
        imgBack.theme_image = GlobalPicker.imgBack
       // btnContinue.theme_backgroundColor = GlobalPicker.themeCommonColor
        btnContinue.backgroundColor = "#E01335".hexStringToUIColor()
        btnContinue.addTextSpacing(spacing: 2.0)
        
        self.setupLocalization()
        
        txtSearch.delegate = self
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        self.performWSToGetRegions(searchText: "")
    }
    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.txtSearch.semanticContentAttribute = .forceRightToLeft
                self.txtSearch.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.txtSearch.semanticContentAttribute = .forceLeftToRight
                self.txtSearch.textAlignment = .left
            }
        }
    }
    
    func setupLocalization() {
        
        lblTitle.text = NSLocalizedString("Region/Places", comment: "")
        txtSearch.placeholder = NSLocalizedString("Search", comment: "")
        btnContinue.setTitle(NSLocalizedString("CONTINUE", comment: ""), for: .normal)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
      
        self.delegate?.setLocationsForAppContent(locations: self.updatedlocationsArr, locationName: self.selectedRegionsArr)
        self.didTapBack(self)
    }
    
    @IBAction func didTapClearAction(_ sender: Any) {
        
        self.clearSearchData()
    }
    
    func clearSearchData() {
        
        txtSearch.resignFirstResponder()
        btnClear.isHidden = true
        txtSearch.text = ""
        nextPaginate = ""
        self.view.endEditing(true)
        self.locationsArr.removeAll()
        self.performWSToGetRegions(searchText: "")
    }
}

//MARK:- UITableView Delegate and DataSource
extension OnboardingRegionnsVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return locationsArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditionCC") as! EditionCC
        cell.layoutIfNeeded()
        
       // cell.contentView.theme_backgroundColor = GlobalPicker.backgroundColor
        cell.lblEdition.textColor = .white
        cell.imgEdition.cornerRadius = cell.imgEdition.frame.size.width / 2
        
        cell.btnSelectTopic.tag = indexPath.row
        cell.btnSelectTopic.addTarget(self, action: #selector(didTapAddRemoveRegion), for: .touchUpInside)
        
        
        if self.locationsArr.count > 0 {
            
            let location = self.locationsArr[indexPath.row]
            cell.lblEdition.text = location.name?.capitalized ?? ""
            if let flag = location.flag {
                
                cell.imgEdition.sd_setImage(with: URL(string: flag), completed: nil)
            }
            else {
                
                cell.imgEdition.sd_setImage(with: URL(string: location.image ?? ""), completed: nil)
            }

            if self.selectedRegionsArr.contains(location.id ?? "") {
                
              //  selectedRegionsArr.remove(object: location.name ?? "")
                cell.imgStatus.image = UIImage(named: MyThemes.current == .dark ? "check" : "checkLight")
                
                
            }
            else {
                
              //  selectedRegionsArr.append(location.name ?? "")
                cell.imgStatus.image = UIImage(named: "checkmark")
            }
            if indexPath.row == self.locationsArr.count - 1 {
                
                if !(nextPaginate.isEmpty) {
                    
                    self.performWSToGetRegions(searchText: self.searchText)
                }
            }
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
 
    @objc func didTapAddRemoveRegion(sender: UIButton) {
        
        let row = sender.tag
        let indexPath = IndexPath(item: row, section: 0)
        
        // Index out of bounds crash fix}
        if self.locationsArr.count == 0  || self.locationsArr.count <= indexPath.row {
            return
        }
        
        let location = self.locationsArr[indexPath.row]
        let cell = tbRegions.cellForRow(at: indexPath) as? EditionCC
    
        if self.selectedRegionsArr.contains(location.id ?? "") {
            
            selectedRegionsArr.remove(object: location.id ?? "")
            cell?.imgStatus.image = UIImage(named: "checkmark")
        }
        else {
            
            if self.updatedlocationsArr.contains(where: {$0.name == location.name ?? ""}) {

                if let index = self.updatedlocationsArr.firstIndex(where: { $0.name == location.name ?? "" }) {
                    
                    self.updatedlocationsArr.remove(at: index)
                }
                self.updatedlocationsArr.insert(location, at: 0)
            }
            else {
                
                self.updatedlocationsArr.insert(location, at: 0)
            }
            
            selectedRegionsArr.append(location.id ?? "")
            cell?.imgStatus.image = UIImage(named: MyThemes.current == .dark ? "check" : "checkLight")
        }
    }
    
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        return arr
    }
}

//MARK: -Keyboard
extension OnboardingRegionnsVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {

        self.searchText = textField.text ?? ""
        if let searchText = textField.text, !(searchText.isEmpty) {
            
            if searchText.count == 1 {
                
                self.locationsArr.removeAll()
                self.tbRegions.reloadData()
            }
            
            self.performWSToGetRegions(searchText: searchText)
            btnClear.isHidden = false
            self.nextPaginate = ""
            
        }
        else {
            
            self.searchText = ""
            self.view.endEditing(true)
            self.nextPaginate = ""
            btnClear.isHidden = true
            self.locationsArr.removeAll()
            self.performWSToGetRegions(searchText: "")
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {

            self.keyboardEvent(true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification?) {
        
            self.keyboardEvent(false)
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

extension OnboardingRegionnsVC {

    func performWSToGetRegions(searchText: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        ANLoader.showLoading(disableUI: false)
        var url = ""
        if searchText == "" {
            
            if self.nextPaginate.isEmpty { ANLoader.showLoading(disableUI: true) }
            url = "news/locations?page=\(nextPaginate)"
        }
        else{
            
            let searchText = searchText.encodeUrl()
            url = "news/locations?query=\(searchText)&page=\(nextPaginate)"
        }
        
        SharedManager.shared.cancelAllCurrentAlamofireRequests()
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                if let locations = FULLResponse.locations  {
                    
                    if searchText != "" {
                        
                        if self.nextPaginate.isEmpty {
                    
                            self.locationsArr.removeAll()
                            self.locationsArr = locations
                        }
                        else {
                            
                            self.locationsArr += locations
                        }
                    }
                    else {
                        self.locationsArr += locations
                    }
                }

                if let meta = FULLResponse.meta {
                    
                    self.nextPaginate = meta.next ?? ""
                }
                
                self.tbRegions.reloadData()
                
                ANLoader.hide()
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

