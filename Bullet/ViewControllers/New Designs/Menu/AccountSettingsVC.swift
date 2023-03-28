//
//  AccountSettingsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 28/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class AccountSettingsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var menuItems =  [
//        MenuModel(name: "Personal information", icon: "PersonalSettings"),
        MenuModel(name: "Change email", icon: "EmailSettings"),
        MenuModel(name: "Change password", icon: "PasswordSettings"),
        MenuModel(name: "App language", icon: "LanguageSettings", type: .info),
        MenuModel(name: "Block List", icon: "PostLanguageSettings"),
        MenuModel(name: "Favorites", icon: "FavSettings")
    ]
    var languagesArray = [languagesData]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        registerCells()
        getAllLanguage()
        setupUI()
        setStatusBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        setStatusBar()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        setStatusBar()
    }

    // MARK: - Methods
    func setupUI() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func registerCells() {
        
        tableView.register(UINib(nibName: "menuCC", bundle: nil), forCellReuseIdentifier: "menuCC")
        tableView.register(UINib(nibName: "switchMenuCC", bundle: nil), forCellReuseIdentifier: "switchMenuCC")
        
    }
    
    
    func setStatusBar() {
        var navVC = (self.navigationController?.navigationController as? AppNavigationController)
        if navVC == nil {
            navVC = (self.navigationController as? AppNavigationController)
        }
        if navVC?.showDarkStatusBar == false {
            navVC?.showDarkStatusBar = true
            navVC?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func openSettings(index: Int) {
        
//        if index == 0 {
//            // Personal information
//            let vc = UserInfoVC.instantiate(fromAppStoryboard: .Profile)
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        if index == 0 {
            // Change email
            let vc = ChangeEmailVC.instantiate(fromAppStoryboard: .registration)
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
//            self.present(vc, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if index == 1 {
            // Change password
            let vc = ChangePasswordVC.instantiate(fromAppStoryboard: .registration)
            vc.modalPresentationStyle = .overFullScreen
//            self.present(vc, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if index == 2 {
            
            //Language
            let vc = LanguageVC.instantiate(fromAppStoryboard: .Main)
    //        vc.modalPresentationStyle = .overFullScreen
//            let nav = AppNavigationController(rootViewController: vc)
//            if MyThemes.current == .light {
//                nav.showDarkStatusBar = true
//            }
//            nav.modalPresentationStyle = .fullScreen
//            nav.navigationBar.isHidden = true
////            self.present(nav, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if index == 3 {
            // Block List
            let vc = blockListVC.instantiate(fromAppStoryboard: .registration)
//            let navVC = AppNavigationController(rootViewController: vc)
//            navVC.modalPresentationStyle = .overFullScreen
//            self.present(navVC, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if index == 4 {
            // Favorites
            let vc = DraftSavedArticlesVC.instantiate(fromAppStoryboard: .Schedule)
            vc.isFromSaveArticles = true
//            let nav = AppNavigationController(rootViewController: vc)
//            if MyThemes.current == .light {
//                nav.showDarkStatusBar = true
//            }
//            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: true, completion: nil)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func getAllLanguage() {
        
        if let lang = SharedManager.shared.loadJsonLanguages(filename: "languages") {
            
            self.languagesArray = lang
            
            if UserDefaults.standard.string(forKey: Constant.UD_appLanguageName) == nil || UserDefaults.standard.string(forKey: Constant.UD_appLanguageName) == "" {
                UserDefaults.standard.set(self.languagesArray.first?.name, forKey: Constant.UD_appLanguageName)
            }
            
        }
    }
    
    
    // MARK: - Actions
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension AccountSettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCC") as! menuCC
        cell.setupCell(model: menuItems[indexPath.item])
        
        if indexPath.row == 2 {
            cell.infoLabel.text = UserDefaults.standard.string(forKey: Constant.UD_appLanguageName)
        }
        
        cell.delegate = self
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let hasPassword = UserDefaults.standard.bool(forKey: Constant.UD_isSocialLinked)

        if indexPath.row == 0 || indexPath.row == 1 {
            if SharedManager.shared.isGuestUser && SharedManager.shared.isLinkedUser == false {
                return 0
            }
            else if hasPassword {
                return Constant.commonCellSize.normalMenuItemHeight
            }
            else {
                return 0
            }
        }
        else {
            return Constant.commonCellSize.normalMenuItemHeight
        }
        
    }
    
    
}

extension AccountSettingsVC: menuCCDelegate {
    
    func didTapItem(cell: menuCC) {
        
        let indexPath = tableView.indexPath(for: cell)
        self.openSettings(index: indexPath?.row ?? 0)
        
    }
    
}

extension AccountSettingsVC: ChangeEmailVCDelegate {
    
    func emailUpdated() {
//        self.lblEmail.text = UserDefaults.standard.value(forKey: Constant.UD_userEmail) as? String
    }
}
