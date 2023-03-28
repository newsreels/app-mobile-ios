//
//  DraftSavedArticlesVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 10/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol DraftSavedArticlesVCDelegate: AnyObject {
    
    func backButtonPressedDraftSavedArticlesVC()
}

class DraftSavedArticlesVC: UIViewController {
    
    @IBOutlet weak var lblNavTitle: UILabel!
//    @IBOutlet weak var imgBack: UIImageView!

    var profileVC = DraftSavedArticlesPageVC()
    var isFirstLoadView = true
    weak var delegate: DraftSavedArticlesVCDelegate?
    var isFromDrafts = false
    var isFromSaveArticles = false
    
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
        if let vc = segue.destination as? DraftSavedArticlesPageVC {
            
            profileVC = vc
            //profileVC.pageDelegate = self
            profileVC.isFromDrafts = isFromDrafts
            profileVC.isFromSaveArticles = isFromSaveArticles
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL() {
                self.lblNavTitle.semanticContentAttribute = .forceRightToLeft
                self.lblNavTitle.textAlignment = .right
            } else {
                self.lblNavTitle.semanticContentAttribute = .forceLeftToRight
                self.lblNavTitle.textAlignment = .left
            }
        }
        
    }
    
    
    func setDesignView() {
        
        self.view.backgroundColor = .white
//        view.theme_backgroundColor = GlobalPicker.backgroundColor
//        imgBack.theme_image = GlobalPicker.imgBack
        
        lblNavTitle.theme_textColor = GlobalPicker.textColor
        
        if isFromDrafts {
            lblNavTitle.text = NSLocalizedString("DRAFTS", comment: "").capitalized
        } else if isFromSaveArticles {
            lblNavTitle.text = NSLocalizedString("FAVORITES", comment: "").capitalized
        } else {
            lblNavTitle.text = ""
        }
        
    }
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapBackAction(_ sender: Any) {
        
        SharedManager.shared.bulletPlayer = nil
        if let vc = profileVC.currentViewController as? ProfileArticlesVC {
            vc.updateProgressbarStatus(isPause: true)
        }
        
        self.delegate?.backButtonPressedDraftSavedArticlesVC()
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
        
    }
}


