//
//  FollowersListVC.swift
//  Bullet
//
//  Created by Mahesh on 25/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class FollowersListVC: UIViewController {
    
    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblAllFollowers: UILabel!
    
    //NO SEARCH DATA VIEW
    @IBOutlet weak var viewNoSearch: UIView!
    @IBOutlet var lblCollectionNoSearch: [UILabel]!
    @IBOutlet weak var lblNoSearchTitle: UILabel!
    @IBOutlet weak var lblNoSearchDesc: UILabel!
    
    var isFromChannel = false
    var selectedChannel: ChannelInfo?
    var author: Author?
    var authorsArr = [Authors]()
    var nextPaginate = ""
    var searching: Bool = false
    var dismissKeyboard : (()-> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDesignView()
        
        if isFromChannel {
            lblNavTitle.text = selectedChannel?.name
        }
        else {
            lblNavTitle.text = (author?.first_name ?? "") + " " + (author?.last_name ?? "").trim()
        }
            
        lblAllFollowers.text = NSLocalizedString("All Followers", comment: "")
        //lblNoSearchTitle.text = NSLocalizedString("No results", comment: "")
        lblNoSearchTitle.text = NSLocalizedString("You don't have any followers yet", comment: "")
        lblNoSearchDesc.text = NSLocalizedString("Try a different keyword", comment: "")

        tableView.register(UINib(nibName: "AuthorsChildCC", bundle: nil), forCellReuseIdentifier: "AuthorsChildCC")

        self.getRefreshData()
    }
    
    func setDesignView() {
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        viewBG.theme_backgroundColor = GlobalPicker.textWBColor
        lblNavTitle.theme_textColor = GlobalPicker.textBWColor

        //search bar
        viewSearch.theme_backgroundColor = GlobalPicker.followingSearchBGColor
        txtSearch.delegate = self
        txtSearch.theme_placeholderAttributes = GlobalPicker.textPlaceHolderDiscover
        txtSearch.theme_tintColor = GlobalPicker.searchTintColor
        txtSearch.theme_textColor = GlobalPicker.textColor
        txtSearch.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

        viewNoSearch.isHidden = true
        lblCollectionNoSearch.forEach {
            $0.theme_textColor = GlobalPicker.textColor
        }
    }
    
    func getRefreshData() {
        
        self.searching = false
        nextPaginate = ""
        authorsArr = [Authors]()
        performWSToGetAuthorList(search: "")
    }

    @IBAction func didTapBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- WebService
extension FollowersListVC {
    
    func performWSToGetAuthorList(search: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        //var query = ""
        if self.nextPaginate.isEmpty {
            ANLoader.showLoading(disableUI: false)
        }
        
        let search = search.encodeUrl()
        //query = "studio/followers/?source=&query=\(search)&page=\(self.nextPaginate)"
        
        let params = ["source": isFromChannel ? selectedChannel?.id ?? "" : "",
                      "query": search,
                      "page": nextPaginate]

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("studio/followers", method: .get, parameters: params, headers: token, withSuccess: { (response) in
            
            do {
                
                let FULLResponse = try
                    JSONDecoder().decode(FollowerAuthorsDC.self, from: response)
                
                if let author = FULLResponse.users {
                    
                    if self.nextPaginate.isEmpty {
                        
                        self.authorsArr = author
                    }
                    else {
                        
                        self.authorsArr += author
                    }

                    //self.viewNoSearch.isHidden = true
                    //self.collectionView.isHidden = false
                    
                    if let meta = FULLResponse.meta {
                        self.nextPaginate = meta.next ?? ""
                    }
                    
                    ANLoader.hide()
                }
                
                if self.authorsArr.count > 0 {
                    
                    self.viewNoSearch.isHidden = true
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
                else {
                    self.viewNoSearch.isHidden = false
                    self.tableView.isHidden = true
                }


            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "studio/followers", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

//MARK: - TextField Delegate
extension FollowersListVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getTextOnStopTyping), object: textField)
        if let searchText = textField.text, !(searchText.isEmpty) {
            
            nextPaginate = ""
            self.perform(#selector(getTextOnStopTyping), with: textField, afterDelay: 0.5)
        }
        else {
            
            nextPaginate = ""
            performWSToGetAuthorList(search: "")
        }
    }
    
    @objc func getTextOnStopTyping(_ textField: UITextField) {
        
        performWSToGetAuthorList(search: textField.text ?? "")
    }
}

//MARK:- TableView DELEGATES and DATASOURCES
extension FollowersListVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.authorsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersListCC", for: indexPath) as! FollowersListCC
        
        let auth = self.authorsArr[indexPath.row]
        cell.imgTag?.sd_setImage(with: URL(string: auth.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" :"icn_profile_placeholder_light"))
        cell.lblTitle.text = auth.name
        cell.lblSubTitle.text = auth.username
                
        cell.didTapRemoveBlock = { [weak self] in
            
//            if let index = self?.authorsArr.firstIndex(where: { $0.id  == auth.id}) {
//                self?.authorsArr.remove(at: index)
//                self?.tableView.reloadData()
//
//            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let author = self.authorsArr[indexPath.row]
        if (author.id ?? "") == SharedManager.shared.userId {
            
            let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            //vc.delegate = self
            self.present(navVC, animated: true, completion: nil)
        }
        else {
            
            performWSToGetAuthor(author.id ?? "")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        dismissKeyboard?()
    }
    
    func performWSToGetAuthor(_ id: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading(disableUI: false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/authors/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(AuthorDC.self, from: response)
                
                if let author = FULLResponse.author {
                    
                    let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                    vc.author = author
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen
                    //vc.delegate = self
                    self.present(navVC, animated: true, completion: nil)
                }

            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/authors/\(id)", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
}
