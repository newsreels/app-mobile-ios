//
//  NotificationsListVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 26/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol NotificationsListVCDelegate: AnyObject {
    func backButtonPressed()
}

class NotificationsListVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNews: UILabel!
    @IBOutlet weak var lblGeneral: UILabel!
    @IBOutlet weak var lblNoChannel: UILabel!
    
    @IBOutlet weak var btnGeneral: UIButton!
    @IBOutlet weak var btnNews: UIButton!
    
    @IBOutlet weak var viewNewsSelectedBar: UIView!
    @IBOutlet weak var viewGeneralSelectedBar: UIView!
    
    @IBOutlet weak var tbNotifications: UITableView!
    
    //PAGINATION VARIABLES
    var nextPaginate = ""
    
    var arrNewsNotifications: [Notifications]?
    var arrGeneralNewNotifications: [NotificationsDetail]?
    var arrGeneralNotifications: [NotificationsDetail]?
    var notificationsType = "General"
    weak var delegate: NotificationsListVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocalizableString()
        
        lblTitle.theme_textColor = GlobalPicker.backgroundColorBlackWhite
        view.theme_backgroundColor = GlobalPicker.customTabbarBGColor
        lblNoChannel.theme_textColor = GlobalPicker.textSubColorDiscover
        viewNewsSelectedBar.roundCorners([.topLeft, .topRight], 6.0)
        viewGeneralSelectedBar.roundCorners([.topLeft, .topRight], 6.0)
        
        tbNotifications.rowHeight = UITableView.automaticDimension
        tbNotifications.estimatedRowHeight = UITableView.automaticDimension
        
        self.didTapSelectedNewsType(self.btnGeneral)
        
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
        
    }
    
    func setLocalizableString() {
        
        lblTitle.text = NSLocalizedString("Notifications", comment: "")
        lblGeneral.text = NSLocalizedString("General", comment: "")
        lblNews.text = NSLocalizedString("News", comment: "")
    }
    
    @objc func swipedLeft(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            
            if notificationsType != "News" {
                
                self.didTapSelectedNewsType(self.btnNews)
            }
        }
    }
    
    @objc func swipedRight(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            
            if notificationsType == "News" {
                
                self.didTapSelectedNewsType(self.btnGeneral)
            }
        }
    }
    
    lazy var leftSwipeGestureRecognizer: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .left
        gesture.addTarget(self, action: #selector(swipedLeft))
        return gesture
    }()
    
    lazy var rightSwipeGestureRecognizer: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .right
        gesture.addTarget(self, action: #selector(swipedRight))
        return gesture
    }()
    
    //Buttons action
    @IBAction func didTapBack(_ sender: Any) {
        
        self.delegate?.backButtonPressed()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSelectedNewsType(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            //General
            notificationsType = "General"
            self .performWSToGetGeneralNotifications()
            UIView.transition(with: viewGeneralSelectedBar, duration: 0.4, options: .transitionCrossDissolve, animations: {
                
                self.viewGeneralSelectedBar.isHidden = false
                self.lblGeneral.theme_textColor = GlobalPicker.backgroundColorBlackWhite
                self.viewNewsSelectedBar.isHidden = true
                self.lblNews.theme_textColor = GlobalPicker.textForYouSubTextSubColor
            })
        }
        else {
            
            //News
            notificationsType = "News"
            self .performWSToGetNewsNotifications()
            UIView.transition(with: viewNewsSelectedBar, duration: 0.4, options: .transitionCrossDissolve, animations: {
                
                self.viewNewsSelectedBar.isHidden = false
                self.lblNews.theme_textColor = GlobalPicker.backgroundColorBlackWhite
                self.viewGeneralSelectedBar.isHidden = true
                self.lblGeneral.theme_textColor = GlobalPicker.textForYouSubTextSubColor
            })
        }
    }
}

//MARK: - tableview Delegate and DaraSource
extension NotificationsListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if notificationsType == "News" {
            
