//
//  UploadArticleBottomSheetVC.swift
//  Bullet
//
//  Created by Mahesh on 06/05/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol BottomSheetArticlesVCDelegate: class {
    
    func dismissBottomSheetArticlesVCDelegateAction(type: Int, idx: Int)
}

class BottomSheetArticlesVC: UIViewController {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet var lblCollection: [UILabel]!
    
    @IBOutlet weak var viewEdit: UIView!
    @IBOutlet weak var lblEdit: UILabel!
    
    @IBOutlet weak var viewDelete: UIView!
    @IBOutlet weak var lblDelete: UILabel!

    @IBOutlet weak var viewSave: UIView!
    @IBOutlet weak var lblSave: UILabel!
    @IBOutlet weak var imgSaveArticle: UIImageView!

    @IBOutlet weak var viewShare: UIView!
    @IBOutlet weak var lblShare: UILabel!
    //@IBOutlet weak var imgShare: UIImageView!

    var index = 0
    var article = articlesData()

//    var articlesList: [String]?
//    var isReportView = false
//    var selectedContent = [String]()
    
    var sourceBlock = false
    var sourceFollow = false
    var article_archived = false
    var share_message = ""
    
//    var showArticleType: ArticleType = .home
//    var isMainScreen = false
    var isFromReels = false

    weak var delegate: BottomSheetArticlesVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBG.theme_backgroundColor = GlobalPicker.backgroundColor
        
        self.setDesignView()
        self.setupLocalization()
    }
    
    override func viewDidLayoutSubviews() {
        
        viewBG.roundCorners([.topLeft, .topRight], 12)
    }
    
    func setDesignView() {
                
        lblCollection.forEach { lbl in
            lbl.theme_textColor = GlobalPicker.textColor
        }
        
        self.viewSave.isHidden = self.isFromReels
        self.viewShare.isHidden = self.isFromReels
    }
    
    func setupLocalization() {
        
        lblEdit.text = NSLocalizedString("Edit Article", comment: "")
        lblDelete.text = NSLocalizedString("Delete Article", comment: "")
        
        if article_archived {
            
            lblSave.text  = NSLocalizedString("Remove from Saved", comment: "")
            imgSaveArticle.theme_image = GlobalPicker.imgBookmarkSelectedWB
            //self.imgSaveArticle.image = UIImage(named: "bookmarkSelected")
        }
        else {
            
            lblSave.text  = NSLocalizedString("Save", comment: "")
            //self.imgSaveArticle.image = UIImage(named: "bookmark")
            imgSaveArticle.theme_image = GlobalPicker.imgBookmarkBottomSheet
        }
        lblShare.text = NSLocalizedString("Share", comment: "")
    }
    
    //MARK:- BUTTONN ACTION
    @IBAction func didTapUploadType(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            self.delegate?.dismissBottomSheetArticlesVCDelegateAction(type: sender.tag, idx: self.index)
        }
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            self.delegate?.dismissBottomSheetArticlesVCDelegateAction(type: -1, idx: self.index)
        }
    }
}
