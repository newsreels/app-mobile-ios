//
//  SearchAllVC.swift
//  Bullet
//
//  Created by Mahesh on 06/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol SearchAllVCDelegate: AnyObject {
    
    func didTapCloseSearch()
}

class SearchAllVC: UIViewController {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgSearch: UIImageView!
    
    @IBOutlet weak var searchContainerView: UIView!
    
    
    let headerViewMinHeight: CGFloat = 90 + UIApplication.shared.statusBarFrame.height
//    var relevantVC: RelevantVC?
//    var articlesVC: articlesChildVC?
    
    var searchPageVC: SearchPageViewController?
    var searchText = ""
    var isViewLoadFirstTime = false
    var currentSearchSelection = SearchPageViewController.searchType.all
    var delegate: SearchAllVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.hidesBottomBarWhenPushed = true
        
        searchContainerView.layer.cornerRadius = 8
        searchContainerView.layer.borderWidth = 1
        searchContainerView.layer.borderColor = UIColor(red: 0.871, green: 0.908, blue: 0.95, alpha: 1).cgColor
        
        
        //LOCALIZABLE STRING
        txtName.placeholder = NSLocalizedString("Search", comment: "")
        txtName.placeholderColor = Constant.appColor.lightGray
        
//        self.view.theme_backgroundColor = GlobalPicker.tabBarTintColor
        self.view.backgroundColor = .white
        viewBG.theme_backgroundColor = GlobalPicker.backgroundColor
        imgBack.theme_image = GlobalPicker.imgBack
     //   viewSearch.theme_backgroundColor = GlobalPicker.backgroundSearchBG
        txtName.delegate = self
        txtName.theme_placeholderAttributes = GlobalPicker.textPlaceHolderDiscover
        
    //    txtName.theme_tintColor = GlobalPicker.searchTintColor
    //    txtName.theme_textColor = GlobalPicker.textColor
        
        self.view.layoutIfNeeded()
        
        containerView.theme_backgroundColor = GlobalPicker.backgroundColor
        isViewLoadFirstTime = true
        
        containerView.isHidden = false
        SharedManager.shared.subTabBarType = .Relevant
        
        if txtName.text?.isEmpty ?? true {
            self.refreshVC()
        }
        else {
            self.getSearchContent(search: txtName.text ?? "")
        }
        
        self .txtName.delegate = self
        self .txtName.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifySearchVC, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapNotifySearchVC(_:)), name: Notification.Name.notifySearchVC, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.txtName.becomeFirstResponder()
        }
        
        setSearchButtonUI()
        
        
        self.navigationController?.presentationController?.delegate = self
        self.presentationController?.delegate = self
        
    }
    
    // MARK : - Search Methods
    func refreshVC() {
        
        searchPageVC?.refreshVC()

    }
    
    func getSearchContent(search: String) {
        
        searchPageVC?.getSearchContent(search: txtName.text ?? "")

    }
    
    
    func appEnteredBackground() {
        
        searchPageVC?.appEnteredBackground()

        
    }
    
    
    func appLoadedToForeground() {
        searchPageVC?.appLoadedToForeground()
    }
    
    func stopAll() {
        
        searchPageVC?.stopAll()

    }
    
    
    
    @objc func tabBarTapped(notification: Notification) {
    
        self.didTapBack(self)
    }
    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.txtName.semanticContentAttribute = .forceRightToLeft
                self.txtName.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.txtName.semanticContentAttribute = .forceLeftToRight
                self.txtName.textAlignment = .left
            }
        }
    }
    
    
    @objc func didTapNotifySearchVC(_ notification: NSNotification) {
        
        self.delegate?.didTapCloseSearch()
        self.navigationController?.popViewController(animated: false)
        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SharedManager.shared.bulletPlayer?.pause()
        SharedManager.shared.bulletPlayer?.stop()
        SharedManager.shared.bulletPlayer?.currentTime = 0
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedFromBackgroundToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tabBarTapped(notification:)), name: Notification.Name.notifySearchTabBarTapped, object: nil)
        
    }
    
    // MARK: - Background Service Methods
    @objc func appMovedToBackground() {
        
        if containerView.isHidden == false {
            
            SharedManager.shared.bulletPlayer?.pause()
            SharedManager.shared.bulletPlayer?.stop()
            
            
            
            self.appEnteredBackground()
            
        }
    }
    
    @objc func appMovedFromBackgroundToForeground() {
        
        if containerView.isHidden == false {

            self.appLoadedToForeground()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? SearchPageViewController {
            
            self.searchPageVC = vc
            self.searchPageVC?.currentSearchSelection = self.currentSearchSelection
//            vc.delegate = self
//            relevantVC = vc

            vc.dismissKeyboard = {
                self.view.endEditing(true)
            }
        }
    }
    
    func clearSearchData() {
        
        self.stopAll()
        txtName.resignFirstResponder()
        txtName.text = ""
        self.view.endEditing(true)

        self.refreshVC()
    
        setSearchButtonUI()
    }
    
    func setSearchButtonUI() {
        
        let search = txtName.text ?? ""
        if search.isEmpty {
            imgSearch.image = UIImage(named: "onBoardingSearch")
        }
        else {
            imgSearch.image = UIImage(named: "onBoardingClear")
        }
        
    }
    
    //MARK:- Button Action
    @IBAction func didTapClearAction(_ sender: Any) {
        
        let search = txtName.text ?? ""
        if search.isEmpty == false {
            self.clearSearchData()
        }
        
        
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        
        self.clearSearchData()
        containerView.isHidden = true
        SharedManager.shared.subTabBarType = .none
        
        self.delegate?.didTapCloseSearch()
        self.navigationController?.popViewController(animated: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    func didTapSearch() {
        
        stopAll()
        SharedManager.shared.bulletPlayer?.pause()
        SharedManager.shared.bulletPlayer?.stop()
        
        
        
        
        SharedManager.shared.articleSearchListVCShowing = false
        
        containerView.isHidden = false
        
        SharedManager.shared.subTabBarType = .Relevant
        
        if txtName.text?.isEmpty ?? true {
            self.refreshVC()
        }
        else {
        
            self.getSearchContent(search: txtName.text ?? "")
        }
    }
}

extension SearchAllVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        self.searchText = textField.text ?? ""
        
//        self.relevantVC?.updateProgressbarStatus(isPause: true)
        WebService.cancelAPIRequest()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getTextOnStopTyping), object: textField)
        
        if let searchText = textField.text, !(searchText.isEmpty) {
            
//            self.articlesVC?.articles.removeAll()
//            self.articlesVC?.nextPaginate = ""
//            self.articlesVC?.tableViewList.contentOffset = .zero
            self.perform(#selector(getTextOnStopTyping), with: textField, afterDelay: 0.5)
        }
        else {
            
            self.view.endEditing(true)
            
            if containerView.isHidden == false {
                
                self.refreshVC()
            }
        }
        
        setSearchButtonUI()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if containerView.isHidden == false {
            
            print("didTapSearch")
//            self.didTapSearch()
        }
        return true
    }
    
    @objc func getTextOnStopTyping(_ textField: UITextField) {
        
        if containerView.isHidden == false {
            

            self.getSearchContent(search: txtName.text ?? "")
        }
    }
}

// MARK: - Relevant VC Delegate
extension SearchAllVC: RelevantVCDelegate {
    
    func userDidSelectViewAll(type: RelevantVC.searchType) {
        
        self.didTapSearch()
    }
}


extension SearchAllVC: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        self.delegate?.didTapCloseSearch()
    }
}