            return 1
        }
        else {
          
            if (self.arrGeneralNewNotifications?.count ?? 0) > 0 || (self.arrGeneralNotifications?.count ?? 0) > 0 {
      
                return 2
            }
            else {
                
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if notificationsType == "News" {
            
            return self.arrNewsNotifications?.count ?? 0
        }
        else {
            
            if section == 0 {
                
                return self.arrGeneralNewNotifications?.count ?? 0
            }
            else {
                
                return self.arrGeneralNotifications?.count ?? 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "NotificationCellHeaderCC") as! NotificationCellHeaderCC
        if section == 0 {
            
            headerCell.lblTitle.text = NSLocalizedString("NEW", comment: "")
        }
        else {
            headerCell.lblTitle.text = NSLocalizedString("EARLIER", comment: "")
                
        }
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if notificationsType == "News" {
            
            if let Notifications = self.arrNewsNotifications?[indexPath.row] {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsNewsCC") as! NotificationsNewsCC
                cell.setupCell(notifications: Notifications)
                cell.viewDividerLine.isHidden = false
                let count = self.arrNewsNotifications?.count ?? 0
                if indexPath.row == count - 1 {
                    cell.viewDividerLine.isHidden = true
                }
                
                return cell
            }
        }
        else {
            
            if indexPath.section == 0 {
                
                if let Notifications = self.arrGeneralNewNotifications?[indexPath.row] {
                    
                    if Notifications.type?.uppercased() == "ARTICLE" || Notifications.type?.uppercased() == "REEL" {
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsNewsCC") as! NotificationsNewsCC
                        cell.setupGeneralCell(notifications: Notifications)
                        return cell
                    }
                    else if Notifications.type?.uppercased() == "ARTICLE_LIKE" || Notifications.type?.uppercased() == "REEL_LIKE" {
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsLikeCC") as! NotificationsLikeCC
                        cell.setupCell(notifications: Notifications)
                        return cell
                    }
                    else if Notifications.type?.uppercased() == "ARTICLE_COMMENT" || Notifications.type?.uppercased() == "REEL_COMMENT" || Notifications.type?.uppercased() == "FOLLOW" {
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCommentsCC") as! NotificationCommentsCC
                        cell.setupCell(notifications: Notifications)
                        return cell
                    }
                }
            }
            else {
                
                if let Notifications = self.arrGeneralNotifications?[indexPath.row] {
                    
                    if Notifications.type?.uppercased() == "ARTICLE" || Notifications.type?.uppercased() == "REEL" {

                        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsNewsCC") as! NotificationsNewsCC
                        cell.setupGeneralCell(notifications: Notifications)
                        return cell
                    }
                    else if Notifications.type?.uppercased() == "ARTICLE_LIKE" || Notifications.type?.uppercased() == "REEL_LIKE" {

                        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsLikeCC") as! NotificationsLikeCC
                        cell.setupCell(notifications: Notifications)
                        return cell
                    }
                    else if Notifications.type?.uppercased() == "ARTICLE_COMMENT" || Notifications.type?.uppercased() == "REEL_COMMENT" || Notifications.type?.uppercased() == "FOLLOW" {

                        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCommentsCC") as! NotificationCommentsCC
                        cell.setupCell(notifications: Notifications)
                        return cell
                    }
                }
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        if notificationsType == "News" {
            
            return 0
        }
        else {
            
            if section == 0 && self.arrGeneralNewNotifications?.count ?? 0 > 0 {
                
                return 62
            } else if section == 1 && self.arrGeneralNotifications?.count ?? 0 > 0 {
                return 62
            }
            else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if notificationsType == "News" {
            
            //News
            if let notification = self.arrNewsNotifications?[indexPath.row] {
                
                self.performWSToUpdateReadNotification(ids: notification.id ?? "")
                if notification.type?.uppercased() == "REEL_LIKE" || notification.type?.uppercased() == "REEL_COMMENT" || notification.type?.uppercased() == "REEL" {

                    self.pustToReelVC(context: notification.detail_id ?? "")
                    
                }
                else{
 
                    self.performWSViewArticle(notification.detail_id ?? "")
                }
            }
        }
        else {
            
            //General
            if indexPath.section == 0 {
                
                if let notification = self.arrGeneralNewNotifications?[indexPath.row] {
                    
                    self.performWSToUpdateReadNotification(ids: notification.id ?? "")
                    if notification.type?.uppercased() == "REEL_LIKE" || notification.type?.uppercased() == "REEL_COMMENT" || notification.type?.uppercased() == "REEL" {

                        self.pustToReelVC(context: notification.detail_id ?? "")
                    }
                    else{
                        
                        self.performWSViewArticle(notification.detail_id ?? "")
                    }
                }
            }
            else {
                
                if let notification = self.arrGeneralNotifications?[indexPath.row] {
                    
                    self.performWSToUpdateReadNotification(ids: notification.id ?? "")
                    
                    if notification.type?.uppercased() == "FOLLOW" {
                        return
                    }
                    if notification.type?.uppercased() == "REEL_LIKE" || notification.type?.uppercased() == "REEL_COMMENT" || notification.type?.uppercased() == "REEL" {

                        self.pustToReelVC(context: notification.detail_id ?? "")
                    }
                    else{
                        
                        self.performWSViewArticle(notification.detail_id ?? "")
                    }
                }
            }
        }
    }
    
    func pustToReelVC(context: String) {
        
        let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
        vc.contextID = context
        vc.isBackButtonNeeded = true
        vc.isOpenfromNotificationList = true
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
        
    }
}

//MARK: - Notifications Webservices
extension NotificationsListVC {
    
    //News Notifications
    func performWSToGetNewsNotifications() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("notification/list/news", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(NotificationsDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let Notifications = FULLResponse.notifications, Notifications.count > 0 {
                        
                        self.lblNoChannel.isHidden = true
                        self.tbNotifications.isHidden = false
                        self.arrNewsNotifications = Notifications
                        if let meta = FULLResponse.meta {
                            
                            self.nextPaginate = meta.next ?? ""
                        }
                        UIView.transition(with: self.tbNotifications, duration: 0.4, options: .transitionCrossDissolve, animations: { self.tbNotifications.reloadData() })
                    }
                    else {
                        
                        self.lblNoChannel.isHidden = false
                        self.tbNotifications.isHidden = true
                        self.arrNewsNotifications?.removeAll()
                        self.tbNotifications.reloadData()
                        
                    }
                }
                ANLoader.hide()
                
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    //General Notifications
    func performWSToGetGeneralNotifications() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        ANLoader.showLoading(disableUI: false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("notification/list/general", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(generalNotificationsDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    self.arrGeneralNewNotifications?.removeAll()
                    self.arrGeneralNotifications?.removeAll()
                    if let newNotifications = FULLResponse.new, newNotifications.count > 0 {
                        
                        self.arrGeneralNewNotifications = newNotifications
                    }
                    if let generalNotifications = FULLResponse.notifications, generalNotifications.count > 0 {
                        
                        self.arrGeneralNotifications = generalNotifications
                    }
               
                    if self.arrGeneralNewNotifications?.count ?? 0 > 0 || self.arrGeneralNotifications?.count ?? 0 > 0 {
                        
                        self.lblNoChannel.isHidden = true
                        self.tbNotifications.isHidden = false
                    }
                    else {
                        
                        self.lblNoChannel.isHidden = false
                        self.tbNotifications.isHidden = true
                    }
                    if let meta = FULLResponse.meta {
                        
                        self.nextPaginate = meta.next ?? ""
                    }
                    UIView.transition(with: self.tbNotifications, duration: 0.4, options: .transitionCrossDissolve, animations: { self.tbNotifications.reloadData() })
                }
                ANLoader.hide()
                
            } catch let jsonerror {
                
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSViewArticle(_ id: String) {
  
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: true)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/articles/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do {
                let FULLResponse = try
                    JSONDecoder().decode(viewArticleDC.self, from: response)
                
                if let article = FULLResponse.article {
                    
                    let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
                    vc.isRelatedArticletNeeded = false
                    vc.selectedArticleData = article
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    
                    SharedManager.shared.showAlertLoader(message: FULLResponse.message ?? NSLocalizedString("Not Found.", comment: ""))
                }
                
            } catch let jsonerror {
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/articles/\(id)", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToUpdateReadNotification(ids: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        var IdsArr = [String]()
        IdsArr.append(ids)
        let params = ["ids": IdsArr]
      
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
    
        WebService.URLResponseJSONRequest("notification/read", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    print("read status", status)
                }
                
            } catch let jsonerror {
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "notification/read", error: jsonerror.localizedDescription, code: "")
            }
        }) { (error) in
            print("error parsing json objects",error)
        }

    }
    
    func performWSToGetMyReelsData(id: String) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
       
        WebService.URLResponse("news/reels?context=\(id)", method: .get, parameters: nil, headers: token, withSuccess: { [weak self] (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ReelsModel.self, from: response)
                if let reelsData = FULLResponse.reels, reelsData.count > 0 {
       
                    print(reelsData)
                } else {
                  
                    
                    print("Empty Result")
                }
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            print("error parsing json objects",error)
        }
    }
}
