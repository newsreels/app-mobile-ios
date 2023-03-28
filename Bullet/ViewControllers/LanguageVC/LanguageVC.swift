//
//  LanguageVC.swift
//  Bullet
//
//  Created by MK on 13/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SwiftTheme
import DataCache


class LanguageVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lblTitle: UILabel!
//    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewUnderLine: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var languagesArrMain: [languagesData]?
    var languagesArr: [languagesData]?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //LOCALIZABLE STRING
        txtSearch.placeholder = NSLocalizedString("Search", comment: "")
        lblTitle.text = NSLocalizedString("Language", comment: "")

        //DESIGN VIEW
        self.view.backgroundColor = .white
//        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
        lblTitle.theme_textColor = GlobalPicker.textColor
//        imgBack.theme_image = GlobalPicker.imgBack
        viewUnderLine.theme_backgroundColor = GlobalPicker.themeCommonColor
        txtSearch.theme_tintColor = GlobalPicker.searchTintColor
        txtSearch.theme_textColor = GlobalPicker.textColor
        txtSearch.theme_placeholderAttributes = GlobalPicker.textPlaceHolder
//        txtSearch.theme_placeholderAttributes = GlobalPicker.textPlaceHolder
        txtSearch.delegate = self
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
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        ANLoader.hide()
    }
    
    
    @IBAction func didTapBackButton(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func performWSToGetAllLanguage() {

        if let lang = SharedManager.shared.loadJsonLanguages(filename: "languages") {
            
            var langArray = lang
            let languageCode = UserDefaults.standard.string(forKey: Constant.UD_languageSelected)
            if let selectedIndex = langArray.firstIndex(where: { $0.code == languageCode }) {
                let selectedItem = langArray[selectedIndex]
                langArray.remove(at: selectedIndex)
                
                langArray = [selectedItem] + langArray
            }
            
            self.languagesArrMain = langArray
            self.languagesArr = langArray
            self.tableView.reloadData()
        }
    }
    
    func performWSToUpdateLanguage(item: languagesData) {

        let params = ["language": item.id ?? ""]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)

        ANLoader.showLoading()
        WebService.URLResponseAuth("auth/update-profile/language", method: .patch, parameters: params, headers: token, withSuccess: { (response) in

            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                if FULLResponse.message?.uppercased() == Constant.STATUS_SUCCESS {
                    
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Language updated successfully.", comment: ""))
                    
                    SharedManager.shared.languageId = item.id ?? ""
                    UserDefaults.standard.set(item.code, forKey: Constant.UD_languageSelected)
                    UserDefaults.standard.set(item.image, forKey: Constant.UD_languageFlag)
                    UserDefaults.standard.synchronize()
                    Bundle.setLanguage(item.code ?? "en")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        
                        WebService.checkValidToken { _ in
                            
                            ANLoader.hide()
                            DispatchQueue.main.async {
                                DataCache.instance.cleanAll()
                                self.appDelegate.setHomeVC()
                            }
                        }
                    })
                }
                
            } catch let jsonerror {

                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "auth/update-profile/language", error: jsonerror.localizedDescription, code: "")
            }

        }) { (error) in

            ANLoader.hide()
            print("error parsing json objects",error)
        }
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

//MARK: - UITablview Delegates and DataSource
extension LanguageVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return languagesArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCC") as! LanguageCC
        
        if let lang = self.languagesArr, lang.count > 0 {
            
            let dict = lang[indexPath.row]
            cell.lblTitle.text = dict.name?.uppercased()
            cell.lblTitle.addTextSpacing(spacing: 2)
            cell.lblSubTitle.text = dict.sample
            cell.lblTitle.theme_textColor = GlobalPicker.textColor
            cell.viewLine.theme_backgroundColor = GlobalPicker.viewLineBGColor

            let code = UserDefaults.standard.string(forKey: Constant.UD_languageSelected)
            
            if dict.code == code {
                let image = UIImage(named: "icn_radio_selected_light")
                let lightImage = image?.sd_tintedImage(with: Constant.appColor.blue)
                let darkImage = image?.sd_tintedImage(with: Constant.appColor.purple)
                let colorImage = ThemeImagePicker(images: lightImage!,darkImage!)
                cell.imgRadio.theme_image = colorImage
            } else {
                cell.imgRadio.image = UIImage(named: "icn_radio_unselected")
            }
            
            cell.imgView.sd_setImage(with: URL(string: dict.image ?? ""), placeholderImage: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.isUserInteractionEnabled = false
        if let lang = self.languagesArr, lang.count > 0 {
            
            let item = lang[indexPath.row]

            UserDefaults.standard.set(item.name, forKey: Constant.UD_appLanguageName)
            SharedManager.shared.isLanguageRTL = Bundle.isLanguageRTL(item.code ?? "en") ? true : false
            performWSToUpdateLanguage(item: item)

//            if indexPath.row == 0 {
//                Bundle.setLanguage("hi")
//            }
//            else {
//                Bundle.setLanguage(item.code ?? "en")
//            }
//            appDelegate.setHomeVC()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

