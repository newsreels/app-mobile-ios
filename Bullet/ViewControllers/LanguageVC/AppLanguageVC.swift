//
//  AppLanguageVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 13/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol AppLanguageVCDelegate: AnyObject {
    func setLanguageForArticle(langName: String)
}
         
class AppLanguageVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var viewSearch: UIView!
  //  @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var viewNoSearch: UIView!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var viewGradient: GradientShadowView!
    @IBOutlet weak var viewContinue: UIView!

    var languagesArrMain: [languagesData]?
    var languagesArr: [languagesData]?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var isFromPostArticle = false
    var article: articlesData?
    var langCode = ""
    
    weak var delegateVC: AppLanguageVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //when post article creating
        langCode = self.article?.language ?? ""
        
        setupLocalization()
        setDesignView()
        
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

        languagesArrMain = [languagesData]()
        languagesArr = [languagesData]()
        performWSToGetAllLanguage()
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    private func setDesignView() {
        
        let selectedThemeType = UserDefaults.standard.bool(forKey: Constant.UD_isLocalTheme)
        if selectedThemeType == true {
            
            btnHelp.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        }
        else {
            
            btnHelp.setTitleColor("#FFFFFF".hexStringToUIColor(), for: .normal)
        }
        btnHelp.addTextSpacing(spacing: 2)
        
        btnBack.theme_setImage(GlobalPicker.imgBack, forState: .normal)
        if isFromPostArticle {
            view.theme_backgroundColor = GlobalPicker.backgroundColor
            tableView.backgroundColor = .clear
            viewSearch.theme_backgroundColor = GlobalPicker.viewSearchBGColor
            
            lblTitle.theme_textColor = GlobalPicker.textColor
            btnBack.isHidden = false
            btnHelp.isHidden = true
            txtSearch.theme_tintColor = GlobalPicker.textColor
            txtSearch.theme_textColor = GlobalPicker.textColor
            
            viewContinue.isHidden = true
            viewGradient.isHidden = true
            //            viewContinue.theme_backgroundColor = GlobalPicker.backgroundColor
            //
            //            if MyThemes.current == .dark {
            //                viewGradient.topColor = .clear
            //                viewGradient.bottomColor = .black
            //                viewGradient.shaddowColor = .black
            //            }
            //            else {
            //                viewGradient.topColor = .clear
            //                viewGradient.bottomColor = .white
            //                viewGradient.shaddowColor = .white
            //            }
        }
        else {
            
            btnBack.isHidden = true
            btnHelp.isHidden = false
            txtSearch.tintColor = .white
            txtSearch.tintColor = .white
        }
        txtSearch.theme_placeholderAttributes = GlobalPicker.textPlaceHolder
        
        continueButton.addTextSpacing(spacing: 2)
        continueButton.backgroundColor = Constant.appColor.purple
    }
    
    private func setupLocalization() {
        lblTitle.text = NSLocalizedString("App Language", comment: "")
        
//        if isFromPostArticle {
//            lblDesc.text = NSLocalizedString("", comment: "")
//        }
//        else {
//            lblDesc.text = NSLocalizedString("Select your preferred language\nfor News in Bullets.", comment: "")
//        }
        
        txtSearch.placeholder = NSLocalizedString("Search", comment: "")
        continueButton.setTitle(NSLocalizedString("CONTINUE", comment: ""), for: .normal)
        btnHelp.setTitle(NSLocalizedString("HELP", comment: ""), for: .normal)
    }
    
    
    //MARK:- UIBUTTON ACTION
    @IBAction func didTapContinue(_ sender: Any) {
        
        if isFromPostArticle {
            
            if langCode.isEmpty { return }
            performWSToUpdateArticleLanguage()
            
            if let index = languagesArr?.firstIndex(where: { $0.code == langCode }), let name = languagesArr?[index].name {
                
                self.delegateVC?.setLanguageForArticle(langName: name)
            }
        }
        else {
         
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.regSelectLanguage, eventDescription: "")
            SharedManager.shared.isAppOnboardScreensLoaded = true
            appDelegate.setOnBoardVC()
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        if isFromPostArticle {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
        
        let vc = helpCenterVC.instantiate(fromAppStoryboard: .registration)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if let searchText = textField.text, !(searchText.isEmpty) {
            
            self.languagesArr?.removeAll()
            self.languagesArr = self.languagesArrMain?.filter { ($0.name?.lowercased().hasPrefix(searchText.lowercased()) ?? true) }
            self.tableView.reloadData()
        }
        else {
            
            //print("Search Text --- 00")
            //self.view.endEditing(true)
            self.languagesArr?.removeAll()
            self.performWSToGetAllLanguage()
        }
    }
}

