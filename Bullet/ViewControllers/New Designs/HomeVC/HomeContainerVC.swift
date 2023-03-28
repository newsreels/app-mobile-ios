//
//  HomeContainerVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 21/03/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class HomeContainerVC: UIViewController {
    
    @IBOutlet weak var viewCategorySelection: UIView!
    @IBOutlet weak var reelsContainerView: UIView!
    @IBOutlet weak var navTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var circularView: GMView!
    @IBOutlet weak var lblSelection: UILabel!
    @IBOutlet weak var downArrowImageView: UIImageView!
    
    
    var pageVC: HomePageVC?
    let normalTopTabBarConstraint: CGFloat = 0
    let hiddenTopTabBarConstraint: CGFloat = -60
    
    @IBOutlet weak var navView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        view.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        
//        reelsFilterImagView.layer.shadowColor = UIColor.black.cgColor
//        reelsFilterImagView.layer.shadowOffset = CGSize(width: 0, height: 1)
//        reelsFilterImagView.layer.shadowOpacity = 0.3
//
//        reelsNotificationsImageView.layer.shadowColor = UIColor.black.cgColor
//        reelsNotificationsImageView.layer.shadowOffset = CGSize(width: 0, height: 1)
//        reelsNotificationsImageView.layer.shadowOpacity = 0.3
        
        
//        forYouButton.layer.cornerRadius = 12
//        followingButton.layer.cornerRadius = 12
//        viewForYou.addShadowCustom(cornerRadius: 12, shadowColor: Constant.appColor.shadowColorDark, shadowRadius: 10, shadowOpacity: 1, shadowOffset: CGSize(width: 0, height: 5))
//
//        lblSelection.addShadow(cornerRadius: 12, fillColor: .clear)
//        downArrowImageView.addShadowCustom(cornerRadius: 12, shadowColor: Constant.appColor.shadowColorDark, shadowRadius: 10, shadowOpacity: 1, shadowOffset: CGSize(width: 0, height: 5))
        
        
        
        selectPageUI(page: 0)
        
        homeScrollViewDidScroll(delta: -1, animated: false)
        
        setStatusBarColor(isDark: true)
        
        loaderView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        homeScrollViewDidScroll(delta: -1)
        addNSNotifications()
        (pageVC?.viewControllers?.first as? HomeVC)?.pageViewControllerViewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeNSNotifications()
        (pageVC?.viewControllers?.first as? HomeVC)?.pageViewControllerViewWillDisappear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setStatusBarColor(isDark: true)
    }
    
    
    func addNSNotifications() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyAppFromBackground, object: nil)
//        NotificationCenter.default.removeObserver(SharedManager.shared.observerArray)
        NotificationCenter.default.addObserver(forName: Notification.Name.notifyAppFromBackground, object: nil, queue: nil) { [weak self] notification in
            
            (self?.pageVC?.viewControllers?.first as? HomeVC)?.notifyAppBackgroundEvent()
        }
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyHomeVolumn, object: nil)
        NotificationCenter.default.addObserver(forName: Notification.Name.notifyHomeVolumn, object: nil, queue: nil) { [weak self] notification in
            
            (self?.pageVC?.viewControllers?.first as? HomeVC)?.didTapVolume()
        }
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyVideoVolumeStatus, object: nil)
        NotificationCenter.default.addObserver(forName: Notification.Name.notifyVideoVolumeStatus, object: nil, queue: nil) { [weak self] notification in
            
            (self?.pageVC?.viewControllers?.first as? HomeVC)?.didTapUpdateVideoVolumeStatus(notification: notification)
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: Notification.Name.notifyOrientationChange, object: nil)
        
        NotificationCenter.default.addObserver(forName: .EZPlayerStatusDidChange, object: nil, queue: nil) { [weak self] notification in
            (self?.pageVC?.viewControllers?.first as? HomeVC)?.videoPlayerStatus(notification)

        }
    }
    
    func removeNSNotifications() {
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyAppFromBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyVideoVolumeStatus, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyHomeVolumn, object: nil)
    }
    
    @objc func orientationChanged() {
        
        (pageVC?.viewControllers?.first as? HomeVC)?.orientationChange()
        
    }
    
    
    func setStatusBarColor(isDark: Bool) {
        
        var navVC = (self.navigationController?.navigationController as? AppNavigationController)
        if navVC == nil {
            navVC = (self.navigationController as? AppNavigationController)
        }
        if navVC?.showDarkStatusBar == false {
            navVC?.showDarkStatusBar = true
            navVC?.setNeedsStatusBarAppearanceUpdate()
        }
        
        /*
        if isDark {
            if navVC?.showDarkStatusBar == false {
                navVC?.showDarkStatusBar = true
                navVC?.setNeedsStatusBarAppearanceUpdate()
            }
        }
        else {
            if navVC?.showDarkStatusBar == true {
                navVC?.showDarkStatusBar = false
                navVC?.setNeedsStatusBarAppearanceUpdate()
            }
        }*/
        
    }
    
    
    func selectPageUI(page: Int) {
        
//        let selectedColor = UIColor.white
//        let unselectedColor = UIColor(displayP3Red: 0.969, green: 0.204, blue: 0.345, alpha: 1)
        
        if page == 0 {
            lblSelection.text = NSLocalizedString("For you", comment: "")
        }
        else {
            lblSelection.text = NSLocalizedString("Following", comment: "")
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HomePageVC {
            vc.homeContVC = self
            self.pageVC = vc
        }
    }
    
    
    func addShadowText(label: UILabel, text: String, font: UIFont) {
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 2
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .shadow: shadow
        ]
        
        let s = text
        let attributedText = NSAttributedString(string: s, attributes: attrs)
        label.attributedText = attributedText
        
        label.layoutIfNeeded()
    }
    
    
    // MARK: - Button Actions
    @IBAction func didTapVerified(_ sender: Any) {
        /*
         UIView.animate(withDuration: 0.25, delay: 0, options: .transitionCrossDissolve) {
         self.addShadowText(label: self.lblVerified, text: "Verified", font: UIFont(name: Constant.FONT_Mulli_BOLD, size: 20)!)
         self.addShadowText(label: self.lblCommunity, text: "Community", font: UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)!)
         self.view.layoutIfNeeded()
         } completion: { status in
         }
         */
        self.pageVC?.changeViewController(index: 0)
    }
    
    
    @IBAction func didTapCommunity(_ sender: Any) {
        /*
         UIView.animate(withDuration: 0.25, delay: 0, options: .transitionCrossDissolve) {
         self.addShadowText(label: self.lblVerified, text: "Verified", font: UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)!)
         self.addShadowText(label: self.lblCommunity, text: "Community", font: UIFont(name: Constant.FONT_Mulli_BOLD, size: 20)!)
         self.view.layoutIfNeeded()
         } completion: { status in
         }
         */
        self.pageVC?.changeViewController(index: 1)
    }
    
    
    @IBAction func didTapSelection(_ sender: Any) {
        
        (self.pageVC?.viewControllers?.first as? HomeVC)?.didTapFilter()
        
    }
    
    
    @IBAction func didTapForYou(_ sender: Any) {
        selectPageUI(page: 0)
        self.pageVC?.changeViewController(index: 0)
    }
    
    @IBAction func didTapFollowing(_ sender: Any) {
        selectPageUI(page: 1)
        self.pageVC?.changeViewController(index: 1)
    }
    
    @IBAction func didTapFilter(_ sender: Any) {
        
        (self.pageVC?.viewControllers?.first as? HomeVC)?.didTapFilter()
        
    }
    
    @IBAction func didTapNotifications(_ sender: Any) {
        
        (self.pageVC?.viewControllers?.first as? HomeVC)?.didTapNotifications()
    }
    
    
    
}


