//
//  ReelsContainerVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 15/07/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import MapKit

class ReelsContainerVC: UIViewController {

    @IBOutlet weak var lblSelection: UILabel!
    @IBOutlet weak var viewCategorySelection: UIView!
    @IBOutlet weak var reelsContainerView: UIView!

    @IBOutlet weak var arrowImageView: UIImageView!
    var pageVC: ReelsPageVC?
    var currentSelectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        /*
        addShadowText(label: lblVerified, text: "Verified", font: UIFont(name: Constant.FONT_Mulli_BOLD, size: 20)!)
        addShadowText(label: lblCommunity, text: "Community", font: UIFont(name: Constant.FONT_Mulli_REGULAR, size: 18)!)
        
        // Calculate max width
        addShadowText(label: lblVerifiedDummy, text: "Verified", font: UIFont(name: Constant.FONT_Mulli_BOLD, size: 20)!)
        addShadowText(label: lblCommunityDummy, text: "Community", font: UIFont(name: Constant.FONT_Mulli_BOLD, size: 20)!)
        
        self.dummyView.isHidden = true
        self.dummyView.layoutIfNeeded()
        categoryWidthConstraint.constant = self.dummyView.frame.size.width
        
        viewSeparator.backgroundColor = .white
        
        */
        
//        reelsFilterImagView.layer.shadowColor = UIColor.black.cgColor
//        reelsFilterImagView.layer.shadowOffset = CGSize(width: 0, height: 1)
//        reelsFilterImagView.layer.shadowOpacity = 0.3
//
//        reelsNotificationsImageView.layer.shadowColor = UIColor.black.cgColor
//        reelsNotificationsImageView.layer.shadowOffset = CGSize(width: 0, height: 1)
//        reelsNotificationsImageView.layer.shadowOpacity = 0.3
        
        
//        forYouButton.layer.cornerRadius = 12
//        followingButton.layer.cornerRadius = 12
        
        
        arrowImageView.layer.shadowColor = UIColor.black.cgColor
        arrowImageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        arrowImageView.layer.shadowOpacity = 0.3
        arrowImageView.layer.shadowRadius = 0.5
        
        selectPageUI(page: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeCategory), name: .didChangeReelsTopics, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @objc func didChangeCategory() {
        
        lblSelection.text = SharedManager.shared.reelsCategories.first(where: {$0.id == SharedManager.shared.curReelsCategoryId})?.title ?? "N/A"
    }
    
    func selectPageUI(page: Int) {
        
//        let selectedColor = UIColor.white
//        let unselectedColor = UIColor(displayP3Red: 0.969, green: 0.204, blue: 0.345, alpha: 1)
//
        if page == 0 {
            addShadowText(label: lblSelection, text: NSLocalizedString("For you", comment: ""), font: UIFont(name: Constant.FONT_ROBOTO_MEDIUM, size: 19)!)
        }
        else {
            addShadowText(label: lblSelection, text: NSLocalizedString("Following", comment: ""), font: UIFont(name: Constant.FONT_ROBOTO_MEDIUM, size: 19)!)
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ReelsPageVC {
            vc.reelsContVC = self
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
    
    
    @IBAction func didTapForYou(_ sender: Any) {
        selectPageUI(page: 0)
        self.pageVC?.changeViewController(index: 0)
    }
    
    @IBAction func didTapFollowing(_ sender: Any) {
        selectPageUI(page: 1)
        self.pageVC?.changeViewController(index: 1)
    }
    
    @IBAction func didTapSelection(_ sender: Any) {
        
        SharedManager.shared.filterType = "reels"
        (self.pageVC?.viewControllers?.first as? ReelsVC)?.didTapFilter(isTabNeeded: true)
        
    }
    
    @IBAction func didTapFilter(_ sender: Any) {
        
        (self.pageVC?.viewControllers?.first as? ReelsVC)?.didTapFilter(isTabNeeded: true)
        
    }
    
    @IBAction func didTapNotifications(_ sender: Any) {
        (self.pageVC?.viewControllers?.first as? ReelsVC)?.didTapNotifications()
    }
    
    
    
}

extension ReelsContainerVC: TutorialVCDelegate {
    
    func userDismissed(vc: TutorialVC) {
    }
    
    
}


extension ReelsContainerVC: ReelsVCDelegate {
    
    func changeScreen(pageIndex: Int) {
        
        selectPageUI(page: pageIndex)
        self.pageVC?.changeViewController(index: pageIndex)
        
    }
    
    func switchBackToForYou() {
        
        didTapForYou(UIButton())
    }
    
    func backButtonPressed(_ isUpdateSavedArticle: Bool) {
    }
    
    func loaderShowing(status: Bool) {
        
        if status {
//            viewCategorySelection.isHidden = true
        }
        else {
//            viewCategorySelection.isHidden = false
        }
        
    }
    
    func currentPlayingVideoChanged(newIndex: IndexPath) {
        
//        if newIndex.item == 0 {
//            viewCategorySelection.isHidden = false
//        }
//        else {
//            if newIndex.item > currentSelectedIndex {
//                viewCategorySelection.isHidden = true
//            }
//            else if newIndex.item == currentSelectedIndex {
//
//            }
//            else {
//                viewCategorySelection.isHidden = false
//            }
//        }
//
        currentSelectedIndex = newIndex.item
        lblSelection.isHidden = currentSelectedIndex == 0 ? false : true
        
    }
    
}


