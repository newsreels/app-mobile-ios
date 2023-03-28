//
//  ForYouPreferencesVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 18/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

enum PreferenceType {
    case reels, articles
}

protocol ForYouPreferencesVCDelegate: AnyObject {
    func userDismissed(vc: ForYouPreferencesVC, selectedPreference: Int, selectedCategory: String)
    func userChangedCategory()
}

class ForYouPreferencesVC: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewNav: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    
//    @IBOutlet weak var closeImage: UIImageView!
//
//    @IBOutlet weak var viewNavTransparent: UIView!
    
    @IBOutlet weak var loaderView: UIView!
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var forYouImageView: UIImageView!
    @IBOutlet weak var followingImageView: UIImageView!
        
    
    var channelsArray = [ChannelInfo]()
    var topicsArray = [TopicData]()
//    var suggestedArray = [TopicData]()
    var locationsArray = [Location]()
    var isSelectedRow = false
    var authorsArray = [ChannelInfo]()
    weak var delegate: ForYouPreferencesVCDelegate?
    
    var preferenceType: PreferenceType = .reels
    
    var currentSelection = 0
    var currentCategory = ""
    
    var isOpenReels = false
    var isOpenFromMenu = false
    var isOpenFromHome = false
    var isReelsTabNeeded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        hideCustomLoader()
        // Do any additional setup after loading the view.
        registerCells()
        tableView.delegate = self
        tableView.dataSource = self
        
        /*
        if isOpenReels {
//            tableView.contentInset = UIEdgeInsets(top: 130, left: 0, bottom: 50, right: 0)
            if isReelsTabNeeded {
                tableView.contentInset = UIEdgeInsets(top: 85, left: 0, bottom: 50, right: 0)
            }
            else {
                tableView.contentInset = UIEdgeInsets(top: 130, left: 0, bottom: 50, right: 0)
            }
        }
        else if isOpenFromMenu {
            tableView.contentInset = UIEdgeInsets(top: 130, left: 0, bottom: 50, right: 0)
        }
        else {
            tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 50, right: 0)
        }
        */
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        setupUI()
        
        setStatusBar()
        self.navigationController?.presentationController?.delegate = self
        
        
        switch preferenceType {
        case .reels:
            currentCategory = SharedManager.shared.curReelsCategoryId
        case .articles:
            currentCategory = SharedManager.shared.curArticlesCategoryId
        }
        
        
        if isOpenReels {
            headerHeightConstraint.constant = 0//128
        }
        else {
            headerHeightConstraint.constant = 0
        }
        
        self.view.layoutIfNeeded()
        self.tableView.updateHeaderViewHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SharedManager.shared.isOnPrefrence = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        SharedManager.shared.isOnPrefrence = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setStatusBar()
    }
    
    
    
    
    // MARK: - Methods
    func setupUI() {
        
        view.backgroundColor = UIColor(displayP3Red: 252.0/255, green: 252.0/255, blue: 252.0/255, alpha: 1)
        //Constant.appColor.backgroundGray
        
        titleLabel.text = NSLocalizedString("Categories", comment: "")
        
//        if isOpenReels {
//            titleLabel.text = "Personalize your reels"
//        }
//        else {
//            titleLabel.text = "Personalize your news"
//        }
        
        setPrefUI()
        
    }
    
    
    func setPrefUI() {
        if currentSelection == 0 {
            forYouImageView.image = UIImage(named: "icn_radio_selected")?.withRenderingMode(.alwaysTemplate)
            followingImageView.image = UIImage(named: "icn_radio_unselected")?.withRenderingMode(.alwaysTemplate)
        }
        else {
            forYouImageView.image = UIImage(named: "icn_radio_unselected")?.withRenderingMode(.alwaysTemplate)
            followingImageView.image =  UIImage(named: "icn_radio_selected")?.withRenderingMode(.alwaysTemplate)
        }

        forYouImageView.tintColor = Constant.appColor.lightRed
        followingImageView.tintColor = Constant.appColor.lightRed
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
    
    
    func registerCells() {

        self.tableView.register(UINib(nibName: "HomeCategoriesCC", bundle: nil), forCellReuseIdentifier: "HomeCategoriesCC")
        
        print("cells registered")
    }
    
    
    func showCustomLoader() {
        self.loaderView.isHidden = false
        self.loaderView.showLoader(color: Constant.appColor.lightRed, backgroundColorNeeded: false , isShowingFullScreenLoader: true)
    }
    
    func hideCustomLoader() {
        DispatchQueue.main.async {
            self.loaderView.isHidden = true
            self.loaderView.hideLoaderView()
        }
    }
    
    
    // MARK: - Actions
    @IBAction func didTapBack(_ sender: Any) {
        
        SharedManager.shared.isOnPrefrence = false
        self.delegate?.userDismissed(vc: self, selectedPreference: currentSelection, selectedCategory: currentCategory)
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapSearch(_ sender: Any) {
        
        let vc = SearchAllVC.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func didTapForYou(_ sender: Any) {
        
        currentSelection = 0
        setPrefUI()
        
        if isOpenFromHome  || isOpenReels {
            self.didTapBack(UIButton())
        }
    }
    
    @IBAction func didTapFollowing(_ sender: Any) {
        
        currentSelection = 1
        setPrefUI()
        
        if isOpenFromHome  || isOpenReels {
            self.didTapBack(UIButton())
        }
    }
    
    
}

extension ForYouPreferencesVC: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        self.delegate?.userDismissed(vc: self, selectedPreference: currentSelection, selectedCategory: currentCategory)
    }
}

