//
//  ProfileSelectionVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 20/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol ProfileSelectionVCDelegate: class {
    
    func didSelectChannel(channel: ChannelInfo?)
    
    
}
class ProfileSelectionVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewNav: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgClose: UIImageView!
    
    var channelsArray = [DataChannels]()
    var delegate: ProfileSelectionVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.theme_backgroundColor = GlobalPicker.backgroundColorWhiteBlack
        registerCells()
        tableView.delegate = self
        tableView.dataSource = self
        viewNav.theme_backgroundColor = GlobalPicker.backgroundColorWhiteBlack
//        viewNav.layer.sha
        imgClose.theme_image = GlobalPicker.closeSelection
        performWSToGetChannels()
        
        self.view.layoutIfNeeded()
        viewNav.roundCorners(corners: [.topLeft, .topRight], radius: 24)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        viewNav.roundCorners(corners: [.topLeft, .topRight], radius: 24)
    }
    
    // MARK: - Methods
    func registerCells() {
        
        tableView.register(UINib(nibName: "ProfileSelectionCC", bundle: nil), forCellReuseIdentifier: "ProfileSelectionCC")
        tableView.register(UINib(nibName: "ProfileSelectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "ProfileSelectionHeader")

    }
    
    
    // MARK : - Actions
    @IBAction func didTapClose(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}


extension ProfileSelectionVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return channelsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return channelsArray[section].channels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSelectionCC") as! ProfileSelectionCC
        cell.setupCell(channel: channelsArray[indexPath.section].channels?[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProfileSelectionHeader") as! ProfileSelectionHeader
        header.lblTitle.text = channelsArray[section].title ?? ""
        header.lblTitle.theme_textColor = GlobalPicker.textBWColor
        header.viewBackground.theme_backgroundColor = GlobalPicker.channelUnderlineColor
        
        return header
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let channel = channelsArray[indexPath.section].channels?[indexPath.row]
        self.delegate?.didSelectChannel(channel: channel)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    }
}


// MARK: - Webservices
extension ProfileSelectionVC {
    
    func performWSToGetChannels() {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        

        ANLoader.showLoading(disableUI: false)
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        WebService.URLResponse("studio/channels/categorized", method: .get, parameters: nil, headers: token, withSuccess: { [weak self] (response) in
           
            ANLoader.hide()
            
            guard let self = self else {
                return
            }
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(UserChannelsDC.self, from: response)
                
                
                self.channelsArray.removeAll()
                
                if let channelsData = FULLResponse.data, channelsData.count > 0 {
                    
                    self.channelsArray = channelsData
                }
                
                if let profile = FULLResponse.profile {
                    
                    let name = (profile.first_name ?? "") + " " + (profile.last_name ?? "")
                    let channel = ChannelInfo(id: profile.id ?? "", name: name, channelDescription: "", link: "", icon: profile.profile_image ?? "", portrait_image: profile.cover_image ?? "", image: profile.cover_image ?? "", updateCount: 0, channelModelType: "", follower_count: profile.follower_count ?? 0)
                    let dataChannel = DataChannels(channels: [channel], title: "PROFILE")
                    self.channelsArray.insert(dataChannel, at: 0)
                }
                
                
                self.tableView.reloadData()
                
            } catch let jsonerror {
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "studio/channels/categorized", error: jsonerror.localizedDescription, code: "")
                
            }
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
}
