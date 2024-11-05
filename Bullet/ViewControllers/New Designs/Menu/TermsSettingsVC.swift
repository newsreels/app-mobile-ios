//
//  TermsSettingsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 04/05/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class TermsSettingsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var menuItems =  [
        MenuModel(name: "Terms & Conditions", icon: "TermsSettings"),
        MenuModel(name: "Privacy Policy", icon: "PrivacySettings2"),
        MenuModel(name: "Community Guidelines", icon: "CommunitySettings"),
        MenuModel(name: "About", icon: "AboutSettings")
    ]
    
    var languagesArray = [languagesData]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        registerCells()
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
        
        if index == 0 {
            // Terms & Conditions
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.termsClick, eventDescription: "")
            let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
            vc.webURL = "https://www.newsinbullets.app/terms/?header=false"
            vc.titleWeb = NSLocalizedString("Terms & Conditions", comment: "")
//            vc.modalPresentationStyle = .overFullScreen
//            self.present(vc, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        else if index == 1 {
            // Privacy Policy
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.policyClick, eventDescription: "")
            let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
            vc.webURL = "https://www.newsinbullets.app/privacy/?header=false"
            vc.titleWeb = NSLocalizedString("Privacy Policy", comment: "")
//            vc.modalPresentationStyle = .overFullScreen
//            self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
            
        }
        else if index == 2 {
            // Community Guidelines
            let vc = webViewVC.instantiate(fromAppStoryboard: .registration)
            vc.webURL = "https://www.newsinbullets.app/community-guidelines?header=false"
            vc.titleWeb = NSLocalizedString("Community Guidelines", comment: "")
//            vc.modalPresentationStyle = .overFullScreen
//            self.present(vc, animated: true, completion: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            
        }
        else if index == 3 {
            //About
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.aboutClick, eventDescription: "")
            let vc = AboutVC.instantiate(fromAppStoryboard: .registration)
//            vc.modalPresentationStyle = .overFullScreen
//            self.present(vc, animated: true, completion: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    
    // MARK: - Actions
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension TermsSettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCC") as! menuCC
        cell.setupCell(model: menuItems[indexPath.item])
        
        if indexPath.row == 3 {
            cell.infoLabel.text = UserDefaults.standard.string(forKey: Constant.UD_appLanguageName)
        }
        
        cell.delegate = self
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
 
        
        return Constant.commonCellSize.normalMenuItemHeight
    }
    
    
}

extension TermsSettingsVC: menuCCDelegate {
    
    func didTapItem(cell: menuCC) {
        
        let indexPath = tableView.indexPath(for: cell)
        self.openSettings(index: indexPath?.row ?? 0)
        
    }
    
}
