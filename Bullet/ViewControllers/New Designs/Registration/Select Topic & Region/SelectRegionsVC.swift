//
//  SelectRegionsVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 11/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class SelectRegionsVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var desc2Label: UILabel!
    
    @IBOutlet weak var selectedCollectionView: UICollectionView!
    @IBOutlet weak var locationsCollectionView: UICollectionView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var selectedCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationsCollectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var moreButton: UIButton!
    
    var topicsArray = [TopicData]()
    var locationsArray = [Location]()
    var selectedLocationsArray = [Location]()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        registerCell()
        setLocalization()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        reloadCollectionViews()
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        
        
        self.locationsCollectionViewHeightConstraint.constant = self.locationsCollectionView.contentSize.height > 50 ? self.locationsCollectionView.contentSize.height : 50
        self.selectedCollectionViewHeightConstraint.constant = self.selectedCollectionView.contentSize.height > 10 ? self.selectedCollectionView.contentSize.height : 10
        
    }
    

    func reloadCollectionViews() {
        
        locationsCollectionView.collectionViewLayout.invalidateLayout()
        selectedCollectionView.collectionViewLayout.invalidateLayout()
        locationsCollectionView.reloadData()
        selectedCollectionView.reloadData()
        self.viewWillLayoutSubviews()
    }
    
    // MARK: - Methods
    func setupUI() {
        
        selectedCollectionView.delegate = self
        selectedCollectionView.dataSource = self
        locationsCollectionView.delegate = self
        locationsCollectionView.dataSource = self
        let layout1 = UICollectionViewCenterLayout()
        layout1.estimatedItemSize = CGSize(width: 140, height: 50)
        locationsCollectionView.collectionViewLayout = layout1
        
        let layout2 = UICollectionViewCenterLayout()
        layout2.estimatedItemSize = CGSize(width: 140, height: 50)
        selectedCollectionView.collectionViewLayout = layout2
        
        
        moreButton.setTitleColor(Constant.appColor.lightRed, for: .normal)

        
    }
    
    func registerCell() {
        
        selectedCollectionView.register(UINib(nibName: "SelectTopicCC", bundle: nil), forCellWithReuseIdentifier: "SelectTopicCC")
        locationsCollectionView.register(UINib(nibName: "SelectTopicCC", bundle: nil), forCellWithReuseIdentifier: "SelectTopicCC")
    }
    
    
    func setLocalization() {
        
        titleLabel.text = NSLocalizedString("Enter your location or select a country of interest", comment: "")
        descLabel.text = NSLocalizedString("Discover curated content from your fav places.", comment: "")
        title2Label.text = NSLocalizedString("Additional recommended locations", comment: "")
        desc2Label.text = NSLocalizedString("Discover curated content from your fav places.", comment: "")
        
        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        moreButton.setTitle("Find more", for: .normal)
        
        
    }

    // MARK: - Actions

    @IBAction func didTapSave(_ sender: Any) {
        
        performWSToUpdateUserOnboarding()
        /*
        if selectedLocationsArray.count >= 1 {
            performWSToUpdateUserOnboarding()
        }
        else {
            SharedManager.shared.showAlertLoader(message: "Please select atleast 1 locations", type: .error)
        }*/
        
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapSearch(_ sender: Any) {
        
        let vc = SearchAllVC.instantiate(fromAppStoryboard: .Main)
        vc.currentSearchSelection = .locations
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
}

extension SelectRegionsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == selectedCollectionView {
            return selectedLocationsArray.count
        }
        else {
            return locationsArray.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectTopicCC", for: indexPath) as! SelectTopicCC
        
        if collectionView == selectedCollectionView {
            cell.setupCell(location: selectedLocationsArray[indexPath.row], isSelected: true)
        }
        else {
            cell.setupCell(location: locationsArray[indexPath.row], isSelected: false)
        }
        
        cell.delegate = self
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == locationsCollectionView {
            selectedLocationsArray.append(locationsArray[indexPath.row])
            locationsArray.remove(at: indexPath.row)
        }
        
        reloadCollectionViews()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }
    
}

extension SelectRegionsVC: SelectTopicCCDelegate {

    func didTapClose(cell: SelectTopicCC) {
        
        guard let indexPath = selectedCollectionView.indexPath(for: cell) else {
            return
        }
        locationsArray.append(selectedLocationsArray[indexPath.row])
        selectedLocationsArray.remove(at: indexPath.row)
        
        reloadCollectionViews()
        
    }
}

extension SelectRegionsVC {
    
    func performWSToUpdateUserOnboarding() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        var selectedTopicsArray = [String]()
        for topic in self.topicsArray {
            selectedTopicsArray.append(topic.id ?? "")
        }
        var selectedLoc = [String]()
        for loc in self.selectedLocationsArray {
            selectedLoc.append(loc.id ?? "")
        }
        
        var params = ["topics":selectedTopicsArray, "languages": [SharedManager.shared.languageId]]
        if selectedLoc.count > 0 {
            params = ["topics":selectedTopicsArray, "regions":selectedLoc, "languages": [SharedManager.shared.languageId]]
        }
        
      
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
    
        self.showLoaderInVC()
        
        WebService.URLResponseJSONRequest("news/onboarding", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            self.hideLoaderVC()
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                SharedManager.shared.isOnboardingPreferenceLoaded = true
                SharedManager.shared.isSavedPreferenceAlertRequired = true
                SharedManager.shared.setThemeAutomatic()
                self.appDelegate?.setHomeVC()
                if let status = FULLResponse.message?.uppercased() {
                    
                    print("read status", status)
                }
                
            } catch let jsonerror {
                self.hideLoaderVC()
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            self.hideLoaderVC()
            print("error parsing json objects",error)
        }

    }
}

extension SelectRegionsVC: SearchAllVCDelegate{
    
    func didTapCloseSearch() {
        
//        self.topicsArray.removeAll()
//        self.locationsArray.removeAll()
//        self.collectionView.reloadData()
//        self.performWSToGetOnboarding()
        
    }
}

