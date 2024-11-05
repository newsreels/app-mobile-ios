//
//  settingsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 26/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import DataCache

struct MenuModel {
    var name: String?
    var subtitle: String?
    var icon: String?
    var info: String?
    var type: menuItemType?
}

enum menuItemType {
    case normal
    case switchSelection
    case info
}

class SettingsVC: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgNotification: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblViewProfile: UILabel!
    @IBOutlet weak var viewPostArticle: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileRightArrow: UIImageView!
    
    @IBOutlet weak var lblVersion: UILabel!
    
    var menuItems =  [
        
//        MenuModel(name: "Preferences", icon: "SecuritySettings"),
        MenuModel(name: "Content Settings", icon: "PostSettings"),
        MenuModel(name: "Account settings", icon: "AccountSettings"),
        MenuModel(name: "Notification settings", icon: "NotificationSettings"),
//        MenuModel(name: "Manage wallet", icon: "WalletSettings", info: "$0.00", type: .info),
        MenuModel(name: "Community terms and policy", icon: "PrivacySettings"),
        MenuModel(name: "Helps & feedback", icon: "FeedbackSettings"),
        MenuModel(name: "Logout", icon: "LogoutSettings")
    ]
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        registerCells()
        setupUI()
        setStatusBar()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        setStatusBar()
        setProfileData()
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(true, animated: false)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        setStatusBar()
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(true, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imgProfile.cornerRadius = imgProfile.frame.height / 2
        imgProfile.contentMode = .scaleAspectFill
    }
    
    // MARK: - Methods
    func setupUI() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        lblVersion.text = "\(NSLocalizedString("App version", comment: "")) \(Bundle.main.releaseVersionNumber ?? "1.0").\(Bundle.main.buildVersionNumber ?? "1.0")"
        lblVersion.textColor = Constant.appColor.lightRed
        
        
    }
    
    func registerCells() {
        
        tableView.register(UINib(nibName: "menuCC", bundle: nil), forCellReuseIdentifier: "menuCC")
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
//
//            if let ptcTBC = tabBarController as? PTCardTabBarController {
//                ptcTBC.showTabBar(false, animated: true)
//            }
//
//            let vc = ForYouPreferencesVC.instantiate(fromAppStoryboard: .Reels)
//            vc.delegate = self
//            vc.currentCategory = SharedManager.shared.curCategoryId
//            vc.isOpenFromMenu = true
//            let nav = AppNavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: true, completion: nil)
//
//        }
        if index == 0 {
            
            if let ptcTBC = tabBarController as? PTCardTabBarController {
                ptcTBC.showTabBar(false, animated: true)
            }
            
            // Post settings
            let vc = PostSettingsVC.instantiate(fromAppStoryboard: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        else if index == 1 {
            
            if let ptcTBC = tabBarController as? PTCardTabBarController {
                ptcTBC.showTabBar(false, animated: true)
            }
            
            // Account Settings
            let vc = AccountSettingsVC.instantiate(fromAppStoryboard: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
//        else if index == 3 {
//
//            // Wallet
//            if let walletLink = UserDefaults.standard.string(forKey: Constant.UD_WalletLink) {
//
//                if let ptcTBC = tabBarController as? PTCardTabBarController {
//                    ptcTBC.showTabBar(false, animated: true)
//                }
//
//                let vc = WalletWebviewVC.instantiate(fromAppStoryboard: .Channel)
//                vc.webURL = walletLink
//                vc.titleWeb = "Wallet"
//                let nav = AppNavigationController(rootViewController: vc)
//                if MyThemes.current == .light {
//                    nav.showDarkStatusBar = true
//                }
//                nav.modalPresentationStyle = .overFullScreen
//
//                self.navigationController?.pushViewController(vc, animated: true)
//                //present(nav, animated: true, completion: nil)
//            }
//
//        }
        else if index == 2 {
            
            // Notification Settings
            if let ptcTBC = tabBarController as? PTCardTabBarController {
                ptcTBC.showTabBar(false, animated: true)
            }
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.pushClicks, eventDescription: "")
            let vc = NotificationVC.instantiate(fromAppStoryboard: .Main)
//            let nav = AppNavigationController(rootViewController: vc)
//            if MyThemes.current == .light {
//                nav.showDarkStatusBar = true
//            }
//            nav.modalPresentationStyle = .fullScreen
//            nav.navigationBar.isHidden = true
//            self.present(nav, animated: true, completion: nil)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if index == 3 {
            // Community Terms and Policy
            if let ptcTBC = tabBarController as? PTCardTabBarController {
                ptcTBC.showTabBar(false, animated: true)
            }
            
            // TermsSettingsVC
            let vc = TermsSettingsVC.instantiate(fromAppStoryboard: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        else if index == 4 {
            // Helps & feedback
            if let ptcTBC = tabBarController as? PTCardTabBarController {
                ptcTBC.showTabBar(false, animated: true)
            }
            
            // HelpSettingsVC
            let vc = HelpSettingsVC.instantiate(fromAppStoryboard: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if index == 5 {
            // Logout
            performWSTologoutUser()
        }
        
        
    }
    
    // MARK: - Actions
    @IBAction func didTapShowNotifications(_ sender: UIButton) {
        
        let vc = NotificationsListVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapViewProfile(_ sender: UIButton) {
        
        if SharedManager.shared.isGuestUser && SharedManager.shared.isLinkedUser == false {
                        
            let vc = RegistrationNewVC.instantiate(fromAppStoryboard: .RegistrationSB)
            let navVC = UINavigationController(rootViewController: vc)
            self.navigationController?.present(navVC, animated: true, completion: nil)
        }
        else {
            
            if let ptcTBC = tabBarController as? PTCardTabBarController {
                ptcTBC.showTabBar(false, animated: true)
            }
            
            // Personal information
            let vc = UserInfoVC.instantiate(fromAppStoryboard: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
            
            //            if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails), (user.setup ?? false) {
            /*
            let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
            let navVC = AppNavigationController(rootViewController: vc)
            if MyThemes.current == .light {
                navVC.showDarkStatusBar = true
            }
            navVC.modalPresentationStyle = .fullScreen
            //vc.delegate = self
            self.present(navVC, animated: true, completion: nil)
            */
            
            /*
            let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
            detailsVC.isOpenFromReel = false
//            detailsVC.delegate = self
            detailsVC.isOpenForTopics = false
            
            let channel = ChannelInfo(id: nil, name: nil, channelDescription: nil, link: nil, icon: nil, image: nil, updateCount: nil, own: true)
            
            detailsVC.channelInfo = channel
    //        detailsVC.context = channel.context ?? ""
    //                    detailsVC.topicTitle = "#\(articles[indexPath.row].suggestedTopics?[row].name ?? "")"
            detailsVC.modalPresentationStyle = .fullScreen
            
            let nav = AppNavigationController(rootViewController: detailsVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            */
            
        }
    }
    
    @IBAction func didTapTikTok(_ sender: Any) {
        
//        https://vm.tiktok.com/ZSJwvRwFk/
        let appURLString = "https://www.tiktok.com/@newsreels.india"
        let webURLString = "https://www.tiktok.com/@newsreels.india"
        guard let appURL = URL(string: appURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
            return
        }
        
        guard let webURL = URL(string: webURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(webURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL)
            }
        }
    }
    
    @IBAction func didTapTwitter(_ sender: Any) {
        //https://twitter.com/Newsreelsapp
        let appURLString = "twitter://user?screen_name=Newsreelsapp"
        let webURLString = "https://twitter.com/Newsreelsapp"
        guard let appURL = URL(string: appURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
            return
        }
        
        guard let webURL = URL(string: webURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(webURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL)
            }
        }
    }
    
    @IBAction func didTapFb(_ sender: Any) {
        
        let appURLString = "fb://profile/100980738491568"
        let webURLString = "https://www.facebook.com/newsreelsofficial/"
        guard let appURL = URL(string: appURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
            return
        }
        
        guard let webURL = URL(string: webURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(webURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL)
            }
        }
    }
    
    @IBAction func didTapYoutube(_ sender: Any) {
        
//https://www.youtube.com/c/NewsreelsOfficial

        let appURLString = "youtube://channel/UCAouHcHjTMJhZAE1E5tdjSg"
        let webURLString = "https://www.youtube.com/channel/UCAouHcHjTMJhZAE1E5tdjSg"
        guard let appURL = URL(string: appURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
            return
        }
        
        guard let webURL = URL(string: webURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(webURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL)
            }
        }
    }
    
    @IBAction func didTapInsta(_ sender: Any) {
        
        //https://www.instagram.com/newsreelsofficial/
        let appURLString = "instagram://user?username=newsreelsofficial"
        let webURLString = "https://www.instagram.com/newsreelsofficial/"
        guard let appURL = URL(string: appURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
            return
        }
        
        guard let webURL = URL(string: webURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(webURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL)
            }
        }
    }
    
    
}

//MARK:- Edit Profile Delegate
extension SettingsVC: EditProfileVCDelegate {
    
    func setProfileData() {
        
        if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {
            
            let profile = user.profile_image ?? ""

            if profile.isEmpty {
                
                //imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
                imgProfile.image = UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" : "icn_profile_placeholder_light")
            }
            else {
                imgProfile.sd_setImage(with: URL(string: profile), placeholderImage: nil)
            }
            
            let fname = user.first_name ?? ""
//            let lname = user.last_name ?? ""
            
            if fname.isEmpty {
                
                profileRightArrow.isHidden = false
                lblEmail.text = NSLocalizedString("Create your profile", comment: "")
                lblViewProfile.text = NSLocalizedString("Set your profile", comment: "")
            }
            else {
                profileRightArrow.isHidden = false
                lblEmail.text = fname.capitalized //+ " " + lname
                lblViewProfile.text = NSLocalizedString("View your profile", comment: "")
            }
        }
        else {
            
            //imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
            imgProfile.image = UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" : "icn_profile_placeholder_light")
            lblEmail.text = NSLocalizedString("Create your profile", comment: "")
            lblViewProfile.text = NSLocalizedString("Set your profile", comment: "")
        }

    }
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCC") as! menuCC
        cell.setupCell(model: menuItems[indexPath.item])
        cell.delegate = self
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 3 || indexPath.row == 5 {
            return Constant.commonCellSize.extendedMenuItemHeight
        }
        return Constant.commonCellSize.normalMenuItemHeight
    }
    
    
}

extension SettingsVC: menuCCDelegate {
    
    func didTapItem(cell: menuCC) {
        
        let indexPath = tableView.indexPath(for: cell)
        self.openSettings(index: indexPath?.row ?? 0)
        
    }
}


extension SettingsVC: ForYouPreferencesVCDelegate {
    
    func userChangedCategory() {
        
        //we will save article id and selected index to update list on home screen
       // let subData = self.homeCategoriesArray[indexPath.section].data
        NotificationCenter.default.post(name: Notification.Name.notifyTapSubcategories, object: nil)
    }
    
    
    func userDismissed(vc: ForYouPreferencesVC, selectedPreference: Int, selectedCategory: String) {
    }
    
}

extension SettingsVC {
    
    func performWSTologoutUser() {
    
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.logoutClick)

        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.showLoaderInVC()
        
        let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
        let refreshToken = UserDefaults.standard.value(forKey: Constant.UD_refreshToken) ?? ""
        let params = ["token": refreshToken]
        
        WebService.URLResponseAuth("auth/logout", method: .post, parameters: params, headers: userToken as? String, withSuccess: { (response) in
            self.hideLoaderVC()
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userDC.self, from: response)
        
                if FULLResponse.message?.lowercased() == "success" {
                    
                    self.appDelegate.logout()
                }
                else {
                    
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                
            } catch let jsonerror {
                self.hideLoaderVC()
                SharedManager.shared.logAPIError(url: "auth/logout", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }){ (error) in
            
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
    
}
