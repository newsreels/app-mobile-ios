//
//  OnboardingLanguageVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 31/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Alamofire

protocol OnboardingLanguageVCDelegate: AnyObject {
    
    func setLanguagezForAppContent(languages: [languagesData], langName: [String])
}

class OnboardingLanguageVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewNoSearch: UIView!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
//    @IBOutlet weak var viewGradient: GradientShadowView!
    @IBOutlet weak var viewContinue: UIView!
    
    var languagesArr = [languagesData]()
    var updatedLanguagesArr = [languagesData]()
    var selectedLanguagesArr = [String]()
    private var nextPaginate = ""
    var searchText = ""
    weak var delegate: OnboardingLanguageVCDelegate?
    var isFromProfileVC = false

    var unfollowLanguagesArr = [String]()
    var jsonError = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
       // txtSearch.theme_placeholderAttributes = GlobalPicker.textPlaceHolder
        
        viewNoSearch.isHidden = true
        txtSearch.placeholderColor = "4D4D4D".hexStringToUIColor()
//        btnHelp.setTitleColor("#FFFFFF".hexStringToUIColor(), for: .normal)
//        view.backgroundColor = "#090909".hexStringToUIColor()
//        tableView.backgroundColor = .black
//        viewSearch.backgroundColor = .black //GlobalPicker.viewSearchBGColor
        
        viewSearch.layer.cornerRadius = 8
        viewSearch.layer.borderWidth = 1
        viewSearch.layer.borderColor = UIColor(red: 0.871, green: 0.908, blue: 0.95, alpha: 1).cgColor
        
        
        continueButton.addTextSpacing(spacing: 2)
        continueButton.backgroundColor = Constant.appColor.lightRed
        //"#E01335".hexStringToUIColor()
        txtSearch.tintColor = .white
        
        self.performWSToGeContentLanguages(searchText: "")
        self.txtSearch.delegate = self
        self.txtSearch.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        self.setupLocalization()
    }

    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                
                self.txtSearch.semanticContentAttribute = .forceRightToLeft
                self.txtSearch.textAlignment = .right
                
                self.btnHelp.semanticContentAttribute = .forceRightToLeft
                self.btnHelp.titleLabel?.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                
                self.txtSearch.semanticContentAttribute = .forceLeftToRight
                self.txtSearch.textAlignment = .left
                
                self.btnHelp.semanticContentAttribute = .forceLeftToRight
                self.btnHelp.titleLabel?.textAlignment = .left
            }
        }
    }
    
    
    private func setupLocalization() {
        
        lblTitle.text = NSLocalizedString("News Content Language", comment: "")
   //     lblTitle.text = self.isFromProfileVC ? NSLocalizedString("App Language", comment: "") : NSLocalizedString("News Content Language", comment: "")
        txtSearch.placeholder = NSLocalizedString("Search", comment: "")
        
        if self.isFromProfileVC {
            
            continueButton.setTitle(NSLocalizedString("Done", comment: "").uppercased(), for: .normal)
        }
        else {
        
            continueButton.setTitle(NSLocalizedString("CONTINUE", comment: ""), for: .normal)
        }
        btnHelp.setTitle(NSLocalizedString("HELP", comment: ""), for: .normal)
    }
    

    //MARK:- Buttons Actions
    @IBAction func didTapBack(_ sender: Any) {
   
        if self.isFromProfileVC {
            
            if self.jsonError {
                
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
            else {
                
                self.performWSToUpdateUserContentLanguages()
            }
        }
        else {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
        
        let vc = helpCenterVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
                
        if self.isFromProfileVC {
            
            SharedManager.shared.isDiscoverTabReload = true
            SharedManager.shared.isTabReload = true
            SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true

            self.performWSToUpdateUserContentLanguages()
        }
        else {
            
            self.delegate?.setLanguagezForAppContent(languages: self.updatedLanguagesArr, langName: self.selectedLanguagesArr)
            self.didTapBack(self)
            
        }
    }
}

//MARK: - Search List
extension OnboardingLanguageVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {

        self.searchText = textField.text ?? ""
        if let searchText = textField.text, !(searchText.isEmpty) {
           
            if searchText.count == 1 {
                
                self.languagesArr.removeAll()
                self.tableView.reloadData()
            }
            
            self.nextPaginate = ""
            self.performWSToGeContentLanguages(searchText: searchText)
            
        }
        else {
            
            self.searchText = ""
            self.view.endEditing(true)
            self.nextPaginate = ""
            self.languagesArr.removeAll()
            self.performWSToGeContentLanguages(searchText: "")
        }
    }
}

