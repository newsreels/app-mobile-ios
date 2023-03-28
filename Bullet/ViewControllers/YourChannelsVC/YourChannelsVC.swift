//
//  YourChannelsVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 07/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class YourChannelsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNoChannel: UILabel!
    
    var channelsArray = [ChannelInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.theme_backgroundColor = GlobalPicker.followingViewBGColor
        self.lblTitle.theme_textColor = GlobalPicker.textColor
        self.lblNoChannel.theme_textColor = GlobalPicker.textSubColorDiscover
        registerCells()
        setLocalization()
        
        
        SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.performWSToGetChannels()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL() {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
            } else {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
            }
        }
        
        
    }
    
    func registerCells() {
        
        tableView.register(UINib(nibName: "ChannelContactCC", bundle: nil), forCellReuseIdentifier: "ChannelContactCC")
        tableView.register(UINib(nibName: "AddChannelCC", bundle: nil), forCellReuseIdentifier: "AddChannelCC")
        tableView.register(UINib(nibName: "ChannelListCC", bundle: nil), forCellReuseIdentifier: "ChannelListCC")
    }
    
    
    func setLocalization() {
        
        self.lblTitle.text = NSLocalizedString("Your Channels", comment: "")
        
    }
    
    //Button actions
    @IBAction func didTapBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension YourChannelsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.channelsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let channel = self.channelsArray[indexPath.row]
        
        if channel.channelModelType == "info" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelContactCC") as! ChannelContactCC
            cell.delegate = self
            return cell

        }
        else if channel.channelModelType == "create" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddChannelCC") as! AddChannelCC
            cell.viewBG.isHidden = true
            self.lblNoChannel.isHidden = true
            if self.channelsArray.count == 1 {
                
                self.lblNoChannel.isHidden = false
                cell.viewBG.isHidden = false
            }
            cell.delegate = self
            return cell

        }
        else {

            let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelListCC") as! ChannelListCC
            cell.setupCell(channel: channel)
            return cell
            
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let channel = self.channelsArray[indexPath.row]
        performGoToSource(channel)
    }
}

// MARK: - Delegates
extension YourChannelsVC: AddChannelCCDelegate {
    
    func userPressedAddChannel() {
        
        if SharedManager.shared.isGuestUser && SharedManager.shared.isLinkedUser == false {
                        
            let vc = RegistrationNewVC.instantiate(fromAppStoryboard: .RegistrationSB)
            let navVC = UINavigationController(rootViewController: vc)
            self.navigationController?.present(navVC, animated: true, completion: nil)
        }
        else {
            
            let vc = ChannelNameVC.instantiate(fromAppStoryboard: .Channel)
            let nav = AppNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
}

extension YourChannelsVC: ChannelContactCCDelegate {
    
    func didTapContactUs() {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.helpCenter, eventDescription: "")
        let vc = contactUsVC.instantiate(fromAppStoryboard: .registration)
        vc.userMessage = "Hi! I'm interested in creating another channel."
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
}

// MARK: - Webservices
extension YourChannelsVC {
    
    func performWSToGetChannels() {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("studio/channels", method: .get, parameters: nil, headers: token, withSuccess: { [weak self] (response) in
            ANLoader.hide()
            guard let self = self else {
                return
            }
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                
                self.channelsArray.removeAll()
                
                if let channelsData = FULLResponse.channels, channelsData.count > 0 {
                    
                    self.channelsArray = channelsData
                }
                
                var channelType = "create"
                if self.channelsArray.count == 5 {
                    channelType = "info"
                }
                let channel = ChannelInfo(id: nil, name: nil, channelDescription: nil, link: nil, icon: nil, image: nil, updateCount: nil, channelModelType: channelType)
                self.channelsArray.append(channel)
                
                self.tableView.reloadData()
            } catch let jsonerror {
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "studio/channels", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performGoToSource(_ channel: ChannelInfo) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let id = channel.id ?? ""
        let query = "news/sources/data/\(id)"
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        WebService.URLResponse(query, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let Info = FULLResponse.channel {
                        
                        let vc = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
                        vc.channelInfo = Info
                        let nav = AppNavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        self.navigationController?.present(nav, animated: true, completion: nil)
                    }
                    else {
                        
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: NSLocalizedString("Related Sources not available", comment: ""))
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
}
