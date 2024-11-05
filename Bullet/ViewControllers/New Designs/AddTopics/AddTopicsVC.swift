//
//  AddTopicsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 25/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol AddTopicsVCDelegate: AnyObject {
    func topicsListUpdated()
}

class AddTopicsVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var moreButton: UIButton!

    
    var myTopicsArray = [TopicData]()
    var suggestedTopicArray = [TopicData]()
    weak var delegate: AddTopicsVCDelegate?
    
    var isOpenForShowAll = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerCells()
        setLocalization()
        setupUI()
        
        performWSToGetUserFollowedTopics()
    }
    
    // MARK: - Methods
    func setupUI() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        moreButton.setTitleColor(Constant.appColor.lightRed, for: .normal)

        
    }
    
    func registerCells() {
        
        self.tableView.register(UINib(nibName: "TopicsCC", bundle: nil), forCellReuseIdentifier: "TopicsCC")
    }
    
    func setLocalization() {
        
        if isOpenForShowAll {
            titleLabel.text = NSLocalizedString("Topics", comment: "")
        }
        else {
            titleLabel.text = NSLocalizedString("Add Topics", comment: "")
        }
        
        closeButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        moreButton.setTitle("Find more", for: .normal)

    }
    
    
    // MARK: - Actions
    
    @IBAction func didTapClose(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    
    @IBAction func didTapSave(_ sender: Any) {
        
        SharedManager.shared.isTabReload = true
        self.performWSToUpdateFollowing()
    }
    
    
    @IBAction func didTapSearch(_ sender: Any) {
        
        let vc = SearchAllVC.instantiate(fromAppStoryboard: .Main)
        vc.currentSearchSelection = .topics
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    
}

extension AddTopicsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicsCC", for: indexPath) as! TopicsCC
        if indexPath.row == 0 {
            
            cell.descriptionLabel.text = "We’ll present more stories from your topics."
            cell.setupTopicsCell(topics: myTopicsArray, isOpenForAddOther: true)
            cell.titleLabel.text = "My Topics"
            
        }
        else if indexPath.row == 1 {
            
            cell.descriptionLabel.text = "We’ll present more stories from your topics."
            cell.setupTopicsCell(topics: suggestedTopicArray, isOpenForAddOther: true)
            cell.titleLabel.text = "Suggested Topics"
            
        }
        cell.delegate = self
        cell.layoutIfNeeded()
        cell.reloadCollectionViews()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = (cell as? TopicsCC) {
            if indexPath.row == 0 {
                cell.roundCorners(corners: [.topLeft,.topRight], radius: 14)
            }
            else {
                cell.roundCorners(corners: [.topLeft,.topRight], radius: 0)
            }
            cell.layoutSubviews()
        }
        
        
    }
}

extension AddTopicsVC: TopicsCCDelegate {
    
    func openAddOther(cell: TopicsCC) {
        
        /*
        if cell.topicArray.count > 0 {
            // Open add topics
            openAddLocation()
        }
        else if cell.locationsArray.count > 0 {
            // Open add locations
            openAddLocation()
        }*/
    }
    
    func didCellReloaded(cell: TopicsCC) {
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        if indexPath.row == 0 {
            self.myTopicsArray = cell.topicArray
        }
        else {
            self.suggestedTopicArray = cell.topicArray
        }
        self.tableView.reloadData()
        
    }
}

extension AddTopicsVC {
    
    //Followed Topics
    func performWSToGetUserFollowedTopics() {

        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.showLoaderInVC()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/topics/followed", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.performWSToGetSuggestedTopics()
            do {
                let FULLResponse = try
                    JSONDecoder().decode(TopicDC.self, from: response)
                
                self.myTopicsArray.removeAll()
                if let topics = FULLResponse.topics {
                    self.myTopicsArray = topics
                }
                
                self.tableView.reloadData()
            } catch let jsonerror {
                self.hideLoaderVC()
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetSuggestedTopics() {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        self.showLoaderInVC()
        WebService.URLResponse("news/topics/suggested", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            self.hideLoaderVC()
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(TopicDC.self, from: response)
                
                self.suggestedTopicArray.removeAll()
                if let topics = FULLResponse.topics {
                    self.suggestedTopicArray = topics
                }
                
                self.tableView.reloadData()
            } catch let jsonerror {
                
                self.hideLoaderVC()
                
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/topics/suggested", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToUpdateFollowing() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let selectedArray = (myTopicsArray + suggestedTopicArray).filter( {$0.favorite == true} )
        var selectedTopics = [String]()
        for top in selectedArray {
            selectedTopics.append(top.id ?? "")
        }
        #imageLiteral(resourceName: "simulator_screenshot_332CF9B1-3FB4-4A5C-B6FB-E3F027F4C510.png")
        
//        let params = ["topics":selectedTopics]
        
      
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
    
        self.showLoaderInVC()
        
        SharedManager.shared.performWSToUpdateUserFollow(id: selectedTopics, isFav: true, type: .topics) { status in
            
            self.hideLoaderVC()
            
            let selectedArray = (self.myTopicsArray + self.suggestedTopicArray).filter( {$0.favorite == false} )
            var unfollowingTopics = [String]()
            for top in selectedArray {
                unfollowingTopics.append(top.id ?? "")
            }
            
            self.showLoaderInVC()
            SharedManager.shared.performWSToUpdateUserFollow(id: unfollowingTopics, isFav: false, type: .topics) { status in
                
                self.hideLoaderVC()
                self.delegate?.topicsListUpdated()
                self.dismiss(animated: true)
            }
            
            
        }

    }
    
    
}



extension AddTopicsVC: SearchAllVCDelegate{
    
    func didTapCloseSearch() {
        
        self.myTopicsArray.removeAll()
        self.suggestedTopicArray.removeAll()
        self.tableView.reloadData()
        self.performWSToGetUserFollowedTopics()
    }
}