extension HomeContainerVC: HomeVCDelegate {
    
    func changeScreen(pageIndex: Int) {
        
        selectPageUI(page: pageIndex)
        self.pageVC?.changeViewController(index: pageIndex)
    }
    
    
    func switchBackToForYou() {
        
        didTapForYou(UIButton())
    }
    
    func backButtonPressed() {
    }
    
    func loaderShowing(status: Bool) {
        
        
        if status {
            viewCategorySelection.isHidden = true
//            viewFilter.isHidden = true
//            viewNotifications.isHidden = true
            
            self.loaderView.isHidden = false
            
            setStatusBarColor(isDark: false)
        }
        else {
            viewCategorySelection.isHidden = false
//            viewFilter.isHidden = false
//            viewNotifications.isHidden = false
            
            self.loaderView.isHidden = true
            
            setStatusBarColor(isDark: true)
        }
        
    }
    
    func homeScrollViewDidScroll(delta: CGFloat, animated: Bool) {

        DispatchQueue.main.async {
            if delta < 0 {
                // the value is negative, so we're scrolling up and the view is moving back into view.
                // take whatever is smaller, the constant minus delta or 0
                SharedManager.shared.isTopTabBarCurrentlHidden = false
                if self.navTopConstraint?.constant != self.normalTopTabBarConstraint {
                    
                    if animated {
                        UIView.animate(withDuration: 0.5) {
                            self.navTopConstraint?.constant = self.normalTopTabBarConstraint
                            self.navView.alpha = 1
                            self.view.layoutIfNeeded()
                            
                        }
                    }
                    else {
                        self.navTopConstraint?.constant = self.normalTopTabBarConstraint
                        self.navView.alpha = 1
                        self.view.layoutIfNeeded()
                    }
                    
                }
                //min(pageViewNormalY - delta, 0)
            } else {
                // the value is positive, so we're scrolling down and the view is moving out of sight.
                // take whatever is "larger," the constant minus delta, or the minimumConstantValue.
                SharedManager.shared.isTopTabBarCurrentlHidden = true
                if self.navTopConstraint?.constant != self.hiddenTopTabBarConstraint {
                    if animated {
                        UIView.animate(withDuration: 0.5) {
                            self.navTopConstraint?.constant = self.hiddenTopTabBarConstraint
                            self.navView.alpha = 0
                            self.view.layoutIfNeeded()
                            
                        }
                    }
                    else {
                        self.navTopConstraint?.constant = self.hiddenTopTabBarConstraint
                        self.navView.alpha = 0
                        self.view.layoutIfNeeded()
                    }
                    
                    
                }
            }
        }
        
    }
    
    
}
