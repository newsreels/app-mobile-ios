//
//  ChannelDetailsVC.swift
//  Bullet
//
//  Created by Mahesh on 17/06/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol ChannelDetailsVCDelegate: AnyObject {
    
    func backButtonPressedChannelDetailsVC()
    func backButtonPressedWhenFromReels(_ channel: ChannelInfo?)
}

class ChannelDetailsVC: UIViewController {
    
//    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var viewNav: UIView!
    
    
    @IBOutlet weak var viewMoreImageView: UIImageView!
    @IBOutlet weak var viewMoreButton: UIButton!
    
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var notificationView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    
    var profileVC = ProfilePageViewController()
    var channelInfo: ChannelInfo?
    var isFav = false
    var isFirstLoadView = true
    var isOpenFromReel = false
    var isOpenForTopics = false
    var context = ""
    
    @IBOutlet weak var titleLabell: UILabel!
    weak var delegate: ChannelDetailsVCDelegate?
    var topicTitle = ""
    var shareTitle =  ""
    var articleArchived = false
    var sourceBlock = false
    var sourceFollow = false
    var fromDiscover = false
    
    @IBOutlet var verifiedIconImageView: UIImageView!
    
    var isVerified : Bool  {
        return self.channelInfo?.verified ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDesignView()
        SharedManager.shared.bulletPlayer = nil
        isFirstLoadView = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isFirstLoadView {
            
            if let vc = profileVC.currentViewController as? ProfileArticlesVC  {
                if SharedManager.shared.isReloadProfileArticle {
                    vc.viewWillAppear(true)
                }
                else {
                    vc.reloadData()
                }
            }
        }
        
        isFirstLoadView = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SharedManager.shared.bulletPlayer = nil
        
        if let vc = profileVC.currentViewController as? ProfileArticlesVC {
            vc.updateProgressbarStatus(isPause: true)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileEmbedSegue" {
            
            var own = self.channelInfo?.own ?? false

            profileVC = segue.destination as! ProfilePageViewController
            //profileVC.pageDelegate = self
            profileVC.isOpenForTopics = isOpenForTopics
            profileVC.context = context
            if isOpenForTopics {
                profileVC.isFromChannelView = false
            }
            else {
                profileVC.isFromChannelView = true
            }
            profileVC.isOwnChannel = own
            profileVC.selectedChannel = own ? self.channelInfo : self.channelInfo
            profileVC.delegate = self
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        DispatchQueue.main.async {
//            if SharedManager.shared.isSelectedLanguageRTL() {
//                self.lblNavTitle.semanticContentAttribute = .forceRightToLeft
//                self.lblNavTitle.textAlignment = .right
//            } else {
//                self.lblNavTitle.semanticContentAttribute = .forceLeftToRight
//                self.lblNavTitle.textAlignment = .left
//            }
//        }
    }

    
    func setDesignView() {
        
//        view.backgroundColor = .black
        //view.theme_backgroundColor = GlobalPicker.backgroundColor
//        imgBack.theme_image = GlobalPicker.imgBack
        
        //lblNavTitle.theme_textColor = GlobalPicker.textColor
//        lblNavTitle.textColor = .white
//        lblNavTitle.text = self.channelInfo?.name ?? ""
        
        moreView.isHidden = false
        menuView.isHidden = true
        notificationView.isHidden = true
        
        if isOpenForTopics {
            imgBack.image = UIImage(named: "BackArrowBlack")
            viewMoreButton.isHidden = true
            viewMoreImageView.isHidden = true
            titleLabell.isHidden = false
            verifiedIconImageView.isHidden = !isVerified
        }
        else {
            titleLabell.isHidden = true
        }
        titleLabell.text = topicTitle
        
        
    }
    
    func openViewMoreOptions(isopenForChannelReport: Bool) {
        
        let content = articlesData(id: channelInfo?.id ?? "", title: "", media: nil, image: nil, link: nil, color: nil, publish_time: nil, source: channelInfo, bullets: nil, topics: nil, status: nil, mute: nil, type: nil, meta: nil, info: nil, media_meta: nil)
        
        let vc = BottomSheetVC.instantiate(fromAppStoryboard: .registration)
        vc.delegateBottomSheet = self
        vc.article = content
        vc.isOpenForChannelDetails = isopenForChannelReport
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapBackAction(_ sender: Any) {
        
        SharedManager.shared.bulletPlayer = nil
        if let vc = profileVC.currentViewController as? ProfileArticlesVC {
            vc.updateProgressbarStatus(isPause: true)
        }
        
        if isOpenFromReel {
            self.delegate?.backButtonPressedWhenFromReels(profileVC.selectedChannel)
        }
        else {
            self.delegate?.backButtonPressedChannelDetailsVC()
        }
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapViewMore(_ sender: Any) {
        
//        performWSToShare(id: channelInfo?.id ?? "")
        openViewMoreOptions(isopenForChannelReport: true)
        
    }
    
    @IBAction func didTapProfile(_ sender: Any) {
        
//        let vc = ProfileVC.instantiate(fromAppStoryboard: .Profile)
//        vc.isOpenFromChannel = true
//        let nav = AppNavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        self.present(nav, animated: true, completion: nil)

    }
    
    
    @IBAction func didTapNotifications(_ sender: Any) {
        
        let vc = NotificationsListVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
//        vc.delegate = self
        self.present(nav, animated: true, completion: nil)
        
    }
    
    
    
}

extension ChannelDetailsVC: ProfilePageViewControllerDelegate {
    
    func shouldShowTitle(_ condition: Bool) {
        if !(channelInfo?.name?.isEmpty ?? true) {
            self.titleLabell.isHidden = !condition
            self.verifiedIconImageView.isHidden = condition ? !isVerified : true
            self.titleLabell.text = channelInfo?.name ?? ""
        }
    }

}

extension ChannelDetailsVC: BottomSheetVCDelegate {
    
    func didTapDissmisReportContent() {
        
        SharedManager.shared.showAlertLoader(message: "Report concern sent successfully.", type: .alert)
        
    }
    
    func didTapUpdateAudioAndProgressStatus() {
    }
    
    
    func didTapBottomShareSheetAction(sender: UIButton, article: articlesData) {
        
        if sender.tag == 5 {
            
            //Block channel
            if self.sourceBlock {
                self.performWSToUnblockSource(channelInfo?.id ?? "", name: article.source?.name ?? "")
            }
            else {
                self.performBlockSource(channelInfo?.id ?? "", sourceName: article.source?.name ?? "")
            }
            
            
        }
        else if sender.tag == 10 {
           
            // Copy
            // write to clipboard
            UIPasteboard.general.string = shareTitle
            SharedManager.shared.showAlertLoader(message: "Copied to clipboard successfully", type: .alert)
        }
        
    }
}


import Foundation

extension String {
    func removingUrls() -> String {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return self
        }
        return detector.stringByReplacingMatches(in: self,
                                                 options: [],
                                                 range: NSRange(location: 0, length: self.utf16.count),
                                                 withTemplate: "")
    }
}

extension ChannelDetailsVC {
    
    func performWSToShare(id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.showLoaderInVC()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/articles/\(id)/share/info", method: .get, parameters: nil, headers: token, withSuccess: { [weak self] (response)  in
            
            self?.hideLoaderVC()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ShareSheetDC.self, from: response)
                
                //"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
                
                SharedManager.shared.instaMediaUrl = ""
                self?.shareTitle = FULLResponse.share_message ?? ""
                self?.articleArchived = FULLResponse.article_archived ?? false
                self?.sourceBlock = FULLResponse.source_blocked ?? false
                self?.sourceFollow = FULLResponse.source_followed ?? false

                
                self?.openViewMoreOptions(isopenForChannelReport: true)

                
            } catch let jsonerror {
                self?.hideLoaderVC()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUnblockSource(_ id: String, name:String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        self.showLoaderInVC()
        
        let param = ["sources":id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/sources/unblock", method: .post, parameters:param , headers: token, withSuccess: { (response) in
            
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(DeleteSourceDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                    
                    SharedManager.shared.showAlertLoader(message: "Unblocked \(name)", type: .alert)
                }
                else {
                    
                    SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: FULLResponse.message ?? "")
                }
                ANLoader.hide()
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/sources/unblock", error: jsonerror.localizedDescription, code: "")
                self.hideLoaderVC()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
    func performBlockSource(_ id: String, sourceName: String) {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.blockSource, eventDescription: "", source_id: id)
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let params = ["sources": id]
        WebService.URLResponse("news/sources/block", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(BlockTopicDC.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    if status == Constant.STATUS_SUCCESS {
                        
                        SharedManager.shared.showAlertLoader(message: "Blocked \(sourceName)", type: .alert)
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/sources/block", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    
}