//MARK:- UITablview Delegates and DataSource
extension OnboardingLanguageVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return languagesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCC") as! LanguageCC
        
        if self.languagesArr.count > 0 {
            
            let lang = self.languagesArr[indexPath.row]
            cell.lblTitle.text = lang.name?.uppercased()
            cell.lblTitle.addTextSpacing(spacing: 2)
            cell.lblSubTitle.text = lang.sample ?? ""
      
            cell.imgRadio.image = UIImage(named: self.selectedLanguagesArr.contains(lang.id ?? "") ? "check" : "checkmark")
            cell.imgView.sd_setImage(with: URL(string: lang.image ?? ""), placeholderImage: nil)
            
            if indexPath.row == self.languagesArr.count - 1 {
                
                if !(nextPaginate.isEmpty) {
                    
                    self.performWSToGeContentLanguages(searchText: self.searchText)
                }
              //  print("Load More Data")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.isFromProfileVC {
            SharedManager.shared.isDiscoverTabReload = true
            SharedManager.shared.isTabReload = true
            SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true
        }
        
        let cell = tableView.cellForRow(at: indexPath) as? LanguageCC
        
        if languagesArr.count > 0 {
            
            let language = self.languagesArr[indexPath.row]
            
            if self.selectedLanguagesArr.contains(language.id ?? "") {
                
                self.selectedLanguagesArr.remove(object: language.id ?? "")
                self.unfollowLanguagesArr.append(language.id ?? "")
                cell?.imgRadio.image = UIImage(named: "checkmark")
            }
            else {
                
                if self.updatedLanguagesArr.contains(where: {$0.name == language.name ?? ""}) {
                    
                    
                }
                else {
                    
                    self.updatedLanguagesArr.insert(language, at: 0)
                }
                self.selectedLanguagesArr.append(language.id ?? "")
                
                if (self.unfollowLanguagesArr.contains(language.id ?? "") ){
                    
                    self.unfollowLanguagesArr.remove(object: language.id ?? "")
                }
                cell?.imgRadio.image = UIImage(named: "check")
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension OnboardingLanguageVC {

    func performWSToGeContentLanguages(searchText: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        ANLoader.showLoading(disableUI: false)
        var url = ""
        if searchText == "" {
            
            if self.nextPaginate.isEmpty { ANLoader.showLoading(disableUI: true) }
            url = "news/languages?page=\(nextPaginate)"
        }
        else{
            
            let searchText = searchText.encodeUrl()
            url = "news/languages?query=\(searchText)&page=\(nextPaginate)"
        }
        
        SharedManager.shared.cancelAllCurrentAlamofireRequests()
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(LanguagesDC.self, from: response)
                
                if let languages = FULLResponse.languages  {
                    
                    if searchText != "" {
                        
                        if self.nextPaginate.isEmpty {
                    
                            self.languagesArr.removeAll()
                            self.languagesArr = languages
                        }
                        else {
                            
                            self.languagesArr += languages
                        }
                    }
                    else {
                        self.languagesArr += languages
                    }
                    
                    if self.isFromProfileVC {
                        
                        for languge in languages {
                            
                            if languge.favorite == true {
                                
                                self.selectedLanguagesArr.append(languge.id ?? "")
                            }
                        }
                    }
                }

                if let meta = FULLResponse.meta {
                    
                    self.nextPaginate = meta.next ?? ""
                }
                
                self.tableView.reloadData()
                
                
                if self.languagesArr.count > 0 {
                    
                    self.viewNoSearch.isHidden = true
                    self.tableView.isHidden = false
                }
                else {
                    
                    self.viewNoSearch.isHidden = false
                    self.tableView.isHidden = true
                }
                
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
    
    func performWSToUpdateUserContentLanguages() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let params = ["follow":self.selectedLanguagesArr, "unfollow":self.unfollowLanguagesArr]
            
        WebService.URLResponseJSONRequest("news/languages/followed?force=true", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                
                if FULLResponse.message?.lowercased() == "success" {
                   
                    SharedManager.shared.isTabReload = true
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
                
            } catch let jsonerror {
                print("error parsing json objects",jsonerror)
                self.jsonError = true
            }
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
            self.jsonError = true
        }
    }
}
