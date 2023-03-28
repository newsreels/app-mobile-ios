//
//  PostSettingsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 27/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class PostSettingsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var menuItems =  [
        MenuModel(name: "Post language", icon: "PostLanguageSettings"),
//        MenuModel(name: "Haptics", subtitle: "Haptic feedback can be enabled or disbled for the posts here. ", type: .switchSelection),
//        MenuModel(name: "Bullets autoplay", subtitle: "Bullets autoplay can be enabled or disbled for the articles here. ", type: .switchSelection),
        MenuModel(name: "Videos autoplay", subtitle: "Videos autoplay can be enabled or disbled for the articles here. ", type: .switchSelection),
        MenuModel(name: "Reels autoplay", subtitle: "Reels autoplay can be enabled or disbled for the reels here. ", type: .switchSelection),
        MenuModel(name: "Reader mode", subtitle: "Reader mode can be enabled or disbled for the posts here. ", type: .switchSelection),
//        MenuModel(name: "Audio settings", icon: "AudioSettings"),
        MenuModel(name: "Article text size", icon: "TextSizeSettings", type: .info)
    ]
    
    
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
            // Post language
            let vc = OnboardingLanguageVC.instantiate(fromAppStoryboard: .Onboarding)
            vc.isFromProfileVC = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
//        else if index == 6 {
//            // Audio settings
//            let vc = AudioSettingsVC.instantiate(fromAppStoryboard: .registration)
//            self.navigationController?.pushViewController(vc, animated: true)
//
//        }
        else if index == 4 {
            // Article text size
            let vc = TextSizeVC.instantiate(fromAppStoryboard: .Main)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func changeSwitchButton(index: Int, switchStatus: Bool) {
        
//        if index == 1 {
//
//            UserDefaults.standard.set(switchStatus, forKey: Constant.UD_isHapticOn)
//        }
//        if index == 2 {
//            UserDefaults.standard.set(switchStatus, forKey: Constant.UD_isBulletsAutoPlay)
//        }
        if index == 1 {
            UserDefaults.standard.set(switchStatus, forKey: Constant.UD_isDataSaver)
        }
        else if index == 2 {
            UserDefaults.standard.set(switchStatus, forKey: Constant.UD_isReelsAutoPlay)
        }
        else if index == 3 {
            UserDefaults.standard.set(switchStatus, forKey: Constant.UD_isReaderMode)
        }
        
        
    }
    
    func hapticStatus()-> Bool {
        let isOn = UserDefaults.standard.bool(forKey: Constant.UD_isHapticOn)
        if isOn {
            
            return true
        }
        else {
        
           return false
        }
    }
    
    func BulletsAutoplayStatus()-> Bool {
        let isOn = UserDefaults.standard.bool(forKey: Constant.UD_isBulletsAutoPlay)
        if isOn {
            
            return true
        }
        else {
        
           return false
        }
    }
    
    func VideosAutoPlayStatus()-> Bool {
        let isOn = UserDefaults.standard.bool(forKey: Constant.UD_isDataSaver)
        if isOn {
            
            return true
        }
        else {
        
           return false
        }
    }
    
    func ReelsAutoPlayStatus()-> Bool {
        let isOn = UserDefaults.standard.bool(forKey: Constant.UD_isReelsAutoPlay)
        if isOn {
            
            return true
        }
        else {
        
           return false
        }
    }
    
    func ReaderModeStatus()-> Bool {
        let isOn = UserDefaults.standard.bool(forKey: Constant.UD_isReaderMode)
        if isOn {
            
            return true
        }
        else {
        
           return false
        }
    }
    
    func textSizeType()-> String {
        
        switch SharedManager.shared.selectedFontType {
        case .defaultSize:
            return "Default"
        case .smallSize:
            return "Small"
        case .mediumSize:
            return "Medium"
        case .largeSize:
            return "Larger"
        default:
            return "Default"
        }
        
    }
    
    
    // MARK: - Actions
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension PostSettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 || indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuCC") as! menuCC
            cell.setupCell(model: menuItems[indexPath.item])
            
            if indexPath.row == 4 {
                cell.infoLabel.text = textSizeType()
            }
            
            cell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchMenuCC") as! switchMenuCC
            
            var isExtended = false
            if indexPath.row == 1 {
                isExtended = true
            }
            
            var isSwitchOn = false
//            if indexPath.row == 1 {
//                isSwitchOn = hapticStatus()
//            }
//            if indexPath.row == 2 {
//                isSwitchOn = BulletsAutoplayStatus()
//            }
            if indexPath.row == 1 {
                isSwitchOn = VideosAutoPlayStatus()
            }
            else if indexPath.row == 2 {
                isSwitchOn = ReelsAutoPlayStatus()
            }
            else if indexPath.row == 3 {
                isSwitchOn = ReaderModeStatus()
            }
            
            cell.setupCell(model: menuItems[indexPath.item], isOn: isSwitchOn, isExtended: isExtended)
            cell.delegate = self
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return Constant.commonCellSize.normalMenuItemHeight
        }
        else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 {
            return UITableView.automaticDimension
        }
        else if indexPath.row == 4 {
            return Constant.commonCellSize.extendedMenuItemHeight
        }
        return Constant.commonCellSize.normalMenuItemHeight
    }
    
    
}


extension PostSettingsVC: menuCCDelegate {
    
    func didTapItem(cell: menuCC) {
        
        let indexPath = tableView.indexPath(for: cell)
        self.openSettings(index: indexPath?.row ?? 0)
        
    }
    
}

extension PostSettingsVC: switchMenuCCDelegate {
    
    func didTapItem(cell: switchMenuCC, switchStatus: Bool) {
        
        let indexPath = tableView.indexPath(for: cell)
        self.changeSwitchButton(index: indexPath?.row ?? 0, switchStatus: switchStatus)
        
    }
    
}