extension AppLanguageVC {
    
    func performWSToGetAllLanguage() {
        
        if let lang = SharedManager.shared.loadJsonLanguages(filename: "languages") {
            
            self.languagesArrMain = lang
            
            self.languagesArr = lang
            
            if UserDefaults.standard.string(forKey: Constant.UD_appLanguageName) == nil || UserDefaults.standard.string(forKey: Constant.UD_appLanguageName) == "" {
                UserDefaults.standard.set(self.languagesArr?.first?.name, forKey: Constant.UD_appLanguageName)
            }
            
            self.tableView.reloadData()
        }
    }
    
    func performWSToUpdateArticleLanguage() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading()
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let params = ["language": langCode]
        
        WebService.URLResponse("studio/articles/\(article?.id ?? "")/language", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                //SharedManager.shared.showAlertLoader(message: NSLocalizedString("Article removed successfully", comment: ""), type: .alert)
                                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "studio/articles/\(self.article?.id ?? "")/language", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

//MARK: - UITablview Delegates and DataSource
extension AppLanguageVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 62
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if languagesArr?.count ?? 0 > 0 {
            
            self.viewNoSearch.isHidden = true
            self.tableView.isHidden = false
        }
        else {
            
            self.viewNoSearch.isHidden = false
            self.tableView.isHidden = true
        }
        
        return languagesArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCC") as! LanguageCC
        
        if let lang = self.languagesArr, lang.count > 0 {
            
            let dict = lang[indexPath.row]
            //cell.imgView.image = dict.image
            cell.lblTitle.text = dict.name?.uppercased()
            cell.lblTitle.addTextSpacing(spacing: 2)
            if isFromPostArticle {
                cell.lblTitle.theme_textColor = GlobalPicker.textColor
            }
            cell.lblSubTitle.text = dict.sample?.capitalized
            
            let code = isFromPostArticle ? langCode : UserDefaults.standard.string(forKey: Constant.UD_languageSelected)
            
            cell.imgRadio.image = UIImage(named: dict.code == code ? "icn_radio_selected" : "icn_radio_unselected")
            cell.imgView.sd_setImage(with: URL(string: dict.image ?? ""), placeholderImage: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //self.view.isUserInteractionEnabled = false
        if let lang = self.languagesArr, lang.count > 0 {
            
            let item = lang[indexPath.row]

            if isFromPostArticle {
                langCode = item.code ?? "en"
                tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
                
                performWSToUpdateArticleLanguage()
                
                if let index = languagesArr?.firstIndex(where: { $0.code == langCode }), let name = languagesArr?[index].name {
                    
                    self.delegateVC?.setLanguageForArticle(langName: name)
                }
            }
            else {
                SharedManager.shared.languageId = item.id ?? ""
                UserDefaults.standard.set(item.name, forKey: Constant.UD_appLanguageName)
                UserDefaults.standard.set(item.code, forKey: Constant.UD_languageSelected)
                UserDefaults.standard.set(item.image, forKey: Constant.UD_languageFlag)
                UserDefaults.standard.synchronize()
                tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
                Bundle.setLanguage(item.code ?? "en")
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}