extension ForYouPreferencesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if topicsArray.count > 0 {
//            self.loaderView.isHidden = true
//            return 4
//        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let emptyCell = UITableViewCell()
        emptyCell.selectionStyle = .none
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCategoriesCC") as! HomeCategoriesCC
        
//        if isOpenReels {
//            cell.setupCell(listArray: nil, isOpenReels: true, userSelected: "\(currentSelection)")
//        }
//        else {
//            cell.setupCell(listArray: SharedManager.shared.articlesCategories, isOpenReels: false, userSelected: currentCategory)
//        }
//
//
        cell.setupCell(listArray: preferenceType == .reels ? SharedManager.shared.reelsCategories : SharedManager.shared.articlesCategories, isOpenReels: false, userSelected: currentCategory)
        
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isOpenFromMenu {
             if indexPath.row == 0 {
                 return 0
            }
        }
        if isOpenReels {
            if isReelsTabNeeded == false{
                if indexPath.row == 0 {
                    return 0
               }
            }
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isOpenFromMenu {
             if indexPath.row == 0 {
                 return 0
            }
        }
        if isOpenReels {
            if isReelsTabNeeded == false{
                if indexPath.row == 0 {
                    return 0
               }
            }
        }
        return UITableView.automaticDimension
    }
    
    
}

extension ForYouPreferencesVC: HomeCategoriesCCDelegate {
    
    func didSelectedCell(cell: HomeCategoriesCC, itemIndex: Int, isOpenForReels: Bool) {
        
//        if isOpenForReels {
//
//            currentSelection = itemIndex
//            cell.userSelectedCategory = "\(self.currentSelection)"
//
//            cell.reloadCollectionViews()
//
//            setPrefUI()
//
//            if isOpenFromHome  || isOpenReels {
//                self.didTapBack(UIButton())
//            }
//        }
//        else {
//            if self.currentCategory != SharedManager.shared.articlesCategories[itemIndex].id ?? "" {
//                SharedManager.shared.curCategoryId = SharedManager.shared.articlesCategories[itemIndex].id ?? ""
//                self.delegate?.userChangedCategory()
//            }
//
//            self.currentCategory = SharedManager.shared.articlesCategories[itemIndex].id ?? ""
//
//            cell.userSelectedCategory = self.currentCategory
//
//            cell.reloadCollectionViews()
//
//            if isOpenFromHome  || isOpenReels {
//                self.didTapBack(UIButton())
//            }
//        }
                
        switch preferenceType {
        case .articles:
            if self.currentCategory != SharedManager.shared.articlesCategories[itemIndex].id ?? "" {
                SharedManager.shared.curArticlesCategoryId = SharedManager.shared.articlesCategories[itemIndex].id ?? ""
                self.delegate?.userChangedCategory()
            }
            self.currentCategory = SharedManager.shared.articlesCategories[itemIndex].id ?? ""
        case .reels:
            if self.currentCategory != SharedManager.shared.reelsCategories[itemIndex].id ?? "" {
                SharedManager.shared.curReelsCategoryId = SharedManager.shared.reelsCategories[itemIndex].id ?? ""
                self.delegate?.userChangedCategory()
            }
            self.currentCategory = SharedManager.shared.reelsCategories[itemIndex].id ?? ""
        }
        
        cell.userSelectedCategory = self.currentCategory
        
        cell.reloadCollectionViews()
        
        if isOpenFromHome  || isOpenReels {
            self.didTapBack(UIButton())
        }
        
        
    }
}
