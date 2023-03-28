//
//  SelectLanguageVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 07/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import DataCache


protocol SelectLanguageVCDelegate: AnyObject {
    func didSaveLanguage()
}

class SelectLanguageVC: UIViewController {

    @IBOutlet weak var dropDownContainerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var dropdownBottomConstraint: NSLayoutConstraint!
    var languagesArray = [languagesData]()
    weak var delegate: SelectLanguageVCDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        UIView.animate(withDuration: 0.5) {
//            self.dropdownBottomConstraint.constant = 0
//            self.view.layoutIfNeeded()
//        }
    }

    override func viewDidLayoutSubviews() {
        
        dropDownContainerView.roundCorners(corners: [.topLeft,.topRight], radius: 14)
    }
    
    // MARK: - Methods
    func setupUI() {
        
        //        languageLabel.text = NSLocalizedString("Language", comment: "")
        //        closeButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        //        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        pickerView.delegate = self
        pickerView.dataSource = self
        getAllLanguage()
        
        
//        dropdownBottomConstraint.constant =  -(self.dropDownContainerView.frame.size.height + 20)
        
        
    }
    
    
    func getAllLanguage() {
        
        if let lang = SharedManager.shared.loadJsonLanguages(filename: "languages") {
            
            self.languagesArray = lang
            
            if UserDefaults.standard.string(forKey: Constant.UD_appLanguageName) == nil || UserDefaults.standard.string(forKey: Constant.UD_appLanguageName) == "" {
                UserDefaults.standard.set(self.languagesArray.first?.name, forKey: Constant.UD_appLanguageName)
            }
            else {
                if let selectedLang = UserDefaults.standard.string(forKey: Constant.UD_appLanguageName), let index = languagesArray.firstIndex(where: {$0.name == selectedLang}) {
                    self.pickerView.selectRow(index, inComponent: 0, animated: false)
//                    self.pickerView.scrol
                }
                
            }
            
            self.pickerView.reloadAllComponents()
        }
    }
    
    
    
    // MARK: - Actions
    @IBAction func didTapClose(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        
        let index = self.pickerView.selectedRow(inComponent: 0)
        let item = self.languagesArray[index]
        
//        performWSToUpdateLanguage(item: self.languagesArray[index])
        SharedManager.shared.languageId = item.id ?? ""
        UserDefaults.standard.set(item.name, forKey: Constant.UD_appLanguageName)
        UserDefaults.standard.set(item.code, forKey: Constant.UD_languageSelected)
        UserDefaults.standard.set(item.image, forKey: Constant.UD_languageFlag)
        UserDefaults.standard.synchronize()
        Bundle.setLanguage(item.code ?? "en")
        
        self.dismiss(animated: true) {
            self.delegate?.didSaveLanguage()
        }
        
    }
    
    
    
    
}

// MARK: - Extensions
// MARK: - PickerView Delegates and datasources
extension SelectLanguageVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.languagesArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return self.languagesArray[row].name ?? ""
    }
    
    
}


extension SelectLanguageVC {
    
    
    func performWSToUpdateLanguage(item: languagesData) {

        let params = ["language": item.id ?? ""]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)

//        ANLoader.showLoading()
        self.showLoaderInVC()
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
                        
                        SharedManager.shared.hideBlockingLoader(isAnimated: false)
                        WebService.checkValidToken { _ in
                            
                            DispatchQueue.main.async {
//                                DataCache.instance.cleanAll()
//                                self.appDelegate.setHomeVC()
                                self.delegate?.didSaveLanguage()
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    })
                }
                
            } catch let jsonerror {

                SharedManager.shared.hideBlockingLoader(isAnimated: false)
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "auth/update-profile/language", error: jsonerror.localizedDescription, code: "")
            }

        }) { (error) in

            SharedManager.shared.hideBlockingLoader(isAnimated: false)
            print("error parsing json objects",error)
        }
    }
    
}
