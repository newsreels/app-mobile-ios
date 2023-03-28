//
//  FollowingPreferenceVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 02/03/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol FollowingPreferenceVCDelegate: AnyObject {
    func userDismissed(vc: FollowingPreferenceVC)
}

class FollowingPreferenceVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewNav: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var closeImage: UIImageView!
    
    @IBOutlet weak var viewNavTransparent: UIView!
    
    var isSelectedRow = false
    weak var delegate: FollowingPreferenceVCDelegate?
    var channelsArray = [ChannelInfo]()
    var nextPaginate = ""
    var isApiRunning = false
    var hasReels = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerCells()
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setupUI()
        performWSToGetChannels()
        
        self.navigationController?.presentationController?.delegate = self
        
        setStatusBar()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        setStatusBar()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    // MARK: - Methods
    func setupUI() {
        
        titleLabel.text = "Channels"
//        viewNav.alpha = 0
//        viewNavTransparent.alpha = 1
        viewNav.alpha = 1
        viewNavTransparent.alpha = 0
    }
    
    func registerCells() {
        
        self.tableView.register(UINib(nibName: "UserFollowCC", bundle: nil), forCellReuseIdentifier: "UserFollowCC")
        
        print("cells registered")
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        /*
        print("self.tableView.contentOffset.y", self.tableView.contentOffset.y)
        
        if self.tableView.contentOffset.y > -50 {
            
            if viewNav.alpha == 0 {
                UIView.animate(withDuration: 0.5) {
                    self.viewNav.alpha = 1
                    self.viewNavTransparent.alpha = 0
                }
            }
        }
        else {
            if viewNav.alpha == 1 {
                UIView.animate(withDuration: 0.5) {
                    self.viewNav.alpha = 0
                    self.viewNavTransparent.alpha = 1
                }
            }
        }
        */
        
        
    }
    
    func openChannelDetails(channel: ChannelInfo) {
        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
        detailsVC.isOpenFromReel = false
        detailsVC.delegate = self
        detailsVC.isOpenForTopics = false
        detailsVC.channelInfo = channel
//        detailsVC.context = channel.context ?? ""
//                    detailsVC.topicTitle = "#\(articles[indexPath.row].suggestedTopics?[row].name ?? "")"
        detailsVC.modalPresentationStyle = .fullScreen
        
        let nav = AppNavigationController(rootViewController: detailsVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    
    // MARK: - Actions
    @IBAction func didTapBack(_ sender: Any) {
        
        self.delegate?.userDismissed(vc: self)
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapSearch(_ sender: Any) {
    }
    
    

}

extension FollowingPreferenceVC: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        self.delegate?.userDismissed(vc: self)
    }
}


extension FollowingPreferenceVC: UITableViewDataSource, UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsArray.count
    }
    
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserFollowCC", for: indexPath) as! UserFollowCC
        cell.setupCell(model: channelsArray[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if nextPaginate.isEmpty == false, channelsArray.count > 0, isApiRunning == false, channelsArray.count - 5 >= indexPath.row {
            performWSToGetChannels()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let channel = channelsArray[indexPath.row]
        openChannelDetails(channel: channel)
        
        
    }
}

extension FollowingPreferenceVC: UserFollowCCDelegate {
    
    func didTapFollowing(cell: UserFollowCC) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        channelsArray[indexPath.row].isShowingLoader = true
        self.tableView.reloadData()
        SharedManager.shared.performWSToUpdateUserFollow(id: [channelsArray[indexPath.row].id ?? ""], isFav: !(channelsArray[indexPath.row].favorite ?? false), type: .sources) { success in
            
            if success {
                self.channelsArray[indexPath.row].favorite = !(self.channelsArray[indexPath.row].favorite ?? false)
            }
            else {
                // failed
                // don't update
            }
            self.channelsArray[indexPath.row].isShowingLoader = false
            self.tableView.reloadData()
        }
        
    }
}

extension FollowingPreferenceVC {
    
    //Followed Topics
    func performWSToGetChannels() {

        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        if self.nextPaginate.isEmpty {
            self.view.showLoader(backgroundColorNeeded: true, isShowingFullScreenLoader: true)
        }
        self.isApiRunning = true
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        WebService.URLResponse("news/sources/suggested?page=\(nextPaginate)&has_reels=\(hasReels)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.view.hideLoaderView()
            self.isApiRunning = false
            
            do {
                let FULLResponse = try
                    JSONDecoder().decode(sourcesDC.self, from: response)
                
                if let sources = FULLResponse.sources {
                    
                    if self.channelsArray.count >= 0 {
                        self.channelsArray += sources
                    }
                    else {
                        self.channelsArray = sources
                    }
                    
                }
                
                self.tableView.reloadData()
                if let meta = FULLResponse.meta {
                    self.nextPaginate = meta.next ?? ""
                }
                
            } catch let jsonerror {
                self.view.hideLoaderView()
                self.isApiRunning = false
                ANLoader.hide()
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/topics/followed?page=\(self.nextPaginate)", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            self.view.hideLoaderView()
            self.isApiRunning = false
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    
}

extension FollowingPreferenceVC: ChannelDetailsVCDelegate {
    
    func backButtonPressedChannelDetailsVC() {
    }
    
    func backButtonPressedWhenFromReels(_ channel: ChannelInfo?) {
    }
    
    
}



extension FollowingPreferenceVC: AquamanChildViewController {
    
    func aquamanChildScrollView() -> UIScrollView {
        return tableView
    }
    
}
